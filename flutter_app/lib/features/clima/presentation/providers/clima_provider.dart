import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/clima/domain/entities/previsao.dart';

// ═══════════════════════════════════════════════════════════════════════
// ESTADO
// ═══════════════════════════════════════════════════════════════════════

/// Estado imutavel da tela de Clima / Previsao do Tempo.
class ClimaState {
  final PrevisaoResponse? previsao;
  final List<AlertaClimatico> alertas;
  final bool isLoading;
  final String? errorMessage;

  const ClimaState({
    this.previsao,
    this.alertas = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  ClimaState copyWith({
    PrevisaoResponse? previsao,
    List<AlertaClimatico>? alertas,
    bool? isLoading,
    String? errorMessage,
  }) {
    return ClimaState(
      previsao: previsao ?? this.previsao,
      alertas: alertas ?? this.alertas,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// NOTIFIER
// ═══════════════════════════════════════════════════════════════════════

/// Gerenciador de estado da tela de Clima.
///
/// Carrega previsao do tempo e alertas climaticos em paralelo
/// para o galpao selecionado.
class ClimaNotifier extends StateNotifier<ClimaState> {
  final ApiClient _api;
  final String _galpaoId;

  ClimaNotifier({
    required ApiClient api,
    required String galpaoId,
  })  : _api = api,
        _galpaoId = galpaoId,
        super(const ClimaState());

  /// Busca previsao e alertas em paralelo.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final results = await Future.wait([
        _fetchPrevisao(),
        _fetchAlertas(),
      ]);

      state = state.copyWith(
        isLoading: false,
        previsao: results[0] as PrevisaoResponse,
        alertas: results[1] as List<AlertaClimatico>,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[ClimaNotifier] Erro ao buscar dados climaticos: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar dados climaticos.',
      );
    }
  }

  /// Busca a previsao do tempo do galpao.
  Future<PrevisaoResponse> _fetchPrevisao() async {
    final response = await _api.apiGet<PrevisaoResponse>(
      '/galpoes/$_galpaoId/clima/previsao',
      fromJson: (json) =>
          PrevisaoResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  /// Busca alertas climaticos do galpao.
  Future<List<AlertaClimatico>> _fetchAlertas() async {
    final response = await _api.apiGet<List<AlertaClimatico>>(
      '/galpoes/$_galpaoId/clima/alertas',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['alertas'] as List<dynamic>;
        return list
            .map((e) => AlertaClimatico.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data;
  }

  /// Limpa mensagens de erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null);
  }
}

// ═══════════════════════════════════════════════════════════════════════
// PROVIDER
// ═══════════════════════════════════════════════════════════════════════

/// Provider family do [ClimaNotifier], parametrizado por galpaoId.
///
/// Cada galpao possui seu proprio estado de clima independente.
final climaProvider =
    StateNotifierProvider.family<ClimaNotifier, ClimaState, String>(
  (ref, galpaoId) {
    final api = ref.watch(apiClientProvider);
    return ClimaNotifier(api: api, galpaoId: galpaoId);
  },
);
