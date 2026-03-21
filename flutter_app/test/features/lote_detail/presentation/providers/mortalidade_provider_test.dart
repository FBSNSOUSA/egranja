import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/mortalidade.dart';
import 'package:egranja_flutter/features/lote_detail/presentation/providers/mortalidade_provider.dart';

class MockApiClient extends Mock implements ApiClient {}

void main() {
  late MockApiClient mockApi;
  late MortalidadeNotifier notifier;

  const loteId = 'lote-test-456';

  final fakeMortalidade = Mortalidade.fromJson({
    'id': 'mort-1',
    'lote_id': loteId,
    'data': '2025-06-15',
    'quantidade': 3,
    'causa': 'morte_subita',
    'observacao': null,
    'foto_url': null,
    'percentual_dia': 0.03,
    'created_at': '2025-06-15T08:00:00Z',
  });

  final fakePagination = const PaginationMeta(
    page: 1,
    perPage: 20,
    total: 1,
    totalPages: 1,
  );

  setUp(() {
    mockApi = MockApiClient();
    notifier = MortalidadeNotifier(api: mockApi, loteId: loteId);
  });

  group('MortalidadeNotifier', () {
    group('fetch', () {
      test('sucesso: seta lista de mortalidades e paginacao', () async {
        when(() => mockApi.apiGet<List<Mortalidade>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakeMortalidade],
              meta: fakePagination,
            ));

        await notifier.fetch();

        expect(notifier.state.mortalidades.length, 1);
        expect(notifier.state.mortalidades[0].id, 'mort-1');
        expect(notifier.state.pagination, fakePagination);
        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, isNull);
      });

      test('NetworkException: seta erro "Sem conexao..."', () async {
        when(() => mockApi.apiGet<List<Mortalidade>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Sem conexao. Tente novamente.');
      });

      test('erro generico: seta mensagem de erro', () async {
        when(() => mockApi.apiGet<List<Mortalidade>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Falha'));

        await notifier.fetch();

        expect(notifier.state.isLoading, false);
        expect(notifier.state.errorMessage, 'Erro ao carregar mortalidades.');
      });
    });

    group('criar', () {
      test('sucesso: retorna true e seta successMessage', () async {
        when(() => mockApi.apiPost<Mortalidade>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer(
                (_) async => SuccessResponse(data: fakeMortalidade));

        // Stub do fetch subsequente
        when(() => mockApi.apiGet<List<Mortalidade>>(
              any(),
              queryParams: any(named: 'queryParams'),
              fromJson: any(named: 'fromJson'),
            )).thenAnswer((_) async => SuccessResponse(
              data: [fakeMortalidade],
              meta: fakePagination,
            ));

        final result = await notifier.criar(
          data: '2025-06-15',
          quantidade: 3,
          causa: 'morte_subita',
        );

        expect(result, true);
        expect(notifier.state.isSaving, false);
      });

      test('NetworkException: retorna true (offline)', () async {
        when(() => mockApi.apiPost<Mortalidade>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(const NetworkException());

        final result = await notifier.criar(
          data: '2025-06-15',
          quantidade: 3,
          causa: 'morte_subita',
        );

        expect(result, true);
        expect(notifier.state.successMessage,
            'Salvo localmente. Sera sincronizado quando online.');
      });

      test('erro generico: retorna false e seta errorMessage', () async {
        when(() => mockApi.apiPost<Mortalidade>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Erro'));

        final result = await notifier.criar(
          data: '2025-06-15',
          quantidade: 3,
          causa: 'morte_subita',
        );

        expect(result, false);
        expect(notifier.state.errorMessage,
            'Erro ao salvar mortalidade. Tente novamente.');
      });
    });

    group('clearMessages', () {
      test('limpa error e success message', () async {
        when(() => mockApi.apiPost<Mortalidade>(
              any(),
              data: any(named: 'data'),
              fromJson: any(named: 'fromJson'),
            )).thenThrow(Exception('Erro'));

        await notifier.criar(
          data: '2025-06-15',
          quantidade: 3,
          causa: 'morte_subita',
        );
        expect(notifier.state.errorMessage, isNotNull);

        notifier.clearMessages();

        expect(notifier.state.errorMessage, isNull);
        expect(notifier.state.successMessage, isNull);
      });
    });
  });
}
