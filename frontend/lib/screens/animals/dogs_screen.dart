// File: lib/screens/dogs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/offline_banner.dart';
import '../../services/mock_database.dart';
import '../../models/animal.dart';
import 'animal_detail.dart';

class DogsScreen extends StatelessWidget {
  const DogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final animals = context.watch<MockDatabase>().animals;
    final dogs = animals.where((a) => a.species == 'dog').toList();
    final friendly = dogs.where((d) => !d.isDangerous).toList();
    final careful = dogs.where((d) => d.isDangerous).toList();

    Widget section(String title, List<Animal> list) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child:
                Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...list.map((dog) => ListTile(
                leading: const CircleAvatar(child: Icon(Icons.pets)),
                title: Text(dog.name),
                subtitle: Text(dog.personality),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AnimalDetailScreen(animal: dog),
                    ),
                  );
                },
              )),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Dogs')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ListView(
              children: [
                section('Friendly', friendly),
                section('Careful', careful),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
