import 'package:drift/drift.dart';

import '../app_database.dart';

part 'sync_queue_dao.g.dart';

/// Data access object for the [SyncQueueEntries] table.
///
/// Manages the offline sync queue: pending operations are stored locally
/// and replayed to the server when connectivity is restored (FIFO order).
@DriftAccessor(tables: [SyncQueueEntries])
class SyncQueueDao extends DatabaseAccessor<AppDatabase>
    with _$SyncQueueDaoMixin {
  SyncQueueDao(super.db);

  /// Get all sync queue entries.
  Future<List<SyncQueueEntry>> getAll() => select(syncQueueEntries).get();

  /// Watch all sync queue entries as a reactive stream.
  Stream<List<SyncQueueEntry>> watchAll() => select(syncQueueEntries).watch();

  /// Get a single entry by local [id].
  Future<SyncQueueEntry?> getById(int id) =>
      (select(syncQueueEntries)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Get all pending operations ordered by created_at ASC (FIFO).
  Future<List<SyncQueueEntry>> getPending() =>
      (select(syncQueueEntries)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  /// Watch pending operations as a reactive stream.
  Stream<List<SyncQueueEntry>> watchPending() =>
      (select(syncQueueEntries)
            ..where((t) => t.status.equals('pending'))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  /// Get count of pending operations.
  Future<int> getPendingCount() async {
    final query = select(syncQueueEntries)
      ..where((t) => t.status.equals('pending'));
    final results = await query.get();
    return results.length;
  }

  /// Watch count of pending operations as a reactive stream.
  Stream<int> watchPendingCount() =>
      (select(syncQueueEntries)
            ..where((t) => t.status.equals('pending')))
          .watch()
          .map((rows) => rows.length);

  /// Insert a new sync queue entry.
  Future<int> insertRow(SyncQueueEntriesCompanion companion) =>
      into(syncQueueEntries).insert(companion);

  /// Mark an entry as completed.
  Future<int> markCompleted(int id) =>
      (update(syncQueueEntries)..where((t) => t.id.equals(id)))
          .write(const SyncQueueEntriesCompanion(
              status: Value('completed')));

  /// Mark an entry as failed.
  Future<int> markFailed(int id) =>
      (update(syncQueueEntries)..where((t) => t.id.equals(id)))
          .write(const SyncQueueEntriesCompanion(
              status: Value('failed')));

  /// Reset a failed entry back to pending for retry.
  Future<int> resetToPending(int id) =>
      (update(syncQueueEntries)..where((t) => t.id.equals(id)))
          .write(const SyncQueueEntriesCompanion(
              status: Value('pending')));

  /// Clear all completed entries.
  Future<int> clearCompleted() =>
      (delete(syncQueueEntries)..where((t) => t.status.equals('completed')))
          .go();

  /// Clear all entries (used on logout).
  Future<int> clearAll() => delete(syncQueueEntries).go();

  /// Delete a single entry by local [id].
  Future<int> deleteById(int id) =>
      (delete(syncQueueEntries)..where((t) => t.id.equals(id))).go();
}
