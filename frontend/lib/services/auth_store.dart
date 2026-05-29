import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/me_response.dart';
import 'api_client.dart';
import 'api_config.dart';
import 'optimistic_sync_store.dart';

enum AuthStatus { anonymous, pending, approved }

class AuthStore extends ChangeNotifier {
  static const _pendingAccessRequestKey = 'pendingAccessRequest';
  static const _retryDelay = Duration(seconds: 15);
  static const _accessRequestSyncKey = 'access_request';

  AuthStore(this._syncStore) {
    _client = ApiClient(ApiConfig.baseUrl);
    _init();
  }

  late final ApiClient _client;
  OptimisticSyncStore _syncStore;

  String? _accessToken;
  String? _refreshToken;
  MeResponse? _me;
  _PendingAccessRequest? _pendingAccessRequest;
  Timer? _retryTimer;
  bool _loading = false;
  bool _isSyncingPendingAccessRequest = false;
  bool _pendingAccessRequestSyncFailed = false;
  int _pendingRequestsCount = 0;

  bool get isLoading => _loading;
  MeResponse? get me => _me;
  String? get accessToken => _accessToken;
  int get pendingRequestsCount => _pendingRequestsCount;
  bool get hasPendingAccessRequest => _pendingAccessRequest != null;
  bool get isSyncingPendingAccessRequest => _isSyncingPendingAccessRequest;
  bool get pendingAccessRequestSyncFailed => _pendingAccessRequestSyncFailed;
  bool get pendingAccessRequestSynced =>
      _pendingAccessRequest != null &&
      _pendingAccessRequest!.syncedAt != null &&
      !_isSyncingPendingAccessRequest &&
      !_pendingAccessRequestSyncFailed;
  String? get pendingVolunteerFrom =>
      _me?.volunteerFrom ?? _pendingAccessRequest?.volunteerFrom;
  String? get pendingVolunteerTo =>
      _me?.volunteerTo ?? _pendingAccessRequest?.volunteerTo;
  String get pendingEmail => _me?.email ?? _pendingAccessRequest?.email ?? '';

  AuthStatus get status {
    if (_me == null) {
      return _pendingAccessRequest == null
          ? AuthStatus.anonymous
          : AuthStatus.pending;
    }
    if (_me!.status.toLowerCase() == 'approved') return AuthStatus.approved;
    return AuthStatus.pending;
  }

  bool get isStaff => _me?.role.toLowerCase() == 'staff';
  bool get isApproved => status == AuthStatus.approved || isStaff;
  bool get isPending => status == AuthStatus.pending;

  void setSyncStore(OptimisticSyncStore syncStore) {
    if (identical(_syncStore, syncStore)) return;
    _syncStore = syncStore;
    if (_pendingAccessRequest != null &&
        (_isSyncingPendingAccessRequest || _pendingAccessRequestSyncFailed)) {
      _syncStore.queueOperation(
        key: _accessRequestSyncKey,
        retry: retryPendingAccessRequestNow,
      );
      if (_pendingAccessRequestSyncFailed) {
        _syncStore.markFailed(_accessRequestSyncKey);
      }
    }
  }

  Future<void> _init() async {
    _loading = true;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString('accessToken');
    _refreshToken = prefs.getString('refreshToken');
    _pendingAccessRequest = _decodePendingAccessRequest(
      prefs.getString(_pendingAccessRequestKey),
    );

    if (_accessToken != null) {
      try {
        await fetchMe();
        await refreshPendingRequestsCount();
      } catch (_) {}
    }

    if (_pendingAccessRequest != null && _me == null) {
      _syncStore.queueOperation(
        key: _accessRequestSyncKey,
        retry: retryPendingAccessRequestNow,
      );
      unawaited(_syncPendingAccessRequest().catchError((_) {}));
    }

    _loading = false;
    notifyListeners();
  }

