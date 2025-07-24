// File: lib/screens/cats_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/offline_banner.dart';
import '../services/mock_database.dart';
import 'animal_detail.dart';

class CatsScreen extends StatelessWidget {
  const CatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final animals = context.watch<MockDatabase>().animals;
    final cats = animals.where((a) => a.species == 'cat').toList();

    return Scaffold(
      appBar: AppBar(title: const Text('Cats')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView.builder(
              itemCount: cats.length,
              itemBuilder: (_, i) {
                final cat = cats[i];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.pets)),
                  title: Text(cat.name),
                  subtitle: Text(cat.personality),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimalDetailScreen(animal: cat),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
