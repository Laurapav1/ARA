import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_database.dart';
import '../widgets/offline_banner.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    return Scaffold(
      appBar: AppBar(title: Text('ARA Dashboard')),
      body: Column(
        children: [
          OfflineBanner(),
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Volunteer Requests'),
                  trailing: db.pendingRequests.isNotEmpty
                      ? CircleAvatar(
                          child: Text('${db.pendingRequests.length}'))
                      : null,
                  onTap: () => Navigator.pushNamed(context, '/volunteers'),
                ),
                ListTile(
                  title: Text('Shifts'),
                  onTap: () => Navigator.pushNamed(context, '/shifts'),
                ),
                ListTile(
                  title: Text('Animals'),
                  onTap: () => Navigator.pushNamed(context, '/animals'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
