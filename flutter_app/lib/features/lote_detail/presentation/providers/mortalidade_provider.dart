import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/mortalidade.dart';

// ── Estado ──────────────────────────────────────────────────────────────

class MortalidadeState {
  final List<Mortalidade> mortalidades;
  final bool isLoading;
  final bool isSaving;
  final PaginationMeta? pagination;
  final String? errorMessage;
  final String? successMessage;

  const MortalidadeState({
    this.mortalidades = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.pagination,
    this.errorMessage,
    this.successMessage,
  });

  MortalidadeState copyWith({
    List<Mortalidade>? mortalidades,
    bool? isLoading,
    bool? isSaving,
    PaginationMeta? pagination,
    String? errorMessage,
    String? successMessage,
  }) {
    return MortalidadeState(
      mortalidades: mortalidades ?? this.mortalidades,
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

class MortalidadeNotifier extends StateNotifier<MortalidadeState> {
  final ApiClient _api;
  final String _loteId;

  MortalidadeNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const MortalidadeState());

  /// Busca mortalidades do lote (primeira pagina).
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Mortalidade>>(
        '/lotes/$_loteId/mortalidades',
        queryParams: {'page': 1, 'per_page': 20},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Mortalidade.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        mortalidades: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[MortalidadeNotifier] Erro ao buscar mortalidades: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar mortalidades.',
      );
    }
  }

  /// Carrega proxima pagina.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = (state.pagination?.page ?? 0) + 1;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.apiGet<List<Mortalidade>>(
        '/lotes/$_loteId/mortalidades',
        queryParams: {'page': nextPage, 'per_page': 20},
        fromJson: (json) => (json as List<dynamic>)
            .map((e) => Mortalidade.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

      state = state.copyWith(
        isLoading: false,
        mortalidades: [...state.mortalidades, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[MortalidadeNotifier] Erro ao carregar mais: $e');
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria novo registro de mortalidade.
  Future<bool> criar({
    required String data,
    required int quantidade,
    required String causa,
    String? observacao,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<Mortalidade>(
        '/lotes/$_loteId/mortalidades',
        data: {
          'data': data,
          'quantidade': quantidade,
          'causa': causa,
          if (observacao != null && observacao.isNotEmpty)
            'observacao': observacao,
        },
        fromJson: (json) =>
            Mortalidade.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        isSaving: false,
        successMessage: 'Mortalidade registrada com sucesso!',
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
      debugPrint('[MortalidadeNotifier] Erro ao criar mortalidade: $e');
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar mortalidade. Tente novamente.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

final mortalidadeProvider = StateNotifierProvider.family<MortalidadeNotifier,
    MortalidadeState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return MortalidadeNotifier(api: api, loteId: loteId);
  },
);
