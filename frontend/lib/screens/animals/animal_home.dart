import 'package:flutter/material.dart';
import '../../widgets/offline_banner.dart';
import 'dogs_screen.dart';
import 'cats_screen.dart';
import '../../theme/ara_theme.dart';
import '../common/card.dart';

class AnimalHomeScreen extends StatelessWidget {
  const AnimalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // pull background from theme
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ARAColors.brand,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        const Icon(Icons.pets, color: Colors.white, size: 32),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meet Our Animals',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      Text(
                        'Find your furry friend',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    const Spacer(),
                    AraCard(
                      title: 'Dogs',
                      description: 'Meet our canine companions',
                      icon: Icons.pets,
                      gradient: ARAColors.dogGradient, // blue family
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
                      gradient: ARAColors.catGradient, // pink/magenta family
                      image: '🐈',
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CatsScreen()),
                      ),
                    ),
                    const Spacer(flex: 2),
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
