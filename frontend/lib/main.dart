import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/mock_database.dart';

import 'screens/account/volunteers.dart';
import 'screens/shifts/shifts.dart';
import 'screens/info/information.dart';
import 'screens/account/account.dart';
import 'screens/animals/animal_home.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => MockDatabase()..isStaff = false, // toggle true for staff
      child: const AnimalRescueApp(),
    ),
  );
}

class AnimalRescueApp extends StatelessWidget {
  const AnimalRescueApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARA Prototype',
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final isStaff = db.isStaff;

    // Build screen list dynamically
    final screens = <Widget>[
      ShiftsScreen(),
      AnimalHomeScreen(),
      const InformationScreen(),
      if (!isStaff) const AccountScreen(), // volunteers
      if (isStaff) const VolunteerRequestsScreen(), // staff
    ];

    // Build nav destinations dynamically
    final destinations = <NavigationDestination>[
      const NavigationDestination(icon: Icon(Icons.schedule), label: 'Shifts'),
      const NavigationDestination(icon: Icon(Icons.pets), label: 'Animals'),
      const NavigationDestination(
          icon: Icon(Icons.info_outline), label: 'Info'),
      if (!isStaff)
        const NavigationDestination(icon: Icon(Icons.person), label: 'Account'),
      if (isStaff)
        NavigationDestination(
          icon: Stack(
            children: [
              const Icon(Icons.person_add_alt_1_outlined),
              if (db.pendingRequests.isNotEmpty)
                Positioned(
                  right: 0,
                  child: CircleAvatar(
                    radius: 6,
                    backgroundColor: Colors.red,
                    child: Text(
                      '${db.pendingRequests.length}',
                      style: TextStyle(fontSize: 8, color: Colors.white),
                    ),
                  ),
                ),
            ],
          ),
          label: 'Requests',
        ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: destinations,
      ),
    );
  }
}
