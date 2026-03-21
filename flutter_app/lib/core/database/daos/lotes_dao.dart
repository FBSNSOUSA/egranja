import 'package:drift/drift.dart';

import '../app_database.dart';

part 'lotes_dao.g.dart';

/// Data access object for the [Lotes] table.
@DriftAccessor(tables: [Lotes])
class LotesDao extends DatabaseAccessor<AppDatabase> with _$LotesDaoMixin {
  LotesDao(super.db);

  /// Watch all lotes as a reactive stream.
  Stream<List<Lote>> watchAll() => select(lotes).watch();

  /// Get all lotes.
  Future<List<Lote>> getAll() => select(lotes).get();

  /// Get a single lote by local [id].
  Future<Lote?> getById(int id) =>
      (select(lotes)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get a single lote by [serverId].
  Future<Lote?> getByServerId(String serverId) =>
      (select(lotes)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all lotes with a given [status] (e.g. 'ativo', 'finalizado').
  Future<List<Lote>> getByStatus(String status) =>
      (select(lotes)..where((t) => t.status.equals(status))).get();

  /// Watch only active lotes.
  Stream<List<Lote>> watchAtivos() =>
      (select(lotes)..where((t) => t.status.equals('ativo'))).watch();

  /// Insert a new lote and return its local id.
  Future<int> insertRow(LotesCompanion companion) =>
      into(lotes).insert(companion);

  /// Update an existing lote.
  Future<bool> updateRow(LotesCompanion companion) =>
      update(lotes).replace(Lote(
        id: companion.id.value,
        serverId: companion.serverId.value,
        usuarioId: companion.usuarioId.value,
        galpaoId: companion.galpaoId.value,
        galpaoNome: companion.galpaoNome.value,
        dataAlojamento: companion.dataAlojamento.value,
        dataPrevistaAbate: companion.dataPrevistaAbate.value,
        quantidade: companion.quantidade.value,
        tipo: companion.tipo.value,
        linhagem: companion.linhagem.value,
        pesoInicialG: companion.pesoInicialG.value,
        status: companion.status.value,
        dataFinalizacao: companion.dataFinalizacao.value,
        createdAt: companion.createdAt.value,
        updatedAt: companion.updatedAt.value,
      ));

  /// Update a lote row using a companion with only the fields to change.
  Future<int> updateById(int id, LotesCompanion companion) =>
      (update(lotes)..where((t) => t.id.equals(id))).write(companion);

  /// Delete a lote by local [id].
  Future<int> deleteById(int id) =>
      (delete(lotes)..where((t) => t.id.equals(id))).go();
}
