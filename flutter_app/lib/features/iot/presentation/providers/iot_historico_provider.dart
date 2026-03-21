import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/iot/domain/entities/historico_iot.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel do historico de sensores IoT.
class IoTHistoricoState {
  /// Dados do historico retornados pela API.
  final HistoricoResponse? historico;

  /// Sensor atualmente selecionado.
  final String sensorSelecionado;

  /// Periodo atualmente selecionado.
  final String periodoSelecionado;

  /// Indica se esta carregando dados.
  final bool isLoading;

  /// Mensagem de erro, se houver.
  final String? errorMessage;

  const IoTHistoricoState({
    this.historico,
    this.sensorSelecionado = 'temperatura',
    this.periodoSelecionado = '24h',
    this.isLoading = false,
    this.errorMessage,
  });

  IoTHistoricoState copyWith({
    HistoricoResponse? historico,
    String? sensorSelecionado,
    String? periodoSelecionado,
    bool? isLoading,
    String? errorMessage,
  }) {
    return IoTHistoricoState(
      historico: historico ?? this.historico,
      sensorSelecionado: sensorSelecionado ?? this.sensorSelecionado,
      periodoSelecionado: periodoSelecionado ?? this.periodoSelecionado,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado do historico de sensores IoT.
///
/// Busca dados do endpoint `/galpoes/{galpaoId}/iot/historico` com
/// filtros de sensor e periodo.
class IoTHistoricoNotifier extends StateNotifier<IoTHistoricoState> {
  final ApiClient _api;
  final String _galpaoId;

  IoTHistoricoNotifier({
    required ApiClient api,
    required String galpaoId,
  })  : _api = api,
        _galpaoId = galpaoId,
        super(const IoTHistoricoState());

  /// Busca os dados historicos do sensor selecionado.
  Future<void> fetch() async {
    if (_galpaoId.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<HistoricoResponse>(
        '/galpoes/$_galpaoId/iot/historico',
        queryParams: {
          'sensor': state.sensorSelecionado,
          'periodo': state.periodoSelecionado,
        },
        fromJson: (json) =>
            HistoricoResponse.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        historico: response.data,
        isLoading: false,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Sem conexao. Verifique sua internet e tente novamente.',
      );
    } catch (e) {
      debugPrint('[IoTHistoricoNotifier] Erro ao buscar historico: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar historico. Tente novamente.',
      );
    }
  }

  /// Altera o sensor selecionado e busca novos dados.
  void setSensor(String sensor) {
    state = state.copyWith(sensorSelecionado: sensor, historico: null);
    fetch();
  }

  /// Altera o periodo selecionado e busca novos dados.
  void setPeriodo(String periodo) {
    state = state.copyWith(periodoSelecionado: periodo, historico: null);
    fetch();
  }

  /// Limpa mensagens de erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [IoTHistoricoNotifier] parametrizado por galpaoId.
final iotHistoricoProvider = StateNotifierProvider.family<
    IoTHistoricoNotifier, IoTHistoricoState, String>(
  (ref, galpaoId) {
    final api = ref.watch(apiClientProvider);
    return IoTHistoricoNotifier(api: api, galpaoId: galpaoId);
  },
);
