import '../models/shift_view.dart';
import 'api_client.dart';
import 'api_config.dart';

class ShiftsService {
  int _shiftTypeValue(String shiftType) {
    switch (shiftType.toLowerCase()) {
      case 'morning':
        return 0;
      case 'evening':
        return 1;
      default:
        throw ArgumentError('Unknown shift type: ');
    }
  }

  ShiftsService({ApiClient? client})
      : _client = client ?? ApiClient(ApiConfig.baseUrl);

  final ApiClient _client;

  Future<ShiftView> getShift({
    required String date,
    required String type,
    required String token,
  }) async {
    final res = await _client.getJson(
      '/api/shifts?date=$date&type=$type',
      token: token,
    );
    return ShiftView.fromJson(res);
  }

  Future<void> createZone({
    required String date,
    required String shiftType,
    required String name,
    required bool isGroupedZone,
    required String token,
  }) async {
    await _client.postJson(
      '/api/shifts/zones',
      token: token,
      body: {
        'date': date,
        'shiftType': _shiftTypeValue(shiftType),
        'name': name,
        'isGroupedZone': isGroupedZone,
      },
    );
  }

  Future<void> updateZone({
    required String date,
    required String shiftType,
    required String currentName,
    required String newName,
    required bool isGroupedZone,
    required String token,
  }) async {
    await _client.putJson(
      '/api/shifts/zones',
      token: token,
      body: {
        'date': date,
        'shiftType': _shiftTypeValue(shiftType),
        'currentName': currentName,
        'newName': newName,
        'isGroupedZone': isGroupedZone,
      },
    );
  }

  Future<void> deleteZone({
    required String date,
    required String shiftType,
    required String name,
    required bool isGroupedZone,
    required String token,
  }) async {
    await _client.deleteJson(
      '/api/shifts/zones',
      token: token,
      body: {
        'date': date,
        'shiftType': _shiftTypeValue(shiftType),
        'name': name,
        'isGroupedZone': isGroupedZone,
      },
    );
  }

  Future<void> joinTask({
    required String shiftId,
    required String taskId,
    required String token,
  }) async {
    await _client.postJson(
      '/api/shifts/$shiftId/tasks/$taskId/join',
      token: token,
    );
  }

  Future<void> leaveTask({
    required String shiftId,
    required String taskId,
    required String token,
  }) async {
    await _client.deleteJson(
      '/api/shifts/$shiftId/tasks/$taskId/leave',
      token: token,
    );
  }

  Future<void> completeTask({
    required String shiftId,
    required String taskId,
    required String token,
  }) async {
    await _client.postJson(
      '/api/shifts/$shiftId/tasks/$taskId/complete',
      token: token,
    );
  }

  Future<void> reopenTask({
    required String shiftId,
    required String taskId,
    required String token,
  }) async {
    await _client.postJson(
      '/api/shifts/$shiftId/tasks/$taskId/reopen',
      token: token,
    );
  }
}
