import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/chat/data/repositories/chat_repository_impl.dart';
import 'package:egranja_flutter/features/chat/domain/entities/conversa.dart';
import 'package:egranja_flutter/features/chat/domain/repositories/chat_repository.dart';

// ── Repositorio ─────────────────────────────────────────────────────────

/// Provider do [ChatRepository].
final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return ChatRepositoryImpl(apiClient: apiClient);
});

// ── Estado ──────────────────────────────────────────────────────────────

/// Estado imutavel da lista de conversas.
class ConversaListState {
  final List<Conversa> conversas;
  final bool isLoading;
  final String? error;

  const ConversaListState({
    this.conversas = const [],
    this.isLoading = false,
    this.error,
  });

  ConversaListState copyWith({
    List<Conversa>? conversas,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return ConversaListState(
      conversas: conversas ?? this.conversas,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversaListState &&
          runtimeType == other.runtimeType &&
          conversas == other.conversas &&
          isLoading == other.isLoading &&
          error == other.error;

  @override
  int get hashCode => Object.hash(conversas, isLoading, error);
}

// ── Notifier ────────────────────────────────────────────────────────────

/// Gerenciador de estado da lista de conversas.
///
/// Carrega conversas do servidor e escuta eventos WebSocket
/// para atualizar a lista em tempo real.
class ConversaListNotifier extends StateNotifier<ConversaListState> {
  final ChatRepository _repository;

  ConversaListNotifier({required ChatRepository repository})
      : _repository = repository,
        super(const ConversaListState());

  /// Carrega a lista de conversas do servidor.
  Future<void> fetchConversas() async {
    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final conversas = await _repository.fetchConversas();
      if (!mounted) return;
      // Ordenar por mais recente
      conversas.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = state.copyWith(
        conversas: conversas,
        isLoading: false,
      );
    } catch (e) {
      debugPrint('[ConversaListNotifier] Erro ao buscar conversas: $e');
      if (!mounted) return;
      state = state.copyWith(
        isLoading: false,
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Recarrega as conversas (pull-to-refresh).
  Future<void> refresh() async {
    try {
      final conversas = await _repository.fetchConversas();
      if (!mounted) return;
      conversas.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
      state = ConversaListState(conversas: conversas);
    } catch (e) {
      debugPrint('[ConversaListNotifier] Erro ao recarregar conversas: $e');
      if (!mounted) return;
      state = state.copyWith(
        error: _extractErrorMessage(e),
      );
    }
  }

  /// Atualiza a lista quando uma nova mensagem chega via WebSocket.
  ///
  /// Move a conversa do [loteId] para o topo da lista com a nova
  /// mensagem como preview e incrementa o contador de nao lidas.
  void onNewMessage({
    required String loteId,
    required String mensagemPreview,
    required String tipo,
    String? participanteNome,
  }) {
    final conversas = List<Conversa>.from(state.conversas);
    final index = conversas.indexWhere((c) => c.loteId == loteId);

    if (index >= 0) {
      final existing = conversas.removeAt(index);
      final updated = Conversa(
        loteId: existing.loteId,
        loteNome: existing.loteNome,
        galpaoNome: existing.galpaoNome,
        ultimaMensagem: mensagemPreview,
        ultimaMensagemTipo: tipo,
        naoLidas: existing.naoLidas + 1,
        updatedAt: DateTime.now(),
        temPendencia: existing.temPendencia,
        participanteNome: participanteNome ?? existing.participanteNome,
      );
      conversas.insert(0, updated);
    }

    state = state.copyWith(conversas: conversas);
  }

  /// Marca uma conversa como lida (zera badge).
  void marcarComoLida(String loteId) {
    final conversas = state.conversas.map((c) {
      if (c.loteId == loteId) {
        return Conversa(
          loteId: c.loteId,
          loteNome: c.loteNome,
          galpaoNome: c.galpaoNome,
          ultimaMensagem: c.ultimaMensagem,
          ultimaMensagemTipo: c.ultimaMensagemTipo,
          naoLidas: 0,
          updatedAt: c.updatedAt,
          temPendencia: c.temPendencia,
          participanteNome: c.participanteNome,
        );
      }
      return c;
    }).toList();

    state = state.copyWith(conversas: conversas);
  }

  String _extractErrorMessage(Object error) {
    if (error is Exception) {
      return error.toString().replaceFirst('Exception: ', '');
    }
    return 'Ocorreu um erro inesperado. Tente novamente.';
  }
}

// ── Provider principal ──────────────────────────────────────────────────

/// Provider do [ConversaListNotifier] e seu [ConversaListState].
final conversaListProvider =
    StateNotifierProvider<ConversaListNotifier, ConversaListState>((ref) {
  final repository = ref.watch(chatRepositoryProvider);
  return ConversaListNotifier(repository: repository);
});
