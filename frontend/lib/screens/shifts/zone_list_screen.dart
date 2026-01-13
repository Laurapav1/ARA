import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/zone.dart';
import '../../theme/ara_theme.dart';
import '../../services/auth_store.dart';
import '../../services/shifts_service.dart';
import '../../services/api_client.dart';

class ZoneListScreen extends StatefulWidget {
  final String shiftType;
  final List<Zone> zones;
  final String? shiftId;
  final VoidCallback? onReload;

  const ZoneListScreen({
    Key? key,
    required this.shiftType,
    required this.zones,
    this.shiftId,
    this.onReload,
  }) : super(key: key);

  @override
  State<ZoneListScreen> createState() => _ZoneListScreenState();
}

class _ZoneListScreenState extends State<ZoneListScreen> {
  late List<Zone> _zones;
  late List<bool> _signedUp;
  final Map<String, bool> _signedUpTasks = {};
  final _service = ShiftsService();

  @override
  void initState() {
    super.initState();
    _zones = widget.zones.map((z) => z.copy()).toList();
    _signedUp = List<bool>.filled(_zones.length, false);
    _signedUpTasks.clear();
  }

  @override
  void didUpdateWidget(covariant ZoneListScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.zones != widget.zones) {
      _zones = widget.zones.map((z) => z.copy()).toList();
      _signedUp = List<bool>.filled(_zones.length, false);
      _signedUpTasks.clear();
    }
  }

  Gradient _shiftGradient() {
    return widget.shiftType == 'Morning'
        ? ARAColors.morningGradient
        : ARAColors.eveningGradient;
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

  bool _canJoin(AuthStore auth) {
    if (auth.isStaff) return true;
    if (!auth.isApproved) return false;
    final me = auth.me;
    if (me == null) return false;
    final now = DateTime.now();
    final from = me.volunteerFrom != null ? DateTime.parse(me.volunteerFrom!) : null;
    final to = me.volunteerTo != null ? DateTime.parse(me.volunteerTo!) : null;
    if (from != null && now.isBefore(from)) return false;
    if (to != null && now.isAfter(to)) return false;
    return true;
  }

  String _joinBlockReason(AuthStore auth) {
    if (auth.isStaff) return '';
    if (!auth.isApproved) {
      return 'Your account is not approved yet.';
    }
    final me = auth.me;
    if (me == null) return 'Please sign in to join tasks.';
    final now = DateTime.now();
    final from = me.volunteerFrom != null ? DateTime.parse(me.volunteerFrom!) : null;
    final to = me.volunteerTo != null ? DateTime.parse(me.volunteerTo!) : null;
    if (from != null && now.isBefore(from)) {
      return 'Your volunteering period has not started yet.';
    }
    if (to != null && now.isAfter(to)) {
      return 'Your volunteering period has ended.';
    }
    return 'You cannot join this task right now.';
  }

  String? _joinCountdownMessage(AuthStore auth) {
    if (auth.isStaff || !auth.isApproved) return null;
    final me = auth.me;
    if (me == null || me.volunteerFrom == null) return null;
    final now = DateTime.now();
    final from = DateTime.parse(me.volunteerFrom!);
    if (!now.isBefore(from)) return null;

    final hours = from.difference(now).inHours;
    final days = (hours / 24).ceil().clamp(1, 365);
    if (days == 1) return 'You can join tasks tomorrow.';
    return 'You can join tasks in $days days.';
  }

  void _showJoinBlocked(AuthStore auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Cannot join task'),
        content: Text(_joinBlockReason(auth)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _joinBackend(Zone zone, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || zone.taskId == null) return;
    try {
      await _service.joinTask(
        shiftId: widget.shiftId!,
        taskId: zone.taskId!,
        token: token,
      );
      widget.onReload?.call();
    } on ApiException catch (e) {
      _showJoinBlockedMessage(e.message);
    }
  }

  Future<void> _leaveBackend(Zone zone, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || zone.taskId == null) return;
    try {
      await _service.leaveTask(
        shiftId: widget.shiftId!,
        taskId: zone.taskId!,
        token: token,
      );
      widget.onReload?.call();
    } on ApiException catch (e) {
      _showJoinBlockedMessage(e.message);
    }
  }

  Future<void> _completeBackend(Zone zone, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || zone.taskId == null) return;
    try {
      await _service.completeTask(
        shiftId: widget.shiftId!,
        taskId: zone.taskId!,
        token: token,
      );
      widget.onReload?.call();
    } on ApiException catch (e) {
      _showJoinBlockedMessage(e.message);
    }
  }

  Future<void> _reopenBackend(Zone zone, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || zone.taskId == null) return;
    try {
      await _service.reopenTask(
        shiftId: widget.shiftId!,
        taskId: zone.taskId!,
        token: token,
      );
      widget.onReload?.call();
    } on ApiException catch (e) {
      _showErrorDialog(
        'Cannot mark done',
        _friendlyCompleteError(e.message),
      );
    }
  }

  Future<void> _joinBackendTask(ZoneTask task, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || task.id == null) return;
    try {
      await _service.joinTask(
        shiftId: widget.shiftId!,
        taskId: task.id!,
        token: token,
      );
      widget.onReload?.call();
    } on ApiException catch (e) {
      _showJoinBlockedMessage(e.message);
    }
  }

  Future<void> _leaveBackendTask(ZoneTask task, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || task.id == null) return;
    try {
      await _service.leaveTask(
        shiftId: widget.shiftId!,
        taskId: task.id!,
        token: token,
      );
      widget.onReload?.call();
    } on ApiException catch (e) {
      _showJoinBlockedMessage(e.message);
    }
  }

  Future<void> _completeBackendTask(ZoneTask task, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || task.id == null) return;
    try {
      await _service.completeTask(
        shiftId: widget.shiftId!,
        taskId: task.id!,
        token: token,
      );
      widget.onReload?.call();
    } on ApiException catch (e) {
      _showErrorDialog(
        'Cannot mark done',
        _friendlyCompleteError(e.message),
      );
    }
  }

  Future<void> _reopenBackendTask(ZoneTask task, AuthStore auth) async {
    final token = auth.accessToken ?? '';
    if (widget.shiftId == null || task.id == null) return;
    try {
      await _service.reopenTask(
        shiftId: widget.shiftId!,
        taskId: task.id!,
        token: token,
      );
      widget.onReload?.call();
    } on ApiException catch (e) {
      _showErrorDialog(
        'Cannot mark done',
        _friendlyCompleteError(e.message),
      );
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
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
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
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: _shiftGradient(),
          ),
          child: Row(
            children: [
              const _HeaderIcon(),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Zones & Tasks',
                      style: TextStyle(
                        color: ARAColors.cardBg,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Tap a task to join',
                      style: TextStyle(
                        color: ARAColors.cardBg.withValues(alpha: 0.95),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
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
    if (category.isEmpty) return 'Other tasks';
    return category;
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
    final isAssigned =
        meId != null && zone.assignedVolunteerIds.contains(meId);

    final bg = _cardColor(index);
    final pal = _paletteFor(bg);

    return _ZoneCard(
      zone: zone,
      bg: bg,
      palette: pal,
      icon: _statusIcon(index),
      isDone: done,
      isAssigned: isAssigned,
      onTap: () {
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
        setState(() => _signedUp[index] = !_signedUp[index]);
      },
      onComplete: () {
        if (!canJoin) {
          _showJoinBlocked(auth);
          return;
        }
        if (zone.taskId != null && widget.shiftId != null) {
          _completeBackend(zone, auth);
          return;
        }
        setState(() => _zones[index] = zone.copyWith(progress: 1.0));
      },
      onReopen: () {
        if (zone.taskId != null && widget.shiftId != null) {
          _reopenBackend(zone, auth);
          return;
        }
        setState(() => _zones[index] = zone.copyWith(progress: 0.0));
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
    final isAssigned =
        meId != null && task.assignedVolunteerIds.contains(meId);
    final signedUp = _isTaskSignedUp(zone, task);

    return Material(
      color: pal.overlay,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          if (!canJoin) {
            _showJoinBlocked(auth);
            return;
          }
          if (task.id != null && widget.shiftId != null) {
            if (isAssigned) {
              _leaveBackendTask(task, auth);
            } else {
              _joinBackendTask(task, auth);
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
              const SizedBox(width: 8),
              if (!done)
                IconButton(
                  icon: const Icon(Icons.check),
                  color: pal.primary,
                  onPressed: () {
                    if (!canJoin) {
                      _showJoinBlocked(auth);
                      return;
                    }
                    if (task.id != null && widget.shiftId != null) {
                      _completeBackendTask(task, auth);
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
                    if (task.id != null && widget.shiftId != null) {
                      _reopenBackendTask(task, auth);
                      return;
                    }
                    _updateSubtaskProgress(zone, task, 0.0);
                  },
                  style: IconButton.styleFrom(
                    backgroundColor: pal.overlay,
                  ),
                ),
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

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ARAColors.cardBg.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(
        Icons.location_on,
        color: ARAColors.cardBg,
        size: 28,
      ),
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
    final taskLabel = '${taskCount} task${taskCount == 1 ? '' : 's'}';
    final subtitle =
        startTime == null || startTime.isEmpty ? taskLabel : '$startTime • $taskLabel';

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
                      child:
                          Icon(widget.icon, color: pal.onAccentIcon, size: 28),
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
                    if (!widget.isDone)
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
