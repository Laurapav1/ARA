import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final Map<String, List<String>>? errors;

  ApiException(this.statusCode, this.message, {this.errors});

  @override
  String toString() => 'ApiException($statusCode): $message';
}

class ApiClient {
  final String baseUrl;
  final http.Client _client;

  ApiClient(this.baseUrl, [http.Client? client])
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> getJson(
    String path, {
    String? token,
  }) async {
    final res = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
    );
    return _handle(res);
  }

  Future<dynamic> getAny(
    String path, {
    String? token,
  }) async {
    final res = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
    );
    return _handleAny(res);
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final res = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body ?? {}),
    );
    return _handle(res);
  }

  Future<dynamic> postAny(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final res = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body ?? {}),
    );
    return _handleAny(res);
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final res = await _client.put(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: jsonEncode(body ?? {}),
    );
    return _handle(res);
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, dynamic>? body,
    String? token,
  }) async {
    final res = await _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers(token),
      body: body == null ? null : jsonEncode(body),
    );
    return _handle(res);
  }

  String _messageWithValidationDetails(
    String message,
    Map<String, List<String>>? errors,
  ) {
    if (errors == null || errors.isEmpty) return message;
    final firstEntry = errors.entries.firstWhere(
      (entry) => entry.value.isNotEmpty,
      orElse: () => const MapEntry('', <String>[]),
    );
    if (firstEntry.value.isEmpty) return message;
    final detail = firstEntry.key.isEmpty
        ? firstEntry.value.first
        : '${firstEntry.key}: ${firstEntry.value.first}';
    if (message == 'Validation failed' || message == 'Request failed') {
      return detail;
    }
    return '$message ($detail)';
  }

  Map<String, String> _headers(String? token) {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };
    if (token != null && token.isNotEmpty) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Map<String, dynamic> _handle(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return {};
      return jsonDecode(res.body) as Map<String, dynamic>;
    }

    String message = 'Request failed';
    Map<String, List<String>>? errors;
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      message = body['error']?.toString() ?? message;
      final rawErrors = body['errors'];
      if (rawErrors is Map<String, dynamic>) {
        errors = rawErrors.map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => e.toString()).toList(),
          ),
        );
      }
    } catch (_) {}

    throw ApiException(
      res.statusCode,
      _messageWithValidationDetails(message, errors),
      errors: errors,
    );
  }

  dynamic _handleAny(http.Response res) {
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (res.body.isEmpty) return null;
      return jsonDecode(res.body);
    }

    String message = 'Request failed';
    Map<String, List<String>>? errors;
    try {
      final body = jsonDecode(res.body) as Map<String, dynamic>;
      message = body['error']?.toString() ?? message;
      final rawErrors = body['errors'];
      if (rawErrors is Map<String, dynamic>) {
        errors = rawErrors.map(
          (key, value) => MapEntry(
            key,
            (value as List<dynamic>).map((e) => e.toString()).toList(),
          ),
        );
      }
    } catch (_) {}

    throw ApiException(
      res.statusCode,
      _messageWithValidationDetails(message, errors),
      errors: errors,
    );
  }
}
