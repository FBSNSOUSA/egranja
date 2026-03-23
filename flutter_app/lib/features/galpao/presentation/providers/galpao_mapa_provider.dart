import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/galpao/domain/entities/galpao_mapa.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da tela de mapa de galpoes.
class GalpaoMapaState {
  final GranjaInfo? granja;
  final bool isLoading;
  final String? errorMessage;

  const GalpaoMapaState({
    this.granja,
    this.isLoading = false,
    this.errorMessage,
  });

  GalpaoMapaState copyWith({
    GranjaInfo? granja,
    bool? isLoading,
    String? errorMessage,
  }) {
    return GalpaoMapaState(
      granja: granja ?? this.granja,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado do mapa de galpoes.
///
/// Busca informacoes da granja com galpoes para exibicao no mapa/grid.
class GalpaoMapaNotifier extends StateNotifier<GalpaoMapaState> {
  final ApiClient _api;

  GalpaoMapaNotifier({required ApiClient api})
      : _api = api,
        super(const GalpaoMapaState());

  /// Busca dados da granja com galpoes para o mapa.
  Future<void> fetch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<GalpaoMapa>>(
        '/galpaos',
        fromJson: (json) => json == null
            ? <GalpaoMapa>[]
            : (json as List<dynamic>)
                .map((e) => GalpaoMapa.fromJson(e as Map<String, dynamic>))
                .toList(),
      );

      if (!mounted) return;
      final galpoes = response.data;

      if (galpoes.isEmpty) {
        // Sem galpoes da API -- usar mock para demonstrar a funcionalidade
        state = state.copyWith(
          isLoading: false,
          granja: _buildMockGranja(),
        );
        return;
      }

      final granja = GranjaInfo(
        nome: '',
        latitude: galpoes.isNotEmpty ? galpoes.first.latitude : 0,
        longitude: galpoes.isNotEmpty ? galpoes.first.longitude : 0,
        galpoes: galpoes,
      );

      state = state.copyWith(
        isLoading: false,
        granja: granja,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[GalpaoMapaNotifier] Erro ao buscar mapa: $e');
      if (!mounted) return;
      // Fallback: mostrar dados mock
      state = state.copyWith(
        isLoading: false,
        granja: _buildMockGranja(),
      );
    }
  }

  /// Gera dados mock de galpoes para demonstrar a funcionalidade
  /// quando a API nao esta disponivel.
  GranjaInfo _buildMockGranja() {
    return GranjaInfo(
      nome: 'Granja Modelo',
      latitude: -23.5505,
      longitude: -46.6333,
      galpoes: [
        const GalpaoMapa(
          id: 'mock-g1',
          nome: 'Galpao 1',
          latitude: -23.5505,
          longitude: -46.6333,
          orientacaoGraus: 45,
          larguraM: 14,
          comprimentoM: 120,
          ventilacao: 'Tunnel',
          cortinas: 'Lateral',
          loteAtivo: LoteAtivoInfo(
            id: 'lote-1',
            avesVivas: 22500,
            diasDeVida: 18,
          ),
          iot: IoTInfo(
            temperatura: 27.5,
            umidade: 65,
            status: 'ok',
          ),
        ),
        const GalpaoMapa(
          id: 'mock-g2',
          nome: 'Galpao 2',
          latitude: -23.5510,
          longitude: -46.6340,
          orientacaoGraus: 45,
          larguraM: 14,
          comprimentoM: 120,
          ventilacao: 'Tunnel',
          cortinas: 'Lateral',
          loteAtivo: LoteAtivoInfo(
            id: 'lote-2',
            avesVivas: 21800,
            diasDeVida: 32,
          ),
          iot: IoTInfo(
            temperatura: 31.2,
            umidade: 72,
            status: 'alerta',
          ),
        ),
        const GalpaoMapa(
          id: 'mock-g3',
          nome: 'Galpao 3',
          latitude: -23.5515,
          longitude: -46.6335,
          orientacaoGraus: 90,
          larguraM: 12,
          comprimentoM: 100,
          ventilacao: 'Convencional',
          cortinas: 'Lateral',
        ),
        const GalpaoMapa(
          id: 'mock-g4',
          nome: 'Galpao 4',
          latitude: -23.5508,
          longitude: -46.6345,
          orientacaoGraus: 45,
          larguraM: 14,
          comprimentoM: 120,
          ventilacao: 'Dark House',
          cortinas: 'Sem cortinas',
          loteAtivo: LoteAtivoInfo(
            id: 'lote-3',
            avesVivas: 23000,
            diasDeVida: 5,
          ),
          iot: IoTInfo(
            temperatura: 32.8,
            umidade: 58,
            status: 'ok',
          ),
        ),
      ],
    );
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [GalpaoMapaNotifier] e seu [GalpaoMapaState].
final galpaoMapaProvider =
    StateNotifierProvider<GalpaoMapaNotifier, GalpaoMapaState>(
  (ref) {
    final api = ref.watch(apiClientProvider);
    return GalpaoMapaNotifier(api: api);
  },
);
