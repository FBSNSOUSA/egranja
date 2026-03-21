import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/database/app_database.dart';
import 'package:egranja_flutter/core/database/daos/sync_queue_dao.dart';
import 'package:egranja_flutter/core/sync/pending_operation.dart';
import 'package:egranja_flutter/core/sync/sync_service.dart';

class MockDio extends Mock implements Dio {}

class MockSyncQueueDao extends Mock implements SyncQueueDao {}

class FakeSyncQueueEntriesCompanion extends Fake
    implements SyncQueueEntriesCompanion {}

class FakeRequestOptions extends Fake implements RequestOptions {}

class FakeOptions extends Fake implements Options {}

void main() {
  late MockDio mockDio;
  late MockSyncQueueDao mockDao;
  late SyncService service;

  setUpAll(() {
    registerFallbackValue(FakeSyncQueueEntriesCompanion());
    registerFallbackValue(FakeOptions());
  });

  setUp(() {
    mockDio = MockDio();
    mockDao = MockSyncQueueDao();
    service = SyncService(dio: mockDio, syncQueueDao: mockDao);
  });

  SyncQueueEntry makeSyncEntry({
    required int id,
    String method = 'POST',
    String url = '/test',
    String? dataJson,
    String status = 'pending',
  }) {
    return SyncQueueEntry(
      id: id,
      method: method,
      url: url,
      dataJson: dataJson,
      createdAt: DateTime(2025, 6, 15),
      status: status,
    );
  }

  group('SyncService', () {
    group('addPendingOp', () {
      test('insere operacao no DAO', () async {
        when(() => mockDao.insertRow(any())).thenAnswer((_) async => 1);

        final op = PendingOperation(
          id: 'op-1',
          method: 'POST',
          url: '/lotes/abc/pesagens',
          data: {'quantidade': 10},
          createdAt: DateTime(2025, 6, 15),
        );

        await service.addPendingOp(op);

        verify(() => mockDao.insertRow(any())).called(1);
      });
    });

    group('syncAll', () {
      test('sem operacoes pendentes: retorna SyncResult(0, 0, [])', () async {
        when(() => mockDao.getPending()).thenAnswer((_) async => []);

        final result = await service.syncAll();

        expect(result.synced, 0);
        expect(result.failed, 0);
        expect(result.errors, isEmpty);
        expect(result.isFullSuccess, true);
      });

      test('prevencao de concorrencia: retorna imediatamente se ja sincronizando',
          () async {
        // Simula que ja esta sincronizando
        service.isSyncing = true;

        final result = await service.syncAll();

        expect(result.synced, 0);
        expect(result.failed, 0);
        expect(result.errors, isEmpty);

        // Nao deve chamar getPending
        verifyNever(() => mockDao.getPending());
      });

      test('batch sucesso: envia POST /sync, marca completado, limpa completados',
          () async {
        final entries = [
          makeSyncEntry(
            id: 1,
            method: 'POST',
            url: '/pesagens',
            dataJson: jsonEncode({'peso': 100}),
          ),
        ];

        when(() => mockDao.getPending()).thenAnswer((_) async => entries);

        when(() => mockDio.post<Map<String, dynamic>>(
              '/sync',
              data: any(named: 'data'),
            )).thenAnswer((_) async => Response(
              data: {
                'synced': 1,
                'failed': 0,
                'results': [
                  {
                    'operationId': '1',
                    'success': true,
                  },
                ],
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/sync'),
            ));

        when(() => mockDao.markCompleted(1)).thenAnswer((_) async => 1);
        when(() => mockDao.clearCompleted()).thenAnswer((_) async => 1);

        final result = await service.syncAll();

        expect(result.synced, 1);
        expect(result.failed, 0);
        expect(result.errors, isEmpty);
        expect(service.isSyncing, false);
        expect(service.lastSync, isNotNull);

        verify(() => mockDao.markCompleted(1)).called(1);
        verify(() => mockDao.clearCompleted()).called(1);
      });

      test('batch falha: fallback para replay individual', () async {
        final entries = [
          makeSyncEntry(
            id: 1,
            method: 'POST',
            url: '/pesagens',
            dataJson: jsonEncode({'peso': 100}),
          ),
        ];

        when(() => mockDao.getPending()).thenAnswer((_) async => entries);

        // Batch falha com excecao
        when(() => mockDio.post<Map<String, dynamic>>(
              '/sync',
              data: any(named: 'data'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/sync'),
          type: DioExceptionType.connectionError,
        ));

        // Individual replay sucesso
        when(() => mockDio.request(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => Response(
              data: {'success': true},
              statusCode: 200,
              requestOptions: RequestOptions(path: '/pesagens'),
            ));

        when(() => mockDao.markCompleted(1)).thenAnswer((_) async => 1);
        when(() => mockDao.clearCompleted()).thenAnswer((_) async => 1);

        final result = await service.syncAll();

        expect(result.synced, 1);
        expect(result.failed, 0);
        expect(service.isSyncing, false);

        // Verificar que usou o fallback individual
        verify(() => mockDio.request(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).called(1);
      });

      test('individual fallback com falha: incrementa failed', () async {
        final entries = [
          makeSyncEntry(
            id: 1,
            method: 'POST',
            url: '/pesagens',
            dataJson: jsonEncode({'peso': 100}),
          ),
        ];

        when(() => mockDao.getPending()).thenAnswer((_) async => entries);

        // Batch falha
        when(() => mockDio.post<Map<String, dynamic>>(
              '/sync',
              data: any(named: 'data'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/sync'),
          type: DioExceptionType.connectionError,
        ));

        // Individual tambem falha
        when(() => mockDio.request(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
          requestOptions: RequestOptions(path: '/pesagens'),
          type: DioExceptionType.connectionError,
        ));

        when(() => mockDao.markFailed(1)).thenAnswer((_) async => 1);
        when(() => mockDao.clearCompleted()).thenAnswer((_) async => 0);

        final result = await service.syncAll();

        expect(result.synced, 0);
        expect(result.failed, 1);
        expect(result.errors.length, 1);
        expect(service.isSyncing, false);

        verify(() => mockDao.markFailed(1)).called(1);
      });
    });

    group('getPendingCount', () {
      test('delega para o DAO', () async {
        when(() => mockDao.getPendingCount()).thenAnswer((_) async => 5);

        final count = await service.getPendingCount();

        expect(count, 5);
        verify(() => mockDao.getPendingCount()).called(1);
      });
    });

    group('clearAll', () {
      test('delega para o DAO', () async {
        when(() => mockDao.clearAll()).thenAnswer((_) async => 3);

        await service.clearAll();

        verify(() => mockDao.clearAll()).called(1);
      });
    });
  });
}
