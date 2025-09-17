// File: lib/screens/animal_detail.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../widgets/offline_banner.dart';
import '../../services/mock_database.dart';
import '../../models/animal.dart';
import '../../models/handling_flag.dart';
import '../../widgets/handling_flag_chips.dart';

class AnimalDetailScreen extends StatelessWidget {
  final Animal animal;
  const AnimalDetailScreen({super.key, required this.animal});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final isStaff = db.isStaff;

    // Always show the newest copy from the DB (so edits reflect immediately)
    final a = db.animals.firstWhere(
      (x) => x.id == animal.id,
      orElse: () => animal,
    );

    return Scaffold(
      appBar: AppBar(title: Text(a.name)),
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

          Text(a.name, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(a.personality),

          // Handling flags section
          if (a.flags.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text('Handling', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            HandlingFlagChips(flags: a.flags),
          ],

          const SizedBox(height: 16),
          Text(a.description),
          const SizedBox(height: 16),
          Text('History: ${a.history}'),

          const SizedBox(height: 24),
          if (a.trainingVideos.isNotEmpty) ...[
            ElevatedButton(
              onPressed: () {
                // TODO: launch a.trainingVideos.first via url_launcher
              },
              child: const Text('Training'),
            ),
            const SizedBox(height: 16),
          ],

          if (isStaff) ...[
            ElevatedButton(
              onPressed: () => _editFlags(context, a),
              child: const Text('Edit handling flags'),
            ),
          ],
        ],
      ),
    );
  }

  void _editFlags(BuildContext context, Animal currentAnimal) async {
    final db = context.read<MockDatabase>();
    final working = Set<HandlingFlag>.from(currentAnimal.flags);

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 560,
            maxHeight: MediaQuery.of(ctx).size.height * 0.8,
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Handling flags',
                        style: Theme.of(ctx).textTheme.titleLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: StatefulBuilder(
                    builder: (ctx, setState) => ListView(
                      children: HandlingFlag.values.map((f) {
                        return CheckboxListTile(
                          value: working.contains(f),
                          onChanged: (v) => setState(() {
                            v == true ? working.add(f) : working.remove(f);
                          }),
                          secondary: Icon(f.icon, color: f.color),
                          title: Text(f.label),
                          dense: true,
                          controlAffinity: ListTileControlAffinity.leading,
                        );
                      }).toList(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: FilledButton(
                    onPressed: () {
                      db.updateAnimal(currentAnimal.copyWith(flags: working));
                      Navigator.of(ctx).pop();
                    },
                    child: const Text('Save'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
