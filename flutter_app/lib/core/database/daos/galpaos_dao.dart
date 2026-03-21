import 'package:drift/drift.dart';

import '../app_database.dart';

part 'galpaos_dao.g.dart';

/// Data access object for the [Galpaos] table.
@DriftAccessor(tables: [Galpaos])
class GalpaosDao extends DatabaseAccessor<AppDatabase> with _$GalpaosDaoMixin {
  GalpaosDao(super.db);

  /// Watch all galpaos as a reactive stream.
  Stream<List<Galpao>> watchAll() => select(galpaos).watch();

  /// Get all galpaos.
  Future<List<Galpao>> getAll() => select(galpaos).get();

  /// Get a single galpao by local [id].
  Future<Galpao?> getById(int id) =>
      (select(galpaos)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get a single galpao by [serverId].
  Future<Galpao?> getByServerId(String serverId) =>
      (select(galpaos)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all galpaos for a given [usuarioId].
  Future<List<Galpao>> getByUsuarioId(String usuarioId) =>
      (select(galpaos)..where((t) => t.usuarioId.equals(usuarioId))).get();

  /// Watch all galpaos for a given [usuarioId].
  Stream<List<Galpao>> watchByUsuarioId(String usuarioId) =>
      (select(galpaos)..where((t) => t.usuarioId.equals(usuarioId))).watch();

  /// Insert a new galpao.
  Future<int> insertRow(GalpaosCompanion companion) =>
      into(galpaos).insert(companion);

  /// Update a galpao by local [id].
  Future<int> updateById(int id, GalpaosCompanion companion) =>
      (update(galpaos)..where((t) => t.id.equals(id))).write(companion);

  /// Delete a galpao by local [id].
  Future<int> deleteById(int id) =>
      (delete(galpaos)..where((t) => t.id.equals(id))).go();
}
