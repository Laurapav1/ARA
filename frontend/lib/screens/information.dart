import 'package:flutter/material.dart';
import '../widgets/offline_banner.dart';

class InformationScreen extends StatelessWidget {
  const InformationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Information')),
      body: Column(
        children: [
          OfflineBanner(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.all(16),
              children: [
                Text('Map', style: Theme.of(context).textTheme.titleLarge),
                Container(
                  height: 200,
                  color: Colors.grey[300],
                  child: Center(child: Text('Map placeholder')),
                ),
                SizedBox(height: 24),
                Text('Tips & Tricks',
                    style: Theme.of(context).textTheme.titleLarge),
                Text(
                    '• Keep water bowls full\n• Check kennels for debris\n• …'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
