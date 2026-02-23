import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_store.dart';
import '../screens/account/account_home_screen.dart';
import '../screens/account/pending_approval.dart';
import '../screens/account/staff_account.dart';
import '../screens/account/volunteer_status.dart';
import '../screens/account/volunteers.dart';
import '../screens/animals/animal_home.dart';
import '../screens/info/information.dart';
import '../screens/shifts/shifts_entry_screen.dart';

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

    final shiftsScreen = ShiftsEntryScreen(
      isApproved: isApproved,
      isPending: isPending,
      onOpenAccount: () => setState(() => _currentIndex = 3),
      onOpenInfo: () => setState(() => _currentIndex = 2),
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
            child: const Icon(Icons.groups_outlined),
          ),
          selectedIcon: Badge(
            isLabelVisible: auth.pendingRequestsCount > 0,
            label: Text('${auth.pendingRequestsCount}'),
            child: const Icon(Icons.groups),
          ),
          label: 'Volunteers',
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
