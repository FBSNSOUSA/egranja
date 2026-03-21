import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/racao.dart';
import 'package:egranja_flutter/features/lote_detail/presentation/providers/racao_provider.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApi;
  late RacaoNotifier notifier;

  const loteId = 'lote-test-789';

  final fakeRecebimento = RecebimentoRacao.fromJson({
    'id': 'rec-1',
    'lote_id': loteId,
    'data_recebimento': '2025-06-10',
    'quantidade_kg': 5000.0,
    'tipo_racao_id': null,
    'tipo_racao_nome': 'Inicial',
    'fornecedor': 'Cargill',
    'lote_racao': null,
    'origem': 'compra',
    'created_at': '2025-06-10T09:00:00Z',
  });

  final fakeConsumo = ConsumoRacao.fromJson({
    'id': 'cons-1',
    'lote_id': loteId,
    'data': '2025-06-15',
    'quantidade_kg': 250.5,
    'created_at': '2025-06-15T18:00:00Z',
  });

  final fakePaginationRec = const PaginationMeta(
    page: 1,
    perPage: 50,
    total: 1,
    totalPages: 1,
  );

  final fakePaginationCons = const PaginationMeta(
    page: 1,
    perPage: 50,
    total: 1,
    totalPages: 1,
  );

  setUp(() {
    mockApi = MockApiClient();
    notifier = RacaoNotifier(api: mockApi, loteId: loteId);
  });

  void stubFetchSuccess() {
    when(() => mockApi.apiGet<List<RecebimentoRacao>>(
          any(),
          queryParams: any(named: 'queryParams'),
          fromJson: any(named: 'fromJson'),
        )).thenAnswer((_) async => SuccessResponse(
          data: [fakeRecebimento],
          meta: fakePaginationRec,
        ));

    when(() => mockApi.apiGet<List<ConsumoRacao>>(
          any(),
          queryParams: any(named: 'queryParams'),
          fromJson: any(named: 'fromJson'),
        )).thenAnswer((_) async => SuccessResponse(
          data: [fakeConsumo],
          meta: fakePaginationCons,
        ));
  }

  group('RacaoNotifier', () {
    group('fetch', () {
      test('sucesso: carrega recebimentos e consumos', () async {
        stubFetchSuccess();

        await notifier.fetch();

        expect(notifier.state.recebimentos.length, 1);
        expect(notifier.state.recebimentos[0].id, 'rec-1');
        expect(notifier.state.consumos.length, 1);
        expect(notifier.state.consumos[0].id, 'cons-1');
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, isNull);
      });

      test('NetworkException: seta erro "Sem conexao..."', () async {
        when(() => mockApi.apiGet<List<RecebimentoRacao>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Sem conexao. Tente novamente.');
      });

      test('erro generico: seta mensagem de erro', () async {
        when(() => mockApi.apiGet<List<RecebimentoRacao>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Falha'));

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(
            notifier.state.errorMessage, 'Erro ao carregar dados de racao.');
      });
    });

    group('criarRecebimento', () {
      test('sucesso: retorna true e seta successMessage', () async {
        when(() => mockApi.apiPost<RecebimentoRacao>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer(
                (_) async => SuccessResponse(data: fakeRecebimento));

        // Stub do fetch subsequente
        stubFetchSuccess();

        final result = await notifier.criarRecebimento(
          dataRecebimento: '2025-06-10',
          quantidadeKg: 5000.0,
          tipoRacao: 'Inicial',
          origem: 'compra',
        );

        expect(result, true);
        expect(notifier.state.isSaving, false);
      });

      test('NetworkException: retorna true (offline)', () async {
        when(() => mockApi.apiPost<RecebimentoRacao>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        final result = await notifier.criarRecebimento(
          dataRecebimento: '2025-06-10',
          quantidadeKg: 5000.0,
          tipoRacao: 'Inicial',
          origem: 'compra',
        );

        expect(result, true);
        expect(notifier.state.successMessage,
            'Salvo localmente. Sera sincronizado quando online.');
      });

      test('erro generico: retorna false e seta errorMessage', () async {
        when(() => mockApi.apiPost<RecebimentoRacao>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Erro'));

        final result = await notifier.criarRecebimento(
          dataRecebimento: '2025-06-10',
          quantidadeKg: 5000.0,
          tipoRacao: 'Inicial',
          origem: 'compra',
        );

        expect(result, false);
        expect(notifier.state.errorMessage,
            'Erro ao salvar recebimento. Tente novamente.');
      });
    });

    group('criarConsumo', () {
      test('sucesso: retorna true e seta successMessage', () async {
        when(() => mockApi.apiPost<ConsumoRacao>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer(
                (_) async => SuccessResponse(data: fakeConsumo));

        // Stub do fetch subsequente
        stubFetchSuccess();

        final result = await notifier.criarConsumo(
          data: '2025-06-15',
          quantidadeKg: 250.5,
        );

        expect(result, true);
        expect(notifier.state.isSaving, false);
      });

      test('NetworkException: retorna true (offline)', () async {
        when(() => mockApi.apiPost<ConsumoRacao>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        final result = await notifier.criarConsumo(
          data: '2025-06-15',
          quantidadeKg: 250.5,
        );

        expect(result, true);
        expect(notifier.state.successMessage,
            'Salvo localmente. Sera sincronizado quando online.');
      });

      test('erro generico: retorna false e seta errorMessage', () async {
        when(() => mockApi.apiPost<ConsumoRacao>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Erro'));

        final result = await notifier.criarConsumo(
          data: '2025-06-15',
          quantidadeKg: 250.5,
        );

        expect(result, false);
        expect(notifier.state.errorMessage,
            'Erro ao salvar consumo. Tente novamente.');
      });
    });

    group('clearMessages', () {
      test('limpa error e success message', () {
        // Simula estado com mensagem de erro
        notifier.clearMessages();

        expect(notifier.state.errorMessage, isNull);
        expect(notifier.state.successMessage, isNull);
      });
    });
  });
}
