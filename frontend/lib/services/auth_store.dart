import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/me_response.dart';
import 'api_client.dart';
import 'api_config.dart';

enum AuthStatus { anonymous, pending, approved }

class AuthStore extends ChangeNotifier {
  AuthStore() {
    _client = ApiClient(ApiConfig.baseUrl);
    _init();
  }

  late final ApiClient _client;

  String? _accessToken;
  String? _refreshToken;
  MeResponse? _me;
  bool _loading = false;

  bool get isLoading => _loading;
  MeResponse? get me => _me;
  String? get accessToken => _accessToken;

  AuthStatus get status {
    if (_me == null) return AuthStatus.anonymous;
    if (_me!.status.toLowerCase() == 'approved') return AuthStatus.approved;
    return AuthStatus.pending;
  }

  bool get isStaff => _me?.role.toLowerCase() == 'staff';
  bool get isApproved => status == AuthStatus.approved || isStaff;
  bool get isPending => status == AuthStatus.pending;

  Future<void> _init() async {
    _loading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');

    if (_accessToken != null) {
      try {
        await fetchMe();
      } catch (_) {}
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> signUp({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String volunteerFrom,
    required String volunteerTo,
  }) async {
    await _client.postJson(
      '/api/auth/signUp',
      body: {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'password': password,
        'volunteerFrom': volunteerFrom,
        'volunteerTo': volunteerTo,
      },
    );
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final res = await _client.postJson(
      '/api/auth/login',
      body: {'email': email, 'password': password},
    );
    _accessToken = res['token']?.toString();
    _refreshToken = res['refreshToken']?.toString();
    _me = MeResponse.fromJson(res['user'] as Map<String, dynamic>);
    await _persistTokens();
    notifyListeners();
  }

  Future<void> refresh() async {
    if (_refreshToken == null) return;
    final res = await _client.postJson(
      '/api/auth/refresh',
      body: {'refreshToken': _refreshToken},
    );
    _accessToken = res['token']?.toString();
    _refreshToken = res['refreshToken']?.toString();
    _me = MeResponse.fromJson(res['user'] as Map<String, dynamic>);
    await _persistTokens();
    notifyListeners();
  }

  Future<void> fetchMe() async {
    if (_accessToken == null) return;
    final res = await _client.getJson('/api/auth/me', token: _accessToken);
    _me = MeResponse.fromJson(res);
    notifyListeners();
  }

  Future<void> logout() async {
    if (_accessToken != null) {
      try {
        await _client.postJson('/api/auth/logout', token: _accessToken);
      } catch (_) {}
    }
    _accessToken = null;
    _refreshToken = null;
    _me = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    notifyListeners();
  }

  Future<void> _persistTokens() async {
    final prefs = await SharedPreferences.getInstance();
    if (_accessToken != null) {
      await prefs.setString('accessToken', _accessToken!);
    }
    if (_refreshToken != null) {
      await prefs.setString('refreshToken', _refreshToken!);
    }
  }
}
