import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/sanidade/domain/entities/medicamento.dart';

// ── Estado ──────────────────────────────────────────────────────────────

class MedicamentosState {
  final List<Medicamento> medicamentos;
  final bool isLoading;
  final bool isSaving;
  final PaginationMeta? pagination;
  final String? errorMessage;
  final String? successMessage;

  const MedicamentosState({
    this.medicamentos = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.pagination,
    this.errorMessage,
    this.successMessage,
  });

  MedicamentosState copyWith({
    List<Medicamento>? medicamentos,
    bool? isLoading,
    bool? isSaving,
    PaginationMeta? pagination,
    String? errorMessage,
    String? successMessage,
  }) {
    return MedicamentosState(
      medicamentos: medicamentos ?? this.medicamentos,
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

class MedicamentosNotifier extends StateNotifier<MedicamentosState> {
  final ApiClient _api;
  final String _loteId;

  MedicamentosNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const MedicamentosState());

  /// Busca medicamentos do lote (primeira pagina).
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Medicamento>>(
        '/lotes/$_loteId/medicamentos',
        queryParams: {'page': 1, 'per_page': 20},
        fromJson: (json) => json == null
            ? <Medicamento>[]
            : (json as List<dynamic>)
                .map((e) => Medicamento.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        medicamentos: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[MedicamentosNotifier] Erro ao buscar medicamentos: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar medicamentos.',
      );
    }
  }

  /// Carrega proxima pagina.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = (state.pagination?.page ?? 0) + 1;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.apiGet<List<Medicamento>>(
        '/lotes/$_loteId/medicamentos',
        queryParams: {'page': nextPage, 'per_page': 20},
        fromJson: (json) => json == null
            ? <Medicamento>[]
            : (json as List<dynamic>)
                .map((e) => Medicamento.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        medicamentos: [...state.medicamentos, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[MedicamentosNotifier] Erro ao carregar mais: $e');
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria novo medicamento.
  ///
  /// Backend expects CreateMedicamentoRequest:
  /// - data_inicio (YYYY-MM-DD) - required
  /// - medicamento - required
  /// - data_fim - optional
  /// - dosagem - optional
  /// - via - optional
  /// - periodo_carencia_dias - optional
  /// - responsavel - optional
  /// - observacao - optional
  Future<bool> criar({
    required String medicamento,
    required String dataInicio,
    String? dataFim,
    String? dosagem,
    String? via,
    int? periodoCarenciaDias,
    String? responsavel,
    String? observacao,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<Medicamento>(
        '/lotes/$_loteId/medicamentos',
        data: {
          'data_inicio': dataInicio,
          'medicamento': medicamento,
          if (dataFim != null && dataFim.isNotEmpty) 'data_fim': dataFim,
          if (dosagem != null && dosagem.isNotEmpty) 'dosagem': dosagem,
          if (via != null && via.isNotEmpty) 'via': via,
          // ignore: use_null_aware_elements
          if (periodoCarenciaDias != null)
            'periodo_carencia_dias': periodoCarenciaDias,
          if (responsavel != null && responsavel.isNotEmpty)
            'responsavel': responsavel,
          if (observacao != null && observacao.isNotEmpty)
            'observacao': observacao,
        },
        fromJson: (json) =>
            Medicamento.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Medicamento registrado com sucesso!',
      );
      await fetch();
      return true;
    } on NetworkException {
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Salvo localmente. Sera sincronizado quando online.',
      );
      return true;
    } catch (e) {
      debugPrint('[MedicamentosNotifier] Erro ao criar medicamento: $e');
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar medicamento. Tente novamente.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

final medicamentosProvider = StateNotifierProvider.family<MedicamentosNotifier,
    MedicamentosState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return MedicamentosNotifier(api: api, loteId: loteId);
  },
);
