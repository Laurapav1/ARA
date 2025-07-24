// File: lib/screens/animal_home.dart
import 'package:flutter/material.dart';
import '../widgets/offline_banner.dart';
import 'dogs_screen.dart';
import 'cats_screen.dart';

class AnimalHomeScreen extends StatelessWidget {
  const AnimalHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Animals')),
      body: Column(
        children: [
          const OfflineBanner(),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DogsScreen()),
            ),
            child: const Text('Dogs'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CatsScreen()),
            ),
            child: const Text('Cats'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
