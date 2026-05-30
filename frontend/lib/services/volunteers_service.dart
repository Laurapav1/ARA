import 'package:intl/intl.dart';
import 'api_client.dart';
import 'api_config.dart';

class VolunteerStay {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String status;
  final String createdAt;
  final String? volunteerFrom;
  final String? volunteerTo;
  final bool isReturning;
  final int previousStayCount;
  final String? lastStayFrom;
  final String? lastStayTo;

  VolunteerStay({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.status,
    required this.createdAt,
    required this.volunteerFrom,
    required this.volunteerTo,
    required this.isReturning,
    required this.previousStayCount,
    required this.lastStayFrom,
    required this.lastStayTo,
  });

  String get fullName => '$firstName $lastName'.trim();
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isCancelled => status.toLowerCase() == 'cancelled';
  bool get isDeclined => status.toLowerCase() == 'declined';

  String get requestedAtLabel {
    try {
      final parsed = DateTime.parse(createdAt);
      return DateFormat('d MMM yyyy').format(parsed);
    } catch (_) {
      return createdAt;
    }
  }

  String get stayLabel {
    if (volunteerFrom == null || volunteerTo == null) return 'Not specified';
    try {
      final start = DateTime.parse(volunteerFrom!);
      final end = DateTime.parse(volunteerTo!);
      return '${DateFormat('d MMM yyyy').format(start)} - ${DateFormat('d MMM yyyy').format(end)}';
    } catch (_) {
      return '$volunteerFrom - $volunteerTo';
    }
  }

  String get lastStayLabel {
    if (lastStayFrom == null || lastStayTo == null) return 'No previous stays';
    try {
      final start = DateTime.parse(lastStayFrom!);
      final end = DateTime.parse(lastStayTo!);
      return '${DateFormat('d MMM yyyy').format(start)} - ${DateFormat('d MMM yyyy').format(end)}';
    } catch (_) {
      return '$lastStayFrom - $lastStayTo';
    }
  }


  VolunteerStay copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? status,
    String? createdAt,
    String? volunteerFrom,
    String? volunteerTo,
    bool? isReturning,
    int? previousStayCount,
    String? lastStayFrom,
    String? lastStayTo,
  }) {
    return VolunteerStay(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      volunteerFrom: volunteerFrom ?? this.volunteerFrom,
      volunteerTo: volunteerTo ?? this.volunteerTo,
      isReturning: isReturning ?? this.isReturning,
      previousStayCount: previousStayCount ?? this.previousStayCount,
      lastStayFrom: lastStayFrom ?? this.lastStayFrom,
      lastStayTo: lastStayTo ?? this.lastStayTo,
    );
  }
  factory VolunteerStay.fromJson(Map<String, dynamic> json) {
    return VolunteerStay(
      id: json['id'].toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      volunteerFrom: json['volunteerFrom']?.toString(),
      volunteerTo: json['volunteerTo']?.toString(),
      isReturning: json['isReturning'] == true,
      previousStayCount:
          int.tryParse(json['previousStayCount']?.toString() ?? '') ?? 0,
      lastStayFrom: json['lastStayFrom']?.toString(),
      lastStayTo: json['lastStayTo']?.toString(),
    );
  }
}

class MyVolunteerStay {
  final String id;
  final String status;
  final String volunteerFrom;
  final String volunteerTo;
  final String requestedAt;

  MyVolunteerStay({
    required this.id,
    required this.status,
    required this.volunteerFrom,
    required this.volunteerTo,
    required this.requestedAt,
  });

  bool get isPending => status.toLowerCase() == 'pending';
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isDeclined => status.toLowerCase() == 'declined';
  bool get isCancelled => status.toLowerCase() == 'cancelled';

  String get stayLabel {
    try {
      final start = DateTime.parse(volunteerFrom);
      final end = DateTime.parse(volunteerTo);
      return '${DateFormat('d MMM yyyy').format(start)} - ${DateFormat('d MMM yyyy').format(end)}';
    } catch (_) {
      return '$volunteerFrom - $volunteerTo';
    }
  }

  factory MyVolunteerStay.fromJson(Map<String, dynamic> json) {
    return MyVolunteerStay(
      id: json['id'].toString(),
      status: json['status']?.toString() ?? '',
      volunteerFrom: json['volunteerFrom']?.toString() ?? '',
      volunteerTo: json['volunteerTo']?.toString() ?? '',
      requestedAt: json['requestedAt']?.toString() ?? '',
    );
  }
}

class VolunteersService {
  VolunteersService({ApiClient? client})
      : _client = client ?? ApiClient(ApiConfig.baseUrl);

  final ApiClient _client;

  Future<List<VolunteerStay>> getAll({required String token}) async {
    final res = await _client.getAny('/api/volunteers/stays', token: token);
    final list = res is List ? res : (res?['items'] as List<dynamic>? ?? []);
    return list
        .map((item) => VolunteerStay.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<VolunteerStay>> getPending({required String token}) async {
    final res = await _client.getAny('/api/volunteers/pending', token: token);
    final list = res is List ? res : (res?['items'] as List<dynamic>? ?? []);
    return list
        .map((item) => VolunteerStay.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<List<MyVolunteerStay>> getMine({required String token}) async {
    final res = await _client.getAny('/api/volunteers/me/stays', token: token);
    final list = res is List ? res : (res?['items'] as List<dynamic>? ?? []);
    return list
        .map((item) => MyVolunteerStay.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> requestNewStay({
    required String token,
    required String volunteerFrom,
    required String volunteerTo,
  }) async {
    await _client.postJson(
      '/api/volunteers/me/stays',
      token: token,
      body: {
        'volunteerFrom': volunteerFrom,
        'volunteerTo': volunteerTo,
      },
    );
  }

  Future<void> approve({required String id, required String token}) async {
    await _client.putJson(
      '/api/volunteers/$id/approve',
      token: token,
    );
  }

  Future<void> decline({required String id, required String token}) async {
    await _client.putJson(
      '/api/volunteers/$id/decline',
      token: token,
    );
  }

  Future<void> updateStay({
    required String id,
    required String token,
    required String volunteerFrom,
    required String volunteerTo,
  }) async {
    await _client.putJson(
      '/api/volunteers/$id/stay',
      token: token,
      body: {
        'volunteerFrom': volunteerFrom,
        'volunteerTo': volunteerTo,
      },
    );
  }

  Future<void> cancelStay({required String id, required String token}) async {
    await _client.putJson(
      '/api/volunteers/$id/cancel',
      token: token,
    );
  }
}

