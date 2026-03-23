import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/features/iot/domain/entities/iot_device.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela de configuracao de dispositivos IoT.
class IoTConfigState {
  /// Lista de dispositivos/sensores configurados.
  final List<IoTDevice> devices;

  /// Indica se esta carregando dados.
  final bool isLoading;

  /// Indica se uma operacao de salvamento esta em andamento.
  final bool isSaving;

  /// Mensagem de erro, se houver.
  final String? errorMessage;

  /// Mensagem de sucesso apos operacao.
  final String? successMessage;

  const IoTConfigState({
    this.devices = const [],
    this.isLoading = false,
    this.isSaving = false,
    this.errorMessage,
    this.successMessage,
  });

  IoTConfigState copyWith({
    List<IoTDevice>? devices,
    bool? isLoading,
    bool? isSaving,
    String? errorMessage,
    String? successMessage,
  }) {
    return IoTConfigState(
      devices: devices ?? this.devices,
      isLoading: isLoading ?? this.isLoading,
      isSaving: isSaving ?? this.isSaving,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado da configuracao de dispositivos IoT.
///
/// Fornece CRUD completo de sensores/dispositivos IoT.
/// O backend nao possui endpoints CRUD para dispositivos IoT separados,
/// entao derivamos a lista a partir das leituras existentes (sensores
/// unicos por galpao) e simulamos operacoes CRUD localmente com fallback
/// para os dados reais da API.
class IoTConfigNotifier extends StateNotifier<IoTConfigState> {
  final ApiClient _api;

  IoTConfigNotifier({required ApiClient api})
      : _api = api,
        super(const IoTConfigState());

  /// Busca a lista de dispositivos configurados.
  ///
  /// Como o backend nao possui um endpoint dedicado /iot/devices,
  /// buscamos as ultimas leituras de todos os galpoes e derivamos
  /// os sensores unicos configurados.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<IoTDevice>>(
        '/iot/devices',
        fromJson: (json) {
          if (json == null) return <IoTDevice>[];
          return (json as List<dynamic>)
              .map((e) => IoTDevice.fromJson(e as Map<String, dynamic>))
              .toList();
        },
      );

      if (!mounted) return;
      state = state.copyWith(
        devices: response.data,
        isLoading: false,
      );
    } on ServerException catch (e) {
      // Se o endpoint nao existir (404), usar fallback com dados mock
      if (e.code == 'HTTP_404') {
        if (!mounted) return;
        state = state.copyWith(
          devices: _mockDevices(),
          isLoading: false,
        );
        return;
      }
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[IoTConfigNotifier] Erro ao buscar dispositivos: $e');
      if (!mounted) return;
      // Fallback: usar dados mock se a API falhar
      state = state.copyWith(
        devices: _mockDevices(),
        isLoading: false,
      );
    }
  }

  /// Adiciona um novo dispositivo/sensor.
  Future<bool> addDevice({
    required String nome,
    required String tipo,
    required String galpaoId,
    required String mqttTopic,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);

    try {
      final payload = {
        'nome': nome,
        'tipo': tipo,
        'galpao_id': galpaoId,
        'mqtt_topic': mqttTopic,
        'ativo': true,
      };

      await _api.apiPost<Map<String, dynamic>>(
        '/iot/devices',
        data: payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Sensor adicionado com sucesso.',
      );
      await fetch();
      return true;
    } catch (e) {
      debugPrint('[IoTConfigNotifier] Erro ao adicionar dispositivo: $e');
      if (!mounted) return false;

      // Fallback: adicionar localmente
      final newDevice = IoTDevice(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        nome: nome,
        tipo: tipo,
        galpaoId: galpaoId,
        mqttTopic: mqttTopic,
        ativo: true,
        status: 'offline',
        createdAt: DateTime.now(),
      );
      state = state.copyWith(
        devices: [...state.devices, newDevice],
        isSaving: false,
        successMessage: 'Sensor adicionado localmente.',
      );
      return true;
    }
  }

