import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'pending_operation.dart';
import 'sync_service.dart';

/// Immutable state representing the current sync status.
class SyncState {
  /// Whether the device currently has network connectivity.
  final bool isOnline;

  /// Whether a sync operation is currently in progress.
  final bool isSyncing;

  /// Number of operations waiting to be synced.
  final int pendingCount;

  /// Timestamp of the last successful sync.
  final DateTime? lastSync;

  /// Error message from the last sync attempt, if any.
  final String? syncError;

  const SyncState({
    this.isOnline = true,
    this.isSyncing = false,
    this.pendingCount = 0,
    this.lastSync,
    this.syncError,
  });

  /// Create a copy with updated fields.
  SyncState copyWith({
    bool? isOnline,
    bool? isSyncing,
    int? pendingCount,
    DateTime? lastSync,
    String? syncError,
    bool clearSyncError = false,
  }) {
    return SyncState(
      isOnline: isOnline ?? this.isOnline,
      isSyncing: isSyncing ?? this.isSyncing,
      pendingCount: pendingCount ?? this.pendingCount,
      lastSync: lastSync ?? this.lastSync,
      syncError: clearSyncError ? null : (syncError ?? this.syncError),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncState &&
          runtimeType == other.runtimeType &&
          isOnline == other.isOnline &&
          isSyncing == other.isSyncing &&
          pendingCount == other.pendingCount &&
          lastSync == other.lastSync &&
          syncError == other.syncError;

  @override
  int get hashCode => Object.hash(
        isOnline,
        isSyncing,
        pendingCount,
        lastSync,
        syncError,
      );

  @override
  String toString() =>
      'SyncState(isOnline: $isOnline, isSyncing: $isSyncing, '
      'pendingCount: $pendingCount, lastSync: $lastSync, '
      'syncError: $syncError)';
}

/// StateNotifier that manages the sync lifecycle.
///
/// Responsibilities:
/// - Track online/offline status
/// - Enqueue pending operations via [addPendingOp]
/// - Trigger sync via [triggerSync]
/// - Auto-sync with 2-second delay when transitioning from offline to online
class SyncNotifier extends StateNotifier<SyncState> {
  final SyncService? _syncService;
  Timer? _autoSyncTimer;

  SyncNotifier(this._syncService) : super(const SyncState()) {
    if (_syncService != null) _refreshPendingCount();
  }

  /// Update the network connectivity status.
  ///
  /// If transitioning from offline to online, automatically triggers
  /// a sync after a 2-second delay to allow the connection to stabilize.
  void setOnline(bool online) {
    final wasOffline = !state.isOnline;
    state = state.copyWith(isOnline: online);

    if (wasOffline && online) {
      debugPrint(
        '[SyncNotifier] Conexao restaurada. '
        'Sincronizacao automatica em 2 segundos...',
      );

      // Cancel any existing timer
      _autoSyncTimer?.cancel();

      // Delay sync to let connection stabilize
      _autoSyncTimer = Timer(const Duration(seconds: 2), () {
        triggerSync();
      });
    }
  }

  /// Trigger a full synchronization of all pending operations.
  Future<void> triggerSync() async {
    if (state.isSyncing) {
      debugPrint('[SyncNotifier] Sincronizacao ja em andamento.');
      return;
    }

    if (!state.isOnline) {
      debugPrint('[SyncNotifier] Dispositivo offline. Sincronizacao adiada.');
      return;
    }

    state = state.copyWith(isSyncing: true, clearSyncError: true);

    try {
      if (_syncService == null) {
        state = state.copyWith(isSyncing: false);
        return;
      }
      final result = await _syncService.syncAll();

      state = state.copyWith(
        isSyncing: false,
        pendingCount: await _syncService.getPendingCount(),
        lastSync: result.synced > 0 ? DateTime.now() : state.lastSync,
        syncError: result.failed > 0
            ? '${result.synced} sincronizadas, ${result.failed} falharam. '
                'Serao reenviadas.'
            : null,
        clearSyncError: result.failed == 0,
      );
    } catch (error) {
      debugPrint('[SyncNotifier] Erro na sincronizacao: $error');
      state = state.copyWith(
        isSyncing: false,
        syncError: 'Erro na sincronizacao: $error',
      );
    }
  }

  /// Add a pending operation to the sync queue.
  ///
  /// The operation is persisted to SQLite and the pending count is updated.
  Future<void> addPendingOp(PendingOperation op) async {
    if (_syncService == null) return;
    await _syncService.addPendingOp(op);
    await _refreshPendingCount();
  }

  /// Clear all pending operations (used on logout).
  Future<void> clearAll() async {
    if (_syncService == null) return;
    await _syncService.clearAll();
    state = state.copyWith(
      pendingCount: 0,
      clearSyncError: true,
    );
  }

  /// Refresh the pending count from the database.
  Future<void> _refreshPendingCount() async {
    if (_syncService == null) return;
    final count = await _syncService.getPendingCount();
    state = state.copyWith(pendingCount: count);
  }

  @override
  void dispose() {
    _autoSyncTimer?.cancel();
    super.dispose();
  }
}

/// Riverpod provider for the [SyncNotifier].
///
/// Depends on a [SyncService] instance, which should be provided
/// via a separate provider (e.g. from the DI layer).
final syncServiceProvider = Provider<SyncService?>((ref) {
  // Retorna null quando o SyncService nao esta configurado (ex: web).
  // Sera sobrescrito com uma instancia real no ProviderScope quando
  // o banco de dados estiver inicializado (mobile).
  return null;
});

final syncProvider = StateNotifierProvider<SyncNotifier, SyncState>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return SyncNotifier(syncService);
});
