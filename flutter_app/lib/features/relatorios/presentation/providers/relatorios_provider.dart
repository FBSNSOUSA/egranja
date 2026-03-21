import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/lote.dart';
import 'package:egranja_flutter/features/relatorios/domain/entities/lote_comparativo.dart';

// ═══════════════════════════════════════════════════════════════════════
// RELATORIOS STATE
// ═══════════════════════════════════════════════════════════════════════

/// Resultado de geracao de relatorio.
class RelatorioResult {
  final String url;
  final String nome;

  const RelatorioResult({required this.url, required this.nome});

  factory RelatorioResult.fromJson(Map<String, dynamic> json) {
    return RelatorioResult(
      url: json['url'] as String,
      nome: json['nome'] as String,
    );
  }
}

class RelatoriosState {
  final List<Lote> lotes;
  final String? selectedLoteId;
  final String? loadingReport;
  final List<LoteComparativo> comparativos;
  final Set<String> selectedLoteIds;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const RelatoriosState({
    this.lotes = const [],
    this.selectedLoteId,
    this.loadingReport,
    this.comparativos = const [],
    this.selectedLoteIds = const {},
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  RelatoriosState copyWith({
    List<Lote>? lotes,
    String? selectedLoteId,
    String? loadingReport,
    bool clearLoadingReport = false,
    List<LoteComparativo>? comparativos,
    Set<String>? selectedLoteIds,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return RelatoriosState(
      lotes: lotes ?? this.lotes,
      selectedLoteId: selectedLoteId ?? this.selectedLoteId,
      loadingReport: clearLoadingReport ? null : (loadingReport ?? this.loadingReport),
      comparativos: comparativos ?? this.comparativos,
      selectedLoteIds: selectedLoteIds ?? this.selectedLoteIds,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// RELATORIOS NOTIFIER
// ═══════════════════════════════════════════════════════════════════════

class RelatoriosNotifier extends StateNotifier<RelatoriosState> {
  final ApiClient _api;

  RelatoriosNotifier({required ApiClient api})
      : _api = api,
        super(const RelatoriosState());

  /// Busca todos os lotes (incluindo finalizados).
  Future<void> fetchLotes() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Lote>>(
        '/lotes',
        queryParams: {'incluir_finalizados': true},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Lote.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      final lotes = response.data;
      state = state.copyWith(
        isLoading: false,
        lotes: lotes,
        selectedLoteId:
            lotes.isNotEmpty ? (state.selectedLoteId ?? lotes.first.id) : null,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[RelatoriosNotifier] Erro ao buscar lotes: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar lotes.',
      );
    }
  }

  /// Define o lote selecionado para geracao de relatorio.
  void setSelectedLote(String loteId) {
    state = state.copyWith(selectedLoteId: loteId);
  }

  /// Gera relatorio do tipo informado para o lote selecionado.
  ///
  /// Tipos aceitos: 'fechamento', 'csv', 'financeiro'.
  Future<void> gerarRelatorio(String tipo) async {
    final loteId = state.selectedLoteId;
    if (loteId == null) {
      state = state.copyWith(
        errorMessage: 'Selecione um lote primeiro.',
      );
      return;
    }

    state = state.copyWith(
      loadingReport: tipo,
      errorMessage: null,
      successMessage: null,
    );

    try {
      final String path;
      switch (tipo) {
        case 'fechamento':
          path = '/lotes/$loteId/relatorios/fechamento';
          break;
        case 'csv':
          path = '/lotes/$loteId/relatorios/csv';
          break;
        case 'financeiro':
          path = '/lotes/$loteId/financeiro/relatorio-pdf';
          break;
        default:
          path = '/lotes/$loteId/relatorios/$tipo';
      }

      final response = await _api.apiPost<RelatorioResult>(
        path,
        fromJson: (json) =>
            RelatorioResult.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        clearLoadingReport: true,
        successMessage:
            'Relatorio "${response.data.nome}" gerado com sucesso!',
      );
    } on NetworkException {
      state = state.copyWith(
        clearLoadingReport: true,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[RelatoriosNotifier] Erro ao gerar relatorio: $e');
      state = state.copyWith(
        clearLoadingReport: true,
        errorMessage: 'Erro ao gerar relatorio. Tente novamente.',
      );
    }
  }

  /// Alterna selecao de um lote para comparativo.
  void toggleLoteComparativo(String loteId) {
    final current = Set<String>.from(state.selectedLoteIds);
    if (current.contains(loteId)) {
      current.remove(loteId);
    } else {
      current.add(loteId);
    }
    state = state.copyWith(selectedLoteIds: current);
  }

  /// Busca dados comparativos dos lotes selecionados.
  Future<void> fetchComparativo(List<String> loteIds) async {
    if (loteIds.length < 2) {
      state = state.copyWith(
        errorMessage: 'Selecione pelo menos 2 lotes para comparar.',
      );
      return;
    }

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final idsParam = loteIds.join(',');
      final response = await _api.apiGet<List<LoteComparativo>>(
        '/relatorios/comparativo',
        queryParams: {'lote_ids': idsParam},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => LoteComparativo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        comparativos: response.data,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[RelatoriosNotifier] Erro ao buscar comparativo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar comparativo.',
      );
    }
  }

  /// Limpa mensagens de sucesso/erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════

final relatoriosProvider =
    StateNotifierProvider<RelatoriosNotifier, RelatoriosState>(
  (ref) {
    final api = ref.watch(apiClientProvider);
    return RelatoriosNotifier(api: api);
  },
);
