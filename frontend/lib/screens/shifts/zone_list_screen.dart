import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/zone.dart';
import '../../theme/ara_theme.dart';
import '../../services/auth_store.dart';
import '../../services/optimistic_mutation_runner.dart';
import '../../services/optimistic_sync_store.dart';
import '../../services/shifts_service.dart';
import '../../services/api_client.dart';
import '../../widgets/inline_staff_action_button.dart';
import 'shift_zone_dialogs.dart';

enum ShiftZoneStaffMode { none, edit, delete }

class ZoneListScreen extends StatefulWidget {
  final String shiftType;
  final DateTime date;
  final List<Zone> zones;
  final ShiftZoneStaffMode staffMode;
  final String? shiftId;
  final VoidCallback? onReload;
  final String? focusedZoneName;
  final int focusRequestId;
  final List<String> initialPinnedZoneIdentities;
  final ValueChanged<List<String>>? onPinnedZonesChanged;

  const ZoneListScreen({
    super.key,
    required this.shiftType,
    required this.date,
    required this.zones,
    this.staffMode = ShiftZoneStaffMode.none,
    this.shiftId,
    this.onReload,
    this.focusedZoneName,
    this.focusRequestId = 0,
    this.initialPinnedZoneIdentities = const <String>[],
    this.onPinnedZonesChanged,
  });

  @override
  State<ZoneListScreen> createState() => _ZoneListScreenState();
}

class _ZoneListScreenState extends State<ZoneListScreen> {
  late List<Zone> _zones;
  late List<bool> _signedUp;
  final Map<String, bool> _signedUpTasks = {};
  final Map<String, GlobalKey> _zoneCardKeys = <String, GlobalKey>{};
  final ScrollController _scrollController = ScrollController();
  final _service = ShiftsService();
  late final OptimisticMutationRunner _mutationRunner;
  int _lastHandledFocusRequestId = -1;
  List<String> _pinnedZoneIdentities = <String>[];

  @override
  void initState() {
    super.initState();
    _mutationRunner = OptimisticMutationRunner(
      context.read<OptimisticSyncStore>(),
    );
    _zones = widget.zones.map((z) => z.copy()).toList();
    _signedUp = List<bool>.filled(_zones.length, false, growable: true);
    _signedUpTasks.clear();
    _pinnedZoneIdentities =
        List<String>.from(widget.initialPinnedZoneIdentities);
    _promotePinnedZonesIfPresent();
    _scheduleFocusIfNeeded();
  }

