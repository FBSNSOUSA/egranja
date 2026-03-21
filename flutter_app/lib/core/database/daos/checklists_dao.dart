import 'package:drift/drift.dart';

import '../app_database.dart';

part 'checklists_dao.g.dart';

/// Data access object for the [Checklists] table.
@DriftAccessor(tables: [Checklists])
class ChecklistsDao extends DatabaseAccessor<AppDatabase>
    with _$ChecklistsDaoMixin {
  ChecklistsDao(super.db);

  /// Watch all checklists as a reactive stream.
  Stream<List<Checklist>> watchAll() => select(checklists).watch();

  /// Get all checklists.
  Future<List<Checklist>> getAll() => select(checklists).get();

  /// Get a single checklist by local [id].
  Future<Checklist?> getById(int id) =>
      (select(checklists)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get a single checklist by [serverId].
  Future<Checklist?> getByServerId(String serverId) =>
      (select(checklists)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all checklists for a given [loteId].
  Future<List<Checklist>> getByLoteId(String loteId) =>
      (select(checklists)..where((t) => t.loteId.equals(loteId))).get();

  /// Watch all checklists for a given [loteId].
  Stream<List<Checklist>> watchByLoteId(String loteId) =>
      (select(checklists)..where((t) => t.loteId.equals(loteId))).watch();

  /// Insert a new checklist.
  Future<int> insertRow(ChecklistsCompanion companion) =>
      into(checklists).insert(companion);

  /// Update a checklist by local [id].
  Future<int> updateById(int id, ChecklistsCompanion companion) =>
      (update(checklists)..where((t) => t.id.equals(id))).write(companion);

  /// Delete a checklist by local [id].
  Future<int> deleteById(int id) =>
      (delete(checklists)..where((t) => t.id.equals(id))).go();
}
