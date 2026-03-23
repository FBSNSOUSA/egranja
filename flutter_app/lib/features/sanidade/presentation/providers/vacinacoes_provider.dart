import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/sanidade/domain/entities/vacinacao.dart';

// ── Estado ──────────────────────────────────────────────────────────────

class VacinacoesState {
  final List<Vacinacao> vacinacoes;
  final bool isLoading;
  final bool isSaving;
  final PaginationMeta? pagination;
  final String? errorMessage;
  final String? successMessage;

  const VacinacoesState({
    this.vacinacoes = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.pagination,
    this.errorMessage,
    this.successMessage,
  });

  VacinacoesState copyWith({
    List<Vacinacao>? vacinacoes,
    bool? isLoading,
    bool? isSaving,
    PaginationMeta? pagination,
    String? errorMessage,
    String? successMessage,
  }) {
    return VacinacoesState(
      vacinacoes: vacinacoes ?? this.vacinacoes,
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

class VacinacoesNotifier extends StateNotifier<VacinacoesState> {
  final ApiClient _api;
  final String _loteId;

  VacinacoesNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const VacinacoesState());

  /// Busca vacinacoes do lote (primeira pagina).
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Vacinacao>>(
        '/lotes/$_loteId/vacinacoes',
        queryParams: {'page': 1, 'per_page': 20},
        fromJson: (json) => json == null
            ? <Vacinacao>[]
            : (json as List<dynamic>)
                .map((e) => Vacinacao.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        vacinacoes: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[VacinacoesNotifier] Erro ao buscar vacinacoes: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar vacinacoes.',
      );
    }
  }

  /// Carrega proxima pagina.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = (state.pagination?.page ?? 0) + 1;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.apiGet<List<Vacinacao>>(
        '/lotes/$_loteId/vacinacoes',
        queryParams: {'page': nextPage, 'per_page': 20},
        fromJson: (json) => json == null
            ? <Vacinacao>[]
            : (json as List<dynamic>)
                .map((e) => Vacinacao.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        vacinacoes: [...state.vacinacoes, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[VacinacoesNotifier] Erro ao carregar mais: $e');
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria nova vacinacao.
  ///
  /// Backend expects CreateVacinacaoRequest:
  /// - data (YYYY-MM-DD) - required
  /// - vacina - required
  /// - lote_produto - optional
  /// - via_administracao - optional
  /// - responsavel - optional
  /// - observacao - optional
  Future<bool> criar({
    required String vacina,
    required String data,
    String? loteProduto,
    String? viaAdministracao,
    String? responsavel,
    String? observacao,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<Vacinacao>(
        '/lotes/$_loteId/vacinacoes',
        data: {
          'data': data,
          'vacina': vacina,
          if (loteProduto != null && loteProduto.isNotEmpty)
            'lote_produto': loteProduto,
          if (viaAdministracao != null && viaAdministracao.isNotEmpty)
            'via_administracao': viaAdministracao,
          if (responsavel != null && responsavel.isNotEmpty)
            'responsavel': responsavel,
          if (observacao != null && observacao.isNotEmpty)
            'observacao': observacao,
        },
        fromJson: (json) => Vacinacao.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Vacinacao registrada com sucesso!',
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
      debugPrint('[VacinacoesNotifier] Erro ao criar vacinacao: $e');
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar vacinacao. Tente novamente.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

final vacinacoesProvider = StateNotifierProvider.family<VacinacoesNotifier,
    VacinacoesState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return VacinacoesNotifier(api: api, loteId: loteId);
  },
);
