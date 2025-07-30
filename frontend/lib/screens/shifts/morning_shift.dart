// File: lib/screens/morning_shift.dart
import 'package:flutter/material.dart';
import '../../widgets/offline_banner.dart';
import 'zone_list_screen.dart';
import '../../models/zone_data.dart';

class MorningShiftScreen extends StatelessWidget {
  const MorningShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Morning Shift')),
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(
            child: ZoneListScreen(
              shiftType: 'Morning',
              zones: ZoneData.morningZones,
            ),
          ),
        ],
      ),
    );
  }
}
