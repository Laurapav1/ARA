import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/mock_database.dart';

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
  const AnimalRescueApp({super.key});

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
