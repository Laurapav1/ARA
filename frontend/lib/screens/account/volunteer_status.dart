import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/api_client.dart';
import '../../services/auth_store.dart';
import '../../services/volunteers_service.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';
import 'widgets/change_password_dialog.dart';

class VolunteerStatusScreen extends StatefulWidget {
  const VolunteerStatusScreen({super.key});

  @override
  State<VolunteerStatusScreen> createState() => _VolunteerStatusScreenState();
}

class _VolunteerStatusScreenState extends State<VolunteerStatusScreen> {
  final _service = VolunteersService();
  List<MyVolunteerStay> _stays = [];
  bool _loadingStays = true;

  @override
  void initState() {
    super.initState();
    _loadStays();
  }

  Future<void> _loadStays() async {
    final token = context.read<AuthStore>().accessToken;
    if (token == null || token.isEmpty) {
      setState(() => _loadingStays = false);
      return;
    }

    try {
      final stays = await _service.getMine(token: token);
      if (!mounted) return;
      setState(() {
        _stays = stays;
        _loadingStays = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingStays = false);
    }
  }

  String _fmtIso(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  DateTime? _parseDateOnly(String raw) {
    try {
      final parts = raw.split('-');
      return DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
    } catch (_) {
      return null;
    }
  }

  void _showSnack(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ARAColors.brand,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _handleChangePassword(BuildContext context) async {
    final changed = await showChangePasswordDialog(context);
    if (changed == true && context.mounted) {
      _showSnack(context, 'Password updated');
    }
  }

  Future<void> _handleRequestNewStay(BuildContext context) async {
    final now = _dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 730)),
      helpText: 'Request new stay',
      saveText: 'Request',
      builder: (context, child) {
        final theme = Theme.of(context);
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: ARAColors.brand,
              onPrimary: ARAColors.ink,
            ),
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );

    if (picked == null || !mounted) return;

    final auth = this.context.read<AuthStore>();
    final token = auth.accessToken ?? '';
    try {
      await _service.requestNewStay(
        token: token,
        volunteerFrom: _fmtIso(picked.start),
        volunteerTo: _fmtIso(picked.end),
      );
      await auth.fetchMe();
      await _loadStays();
      if (mounted) {
        _showSnack(this.context, 'Stay request submitted');
      }
    } on ApiException catch (e) {
      if (mounted) {
        _showSnack(this.context, e.message);
      }
    } catch (_) {
      if (mounted) {
        _showSnack(this.context, 'Could not submit stay request.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final me = auth.me;
    final name = me?.fullName ?? 'Volunteer';
    final email = me?.email ?? '';
    final today = _dateOnly(DateTime.now());
    final approved = _stays.where((stay) => stay.isApproved).toList();
    final pending = _stays.where((stay) => stay.isPending).toList()
      ..sort((a, b) => a.volunteerFrom.compareTo(b.volunteerFrom));
    final current = approved.where((stay) {
      final start = _parseDateOnly(stay.volunteerFrom);
      final end = _parseDateOnly(stay.volunteerTo);
      if (start == null || end == null) return false;
      return !today.isBefore(start) && !today.isAfter(end);
    }).toList();
    final upcoming = approved.where((stay) {
      final start = _parseDateOnly(stay.volunteerFrom);
      return start != null && start.isAfter(today);
    }).toList()
      ..sort((a, b) => a.volunteerFrom.compareTo(b.volunteerFrom));
    final previous = approved.where((stay) {
      final end = _parseDateOnly(stay.volunteerTo);
      return end != null && end.isBefore(today);
    }).toList()
      ..sort((a, b) => b.volunteerTo.compareTo(a.volunteerTo));
    final currentStay = current.isNotEmpty ? current.first : null;
    final pendingStay = pending.isNotEmpty ? pending.first : null;
    final upcomingStay = upcoming.isNotEmpty ? upcoming.first : null;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    _ProfileCard(name: name, email: email),
                    const SizedBox(height: 24),
                    const _SectionLabel(title: 'Stay'),
                    const SizedBox(height: 12),
                    if (_loadingStays)
                      const Center(child: CircularProgressIndicator())
                    else ...[
                      _InfoCard(
                        title: 'Current stay',
                        value: currentStay != null
                            ? currentStay.stayLabel
                            : upcomingStay != null
                                ? 'Next stay ${upcomingStay.stayLabel}'
                                : 'No current stay scheduled',
                        icon: Icons.event_available,
                      ),
                      if (pendingStay != null) ...[
                        const SizedBox(height: 12),
                        _InfoCard(
                          title: 'Pending request',
                          value: pendingStay.stayLabel,
                          icon: Icons.pending_actions,
                        ),
                      ],
                    ],
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Last volunteered',
                      value: previous.isEmpty
                          ? 'No previous stays'
                          : previous.first.stayLabel,
                      icon: Icons.history,
                    ),
                    if (previous.length > 1) ...[
                      const SizedBox(height: 12),
                      ...previous.skip(1).take(3).map(
                            (stay) => Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: _InfoCard(
                                title: 'Previous stay',
                                value: stay.stayLabel,
                                icon: Icons.history_toggle_off,
                              ),
                            ),
                          ),
                    ],
                    const SizedBox(height: 12),
                    _SettingsTile(
                      title: 'Request new stay',
                      subtitle: pendingStay == null
                          ? 'Ask staff to approve another volunteer period'
                          : 'You already have a pending request',
                      icon: Icons.event_repeat,
                      onTap: pendingStay == null
                          ? () => _handleRequestNewStay(context)
                          : () async => _showSnack(
                                context,
                                'You already have a pending stay request.',
                              ),
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(title: 'Account'),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      title: 'Change password',
                      subtitle: 'Update your login details',
                      icon: Icons.lock_reset,
                      onTap: () => _handleChangePassword(context),
                    ),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      title: 'Log out',
                      subtitle: 'Sign out of this device',
                      icon: Icons.logout,
                      onTap: () => auth.logout(),
                      isDestructive: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _InfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ARAColors.cardBg,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: ARAColors.ink.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: ARAColors.brand.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: ARAColors.brandDark, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        color: ARAColors.subInk,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: ARAColors.ink,
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  final String name;
  final String email;

  const _ProfileCard({
    required this.name,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ARAColors.cardBg,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: ARAColors.ink.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: ARAColors.cardBg, width: 3),
              boxShadow: [
                BoxShadow(
                  color: ARAColors.ink.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const CircleAvatar(
              radius: 36,
              backgroundColor: ARAColors.surfaceWarmTint,
              child: Icon(Icons.person, color: ARAColors.brandDark, size: 36),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: ARAColors.ink,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: ARAColors.subInk,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: ARAColors.brand.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Approved volunteer',
              style: TextStyle(
                color: ARAColors.brandDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Future<void> Function() onTap;
  final bool isDestructive;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final accent = isDestructive ? ARAColors.danger : ARAColors.brandDark;

    return Material(
      color: ARAColors.cardBg,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: ARAColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: ARAColors.ink.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            color: ARAColors.ink,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: ARAColors.subInk,
                          ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: ARAColors.subInk),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String title;

  const _SectionLabel({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: ARAColors.subInk,
            letterSpacing: 1.2,
            fontWeight: FontWeight.w600,
          ),
    );
  }
}

