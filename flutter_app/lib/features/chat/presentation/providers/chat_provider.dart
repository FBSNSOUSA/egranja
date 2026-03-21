import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/features/chat/domain/entities/mensagem.dart';
import 'package:egranja_flutter/features/chat/domain/repositories/chat_repository.dart';
import 'package:egranja_flutter/features/chat/presentation/providers/chat_list_provider.dart';

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel de um chat individual.
class ChatState {
  final List<Mensagem> mensagens;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final bool isSending;
  final String? error;
  final int currentPage;

  const ChatState({
    this.mensagens = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.isSending = false,
    this.error,
    this.currentPage = 1,
  });

  ChatState copyWith({
    List<Mensagem>? mensagens,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    bool? isSending,
    String? error,
    bool clearError = false,
    int? currentPage,
  }) {
    return ChatState(
      mensagens: mensagens ?? this.mensagens,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      isSending: isSending ?? this.isSending,
      error: clearError ? null : (error ?? this.error),
      currentPage: currentPage ?? this.currentPage,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatState &&
          runtimeType == other.runtimeType &&
          mensagens == other.mensagens &&
          isLoading == other.isLoading &&
          isLoadingMore == other.isLoadingMore &&
          hasMore == other.hasMore &&
          isSending == other.isSending &&
          error == other.error &&
          currentPage == other.currentPage;

  @override
  int get hashCode => Object.hash(
        mensagens,
        isLoading,
        isLoadingMore,
        hasMore,
        isSending,
        error,
        currentPage,
      );
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado de um chat individual.
///
/// Carrega mensagens com paginacao, envia mensagens (texto, foto, audio)
/// e recebe mensagens em tempo real via WebSocket.
class ChatNotifier extends StateNotifier<ChatState> {
  final ChatRepository _repository;
  final String loteId;

  ChatNotifier({
    required ChatRepository repository,
    required this.loteId,
  })  : _repository = repository,
        super(const ChatState());

  /// Carrega a primeira pagina de mensagens.
  Future<void> fetchMensagens() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final (mensagens, hasMore) = await _repository.fetchMensagens(
        loteId,
        page: 1,
      );
      state = state.copyWith(
        mensagens: mensagens,
        isLoading: false,
        hasMore: hasMore,
        currentPage: 1,
      );
    } catch (e) {
      debugPrint('[ChatNotifier] Erro ao buscar mensagens: $e');
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Carrega a proxima pagina de mensagens (load more / scroll up).
  Future<void> loadMore() async {
    if (state.isLoadingMore || !state.hasMore) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final nextPage = state.currentPage + 1;
      final (mensagens, hasMore) = await _repository.fetchMensagens(
        loteId,
        page: nextPage,
      );
      state = state.copyWith(
        mensagens: [...state.mensagens, ...mensagens],
        isLoadingMore: false,
        hasMore: hasMore,
        currentPage: nextPage,
      );
    } catch (e) {
      debugPrint('[ChatNotifier] Erro ao carregar mais mensagens: $e');
      state = state.copyWith(
        isLoadingMore: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Envia uma mensagem de texto.
  Future<void> enviarTexto(String texto) async {
    if (texto.trim().isEmpty) return;

    state = state.copyWith(isSending: true, clearError: true);

    try {
      final mensagem = await _repository.enviarMensagem(loteId, {
        'type': 'text',
        'content': texto.trim(),
      });

      state = state.copyWith(
        mensagens: [mensagem, ...state.mensagens],
        isSending: false,
      );
    } catch (e) {
      debugPrint('[ChatNotifier] Erro ao enviar mensagem: $e');
      state = state.copyWith(
        isSending: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Envia uma foto (upload + mensagem).
  ///
  /// [mediaUrl] URL retornada pelo endpoint de upload.
  Future<void> enviarFoto(String mediaUrl) async {
    state = state.copyWith(isSending: true, clearError: true);

    try {
      final mensagem = await _repository.enviarMensagem(loteId, {
        'type': 'photo',
        'media_url': mediaUrl,
      });

      state = state.copyWith(
        mensagens: [mensagem, ...state.mensagens],
        isSending: false,
      );
    } catch (e) {
      debugPrint('[ChatNotifier] Erro ao enviar foto: $e');
      state = state.copyWith(
        isSending: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Envia um audio (upload + mensagem).
  ///
  /// [mediaUrl] URL retornada pelo endpoint de upload.
  Future<void> enviarAudio(String mediaUrl) async {
    state = state.copyWith(isSending: true, clearError: true);

    try {
      final mensagem = await _repository.enviarMensagem(loteId, {
        'type': 'audio',
        'media_url': mediaUrl,
      });

      state = state.copyWith(
        mensagens: [mensagem, ...state.mensagens],
        isSending: false,
      );
    } catch (e) {
      debugPrint('[ChatNotifier] Erro ao enviar audio: $e');
      state = state.copyWith(
        isSending: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Marca as mensagens como lidas no servidor.
  Future<void> marcarComoLida() async {
    try {
      await _repository.marcarComoLida(loteId);
    } catch (e) {
      debugPrint('[ChatNotifier] Erro ao marcar como lida: $e');
    }
  }

  /// Adiciona uma mensagem recebida via WebSocket.
  void onMensagemRecebida(Mensagem mensagem) {
    // Evitar duplicatas
    final exists = state.mensagens.any((m) => m.id == mensagem.id);
    if (exists) return;

    state = state.copyWith(
      mensagens: [mensagem, ...state.mensagens],
    );
  }

  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}

// ── Provider family ─────────────────────────────────────────────────────

/// Provider do [ChatNotifier] parametrizado por loteId.
///
/// Cada chat tem sua propria instancia de estado.
final chatProvider =
    StateNotifierProvider.family<ChatNotifier, ChatState, String>(
  (ref, loteId) {
    final repository = ref.watch(chatRepositoryProvider);
    return ChatNotifier(repository: repository, loteId: loteId);
  },
);