  @override
  void didUpdateWidget(covariant ZoneListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zones != widget.zones) {
      _zones = widget.zones.map((z) => z.copy()).toList();
      _signedUp = List<bool>.filled(_zones.length, false, growable: true);
      _signedUpTasks.clear();
      _promotePinnedZonesIfPresent();
    }
    if (oldWidget.initialPinnedZoneIdentities !=
        widget.initialPinnedZoneIdentities) {
      _pinnedZoneIdentities =
          List<String>.from(widget.initialPinnedZoneIdentities);
      _promotePinnedZonesIfPresent();
    }
    _scheduleFocusIfNeeded();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _mutationRunner.dispose();
    super.dispose();
  }

  String _zoneIdentity(Zone zone) {
    if (zone.taskId != null && zone.taskId!.isNotEmpty) {
      return zone.taskId!;
    }
    return '${zone.name}::${zone.category}'.toLowerCase();
  }

  GlobalKey _zoneCardKey(Zone zone) {
    final id = _zoneIdentity(zone);
    return _zoneCardKeys.putIfAbsent(id, GlobalKey.new);
  }

  void _scrollToTop() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void _promotePinnedZonesIfPresent() {
    if (_pinnedZoneIdentities.isEmpty) return;
    // Rebuild top order to match recency list, preserving order for non-pinned zones.
    final originalZones = List<Zone>.from(_zones);
    final originalSigned = List<bool>.from(_signedUp);
    final indexById = <String, int>{};
    for (var i = 0; i < originalZones.length; i++) {
      indexById[_zoneIdentity(originalZones[i])] = i;
    }

    final newZones = <Zone>[];
    final newSigned = <bool>[];
    final usedIds = <String>{};

    for (final id in _pinnedZoneIdentities) {
      final idx = indexById[id];
      if (idx == null || usedIds.contains(id)) continue;
      newZones.add(originalZones[idx]);
      newSigned.add(originalSigned[idx]);
      usedIds.add(id);
    }

    for (var i = 0; i < originalZones.length; i++) {
      final id = _zoneIdentity(originalZones[i]);
      if (usedIds.contains(id)) continue;
      newZones.add(originalZones[i]);
      newSigned.add(originalSigned[i]);
    }

    _zones = newZones;
    _signedUp = newSigned;
  }

  int _pinAndPromoteZone(Zone zone) {
    final pinned = _zoneIdentity(zone);
    _pinnedZoneIdentities.removeWhere((id) => id == pinned);
    _pinnedZoneIdentities.insert(0, pinned);
    const maxPinned = 8;
    if (_pinnedZoneIdentities.length > maxPinned) {
      _pinnedZoneIdentities = _pinnedZoneIdentities.take(maxPinned).toList();
    }
    widget.onPinnedZonesChanged?.call(List<String>.from(_pinnedZoneIdentities));
    final idx = _zones.indexWhere((z) => _zoneIdentity(z) == pinned);
    if (idx < 0) {
      return -1;
    }
    if (idx == 0) {
      _scrollToTop();
      return 0;
    }

    setState(() {
      final moved = _zones.removeAt(idx);
      _zones.insert(0, moved);
      final signed = _signedUp.removeAt(idx);
      _signedUp.insert(0, signed);
    });
    _scrollToTop();
    return 0;
  }

  void _scheduleFocusIfNeeded() {
    if (widget.focusedZoneName == null ||
        widget.focusedZoneName!.trim().isEmpty) {
      return;
    }
    if (widget.focusRequestId == _lastHandledFocusRequestId) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final target = widget.focusedZoneName!.trim().toLowerCase();
      final zone = _zones.cast<Zone?>().firstWhere(
            (z) => z != null && z.name.trim().toLowerCase() == target,
            orElse: () => null,
          );
      if (zone == null) return;
      final keyContext = _zoneCardKey(zone).currentContext;
      if (keyContext != null) {
        Scrollable.ensureVisible(
          keyContext,
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          alignment: 0.1,
        );
      }
      _lastHandledFocusRequestId = widget.focusRequestId;
    });
  }

  // State colors:
  //  - Done: green
  //  - In progress (someone on it): softer amber
  //  - Unassigned: red
  Color _cardColor(int index) {
    final zone = _zones[index];
    if (_isGrouped(zone)) return _groupCardColor(zone);
    if (zone.progress >= 1.0) return ARAColors.successSoft; // darker green

    final hasAnyone = zone.volunteers + (_signedUp[index] ? 1 : 0) > 0;
    if (hasAnyone) return ARAColors.warningSoft; // darker amber

    return ARAColors.dangerSoft; // darker red
  }

  IconData _statusIcon(int index) {
    final zone = _zones[index];
    if (_isGrouped(zone)) return _groupStatusIcon(zone);
    if (zone.progress >= 1.0) return Icons.check_circle;

    final hasAnyone = zone.volunteers + (_signedUp[index] ? 1 : 0) > 0;
    if (hasAnyone) return Icons.schedule;

    return Icons.warning_rounded;
  }

  bool _isGrouped(Zone zone) => zone.subtasks.isNotEmpty;

  Color _groupCardColor(Zone zone) {
    final allDone = zone.subtasks.every((t) => t.progress >= 1.0);
    if (allDone) return ARAColors.successSoft; // darker green

    final anyAssigned = zone.subtasks.any((t) => _hasAnyoneForTask(zone, t));
    if (anyAssigned) return ARAColors.warningSoft; // darker amber

    return ARAColors.dangerSoft; // darker red
  }

  IconData _groupStatusIcon(Zone zone) {
    final allDone = zone.subtasks.every((t) => t.progress >= 1.0);
    if (allDone) return Icons.check_circle;

    final anyAssigned = zone.subtasks.any((t) => _hasAnyoneForTask(zone, t));
    if (anyAssigned) return Icons.schedule;

    return Icons.warning_rounded;
  }

  bool _hasAnyoneForTask(Zone zone, ZoneTask task) {
    final signedUp = _isTaskSignedUp(zone, task);
    return task.volunteers + (signedUp ? 1 : 0) > 0;
  }

  bool _isTaskSignedUp(Zone zone, ZoneTask task) {
    final key = _taskKey(zone, task);
    return _signedUpTasks[key] ?? false;
  }

  String _taskKey(Zone zone, ZoneTask task) {
    final id = task.id;
    if (id != null && id.isNotEmpty) return id;
    return '${zone.name}::${task.name}';
  }


  List<Zone> _cloneZones() => _zones.map(_cloneZone).toList();

  Zone _cloneZone(Zone zone) {
    return zone.copyWith(
      tasks: List<String>.from(zone.tasks),
      assignedVolunteerIds: List<String>.from(zone.assignedVolunteerIds),
      assignedVolunteerNames: List<String>.from(zone.assignedVolunteerNames),
      subtasks: zone.subtasks.map(_cloneTask).toList(),
    );
  }

  ZoneTask _cloneTask(ZoneTask task) {
    return task.copyWith(
      assignedVolunteerIds: List<String>.from(task.assignedVolunteerIds),
      assignedVolunteerNames: List<String>.from(task.assignedVolunteerNames),
    );
  }

  bool _isRetryable(Object error) =>
      OptimisticMutationRunner.defaultRetryable(error);

  void _restoreZones(List<Zone> snapshot) {
    if (!mounted) return;
    setState(() {
      _zones = snapshot.map(_cloneZone).toList();
    });
  }

  void _setZoneAssigned({
    required Zone zone,
    required String volunteerId,
    required String volunteerName,
    required bool assigned,
  }) {
    final index = _zones.indexWhere((current) => _zoneIdentity(current) == _zoneIdentity(zone));
    if (index == -1) return;
    final current = _zones[index];
    final ids = List<String>.from(current.assignedVolunteerIds);
    final names = List<String>.from(current.assignedVolunteerNames);
    if (assigned) {
      if (!ids.contains(volunteerId)) ids.add(volunteerId);
      if (!names.contains(volunteerName)) names.add(volunteerName);
    } else {
      ids.removeWhere((id) => id == volunteerId);
      names.removeWhere((name) => name == volunteerName);
    }
    final volunteers = assigned
        ? current.volunteers + (current.assignedVolunteerIds.contains(volunteerId) ? 0 : 1)
        : (current.assignedVolunteerIds.contains(volunteerId)
            ? (current.volunteers - 1).clamp(0, 999)
            : current.volunteers);
    if (!mounted) return;
    setState(() {
      _zones[index] = current.copyWith(
        volunteers: volunteers,
        assignedVolunteerIds: ids,
        assignedVolunteerNames: names,
      );
    });
  }

  void _setZoneProgress(Zone zone, double progress) {
    final index = _zones.indexWhere((current) => _zoneIdentity(current) == _zoneIdentity(zone));
    if (index == -1 || !mounted) return;
    final current = _zones[index];
    setState(() {
      _zones[index] = current.copyWith(progress: progress);
    });
  }

  void _setTaskAssigned({
    required Zone zone,
    required ZoneTask task,
    required String volunteerId,
    required String volunteerName,
    required bool assigned,
  }) {
    final zoneIndex = _zones.indexWhere((current) => _zoneIdentity(current) == _zoneIdentity(zone));
    if (zoneIndex == -1) return;
    final currentZone = _zones[zoneIndex];
    final subtasks = currentZone.subtasks.map(_cloneTask).toList();
    final taskIndex = subtasks.indexWhere((current) => _taskKey(currentZone, current) == _taskKey(zone, task));
    if (taskIndex == -1) return;
    final currentTask = subtasks[taskIndex];
    final ids = List<String>.from(currentTask.assignedVolunteerIds);
    final names = List<String>.from(currentTask.assignedVolunteerNames);
    if (assigned) {
      if (!ids.contains(volunteerId)) ids.add(volunteerId);
      if (!names.contains(volunteerName)) names.add(volunteerName);
    } else {
      ids.removeWhere((id) => id == volunteerId);
      names.removeWhere((name) => name == volunteerName);
    }
    final volunteers = assigned
        ? currentTask.volunteers + (currentTask.assignedVolunteerIds.contains(volunteerId) ? 0 : 1)
        : (currentTask.assignedVolunteerIds.contains(volunteerId)
            ? (currentTask.volunteers - 1).clamp(0, 999)
            : currentTask.volunteers);
    subtasks[taskIndex] = currentTask.copyWith(
      volunteers: volunteers,
      assignedVolunteerIds: ids,
      assignedVolunteerNames: names,
    );
    if (!mounted) return;
    setState(() {
      _zones[zoneIndex] = currentZone.copyWith(subtasks: subtasks);
    });
  }

  void _setTaskProgress(Zone zone, ZoneTask task, double progress) {
    final zoneIndex = _zones.indexWhere((current) => _zoneIdentity(current) == _zoneIdentity(zone));
    if (zoneIndex == -1) return;
    final currentZone = _zones[zoneIndex];
    final subtasks = currentZone.subtasks.map(_cloneTask).toList();
    final taskIndex = subtasks.indexWhere((current) => _taskKey(currentZone, current) == _taskKey(zone, task));
    if (taskIndex == -1 || !mounted) return;
    subtasks[taskIndex] = subtasks[taskIndex].copyWith(progress: progress);
    setState(() {
      _zones[zoneIndex] = currentZone.copyWith(subtasks: subtasks);
    });
  }
  String _fmtIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  bool _canJoin(AuthStore auth) {
    if (auth.isStaff) return true;
    return auth.isApproved && auth.me != null;
  }

  String _joinBlockReason(AuthStore auth) {
    if (auth.isStaff) return '';
    if (!auth.isApproved) {
      return 'Your account is not approved yet.';
    }
    if (auth.me == null) return 'Please sign in to join tasks.';
    return 'You need an approved stay for this shift date.';
  }

  String? _joinCountdownMessage(AuthStore auth) {
    return null;
  }

  void _showJoinBlocked(AuthStore auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cannot join task'),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actionsAlignment: MainAxisAlignment.end,
        actionsOverflowButtonSpacing: 10,
        content: Text(_joinBlockReason(auth)),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinBackend(Zone zone, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    final volunteerId = auth.me?.id;
    final volunteerName = auth.me?.fullName ?? 'You';
    if (widget.shiftId == null || zone.taskId == null || volunteerId == null) {
      return;
    }
    final previous = _cloneZones();
    _mutationRunner.run(
      key: 'shift_join_${zone.taskId}',
      applyOptimistic: () => _setZoneAssigned(
        zone: zone,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
        assigned: true,
      ),
      sync: () => _service.joinTask(
        shiftId: widget.shiftId!,
        taskId: zone.taskId!,
        token: token,
      ),
      revertOptimistic: () => _restoreZones(previous),
      onSuccess: widget.onReload,
      onPermanentFailure: (error) {
        final message =
            error is ApiException ? error.message : 'Could not join task.';
        _showJoinBlockedMessage(message);
      },
      isRetryable: _isRetryable,
    );
  }

  Future<void> _leaveBackend(Zone zone, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    final volunteerId = auth.me?.id;
    final volunteerName = auth.me?.fullName ?? 'You';
    if (widget.shiftId == null || zone.taskId == null || volunteerId == null) {
      return;
    }
    final previous = _cloneZones();
    _mutationRunner.run(
      key: 'shift_leave_${zone.taskId}',
      applyOptimistic: () => _setZoneAssigned(
        zone: zone,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
        assigned: false,
      ),
      sync: () => _service.leaveTask(
        shiftId: widget.shiftId!,
        taskId: zone.taskId!,
        token: token,
      ),
      revertOptimistic: () => _restoreZones(previous),
      onSuccess: widget.onReload,
      onPermanentFailure: (error) {
        final message =
            error is ApiException ? error.message : 'Could not leave task.';
        _showJoinBlockedMessage(message);
      },
      isRetryable: _isRetryable,
    );
  }

  Future<void> _completeBackend(Zone zone, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || zone.taskId == null) return;
    final previous = _cloneZones();
    _mutationRunner.run(
      key: 'shift_complete_${zone.taskId}',
      applyOptimistic: () => _setZoneProgress(zone, 1.0),
      sync: () => _service.completeTask(
        shiftId: widget.shiftId!,
        taskId: zone.taskId!,
        token: token,
      ),
      revertOptimistic: () => _restoreZones(previous),
      onSuccess: widget.onReload,
      onPermanentFailure: (error) {
        final message = error is ApiException
            ? _friendlyCompleteError(error.message)
            : 'Could not mark task done.';
        _showErrorDialog('Cannot mark done', message);
      },
      isRetryable: _isRetryable,
    );
  }

  Future<void> _reopenBackend(Zone zone, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || zone.taskId == null) return;
    final previous = _cloneZones();
    _mutationRunner.run(
      key: 'shift_reopen_${zone.taskId}',
      applyOptimistic: () => _setZoneProgress(zone, 0.0),
      sync: () => _service.reopenTask(
        shiftId: widget.shiftId!,
        taskId: zone.taskId!,
        token: token,
      ),
      revertOptimistic: () => _restoreZones(previous),
      onSuccess: widget.onReload,
      onPermanentFailure: (error) {
        final message = error is ApiException
            ? _friendlyCompleteError(error.message)
            : 'Could not reopen task.';
        _showErrorDialog('Cannot mark done', message);
      },
      isRetryable: _isRetryable,
    );
  }

  Future<void> _joinBackendTask(Zone zone, ZoneTask task, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    final volunteerId = auth.me?.id;
    final volunteerName = auth.me?.fullName ?? 'You';
    if (widget.shiftId == null || task.id == null || volunteerId == null) {
      return;
    }
    final previous = _cloneZones();
    _mutationRunner.run(
      key: 'shift_join_${task.id}',
      applyOptimistic: () => _setTaskAssigned(
        zone: zone,
        task: task,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
        assigned: true,
      ),
      sync: () => _service.joinTask(
        shiftId: widget.shiftId!,
        taskId: task.id!,
        token: token,
      ),
      revertOptimistic: () => _restoreZones(previous),
      onSuccess: widget.onReload,
      onPermanentFailure: (error) {
        final message =
            error is ApiException ? error.message : 'Could not join task.';
        _showJoinBlockedMessage(message);
      },
      isRetryable: _isRetryable,
    );
  }

  Future<void> _leaveBackendTask(Zone zone, ZoneTask task, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    final volunteerId = auth.me?.id;
    final volunteerName = auth.me?.fullName ?? 'You';
    if (widget.shiftId == null || task.id == null || volunteerId == null) {
      return;
    }
    final previous = _cloneZones();
    _mutationRunner.run(
      key: 'shift_leave_${task.id}',
      applyOptimistic: () => _setTaskAssigned(
        zone: zone,
        task: task,
        volunteerId: volunteerId,
        volunteerName: volunteerName,
        assigned: false,
      ),
      sync: () => _service.leaveTask(
        shiftId: widget.shiftId!,
        taskId: task.id!,
        token: token,
      ),
      revertOptimistic: () => _restoreZones(previous),
      onSuccess: widget.onReload,
      onPermanentFailure: (error) {
        final message =
            error is ApiException ? error.message : 'Could not leave task.';
        _showJoinBlockedMessage(message);
      },
      isRetryable: _isRetryable,
    );
  }

  Future<void> _completeBackendTask(Zone zone, ZoneTask task, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || task.id == null) return;
    final previous = _cloneZones();
    _mutationRunner.run(
      key: 'shift_complete_${task.id}',
      applyOptimistic: () => _setTaskProgress(zone, task, 1.0),
      sync: () => _service.completeTask(
        shiftId: widget.shiftId!,
        taskId: task.id!,
        token: token,
      ),
      revertOptimistic: () => _restoreZones(previous),
      onSuccess: widget.onReload,
      onPermanentFailure: (error) {
        final message = error is ApiException
            ? _friendlyCompleteError(error.message)
            : 'Could not mark task done.';
        _showErrorDialog('Cannot mark done', message);
      },
      isRetryable: _isRetryable,
    );
  }

  Future<void> _reopenBackendTask(Zone zone, ZoneTask task, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || task.id == null) return;
    final previous = _cloneZones();
    _mutationRunner.run(
      key: 'shift_reopen_${task.id}',
      applyOptimistic: () => _setTaskProgress(zone, task, 0.0),
      sync: () => _service.reopenTask(
        shiftId: widget.shiftId!,
        taskId: task.id!,
        token: token,
      ),
      revertOptimistic: () => _restoreZones(previous),
      onSuccess: widget.onReload,
      onPermanentFailure: (error) {
        final message = error is ApiException
            ? _friendlyCompleteError(error.message)
            : 'Could not reopen task.';
        _showErrorDialog('Cannot mark done', message);
      },
      isRetryable: _isRetryable,
    );
  }

  Future<void> _editZone(Zone zone, AuthStore auth) async {
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      _showMessage('Missing login token.');
      return;
    }

    final newName = await showShiftZoneNameDialog(
      context: context,
      title: 'Edit zone',
      initialValue: zone.name,
    );
    if (!mounted || newName == null) return;

    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == zone.name) return;

    try {
      await _service.updateZone(
        date: _fmtIso(widget.date),
        shiftType: widget.shiftType,
        currentName: zone.name,
        newName: trimmed,
        isGroupedZone: zone.subtasks.isNotEmpty,
        token: token,
      );
      widget.onReload?.call();
      _showMessage('Zone updated.');
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  Future<void> _deleteZone(Zone zone, AuthStore auth) async {
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      _showMessage('Missing login token.');
      return;
    }

    final confirmed = await showShiftZoneDeleteDialog(
      context: context,
      zoneName: zone.name,
    );
    if (!mounted || !confirmed) return;

    try {
      await _service.deleteZone(
        date: _fmtIso(widget.date),
        shiftType: widget.shiftType,
        name: zone.name,
        isGroupedZone: zone.subtasks.isNotEmpty,
        token: token,
      );
      widget.onReload?.call();
      _showMessage('Zone deleted.');
    } on ApiException catch (e) {
      _showMessage(e.message);
    }
  }

  String _friendlyCompleteError(String message) {
    final normalized = message.toLowerCase();
    if (normalized.contains('not assigned')) {
      return 'No one is assigned to this task yet, so it cannot be marked done.';
    }
    return message;
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(title),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actionsAlignment: MainAxisAlignment.end,
        actionsOverflowButtonSpacing: 10,
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(ctx),
            style: FilledButton.styleFrom(
              minimumSize: const Size(100, 44),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showJoinBlockedMessage(String message) {
    _showErrorDialog('Cannot join task', message);
  }

  _TextPalette _paletteFor(Color bg) {
    final brightness = ThemeData.estimateBrightnessForColor(bg);

    if (brightness == Brightness.light) {
      return const _TextPalette(
        primary: ARAColors.ink,
        secondary: ARAColors.inkSoft,
        overlay: ARAColors.overlayLight,
        onAccentIcon: ARAColors.ink,
      );
    }

    return const _TextPalette(
      primary: ARAColors.cardBg,
      secondary: ARAColors.surfaceCoolSoft,
      overlay: ARAColors.overlayDark,
      onAccentIcon: ARAColors.cardBg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final canJoin = _canJoin(auth);
    final meId = auth.me?.id;
    final sections = _sectionedIndices();
    final countdownMessage = _joinCountdownMessage(auth);

    return Column(
      children: [
        if (countdownMessage != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: ARAColors.countdownSurface,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lock_clock,
                      size: 18, color: ARAColors.countdownText),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      countdownMessage,
                      style: const TextStyle(
                        color: ARAColors.countdownText,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        Expanded(
          child: ListView(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              for (final section in sections) ...[
                if (section.title.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    child: _SectionHeader(title: section.title),
                  ),
                for (final index in section.indices)
                  Padding(
                    key: _zoneCardKey(_zones[index]),
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildZoneCard(
                      index,
                      auth,
                      canJoin,
                      meId,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  List<_ZoneSection> _sectionedIndices() {
    if (widget.shiftType != 'Evening' ||
        _zones.any((z) => z.subtasks.isNotEmpty)) {
      return [_ZoneSection('', List<int>.generate(_zones.length, (i) => i))];
    }

    final byCategory = <String, List<int>>{};
    for (var i = 0; i < _zones.length; i++) {
      final category = _zones[i].category;
      byCategory.putIfAbsent(category, () => []).add(i);
    }

    final ordered = <_ZoneSection>[];
    void addSection(String category, String title) {
      final indices = byCategory[category];
      if (indices == null || indices.isEmpty) return;
      ordered.add(_ZoneSection(title, indices));
    }

    addSection('Water', 'Fill water');
    addSection('Cleaning', 'Pick up poo / cleaning');

    for (final entry in byCategory.entries) {
      if (entry.key == 'Water' || entry.key == 'Cleaning') continue;
      ordered.add(_ZoneSection(_titleForCategory(entry.key), entry.value));
    }

    return ordered.isEmpty
        ? [_ZoneSection('', List<int>.generate(_zones.length, (i) => i))]
        : ordered;
  }

  String _titleForCategory(String category) {
    final normalized = category.trim().toLowerCase();
    if (normalized.isEmpty || normalized == 'general') return '';
    return category;
  }

  Future<void> _handleZoneStaffAction(Zone zone, AuthStore auth) async {
    switch (widget.staffMode) {
      case ShiftZoneStaffMode.edit:
        await _editZone(zone, auth);
        return;
      case ShiftZoneStaffMode.delete:
        await _deleteZone(zone, auth);
        return;
      case ShiftZoneStaffMode.none:
        return;
    }
  }

  IconData? _zoneStaffActionIcon() {
    switch (widget.staffMode) {
      case ShiftZoneStaffMode.edit:
        return Icons.edit_outlined;
      case ShiftZoneStaffMode.delete:
        return Icons.delete_outline;
      case ShiftZoneStaffMode.none:
        return null;
    }
  }

  String? _zoneStaffActionTooltip() {
    switch (widget.staffMode) {
      case ShiftZoneStaffMode.edit:
        return 'Edit zone';
      case ShiftZoneStaffMode.delete:
        return 'Delete zone';
      case ShiftZoneStaffMode.none:
        return null;
    }
  }

  Widget _buildZoneCard(
    int index,
    AuthStore auth,
    bool canJoin,
    String? meId,
  ) {
    final zone = _zones[index];
    if (_isGrouped(zone)) {
      return _buildGroupedZoneCard(zone, auth, canJoin, meId);
    }
    final done = zone.progress >= 1.0;
    final isAssigned = meId != null && zone.assignedVolunteerIds.contains(meId);

    final bg = _cardColor(index);
    final pal = _paletteFor(bg);
    final staffActionEnabled =
        auth.isStaff && widget.staffMode != ShiftZoneStaffMode.none;

    return _ZoneCard(
      zone: zone,
      bg: bg,
      palette: pal,
      icon: _statusIcon(index),
      isDone: done,
      isAssigned: isAssigned,
      staffActionIcon: staffActionEnabled ? _zoneStaffActionIcon() : null,
      staffActionTooltip: staffActionEnabled ? _zoneStaffActionTooltip() : null,
      onStaffActionPressed:
          staffActionEnabled ? () => _handleZoneStaffAction(zone, auth) : null,
      onTap: () {
        final currentIndex = _pinAndPromoteZone(zone);
        if (currentIndex < 0) return;
        if (staffActionEnabled) {
          _handleZoneStaffAction(zone, auth);
          return;
        }
        if (!canJoin) {
          _showJoinBlocked(auth);
          return;
        }
        if (zone.taskId != null && widget.shiftId != null) {
          if (isAssigned) {
            _leaveBackend(zone, auth);
          } else {
            _joinBackend(zone, auth);
          }
          return;
        }
        setState(() => _signedUp[currentIndex] = !_signedUp[currentIndex]);
      },
      onComplete: () {
        final currentIndex = _pinAndPromoteZone(zone);
        if (currentIndex < 0) return;
        if (!canJoin) {
          _showJoinBlocked(auth);
          return;
        }
        if (zone.taskId != null && widget.shiftId != null) {
          _completeBackend(zone, auth);
          return;
        }
        final current = _zones[currentIndex];
        setState(() => _zones[currentIndex] = current.copyWith(progress: 1.0));
      },
      onReopen: () {
        final currentIndex = _pinAndPromoteZone(zone);
        if (currentIndex < 0) return;
        if (zone.taskId != null && widget.shiftId != null) {
          _reopenBackend(zone, auth);
          return;
        }
        final current = _zones[currentIndex];
        setState(() => _zones[currentIndex] = current.copyWith(progress: 0.0));
      },
    );
  }

  Widget _buildGroupedZoneCard(
    Zone zone,
    AuthStore auth,
    bool canJoin,
    String? meId,
  ) {
    final bg = _groupCardColor(zone);
    final pal = _paletteFor(bg);

    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(color: bg),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: pal.overlay,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _groupStatusIcon(zone),
                      color: pal.onAccentIcon,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      zone.name,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: pal.primary,
                      ),
                    ),
                  ),
                  if (auth.isStaff &&
                      widget.staffMode != ShiftZoneStaffMode.none)
                    InlineStaffActionButton(
                      onPressed: () => _handleZoneStaffAction(zone, auth),
                      icon: _zoneStaffActionIcon()!,
                      tooltip: _zoneStaffActionTooltip(),
                      iconColor: widget.staffMode == ShiftZoneStaffMode.delete
                          ? ARAColors.danger
                          : pal.primary,
                      backgroundColor: pal.overlay,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              for (final task in zone.subtasks)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: _buildGroupedTaskRow(
                    zone,
                    task,
                    auth,
                    canJoin,
                    meId,
                    pal,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGroupedTaskRow(
    Zone zone,
    ZoneTask task,
    AuthStore auth,
    bool canJoin,
    String? meId,
    _TextPalette pal,
  ) {
    final done = task.progress >= 1.0;
    final isAssigned = meId != null && task.assignedVolunteerIds.contains(meId);
    final signedUp = _isTaskSignedUp(zone, task);
    final staffModeActive =
        auth.isStaff && widget.staffMode != ShiftZoneStaffMode.none;

    return Material(
      color: pal.overlay,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          _pinAndPromoteZone(zone);
          if (staffModeActive) {
            _handleZoneStaffAction(zone, auth);
            return;
          }
          if (!canJoin) {
            _showJoinBlocked(auth);
            return;
          }
          if (task.id != null && widget.shiftId != null) {
            if (isAssigned) {
              _leaveBackendTask(zone, task, auth);
            } else {
              _joinBackendTask(zone, task, auth);
            }
            return;
          }
          final key = _taskKey(zone, task);
          setState(() => _signedUpTasks[key] = !signedUp);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(
                _taskStatusIcon(task, zone),
                color: pal.onAccentIcon,
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  task.name,
                  style: TextStyle(
                    color: pal.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              _buildVolunteerIconsFor(
                task.assignedVolunteerNames,
                isAssigned,
              ),
              if (!staffModeActive) ...[
                const SizedBox(width: 8),
                if (!done)
                  IconButton(
                    icon: const Icon(Icons.check),
                    color: pal.primary,
                    onPressed: () {
                      _pinAndPromoteZone(zone);
                      if (!canJoin) {
                        _showJoinBlocked(auth);
                        return;
                      }
                      if (task.id != null && widget.shiftId != null) {
                        _completeBackendTask(zone, task, auth);
                        return;
                      }
                      _updateSubtaskProgress(zone, task, 1.0);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: pal.overlay,
                    ),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.replay),
                    color: pal.primary,
                    onPressed: () {
                      _pinAndPromoteZone(zone);
                      if (task.id != null && widget.shiftId != null) {
                        _reopenBackendTask(zone, task, auth);
                        return;
                      }
                      _updateSubtaskProgress(zone, task, 0.0);
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: pal.overlay,
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  IconData _taskStatusIcon(ZoneTask task, Zone zone) {
    if (task.progress >= 1.0) return Icons.check_circle;
    if (_hasAnyoneForTask(zone, task)) return Icons.schedule;
    return Icons.warning_rounded;
  }

  void _updateSubtaskProgress(Zone zone, ZoneTask task, double progress) {
    final zoneIndex = _zones.indexOf(zone);
    if (zoneIndex == -1) return;
    final current = _zones[zoneIndex];
    final subtasks = List<ZoneTask>.from(current.subtasks);
    final idx = subtasks.indexWhere(
      (t) => _taskKey(zone, t) == _taskKey(zone, task),
    );
    if (idx == -1) return;
    subtasks[idx] = subtasks[idx].copyWith(progress: progress);
    setState(() => _zones[zoneIndex] = current.copyWith(subtasks: subtasks));
  }

  Widget _buildVolunteerIconsFor(List<String> names, bool isAssigned) {
    if (names.isEmpty && !isAssigned) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < names.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: ARAColors.cardBg,
              child: Text(
                names[i].isNotEmpty ? names[i][0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ARAColors.ink,
                ),
              ),
            ),
          ),
        if (isAssigned && names.isEmpty)
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: ARAColors.cardBg,
              child: Icon(Icons.person, size: 14, color: ARAColors.ink),
            ),
          ),
      ],
    );
  }
}

class _ZoneCard extends StatefulWidget {
  final Zone zone;
  final Color bg;
  final _TextPalette palette;
  final IconData icon;
  final bool isDone;
  final bool isAssigned;
  final IconData? staffActionIcon;
  final String? staffActionTooltip;
  final VoidCallback? onStaffActionPressed;
  final VoidCallback onTap;
  final VoidCallback onComplete;
  final VoidCallback onReopen;

  const _ZoneCard({
    required this.zone,
    required this.bg,
    required this.palette,
    required this.icon,
    required this.isDone,
    required this.isAssigned,
    this.staffActionIcon,
    this.staffActionTooltip,
    this.onStaffActionPressed,
    required this.onTap,
    required this.onComplete,
    required this.onReopen,
  });

  @override
  State<_ZoneCard> createState() => _ZoneCardState();
}

class _ZoneCardState extends State<_ZoneCard> {
  @override
  Widget build(BuildContext context) {
    final pal = widget.palette;
    final taskCount = widget.zone.taskCount ?? widget.zone.tasks.length;
    final startTime = widget.zone.startTime;
    final taskLabel = '$taskCount task${taskCount == 1 ? '' : 's'}';
    final subtitle = startTime == null || startTime.isEmpty
        ? taskLabel
        : '$startTime â€¢ $taskLabel';

    return Material(
      borderRadius: BorderRadius.circular(20),
      elevation: 6,
      clipBehavior: Clip.antiAlias,
      child: Ink(
        decoration: BoxDecoration(color: widget.bg),
        child: InkWell(
          onTap: widget.onTap,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: pal.overlay,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        widget.icon,
                        color: pal.onAccentIcon,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.zone.name,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: pal.primary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            subtitle,
                            style: TextStyle(
                              color: pal.secondary,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _buildVolunteerIcons(),
                    const SizedBox(width: 8),
                    if (widget.onStaffActionPressed != null &&
                        widget.staffActionIcon != null)
                      InlineStaffActionButton(
                        icon: widget.staffActionIcon!,
                        tooltip: widget.staffActionTooltip,
                        iconColor: widget.staffActionIcon == Icons.delete_outline
                            ? ARAColors.danger
                            : pal.primary,
                        onPressed: widget.onStaffActionPressed!,
                        backgroundColor: pal.overlay,
                      )
                    else if (!widget.isDone)
                      IconButton(
                        icon: const Icon(Icons.check),
                        color: pal.primary,
                        onPressed: widget.onComplete,
                        style: IconButton.styleFrom(
                          backgroundColor: pal.overlay,
                        ),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.replay),
                        color: pal.primary,
                        onPressed: widget.onReopen,
                        style: IconButton.styleFrom(
                          backgroundColor: pal.overlay,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVolunteerIcons() {
    final names = widget.zone.assignedVolunteerNames;
    if (names.isEmpty && !widget.isAssigned) return const SizedBox.shrink();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < names.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: ARAColors.cardBg,
              child: Text(
                names[i].isNotEmpty ? names[i][0].toUpperCase() : '?',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: ARAColors.ink,
                ),
              ),
            ),
          ),
        if (widget.isAssigned && names.isEmpty)
          const Padding(
            padding: EdgeInsets.only(right: 4),
            child: CircleAvatar(
              radius: 12,
              backgroundColor: ARAColors.cardBg,
              child: Icon(Icons.person, size: 14, color: ARAColors.ink),
            ),
          ),
      ],
    );
  }
}

class _TextPalette {
  final Color primary;
  final Color secondary;
  final Color overlay;
  final Color onAccentIcon;

  const _TextPalette({
    required this.primary,
    required this.secondary,
    required this.overlay,
    required this.onAccentIcon,
  });
}

class _ZoneSection {
  final String title;
  final List<int> indices;

  _ZoneSection(this.title, this.indices);
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: ARAColors.inkStrong,
      ),
    );
  }
}











