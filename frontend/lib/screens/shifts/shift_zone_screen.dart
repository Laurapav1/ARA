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
    if (widget.shiftType == 'Evening') {
      return _toGroupedEveningZones(shift.tasks);
    }
    return shift.tasks.map(_toSingleZone).toList();
  }

  Zone _toSingleZone(ShiftTask task) {
    final progress = _progressFor(task.status);
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
      tasks: const [],
      tip: tip,
      assignedVolunteerIds: assignedIds,
      assignedVolunteerNames: assignedNames,
    );
  }

  List<Zone> _toGroupedEveningZones(List<ShiftTask> tasks) {
    final grouped = <String, List<_GroupedTask>>{};
    for (final task in tasks) {
      final grouping = _groupingFor(task);
      grouped.putIfAbsent(grouping.groupName, () => []).add(
            _GroupedTask(task: task, subLabel: grouping.subLabel),
          );
    }

    final zones = <Zone>[];
    for (final entry in grouped.entries) {
      final items = entry.value;
      final hasSubtasks = items.any((i) => i.subLabel != null);
      if (!hasSubtasks && items.length == 1) {
        final task = items.first.task;
        if (_shouldSplitEveningTask(task)) {
          zones.add(_toSplitEveningZone(task));
          continue;
        }
        zones.add(_toSingleZone(task));
        continue;
      }

      final subtasks = items
          .map(
            (i) => _toZoneTask(i.task, i.subLabel ?? i.task.name),
          )
          .toList();

      final allDone = subtasks.every((t) => t.progress >= 1.0);
      final totalVolunteers =
          subtasks.fold<int>(0, (sum, t) => sum + t.volunteers);

      zones.add(
        Zone(
          name: entry.key,
          category: 'Parks',
          progress: allDone ? 1.0 : 0.0,
          volunteers: totalVolunteers,
          taskCount: subtasks.length,
          tasks: const [],
          tip: 'Tap a task to join',
          subtasks: subtasks,
        ),
      );
    }

    return zones;
  }

  Zone _toSplitEveningZone(ShiftTask task) {
    final progress = _progressFor(task.status);
    final subtasks = [
      ZoneTask(
        id: null,
        name: 'Water',
        progress: progress,
        volunteers: 0,
      ),
      ZoneTask(
        id: null,
        name: 'Cleaning',
        progress: progress,
        volunteers: 0,
      ),
    ];

    return Zone(
      name: task.name,
      category: task.category.isEmpty ? 'Parks' : task.category,
      progress: progress >= 1.0 ? 1.0 : 0.0,
      volunteers: 0,
      taskCount: subtasks.length,
      tasks: const [],
      tip: 'Tap a task to join',
      subtasks: subtasks,
    );
  }

  bool _shouldSplitEveningTask(ShiftTask task) {
    final name = task.name.toLowerCase();
    if (_isEveningSpecialTask(name)) return false;
    final category = task.category.toLowerCase();
    if (category == 'park' ||
        category == 'parks' ||
        category == 'zone' ||
        category == 'zones') {
      return true;
    }
    return name.contains('park') || name.contains('zone');
  }

  bool _isEveningSpecialTask(String nameLower) {
    return nameLower.contains('trash') ||
        nameLower.contains('check') ||
        nameLower.contains('helper');
  }

  ZoneTask _toZoneTask(ShiftTask task, String name) {
    final progress = _progressFor(task.status);
    final assignedNames = task.assignedVolunteers
        .map((v) => '${v.firstName} ${v.lastName}'.trim())
        .toList();
    final assignedIds = task.assignedVolunteers.map((v) => v.id).toList();

    return ZoneTask(
      id: task.id,
      name: name,
      progress: progress,
      volunteers: task.assignedCount,
      assignedVolunteerIds: assignedIds,
      assignedVolunteerNames: assignedNames,
    );
  }

  double _progressFor(String status) {
    if (status == 'Done') return 1.0;
    if (status == 'InProgress') return 0.5;
    return 0.0;
  }

  _TaskGrouping _groupingFor(ShiftTask task) {
    final category = task.category.trim();
    if (category.isNotEmpty && category.toLowerCase() != 'general') {
      return _TaskGrouping(task.name, category);
    }

    final separators = [' - ', ': '];
    for (final sep in separators) {
      final idx = task.name.indexOf(sep);
      if (idx > 0) {
        final group = task.name.substring(0, idx).trim();
        final label = task.name.substring(idx + sep.length).trim();
        if (_isParkSubtaskLabel(label)) {
          return _TaskGrouping(group, label);
        }
        if (_isParkSubtaskLabel(group)) {
          return _TaskGrouping(label, group);
        }
      }
    }

    return _TaskGrouping(task.name, null);
  }

  bool _isParkSubtaskLabel(String label) {
    final lower = label.toLowerCase();
    return lower.contains('water') ||
        lower.contains('clean') ||
        lower.contains('poo');
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

class _GroupedTask {
  final ShiftTask task;
  final String? subLabel;

  const _GroupedTask({required this.task, required this.subLabel});
}

class _TaskGrouping {
  final String groupName;
  final String? subLabel;

  const _TaskGrouping(this.groupName, this.subLabel);
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
