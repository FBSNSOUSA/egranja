import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';

import 'package:egranja_flutter/core/di/providers.dart';
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
/// Implementa envio de fotos (camera/galeria) e gravacao de audio.
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

  // ── Estado de gravacao de audio ──────────────────────────────────────
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  int _recordingSeconds = 0;
  Timer? _recordingTimer;
  String? _recordedAudioPath;

  // ── Estado de preview de foto ────────────────────────────────────────
  File? _selectedPhoto;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final notifier = ref.read(chatProvider(widget.loteId).notifier);
      await notifier.fetchMensagens();
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
    _recordingTimer?.cancel();
    _audioRecorder.dispose();
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
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // ── Foto ──────────────────────────────────────────────────────────────

  /// Exibe bottom sheet para escolher entre camera e galeria.
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.gray300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enviar foto',
              style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Tirar foto'),
              subtitle: const Text('Abrir a camera do dispositivo'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.photo_library, color: AppColors.tertiary),
              title: const Text('Escolher da galeria'),
              subtitle: const Text('Selecionar uma foto existente'),
              onTap: () {
                Navigator.pop(ctx);
                _pickPhoto(ImageSource.gallery);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  /// Seleciona uma foto e exibe preview.
  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;

      setState(() {
        _selectedPhoto = File(image.path);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao acessar ${source == ImageSource.camera ? 'camera' : 'galeria'}: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Faz upload da foto selecionada e envia como mensagem.
  Future<void> _enviarFoto() async {
    if (_selectedPhoto == null || _isUploading) return;

    setState(() => _isUploading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final ext = _selectedPhoto!.path.toLowerCase();
      final contentType = ext.endsWith('.png') ? 'image/png' : 'image/jpeg';
      final fileName = _selectedPhoto!.path.split('/').last;

      final response = await apiClient.apiUpload(
        _selectedPhoto!.path,
        contentType,
        fileName,
      );

      if (!mounted) return;

      final mediaUrl = response.data['url'] as String;
      await ref
          .read(chatProvider(widget.loteId).notifier)
          .enviarFoto(mediaUrl);

      setState(() {
        _selectedPhoto = null;
        _isUploading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao enviar foto. Tente novamente.'),
            backgroundColor: AppColors.danger,
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: AppColors.white,
              onPressed: _enviarFoto,
            ),
          ),
        );
      }
    }
  }

  /// Cancela o preview da foto selecionada.
  void _cancelarFoto() {
    setState(() {
      _selectedPhoto = null;
    });
  }

  // ── Audio ─────────────────────────────────────────────────────────────

  /// Inicia a gravacao de audio.
  Future<void> _iniciarGravacao() async {
    try {
      if (!await _audioRecorder.hasPermission()) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Permissao de microfone necessaria para gravar audio.'),
              backgroundColor: AppColors.warning,
            ),
          );
        }
        return;
      }

      final dir = await getTemporaryDirectory();
      final filePath =
          '${dir.path}/egranja_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          sampleRate: 44100,
          bitRate: 128000,
        ),
        path: filePath,
      );

      if (!mounted) return;

      setState(() {
        _isRecording = true;
        _recordingSeconds = 0;
        _recordedAudioPath = null;
      });

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() => _recordingSeconds++);
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao iniciar gravacao: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Para a gravacao e exibe preview.
  Future<void> _pararGravacao() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      final path = await _audioRecorder.stop();

      if (!mounted) return;

      if (path != null && path.isNotEmpty) {
        setState(() {
          _isRecording = false;
          _recordedAudioPath = path;
        });
      } else {
        setState(() {
          _isRecording = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRecording = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao parar gravacao: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  /// Cancela a gravacao em andamento.
  Future<void> _cancelarGravacao() async {
    _recordingTimer?.cancel();
    _recordingTimer = null;

    try {
      await _audioRecorder.stop();
    } catch (_) {
      // Ignorar erro ao cancelar
    }

    if (mounted) {
      setState(() {
        _isRecording = false;
        _recordingSeconds = 0;
        _recordedAudioPath = null;
      });
    }
  }

  /// Descarta o audio gravado (preview).
  void _descartarAudio() {
    if (_recordedAudioPath != null) {
      try {
        File(_recordedAudioPath!).deleteSync();
      } catch (_) {
        // Ignorar erro ao deletar arquivo temporario
      }
    }
    setState(() {
      _recordedAudioPath = null;
      _recordingSeconds = 0;
    });
  }

  /// Faz upload do audio gravado e envia como mensagem.
  Future<void> _enviarAudio() async {
    if (_recordedAudioPath == null || _isUploading) return;

    setState(() => _isUploading = true);

    try {
      final apiClient = ref.read(apiClientProvider);
      final fileName = _recordedAudioPath!.split('/').last;

      final response = await apiClient.apiUpload(
        _recordedAudioPath!,
        'audio/mp4',
        fileName,
      );

      if (!mounted) return;

      final mediaUrl = response.data['url'] as String;
      await ref
          .read(chatProvider(widget.loteId).notifier)
          .enviarAudio(mediaUrl);

      // Limpar arquivo temporario
      try {
        File(_recordedAudioPath!).deleteSync();
      } catch (_) {}

      setState(() {
        _recordedAudioPath = null;
        _recordingSeconds = 0;
        _isUploading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Erro ao enviar audio. Tente novamente.'),
            backgroundColor: AppColors.danger,
            action: SnackBarAction(
              label: 'Tentar novamente',
              textColor: AppColors.white,
              onPressed: _enviarAudio,
            ),
          ),
        );
      }
    }
  }

  /// Formata segundos em MM:SS.
  String _formatDuration(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chatProvider(widget.loteId));
    final authState = ref.watch(authNotifierProvider);
    final currentUserId = authState.user?.id ?? '';
    final theme = Theme.of(context);

    return Column(
      children: [
        // Mensagens
        Expanded(
          child: _buildMensagens(state, currentUserId, theme),
        ),

        // Preview de foto selecionada
        if (_selectedPhoto != null) _buildPhotoPreview(theme),

        // Preview de audio gravado
        if (_recordedAudioPath != null && !_isRecording)
          _buildAudioPreview(theme),

        // Barra de gravacao ativa
        if (_isRecording)
          _buildRecordingBar(theme)
        // Input normal
        else if (_selectedPhoto == null && _recordedAudioPath == null)
          _buildInputBar(state, theme),
      ],
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
    // Visita: centralizada (mensagem de visita tecnica)
    if (mensagem.tipo == MensagemTipo.visita) {
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
                color: isMe ? AppColors.primary : AppColors.surface,
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
                  color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
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
              color: isMe ? AppColors.textOnPrimary : AppColors.primary,
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
                      ? AppColors.textOnPrimary.withAlpha(179)
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
                color: isMe ? AppColors.textOnPrimary : AppColors.textSecondary,
              ),
            ),
          ],
        );

      case MensagemTipo.texto:
      case MensagemTipo.visita:
      case MensagemTipo.solicitacao:
        return Text(
          mensagem.conteudo,
          style: TextStyle(
            fontSize: 14,
            color: isMe ? AppColors.textOnPrimary : AppColors.textPrimary,
          ),
        );
    }
  }

  // ── Preview de foto ───────────────────────────────────────────────────

  Widget _buildPhotoPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Foto selecionada',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: _isUploading ? null : _cancelarFoto,
                  color: AppColors.gray600,
                  visualDensity: VisualDensity.compact,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Imagem
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                _selectedPhoto!,
                height: 200,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),

            // Botoes
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isUploading ? null : _cancelarFoto,
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _isUploading ? null : _enviarFoto,
                    icon: _isUploading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.white,
                            ),
                          )
                        : const Icon(Icons.send),
                    label: Text(
                      _isUploading ? 'Enviando...' : 'Enviar foto',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Preview de audio gravado ──────────────────────────────────────────

  Widget _buildAudioPreview(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: AppColors.divider),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Icone de audio
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mic,
                color: AppColors.white,
                size: 22,
              ),
            ),
            const SizedBox(width: 12),

            // Duracao
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Audio gravado',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    _formatDuration(_recordingSeconds),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Descartar
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: _isUploading ? null : _descartarAudio,
              color: AppColors.danger,
              tooltip: 'Descartar audio',
            ),

            // Enviar
            IconButton(
              icon: _isUploading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send),
              onPressed: _isUploading ? null : _enviarAudio,
              color: AppColors.primary,
              tooltip: 'Enviar audio',
            ),
          ],
        ),
      ),
    );
  }

  // ── Barra de gravacao ativa ───────────────────────────────────────────

  Widget _buildRecordingBar(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.dangerLight,
        border: Border(
          top: BorderSide(color: AppColors.danger.withAlpha(60)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Icone pulsante de gravacao
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeInOut,
              builder: (context, value, child) {
                return Opacity(
                  opacity: value,
                  child: child,
                );
              },
              onEnd: () {
                // Repetir a animacao manualmente nao e simples com TweenAnimationBuilder.
                // O icone vermelho ja transmite feedback suficiente.
              },
              child: Container(
                width: 12,
                height: 12,
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Timer
            Text(
              'Gravando  ${_formatDuration(_recordingSeconds)}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),

            const Spacer(),

            // Cancelar
            TextButton(
              onPressed: _cancelarGravacao,
              child: const Text(
                'Cancelar',
                style: TextStyle(color: AppColors.danger),
              ),
            ),

            // Parar e preview
            FilledButton.icon(
              onPressed: _pararGravacao,
              icon: const Icon(Icons.stop, size: 20),
              label: const Text('Parar'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: AppColors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Input bar normal ──────────────────────────────────────────────────

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
            // Botao de foto
            IconButton(
              icon: const Icon(Icons.camera_alt_outlined),
              color: AppColors.gray600,
              onPressed: state.isSending ? null : _showPhotoOptions,
              tooltip: 'Enviar foto',
            ),
            // Botao de audio
            IconButton(
              icon: const Icon(Icons.mic_outlined),
              color: AppColors.gray600,
              onPressed: state.isSending ? null : _iniciarGravacao,
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
