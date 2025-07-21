import 'package:flutter/material.dart';
import '../widgets/offline_banner.dart';

class ShiftsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // For prototyping, show a placeholder
    return Scaffold(
      appBar: AppBar(title: Text('Shifts')),
      body: Column(
        children: [
          OfflineBanner(),
          Expanded(
            child: Center(child: Text('Morning/Evening shifts go here')),
          ),
        ],
      ),
    );
  }
}
