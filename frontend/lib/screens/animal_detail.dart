// File: lib/screens/animal_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/offline_banner.dart';
import '../models/animal.dart';
import '../services/mock_database.dart';

class AnimalDetailScreen extends StatelessWidget {
  final Animal animal;
  const AnimalDetailScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final isStaff = context.read<MockDatabase>().isStaff;

    return Scaffold(
      appBar: AppBar(title: Text(animal.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const OfflineBanner(),
          const SizedBox(height: 16),
          // Placeholder image
          const CircleAvatar(
            radius: 48,
            child: Icon(Icons.pets, size: 48),
          ),
          const SizedBox(height: 16),
          Text(animal.name,
              style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(animal.personality),
          const SizedBox(height: 16),
          Text(animal.description),
          const SizedBox(height: 16),
          Text('History: ${animal.history}'),
          const SizedBox(height: 24),
          if (animal.trainingVideos.isNotEmpty) ...[
            ElevatedButton(
              onPressed: () {
                // TODO: launch trainingVideos.first via url_launcher
              },
              child: const Text('Training'),
            ),
            const SizedBox(height: 16),
          ],
          if (isStaff) ...[
            ElevatedButton(
              onPressed: () {
                // TODO: navigate to an edit screen
              },
              child: const Text('Edit'),
            ),
          ],
        ],
      ),
    );
  }
}
