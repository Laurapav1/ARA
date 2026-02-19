import 'package:flutter/material.dart';
import '../../theme/ara_theme.dart';
import '../common/hero_circle.dart';
import '../../widgets/offline_banner.dart';
import 'account.dart';
import 'login_screen.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                        const _AraHomeLogo(),
                        const SizedBox(height: 22),
                        Text(
                          'Animal Rescue Algarve',
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
                          "Help care for our animals\nPortugal's shelter community",
                          textAlign: TextAlign.center,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                color: ARAColors.subInk.withValues(alpha: 0.7),
                                height: 1.5,
                              ),
                        ),
                        const SizedBox(height: 28),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: SizedBox(
                              width: double.infinity,
                              child: FilledButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LoginScreen(),
                                  ),
                                ),
                                child: const Text('Sign In'),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 280),
                            child: SizedBox(
                              width: double.infinity,
                              child: OutlinedButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const RequestAccessScreen(),
                                  ),
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ARAColors.ink,
                                  side: BorderSide(
                                    color: Theme.of(context).dividerColor
                                        .withValues(alpha: 0.9),
                                  ),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  textStyle: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                child: const Text('Create Account'),
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

class _AraHomeLogo extends StatelessWidget {
  const _AraHomeLogo();

  @override
  Widget build(BuildContext context) {
    return HeroCircle(
      child: ClipOval(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Image.asset(
            'assets/images/ARA-logo.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
