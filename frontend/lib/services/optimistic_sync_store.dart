import 'dart:async';

import 'package:flutter/foundation.dart';

class OptimisticSyncStore extends ChangeNotifier {
  OptimisticSyncStore({
    Duration bannerGracePeriod = const Duration(seconds: 5),
  }) : _bannerGracePeriod = bannerGracePeriod;

  final Duration _bannerGracePeriod;
  final Map<String, _TrackedSyncOperation> _operations = {};

  bool get hasVisibleOperations =>
      _operations.values.any((operation) => operation.visible);

  bool get hasVisibleFailures => _operations.values.any(
        (operation) => operation.visible && operation.failed,
      );

  String? get bannerMessage {
    if (!hasVisibleOperations) return null;
    if (hasVisibleFailures) {
      return 'Not synced yet. Retrying automatically...';
    }
    return 'Syncing changes...';
  }

  void queueOperation({
    required String key,
    required Future<void> Function() retry,
  }) {
    clearOperation(key, notify: false);
    final operation = _TrackedSyncOperation(
      retry: retry,
      timer: Timer(_bannerGracePeriod, () {
        final current = _operations[key];
        if (current == null || current.failed || current.visible) return;
        current.visible = true;
        notifyListeners();
      }),
    );
    _operations[key] = operation;
    notifyListeners();
  }

  void markSyncing(String key) {
    final operation = _operations[key];
    if (operation == null) return;
    operation.failed = false;
    notifyListeners();
  }

  void markFailed(String key) {
    final operation = _operations[key];
    if (operation == null) return;
    operation.timer?.cancel();
    operation.timer = null;
    operation.failed = true;
    operation.visible = true;
    notifyListeners();
  }

  void markSucceeded(String key) {
    clearOperation(key);
  }

  void clearOperation(String key, {bool notify = true}) {
    final operation = _operations.remove(key);
    operation?.timer?.cancel();
    if (notify) notifyListeners();
  }

  Future<void> retryVisibleOperations() async {
    final retries = _operations.entries
        .where((entry) => entry.value.visible)
        .map((entry) => entry.value.retry)
        .toList(growable: false);
    for (final retry in retries) {
      await retry();
    }
  }

  @override
  void dispose() {
    for (final operation in _operations.values) {
      operation.timer?.cancel();
    }
    super.dispose();
  }
}

class _TrackedSyncOperation {
  _TrackedSyncOperation({
    required this.retry,
    this.timer,
  });

  final Future<void> Function() retry;
  Timer? timer;
  bool visible = false;
  bool failed = false;
}
