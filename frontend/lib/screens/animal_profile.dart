// lib/screens/animal_profile.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_database.dart';
import '../widgets/offline_banner.dart';
import '../models/animal.dart';

class AnimalProfileListScreen extends StatelessWidget {
  const AnimalProfileListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final animals = context.watch<MockDatabase>().animals;
    return Scaffold(
      appBar: AppBar(title: const Text('Animals')),
      body: Column(
        children: [
          OfflineBanner(),
          Expanded(
            child: ListView.builder(
              itemCount: animals.length,
              itemBuilder: (_, i) {
                final a = animals[i];
                return ListTile(
                  title: Text(a.name),
                  subtitle: Text(a.personality),
                  trailing: a.isDangerous
                      ? const Icon(Icons.warning, color: Colors.red)
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => AnimalDetailScreen(animal: a),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AnimalDetailScreen extends StatefulWidget {
  final Animal animal;
  const AnimalDetailScreen({super.key, required this.animal});

  @override
  State<AnimalDetailScreen> createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  late String personality;
  late bool isDangerous;
  late String description;
  late String history;

  @override
  void initState() {
    super.initState();
    personality = widget.animal.personality;
    isDangerous = widget.animal.isDangerous;
    description = widget.animal.description;
    history = widget.animal.history;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<MockDatabase>();
    final isStaff = db.isStaff;

    return Scaffold(
      appBar: AppBar(title: Text(widget.animal.name)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            _LabeledField(
              label: 'Personality',
              child: isStaff
                  ? TextFormField(
                      initialValue: personality,
                      onChanged: (v) => personality = v,
                    )
                  : SelectableText(personality),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Dangerous',
              child: isStaff
                  ? Switch(
                      value: isDangerous,
                      onChanged: (v) => setState(() => isDangerous = v),
                    )
                  : Icon(
                      isDangerous ? Icons.warning : Icons.check,
                      color: isDangerous ? Colors.red : Colors.green,
                    ),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'Description',
              child: isStaff
                  ? TextFormField(
                      initialValue: description,
                      maxLines: 3,
                      onChanged: (v) => description = v,
                    )
                  : SelectableText(description.isEmpty ? '—' : description),
            ),
            const SizedBox(height: 16),
            _LabeledField(
              label: 'History',
              child: isStaff
                  ? TextFormField(
                      initialValue: history,
                      maxLines: 4,
                      onChanged: (v) => history = v,
                    )
                  : SelectableText(history.isEmpty ? '—' : history),
            ),
            const SizedBox(height: 24),
            if (isStaff)
              ElevatedButton(
                onPressed: () {
                  db.updateAnimal(
                    widget.animal.copyWith(
                      personality: personality,
                      isDangerous: isDangerous,
                      description: description,
                      history: history,
                    ),
                  );
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
          ],
        ),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  final String label;
  final Widget child;
  const _LabeledField({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        child,
      ],
    );
  }
}
