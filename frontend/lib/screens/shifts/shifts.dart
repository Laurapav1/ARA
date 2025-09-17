// File: lib/screens/shifts.dart
import 'package:flutter/material.dart';
import '../../widgets/offline_banner.dart';
import 'morning_shift.dart';
import 'evening_shift.dart';

/// Main Shifts screen with two buttons
class ShiftsScreen extends StatelessWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Shifts')),
      body: Column(
        children: [
          const OfflineBanner(),
          const Spacer(),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const MorningShiftScreen()),
            ),
            child: const Text('Morning Shift'),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EveningShiftScreen()),
            ),
            child: const Text('Evening Shift'),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}
