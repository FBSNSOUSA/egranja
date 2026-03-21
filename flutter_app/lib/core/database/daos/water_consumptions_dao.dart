import 'package:drift/drift.dart';

import '../app_database.dart';

part 'water_consumptions_dao.g.dart';

/// Data access object for the [WaterConsumptions] table.
@DriftAccessor(tables: [WaterConsumptions])
class WaterConsumptionsDao extends DatabaseAccessor<AppDatabase>
    with _$WaterConsumptionsDaoMixin {
  WaterConsumptionsDao(super.db);

  /// Watch all water consumptions as a reactive stream.
  Stream<List<WaterConsumption>> watchAll() =>
      select(waterConsumptions).watch();

  /// Get all water consumptions.
  Future<List<WaterConsumption>> getAll() => select(waterConsumptions).get();

  /// Get a single water consumption by local [id].
  Future<WaterConsumption?> getById(int id) =>
      (select(waterConsumptions)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Get a single water consumption by [serverId].
  Future<WaterConsumption?> getByServerId(String serverId) =>
      (select(waterConsumptions)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all water consumptions for a given [loteId].
  Future<List<WaterConsumption>> getByLoteId(String loteId) =>
      (select(waterConsumptions)..where((t) => t.loteId.equals(loteId))).get();

  /// Watch all water consumptions for a given [loteId].
  Stream<List<WaterConsumption>> watchByLoteId(String loteId) =>
      (select(waterConsumptions)..where((t) => t.loteId.equals(loteId)))
          .watch();

  /// Insert a new water consumption.
  Future<int> insertRow(WaterConsumptionsCompanion companion) =>
      into(waterConsumptions).insert(companion);

  /// Update a water consumption by local [id].
  Future<int> updateById(int id, WaterConsumptionsCompanion companion) =>
      (update(waterConsumptions)..where((t) => t.id.equals(id)))
          .write(companion);

  /// Delete a water consumption by local [id].
  Future<int> deleteById(int id) =>
      (delete(waterConsumptions)..where((t) => t.id.equals(id))).go();
}
