import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';
import 'package:egranja_flutter/features/ia/domain/entities/ia_mensagem.dart';
import 'package:egranja_flutter/features/ia/presentation/providers/ia_assistente_provider.dart';

/// Tela do assistente IA do eGranja.
///
/// Exibe um chat com a IA, bolhas de mensagem (esquerda para IA
/// com avatar de robo, direita para usuario), campo de texto
/// para perguntas e sugestoes rapidas quando nao ha mensagens.
class IAAssistenteScreen extends ConsumerStatefulWidget {
  const IAAssistenteScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<IAAssistenteScreen> createState() =>
      _IAAssistenteScreenState();
}

class _IAAssistenteScreenState extends ConsumerState<IAAssistenteScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  late String _selectedLoteId;

  static const _sugestoes = [
    'Como melhorar o ICA?',
    'Qual a mortalidade ideal?',
    'Analise o ganho de peso',
    'Dicas de manejo para calor',
  ];

  @override
  void initState() {
    super.initState();
    _selectedLoteId = widget.loteId;
    if (_selectedLoteId.isNotEmpty) {
      Future.microtask(() {
        ref
            .read(iaAssistenteProvider(_selectedLoteId).notifier)
            .carregarHistorico();
      });
    }
    Future.microtask(() {
      ref.read(homeProvider.notifier).fetchLotes();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  void _enviarMensagem([String? texto]) {
    final pergunta = texto ?? _textController.text.trim();
    if (pergunta.isEmpty || _selectedLoteId.isEmpty) return;

    ref
        .read(iaAssistenteProvider(_selectedLoteId).notifier)
        .enviarMensagem(pergunta);
    _textController.clear();
    _focusNode.requestFocus();
    _scrollToBottom();
  }

  void _onLoteChanged(String loteId) {
    setState(() {
      _selectedLoteId = loteId;
    });
    if (loteId.isNotEmpty) {
      ref
          .read(iaAssistenteProvider(loteId).notifier)
          .carregarHistorico();
    }
  }

  @override
  Widget build(BuildContext context) {
    final iaState = _selectedLoteId.isNotEmpty
        ? ref.watch(iaAssistenteProvider(_selectedLoteId))
        : const IAAssistenteState();
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);

    // Scroll to bottom when new messages arrive
    ref.listen(
      _selectedLoteId.isNotEmpty
          ? iaAssistenteProvider(_selectedLoteId)
          : iaAssistenteProvider(''),
      (previous, next) {
        if (previous != null &&
            next.mensagens.length > previous.mensagens.length) {
          _scrollToBottom();
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistente IA'),
        backgroundColor: AppColors.secondary,
        foregroundColor: AppColors.white,
      ),
      body: Column(
        children: [
          // Seletor de lote
          _buildLoteSelector(homeState, theme),

          // Mensagens ou estado vazio
          Expanded(
            child: _selectedLoteId.isEmpty
                ? _buildSelectLotePrompt(theme)
                : _buildMessages(iaState, theme),
          ),

          // Input
          _buildInputBar(iaState, theme),
        ],
      ),
    );
  }

  Widget _buildLoteSelector(HomeState homeState, ThemeData theme) {
    final lotes = homeState.lotesAtivos;
    final options = lotes
        .map((l) => DropdownOption(
              value: l.id,
              label: '${l.galpaoNome} - Dia ${l.diasDeVida ?? 0}',
              subtitle: 'Alojado: ${l.dataAlojamento}',
            ))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: DropdownField(
        label: 'Lote',
        value: _selectedLoteId.isNotEmpty ? _selectedLoteId : null,
        options: options,
        placeholder: 'Selecione um lote...',
        searchable: true,
        onSelect: (option) => _onLoteChanged(option.value),
      ),
    );
  }

  Widget _buildSelectLotePrompt(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 36,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecione um lote',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha um lote para conversar com o assistente IA.',
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

  Widget _buildMessages(IAAssistenteState state, ThemeData theme) {
    // Loading
    if (state.isCarregandoHistorico && state.mensagens.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // Error
    if (state.errorMessage != null && state.mensagens.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref
                      .read(
                          iaAssistenteProvider(_selectedLoteId).notifier)
                      .carregarHistorico();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty - welcome card with suggestions
    if (state.mensagens.isEmpty) {
      return _buildWelcomeCard(theme);
    }

    // Messages list
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      itemCount: state.mensagens.length + (state.isEnviando ? 1 : 0),
      itemBuilder: (context, index) {
        // Loading indicator at the end
        if (index >= state.mensagens.length) {
          return _buildTypingIndicator(theme);
        }

        final mensagem = state.mensagens[index];
        final isUser = mensagem.remetente == 'usuario';

        return _buildMessageBubble(mensagem, isUser, theme);
      },
    );
  }

  Widget _buildWelcomeCard(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const SizedBox(height: 32),

          // Robot avatar
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 40,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: 20),

          // Title
          Text(
            'Assistente IA eGranja',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.secondary,
            ),
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'Tire duvidas sobre o manejo do seu lote, analise indicadores '
            'e receba recomendacoes personalizadas baseadas nos dados reais.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Quick suggestion chips
          Text(
            'Sugestoes rapidas:',
            style: theme.textTheme.titleSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: _sugestoes.map((sugestao) {
              return ActionChip(
                avatar: const Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: AppColors.secondary,
                ),
                label: Text(sugestao),
                labelStyle: TextStyle(
                  color: AppColors.secondary,
                  fontSize: 13,
                ),
                backgroundColor: AppColors.secondary.withAlpha(20),
                side: BorderSide(color: AppColors.secondary.withAlpha(60)),
                onPressed: () => _enviarMensagem(sugestao),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(
    IAMensagem mensagem,
    bool isUser,
    ThemeData theme,
  ) {
    final hora = mensagem.timestamp.hour.toString().padLeft(2, '0');
    final minuto = mensagem.timestamp.minute.toString().padLeft(2, '0');
    final timeStr = '$hora:$minuto';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // IA avatar
          if (!isUser) ...[
            Container(
              width: 32,
              height: 32,
              margin: const EdgeInsets.only(top: 4),
              decoration: const BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 18,
                color: AppColors.white,
              ),
            ),
            const SizedBox(width: 8),
          ],

          // Bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isUser ? AppColors.secondary : AppColors.surface,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: isUser
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Content with simple markdown
                  _buildMessageText(mensagem.texto, isUser, theme),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.bottomRight,
                    child: Text(
                      timeStr,
                      style: TextStyle(
                        fontSize: 11,
                        color: isUser
                            ? AppColors.white.withAlpha(179)
                            : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Renders text with simple markdown support for **bold** and bullet lists.
  Widget _buildMessageText(String text, bool isUser, ThemeData theme) {
    final baseColor = isUser ? AppColors.textOnSecondary : AppColors.textPrimary;
    final lines = text.split('\n');

    final children = <Widget>[];
    for (final line in lines) {
      if (line.trimLeft().startsWith('- ') ||
          line.trimLeft().startsWith('* ')) {
        // Bullet list item
        final content = line.trimLeft().substring(2);
        children.add(
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 2),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '\u2022 ',
                  style: TextStyle(fontSize: 14, color: baseColor),
                ),
                Expanded(
                  child: _buildRichText(content, baseColor),
                ),
              ],
            ),
          ),
        );
      } else {
        children.add(
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: _buildRichText(line, baseColor),
          ),
        );
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: children,
    );
  }

  /// Parses **bold** patterns in text and returns a RichText widget.
  Widget _buildRichText(String text, Color baseColor) {
    final spans = <TextSpan>[];
    final regex = RegExp(r'\*\*(.+?)\*\*');
    int lastEnd = 0;

    for (final match in regex.allMatches(text)) {
      // Text before the bold
      if (match.start > lastEnd) {
        spans.add(TextSpan(
          text: text.substring(lastEnd, match.start),
        ));
      }
      // Bold text
      spans.add(TextSpan(
        text: match.group(1),
        style: const TextStyle(fontWeight: FontWeight.bold),
      ));
      lastEnd = match.end;
    }

    // Remaining text after last bold
    if (lastEnd < text.length) {
      spans.add(TextSpan(
        text: text.substring(lastEnd),
      ));
    }

    // If no bold found, just return simple text
    if (spans.isEmpty) {
      spans.add(TextSpan(text: text));
    }

    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 14, color: baseColor, height: 1.4),
        children: spans,
      ),
    );
  }

  Widget _buildTypingIndicator(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.smart_toy,
              size: 18,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.black.withAlpha(13),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.secondary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Analisando...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.secondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar(IAAssistenteState state, ThemeData theme) {
    final canSend = _selectedLoteId.isNotEmpty && !state.isEnviando;

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
            // Campo de texto
            Expanded(
              child: TextField(
                controller: _textController,
                focusNode: _focusNode,
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                enabled: _selectedLoteId.isNotEmpty,
                decoration: InputDecoration(
                  hintText: _selectedLoteId.isNotEmpty
                      ? 'Pergunte algo sobre o lote...'
                      : 'Selecione um lote primeiro',
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
                onSubmitted: canSend ? (_) => _enviarMensagem() : null,
              ),
            ),

            const SizedBox(width: 4),

            // Botao de enviar
            IconButton(
              icon: state.isEnviando
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              color: AppColors.secondary,
              onPressed: canSend ? () => _enviarMensagem() : null,
              tooltip: 'Enviar',
            ),
          ],
        ),
      ),
    );
  }
}
