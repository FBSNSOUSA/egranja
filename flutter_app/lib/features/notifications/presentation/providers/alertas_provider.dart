import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/notifications/data/repositories/alertas_repository.dart';
import 'package:egranja_flutter/features/notifications/domain/entities/alerta.dart';

// ── Repositorio ─────────────────────────────────────────────────────────

/// Provider do [AlertasRepository].
final alertasRepositoryProvider = Provider<AlertasRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return AlertasRepository(apiClient: apiClient);
});

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela de alertas/notificacoes.
class AlertasState {
  final List<Alerta> alertas;
  final bool isLoading;
  final String? error;

  const AlertasState({
    this.alertas = const [],
    this.isLoading = false,
    this.error,
  });

  AlertasState copyWith({
    List<Alerta>? alertas,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return AlertasState(
      alertas: alertas ?? this.alertas,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Total de alertas criticos.
  int get totalCriticos =>
      alertas.where((a) => a.prioridade == AlertaPrioridade.critica).length;

  /// Total de alertas altos.
  int get totalAltos =>
      alertas.where((a) => a.prioridade == AlertaPrioridade.alta).length;
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado de alertas/notificacoes.
class AlertasNotifier extends StateNotifier<AlertasState> {
  final AlertasRepository _repository;

  AlertasNotifier({required AlertasRepository repository})
      : _repository = repository,
        super(const AlertasState());

  /// Busca todos os alertas do usuario.
  Future<void> fetchAlertas() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final alertas = await _repository.fetchAlertas();
      if (!mounted) return;

      // Ordenar por prioridade: critica primeiro, depois alta, depois media
      alertas.sort((a, b) {
        final prioridadeOrder = {
          AlertaPrioridade.critica: 0,
          AlertaPrioridade.alta: 1,
          AlertaPrioridade.media: 2,
        };
        return (prioridadeOrder[a.prioridade] ?? 3)
            .compareTo(prioridadeOrder[b.prioridade] ?? 3);
      });

      state = state.copyWith(
        alertas: alertas,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[AlertasNotifier] Erro ao buscar alertas: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Recarrega alertas (pull-to-refresh).
  Future<void> refresh() async {
    await fetchAlertas();
  }
}

// ── Provider principal ──────────────────────────────────────────────────

/// Provider do [AlertasNotifier] e seu [AlertasState].
final alertasProvider =
    StateNotifierProvider<AlertasNotifier, AlertasState>((ref) {
  final repository = ref.watch(alertasRepositoryProvider);
  return AlertasNotifier(repository: repository);
});

/// Provider derivado que retorna apenas a contagem total de alertas.
///
/// Usado pelo badge do sino no AppBar para exibir o numero sem
/// precisar reconstruir toda a tela.
final alertasCountProvider = Provider<int>((ref) {
  final state = ref.watch(alertasProvider);
  return state.alertas.length;
});
