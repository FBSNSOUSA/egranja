import 'package:drift/drift.dart';

import '../app_database.dart';

part 'feed_consumptions_dao.g.dart';

/// Data access object for the [FeedConsumptions] table.
@DriftAccessor(tables: [FeedConsumptions])
class FeedConsumptionsDao extends DatabaseAccessor<AppDatabase>
    with _$FeedConsumptionsDaoMixin {
  FeedConsumptionsDao(super.db);

  /// Watch all feed consumptions as a reactive stream.
  Stream<List<FeedConsumption>> watchAll() => select(feedConsumptions).watch();

  /// Get all feed consumptions.
  Future<List<FeedConsumption>> getAll() => select(feedConsumptions).get();

  /// Get a single feed consumption by local [id].
  Future<FeedConsumption?> getById(int id) =>
      (select(feedConsumptions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Get a single feed consumption by [serverId].
  Future<FeedConsumption?> getByServerId(String serverId) =>
      (select(feedConsumptions)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all feed consumptions for a given [loteId].
  Future<List<FeedConsumption>> getByLoteId(String loteId) =>
      (select(feedConsumptions)..where((t) => t.loteId.equals(loteId))).get();

  /// Watch all feed consumptions for a given [loteId].
  Stream<List<FeedConsumption>> watchByLoteId(String loteId) =>
      (select(feedConsumptions)..where((t) => t.loteId.equals(loteId))).watch();

  /// Insert a new feed consumption.
  Future<int> insertRow(FeedConsumptionsCompanion companion) =>
      into(feedConsumptions).insert(companion);

  /// Update a feed consumption by local [id].
  Future<int> updateById(int id, FeedConsumptionsCompanion companion) =>
      (update(feedConsumptions)..where((t) => t.id.equals(id)))
          .write(companion);

  /// Delete a feed consumption by local [id].
  Future<int> deleteById(int id) =>
      (delete(feedConsumptions)..where((t) => t.id.equals(id))).go();
}
