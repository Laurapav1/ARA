import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/mock_database.dart';
import 'services/auth_store.dart';
import 'screens/account/volunteers.dart';
import 'screens/account/pending_approval.dart';
import 'screens/account/volunteer_status.dart';
import 'screens/account/staff_account.dart';
import 'screens/shifts/shifts.dart';
import 'screens/info/information.dart';
import 'screens/account/account_home_screen.dart';
import 'screens/animals/animal_home.dart';
import 'screens/common/access_gate.dart';
import 'theme/ara_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthStore()),
        ChangeNotifierProxyProvider<AuthStore, MockDatabase>(
          create: (_) => MockDatabase(),
          update: (_, auth, db) {
            db ??= MockDatabase();
            db.setStaff(auth.isStaff);
            return db;
          },
        ),
      ],
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
      debugShowCheckedModeBanner: false,
      theme: ARATheme.light,
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
  int _currentIndex = 3;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthStore>();
    final isStaff = auth.isStaff;
    final isApproved = auth.isApproved;
    final isPending = auth.isPending;

    final shiftsScreen = AccessGate(
      allowed: isApproved,
      title: isPending ? 'Waiting for approval' : 'Volunteer access required',
      message: isPending
          ? 'Your request is pending review. You will get access once approved.'
          : 'Sign in or submit a volunteer request to access shifts.',
      ctaLabel: isPending ? 'Go to Info' : 'Apply or Sign In',
      onCta: () => setState(() => _currentIndex = isPending ? 2 : 3),
      child: const ShiftsScreen(),
    );

    const animalsScreen = AnimalHomeScreen();

    final accountScreen = isPending
        ? const PendingApprovalScreen()
        : isApproved
            ? const VolunteerStatusScreen()
            : const AccountScreen();

    final screens = <Widget>[
      shiftsScreen,
      animalsScreen,
      const InformationScreen(),
      if (!isStaff) accountScreen,
      if (isStaff) const VolunteerRequestsScreen(),
      if (isStaff) const StaffAccountScreen(),
    ];

    if (_currentIndex >= screens.length) {
      _currentIndex = screens.length - 1;
    }

    final destinations = <NavigationDestination>[
      const NavigationDestination(
        icon: Icon(Icons.schedule_outlined),
        selectedIcon: Icon(Icons.schedule),
        label: 'Shifts',
      ),
      const NavigationDestination(
        icon: Icon(Icons.pets_outlined),
        selectedIcon: Icon(Icons.pets),
        label: 'Animals',
      ),
      const NavigationDestination(
        icon: Icon(Icons.info_outline),
        selectedIcon: Icon(Icons.info),
        label: 'Info',
      ),
      if (!isStaff)
        const NavigationDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: 'Account',
        ),
      if (isStaff)
        NavigationDestination(
          icon: Badge(
            isLabelVisible: auth.pendingRequestsCount > 0,
            label: Text('${auth.pendingRequestsCount}'),
            child: const Icon(Icons.person_add_alt_1_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: auth.pendingRequestsCount > 0,
            label: Text('${auth.pendingRequestsCount}'),
            child: const Icon(Icons.person_add_alt_1),
          ),
          label: 'Requests',
        ),
      if (isStaff)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Account',
        ),
    ];

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: screens[_currentIndex],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          border: const Border(
            top: BorderSide(color: Color(0x1A000000), width: 1),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (i) => setState(() => _currentIndex = i),
          destinations: destinations,
          elevation: 0,
          height: 70,
        ),
      ),
    );
  }
}
