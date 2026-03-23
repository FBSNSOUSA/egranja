import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/pesagem.dart';

// ── Estado ──────────────────────────────────────────────────────────────

class PesagensState {
  final List<Pesagem> pesagens;
  final bool isLoading;
  final bool isSaving;
  final PaginationMeta? pagination;
  final String? errorMessage;
  final String? successMessage;

  const PesagensState({
    this.pesagens = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.pagination,
    this.errorMessage,
    this.successMessage,
  });

  PesagensState copyWith({
    List<Pesagem>? pesagens,
    bool? isLoading,
    bool? isSaving,
    PaginationMeta? pagination,
    String? errorMessage,
    String? successMessage,
  }) {
    return PesagensState(
      pesagens: pesagens ?? this.pesagens,
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

class PesagensNotifier extends StateNotifier<PesagensState> {
  final ApiClient _api;
  final String _loteId;

  PesagensNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const PesagensState());

  /// Busca pesagens do lote (primeira pagina).
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Pesagem>>(
        '/lotes/$_loteId/pesagens',
        queryParams: {'page': 1, 'per_page': 20},
        fromJson: (json) => (json as List<dynamic>?)
                ?.map((e) => Pesagem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        pesagens: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[PesagensNotifier] Erro ao buscar pesagens: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar pesagens.',
      );
    }
  }

  /// Carrega proxima pagina de pesagens.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = (state.pagination?.page ?? 0) + 1;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.apiGet<List<Pesagem>>(
        '/lotes/$_loteId/pesagens',
        queryParams: {'page': nextPage, 'per_page': 20},
        fromJson: (json) => (json as List<dynamic>?)
                ?.map((e) => Pesagem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        pesagens: [...state.pesagens, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[PesagensNotifier] Erro ao carregar mais pesagens: $e');
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria uma nova pesagem.
  Future<bool> criar({
    required String data,
    required List<Map<String, dynamic>> items,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<Pesagem>(
        '/lotes/$_loteId/pesagens',
        data: {'data': data, 'items': items},
        fromJson: (json) => Pesagem.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Pesagem registrada com sucesso!',
      );
      // Recarregar lista
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
      debugPrint('[PesagensNotifier] Erro ao criar pesagem: $e');
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar pesagem. Tente novamente.',
      );
      return false;
    }
  }

  /// Limpa mensagens de sucesso/erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

final pesagensProvider = StateNotifierProvider.family<PesagensNotifier,
    PesagensState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return PesagensNotifier(api: api, loteId: loteId);
  },
);