  Future<void> submitPendingAccessRequest({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
    required String volunteerFrom,
    required String volunteerTo,
  }) async {
    _pendingAccessRequest = _PendingAccessRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      volunteerFrom: volunteerFrom,
      volunteerTo: volunteerTo,
      createdAt: DateTime.now().toUtc(),
    );
    _pendingAccessRequestSyncFailed = false;
    _retryTimer?.cancel();
    await _persistPendingAccessRequest();
    _syncStore.queueOperation(
      key: _accessRequestSyncKey,
      retry: retryPendingAccessRequestNow,
    );
    notifyListeners();
    unawaited(_syncPendingAccessRequest().catchError((_) {}));
  }

  Future<void> retryPendingAccessRequestNow() async {
    if (_pendingAccessRequest == null) return;
    _retryTimer?.cancel();
    await _syncPendingAccessRequest(force: true);
  }

  Future<void> _syncPendingAccessRequest({bool force = false}) async {
    final pending = _pendingAccessRequest;
    if (pending == null) return;
    if (_isSyncingPendingAccessRequest && !force) return;

    _isSyncingPendingAccessRequest = true;
    _pendingAccessRequestSyncFailed = false;
    _syncStore.markSyncing(_accessRequestSyncKey);
    notifyListeners();

    try {
      await _client.postJson(
        '/api/auth/signUp',
        body: {
          'firstName': pending.firstName,
          'lastName': pending.lastName,
          'email': pending.email,
          'password': pending.password,
          'volunteerFrom': pending.volunteerFrom,
          'volunteerTo': pending.volunteerTo,
        },
      );
      _pendingAccessRequest = pending.copyWith(syncedAt: DateTime.now().toUtc());
      await _persistPendingAccessRequest();
      _syncStore.markSucceeded(_accessRequestSyncKey);
    } on ApiException catch (e) {
      if (_isRetryableSignupFailure(e.statusCode)) {
        _pendingAccessRequestSyncFailed = true;
        _syncStore.markFailed(_accessRequestSyncKey);
        _scheduleRetry();
      } else {
        _clearPendingAccessRequest();
        await _persistPendingAccessRequest();
        _syncStore.clearOperation(_accessRequestSyncKey);
        _isSyncingPendingAccessRequest = false;
        notifyListeners();
        rethrow;
      }
    } catch (_) {
      _pendingAccessRequestSyncFailed = true;
      _syncStore.markFailed(_accessRequestSyncKey);
      _scheduleRetry();
    } finally {
      if (_pendingAccessRequest != null) {
        _isSyncingPendingAccessRequest = false;
        notifyListeners();
      }
    }
  }

  bool _isRetryableSignupFailure(int statusCode) {
    return statusCode == 408 ||
        statusCode == 425 ||
        statusCode == 429 ||
        statusCode >= 500;
  }

  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(_retryDelay, () {
      unawaited(_syncPendingAccessRequest().catchError((_) {}));
    });
  }

  _PendingAccessRequest? _decodePendingAccessRequest(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return _PendingAccessRequest.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> _persistPendingAccessRequest() async {
    final prefs = await SharedPreferences.getInstance();
    if (_pendingAccessRequest == null) {
      await prefs.remove(_pendingAccessRequestKey);
      return;
    }
    await prefs.setString(
      _pendingAccessRequestKey,
      jsonEncode(_pendingAccessRequest!.toJson()),
    );
  }

  void _clearPendingAccessRequest() {
    _retryTimer?.cancel();
    _pendingAccessRequest = null;
    _pendingAccessRequestSyncFailed = false;
    _syncStore.clearOperation(_accessRequestSyncKey);
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
    _me = _meFromAuthPayload(res);
    if (_me == null && _accessToken != null && _accessToken!.isNotEmpty) {
      final meRes = await _client.getJson('/api/auth/me', token: _accessToken);
      _me = MeResponse.fromJson(meRes);
    }
    _clearPendingAccessRequest();
    await _persistTokens();
    await _persistPendingAccessRequest();
    await refreshPendingRequestsCount();
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
    _me = _meFromAuthPayload(res);
    if (_me == null && _accessToken != null && _accessToken!.isNotEmpty) {
      final meRes = await _client.getJson('/api/auth/me', token: _accessToken);
      _me = MeResponse.fromJson(meRes);
    }
    _clearPendingAccessRequest();
    await _persistTokens();
    await _persistPendingAccessRequest();
    await refreshPendingRequestsCount();
    notifyListeners();
  }


  MeResponse? _meFromAuthPayload(Map<String, dynamic> payload) {
    final user = payload['user'];
    if (user is Map<String, dynamic>) {
      return MeResponse.fromJson(user);
    }
    return null;
  }
  Future<void> fetchMe() async {
    if (_accessToken == null) return;
    final res = await _client.getJson('/api/auth/me', token: _accessToken);
    _me = MeResponse.fromJson(res);
    _clearPendingAccessRequest();
    await _persistPendingAccessRequest();
    await refreshPendingRequestsCount();
    notifyListeners();
  }

  void setPendingRequestsCount(int count) {
    if (_pendingRequestsCount == count) return;
    _pendingRequestsCount = count;
    notifyListeners();
  }

  Future<void> refreshPendingRequestsCount() async {
    if (_accessToken == null || !isStaff) {
      if (_pendingRequestsCount != 0) {
        _pendingRequestsCount = 0;
        notifyListeners();
      }
      return;
    }
    try {
      final res = await _client.getAny(
        '/api/volunteers/pending',
        token: _accessToken,
      );
      final list = res is List ? res : (res?['items'] as List<dynamic>? ?? []);
      setPendingRequestsCount(list.length);
    } catch (_) {}
  }


  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_accessToken == null || _accessToken!.isEmpty) {
      throw ApiException(401, 'Please sign in again.');
    }
    await _client.postJson(
      '/api/auth/change-password',
      token: _accessToken,
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
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
    _clearPendingAccessRequest();
    _pendingRequestsCount = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('accessToken');
    await prefs.remove('refreshToken');
    await prefs.remove(_pendingAccessRequestKey);
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

  @override
  void dispose() {
    _retryTimer?.cancel();
    super.dispose();
  }
}

class _PendingAccessRequest {
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String volunteerFrom;
  final String volunteerTo;
  final DateTime createdAt;
  final DateTime? syncedAt;

  const _PendingAccessRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.volunteerFrom,
    required this.volunteerTo,
    required this.createdAt,
    this.syncedAt,
  });

  _PendingAccessRequest copyWith({
    DateTime? syncedAt,
  }) {
    return _PendingAccessRequest(
      firstName: firstName,
      lastName: lastName,
      email: email,
      password: password,
      volunteerFrom: volunteerFrom,
      volunteerTo: volunteerTo,
      createdAt: createdAt,
      syncedAt: syncedAt,
    );
  }

  factory _PendingAccessRequest.fromJson(Map<String, dynamic> json) {
    return _PendingAccessRequest(
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      password: json['password']?.toString() ?? '',
      volunteerFrom: json['volunteerFrom']?.toString() ?? '',
      volunteerTo: json['volunteerTo']?.toString() ?? '',
      createdAt: DateTime.parse(json['createdAt'].toString()),
      syncedAt: json['syncedAt'] == null
          ? null
          : DateTime.parse(json['syncedAt'].toString()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'volunteerFrom': volunteerFrom,
      'volunteerTo': volunteerTo,
      'createdAt': createdAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
    };
  }
}


