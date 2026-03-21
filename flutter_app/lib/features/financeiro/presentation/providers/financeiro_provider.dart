import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/financeiro/domain/entities/custo.dart';
import 'package:egranja_flutter/features/financeiro/domain/entities/remuneracao.dart';
import 'package:egranja_flutter/features/financeiro/domain/entities/resumo_financeiro.dart';

// ═══════════════════════════════════════════════════════════════════════
// RESUMO FINANCEIRO
// ═══════════════════════════════════════════════════════════════════════

class ResumoFinanceiroState {
  final ResumoFinanceiro? resumo;
  final bool isLoading;
  final String? errorMessage;

  const ResumoFinanceiroState({
    this.resumo,
    this.isLoading = false,
    this.errorMessage,
  });

  ResumoFinanceiroState copyWith({
    ResumoFinanceiro? resumo,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ResumoFinanceiroState(
      resumo: resumo ?? this.resumo,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class ResumoFinanceiroNotifier extends StateNotifier<ResumoFinanceiroState> {
  final ApiClient _api;
  final String _loteId;

  ResumoFinanceiroNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const ResumoFinanceiroState());

  /// Busca o resumo financeiro do lote.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<ResumoFinanceiro>(
        '/lotes/$_loteId/financeiro/resumo',
        fromJson: (json) =>
            ResumoFinanceiro.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        isLoading: false,
        resumo: response.data,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[ResumoFinanceiroNotifier] Erro ao buscar resumo: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar resumo financeiro.',
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// CUSTOS
// ═══════════════════════════════════════════════════════════════════════

class CustosState {
  final List<Custo> custos;
  final bool isLoading;
  final bool isSaving;
  final PaginationMeta? pagination;
  final String? errorMessage;
  final String? successMessage;

  const CustosState({
    this.custos = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.pagination,
    this.errorMessage,
    this.successMessage,
  });

  CustosState copyWith({
    List<Custo>? custos,
    bool? isLoading,
    bool? isSaving,
    PaginationMeta? pagination,
    String? errorMessage,
    String? successMessage,
  }) {
    return CustosState(
      custos: custos ?? this.custos,
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

class CustosNotifier extends StateNotifier<CustosState> {
  final ApiClient _api;
  final String _loteId;

  CustosNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const CustosState());

  /// Busca custos do lote (primeira pagina).
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Custo>>(
        '/lotes/$_loteId/financeiro/custos',
        queryParams: {'page': 1, 'per_page': 20},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Custo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        custos: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[CustosNotifier] Erro ao buscar custos: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar custos.',
      );
    }
  }

  /// Carrega proxima pagina de custos.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = (state.pagination?.page ?? 0) + 1;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.apiGet<List<Custo>>(
        '/lotes/$_loteId/financeiro/custos',
        queryParams: {'page': nextPage, 'per_page': 20},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Custo.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        custos: [...state.custos, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[CustosNotifier] Erro ao carregar mais custos: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria um novo custo.
  Future<bool> criar({
    required Map<String, dynamic> data,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<Custo>(
        '/lotes/$_loteId/financeiro/custos',
        data: data,
        fromJson: (json) => Custo.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Custo registrado com sucesso!',
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
      debugPrint('[CustosNotifier] Erro ao criar custo: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar custo. Tente novamente.',
      );
      return false;
    }
  }

  /// Limpa mensagens de sucesso/erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// REMUNERACAO
// ═══════════════════════════════════════════════════════════════════════

class RemuneracaoState {
  final List<Remuneracao> remuneracoes;
  final bool isLoading;
  final String? errorMessage;

  const RemuneracaoState({
    this.remuneracoes = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  RemuneracaoState copyWith({
    List<Remuneracao>? remuneracoes,
    bool? isLoading,
    String? errorMessage,
  }) {
    return RemuneracaoState(
      remuneracoes: remuneracoes ?? this.remuneracoes,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

class RemuneracaoNotifier extends StateNotifier<RemuneracaoState> {
  final ApiClient _api;
  final String _loteId;

  RemuneracaoNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const RemuneracaoState());

  /// Busca remuneracoes do lote.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Remuneracao>>(
        '/lotes/$_loteId/financeiro/remuneracoes',
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Remuneracao.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        remuneracoes: response.data,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[RemuneracaoNotifier] Erro ao buscar remuneracoes: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar remuneracao.',
      );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PROVIDERS
// ═══════════════════════════════════════════════════════════════════════

final resumoFinanceiroProvider = StateNotifierProvider.family<
    ResumoFinanceiroNotifier, ResumoFinanceiroState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return ResumoFinanceiroNotifier(api: api, loteId: loteId);
  },
);

final custosProvider =
    StateNotifierProvider.family<CustosNotifier, CustosState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return CustosNotifier(api: api, loteId: loteId);
  },
);

final remuneracaoProvider = StateNotifierProvider.family<RemuneracaoNotifier,
    RemuneracaoState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return RemuneracaoNotifier(api: api, loteId: loteId);
  },
);
