import 'dart:async';

import 'package:flutter/foundation.dart';

import 'api_client.dart';
import 'optimistic_sync_store.dart';

typedef OptimisticRetryable = bool Function(Object error);

class OptimisticMutationRunner {
  OptimisticMutationRunner(this._syncStore);

  final OptimisticSyncStore _syncStore;
  final Map<String, Timer> _retryTimers = {};

  void run({
    required String key,
    required VoidCallback applyOptimistic,
    required Future<void> Function() sync,
    required VoidCallback revertOptimistic,
    VoidCallback? onSuccess,
    ValueChanged<Object>? onPermanentFailure,
    OptimisticRetryable isRetryable = defaultRetryable,
    Duration retryDelay = const Duration(seconds: 15),
  }) {
    _retryTimers.remove(key)?.cancel();
    applyOptimistic();
    _syncStore.queueOperation(
      key: key,
      retry: () async {
        _attempt(
          key: key,
          sync: sync,
          revertOptimistic: revertOptimistic,
          onSuccess: onSuccess,
          onPermanentFailure: onPermanentFailure,
          isRetryable: isRetryable,
          retryDelay: retryDelay,
        );
      },
    );
    _attempt(
      key: key,
      sync: sync,
      revertOptimistic: revertOptimistic,
      onSuccess: onSuccess,
      onPermanentFailure: onPermanentFailure,
      isRetryable: isRetryable,
      retryDelay: retryDelay,
    );
  }

  void _attempt({
    required String key,
    required Future<void> Function() sync,
    required VoidCallback revertOptimistic,
    VoidCallback? onSuccess,
    ValueChanged<Object>? onPermanentFailure,
    required OptimisticRetryable isRetryable,
    required Duration retryDelay,
  }) {
    _syncStore.markSyncing(key);
    unawaited(
      sync().then((_) {
        _retryTimers.remove(key)?.cancel();
        _syncStore.markSucceeded(key);
        onSuccess?.call();
      }).catchError((Object error) {
        if (isRetryable(error)) {
          _syncStore.markFailed(key);
          _retryTimers.remove(key)?.cancel();
          _retryTimers[key] = Timer(retryDelay, () {
            _attempt(
              key: key,
              sync: sync,
              revertOptimistic: revertOptimistic,
              onSuccess: onSuccess,
              onPermanentFailure: onPermanentFailure,
              isRetryable: isRetryable,
              retryDelay: retryDelay,
            );
          });
          return;
        }

        _retryTimers.remove(key)?.cancel();
        _syncStore.clearOperation(key);
        revertOptimistic();
        onPermanentFailure?.call(error);
      }),
    );
  }

  void dispose() {
    for (final timer in _retryTimers.values) {
      timer.cancel();
    }
    _retryTimers.clear();
  }

  static bool defaultRetryable(Object error) {
    if (error is ApiException) {
      return error.statusCode == 408 ||
          error.statusCode == 425 ||
          error.statusCode == 429 ||
          error.statusCode >= 500;
    }
    return true;
  }
}

