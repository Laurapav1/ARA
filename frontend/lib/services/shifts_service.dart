import '../models/shift_view.dart';
import 'api_client.dart';
import 'api_config.dart';

class ShiftsService {
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
