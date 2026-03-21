import 'package:drift/drift.dart';

import '../app_database.dart';

part 'feed_receipts_dao.g.dart';

/// Data access object for the [FeedReceipts] table.
@DriftAccessor(tables: [FeedReceipts])
class FeedReceiptsDao extends DatabaseAccessor<AppDatabase>
    with _$FeedReceiptsDaoMixin {
  FeedReceiptsDao(super.db);

  /// Watch all feed receipts as a reactive stream.
  Stream<List<FeedReceipt>> watchAll() => select(feedReceipts).watch();

  /// Get all feed receipts.
  Future<List<FeedReceipt>> getAll() => select(feedReceipts).get();

  /// Get a single feed receipt by local [id].
  Future<FeedReceipt?> getById(int id) =>
      (select(feedReceipts)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get a single feed receipt by [serverId].
  Future<FeedReceipt?> getByServerId(String serverId) =>
      (select(feedReceipts)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all feed receipts for a given [loteId].
  Future<List<FeedReceipt>> getByLoteId(String loteId) =>
      (select(feedReceipts)..where((t) => t.loteId.equals(loteId))).get();

  /// Watch all feed receipts for a given [loteId].
  Stream<List<FeedReceipt>> watchByLoteId(String loteId) =>
      (select(feedReceipts)..where((t) => t.loteId.equals(loteId))).watch();

  /// Insert a new feed receipt.
  Future<int> insertRow(FeedReceiptsCompanion companion) =>
      into(feedReceipts).insert(companion);

  /// Update a feed receipt by local [id].
  Future<int> updateById(int id, FeedReceiptsCompanion companion) =>
      (update(feedReceipts)..where((t) => t.id.equals(id))).write(companion);

  /// Delete a feed receipt by local [id].
  Future<int> deleteById(int id) =>
      (delete(feedReceipts)..where((t) => t.id.equals(id))).go();
}
