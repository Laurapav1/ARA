import 'package:flutter/material.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';

class PendingApprovalScreen extends StatelessWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                    const SizedBox(height: 24),
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
                      'Your request has been submitted. A staff member will review it soon.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: ARAColors.subInk,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
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
          ],
        ),
      ),
    );
  }
}
