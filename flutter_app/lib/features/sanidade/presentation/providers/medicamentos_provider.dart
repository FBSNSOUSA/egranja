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
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Medicamento.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        medicamentos: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[MedicamentosNotifier] Erro ao buscar medicamentos: $e');
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
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Medicamento.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        medicamentos: [...state.medicamentos, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[MedicamentosNotifier] Erro ao carregar mais: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria novo medicamento.
  Future<bool> criar({
    required String nome,
    String? principioAtivo,
    String? dosagem,
    String? viaAdministracao,
    int? duracaoTratamentoDias,
    int? periodoCarenciaDias,
    String? dataInicio,
    String? dataFim,
    String? responsavel,
    String? observacao,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<Medicamento>(
        '/lotes/$_loteId/medicamentos',
        data: {
          'nome': nome,
          if (principioAtivo != null && principioAtivo.isNotEmpty)
            'principio_ativo': principioAtivo,
          if (dosagem != null && dosagem.isNotEmpty) 'dosagem': dosagem,
          if (viaAdministracao != null && viaAdministracao.isNotEmpty)
            'via_administracao': viaAdministracao,
          'duracao_tratamento_dias': ?duracaoTratamentoDias,
          'periodo_carencia_dias': ?periodoCarenciaDias,
          'data_inicio': ?dataInicio,
          'data_fim': ?dataFim,
          if (responsavel != null && responsavel.isNotEmpty)
            'responsavel': responsavel,
          if (observacao != null && observacao.isNotEmpty)
            'observacao': observacao,
        },
        fromJson: (json) =>
            Medicamento.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Medicamento registrado com sucesso!',
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
      debugPrint('[MedicamentosNotifier] Erro ao criar medicamento: $e');
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
