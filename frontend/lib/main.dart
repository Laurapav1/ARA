import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/mock_database.dart';
import 'widgets/offline_banner.dart';

import 'screens/dashboard.dart';
import 'screens/volunteers.dart';
import 'screens/shifts.dart';
import 'screens/animal_profile.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MockDatabase(),
      child: AnimalRescueApp(),
    ),
  );
}

class AnimalRescueApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARA Prototype',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => DashboardScreen(),
        '/volunteers': (_) => VolunteerRequestsScreen(),
        '/shifts': (_) => ShiftsScreen(),
        '/animals': (_) => AnimalProfileListScreen(),
      },
    );
  }
}
