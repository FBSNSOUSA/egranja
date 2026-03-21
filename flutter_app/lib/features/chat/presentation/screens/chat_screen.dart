import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/solicitacao_card.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:egranja_flutter/features/chat/domain/entities/mensagem.dart';
import 'package:egranja_flutter/features/chat/presentation/providers/chat_provider.dart';

/// Tela de chat individual do eGranja.
///
/// Exibe mensagens em bolhas (esquerda para outros, direita para o
/// usuario atual), input de texto com botao de enviar, mensagens de
/// sistema centralizadas e SolicitacaoCard para solicitacoes formais.
/// Suporta paginacao via scroll para cima.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({
    super.key,
    required this.loteId,
    this.loteNome,
  });

  /// Identificador do lote associado a esta conversa.
  final String loteId;

  /// Nome do lote para exibir no AppBar.
  final String? loteNome;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final notifier = ref.read(chatProvider(widget.loteId).notifier);
      notifier.fetchMensagens();
      notifier.marcarComoLida();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Load more quando chegar perto do final da lista (mensagens mais antigas)
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(chatProvider(widget.loteId).notifier).loadMore();
    }
  }

  void _enviarMensagem() {
    final texto = _textController.text.trim();
    if (texto.isEmpty) return;

    ref.read(chatProvider(widget.loteId).notifier).enviarTexto(texto);
    _textController.clear();
    _focusNode.requestFocus();

    // Scroll para o inicio (mensagens mais recentes)
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider(widget.loteId));
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id ?? '';
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.loteNome ?? 'Chat'),
      ),
      body: Column(
        children: [
          // Mensagens
          Expanded(
            child: _buildMensagens(state, currentUserId, theme),
          ),

          // Input
          _buildInputBar(state, theme),
        ],
      ),
    );
  }

  Widget _buildMensagens(
    ChatState state,
    String currentUserId,
    ThemeData theme,
  ) {
    // Loading
    if (state.isLoading && state.mensagens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (state.error != null && state.mensagens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.error!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref
                      .read(chatProvider(widget.loteId).notifier)
                      .fetchMensagens();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty
    if (state.mensagens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 64,
                color: AppColors.gray400,
              ),
              const SizedBox(height: 16),
              Text(
                'Nenhuma mensagem ainda',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Envie a primeira mensagem para iniciar a conversa.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    // Messages list (reversed - newest at bottom visually,
    // but the list is reversed so index 0 is newest)
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: state.mensagens.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading more indicator
        if (index >= state.mensagens.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final mensagem = state.mensagens[index];
        final isMe = mensagem.remetenteId == currentUserId;

        // Date separator
        Widget? dateSeparator;
        if (index < state.mensagens.length - 1) {
          final next = state.mensagens[index + 1];
          if (!_sameDay(mensagem.createdAt, next.createdAt)) {
            dateSeparator = _buildDateSeparator(mensagem.createdAt, theme);
          }
        } else {
          // First message (oldest in view) always shows date
          dateSeparator = _buildDateSeparator(mensagem.createdAt, theme);
        }

        return Column(
          children: [
            ?dateSeparator,
            _buildMensagemItem(mensagem, isMe, theme),
          ],
        );
      },
    );
  }

  bool _sameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildDateSeparator(DateTime date, ThemeData theme) {
    final now = DateTime.now();
    String label;

    if (_sameDay(date, now)) {
      label = 'Hoje';
    } else if (_sameDay(date, now.subtract(const Duration(days: 1)))) {
      label = 'Ontem';
    } else {
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final ano = date.year;
      label = '$dia/$mes/$ano';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMensagemItem(
    Mensagem mensagem,
    bool isMe,
    ThemeData theme,
  ) {
    // Sistema: centralizada
    if (mensagem.tipo == MensagemTipo.sistema) {
      return _buildSystemMessage(mensagem, theme);
    }

    // Solicitacao: card especial
    if (mensagem.tipo == MensagemTipo.solicitacao) {
      return _buildSolicitacaoMessage(mensagem, theme);
    }

    // Mensagens normais (texto, foto, audio)
    return _buildBubbleMessage(mensagem, isMe, theme);
  }

  Widget _buildSystemMessage(Mensagem mensagem, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.gray100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            mensagem.conteudo,
            style: theme.textTheme.bodySmall?.copyWith(
              color: AppColors.textSecondary,
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _buildSolicitacaoMessage(Mensagem mensagem, ThemeData theme) {
    // Parse prazo from content or use a default
    DateTime prazo;
    try {
      prazo = DateTime.parse(mensagem.conteudo);
    } catch (_) {
      prazo = mensagem.createdAt.add(const Duration(days: 7));
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: SolicitacaoCard(
          titulo: 'Solicitacao',
          descricao: mensagem.conteudo,
          prazo: prazo,
          status: SolicitacaoStatus.pendente,
        ),
      ),
    );
  }

  Widget _buildBubbleMessage(
    Mensagem mensagem,
    bool isMe,
    ThemeData theme,
  ) {
    final hora = mensagem.createdAt.hour.toString().padLeft(2, '0');
    final minuto = mensagem.createdAt.minute.toString().padLeft(2, '0');
    final timeStr = '$hora:$minuto';

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: const EdgeInsets.symmetric(vertical: 3),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            // Nome do remetente (apenas para mensagens de outros)
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(left: 12, bottom: 2),
                child: Text(
                  mensagem.remetenteNome,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

            // Bolha
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: isMe ? AppColors.secondary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                  bottomRight: Radius.circular(isMe ? 4 : 16),
                ),
                boxShadow: isMe
                    ? null
                    : [
                        BoxShadow(
                          color: AppColors.black.withAlpha(13),
                          blurRadius: 2,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Conteudo
                  _buildMessageContent(mensagem, isMe, theme),

                  const SizedBox(height: 2),

                  // Hora
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: isMe
                          ? AppColors.white.withAlpha(179)
                          : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(
    Mensagem mensagem,
    bool isMe,
    ThemeData theme,
  ) {
    switch (mensagem.tipo) {
      case MensagemTipo.foto:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder para foto
            Container(
              height: 150,
              width: 200,
              decoration: BoxDecoration(
                color: AppColors.gray200,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Icon(
                  Icons.image_outlined,
                  size: 48,
                  color: AppColors.gray500,
                ),
              ),
            ),
            if (mensagem.conteudo.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                mensagem.conteudo,
                style: TextStyle(
                  fontSize: 14,
                  color: isMe ? AppColors.textOnSecondary : AppColors.textPrimary,
                ),
              ),
            ],
          ],
        );

      case MensagemTipo.audio:
        // Placeholder para audio
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.play_circle_filled,
              size: 32,
              color: isMe ? AppColors.textOnSecondary : AppColors.primary,
            ),
            const SizedBox(width: 8),
            // Waveform placeholder
            ...List.generate(
              7,
              (i) => Container(
                width: 3,
                height: [12.0, 20.0, 16.0, 24.0, 14.0, 18.0, 10.0][i],
                margin: const EdgeInsets.symmetric(horizontal: 1),
                decoration: BoxDecoration(
                  color: isMe
                      ? AppColors.textOnSecondary.withAlpha(179)
                      : AppColors.gray400,
                  borderRadius: BorderRadius.circular(1.5),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              'Audio',
              style: TextStyle(
                fontSize: 12,
                color: isMe ? AppColors.textOnSecondary : AppColors.textSecondary,
              ),
            ),
          ],
        );

      case MensagemTipo.texto:
      case MensagemTipo.sistema:
      case MensagemTipo.solicitacao:
        return Text(
          mensagem.conteudo,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? AppColors.textOnSecondary : AppColors.textPrimary,
          ),
        );
    }
  }

  Widget _buildInputBar(ChatState state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Botoes de acao (placeholder para foto e audio)
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              color: AppColors.gray600,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Envio de fotos sera implementado em breve.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Enviar foto',
            ),
            IconButton(
              icon: const Icon(Icons.mic_outlined),
              color: AppColors.gray600,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content:
                        Text('Gravacao de audio sera implementada em breve.'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
              tooltip: 'Gravar audio',
            ),

            // Campo de texto
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                decoration: InputDecoration(
                  hintText: 'Digite sua mensagem...',
                  hintStyle: TextStyle(color: AppColors.gray500),
                  filled: true,
                  fillColor: AppColors.gray100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _enviarMensagem(),
              ),
            ),

            const SizedBox(width: 4),

            // Botao de enviar
            IconButton(
              icon: state.isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              color: theme.colorScheme.primary,
              onPressed: state.isSending ? null : _enviarMensagem,
              tooltip: 'Enviar',
            ),
          ],
        ),
      ),
    );
  }
}
