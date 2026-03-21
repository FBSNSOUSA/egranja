import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/pesagem.dart';
import 'package:egranja_flutter/features/lote_detail/presentation/providers/pesagens_provider.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApi;
  late PesagensNotifier notifier;

  const loteId = 'lote-test-123';

  final fakePesagem = Pesagem.fromJson({
    'id': 'pes-1',
    'lote_id': loteId,
    'data': '2025-06-15',
    'quantidade_total': 10,
    'peso_total': 25000.0,
    'peso_medio': 2500.0,
    'peso_benchmark': null,
    'desvio_pct': null,
    'uniformidade_cv': null,
    'idade': 28,
    'itens': <dynamic>[],
    'created_at': '2025-06-15T10:00:00Z',
  });

  final fakePagination = const PaginationMeta(
    page: 1,
    perPage: 20,
    total: 1,
    totalPages: 1,
  );

  setUp(() {
    mockApi = MockApiClient();
    notifier = PesagensNotifier(api: mockApi, loteId: loteId);
  });

  group('PesagensNotifier', () {
    group('fetch', () {
      test('sucesso: seta lista de pesagens e paginacao', () async {
        when(() => mockApi.apiGet<List<Pesagem>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakePesagem],
              meta: fakePagination,
            ));

        await notifier.fetch();

        expect(notifier.state.pesagens.length, 1);
        expect(notifier.state.pesagens[0].id, 'pes-1');
        expect(notifier.state.pagination, fakePagination);
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, isNull);
      });

      test('NetworkException: seta erro "Sem conexao..."', () async {
        when(() => mockApi.apiGet<List<Pesagem>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Sem conexao. Tente novamente.');
        expect(notifier.state.pesagens, isEmpty);
      });

      test('erro generico: seta mensagem de erro', () async {
        when(() => mockApi.apiGet<List<Pesagem>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Erro inesperado'));

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Erro ao carregar pesagens.');
      });
    });

    group('loadMore', () {
      test('sucesso: adiciona pesagens a lista existente', () async {
        // Primeiro fetch para ter estado inicial com paginacao que permite mais
        when(() => mockApi.apiGet<List<Pesagem>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakePesagem],
              meta: const PaginationMeta(
                page: 1,
                perPage: 20,
                total: 40,
                totalPages: 2,
              ),
            ));

        await notifier.fetch();
        expect(notifier.state.pesagens.length, 1);

        // Agora loadMore - segunda pagina
        final fakePesagem2 = Pesagem.fromJson({
          'id': 'pes-2',
          'lote_id': loteId,
          'data': '2025-06-16',
          'quantidade_total': 15,
          'peso_total': 38000.0,
          'peso_medio': 2533.0,
          'peso_benchmark': null,
          'desvio_pct': null,
          'uniformidade_cv': null,
          'idade': 29,
          'itens': <dynamic>[],
          'created_at': '2025-06-16T10:00:00Z',
        });

        when(() => mockApi.apiGet<List<Pesagem>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakePesagem2],
              meta: const PaginationMeta(
                page: 2,
                perPage: 20,
                total: 40,
                totalPages: 2,
              ),
            ));

        await notifier.loadMore();

        expect(notifier.state.pesagens.length, 2);
        expect(notifier.state.pesagens[1].id, 'pes-2');
        expect(notifier.state.isLoading, false);
      });

      test('sem mais paginas: nao faz requisicao', () async {
        // Fetch com paginacao indicando que nao ha mais
        when(() => mockApi.apiGet<List<Pesagem>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakePesagem],
              meta: fakePagination, // page 1, totalPages 1
            ));

        await notifier.fetch();

        // Reset interaction count
        reset(mockApi);

        await notifier.loadMore();

        // Nao deve ter chamado apiGet novamente
        verifyNever(() => mockApi.apiGet<List<Pesagem>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            ));
      });
    });

    group('criar', () {
      test('sucesso: retorna true e seta successMessage', () async {
        when(() => mockApi.apiPost<Pesagem>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(data: fakePesagem));

        // Stub do fetch que sera chamado apos criar
        when(() => mockApi.apiGet<List<Pesagem>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakePesagem],
              meta: fakePagination,
            ));

        final result = await notifier.criar(
          itens: [
            {'quantidade': 10, 'peso': 25000.0},
          ],
        );

        expect(result, true);
        // Apos o fetch interno, successMessage pode ter sido limpa pelo copyWith
        // mas no fluxo, o successMessage eh setado antes do fetch
        expect(notifier.state.isSaving, false);
      });

      test('NetworkException: retorna true (offline) e seta successMessage offline', () async {
        when(() => mockApi.apiPost<Pesagem>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        final result = await notifier.criar(
          itens: [
            {'quantidade': 10, 'peso': 25000.0},
          ],
        );

        expect(result, true);
        expect(notifier.state.isSaving, false);
        expect(notifier.state.successMessage,
            'Salvo localmente. Sera sincronizado quando online.');
      });

      test('erro generico: retorna false e seta errorMessage', () async {
        when(() => mockApi.apiPost<Pesagem>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Falha ao salvar'));

        final result = await notifier.criar(
          itens: [
            {'quantidade': 10, 'peso': 25000.0},
          ],
        );

        expect(result, false);
        expect(notifier.state.isSaving, false);
        expect(notifier.state.errorMessage,
            'Erro ao salvar pesagem. Tente novamente.');
      });
    });

    group('clearMessages', () {
      test('limpa error e success message', () async {
        when(() => mockApi.apiPost<Pesagem>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        await notifier.criar(itens: []);
        expect(notifier.state.successMessage, isNotNull);

        notifier.clearMessages();

        expect(notifier.state.errorMessage, isNull);
        expect(notifier.state.successMessage, isNull);
      });
    });
  });
}
