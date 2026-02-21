import 'package:flutter/material.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/offline_banner.dart';
import 'hero_circle.dart';

class AccessGate extends StatelessWidget {
  final bool allowed;
  final String title;
  final String message;
  final String ctaLabel;
  final VoidCallback onCta;
  final Widget child;

  const AccessGate({
    super.key,
    required this.allowed,
    required this.title,
    required this.message,
    required this.ctaLabel,
    required this.onCta,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    if (allowed) return child;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 36),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 460),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        HeroCircle(
                          backgroundColor: ARAColors.brand.withValues(
                            alpha: 0.15,
                          ),
                          child: Center(
                            child: Icon(
                              Icons.lock,
                              size: 52,
                              color: ARAColors.brandDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 22),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: ARAColors.ink,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.2,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          message,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: ARAColors.subInk.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: onCta,
                                child: Text(ctaLabel),
                              ),
                            ),
                          ),
                        ),
                      ],
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
