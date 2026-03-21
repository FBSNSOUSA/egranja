import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/indicadores.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/lote.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/grafico_data.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/finalizar_lote_payload.dart';

// ── Estado ──────────────────────────────────────────────────────────────

class LoteDetailState {
  final bool isLoading;
  final Lote? lote;
  final Indicadores? indicadores;
  final DadosGraficoPeso? dadosGraficoPeso;
  final DadosGraficoMortalidade? dadosGraficoMortalidade;
  final String? errorMessage;
  final bool isFinalizando;
  final String? successMessage;

  const LoteDetailState({
    this.isLoading = false,
    this.lote,
    this.indicadores,
    this.dadosGraficoPeso,
    this.dadosGraficoMortalidade,
    this.errorMessage,
    this.isFinalizando = false,
    this.successMessage,
  });

  LoteDetailState copyWith({
    bool? isLoading,
    Lote? lote,
    Indicadores? indicadores,
    DadosGraficoPeso? dadosGraficoPeso,
    DadosGraficoMortalidade? dadosGraficoMortalidade,
    String? errorMessage,
    bool? isFinalizando,
    String? successMessage,
  }) {
    return LoteDetailState(
      isLoading: isLoading ?? this.isLoading,
      lote: lote ?? this.lote,
      indicadores: indicadores ?? this.indicadores,
      dadosGraficoPeso: dadosGraficoPeso ?? this.dadosGraficoPeso,
      dadosGraficoMortalidade:
          dadosGraficoMortalidade ?? this.dadosGraficoMortalidade,
      errorMessage: errorMessage,
      isFinalizando: isFinalizando ?? this.isFinalizando,
      successMessage: successMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

class LoteDetailNotifier extends StateNotifier<LoteDetailState> {
  final ApiClient _api;
  final String _loteId;
  DateTime? _lastFetchIndicadores;

  LoteDetailNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const LoteDetailState());

  /// Busca dados do lote e indicadores.
  /// Cache de 5 minutos para indicadores.
  Future<void> fetchIndicadores({bool forceRefresh = false}) async {
    final now = DateTime.now();
    if (!forceRefresh &&
        _lastFetchIndicadores != null &&
        now.difference(_lastFetchIndicadores!).inMinutes < 5 &&
        state.indicadores != null) {
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final loteResponse = await _api.apiGet<Lote>(
        '/lotes/$_loteId',
        fromJson: (json) => Lote.fromJson(json as Map<String, dynamic>),
      );

      final indicadoresResponse = await _api.apiGet<Indicadores>(
        '/lotes/$_loteId/indicadores',
        fromJson: (json) =>
            Indicadores.fromJson(json as Map<String, dynamic>),
      );

      _lastFetchIndicadores = now;
      state = state.copyWith(
        isLoading: false,
        lote: loteResponse.data,
        indicadores: indicadoresResponse.data,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Sem conexao. Verifique sua internet e tente novamente.',
      );
    } catch (e) {
      debugPrint('[LoteDetailNotifier] Erro ao buscar indicadores: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar indicadores. Tente novamente.',
      );
    }
  }

  /// Busca dados para o grafico de evolucao de peso.
  Future<void> fetchDadosGraficoPeso() async {
    if (state.dadosGraficoPeso != null) return;

    try {
      final response = await _api.apiGet<DadosGraficoPeso>(
        '/lotes/$_loteId/grafico-peso',
        fromJson: (json) =>
            DadosGraficoPeso.fromJson(json as Map<String, dynamic>),
      );
      state = state.copyWith(dadosGraficoPeso: response.data);
    } catch (e) {
      debugPrint('[LoteDetailNotifier] Erro ao buscar grafico peso: $e');
    }
  }

  /// Busca dados para o grafico de mortalidade.
  Future<void> fetchDadosGraficoMortalidade() async {
    if (state.dadosGraficoMortalidade != null) return;

    try {
      final response = await _api.apiGet<DadosGraficoMortalidade>(
        '/lotes/$_loteId/grafico-mortalidade',
        fromJson: (json) =>
            DadosGraficoMortalidade.fromJson(json as Map<String, dynamic>),
      );
      state = state.copyWith(dadosGraficoMortalidade: response.data);
    } catch (e) {
      debugPrint(
          '[LoteDetailNotifier] Erro ao buscar grafico mortalidade: $e');
    }
  }

  /// Finaliza o lote.
  Future<bool> finalizarLote(FinalizarLotePayload payload) async {
    state = state.copyWith(isFinalizando: true, errorMessage: null);

    try {
      await _api.apiPatch<Map<String, dynamic>>(
        '/lotes/$_loteId/finalizar',
        data: payload.toJson(),
        fromJson: (json) => json as Map<String, dynamic>,
      );

      state = state.copyWith(
        isFinalizando: false,
        successMessage: 'Lote finalizado com sucesso!',
      );
      return true;
    } on NetworkException {
      state = state.copyWith(
        isFinalizando: false,
        successMessage: 'Salvo localmente. Sera sincronizado quando online.',
      );
      return true;
    } catch (e) {
      debugPrint('[LoteDetailNotifier] Erro ao finalizar lote: $e');
      state = state.copyWith(
        isFinalizando: false,
        errorMessage: 'Erro ao finalizar lote. Tente novamente.',
      );
      return false;
    }
  }

  /// Limpa mensagens de sucesso/erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  /// Invalida o cache para forcar recarregamento na proxima chamada.
  void invalidateCache() {
    _lastFetchIndicadores = null;
    state = LoteDetailState(lote: state.lote);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

final loteDetailProvider = StateNotifierProvider.family<LoteDetailNotifier,
    LoteDetailState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return LoteDetailNotifier(api: api, loteId: loteId);
  },
);
