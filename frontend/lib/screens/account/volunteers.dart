import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/mock_database.dart';
import '../../widgets/offline_banner.dart';

class VolunteerRequestsScreen extends StatelessWidget {
  const VolunteerRequestsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    final requests = db.pendingRequests;

    return Scaffold(
      appBar: AppBar(title: Text('Volunteer Requests')),
      body: Column(
        children: [
          OfflineBanner(),
          Expanded(
            child: ListView.builder(
              itemCount: requests.length,
              itemBuilder: (_, i) {
                final v = requests[i];
                return ListTile(
                  title: Text(v.name),
                  subtitle: Text('End: ${v.endOfStay.toLocal()}'.split(' ')[0]),
                  trailing: ElevatedButton(
                    child: Text('Accept'),
                    onPressed: () => db.acceptRequest(v.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
