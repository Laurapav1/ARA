import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_store.dart';
import '../../services/volunteers_service.dart';
import '../../services/api_client.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/global_search_filter.dart';
import '../../widgets/offline_banner.dart';
import '../../widgets/screen_header.dart';

class VolunteerRequestsScreen extends StatefulWidget {
  const VolunteerRequestsScreen({super.key});

  @override
  State<VolunteerRequestsScreen> createState() => _VolunteerRequestsScreenState();
}

class _VolunteerRequestsScreenState extends State<VolunteerRequestsScreen> {
  final _service = VolunteersService();
  late final GlobalSearchFilterController<VolunteerStay> _searchController;

  List<VolunteerStay> _volunteers = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _searchController = GlobalSearchFilterController<VolunteerStay>(
      resourceType: 'staff_volunteers',
      titleOf: (volunteer) => volunteer.fullName,
      subtitleOf: (volunteer) => volunteer.email,
      tagsOf: (volunteer) => [
        volunteer.status,
        volunteer.requestedAtLabel,
        volunteer.stayLabel,
      ],
    );
    _loadVolunteers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadVolunteers() async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken;
    if (token == null || token.isEmpty) {
      setState(() {
        _loading = false;
        _error = 'Please sign in as staff.';
      });
      auth.setPendingRequestsCount(0);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await _service.getAll(token: token);
      if (!mounted) return;

      final pendingCount = list.where((v) => v.isPending).length;
      auth.setPendingRequestsCount(pendingCount);

      setState(() {
        _volunteers = list;
        _loading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
      auth.setPendingRequestsCount(0);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Could not load volunteers.';
      });
      auth.setPendingRequestsCount(0);
    }
  }

  DateTime? _parseDateOnly(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      final parts = raw.split('-');
      if (parts.length != 3) return null;
      final year = int.parse(parts[0]);
      final month = int.parse(parts[1]);
      final day = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return null;
    }
  }

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  List<VolunteerStay> get _pending {
    final list = _volunteers.where((v) => v.isPending).toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  List<VolunteerStay> get _upcoming {
    final today = _today;
    final list = _volunteers.where((v) {
      if (!v.isApproved) return false;
      final start = _parseDateOnly(v.volunteerFrom);
      if (start == null) return true;
      return start.isAfter(today);
    }).toList();

    list.sort((a, b) {
      final aStart = _parseDateOnly(a.volunteerFrom) ?? DateTime(9999);
      final bStart = _parseDateOnly(b.volunteerFrom) ?? DateTime(9999);
      return aStart.compareTo(bStart);
    });

    return list;
  }

  List<VolunteerStay> get _activeNow {
    final today = _today;
    final list = _volunteers.where((v) {
      if (!v.isApproved) return false;
      final start = _parseDateOnly(v.volunteerFrom);
      final end = _parseDateOnly(v.volunteerTo);
      if (start == null || end == null) return false;
      return !today.isBefore(start) && !today.isAfter(end);
    }).toList();

    list.sort((a, b) {
      final aEnd = _parseDateOnly(a.volunteerTo) ?? DateTime(9999);
      final bEnd = _parseDateOnly(b.volunteerTo) ?? DateTime(9999);
      return aEnd.compareTo(bEnd);
    });

    return list;
  }

  List<VolunteerStay> get _past {
    final today = _today;
    final list = _volunteers.where((v) {
      if (!v.isApproved) return false;
      final end = _parseDateOnly(v.volunteerTo);
      return end != null && end.isBefore(today);
    }).toList();

    list.sort((a, b) {
      final aEnd = _parseDateOnly(a.volunteerTo) ?? DateTime(1900);
      final bEnd = _parseDateOnly(b.volunteerTo) ?? DateTime(1900);
      return bEnd.compareTo(aEnd);
    });

    return list;
  }

  int _tabIndexForVolunteer(VolunteerStay volunteer) {
    if (volunteer.isPending) return 0;

    final today = _today;
    final start = _parseDateOnly(volunteer.volunteerFrom);
    final end = _parseDateOnly(volunteer.volunteerTo);
    if (start == null || end == null) return 1;
    if (start.isAfter(today)) return 1;
    if (!today.isBefore(start) && !today.isAfter(end)) return 2;
    return 3;
  }

  Future<void> _approve(VolunteerStay volunteer) async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken ?? '';
    try {
      await _service.approve(id: volunteer.id, token: token);
      _showSnack('${volunteer.fullName} approved', ARAColors.success);
      await _loadVolunteers();
    } on ApiException catch (e) {
      _showSnack(e.message, ARAColors.danger);
    }
  }

  Future<void> _decline(VolunteerStay volunteer) async {
    final auth = context.read<AuthStore>();
    final token = auth.accessToken ?? '';
    try {
      await _service.decline(id: volunteer.id, token: token);
      _showSnack('Request declined', ARAColors.danger);
      await _loadVolunteers();
    } on ApiException catch (e) {
      _showSnack(e.message, ARAColors.danger);
    }
  }

  Future<void> _editStay(VolunteerStay volunteer) async {
    final currentStart = _parseDateOnly(volunteer.volunteerFrom);
    final currentEnd = _parseDateOnly(volunteer.volunteerTo);
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, 1, 1);
    final lastDate = DateTime(now.year + 2, 12, 31);

    final initialRange = (currentStart != null && currentEnd != null)
        ? DateTimeRange(start: currentStart, end: currentEnd)
        : DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: DateTime(now.year, now.month, now.day + 7),
          );

    final picked = await showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialRange,
      barrierColor: Colors.black54,
      helpText: 'Edit volunteer stay',
      saveText: 'Save',
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: ARAColors.brand,
              onPrimary: ARAColors.ink,
            ),
            datePickerTheme: DatePickerThemeData(
              rangeSelectionBackgroundColor: ARAColors.brand.withValues(alpha: 0.20),
              dayBackgroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return ARAColors.brand;
                }
                return null;
              }),
              dayForegroundColor: WidgetStateProperty.resolveWith((states) {
                if (states.contains(WidgetState.selected)) {
                  return ARAColors.ink;
                }
                return null;
              }),
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null) return;

    final auth = context.read<AuthStore>();
    final token = auth.accessToken ?? '';
    try {
      await _service.updateStay(
        id: volunteer.id,
        token: token,
        volunteerFrom: _fmtIsoDate(picked.start),
        volunteerTo: _fmtIsoDate(picked.end),
      );
      _showSnack('Stay dates updated', ARAColors.success);
      await _loadVolunteers();
    } on ApiException catch (e) {
      _showSnack(e.message, ARAColors.danger);
    }
  }

  Future<void> _cancelStay(VolunteerStay volunteer) async {
    final approved = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Cancel volunteer stay'),
            content: Text(
              'Cancel ${volunteer.fullName} and remove from active planning?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Keep'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(
                  backgroundColor: ARAColors.danger,
                  foregroundColor: ARAColors.cardBg,
                ),
                child: const Text('Cancel stay'),
              ),
            ],
          ),
        ) ??
        false;

    if (!approved) return;

    final auth = context.read<AuthStore>();
    final token = auth.accessToken ?? '';
    try {
      await _service.cancelStay(id: volunteer.id, token: token);
      _showSnack('Stay cancelled', ARAColors.danger);
      await _loadVolunteers();
    } on ApiException catch (e) {
      _showSnack(e.message, ARAColors.danger);
    }
  }

  String _fmtIsoDate(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    final year = d.year.toString().padLeft(4, '0');
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  void _showDeclineDialog(VolunteerStay volunteer) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Decline request'),
        content: Text('Decline ${volunteer.fullName}\'s volunteer request?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Keep'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _decline(volunteer);
            },
            style: FilledButton.styleFrom(
              backgroundColor: ARAColors.danger,
              foregroundColor: ARAColors.cardBg,
            ),
            child: const Text('Decline request'),
          ),
        ],
      ),
    );
  }

  void _showSnack(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pending = _pending;
    final upcoming = _upcoming;
    final active = _activeNow;
    final past = _past;

    return DefaultTabController(
      length: 4,
      child: Builder(
        builder: (tabContext) {
          final searchAction = buildGlobalSearchFilterActions<VolunteerStay>(
            context: tabContext,
            title: 'volunteers',
            items: _volunteers,
            controller: _searchController,
            showFilter: false,
            searchResultBuilder: (context, volunteer, onTap) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.person)),
              title: Text(volunteer.fullName),
              subtitle: Text(
                '${volunteer.email} - ${volunteer.stayLabel}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              trailing: Text(
                volunteer.status,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: ARAColors.subInk,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              onTap: onTap,
            ),
            onItemSelected: (volunteer) {
              final tabController = DefaultTabController.of(tabContext);
              tabController.animateTo(_tabIndexForVolunteer(volunteer));
            },
          ).first;

          return Scaffold(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            body: SafeArea(
              child: Column(
                children: [
                  const OfflineBanner(),
                  ScreenHeader(
                    title: 'Volunteers',
                    subtitle: 'Manage volunteer stays',
                    trailing: searchAction,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final isNarrow = constraints.maxWidth < 380;

                        return Container(
                          decoration: BoxDecoration(
                            color: ARAColors.cardBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Theme.of(context).dividerColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: TabBar(
                            isScrollable: isNarrow,
                            indicatorSize: TabBarIndicatorSize.label,
                            dividerColor: Colors.transparent,
                            indicatorColor: ARAColors.brand,
                            indicatorWeight: 3,
                            labelStyle: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                            unselectedLabelStyle:
                                Theme.of(context).textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 15,
                                    ),
                            labelPadding: const EdgeInsets.symmetric(horizontal: 8),
                            labelColor: ARAColors.inkStrong,
                            unselectedLabelColor: ARAColors.subInk,
                            tabs: [
                              Tab(height: 48, text: 'Pending (${pending.length})'),
                              const Tab(height: 48, text: 'Upcoming'),
                              const Tab(height: 48, text: 'Active now'),
                              const Tab(height: 48, text: 'Past'),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  Expanded(
                    child: _loading
                        ? const Center(child: CircularProgressIndicator())
                        : _error != null
                            ? _ErrorState(message: _error!, onRetry: _loadVolunteers)
                            : TabBarView(
                                children: [
                                  _VolunteerList(
                                    volunteers: pending,
                                    emptyTitle: 'No pending requests',
                                    emptySubtitle:
                                        'New volunteer applications will appear here.',
                                    onRefresh: _loadVolunteers,
                                    itemBuilder: (v) => _VolunteerStayCard(
                                      volunteer: v,
                                      primaryActionLabel: 'Accept',
                                      secondaryActionLabel: 'Decline request',
                                      onPrimaryAction: () => _approve(v),
                                      onSecondaryAction: () => _showDeclineDialog(v),
                                    ),
                                  ),
                                  _VolunteerList(
                                    volunteers: upcoming,
                                    emptyTitle: 'No upcoming stays',
                                    emptySubtitle:
                                        'Approved volunteers starting today or later show here.',
                                    onRefresh: _loadVolunteers,
                                    itemBuilder: (v) => _VolunteerStayCard(
                                      volunteer: v,
                                      primaryActionLabel: 'Edit dates',
                                      secondaryActionLabel: 'Cancel stay',
                                      onPrimaryAction: () => _editStay(v),
                                      onSecondaryAction: () => _cancelStay(v),
                                    ),
                                  ),
                                  _VolunteerList(
                                    volunteers: active,
                                    emptyTitle: 'No active volunteers right now',
                                    emptySubtitle:
                                        'Current in-shelter volunteers appear here.',
                                    onRefresh: _loadVolunteers,
                                    itemBuilder: (v) => _VolunteerStayCard(
                                      volunteer: v,
                                      primaryActionLabel: 'Edit dates',
                                      secondaryActionLabel: 'Cancel stay',
                                      onPrimaryAction: () => _editStay(v),
                                      onSecondaryAction: () => _cancelStay(v),
                                    ),
                                  ),
                                  _VolunteerList(
                                    volunteers: past,
                                    emptyTitle: 'No past stays yet',
                                    emptySubtitle:
                                        'Completed volunteer stays will appear here.',
                                    onRefresh: _loadVolunteers,
                                    itemBuilder: (v) => _VolunteerStayCard(volunteer: v),
                                  ),
                                ],
                              ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _VolunteerList extends StatelessWidget {
  final List<VolunteerStay> volunteers;
  final String emptyTitle;
  final String emptySubtitle;
  final Future<void> Function() onRefresh;
  final Widget Function(VolunteerStay volunteer) itemBuilder;

  const _VolunteerList({
    required this.volunteers,
    required this.emptyTitle,
    required this.emptySubtitle,
    required this.onRefresh,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    if (volunteers.isEmpty) {
      return RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 84),
            Icon(Icons.volunteer_activism_outlined, size: 72, color: ARAColors.subInk),
            const SizedBox(height: 16),
            Text(
              emptyTitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: ARAColors.ink,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              emptySubtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ARAColors.subInk,
                  ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        itemCount: volunteers.length,
        itemBuilder: (context, index) => itemBuilder(volunteers[index]),
      ),
    );
  }
}

class _VolunteerStayCard extends StatelessWidget {
  final VolunteerStay volunteer;
  final String? primaryActionLabel;
  final String? secondaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onSecondaryAction;

  const _VolunteerStayCard({
    required this.volunteer,
    this.primaryActionLabel,
    this.secondaryActionLabel,
    this.onPrimaryAction,
    this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final hasActions = onPrimaryAction != null || onSecondaryAction != null;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 380;

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Theme.of(context).dividerColor),
            boxShadow: [
              BoxShadow(
                color: ARAColors.ink.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: ARAColors.surfaceCoolSoft,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person, color: ARAColors.brandDark),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            volunteer.fullName,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: ARAColors.ink,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            volunteer.email,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ARAColors.subInk,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                if (isNarrow) ...[
                  _InfoPill(
                    icon: Icons.calendar_today,
                    label: 'Requested ${volunteer.requestedAtLabel}',
                  ),
                  const SizedBox(height: 8),
                  _InfoPill(
                    icon: Icons.event_available,
                    label: volunteer.stayLabel,
                  ),
                ] else
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: _InfoPill(
                            icon: Icons.calendar_today,
                            label: 'Requested ${volunteer.requestedAtLabel}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _InfoPill(
                            icon: Icons.event_available,
                            label: volunteer.stayLabel,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (hasActions) ...[
                  const SizedBox(height: 14),
                  if (isNarrow) ...[
                    if (onPrimaryAction != null)
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: onPrimaryAction,
                          style: FilledButton.styleFrom(
                            backgroundColor: ARAColors.brand,
                            foregroundColor: ARAColors.ink,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(primaryActionLabel ?? 'Action'),
                        ),
                      ),
                    if (onPrimaryAction != null && onSecondaryAction != null)
                      const SizedBox(height: 10),
                    if (onSecondaryAction != null)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: onSecondaryAction,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ARAColors.danger,
                            side: const BorderSide(color: ARAColors.dangerLight),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(secondaryActionLabel ?? 'Action'),
                        ),
                      ),
                  ] else
                    Row(
                      children: [
                        if (onSecondaryAction != null)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: onSecondaryAction,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: ARAColors.danger,
                                side: const BorderSide(color: ARAColors.dangerLight),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(secondaryActionLabel ?? 'Action'),
                            ),
                          ),
                        if (onSecondaryAction != null && onPrimaryAction != null)
                          const SizedBox(width: 10),
                        if (onPrimaryAction != null)
                          Expanded(
                            child: FilledButton(
                              onPressed: onPrimaryAction,
                              style: FilledButton.styleFrom(
                                backgroundColor: ARAColors.brand,
                                foregroundColor: ARAColors.ink,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: Text(primaryActionLabel ?? 'Action'),
                            ),
                          ),
                      ],
                    ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _InfoPill extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoPill({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: ARAColors.surfaceCoolSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: ARAColors.brandDark),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              label,
              softWrap: true,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ARAColors.ink,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 72, color: ARAColors.subInk),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: ARAColors.subInk,
                  ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}
