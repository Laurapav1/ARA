import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_store.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';

class VolunteerStatusScreen extends StatelessWidget {
  const VolunteerStatusScreen({super.key});

  String _fmt(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String _fmtRange(DateTime start, DateTime end) =>
      '${_fmt(start)} – ${_fmt(end)}';

  void _showChangePasswordDialog(BuildContext context) {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change password'),
        actionsAlignment: MainAxisAlignment.center,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'New password',
                prefixIcon: Icon(Icons.lock_reset),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Confirm new password',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Password updated'),
                  backgroundColor: ARAColors.brand,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final me = auth.me;
    final name = me?.fullName ?? 'Volunteer';
    final email = me?.email ?? '';

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
                    _InfoCard(
                      title: 'Current stay',
                      value: me?.volunteerFrom != null &&
                              me?.volunteerTo != null
                          ? _fmtRange(
                              DateTime.parse(me!.volunteerFrom!),
                              DateTime.parse(me.volunteerTo!),
                            )
                          : 'No current stay scheduled',
                      icon: Icons.event_available,
                    ),
                    const SizedBox(height: 12),
                    _InfoCard(
                      title: 'Previous stays',
                      value: 'No previous stays',
                      icon: Icons.history,
                    ),
                    const SizedBox(height: 24),
                    const _SectionLabel(title: 'Account'),
                    const SizedBox(height: 12),
                    _SettingsTile(
                      title: 'Change password',
                      subtitle: 'Update your login details',
                      icon: Icons.lock_reset,
                      onTap: () => _showChangePasswordDialog(context),
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
  final VoidCallback onTap;
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
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
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
