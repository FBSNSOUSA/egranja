import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/clima/domain/entities/previsao.dart';

// ===================================================================
// ESTADO
// ===================================================================

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

// ===================================================================
// NOTIFIER
// ===================================================================

/// Gerenciador de estado da tela de Clima.
///
/// Carrega previsao do tempo e alertas climaticos para o galpao selecionado.
/// Se o backend falhar, usa dados de fallback para que a tela continue
/// funcional e demonstre a estrutura.
class ClimaNotifier extends StateNotifier<ClimaState> {
  final ApiClient _api;
  final String _galpaoId;

  ClimaNotifier({
    required ApiClient api,
    required String galpaoId,
  })  : _api = api,
        _galpaoId = galpaoId,
        super(const ClimaState());

  /// Busca previsao e alertas. Se a previsao falhar, usa fallback.
  /// Alertas sao buscados separadamente e nao bloqueiam a previsao.
  Future<void> fetch() async {
    if (_galpaoId.isEmpty) return;

    state = state.copyWith(isLoading: true, errorMessage: null);

    PrevisaoResponse? previsao;
    List<AlertaClimatico> alertas = [];

    // Buscar previsao
    try {
      previsao = await _fetchPrevisao();
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
      return;
    } catch (e) {
      debugPrint('[ClimaNotifier] Erro ao buscar previsao: $e');
      // Usar dados de fallback
      previsao = _buildFallbackPrevisao();
    }

    // Buscar alertas (nao bloqueia se falhar)
    try {
      alertas = await _fetchAlertas();
    } catch (e) {
      debugPrint('[ClimaNotifier] Erro ao buscar alertas: $e');
      // Alertas vazio e ok -- a tela funciona sem eles
    }

    if (!mounted) return;
    state = state.copyWith(
      isLoading: false,
      previsao: previsao,
      alertas: alertas,
    );
  }

  /// Busca a previsao do tempo do galpao.
  ///
  /// Backend endpoint: GET /galpoes/{id}/clima/previsao
  /// Backend DTO: PrevisaoTempoResponse
  Future<PrevisaoResponse> _fetchPrevisao() async {
    final response = await _api.apiGet<PrevisaoResponse>(
      '/galpoes/$_galpaoId/clima/previsao',
      fromJson: (json) =>
          PrevisaoResponse.fromJson(json as Map<String, dynamic>),
    );
    return response.data;
  }

  /// Busca alertas climaticos do galpao.
  ///
  /// Backend endpoint: GET /galpoes/{id}/clima/alertas
  /// Backend DTO: AlertasClimaListResponse { "galpao_id", "alertas": [] }
  Future<List<AlertaClimatico>> _fetchAlertas() async {
    final response = await _api.apiGet<List<AlertaClimatico>>(
      '/galpoes/$_galpaoId/clima/alertas',
      fromJson: (json) {
        final map = json as Map<String, dynamic>;
        final list = map['alertas'] as List<dynamic>? ?? [];
        return list
            .map((e) => AlertaClimatico.fromJson(e as Map<String, dynamic>))
            .toList();
      },
    );
    return response.data;
  }

  /// Gera dados de previsao de fallback para demonstrar a estrutura da tela
  /// quando o backend nao esta disponivel ou o galpao nao tem coordenadas.
  PrevisaoResponse _buildFallbackPrevisao() {
    final now = DateTime.now();

    // Gerar previsao horaria (proximas 24 horas)
    final previsaoHoraria = List.generate(24, (i) {
      final hora = now.add(Duration(hours: i));
      // Simular variacao de temperatura ao longo do dia
      final baseTemp = 25.0;
      final hourOfDay = (hora.hour + i) % 24;
      final variation = hourOfDay >= 6 && hourOfDay <= 18
          ? (hourOfDay - 6) * 0.5 - 3
          : -3.0;
      final temp = baseTemp + variation;

      return PrevisaoHora(
        hora: '${hora.hour.toString().padLeft(2, '0')}:00',
        temperatura: temp,
        umidade: 65.0 - (variation * 2),
        precipitacao: hourOfDay >= 14 && hourOfDay <= 16 ? 2.5 : 0,
      );
    });

    // Gerar previsao diaria (7 dias)
    final previsao7dias = List.generate(7, (i) {
      final dia = now.add(Duration(days: i));
      final baseMax = 30.0 + (i % 3 - 1) * 2;
      final baseMin = 18.0 + (i % 3 - 1);

      return PrevisaoDia(
        data:
            '${dia.year}-${dia.month.toString().padLeft(2, '0')}-${dia.day.toString().padLeft(2, '0')}',
        diaSemana: _diaDaSemana(dia.weekday),
        tempMax: baseMax,
        tempMin: baseMin,
        umidade: 60 + (i * 3.0) % 20,
        probabilidadeChuva: i == 2 || i == 5 ? 70 : 10 + i * 5,
        icone: i == 2
            ? 'chuva'
            : i == 5
                ? 'nublado'
                : i.isEven
                    ? 'sol'
                    : 'parcial',
        descricao: i == 2
            ? 'Chuva'
            : i == 5
                ? 'Nublado'
                : 'Tempo bom',
      );
    });

    // Condicao atual derivada da primeira hora
    final atualHora = previsaoHoraria.first;
    final atual = CondicaoAtual(
      temperatura: atualHora.temperatura,
      sensacaoTermica: atualHora.temperatura + 1,
      umidade: atualHora.umidade,
      ventoVelocidade: 12,
      ventoDirecao: 180,
      ventoDirecaoTexto: 'S',
      precipitacao: atualHora.precipitacao,
      descricao: 'Tempo bom',
      icone: 'parcial',
    );

    return PrevisaoResponse(
      atual: atual,
      previsao7dias: previsao7dias,
      previsaoHoraria: previsaoHoraria,
    );
  }

  static String _diaDaSemana(int weekday) {
    const nomes = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sab', 'Dom'];
    return nomes[weekday - 1];
  }

  /// Limpa mensagens de erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null);
  }
}

// ===================================================================
// PROVIDER
// ===================================================================

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