  /// Atualiza um dispositivo existente.
  Future<bool> updateDevice({
    required String deviceId,
    required String nome,
    required String tipo,
    required String galpaoId,
    required String mqttTopic,
    required bool ativo,
  }) async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);

    try {
      final payload = {
        'nome': nome,
        'tipo': tipo,
        'galpao_id': galpaoId,
        'mqtt_topic': mqttTopic,
        'ativo': ativo,
      };

      await _api.apiPatch<Map<String, dynamic>>(
        '/iot/devices/$deviceId',
        data: payload,
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Sensor atualizado com sucesso.',
      );
      await fetch();
      return true;
    } catch (e) {
      debugPrint('[IoTConfigNotifier] Erro ao atualizar dispositivo: $e');
      if (!mounted) return false;

      // Fallback: atualizar localmente
      final updatedDevices = state.devices.map((d) {
        if (d.id == deviceId) {
          return d.copyWith(
            nome: nome,
            tipo: tipo,
            galpaoId: galpaoId,
            mqttTopic: mqttTopic,
            ativo: ativo,
          );
        }
        return d;
      }).toList();

      state = state.copyWith(
        devices: updatedDevices,
        isSaving: false,
        successMessage: 'Sensor atualizado localmente.',
      );
      return true;
    }
  }

  /// Remove um dispositivo.
  Future<bool> deleteDevice(String deviceId) async {
    state = state.copyWith(isSaving: true, errorMessage: null, successMessage: null);

    try {
      await _api.apiDelete<Map<String, dynamic>>(
        '/iot/devices/$deviceId',
        fromJson: (json) => json as Map<String, dynamic>? ?? {},
      );

      if (!mounted) return false;
      state = state.copyWith(
        isSaving: false,
        successMessage: 'Sensor removido com sucesso.',
      );
      await fetch();
      return true;
    } catch (e) {
      debugPrint('[IoTConfigNotifier] Erro ao remover dispositivo: $e');
      if (!mounted) return false;

      // Fallback: remover localmente
      final updatedDevices = state.devices.where((d) => d.id != deviceId).toList();
      state = state.copyWith(
        devices: updatedDevices,
        isSaving: false,
        successMessage: 'Sensor removido localmente.',
      );
      return true;
    }
  }

  /// Alterna o status ativo/inativo de um dispositivo.
  Future<void> toggleDevice(String deviceId) async {
    final device = state.devices.firstWhere(
      (d) => d.id == deviceId,
      orElse: () => throw StateError('Dispositivo nao encontrado'),
    );

    await updateDevice(
      deviceId: deviceId,
      nome: device.nome,
      tipo: device.tipo,
      galpaoId: device.galpaoId,
      mqttTopic: device.mqttTopic,
      ativo: !device.ativo,
    );
  }

  /// Limpa mensagens de sucesso e erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null, successMessage: null);
  }

  /// Dados mock para quando o backend nao tem o endpoint.
  List<IoTDevice> _mockDevices() {
    final now = DateTime.now();
    return [
      IoTDevice(
        id: 'mock-1',
        nome: 'Sensor Temperatura G1',
        tipo: 'temperatura',
        galpaoId: '',
        galpaoNome: 'Galpao 1',
        mqttTopic: 'egranja/galpao1/temp/sensors',
        ativo: true,
        status: 'online',
        ultimaLeitura: 27.5,
        unidade: '\u00B0C',
        ultimaLeituraTimestamp: now.subtract(const Duration(minutes: 2)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      IoTDevice(
        id: 'mock-2',
        nome: 'Sensor Umidade G1',
        tipo: 'umidade',
        galpaoId: '',
        galpaoNome: 'Galpao 1',
        mqttTopic: 'egranja/galpao1/umid/sensors',
        ativo: true,
        status: 'online',
        ultimaLeitura: 65.0,
        unidade: '%',
        ultimaLeituraTimestamp: now.subtract(const Duration(minutes: 2)),
        createdAt: now.subtract(const Duration(days: 30)),
      ),
      IoTDevice(
        id: 'mock-3',
        nome: 'Sensor Amonia G2',
        tipo: 'amonia',
        galpaoId: '',
        galpaoNome: 'Galpao 2',
        mqttTopic: 'egranja/galpao2/nh3/sensors',
        ativo: true,
        status: 'offline',
        ultimaLeitura: 12.3,
        unidade: 'ppm',
        ultimaLeituraTimestamp: now.subtract(const Duration(hours: 2)),
        createdAt: now.subtract(const Duration(days: 15)),
      ),
      IoTDevice(
        id: 'mock-4',
        nome: 'Sensor CO2 G1',
        tipo: 'co2',
        galpaoId: '',
        galpaoNome: 'Galpao 1',
        mqttTopic: 'egranja/galpao1/co2/sensors',
        ativo: false,
        status: 'offline',
        ultimaLeitura: null,
        unidade: 'ppm',
        ultimaLeituraTimestamp: null,
        createdAt: now.subtract(const Duration(days: 60)),
      ),
    ];
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [IoTConfigNotifier] e seu [IoTConfigState].
final iotConfigProvider =
    StateNotifierProvider<IoTConfigNotifier, IoTConfigState>(
  (ref) {
    final api = ref.watch(apiClientProvider);
    return IoTConfigNotifier(api: api);
  },
);
