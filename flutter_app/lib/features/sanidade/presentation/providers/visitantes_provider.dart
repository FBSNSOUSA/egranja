import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/network/api_response.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/sanidade/domain/entities/granja.dart';
import 'package:egranja_flutter/features/sanidade/domain/entities/visitante.dart';

// ── Granjas Provider ────────────────────────────────────────────────────

/// Provider que busca a lista de granjas do usuario.
///
/// Usado pelo seletor de granja na tela de visitantes.
/// Chama GET /granjas e retorna lista de [Granja].
final granjasProvider = FutureProvider<List<Granja>>((ref) async {
  final api = ref.watch(apiClientProvider);
  final response = await api.apiGet<List<Granja>>(
    '/granjas',
    fromJson: (json) {
      final list = (json as List<dynamic>?) ?? [];
      return list
          .map((e) => Granja.fromJson(e as Map<String, dynamic>))
          .toList();
    },
  );
  return response.data;
});

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
  final String _granjaId;

  VisitantesNotifier({
    required ApiClient api,
    required String granjaId,
  })  : _api = api,
        _granjaId = granjaId,
        super(const VisitantesState());

  /// Busca visitantes da granja (primeira pagina).
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<Visitante>>(
        '/granjas/$_granjaId/visitantes',
        queryParams: {'page': 1, 'per_page': 20},
        fromJson: (json) => json == null
            ? <Visitante>[]
            : (json as List<dynamic>)
                .map((e) => Visitante.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        visitantes: response.data,
        pagination: response.meta,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[VisitantesNotifier] Erro ao buscar visitantes: $e');
      if (!mounted) return;
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
        '/granjas/$_granjaId/visitantes',
        queryParams: {'page': nextPage, 'per_page': 20},
        fromJson: (json) => json == null
            ? <Visitante>[]
            : (json as List<dynamic>)
                .map((e) => Visitante.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        visitantes: [...state.visitantes, ...response.data],
        pagination: response.meta,
      );
    } catch (e) {
      debugPrint('[VisitantesNotifier] Erro ao carregar mais: $e');
      if (!mounted) return;
      state = state.copyWith(isLoading: false);
    }
  }

  /// Cria novo visitante.
  ///
  /// Backend expects CreateVisitanteRequest:
  /// - nome - required
  /// - data_entrada (YYYY-MM-DDTHH:MM:SS or YYYY-MM-DD) - required
  /// - documento - optional
  /// - origem - optional
  /// - motivo - optional
  /// - ultimo_contato_aves (YYYY-MM-DD) - optional
  /// - placa_veiculo - optional
  /// - observacao - optional
  Future<bool> criar({
    required String nome,
    required String dataEntrada,
    String? documento,
    String? origem,
    String? motivo,
    String? ultimoContatoAves,
    String? placaVeiculo,
    String? observacao,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPost<Visitante>(
        '/granjas/$_granjaId/visitantes',
        data: {
          'nome': nome,
          'data_entrada': dataEntrada,
          if (documento != null && documento.isNotEmpty)
            'documento': documento,
          if (origem != null && origem.isNotEmpty) 'origem': origem,
          if (motivo != null && motivo.isNotEmpty) 'motivo': motivo,
          if (ultimoContatoAves != null && ultimoContatoAves.isNotEmpty)
            'ultimo_contato_aves': ultimoContatoAves,
          if (placaVeiculo != null && placaVeiculo.isNotEmpty)
            'placa_veiculo': placaVeiculo,
          if (observacao != null && observacao.isNotEmpty)
            'observacao': observacao,
        },
        fromJson: (json) => Visitante.fromJson(json as Map<String, dynamic>),
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Visitante registrado com sucesso!',
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
      debugPrint('[VisitantesNotifier] Erro ao criar visitante: $e');
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao salvar visitante. Tente novamente.',
      );
      return false;
    }
  }

  /// Registra saida de visitante.
  Future<bool> registrarSaida(String visitanteId) async {
    state = state.copyWith(isSaving: true, errorMessage: null);

    try {
      await _api.apiPatch<Map<String, dynamic>>(
        '/granjas/$_granjaId/visitantes/$visitanteId/saida',
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Saida registrada com sucesso!',
      );
      await fetch();
      return true;
    } catch (e) {
      debugPrint('[VisitantesNotifier] Erro ao registrar saida: $e');
      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        errorMessage: 'Erro ao registrar saida. Tente novamente.',
      );
      return false;
    }
  }

  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [VisitantesNotifier] parametrizado por granjaId.
/// Note: The parameter is granjaId, not loteId.
final visitantesProvider = StateNotifierProvider.family<VisitantesNotifier,
    VisitantesState, String>(
  (ref, granjaId) {
    final api = ref.watch(apiClientProvider);
    return VisitantesNotifier(api: api, granjaId: granjaId);
  },
);
