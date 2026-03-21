import 'package:drift/drift.dart';

import '../app_database.dart';

part 'mensagens_dao.g.dart';

/// Data access object for the [Mensagens] table.
@DriftAccessor(tables: [Mensagens])
class MensagensDao extends DatabaseAccessor<AppDatabase>
    with _$MensagensDaoMixin {
  MensagensDao(super.db);

  /// Watch all mensagens as a reactive stream.
  Stream<List<Mensagen>> watchAll() => select(mensagens).watch();

  /// Get all mensagens.
  Future<List<Mensagen>> getAll() => select(mensagens).get();

  /// Get a single mensagem by local [id].
  Future<Mensagen?> getById(int id) =>
      (select(mensagens)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Get a single mensagem by [serverId].
  Future<Mensagen?> getByServerId(String serverId) =>
      (select(mensagens)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all mensagens for a given [loteId].
  Future<List<Mensagen>> getByLoteId(String loteId) =>
      (select(mensagens)
            ..where((t) => t.loteId.equals(loteId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .get();

  /// Watch all mensagens for a given [loteId], ordered by creation time.
  Stream<List<Mensagen>> watchByLoteId(String loteId) =>
      (select(mensagens)
            ..where((t) => t.loteId.equals(loteId))
            ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
          .watch();

  /// Get unread messages count for a given [loteId].
  Future<int> getUnreadCount(String loteId) async {
    final query = select(mensagens)
      ..where(
          (t) => t.loteId.equals(loteId) & t.lida.equals(false));
    final results = await query.get();
    return results.length;
  }

  /// Mark a mensagem as read.
  Future<int> markAsRead(int id) =>
      (update(mensagens)..where((t) => t.id.equals(id)))
          .write(const MensagensCompanion(lida: Value(true)));

  /// Insert a new mensagem.
  Future<int> insertRow(MensagensCompanion companion) =>
      into(mensagens).insert(companion);

  /// Delete a mensagem by local [id].
  Future<int> deleteById(int id) =>
      (delete(mensagens)..where((t) => t.id.equals(id))).go();
}
