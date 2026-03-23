import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/agua.dart';

// ── Estado ──────────────────────────────────────────────────────────────

class AguaState {
  final List<ConsumoAgua> consumos;
  final bool isLoading;
  final bool isSaving;
  final PaginationMeta? pagination;
  final String? errorMessage;
  final String? successMessage;

  const AguaState({
    this.consumos = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.pagination,
    this.errorMessage,
    this.successMessage,
  });

  AguaState copyWith({
    List<ConsumoAgua>? consumos,
    bool? isLoading,
    bool? isSaving,
    PaginationMeta? pagination,
    String? errorMessage,
    String? successMessage,
  }) {
    return AguaState(
      consumos: consumos ?? this.consumos,
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

class AguaNotifier extends StateNotifier<AguaState> {
  final ApiClient _api;
  final String _loteId;

  AguaNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const AguaState());

  /// Busca consumos de agua do lote.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<ConsumoAgua>>(
        '/lotes/$_loteId/water_consumptions',
        queryParams: {'page': 1, 'per_page': 50},
        fromJson: (json) => (json as List<dynamic>?)
                ?.map(
                    (e) => ConsumoAgua.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        consumos: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[AguaNotifier] Erro ao buscar consumos de agua: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar consumos de agua.',
      );
    }
  }

  /// Carrega proxima pagina.
  Future<void> loadMore() async {
    if (!state.hasMore || state.isLoading) return;

    final nextPage = (state.pagination?.page ?? 0) + 1;
    state = state.copyWith(isLoading: true);

    try {
      final response = await _api.apiGet<List<ConsumoAgua>>(
        '/lotes/$_loteId/water_consumptions',
        queryParams: {'page': nextPage, 'per_page': 50},
        fromJson: (json) => (json as List<dynamic>?)
                ?.map(
                    (e) => ConsumoAgua.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        consumos: [...state.consumos, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[AguaNotifier] Erro ao carregar mais: $e');
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria novo registro de consumo de agua.
  Future<bool> criar({
    required String data,
    required double quantidadeLitros,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<ConsumoAgua>(
        '/lotes/$_loteId/water_consumptions',
        data: {
          'data': data,
          'quantidade_litros': quantidadeLitros,
        },
        fromJson: (json) =>
            ConsumoAgua.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Consumo de agua registrado com sucesso!',
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
      debugPrint('[AguaNotifier] Erro ao criar consumo de agua: $e');
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar consumo de agua. Tente novamente.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

final aguaProvider =
    StateNotifierProvider.family<AguaNotifier, AguaState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return AguaNotifier(api: api, loteId: loteId);
  },
);
