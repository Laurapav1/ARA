import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/mock_database.dart';

class OfflineBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final db = context.watch<MockDatabase>();
    if (!db.isOffline && db.pendingChanges == 0) return SizedBox.shrink();
    return MaterialBanner(
      backgroundColor: db.isOffline ? Colors.red : Colors.orange,
      content: Text(
        db.isOffline
            ? '🔴 Offline – ${db.pendingChanges} pending changes'
            : '🟠 Syncing…',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: db.sync,
          child: Text('Sync now', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
