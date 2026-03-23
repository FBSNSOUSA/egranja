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
  ///
  /// O backend espera query params `from`, `to` e `intervalo` (hora/dia),
  /// nao `sensor` e `periodo`. Convertemos o periodo do UI (24h/7d/30d)
  /// para as datas from/to e intervalo adequados.
  Future<void> fetch() async {
    if (_galpaoId.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Converter periodo do UI para from/to/intervalo do backend
      final now = DateTime.now();
      late DateTime from;
      late String intervalo;

      switch (state.periodoSelecionado) {
        case '7d':
          from = now.subtract(const Duration(days: 7));
          intervalo = 'dia';
          break;
        case '30d':
          from = now.subtract(const Duration(days: 30));
          intervalo = 'dia';
          break;
        case '24h':
        default:
          from = now.subtract(const Duration(hours: 24));
          intervalo = 'hora';
          break;
      }

      final fromStr =
          '${from.year}-${from.month.toString().padLeft(2, '0')}-${from.day.toString().padLeft(2, '0')}T${from.hour.toString().padLeft(2, '0')}:${from.minute.toString().padLeft(2, '0')}:${from.second.toString().padLeft(2, '0')}';
      final toStr =
          '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}T${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}:${now.second.toString().padLeft(2, '0')}';

      final response = await _api.apiGet<HistoricoResponse>(
        '/galpoes/$_galpaoId/iot/historico',
        queryParams: {
          'from': fromStr,
          'to': toStr,
          'intervalo': intervalo,
        },
        fromJson: (json) => HistoricoResponse.fromBackendJson(
          json as Map<String, dynamic>,
          sensorTipo: state.sensorSelecionado,
          periodo: state.periodoSelecionado,
        ),
      );

      if (!mounted) return;
      state = state.copyWith(
        historico: response.data,
        isLoading: false,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Sem conexao. Verifique sua internet e tente novamente.',
      );
    } catch (e) {
      debugPrint('[IoTHistoricoNotifier] Erro ao buscar historico: $e');
      if (!mounted) return;
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
