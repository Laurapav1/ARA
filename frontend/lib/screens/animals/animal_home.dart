import 'package:flutter/material.dart';
import '../../widgets/offline_banner.dart';
import 'dogs_screen.dart';
import 'cats_screen.dart';
import '../../theme/ara_theme.dart';
import '../common/card.dart';
import '../../widgets/screen_header.dart';

class AnimalHomeScreen extends StatelessWidget {
  const AnimalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            const ScreenHeader(
              title: 'Meet Our Animals',
            ),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final topInset =
                      (constraints.maxHeight * 0.14).clamp(12.0, 96.0).toDouble();

                  return ListView(
                    padding: EdgeInsets.fromLTRB(24, topInset, 24, 24),
                    children: [
                      AraCard(
                        title: 'Dogs',
                        description: 'Meet our canine companions',
                        icon: Icons.pets,
                        gradient: ARAColors.dogGradient,
                        image: '\u{1F415}',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const DogsScreen()),
                        ),
                      ),
                      const SizedBox(height: 20),
                      AraCard(
                        title: 'Cats',
                        description: 'Explore our feline friends',
                        icon: Icons.pets,
                        gradient: ARAColors.catGradient,
                        image: '\u{1F408}',
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const CatsScreen()),
                        ),
                      ),
                    ],
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
