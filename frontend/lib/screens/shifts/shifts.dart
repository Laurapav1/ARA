import 'package:flutter/material.dart';
import 'package:frontend/screens/common/card.dart';
import '../../widgets/offline_banner.dart';
import 'morning_shift.dart';
import 'evening_shift.dart';
import '../../models/zone_data.dart';
import '../../theme/ara_theme.dart';
import '../../widgets/screen_header.dart';

class ShiftsScreen extends StatelessWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final schedule = ZoneData.scheduleFor(DateTime.now());

    return Scaffold(
      backgroundColor: ARAColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            const ScreenHeader(
              title: 'Choose Your Shift',
              subtitle: 'Select when you\'d like to volunteer',
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                children: [
                  AraCard(
                    title: 'Morning Shift',
                    description: '${schedule.label} - ${schedule.morning}',
                    icon: Icons.wb_sunny,
                    gradient: ARAColors.morningGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const MorningShiftScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  AraCard(
                    title: 'Evening Shift',
                    description: '${schedule.label} - ${schedule.evening}',
                    icon: Icons.nightlight_round,
                    gradient: ARAColors.eveningGradient,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const EveningShiftScreen(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
