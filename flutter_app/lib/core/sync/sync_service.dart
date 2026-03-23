import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../database/app_database.dart';
import '../database/daos/sync_queue_dao.dart';
import 'pending_operation.dart';

/// Result of a full sync cycle.
class SyncResult {
  /// Number of operations successfully synced.
  final int synced;

  /// Number of operations that failed.
  final int failed;

  /// Error messages for operations that failed.
  final List<String> errors;

  const SyncResult({
    required this.synced,
    required this.failed,
    required this.errors,
  });

  /// Whether all operations succeeded.
  bool get isFullSuccess => failed == 0;

  @override
  String toString() =>
      'SyncResult(synced: $synced, failed: $failed, errors: $errors)';
}

/// Service responsible for synchronizing offline-queued operations
/// with the backend server.
///
/// Operations flow:
/// 1. When offline, mutations are saved to [SyncQueueEntries] via [addPendingOp]
/// 2. When connectivity is restored, [syncAll] is called
/// 3. First attempts batch sync via POST /sync endpoint
/// 4. If batch fails, falls back to individual request replay
/// 5. Completed operations are marked/removed from the queue
class SyncService {
  final Dio _dio;
  final SyncQueueDao _syncQueueDao;

  /// Whether a sync is currently in progress.
  bool isSyncing = false;

  /// Timestamp of the last successful sync.
  DateTime? lastSync;

  SyncService({
    required Dio dio,
    required SyncQueueDao syncQueueDao,
  })  : _dio = dio,
        _syncQueueDao = syncQueueDao;

  /// Add a pending operation to the sync queue (persisted in SQLite).
  Future<void> addPendingOp(PendingOperation op) async {
    await _syncQueueDao.insertRow(
      SyncQueueEntriesCompanion.insert(
        method: op.method,
        url: op.url,
        dataJson: Value(op.data != null ? jsonEncode(op.data) : null),
        createdAt: op.createdAt,
      ),
    );

    debugPrint(
      '[SyncService] Operacao adicionada a fila: ${op.method} ${op.url}',
    );
  }

  /// Sync all pending operations with the server.
  ///
  /// Strategy:
  /// 1. Get all pending ops from DB ordered by created_at (FIFO)
  /// 2. Try batch: POST /sync with all operations
  /// 3. If batch fails, try individual: replay each request one by one
  /// 4. Mark completed/failed in DB
  /// 5. Update lastSync timestamp
  Future<SyncResult> syncAll() async {
    // Avoid concurrent syncs
    if (isSyncing) {
      debugPrint('[SyncService] Sincronizacao ja em andamento.');
      return const SyncResult(synced: 0, failed: 0, errors: []);
    }

    final pendingOps = await _syncQueueDao.getPending();

    if (pendingOps.isEmpty) {
      debugPrint('[SyncService] Nenhuma operacao pendente para sincronizar.');
      return const SyncResult(synced: 0, failed: 0, errors: []);
    }

    isSyncing = true;

    debugPrint(
      '[SyncService] Iniciando sincronizacao de ${pendingOps.length} operacoes...',
    );

    try {
      // Try batch sync first
      return await _syncBatch(pendingOps);
    } catch (batchError) {
      debugPrint(
        '[SyncService] Erro na sincronizacao em lote: $batchError. '
        'Tentando individualmente...',
      );

      // Fallback: sync individually
      return await _syncIndividually(pendingOps);
    } finally {
      isSyncing = false;
    }
  }

  /// Attempt batch synchronization via POST /sync endpoint.
  Future<SyncResult> _syncBatch(List<SyncQueueEntry> pendingOps) async {
    // Prepare payload for batch sync
    final syncPayload = pendingOps.map((op) {
      return {
        'id': op.id.toString(),
        'method': op.method,
        'url': op.url,
        'data': op.dataJson != null ? jsonDecode(op.dataJson!) : null,
        'created_at': op.createdAt.toIso8601String(),
      };
    }).toList();

    // Send batch to the server
    final response = await _dio.post<Map<String, dynamic>>(
      '/sync',
      data: {'operations': syncPayload},
    );

    final responseData = response.data!;
    final results = responseData['results'] as List<dynamic>;
    final synced = (responseData['synced'] as num).toInt();
    final failed = (responseData['failed'] as num).toInt();

    // Process results: mark completed or keep as pending
    final errors = <String>[];

    for (final result in results) {
      final resultMap = result as Map<String, dynamic>;
      final operationId = int.tryParse(resultMap['operationId'].toString());
      final success = resultMap['success'] as bool;

      if (operationId == null) continue;

      if (success) {
        await _syncQueueDao.markCompleted(operationId);
      } else {
        final error = resultMap['error'] as String? ?? 'Erro desconhecido';
        errors.add(error);
        await _syncQueueDao.markFailed(operationId);
      }
    }

    // Clean up completed entries
    await _syncQueueDao.clearCompleted();

    if (synced > 0) {
      lastSync = DateTime.now();
    }

    debugPrint(
      '[SyncService] Sync em lote concluido: $synced sucesso, $failed falhas.',
    );

    return SyncResult(synced: synced, failed: failed, errors: errors);
  }

  /// Fallback: replay each pending operation individually.
  Future<SyncResult> _syncIndividually(List<SyncQueueEntry> pendingOps) async {
    int synced = 0;
    int failed = 0;
    final errors = <String>[];

    for (final op in pendingOps) {
      try {
        final data = op.dataJson != null ? jsonDecode(op.dataJson!) : null;

        await _dio.request(
          op.url,
          data: data,
          options: Options(method: op.method.toLowerCase()),
        );

        // Success: mark completed and remove
        await _syncQueueDao.markCompleted(op.id);
        synced++;
      } catch (error) {
        debugPrint(
          '[SyncService] Falha ao sincronizar operacao ${op.id}: $error',
        );
        await _syncQueueDao.markFailed(op.id);
        errors.add('Operacao ${op.id}: $error');
        failed++;
        // Keep in queue for next retry
      }
    }

    // Clean up completed entries
    await _syncQueueDao.clearCompleted();

    if (synced > 0) {
      lastSync = DateTime.now();
    }

    debugPrint(
      '[SyncService] Sync individual concluido: $synced sucesso, $failed falhas.',
    );

    return SyncResult(synced: synced, failed: failed, errors: errors);
  }

  /// Get count of pending operations.
  Future<int> getPendingCount() => _syncQueueDao.getPendingCount();

  /// Watch pending count as a reactive stream.
  Stream<int> watchPendingCount() => _syncQueueDao.watchPendingCount();

  /// Clear all pending operations (used on logout).
  Future<void> clearAll() async {
    await _syncQueueDao.clearAll();
    debugPrint('[SyncService] Todas as operacoes pendentes foram removidas.');
  }
}
