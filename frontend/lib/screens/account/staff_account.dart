import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_store.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';
import 'widgets/change_password_dialog.dart';

class StaffAccountScreen extends StatelessWidget {
  const StaffAccountScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final me = auth.me;

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
                    const SizedBox(height: 16),
                    _ProfileCard(
                      name: me?.fullName ?? 'Staff',
                      email: me?.email ?? '',
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
              child: Icon(
                Icons.admin_panel_settings,
                color: ARAColors.brandDark,
                size: 36,
              ),
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
              'Staff member',
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

