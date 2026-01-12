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
import 'screens/account/account.dart';
import 'screens/animals/animal_home.dart';
import 'screens/common/access_gate.dart';
import 'theme/ara_theme.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockDatabase()..isStaff = false),
        ChangeNotifierProvider(create: (_) => AuthStore()),
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
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainScaffold(),
            transitionsBuilder: (_, anim, __, child) {
              return FadeTransition(opacity: anim, child: child);
            },
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              const Color(0xFFF3A93B), // ARA golden
              const Color(0xFFE8952A), // Slightly darker golden
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ARA Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.network(
                      'https://animalrescuealgarve.com/wp-content/uploads/2025/05/ARA-Website-logo-new.png',
                      width: 120,
                      height: 120,
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to paw icon if logo fails to load
                        return const Icon(
                          Icons.pets,
                          size: 80,
                          color: Color(0xFFF3A93B),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Animal Rescue Algarve',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Volunteer Portal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 16,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
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
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: destinations,
        elevation: 8,
        height: 70,
      ),
    );
  }
}
