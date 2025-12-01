import 'package:flutter/material.dart';
import 'package:frontend/screens/common/card.dart';
import '../../widgets/offline_banner.dart';
import 'morning_shift.dart';
import 'evening_shift.dart';
import '../../theme/ara_theme.dart';

class ShiftsScreen extends StatelessWidget {
  const ShiftsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ARAColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            const OfflineBanner(),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Choose Your Shift',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Select when you\'d like to volunteer',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AraCard(
                      title: 'Morning Shift',
                      description: '8:00 AM - 12:00 PM',
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
                      description: '5:00 PM - 7:00 PM',
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
            ),
          ],
        ),
      ),
    );
  }
}
