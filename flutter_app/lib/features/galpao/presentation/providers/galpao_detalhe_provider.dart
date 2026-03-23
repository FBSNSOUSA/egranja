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
  ///
  /// O backend nao possui endpoint GET por ID para galpaos,
  /// entao buscamos a lista completa e filtramos pelo ID desejado.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<GalpaoDetalhe>>(
        '/galpaos',
        fromJson: (json) => json == null
            ? <GalpaoDetalhe>[]
            : (json as List<dynamic>)
                .map((e) => GalpaoDetalhe.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (!mounted) return;
      final galpao = response.data.cast<GalpaoDetalhe?>().firstWhere(
            (g) => g!.id == _galpaoId,
            orElse: () => null,
          );

      if (galpao == null) {
        state = state.copyWith(
          isLoading: false,
          errorMessage: 'Galpao nao encontrado.',
        );
        return;
      }

      state = state.copyWith(
        isLoading: false,
        galpao: galpao,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[GalpaoDetalheNotifier] Erro ao buscar detalhe: $e');
      if (!mounted) return;
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
