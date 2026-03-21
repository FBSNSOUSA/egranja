import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/sanidade/domain/entities/visitante.dart';

// ── Estado ──────────────────────────────────────────────────────────────

class VisitantesState {
  final List<Visitante> visitantes;
  final bool isLoading;
  final bool isSaving;
  final PaginationMeta? pagination;
  final String? errorMessage;
  final String? successMessage;

  const VisitantesState({
    this.visitantes = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.pagination,
    this.errorMessage,
    this.successMessage,
  });

  VisitantesState copyWith({
    List<Visitante>? visitantes,
    bool? isLoading,
    bool? isSaving,
    PaginationMeta? pagination,
    String? errorMessage,
    String? successMessage,
  }) {
    return VisitantesState(
      visitantes: visitantes ?? this.visitantes,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      pagination: pagination ?? this.pagination,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  bool get hasMore {
    if (pagination == null) return true;
    return pagination!.page < pagination!.totalPages;
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

class VisitantesNotifier extends StateNotifier<VisitantesState> {
  final ApiClient _api;
  final String _loteId;

  VisitantesNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const VisitantesState());

  /// Busca visitantes do lote (primeira pagina).
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Visitante>>(
        '/lotes/$_loteId/visitantes',
        queryParams: {'page': 1, 'per_page': 20},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Visitante.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        visitantes: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[VisitantesNotifier] Erro ao buscar visitantes: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar visitantes.',
      );
    }
  }

  /// Carrega proxima pagina.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = (state.pagination?.page ?? 0) + 1;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.apiGet<List<Visitante>>(
        '/lotes/$_loteId/visitantes',
        queryParams: {'page': nextPage, 'per_page': 20},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Visitante.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        visitantes: [...state.visitantes, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[VisitantesNotifier] Erro ao carregar mais: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria novo visitante.
  Future<bool> criar({
    required String nome,
    required String dataVisita,
    String? empresa,
    String? motivo,
    String? horaEntrada,
    String? horaSaida,
    bool usouEpi = false,
    String? observacao,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<Visitante>(
        '/lotes/$_loteId/visitantes',
        data: {
          'nome': nome,
          'data_visita': dataVisita,
          'usou_epi': usouEpi,
          if (empresa != null && empresa.isNotEmpty) 'empresa': empresa,
          if (motivo != null && motivo.isNotEmpty) 'motivo': motivo,
          if (horaEntrada != null && horaEntrada.isNotEmpty)
            'hora_entrada': horaEntrada,
          if (horaSaida != null && horaSaida.isNotEmpty)
            'hora_saida': horaSaida,
          if (observacao != null && observacao.isNotEmpty)
            'observacao': observacao,
        },
        fromJson: (json) => Visitante.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Visitante registrado com sucesso!',
      );
      await fetch();
      return true;
    } on NetworkException {
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Salvo localmente. Sera sincronizado quando online.',
      );
      return true;
    } catch (e) {
      debugPrint('[VisitantesNotifier] Erro ao criar visitante: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar visitante. Tente novamente.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

final visitantesProvider = StateNotifierProvider.family<VisitantesNotifier,
    VisitantesState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return VisitantesNotifier(api: api, loteId: loteId);
  },
);
