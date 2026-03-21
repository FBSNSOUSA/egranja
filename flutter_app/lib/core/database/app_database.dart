/// Drift database definition for eGranja.
///
/// Defines all 12 local tables that mirror the backend PostgreSQL schema,
/// plus a sync_queue table for offline operation queue.
///
/// Tables use integer auto-increment primary keys locally and nullable
/// server_id (text) for mapping to backend UUIDs after synchronization.
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'daos/benchmarks_dao.dart';
import 'daos/checklists_dao.dart';
import 'daos/feed_consumptions_dao.dart';
import 'daos/feed_receipts_dao.dart';
import 'daos/galpaos_dao.dart';
import 'daos/lotes_dao.dart';
import 'daos/mensagens_dao.dart';
import 'daos/mortalidades_dao.dart';
import 'daos/pesagens_dao.dart';
import 'daos/sync_queue_dao.dart';
import 'daos/water_consumptions_dao.dart';

part 'app_database.g.dart';

// ============================================================================
// TABLE DEFINITIONS
// ============================================================================

/// Lotes de aves — tabela principal.
class Lotes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get usuarioId => text()();
  TextColumn get galpaoId => text()();
  TextColumn get galpaoNome => text().nullable()();
  DateTimeColumn get dataAlojamento => dateTime()();
  DateTimeColumn get dataPrevistaAbate => dateTime()();
  IntColumn get quantidade => integer()();
  TextColumn get tipo => text()();
  TextColumn get linhagem => text().nullable()();
  RealColumn get pesoInicialG => real()();
  TextColumn get status => text().withDefault(const Constant('ativo'))();
  DateTimeColumn get dataFinalizacao => dateTime().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Pesagens semanais do lote.
class Pesagens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get loteId => text()();
  DateTimeColumn get data => dateTime()();
  IntColumn get quantidadeTotal => integer()();
  RealColumn get pesoTotal => real()();
  RealColumn get pesoMedio => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  List<Set<Column>> get uniqueKeys => [];

  @override
  List<String> get customConstraints => [];
}

/// Itens (amostras) de uma pesagem.
class PesagemItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get pesagemId => text()();
  IntColumn get quantidade => integer()();
  RealColumn get peso => real()();
  RealColumn get pesoMedio => real()();
  DateTimeColumn get createdAt => dateTime()();
}

/// Registro diario de mortalidade.
class Mortalidades extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get loteId => text()();
  DateTimeColumn get data => dateTime()();
  IntColumn get quantidade => integer()();
  TextColumn get causa => text()();
  TextColumn get observacao => text().nullable()();
  TextColumn get fotoUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Recebimentos de racao (entradas de estoque).
class FeedReceipts extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get loteId => text()();
  TextColumn get tipoRacaoId => text().nullable()();
  TextColumn get tipoRacaoNome => text().nullable()();
  RealColumn get quantidadeKg => real()();
  DateTimeColumn get dataRecebimento => dateTime()();
  TextColumn get fornecedor => text().nullable()();
  TextColumn get loteRacao => text().nullable()();
  TextColumn get origem => text().withDefault(const Constant('compra'))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Consumo diario de racao.
class FeedConsumptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get loteId => text()();
  DateTimeColumn get data => dateTime()();
  RealColumn get quantidadeKg => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Consumo diario de agua (litros).
class WaterConsumptions extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get loteId => text()();
  DateTimeColumn get data => dateTime()();
  RealColumn get quantidadeLitros => real()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Checklist diario de manejo.
class Checklists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get loteId => text()();
  DateTimeColumn get data => dateTime()();
  TextColumn get itensJson => text()();
  BoolColumn get completado => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Mensagens do chat produtor-tecnico.
class Mensagens extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get loteId => text()();
  TextColumn get remetenteId => text()();
  TextColumn get remetenteNome => text().nullable()();
  TextColumn get tipo => text()();
  TextColumn get conteudo => text().nullable()();
  TextColumn get midiaUrl => text().nullable()();
  TextColumn get midiaThumbnailUrl => text().nullable()();
  BoolColumn get lida => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

/// Galpoes do usuario.
class Galpaos extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get usuarioId => text()();
  TextColumn get nome => text()();
  IntColumn get capacidade => integer()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  RealColumn get orientacaoGraus => real().nullable()();
  RealColumn get comprimentoM => real().nullable()();
  RealColumn get larguraM => real().nullable()();
  TextColumn get tipoVentilacao => text().nullable()();
  TextColumn get ladoCortinas => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();
}

/// Benchmarks de linhagem (Cobb 500, Ross 308, etc.).
class BenchmarksLinhagem extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get serverId => text().nullable()();
  TextColumn get linhagem => text()();
  IntColumn get dia => integer()();
  RealColumn get pesoG => real()();
  RealColumn get consumoAcumG => real().nullable()();
  RealColumn get ca => real().nullable()();
  RealColumn get gpdG => real().nullable()();
}

/// Fila de operacoes pendentes para sincronizacao offline.
class SyncQueueEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get method => text()();
  TextColumn get url => text()();
  TextColumn get dataJson => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get status => text().withDefault(const Constant('pending'))();
}

// ============================================================================
// DATABASE
// ============================================================================

@DriftDatabase(
  tables: [
    Lotes,
    Pesagens,
    PesagemItems,
    Mortalidades,
    FeedReceipts,
    FeedConsumptions,
    WaterConsumptions,
    Checklists,
    Mensagens,
    Galpaos,
    BenchmarksLinhagem,
    SyncQueueEntries,
  ],
  daos: [
    LotesDao,
    PesagensDao,
    MortalidadesDao,
    FeedReceiptsDao,
    FeedConsumptionsDao,
    WaterConsumptionsDao,
    ChecklistsDao,
    MensagensDao,
    GalpaosDao,
    BenchmarksDao,
    SyncQueueDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with a custom query executor.
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // Future migrations go here.
        },
      );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'egranja.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
