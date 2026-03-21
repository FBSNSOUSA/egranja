import 'package:drift/drift.dart';

import '../app_database.dart';

part 'benchmarks_dao.g.dart';

/// Data access object for the [BenchmarksLinhagem] table.
@DriftAccessor(tables: [BenchmarksLinhagem])
class BenchmarksDao extends DatabaseAccessor<AppDatabase>
    with _$BenchmarksDaoMixin {
  BenchmarksDao(super.db);

  /// Watch all benchmarks as a reactive stream.
  Stream<List<BenchmarksLinhagemData>> watchAll() =>
      select(benchmarksLinhagem).watch();

  /// Get all benchmarks.
  Future<List<BenchmarksLinhagemData>> getAll() =>
      select(benchmarksLinhagem).get();

  /// Get a single benchmark by local [id].
  Future<BenchmarksLinhagemData?> getById(int id) =>
      (select(benchmarksLinhagem)..where((t) => t.id.equals(id)))
          .getSingleOrNull();

  /// Get a single benchmark by [serverId].
  Future<BenchmarksLinhagemData?> getByServerId(String serverId) =>
      (select(benchmarksLinhagem)..where((t) => t.serverId.equals(serverId)))
          .getSingleOrNull();

  /// Get all benchmarks for a given [linhagem] (e.g. 'Cobb 500', 'Ross 308').
  Future<List<BenchmarksLinhagemData>> getByLinhagem(String linhagem) =>
      (select(benchmarksLinhagem)
            ..where((t) => t.linhagem.equals(linhagem))
            ..orderBy([(t) => OrderingTerm.asc(t.dia)]))
          .get();

  /// Watch all benchmarks for a given [linhagem], ordered by day.
  Stream<List<BenchmarksLinhagemData>> watchByLinhagem(String linhagem) =>
      (select(benchmarksLinhagem)
            ..where((t) => t.linhagem.equals(linhagem))
            ..orderBy([(t) => OrderingTerm.asc(t.dia)]))
          .watch();

  /// Get the benchmark for a specific [linhagem] and [dia].
  Future<BenchmarksLinhagemData?> getByLinhagemAndDia(
          String linhagem, int dia) =>
      (select(benchmarksLinhagem)
            ..where(
                (t) => t.linhagem.equals(linhagem) & t.dia.equals(dia)))
          .getSingleOrNull();

  /// Insert a new benchmark row.
  Future<int> insertRow(BenchmarksLinhagemCompanion companion) =>
      into(benchmarksLinhagem).insert(companion);

  /// Update a benchmark by local [id].
  Future<int> updateById(int id, BenchmarksLinhagemCompanion companion) =>
      (update(benchmarksLinhagem)..where((t) => t.id.equals(id)))
          .write(companion);

  /// Delete a benchmark by local [id].
  Future<int> deleteById(int id) =>
      (delete(benchmarksLinhagem)..where((t) => t.id.equals(id))).go();

  /// Replace all benchmarks for a given [linhagem] with new data.
  /// Used when syncing benchmark tables from the server.
  Future<void> replaceByLinhagem(
    String linhagem,
    List<BenchmarksLinhagemCompanion> rows,
  ) async {
    await transaction(() async {
      await (delete(benchmarksLinhagem)
            ..where((t) => t.linhagem.equals(linhagem)))
          .go();
      for (final row in rows) {
        await into(benchmarksLinhagem).insert(row);
      }
    });
  }
}
