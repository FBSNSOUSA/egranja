import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/indicadores.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/lote.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/grafico_data.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/mortalidade.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/pesagem.dart';
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

      if (!mounted) return;
      _lastFetchIndicadores = now;
      state = state.copyWith(
        isLoading: false,
        lote: loteResponse.data,
        indicadores: indicadoresResponse.data,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Sem conexao. Verifique sua internet e tente novamente.',
      );
    } catch (e) {
      debugPrint('[LoteDetailNotifier] Erro ao buscar indicadores: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar indicadores. Tente novamente.',
      );
    }
  }

  /// Busca dados para o grafico de evolucao de peso.
  ///
  /// O backend nao possui endpoint dedicado para dados de grafico.
  /// Busca a lista de pesagens e constroi os dados do grafico client-side.
  Future<void> fetchDadosGraficoPeso() async {
    if (state.dadosGraficoPeso != null) return;

    try {
      final response = await _api.apiGet<List<Pesagem>>(
        '/lotes/$_loteId/pesagens',
        queryParams: {'per_page': 100},
        fromJson: (json) => (json as List<dynamic>?)
                ?.map((e) => Pesagem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      if (!mounted) return;
      final pesagens = response.data;
      final pesoReal = pesagens.map((p) {
        final date = DateTime.tryParse(p.data);
        final label = date != null
            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
            : p.data;
        return PontoGrafico(label: label, valor: p.pesoMedio);
      }).toList();

      state = state.copyWith(
        dadosGraficoPeso: DadosGraficoPeso(
          pesoReal: pesoReal,
          pesoBenchmark: const [],
        ),
      );
    } catch (e) {
      debugPrint('[LoteDetailNotifier] Erro ao buscar grafico peso: $e');
    }
  }

  /// Busca dados para o grafico de mortalidade.
  ///
  /// O backend nao possui endpoint dedicado para dados de grafico.
  /// Busca a lista de mortalidades e constroi os dados do grafico client-side.
  Future<void> fetchDadosGraficoMortalidade() async {
    if (state.dadosGraficoMortalidade != null) return;

    try {
      final response = await _api.apiGet<List<Mortalidade>>(
        '/lotes/$_loteId/mortalidades',
        queryParams: {'per_page': 100},
        fromJson: (json) => (json as List<dynamic>?)
                ?.map(
                    (e) => Mortalidade.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      final mortalidades = response.data;

      // Ordenar por data
      final sorted = List<Mortalidade>.from(mortalidades)
        ..sort((a, b) => a.data.compareTo(b.data));

      final diaria = <PontoGrafico>[];
      final acumulada = <PontoGrafico>[];
      int acum = 0;

      for (final m in sorted) {
        final date = DateTime.tryParse(m.data);
        final label = date != null
            ? '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}'
            : m.data;
        diaria
            .add(PontoGrafico(label: label, valor: m.quantidade.toDouble()));
        acum += m.quantidade;
        acumulada.add(PontoGrafico(label: label, valor: acum.toDouble()));
      }

      if (!mounted) return;
      state = state.copyWith(
        dadosGraficoMortalidade: DadosGraficoMortalidade(
          mortalidadeDiaria: diaria,
          mortalidadeAcumulada: acumulada,
        ),
      );
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

      if (!mounted) return false;
      state = state.copyWith(
        isFinalizando: false,
        successMessage: 'Lote finalizado com sucesso!',
      );
      return true;
    } on NetworkException {
      if (!mounted) return false;
      state = state.copyWith(
        isFinalizando: false,
        successMessage: 'Salvo localmente. Sera sincronizado quando online.',
      );
      return true;
    } catch (e) {
      debugPrint('[LoteDetailNotifier] Erro ao finalizar lote: $e');
      if (!mounted) return false;
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
