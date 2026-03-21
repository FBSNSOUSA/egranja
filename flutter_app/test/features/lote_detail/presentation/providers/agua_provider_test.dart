import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/agua.dart';
import 'package:egranja_flutter/features/lote_detail/presentation/providers/agua_provider.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApi;
  late AguaNotifier notifier;

  const loteId = 'lote-test-agua';

  final fakeConsumo = ConsumoAgua.fromJson({
    'id': 'agua-1',
    'lote_id': loteId,
    'data': '2025-06-15',
    'quantidade_litros': 1500.0,
    'consumo_por_ave': 150.0,
    'relacao_agua_racao': 1.8,
    'created_at': '2025-06-15T18:00:00Z',
  });

  final fakePagination = const PaginationMeta(
    page: 1,
    perPage: 50,
    total: 1,
    totalPages: 1,
  );

  setUp(() {
    mockApi = MockApiClient();
    notifier = AguaNotifier(api: mockApi, loteId: loteId);
  });

  group('AguaNotifier', () {
    group('fetch', () {
      test('sucesso: seta lista de consumos e paginacao', () async {
        when(() => mockApi.apiGet<List<ConsumoAgua>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakeConsumo],
              meta: fakePagination,
            ));

        await notifier.fetch();

        expect(notifier.state.consumos.length, 1);
        expect(notifier.state.consumos[0].id, 'agua-1');
        expect(notifier.state.pagination, fakePagination);
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, isNull);
      });

      test('NetworkException: seta erro "Sem conexao..."', () async {
        when(() => mockApi.apiGet<List<ConsumoAgua>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Sem conexao. Tente novamente.');
      });

      test('erro generico: seta mensagem de erro', () async {
        when(() => mockApi.apiGet<List<ConsumoAgua>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Falha'));

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage,
            'Erro ao carregar consumos de agua.');
      });
    });

    group('loadMore', () {
      test('sucesso: adiciona consumos a lista existente', () async {
        // Primeiro fetch com paginacao que permite mais
        when(() => mockApi.apiGet<List<ConsumoAgua>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakeConsumo],
              meta: const PaginationMeta(
                page: 1,
                perPage: 50,
                total: 100,
                totalPages: 2,
              ),
            ));

        await notifier.fetch();
        expect(notifier.state.consumos.length, 1);

        final fakeConsumo2 = ConsumoAgua.fromJson({
          'id': 'agua-2',
          'lote_id': loteId,
          'data': '2025-06-16',
          'quantidade_litros': 1600.0,
          'consumo_por_ave': null,
          'relacao_agua_racao': null,
          'created_at': '2025-06-16T18:00:00Z',
        });

        when(() => mockApi.apiGet<List<ConsumoAgua>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakeConsumo2],
              meta: const PaginationMeta(
                page: 2,
                perPage: 50,
                total: 100,
                totalPages: 2,
              ),
            ));

        await notifier.loadMore();

        expect(notifier.state.consumos.length, 2);
        expect(notifier.state.consumos[1].id, 'agua-2');
      });

      test('sem mais paginas: nao faz requisicao', () async {
        when(() => mockApi.apiGet<List<ConsumoAgua>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakeConsumo],
              meta: fakePagination, // page 1, totalPages 1
            ));

        await notifier.fetch();
        reset(mockApi);

        await notifier.loadMore();

        verifyNever(() => mockApi.apiGet<List<ConsumoAgua>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            ));
      });
    });

    group('criar', () {
      test('sucesso: retorna true e seta successMessage', () async {
        when(() => mockApi.apiPost<ConsumoAgua>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer(
                (_) async => SuccessResponse(data: fakeConsumo));

        when(() => mockApi.apiGet<List<ConsumoAgua>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakeConsumo],
              meta: fakePagination,
            ));

        final result = await notifier.criar(
          data: '2025-06-15',
          quantidadeLitros: 1500.0,
        );

        expect(result, true);
        expect(notifier.state.isSaving, false);
      });

      test('NetworkException: retorna true (offline)', () async {
        when(() => mockApi.apiPost<ConsumoAgua>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        final result = await notifier.criar(
          data: '2025-06-15',
          quantidadeLitros: 1500.0,
        );

        expect(result, true);
        expect(notifier.state.successMessage,
            'Salvo localmente. Sera sincronizado quando online.');
      });

      test('erro generico: retorna false e seta errorMessage', () async {
        when(() => mockApi.apiPost<ConsumoAgua>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Erro'));

        final result = await notifier.criar(
          data: '2025-06-15',
          quantidadeLitros: 1500.0,
        );

        expect(result, false);
        expect(notifier.state.errorMessage,
            'Erro ao salvar consumo de agua. Tente novamente.');
      });
    });

    group('clearMessages', () {
      test('limpa error e success message', () {
        notifier.clearMessages();

        expect(notifier.state.errorMessage, isNull);
        expect(notifier.state.successMessage, isNull);
      });
    });
  });
}
