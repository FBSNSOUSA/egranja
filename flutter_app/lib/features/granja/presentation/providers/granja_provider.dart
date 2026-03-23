import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/granja/data/repositories/granja_repository_impl.dart';
import 'package:egranja_flutter/features/granja/domain/entities/granja.dart';
import 'package:egranja_flutter/features/granja/domain/entities/granja_form.dart';
import 'package:egranja_flutter/features/granja/domain/repositories/granja_repository.dart';

// ── Repositorio ─────────────────────────────────────────────────────────

/// Provider do [GranjaRepository].
final granjaRepositoryProvider = Provider<GranjaRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return GranjaRepositoryImpl(apiClient: apiClient);
});

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela de listagem de granjas.
class GranjaListState {
  final List<Granja> granjas;
  final bool isLoading;
  final String? error;

  const GranjaListState({
    this.granjas = const [],
    this.isLoading = false,
    this.error,
  });

  GranjaListState copyWith({
    List<Granja>? granjas,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return GranjaListState(
      granjas: granjas ?? this.granjas,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GranjaListState &&
          runtimeType == other.runtimeType &&
          granjas == other.granjas &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Object.hash(granjas, isLoading, error);
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado da listagem de granjas.
class GranjaListNotifier extends StateNotifier<GranjaListState> {
  final GranjaRepository _repository;

  GranjaListNotifier({required GranjaRepository repository})
      : _repository = repository,
        super(const GranjaListState());

  /// Carrega a lista de granjas acessiveis.
  Future<void> fetchGranjas() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final granjas = await _repository.fetchGranjas();
      if (!mounted) return;
      state = state.copyWith(
        granjas: granjas,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[GranjaListNotifier] Erro ao buscar granjas: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Recarrega a lista de granjas (pull-to-refresh).
  Future<void> refresh() async {
    try {
      final granjas = await _repository.fetchGranjas();
      if (!mounted) return;
      state = GranjaListState(granjas: granjas);
    } catch (e) {
      debugPrint('[GranjaListNotifier] Erro ao recarregar granjas: $e');
      if (!mounted) return;
      state = state.copyWith(error: _extractErrorMessage(e));
    }
  }

  /// Cria uma nova granja e recarrega a lista.
  Future<Granja> criarGranja(GranjaFormPayload payload) async {
    final granja = await _repository.criarGranja(payload);
    await refresh();
    return granja;
  }

  /// Remove uma granja e recarrega a lista.
  Future<void> deletarGranja(String id) async {
    await _repository.deletarGranja(id);
    await refresh();
  }

  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}

// ── Provider principal ──────────────────────────────────────────────────

/// Provider do [GranjaListNotifier] e seu [GranjaListState].
final granjaListProvider =
    StateNotifierProvider<GranjaListNotifier, GranjaListState>((ref) {
  final repository = ref.watch(granjaRepositoryProvider);
  return GranjaListNotifier(repository: repository);
});

// ── Provider de detalhe ─────────────────────────────────────────────────

/// Provider que busca detalhes de uma granja especifica.
final granjaDetailProvider =
    FutureProvider.family<Granja, String>((ref, granjaId) async {
  final repository = ref.watch(granjaRepositoryProvider);
  return repository.fetchGranjaById(granjaId);
});
