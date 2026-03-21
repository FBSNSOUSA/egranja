import 'package:drift/drift.dart';

import '../app_database.dart';

part 'mortalidades_dao.g.dart';

/// Data access object for the [Mortalidades] table.
@DriftAccessor(tables: [Mortalidades])
class MortalidadesDao extends DatabaseAccessor<AppDatabase>
    with _$MortalidadesDaoMixin {
  MortalidadesDao(super.db);

  /// Watch all mortalidades as a reactive stream.
  Stream<List<Mortalidade>> watchAll() => select(mortalidades).watch();

  /// Get all mortalidades.
  Future<List<Mortalidade>> getAll() => select(mortalidades).get();

  /// Get a single mortalidade by local [id].
  Future<Mortalidade?> getById(int id) =>
      (select(mortalidades)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get a single mortalidade by [serverId].
  Future<Mortalidade?> getByServerId(String serverId) =>
      (select(mortalidades)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all mortalidades for a given [loteId].
  Future<List<Mortalidade>> getByLoteId(String loteId) =>
      (select(mortalidades)..where((t) => t.loteId.equals(loteId))).get();

  /// Watch all mortalidades for a given [loteId].
  Stream<List<Mortalidade>> watchByLoteId(String loteId) =>
      (select(mortalidades)..where((t) => t.loteId.equals(loteId))).watch();

  /// Insert a new mortalidade.
  Future<int> insertRow(MortalidadesCompanion companion) =>
      into(mortalidades).insert(companion);

  /// Update a mortalidade by local [id].
  Future<int> updateById(int id, MortalidadesCompanion companion) =>
      (update(mortalidades)..where((t) => t.id.equals(id))).write(companion);

  /// Delete a mortalidade by local [id].
  Future<int> deleteById(int id) =>
      (delete(mortalidades)..where((t) => t.id.equals(id))).go();
}
