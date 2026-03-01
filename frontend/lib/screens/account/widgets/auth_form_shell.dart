import 'package:flutter/material.dart';
import '../../../theme/ara_theme.dart';
import '../../../widgets/offline_banner.dart';
import '../../common/page_back_app_bar.dart';

class AuthFormShell extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;
  final double maxWidth;
  final bool showOfflineBanner;

  const AuthFormShell({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.maxWidth = 520,
    this.showOfflineBanner = false,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const PageBackAppBar(),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            if (showOfflineBanner) const OfflineBanner(),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final topInset =
                      (constraints.maxHeight * 0.10).clamp(16.0, 80.0).toDouble();

                  return SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(24, topInset, 24, 32),
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(maxWidth: maxWidth),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              title,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(
                                    color: ARAColors.ink,
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(color: ARAColors.subInk),
                            ),
                            const SizedBox(height: 20),
                            child,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
