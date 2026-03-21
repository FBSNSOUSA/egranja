import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/galpao/domain/entities/galpao_detalhe.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela de detalhe do galpao.
class GalpaoDetalheState {
  final GalpaoDetalhe? galpao;
  final bool isLoading;
  final String? errorMessage;

  const GalpaoDetalheState({
    this.galpao,
    this.isLoading = false,
    this.errorMessage,
  });

  GalpaoDetalheState copyWith({
    GalpaoDetalhe? galpao,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GalpaoDetalheState(
      galpao: galpao ?? this.galpao,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado do detalhe do galpao.
///
/// Busca informacoes detalhadas de um galpao especifico.
class GalpaoDetalheNotifier extends StateNotifier<GalpaoDetalheState> {
  final ApiClient _api;
  final String _galpaoId;

  GalpaoDetalheNotifier({
    required ApiClient api,
    required String galpaoId,
  })  : _api = api,
        _galpaoId = galpaoId,
        super(const GalpaoDetalheState());

  /// Busca detalhes do galpao.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<GalpaoDetalhe>(
        '/galpoes/$_galpaoId',
        fromJson: (json) =>
            GalpaoDetalhe.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        isLoading: false,
        galpao: response.data,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[GalpaoDetalheNotifier] Erro ao buscar detalhe: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar detalhes do galpao.',
      );
    }
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [GalpaoDetalheNotifier] parametrizado por galpaoId.
final galpaoDetalheProvider = StateNotifierProvider.family<
    GalpaoDetalheNotifier, GalpaoDetalheState, String>(
  (ref, galpaoId) {
    final api = ref.watch(apiClientProvider);
    return GalpaoDetalheNotifier(api: api, galpaoId: galpaoId);
  },
);
