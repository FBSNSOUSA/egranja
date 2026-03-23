import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/home/data/models/lote_model.dart';
import 'package:egranja_flutter/features/home/domain/entities/lote.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela de produtores (visao tecnico).
class ProdutoresState {
  final List<Lote> lotes;
  final bool isLoading;
  final String? error;

  const ProdutoresState({
    this.lotes = const [],
    this.isLoading = false,
    this.error,
  });

  ProdutoresState copyWith({
    List<Lote>? lotes,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ProdutoresState(
      lotes: lotes ?? this.lotes,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  /// Agrupa lotes por usuario (produtor).
  Map<String, List<Lote>> get lotesPorProdutor {
    final grouped = <String, List<Lote>>{};
    for (final lote in lotes) {
      final key = lote.usuarioId ?? 'desconhecido';
      grouped.putIfAbsent(key, () => []).add(lote);
    }
    return grouped;
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado para a tela de produtores.
///
/// Busca lotes do endpoint `/tecnico/lotes` que retorna todos os lotes
/// dos produtores vinculados ao tecnico.
class ProdutoresNotifier extends StateNotifier<ProdutoresState> {
  final ApiClient _apiClient;

  ProdutoresNotifier({required ApiClient apiClient})
      : _apiClient = apiClient,
        super(const ProdutoresState());

  /// Busca todos os lotes dos produtores vinculados ao tecnico.
  Future<void> fetchLotes() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final response = await _apiClient.apiGet<List<LoteModel>>(
        '/tecnico/lotes',
        fromJson: (json) {
          final list = (json as List<dynamic>?) ?? [];
          return list
              .map((e) => LoteModel.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

      if (!mounted) return;
      state = state.copyWith(
        lotes: response.data,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[ProdutoresNotifier] Erro ao buscar lotes: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  /// Recarrega os lotes (pull-to-refresh).
  Future<void> refresh() async {
    await fetchLotes();
  }
}

// ── Provider principal ──────────────────────────────────────────────────

/// Provider do [ProdutoresNotifier] e seu [ProdutoresState].
final produtoresProvider =
    StateNotifierProvider<ProdutoresNotifier, ProdutoresState>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ProdutoresNotifier(apiClient: apiClient);
});
