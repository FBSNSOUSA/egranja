import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/features/home/data/repositories/home_repository_impl.dart';
import 'package:egranja_flutter/features/home/domain/entities/galpao.dart';
import 'package:egranja_flutter/features/home/domain/entities/lote.dart';
import 'package:egranja_flutter/features/home/domain/repositories/home_repository.dart';

// ── Repositorio ─────────────────────────────────────────────────────────

/// Provider do [HomeRepository].
final homeRepositoryProvider = Provider<HomeRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return HomeRepositoryImpl(apiClient: apiClient);
});

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela Home.
class HomeState {
  final List<Lote> lotesAtivos;
  final bool isLoading;
  final bool isLoadingMore;
  final PaginationMeta? pagination;
  final String? error;

  const HomeState({
    this.lotesAtivos = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.pagination,
    this.error,
  });

  HomeState copyWith({
    List<Lote>? lotesAtivos,
    bool? isLoading,
    bool? isLoadingMore,
    PaginationMeta? pagination,
    String? error,
    bool clearError = false,
  }) {
    return HomeState(
      lotesAtivos: lotesAtivos ?? this.lotesAtivos,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      pagination: pagination ?? this.pagination,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Verifica se ha mais paginas para carregar.
  bool get hasMore {
    if (pagination == null) return false;
    return pagination!.page < pagination!.totalPages;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HomeState &&
          runtimeType == other.runtimeType &&
          lotesAtivos == other.lotesAtivos &&
          isLoading == other.isLoading &&
          isLoadingMore == other.isLoadingMore &&
          pagination == other.pagination &&
          error == other.error;

  @override
  int get hashCode => Object.hash(
        lotesAtivos,
        isLoading,
        isLoadingMore,
        pagination,
        error,
      );
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado da Home.
///
/// Carrega lotes ativos com paginacao, suporta pull-to-refresh
/// e load-more ao atingir o fim da lista.
class HomeNotifier extends StateNotifier<HomeState> {
  final HomeRepository _repository;

  HomeNotifier({required HomeRepository repository})
      : _repository = repository,
        super(const HomeState());

  /// Carrega a primeira pagina de lotes ativos.
  Future<void> fetchLotes() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final (lotes, meta) = await _repository.fetchLotesAtivos(page: 1);
      if (!mounted) return;
      state = state.copyWith(
        lotesAtivos: lotes,
        pagination: meta,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[HomeNotifier] Erro ao buscar lotes: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Carrega a proxima pagina de lotes (infinite scroll).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = (state.pagination?.page ?? 0) + 1;
      final (lotes, meta) =
          await _repository.fetchLotesAtivos(page: nextPage);
      if (!mounted) return;
      state = state.copyWith(
        lotesAtivos: [...state.lotesAtivos, ...lotes],
        pagination: meta,
        isLoadingMore: false,
      );
    } catch (e) {
      debugPrint('[HomeNotifier] Erro ao carregar mais lotes: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoadingMore: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Recarrega todos os lotes (pull-to-refresh).
  Future<void> refresh() async {
    try {
      final (lotes, meta) = await _repository.fetchLotesAtivos(page: 1);
      if (!mounted) return;
      state = HomeState(
        lotesAtivos: lotes,
        pagination: meta,
      );
    } catch (e) {
      debugPrint('[HomeNotifier] Erro ao recarregar lotes: $e');
      if (!mounted) return;
      state = state.copyWith(
        error: _extractErrorMessage(e),
      );
    }
  }

  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}

// ── Provider principal ──────────────────────────────────────────────────

/// Provider do [HomeNotifier] e seu [HomeState].
final homeProvider = StateNotifierProvider<HomeNotifier, HomeState>((ref) {
  final repository = ref.watch(homeRepositoryProvider);
  return HomeNotifier(repository: repository);
});

// ── Provider de galpoes ─────────────────────────────────────────────────

/// Provider que busca a lista de galpoes disponiveis.
final galpaosProvider = FutureProvider<List<Galpao>>((ref) async {
  final repository = ref.watch(homeRepositoryProvider);
  return repository.fetchGalpaos();
});
