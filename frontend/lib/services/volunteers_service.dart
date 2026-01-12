import 'package:intl/intl.dart';
import 'api_client.dart';
import 'api_config.dart';

class PendingVolunteer {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String createdAt;
  final String? volunteerFrom;
  final String? volunteerTo;

  PendingVolunteer({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.createdAt,
    required this.volunteerFrom,
    required this.volunteerTo,
  });

  String get fullName => '$firstName $lastName'.trim();

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
      return '${DateFormat('d MMM yyyy').format(start)} – ${DateFormat('d MMM yyyy').format(end)}';
    } catch (_) {
      return '$volunteerFrom – $volunteerTo';
    }
  }

  factory PendingVolunteer.fromJson(Map<String, dynamic> json) {
    return PendingVolunteer(
      id: json['id'].toString(),
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      createdAt: json['createdAt']?.toString() ?? '',
      volunteerFrom: json['volunteerFrom']?.toString(),
      volunteerTo: json['volunteerTo']?.toString(),
    );
  }
}

class VolunteersService {
  VolunteersService({ApiClient? client})
      : _client = client ?? ApiClient(ApiConfig.baseUrl);

  final ApiClient _client;

  Future<List<PendingVolunteer>> getPending({required String token}) async {
    final res = await _client.getAny('/api/volunteers/pending', token: token);
    final list = res is List ? res : (res?['items'] as List<dynamic>? ?? []);
    return list
        .map((item) => PendingVolunteer.fromJson(item as Map<String, dynamic>))
        .toList();
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
}
