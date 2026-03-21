import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/galpao/domain/entities/galpao_mapa.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela de mapa de galpoes.
class GalpaoMapaState {
  final GranjaInfo? granja;
  final bool isLoading;
  final String? errorMessage;

  const GalpaoMapaState({
    this.granja,
    this.isLoading = false,
    this.errorMessage,
  });

  GalpaoMapaState copyWith({
    GranjaInfo? granja,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GalpaoMapaState(
      granja: granja ?? this.granja,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado do mapa de galpoes.
///
/// Busca informacoes da granja com galpoes para exibicao no mapa.
class GalpaoMapaNotifier extends StateNotifier<GalpaoMapaState> {
  final ApiClient _api;

  GalpaoMapaNotifier({required ApiClient api})
      : _api = api,
        super(const GalpaoMapaState());

  /// Busca dados da granja com galpoes para o mapa.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<GranjaInfo>(
        '/galpoes/mapa',
        fromJson: (json) =>
            GranjaInfo.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        isLoading: false,
        granja: response.data,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[GalpaoMapaNotifier] Erro ao buscar mapa: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar mapa de galpoes.',
      );
    }
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [GalpaoMapaNotifier] e seu [GalpaoMapaState].
final galpaoMapaProvider =
    StateNotifierProvider<GalpaoMapaNotifier, GalpaoMapaState>(
  (ref) {
    final api = ref.watch(apiClientProvider);
    return GalpaoMapaNotifier(api: api);
  },
);
