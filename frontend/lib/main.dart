import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app/main_scaffold.dart';
import 'services/mock_database.dart';
import 'services/auth_store.dart';
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
