import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/auth_store.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

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

  String? _tryFormatRange(String? startIso, String? endIso) {
    if (startIso == null || endIso == null) return null;
    try {
      return '${_fmt(DateTime.parse(startIso))} - ${_fmt(DateTime.parse(endIso))}';
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final stayRange = _tryFormatRange(
      auth.pendingVolunteerFrom,
      auth.pendingVolunteerTo,
    );
    final badgeLabel = auth.pendingAccessRequestSynced
        ? 'Requested'
        : 'Pending sync';
    final badgeColor = auth.pendingAccessRequestSynced
        ? ARAColors.brandDark
        : const Color(0xFF8A5A00);
    final badgeBg = auth.pendingAccessRequestSynced
        ? ARAColors.brand.withValues(alpha: 0.18)
        : const Color(0xFFFFE4B5);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: ARAColors.cardBg,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: ARAColors.ink.withValues(alpha: 0.06),
                            blurRadius: 22,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: ARAColors.brand.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.hourglass_top,
                              size: 64,
                              color: ARAColors.brandDark,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: badgeBg,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              badgeLabel,
                              style: TextStyle(
                                color: badgeColor,
                                fontWeight: FontWeight.w700,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          const SizedBox(height: 18),
                          Text(
                            'Waiting for approval',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: ARAColors.ink,
                                  fontWeight: FontWeight.bold,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Your request is saved and will stay pending until a staff member approves it.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: ARAColors.subInk,
                                ),
                            textAlign: TextAlign.center,
                          ),
                          if (auth.pendingEmail.isNotEmpty) ...[
                            const SizedBox(height: 18),
                            _DetailRow(
                              icon: Icons.mail_outline,
                              label: 'Email',
                              value: auth.pendingEmail,
                            ),
                          ],
                          if (stayRange != null) ...[
                            const SizedBox(height: 12),
                            _DetailRow(
                              icon: Icons.event_available,
                              label: 'Stay dates',
                              value: stayRange,
                            ),
                          ],
                          const SizedBox(height: 16),
                          Text(
                            'You can still use the Info tab while you wait.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: ARAColors.subInk,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.6),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: ARAColors.brandDark, size: 20),
          const SizedBox(width: 10),
          Text(
            '$label:',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: ARAColors.subInk,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
