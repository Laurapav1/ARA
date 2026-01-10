import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/zone.dart';
import '../../models/shift_view.dart';
import '../../services/auth_store.dart';
import '../../services/shifts_service.dart';
import '../../services/api_client.dart';
import '../../widgets/offline_banner.dart';
import 'zone_list_screen.dart';

class ShiftZoneScreen extends StatefulWidget {
  final String shiftType;
  final DateTime date;

  const ShiftZoneScreen({
    super.key,
    required this.shiftType,
    required this.date,
  });

  @override
  State<ShiftZoneScreen> createState() => _ShiftZoneScreenState();
}

class _ShiftZoneScreenState extends State<ShiftZoneScreen> {
  final _service = ShiftsService();
  late Future<ShiftView> _future;
  int _reloadKey = 0;
  ShiftView? _currentShift;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _future = _loadShift();
  }

  Future<ShiftView> _loadShift() async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      throw ApiException(401, 'Please sign in to view shifts.');
    }
    final date = _fmtIso(widget.date);
    return _service.getShift(
      date: date,
      type: widget.shiftType,
      token: token,
    );
  }

  String _fmtIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  List<Zone> _toZones(ShiftView shift) {
    return shift.tasks.map((task) {
      final progress = task.status == 'Done'
          ? 1.0
          : task.status == 'InProgress'
              ? 0.5
              : 0.0;
      final assignedNames = task.assignedVolunteers
          .map((v) => '${v.firstName} ${v.lastName}'.trim())
          .toList();
      final assignedIds = task.assignedVolunteers.map((v) => v.id).toList();
      final tip = task.maxVolunteers == null
          ? 'Required volunteers: ${task.requiredVolunteers}'
          : 'Required ${task.requiredVolunteers} / Max ${task.maxVolunteers}';

      return Zone(
        taskId: task.id,
        name: task.name,
        category: task.category,
        startTime: task.startTime,
        progress: progress,
        volunteers: task.assignedCount,
        taskCount: 1,
        tasks: assignedNames,
        tip: tip,
        assignedVolunteerIds: assignedIds,
        assignedVolunteerNames: assignedNames,
      );
    }).toList();
  }

  Future<void> _reload() async {
    setState(() => _isRefreshing = true);
    try {
      final shift = await _loadShift();
      if (!mounted) return;
      setState(() {
        _currentShift = shift;
        _reloadKey++;
      });
    } on ApiException catch (_) {
      // Keep existing data on refresh errors.
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.shiftType} Shift')),
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: FutureBuilder<ShiftView>(
                future: _future,
                builder: (context, snapshot) {
                  if (_currentShift == null) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      final message = snapshot.error is ApiException
                          ? (snapshot.error as ApiException).message
                          : 'Could not load shift.';
                      return _ErrorState(message: message);
                    }
                    _currentShift = snapshot.data;
                  }

                  final shift = _currentShift!;
                  final zones = _toZones(shift);
                  return Stack(
                    children: [
                      ZoneListScreen(
                        key: ValueKey('${shift.shiftId}-$_reloadKey'),
                        shiftType: widget.shiftType,
                        zones: zones,
                        shiftId: shift.shiftId,
                        onReload: _reload,
                      ),
                      if (_isRefreshing)
                        const Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: LinearProgressIndicator(minHeight: 2),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.grey.shade700),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
