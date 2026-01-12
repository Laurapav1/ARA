import 'package:flutter/material.dart';
import 'shift_zone_screen.dart';

class MorningShiftScreen extends StatelessWidget {
  const MorningShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShiftZoneScreen(
      shiftType: 'Morning',
      date: DateTime.now(),
    );
  }
}
