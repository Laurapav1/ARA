// File: lib/screens/evening_shift.dart
import 'package:flutter/material.dart';
import '../widgets/offline_banner.dart';
import 'zone_list_screen.dart';
import '../models/zone_data.dart';

class EveningShiftScreen extends StatelessWidget {
  const EveningShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evening Shift')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ZoneListScreen(
              shiftType: 'Evening',
              zones: ZoneData.eveningZones,
            ),
          ),
        ],
      ),
    );
  }
}
