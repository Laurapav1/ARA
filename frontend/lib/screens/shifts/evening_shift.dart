import 'package:flutter/material.dart';
import 'shift_zone_screen.dart';

class EveningShiftScreen extends StatelessWidget {
  const EveningShiftScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ShiftZoneScreen(
      shiftType: 'Evening',
      date: DateTime.now(),
    );
  }
}
