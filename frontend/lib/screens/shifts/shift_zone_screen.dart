import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/zone.dart';
import '../../models/shift_view.dart';
import '../../services/auth_store.dart';
import '../../services/shifts_service.dart';
import '../../services/api_client.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/global_search_filter.dart';
import '../../theme/ara_theme.dart';
import 'shift_zone_dialogs.dart';
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

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  ShiftView? _currentShift;
  bool _isRefreshing = false;
  Timer? _midnightTimer;
  late final GlobalSearchFilterController<Zone> _searchFilterController;
  String? _focusedZoneName;
  List<String> _pinnedZoneIdentities = <String>[];
  int _focusRequestId = 0;
  ShiftZoneStaffMode _staffMode = ShiftZoneStaffMode.none;

  @override
  void initState() {
    super.initState();
    _searchFilterController = GlobalSearchFilterController<Zone>(
      resourceType: 'tasks_${widget.shiftType.toLowerCase()}',
      titleOf: (zone) => zone.name,
      subtitleOf: (zone) {
        final taskCount = zone.taskCount ?? zone.tasks.length;
        final start = zone.startTime ?? '';
        if (start.isEmpty) return '$taskCount task${taskCount == 1 ? '' : 's'}';
        return '$start - $taskCount task${taskCount == 1 ? '' : 's'}';
      },
      tagsOf: (zone) => [
        zone.category,
        ...zone.tasks,
        ...zone.subtasks.map((task) => task.name),
      ],
    )..addListener(_onSearchFilterChanged);
    _future = _loadShift();
    _future.then((shift) {
      if (!mounted) return;
      setState(() {
        _currentShift = shift;
      });
    }).catchError((_) {
      // Error handling stays in FutureBuilder.
    });
    unawaited(_loadPinnedZoneIdentity());
    _scheduleMidnightRefresh();
  }

  String get _pinnedZoneKey =>
      'pinned_zones_${widget.shiftType.toLowerCase()}_${_fmtIso(widget.date)}';

  Future<void> _loadPinnedZoneIdentity() async {
    final prefs = await SharedPreferences.getInstance();
    final pinned = prefs.getStringList(_pinnedZoneKey) ?? const <String>[];
    if (!mounted) return;
    setState(() {
      _pinnedZoneIdentities = pinned.where((x) => x.trim().isNotEmpty).toList();
    });
  }

  Future<void> _savePinnedZoneIdentity(List<String> pinned) async {
    final prefs = await SharedPreferences.getInstance();
    if (pinned.isEmpty) {
      await prefs.remove(_pinnedZoneKey);
      return;
    }
    await prefs.setStringList(_pinnedZoneKey, pinned);
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final nowUtc = DateTime.now().toUtc();
    final lisbonNow = _toLisbon(nowUtc);
    final nextLisbonMidnight =
        DateTime(lisbonNow.year, lisbonNow.month, lisbonNow.day + 1);
    final nextMidnightUtc = _lisbonToUtc(nextLisbonMidnight);
    final delay = nextMidnightUtc.difference(nowUtc);
    _midnightTimer = Timer(delay, () async {
      if (!mounted) return;
      await _reload();
      if (mounted) {
        _scheduleMidnightRefresh();
      }
    });
  }

  DateTime _toLisbon(DateTime utc) {
    return utc.add(_lisbonOffsetFor(utc));
  }

  DateTime _lisbonToUtc(DateTime lisbonLocal) {
    var utc = DateTime.utc(
      lisbonLocal.year,
      lisbonLocal.month,
      lisbonLocal.day,
      lisbonLocal.hour,
      lisbonLocal.minute,
      lisbonLocal.second,
      lisbonLocal.millisecond,
      lisbonLocal.microsecond,
    );
    var offset = _lisbonOffsetFor(utc);
    utc = utc.subtract(offset);
    final correctedOffset = _lisbonOffsetFor(utc);
    if (correctedOffset != offset) {
      utc = utc.add(offset).subtract(correctedOffset);
    }
    return utc;
  }

  Duration _lisbonOffsetFor(DateTime utc) {
    final year = utc.year;
    final dstStart = _lastSundayUtc(year, 3).add(const Duration(hours: 1));
    final dstEnd = _lastSundayUtc(year, 10).add(const Duration(hours: 1));
    final inDst = utc.isAtSameMomentAs(dstStart) ||
        (utc.isAfter(dstStart) && utc.isBefore(dstEnd));
    return inDst ? const Duration(hours: 1) : Duration.zero;
  }

  DateTime _lastSundayUtc(int year, int month) {
    final lastDay = DateTime.utc(year, month + 1, 0);
    final daysToSubtract = lastDay.weekday % 7;
    return lastDay.subtract(Duration(days: daysToSubtract));
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
  void dispose() {
    _searchFilterController
      ..reset(notify: false)
      ..removeListener(_onSearchFilterChanged)
      ..dispose();
    _midnightTimer?.cancel();
    super.dispose();
  }

  void _onSearchFilterChanged() {
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _addZone() async {
    final name = await showShiftZoneNameDialog(
      context: context,
      title: 'Add zone',
    );
    if (!mounted || name == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;

    final auth = context.read<AuthStore>();
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      _showMessage('Missing login token.');
      return;
    }

    try {
      await _service.createZone(
        date: _fmtIso(widget.date),
        shiftType: widget.shiftType,
        name: trimmed,
        isGroupedZone: widget.shiftType == 'Evening',
        token: token,
      );
      await _reload();
      _showMessage('Zone added.');
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  void _setStaffMode(ShiftZoneStaffMode mode) {
    if (!mounted) return;
    setState(() => _staffMode = mode);
  }

  Future<void> _openShiftActionsSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: const Text('Add zone'),
              onTap: () async {
                Navigator.pop(ctx);
                if (!mounted) return;
                await _addZone();
              },
            ),
            ListTile(
              leading: Icon(
                _staffMode == ShiftZoneStaffMode.edit
                    ? Icons.check_circle_outline
                    : Icons.edit_outlined,
              ),
              title: Text(
                _staffMode == ShiftZoneStaffMode.edit
                    ? 'Done editing zones'
                    : 'Edit zones',
              ),
              onTap: () {
                Navigator.pop(ctx);
                _setStaffMode(
                  _staffMode == ShiftZoneStaffMode.edit
                      ? ShiftZoneStaffMode.none
                      : ShiftZoneStaffMode.edit,
                );
              },
            ),
            ListTile(
              leading: Icon(
                _staffMode == ShiftZoneStaffMode.delete
                    ? Icons.check_circle_outline
                    : Icons.delete_outline,
                color: _staffMode == ShiftZoneStaffMode.delete
                    ? null
                    : ARAColors.danger,
              ),
              title: Text(
                _staffMode == ShiftZoneStaffMode.delete
                    ? 'Done deleting zones'
                    : 'Delete zones',
                style: TextStyle(
                  color: _staffMode == ShiftZoneStaffMode.delete
                      ? null
                      : ARAColors.danger,
                ),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _setStaffMode(
                  _staffMode == ShiftZoneStaffMode.delete
                      ? ShiftZoneStaffMode.none
                      : ShiftZoneStaffMode.delete,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.shiftType} Shift'),
        actions: [
          ...buildGlobalSearchFilterActions<Zone>(
            context: context,
            title: 'tasks',
            items: _currentShift == null ? <Zone>[] : _toZones(_currentShift!),
            controller: _searchFilterController,
            showFilter: false,
            searchResultBuilder: (context, zone, onTap) => Padding(
              padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
              child: Card(
                child: ListTile(
                  onTap: onTap,
                  leading: CircleAvatar(
                    backgroundColor: zone.progress >= 1.0
                        ? ARAColors.successDark
                        : ARAColors.surfaceWarm,
                    child: Icon(
                      zone.progress >= 1.0 ? Icons.check : Icons.task_alt,
                      color: ARAColors.ink,
                    ),
                  ),
                  title: Text(zone.name),
                  subtitle: Text(
                    [
                      if (zone.category.trim().toLowerCase() != 'general')
                        zone.category,
                      if ((zone.startTime ?? '').isNotEmpty) zone.startTime!,
                      '${zone.taskCount ?? zone.tasks.length} task(s)',
                    ].join(' - '),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              ),
            ),
            onItemSelected: (zone) {
              _searchFilterController.updateQuery(zone.name);
              setState(() {
                _focusedZoneName = zone.name;
                _focusRequestId++;
              });
            },
          ),
          if (_searchFilterController.query.trim().isNotEmpty)
            IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close),
              onPressed: _searchFilterController.clearQuery,
            ),
          if (auth.isStaff)
            IconButton(
              onPressed: _openShiftActionsSheet,
              icon: const Icon(Icons.more_vert),
              tooltip: 'Shift actions',
            ),
        ],
      ),
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
                  }

                  final shift = _currentShift!;
                  final zones = _toZones(shift);
                  _searchFilterController.setFilterOptions(const []);
                  final visibleZones = _searchFilterController.apply(zones);
                  return Stack(
                    children: [
                      ZoneListScreen(
                        key: ValueKey(shift.shiftId),
                        shiftType: widget.shiftType,
                        date: widget.date,
                        zones: visibleZones,
                        staffMode: _staffMode,
                        shiftId: shift.shiftId,
                        onReload: _reload,
                        initialPinnedZoneIdentities: _pinnedZoneIdentities,
                        onPinnedZonesChanged: (pinned) {
                          _pinnedZoneIdentities = List<String>.from(pinned);
                          unawaited(_savePinnedZoneIdentity(pinned));
                        },
                        focusedZoneName: _focusedZoneName,
                        focusRequestId: _focusRequestId,
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
            const Icon(Icons.error_outline, size: 64, color: ARAColors.subInk),
            const SizedBox(height: 12),
            Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: ARAColors.subInk),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
