import 'package:drift/drift.dart';

import '../app_database.dart';

part 'pesagens_dao.g.dart';

/// Data access object for [Pesagens] and [PesagemItems] tables.
@DriftAccessor(tables: [Pesagens, PesagemItems])
class PesagensDao extends DatabaseAccessor<AppDatabase>
    with _$PesagensDaoMixin {
  PesagensDao(super.db);

  // ---------------------------------------------------------------------------
  // Pesagens
  // ---------------------------------------------------------------------------

  /// Watch all pesagens as a reactive stream.
  Stream<List<Pesagen>> watchAll() => select(pesagens).watch();

  /// Get all pesagens.
  Future<List<Pesagen>> getAll() => select(pesagens).get();

  /// Get a single pesagem by local [id].
  Future<Pesagen?> getById(int id) =>
      (select(pesagens)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get a single pesagem by [serverId].
  Future<Pesagen?> getByServerId(String serverId) =>
      (select(pesagens)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all pesagens for a given [loteId].
  Future<List<Pesagen>> getByLoteId(String loteId) =>
      (select(pesagens)..where((t) => t.loteId.equals(loteId))).get();

  /// Watch all pesagens for a given [loteId].
  Stream<List<Pesagen>> watchByLoteId(String loteId) =>
      (select(pesagens)..where((t) => t.loteId.equals(loteId))).watch();

  /// Insert a new pesagem.
  Future<int> insertRow(PesagensCompanion companion) =>
      into(pesagens).insert(companion);

  /// Update a pesagem by local [id].
  Future<int> updateById(int id, PesagensCompanion companion) =>
      (update(pesagens)..where((t) => t.id.equals(id))).write(companion);

  /// Delete a pesagem by local [id].
  Future<int> deleteById(int id) =>
      (delete(pesagens)..where((t) => t.id.equals(id))).go();

  // ---------------------------------------------------------------------------
  // PesagemItems
  // ---------------------------------------------------------------------------

  /// Get all items for a given [pesagemId].
  Future<List<PesagemItem>> getItemsByPesagemId(String pesagemId) =>
      (select(pesagemItems)..where((t) => t.pesagemId.equals(pesagemId))).get();

  /// Watch all items for a given [pesagemId].
  Stream<List<PesagemItem>> watchItemsByPesagemId(String pesagemId) =>
      (select(pesagemItems)..where((t) => t.pesagemId.equals(pesagemId)))
          .watch();

  /// Insert a pesagem item.
  Future<int> insertItem(PesagemItemsCompanion companion) =>
      into(pesagemItems).insert(companion);

  /// Delete a pesagem item by local [id].
  Future<int> deleteItemById(int id) =>
      (delete(pesagemItems)..where((t) => t.id.equals(id))).go();

  /// Delete all items for a given [pesagemId].
  Future<int> deleteItemsByPesagemId(String pesagemId) =>
      (delete(pesagemItems)..where((t) => t.pesagemId.equals(pesagemId))).go();

  // ---------------------------------------------------------------------------
  // Draft helpers
  // ---------------------------------------------------------------------------

  /// Get draft pesagem (serverId is null) for a given [loteId] and [date].
  Future<Pesagen?> getDraft(String loteId, DateTime date) async {
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    return (select(pesagens)
          ..where((t) => t.loteId.equals(loteId))
          ..where((t) => t.serverId.isNull())
          ..where((t) => t.data.isBetweenValues(startOfDay, endOfDay)))
        .getSingleOrNull();
  }

  /// Delete a draft pesagem and all its items in a transaction.
  Future<void> deleteDraftWithItems(int pesagemLocalId) async {
    await transaction(() async {
      final pesagem = await getById(pesagemLocalId);
      if (pesagem != null) {
        await deleteItemsByPesagemId(pesagemLocalId.toString());
      }
      await deleteById(pesagemLocalId);
    });
  }
}
