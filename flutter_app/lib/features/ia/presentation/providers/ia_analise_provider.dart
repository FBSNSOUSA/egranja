import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/ia/domain/entities/analise_ia.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da analise IA.
class IAAnaliseState {
  final AnaliseIA? analise;
  final bool isLoading;
  final bool isGerando;
  final String? errorMessage;

  const IAAnaliseState({
    this.analise,
    this.isLoading = false,
    this.isGerando = false,
    this.errorMessage,
  });

  IAAnaliseState copyWith({
    AnaliseIA? analise,
    bool? isLoading,
    bool? isGerando,
    String? errorMessage,
  }) {
    return IAAnaliseState(
      analise: analise ?? this.analise,
      isLoading: isLoading ?? this.isLoading,
      isGerando: isGerando ?? this.isGerando,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado da analise IA.
///
/// Carrega e gera analises de desempenho do lote.
class IAAnaliseNotifier extends StateNotifier<IAAnaliseState> {
  final ApiClient _api;
  final String _loteId;

  IAAnaliseNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const IAAnaliseState());

  /// Carrega a analise mais recente do lote.
  ///
  /// O backend so possui POST /lotes/{id}/ia/analisar (nao GET).
  /// Tentamos buscar do historico; se nao houver, mostramos estado vazio
  /// para que o usuario clique em "Gerar analise".
  Future<void> carregarAnalise() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Buscar ultima interacao do tipo 'analise' no historico
      final response = await _api.apiGet<AnaliseIA?>(
        '/lotes/$_loteId/ia/historico',
        queryParams: {'per_page': '1'},
        fromJson: (json) {
          if (json == null) return null;
          final list = json as List<dynamic>;
          // Procurar a interacao mais recente do tipo 'analise'
          for (final item in list) {
            final map = item as Map<String, dynamic>;
            if (map['tipo'] == 'analise') {
              return AnaliseIA.fromJson(map);
            }
          }
          // Se nao encontrou analise, usar a primeira interacao
          if (list.isNotEmpty) {
            final map = list.first as Map<String, dynamic>;
            if (map['tipo'] == 'analise') {
              return AnaliseIA.fromJson(map);
            }
          }
          return null;
        },
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        analise: response.data,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[IAAnaliseNotifier] Erro ao carregar analise: $e');
      if (!mounted) return;
      // Nao tratar como erro critico -- pode simplesmente nao ter analise
      state = state.copyWith(
        isLoading: false,
      );
    }
  }

  /// Gera uma nova analise do lote via POST.
  ///
  /// Backend endpoint: POST /lotes/{id}/ia/analisar
  /// Backend DTO: IAAnaliseResponse { "resposta": "...", "tokens": ... }
  Future<void> gerarNovaAnalise() async {
    state = state.copyWith(isGerando: true, errorMessage: null);

    try {
      final response = await _api.apiPost<AnaliseIA>(
        '/lotes/$_loteId/ia/analisar',
        fromJson: (json) =>
            AnaliseIA.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return;
      state = state.copyWith(
        isGerando: false,
        analise: response.data,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isGerando: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[IAAnaliseNotifier] Erro ao gerar analise: $e');
      if (!mounted) return;
      state = state.copyWith(
        isGerando: false,
        errorMessage: 'Erro ao gerar analise. Tente novamente.',
      );
    }
  }

  /// Limpa mensagens de erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [IAAnaliseNotifier] parametrizado por loteId.
final iaAnaliseProvider =
    StateNotifierProvider.family<IAAnaliseNotifier, IAAnaliseState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return IAAnaliseNotifier(api: api, loteId: loteId);
  },
);
