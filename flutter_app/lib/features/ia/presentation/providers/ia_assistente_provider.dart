import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/network/api_client.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/ia/domain/entities/ia_mensagem.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel do chat com IA.
class IAAssistenteState {
  final List<IAMensagem> mensagens;
  final bool isCarregandoHistorico;
  final bool isEnviando;
  final String? errorMessage;

  const IAAssistenteState({
    this.mensagens = const [],
    this.isCarregandoHistorico = false,
    this.isEnviando = false,
    this.errorMessage,
  });

  IAAssistenteState copyWith({
    List<IAMensagem>? mensagens,
    bool? isCarregandoHistorico,
    bool? isEnviando,
    String? errorMessage,
  }) {
    return IAAssistenteState(
      mensagens: mensagens ?? this.mensagens,
      isCarregandoHistorico:
          isCarregandoHistorico ?? this.isCarregandoHistorico,
      isEnviando: isEnviando ?? this.isEnviando,
      errorMessage: errorMessage,
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado do assistente IA.
///
/// Carrega historico de mensagens e envia perguntas para a IA.
class IAAssistenteNotifier extends StateNotifier<IAAssistenteState> {
  final ApiClient _api;
  final String _loteId;

  IAAssistenteNotifier({
    required ApiClient api,
    required String loteId,
  })  : _api = api,
        _loteId = loteId,
        super(const IAAssistenteState());

  /// Carrega o historico de mensagens do chat com IA.
  ///
  /// Backend endpoint: GET /lotes/{id}/ia/historico
  /// Backend DTO: []IAInteracaoResponse (paginado)
  ///   { "id", "pergunta", "resposta", "tipo", "modelo", "tokens", "created_at" }
  ///
  /// Cada interacao gera duas IAMensagens (pergunta + resposta).
  /// A resposta e paginada: data e uma lista, com meta de paginacao.
  /// Se data for null, tratamos como lista vazia.
  Future<void> carregarHistorico() async {
    state = state.copyWith(isCarregandoHistorico: true, errorMessage: null);

    try {
      final response = await _api.apiGet<List<IAMensagem>>(
        '/lotes/$_loteId/ia/historico',
        fromJson: (json) {
          // Backend retorna lista paginada (pode ser null ou lista)
          if (json == null) return <IAMensagem>[];
          final list = json as List<dynamic>;
          final mensagens = <IAMensagem>[];
          for (final item in list) {
            final map = item as Map<String, dynamic>;
            mensagens.addAll(IAMensagem.fromInteracaoJson(map));
          }
          return mensagens;
        },
      );

      if (!mounted) return;
      state = state.copyWith(
        isCarregandoHistorico: false,
        mensagens: response.data,
      );
    } on NetworkException {
      if (!mounted) return;
      state = state.copyWith(
        isCarregandoHistorico: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[IAAssistenteNotifier] Erro ao carregar historico: $e');
      if (!mounted) return;
      state = state.copyWith(
        isCarregandoHistorico: false,
        errorMessage: 'Erro ao carregar historico.',
      );
    }
  }

  /// Envia uma pergunta para a IA e aguarda a resposta.
  ///
  /// Adiciona a mensagem do usuario imediatamente na lista,
  /// e quando a IA responde, adiciona a resposta tambem.
  Future<void> enviarMensagem(String pergunta) async {
    if (pergunta.trim().isEmpty) return;

    // Adiciona mensagem do usuario imediatamente
    final userMessage = IAMensagem(
      id: 'user_${DateTime.now().millisecondsSinceEpoch}',
      remetente: 'usuario',
      texto: pergunta.trim(),
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      mensagens: [...state.mensagens, userMessage],
      isEnviando: true,
      errorMessage: null,
    );

    try {
      final response = await _api.apiPost<Map<String, dynamic>>(
        '/lotes/$_loteId/ia/consultar',
        data: {'pergunta': pergunta.trim()},
        fromJson: (json) => json as Map<String, dynamic>,
      );

      if (!mounted) return;
      final data = response.data;
      final iaMessage = IAMensagem(
        id: data['id']?.toString() ??
            'ia_${DateTime.now().millisecondsSinceEpoch}',
        remetente: 'ia',
        texto: data['resposta'] as String? ?? '',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        mensagens: [...state.mensagens, iaMessage],
        isEnviando: false,
      );
    } on NetworkException {
      if (!mounted) return;
      final errorMsg = IAMensagem(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        remetente: 'ia',
        texto: 'Sem conexao com a internet. Tente novamente quando estiver online.',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        mensagens: [...state.mensagens, errorMsg],
        isEnviando: false,
        errorMessage: 'Sem conexao. Tente novamente.',
      );
    } catch (e) {
      debugPrint('[IAAssistenteNotifier] Erro ao enviar mensagem: $e');
      if (!mounted) return;

      final errorMsg = IAMensagem(
        id: 'error_${DateTime.now().millisecondsSinceEpoch}',
        remetente: 'ia',
        texto:
            'Desculpe, ocorreu um erro ao processar sua pergunta. Tente novamente.',
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        mensagens: [...state.mensagens, errorMsg],
        isEnviando: false,
        errorMessage: 'Erro ao enviar mensagem.',
      );
    }
  }

  /// Limpa mensagens de erro.
  void clearMessages() {
    state = state.copyWith(errorMessage: null);
  }
}

// ── Provider ────────────────────────────────────────────────────────────

/// Provider do [IAAssistenteNotifier] parametrizado por loteId.
final iaAssistenteProvider = StateNotifierProvider.family<IAAssistenteNotifier,
    IAAssistenteState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return IAAssistenteNotifier(api: api, loteId: loteId);
  },
);
