import 'dart:convert';

import 'api_client.dart';

class InformationService {
  InformationService(this._client);

  final ApiClient _client;

  Future<dynamic> getDocument(String key, {String? token}) async {
    try {
      final res = await _client.getAny(
        '/api/information/${Uri.encodeComponent(key)}',
        token: token,
      );
      if (res is Map<String, dynamic>) {
        return res['data'];
      }
      return null;
    } on ApiException catch (e) {
      if (e.statusCode == 404) return null;
      rethrow;
    }
  }

  Future<void> saveDocument(
    String key,
    dynamic data, {
    required String token,
  }) async {
    await _client.putJson(
      '/api/information/${Uri.encodeComponent(key)}',
      token: token,
      body: {'data': data},
    );
  }

  static String encodeIconData({
    required int codePoint,
    String? fontFamily,
    String? fontPackage,
    required bool matchTextDirection,
  }) {
    return jsonEncode({
      'codePoint': codePoint,
      'fontFamily': fontFamily,
      'fontPackage': fontPackage,
      'matchTextDirection': matchTextDirection,
    });
  }
}

