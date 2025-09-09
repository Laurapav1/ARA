// File: lib/screens/dogs_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/offline_banner.dart';
import '../../services/mock_database.dart';
import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../widgets/handling_flag_chips.dart'; // still used on detail screen
import 'animal_detail.dart';

class DogsScreen extends StatelessWidget {
  const DogsScreen({super.key});

  bool _requiresCaution(Animal a) =>
      a.isDangerous || (a.flags.isNotEmpty); // flags imply extra care

  @override
  Widget build(BuildContext context) {
    final animals = context.watch<MockDatabase>().animals;
    final dogs = animals.where((a) => a.species == 'dog').toList();

    final friendly = dogs.where((d) => !_requiresCaution(d)).toList();
    final careful = dogs.where((d) => _requiresCaution(d)).toList();

    Widget section(String title, List<Animal> list) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(title, style: Theme.of(context).textTheme.titleMedium),
          ),
          ...list.map(
            (dog) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.pets)),
              title: Text(dog.name),
              subtitle: Text(dog.personality),
              // Tiny indicators on the right (or null if none)
              trailing: dog.flags.isNotEmpty
                  ? HandlingFlagIcons(flags: dog.flags)
                  : null,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AnimalDetailScreen(animal: dog),
                  ),
                );
              },
              // Optional: press-and-hold for a quick peek
              onLongPress: dog.flags.isEmpty
                  ? null
                  : () => _showFlagsQuick(context, dog),
            ),
          ),
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

  void _showFlagsQuick(BuildContext context, Animal dog) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Handling • ${dog.name}'),
        content: HandlingFlagChips(flags: dog.flags), // reuse chips here
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AnimalDetailScreen(animal: dog),
                ),
              );
            },
            child: const Text('Open profile'),
          ),
        ],
      ),
    );
  }
}

/// Tiny, unobtrusive icons row for list items.
/// Shows up to 3 flag icons; if more, shows "+N".
class HandlingFlagIcons extends StatelessWidget {
  final Set<HandlingFlag> flags;
  final double size;
  const HandlingFlagIcons({super.key, required this.flags, this.size = 16});

  @override
  Widget build(BuildContext context) {
    final list = flags.toList();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final f in list.take(3))
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Icon(f.icon, size: size, color: f.color),
          ),
        if (list.length > 3)
          Padding(
            padding: const EdgeInsets.only(left: 6),
            child: Text(
              '+${list.length - 3}',
              style: Theme.of(context).textTheme.labelSmall,
            ),
          ),
      ],
    );
  }
}
