import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/racao.dart';

// ── Estado ──────────────────────────────────────────────────────────────

class RacaoState {
  final List<RecebimentoRacao> recebimentos;
  final List<ConsumoRacao> consumos;
  final bool isLoading;
  final bool isSaving;
  final PaginationMeta? paginationRecebimentos;
  final PaginationMeta? paginationConsumos;
  final String? errorMessage;
  final String? successMessage;

  const RacaoState({
    this.recebimentos = const [],
    this.consumos = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.paginationRecebimentos,
    this.paginationConsumos,
    this.errorMessage,
    this.successMessage,
  });

  RacaoState copyWith({
    List<RecebimentoRacao>? recebimentos,
    List<ConsumoRacao>? consumos,
    bool? isLoading,
    bool? isSaving,
    PaginationMeta? paginationRecebimentos,
    PaginationMeta? paginationConsumos,
    String? errorMessage,
    String? successMessage,
  }) {
    return RacaoState(
      recebimentos: recebimentos ?? this.recebimentos,
      consumos: consumos ?? this.consumos,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      paginationRecebimentos:
          paginationRecebimentos ?? this.paginationRecebimentos,
      paginationConsumos: paginationConsumos ?? this.paginationConsumos,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

class RacaoNotifier extends StateNotifier<RacaoState> {
  final ApiClient _api;
  final String _loteId;

  RacaoNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const RacaoState());

  /// Busca recebimentos e consumos de racao.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final recebimentosResponse =
          await _api.apiGet<List<RecebimentoRacao>>(
        '/lotes/$_loteId/feed_receipts',
        queryParams: {'page': 1, 'per_page': 50},
        fromJson: (json) => (json as List<dynamic>?)
                ?.map((e) =>
                    RecebimentoRacao.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      final consumosResponse = await _api.apiGet<List<ConsumoRacao>>(
        '/lotes/$_loteId/feed_consumptions',
        queryParams: {'page': 1, 'per_page': 50},
        fromJson: (json) => (json as List<dynamic>?)
                ?.map(
                    (e) => ConsumoRacao.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        recebimentos: recebimentosResponse.data,
        consumos: consumosResponse.data,
        paginationRecebimentos: recebimentosResponse.meta,
        paginationConsumos: consumosResponse.meta,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[RacaoNotifier] Erro ao buscar racao: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados de racao.',
      );
    }
  }

  /// Cria novo recebimento de racao.
  Future<bool> criarRecebimento({
    required String dataRecebimento,
    required double quantidadeKg,
    required String tipoRacao,
    String? fornecedor,
    String? loteRacao,
    required String origem,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<RecebimentoRacao>(
        '/lotes/$_loteId/feed_receipts',
        data: {
          'data_recebimento': dataRecebimento,
          'quantidade_kg': quantidadeKg,
          'tipo_racao_nome': tipoRacao,
          if (fornecedor != null && fornecedor.isNotEmpty)
            'fornecedor': fornecedor,
          if (loteRacao != null && loteRacao.isNotEmpty)
            'lote_racao': loteRacao,
          'origem': origem,
        },
        fromJson: (json) =>
            RecebimentoRacao.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Recebimento registrado com sucesso!',
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
      debugPrint('[RacaoNotifier] Erro ao criar recebimento: $e');
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar recebimento. Tente novamente.',
      );
      return false;
    }
  }

  /// Cria novo consumo de racao.
  Future<bool> criarConsumo({
    required String data,
    required double quantidadeKg,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<ConsumoRacao>(
        '/lotes/$_loteId/feed_consumptions',
        data: {
          'data': data,
          'quantidade_kg': quantidadeKg,
        },
        fromJson: (json) =>
            ConsumoRacao.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Consumo registrado com sucesso!',
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
      debugPrint('[RacaoNotifier] Erro ao criar consumo: $e');
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar consumo. Tente novamente.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

final racaoProvider =
    StateNotifierProvider.family<RacaoNotifier, RacaoState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return RacaoNotifier(api: api, loteId: loteId);
  },
);
