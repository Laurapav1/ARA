import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_database.dart';
import '../widgets/offline_banner.dart';
import '../models/animal.dart';

class AnimalProfileListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final animals = context.watch<MockDatabase>().animals;
    return Scaffold(
      appBar: AppBar(title: Text('Animals')),
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
                      ? Icon(Icons.warning, color: Colors.red)
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
  AnimalDetailScreen({required this.animal});

  @override
  _AnimalDetailScreenState createState() => _AnimalDetailScreenState();
}

class _AnimalDetailScreenState extends State<AnimalDetailScreen> {
  late String personality;
  late bool isDangerous;

  @override
  void initState() {
    super.initState();
    personality = widget.animal.personality;
    isDangerous = widget.animal.isDangerous;
  }

  @override
  Widget build(BuildContext context) {
    final db = context.read<MockDatabase>();

    return Scaffold(
      appBar: AppBar(title: Text(widget.animal.name)),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Text('Personality:'),
                SizedBox(width: 8),
                Expanded(
                  child: TextFormField(
                    initialValue: personality,
                    onChanged: (v) => personality = v,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text('Dangerous:'),
                Switch(
                  value: isDangerous,
                  onChanged: (v) => setState(() => isDangerous = v),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              child: Text('Save'),
              onPressed: () {
                db.updateAnimal(
                  widget.animal.copyWith(
                    personality: personality,
                    isDangerous: isDangerous,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
