import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/mock_database.dart';
import '../services/optimistic_sync_store.dart';

class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final syncStore = context.watch<OptimisticSyncStore>();
    final db = context.watch<MockDatabase>();

    final hasSyncBanner = syncStore.hasVisibleOperations;
    final hasDbBanner = db.pendingChanges > 0;
    if (!hasSyncBanner && !hasDbBanner) return const SizedBox.shrink();

    final backgroundColor = hasSyncBanner
        ? (syncStore.hasVisibleFailures ? Colors.red : Colors.orange)
        : (db.isOffline ? Colors.red : Colors.orange);
    final content = hasSyncBanner
        ? syncStore.bannerMessage!
        : (db.isOffline
            ? 'Offline - ${db.pendingChanges} pending changes'
            : 'Syncing...');

    return MaterialBanner(
      backgroundColor: backgroundColor,
      content: Text(
        content,
        style: const TextStyle(color: Colors.white),
      ),
      actions: [
        TextButton(
          onPressed: hasSyncBanner
              ? context.read<OptimisticSyncStore>().retryVisibleOperations
              : db.sync,
          child: const Text(
            'Sync now',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
