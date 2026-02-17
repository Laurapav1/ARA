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
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
                children: [
                  AraCard(
                    title: 'Dogs',
                    description: 'Meet our canine companions',
                    icon: Icons.pets,
                    gradient: ARAColors.dogGradient,
                    image: '🐕',
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
                    image: '🐈',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CatsScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
