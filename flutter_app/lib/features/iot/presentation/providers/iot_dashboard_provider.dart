import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/iot/domain/entities/sensor_data.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel do painel de sensores IoT.
class IoTDashboardState {
  /// Lista de sensores com leituras atuais.
  final List<SensorData> sensores;

  /// Momento da ultima leitura recebida.
  final DateTime? ultimaLeitura;

  /// Indica se esta carregando dados.
  final bool isLoading;

  /// Mensagem de erro, se houver.
  final String? errorMessage;

  const IoTDashboardState({
    this.sensores = const [],
    this.ultimaLeitura,
    this.isLoading = false,
    this.errorMessage,
  });

  IoTDashboardState copyWith({
    List<SensorData>? sensores,
    DateTime? ultimaLeitura,
    bool? isLoading,
    String? errorMessage,
  }) {
    return IoTDashboardState(
      sensores: sensores ?? this.sensores,
      ultimaLeitura: ultimaLeitura ?? this.ultimaLeitura,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado do dashboard de sensores IoT.
///
/// Busca dados do endpoint `/galpoes/{galpaoId}/iot/latest` e
/// auto-atualiza a cada 30 segundos via [Timer.periodic].
class IoTDashboardNotifier extends StateNotifier<IoTDashboardState> {
  final ApiClient _api;
  final String _galpaoId;
  Timer? _refreshTimer;

  IoTDashboardNotifier({
    required ApiClient api,
    required String galpaoId,
  })  : _api = api,
        _galpaoId = galpaoId,
        super(const IoTDashboardState()) {
    _startAutoRefresh();
  }

  /// Inicia o timer de auto-refresh a cada 30 segundos.
  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(
      const Duration(seconds: 30),
      (_) => fetch(),
    );
  }

  /// Busca as leituras mais recentes dos sensores do galpao.
  Future<void> fetch() async {
    if (_galpaoId.isEmpty) return;

    state = state.copyWith(isLoading: state.sensores.isEmpty);

    try {
      final response = await _api.apiGet<IoTLatestResponse>(
        '/galpoes/$_galpaoId/iot/latest',
        fromJson: (json) =>
            IoTLatestResponse.fromJson(json as Map<String, dynamic>),
      );

      state = state.copyWith(
        sensores: response.data.sensores,
        ultimaLeitura: response.data.ultimaLeitura,
        isLoading: false,
        errorMessage: null,
      );
    } on NetworkException {
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            'Sem conexao. Verifique sua internet e tente novamente.',
      );
    } catch (e) {
      debugPrint('[IoTDashboardNotifier] Erro ao buscar sensores: $e');
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar sensores. Tente novamente.',
      );
    }
  }

  /// Limpa mensagens de erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null);
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [IoTDashboardNotifier] parametrizado por galpaoId.
final iotDashboardProvider = StateNotifierProvider.family<
    IoTDashboardNotifier, IoTDashboardState, String>(
  (ref, galpaoId) {
    final api = ref.watch(apiClientProvider);
    return IoTDashboardNotifier(api: api, galpaoId: galpaoId);
  },
);
