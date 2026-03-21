import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/features/home/domain/entities/lote.dart';
import 'package:egranja_flutter/features/home/domain/repositories/home_repository.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';

// ── Mock ───────────────────────────────────────────────────────────────

class MockHomeRepository extends Mock implements HomeRepository {}

// ── Helpers ────────────────────────────────────────────────────────────

Lote createLote(String id) => Lote(
      id: id,
      galpaoId: 'galpao-1',
      galpaoNome: 'Galpao 1',
      dataAlojamento: '2025-03-01',
      dataPrevistaAbate: '2025-04-15',
      quantidade: 25000,
      tipo: 'Misto',
      pesoInicialG: 42.0,
      status: 'ativo',
      diasDeVida: 21,
      avesVivas: 24800,
      createdAt: '2025-03-01T00:00:00Z',
      updatedAt: '2025-03-21T00:00:00Z',
    );

const paginationPage1 = PaginationMeta(
  page: 1,
  perPage: 10,
  total: 25,
  totalPages: 3,
);

const paginationPage2 = PaginationMeta(
  page: 2,
  perPage: 10,
  total: 25,
  totalPages: 3,
);

const paginationLastPage = PaginationMeta(
  page: 3,
  perPage: 10,
  total: 25,
  totalPages: 3,
);

void main() {
  late MockHomeRepository mockRepository;
  late HomeNotifier notifier;

  setUp(() {
    mockRepository = MockHomeRepository();
    notifier = HomeNotifier(repository: mockRepository);
  });

  group('HomeNotifier', () {
    group('fetchLotes', () {
      test('sucesso: define lotesAtivos e pagination', () async {
        final lotes = [createLote('1'), createLote('2')];
        when(() => mockRepository.fetchLotesAtivos(page: 1))
            .thenAnswer((_) async => (lotes, paginationPage1));

        await notifier.fetchLotes();

        expect(notifier.state.lotesAtivos, lotes);
        expect(notifier.state.pagination, isNotNull);
        expect(notifier.state.pagination!.page, 1);
        expect(notifier.state.isLoading, false);
        expect(notifier.state.error, isNull);
      });

      test('erro: define mensagem de erro', () async {
        when(() => mockRepository.fetchLotesAtivos(page: 1))
            .thenThrow(Exception('Erro de conexao'));

        await notifier.fetchLotes();

        expect(notifier.state.error, isNotNull);
        expect(notifier.state.isLoading, false);
        expect(notifier.state.lotesAtivos, isEmpty);
      });
    });

    group('loadMore', () {
      test('sucesso: adiciona lotes e atualiza pagination', () async {
        // Primeira pagina
        final firstPage = [createLote('1'), createLote('2')];
        when(() => mockRepository.fetchLotesAtivos(page: 1))
            .thenAnswer((_) async => (firstPage, paginationPage1));
        await notifier.fetchLotes();

        // Segunda pagina
        final secondPage = [createLote('3'), createLote('4')];
        when(() => mockRepository.fetchLotesAtivos(page: 2))
            .thenAnswer((_) async => (secondPage, paginationPage2));

        await notifier.loadMore();

        expect(notifier.state.lotesAtivos.length, 4);
        expect(notifier.state.pagination!.page, 2);
        expect(notifier.state.isLoadingMore, false);
      });

      test('quando nao ha mais paginas: nao faz nada', () async {
        // Carregar ultima pagina
        final lotes = [createLote('1')];
        when(() => mockRepository.fetchLotesAtivos(page: 1))
            .thenAnswer((_) async => (lotes, paginationLastPage));
        await notifier.fetchLotes();

        // hasMore deve ser false
        expect(notifier.state.hasMore, false);

        // loadMore nao deve chamar repository
        await notifier.loadMore();

        verifyNever(() => mockRepository.fetchLotesAtivos(page: 4));
      });
    });

    group('refresh', () {
      test('substitui todos os lotes', () async {
        // Carregar primeira pagina
        final firstLoad = [createLote('1'), createLote('2')];
        when(() => mockRepository.fetchLotesAtivos(page: 1))
            .thenAnswer((_) async => (firstLoad, paginationPage1));
        await notifier.fetchLotes();
        expect(notifier.state.lotesAtivos.length, 2);

        // Refresh com novos dados
        final refreshedData = [createLote('A'), createLote('B'), createLote('C')];
        when(() => mockRepository.fetchLotesAtivos(page: 1))
            .thenAnswer((_) async => (refreshedData, paginationPage1));

        await notifier.refresh();

        expect(notifier.state.lotesAtivos.length, 3);
        expect(notifier.state.lotesAtivos.first.id, 'A');
        expect(notifier.state.isLoading, false);
      });
    });

    group('hasMore', () {
      test('true quando page < totalPages', () async {
        final lotes = [createLote('1')];
        when(() => mockRepository.fetchLotesAtivos(page: 1))
            .thenAnswer((_) async => (lotes, paginationPage1));
        await notifier.fetchLotes();

        expect(notifier.state.hasMore, true);
      });

      test('false quando page == totalPages', () async {
        final lotes = [createLote('1')];
        when(() => mockRepository.fetchLotesAtivos(page: 1))
            .thenAnswer((_) async => (lotes, paginationLastPage));
        await notifier.fetchLotes();

        expect(notifier.state.hasMore, false);
      });

      test('false quando pagination e null', () {
        expect(notifier.state.hasMore, false);
      });
    });
  });
}
