import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/whatsapp_utils.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist_item.dart';
import 'package:egranja_flutter/features/checklist/presentation/providers/checklist_provider.dart';
import 'package:egranja_flutter/features/config/presentation/providers/whatsapp_config_provider.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';

/// Tela de Checklist Diario de Manejo.
///
/// Exibe os itens de verificacao diaria com barra de progresso,
/// navegacao por data, toggle de itens, e suporte a observacoes
/// e fotos por item.
class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key, this.loteId = ''});

  /// ID do lote. Quando vazio, exibe seletor de lote.
  final String loteId;

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  static final _displayDateFormat = DateFormat('dd/MM/yyyy');

  late String _selectedLoteId;

  /// Indice do item com detalhes expandidos (-1 = nenhum).
  int _expandedIndex = -1;

  /// Controller para o campo de observacao do item expandido.
  final _obsController = TextEditingController();

  /// Picker de imagens.
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _selectedLoteId = widget.loteId;
    // Fetch lotes list for the dropdown
    Future.microtask(() {
      ref.read(homeProvider.notifier).fetchLotes();
    });
    // If we already have a loteId, fetch data
    if (_selectedLoteId.isNotEmpty) {
      Future.microtask(() {
        ref.read(checklistProvider(_selectedLoteId).notifier).fetchChecklist();
      });
    }
  }

  @override
  void dispose() {
    _obsController.dispose();
    super.dispose();
  }

  void _onLoteChanged(String loteId) {
    setState(() {
      _selectedLoteId = loteId;
      _expandedIndex = -1;
    });
    if (loteId.isNotEmpty) {
      ref.read(checklistProvider(loteId).notifier).fetchChecklist();
    }
  }

  void _toggleExpanded(int index, ChecklistItem item) {
    setState(() {
      if (_expandedIndex == index) {
        _expandedIndex = -1;
      } else {
        _expandedIndex = index;
        _obsController.text = item.observacao ?? '';
      }
    });
  }

  Future<void> _pickPhoto(int index) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galeria'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    final xFile = await _picker.pickImage(
      source: source,
      maxWidth: 1280,
      maxHeight: 1280,
      imageQuality: 80,
    );
    if (xFile == null || !mounted) return;

    // Upload the file via apiUpload
    try {
      final api = ref.read(apiClientProvider);
      final result = await api.apiUpload(
        xFile.path,
        'image/jpeg',
        xFile.name,
      );
      final url = result.data['url'] as String?;
      if (url != null && url.isNotEmpty && mounted) {
        ref.read(checklistProvider(_selectedLoteId).notifier).updateItemDetails(
              index,
              fotoUrl: url,
            );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao enviar foto: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  void _saveObservacao(int index) {
    final text = _obsController.text.trim();
    ref.read(checklistProvider(_selectedLoteId).notifier).updateItemDetails(
          index,
          observacao: text.isEmpty ? null : text,
        );
    setState(() => _expandedIndex = -1);
  }

  void _viewPhoto(String url) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    url,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const SizedBox(
                      height: 200,
                      child: Center(child: Icon(Icons.broken_image, size: 48)),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: AppColors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.black.withAlpha(120),
                    ),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _deletePhoto(int index) {
    ref.read(checklistProvider(_selectedLoteId).notifier).updateItemDetails(
          index,
          clearFoto: true,
        );
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);

    // Auto-select first lote if none selected
    final lotes = homeState.lotesAtivos;
    if (_selectedLoteId.isEmpty && lotes.isNotEmpty) {
      Future.microtask(() {
        _onLoteChanged(lotes.first.id);
      });
    }

    // Listen for success messages
    if (_selectedLoteId.isNotEmpty) {
      ref.listen<ChecklistState>(
        checklistProvider(_selectedLoteId),
        (previous, next) {
          if (next.successMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.successMessage!),
                backgroundColor: AppColors.success,
                duration: const Duration(seconds: 2),
              ),
            );
            ref
                .read(checklistProvider(_selectedLoteId).notifier)
                .clearSuccess();
          }
        },
      );
    }

    return Column(
      children: [
        // Date selector (shown when a lote is selected)
        if (_selectedLoteId.isNotEmpty)
          _buildDateSelector(
              ref.watch(checklistProvider(_selectedLoteId)), theme),

        // Seletor de lote
        _buildLoteSelector(homeState, theme),

        // Conteudo
        Expanded(
          child: _selectedLoteId.isEmpty
              ? const EmptyState(
                  icon: Icons.check_box_outline_blank,
                  titulo: 'Selecione um lote',
                  descricao:
                      'Selecione um lote ativo para ver o checklist do dia.',
                )
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(checklistProvider(_selectedLoteId).notifier)
                      .fetchChecklist(),
                  child: _buildBody(
                    ref.watch(checklistProvider(_selectedLoteId)),
                    theme,
                  ),
                ),
        ),
      ],
    );
  }

  // ── Seletor de lote ───────────────────────────────────────────────────

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
        onSelect: (option) => _onLoteChanged(option.value),
      ),
    );
  }

  // ── Seletor de data ────────────────────────────────────────────────────

  Widget _buildDateSelector(ChecklistState state, ThemeData theme) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selected = DateTime(
      state.selectedDate.year,
      state.selectedDate.month,
      state.selectedDate.day,
    );
    final canGoNext = selected.isBefore(today);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              ref
                  .read(checklistProvider(_selectedLoteId).notifier)
                  .previousDay();
              setState(() => _expandedIndex = -1);
            },
            tooltip: 'Dia anterior',
          ),
          GestureDetector(
            onTap: () => _showDatePicker(state),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 18,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
                const SizedBox(width: 8),
                Text(
                  _displayDateFormat.format(state.selectedDate),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.isToday) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Hoje',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: canGoNext
                ? () {
                    ref
                        .read(checklistProvider(_selectedLoteId).notifier)
                        .nextDay();
                    setState(() => _expandedIndex = -1);
                  }
                : null,
            tooltip: 'Proximo dia',
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(ChecklistState state) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: state.selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      locale: const Locale('pt', 'BR'),
    );
    if (picked != null && mounted) {
      ref
          .read(checklistProvider(_selectedLoteId).notifier)
          .selectDate(picked);
      setState(() => _expandedIndex = -1);
    }
  }

  // ── Body ────────────────────────────────────────────────────────────────

  Widget _buildBody(ChecklistState state, ThemeData theme) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () {
          ref
              .read(checklistProvider(_selectedLoteId).notifier)
              .fetchChecklist();
        },
      );
    }

    if (state.checklist == null || state.checklist!.itens.isEmpty) {
      return ListView(
        children: const [
          SizedBox(height: 48),
          EmptyState(
            icon: Icons.check_box_outline_blank,
            titulo: 'Nenhum checklist',
            descricao:
                'Nao ha checklist disponivel para esta data. '
                'Selecione outra data ou verifique o lote.',
          ),
        ],
      );
    }

    return _buildChecklistContent(state, theme);
  }

  // ── Conteudo do checklist ──────────────────────────────────────────────

  Widget _buildChecklistContent(ChecklistState state, ThemeData theme) {
    final checklist = state.checklist!;

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Barra de progresso
        _buildProgressSection(state, theme),

        // Itens
        ...checklist.itens
            .asMap()
            .entries
            .map((entry) =>
                _buildChecklistItem(entry.key, entry.value, state, theme)),
      ],
    );
  }

  // ── Progresso ──────────────────────────────────────────────────────────

  Widget _buildProgressSection(ChecklistState state, ThemeData theme) {
    final fraction = state.progressFraction;
    final isComplete = fraction >= 1.0;
    final progressColor = isComplete
        ? AppColors.success
        : fraction >= 0.8
            ? AppColors.warning
            : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isComplete ? AppColors.successLight : theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: isComplete
            ? Border.all(color: AppColors.success.withAlpha(100), width: 2)
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progresso',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: isComplete
                      ? AppColors.success
                      : theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${state.progressText} (${(fraction * 100).round()}%)',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isComplete ? AppColors.success : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.gray200,
              color: progressColor,
              minHeight: 12,
            ),
          ),
          if (isComplete) ...[
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.check_circle,
                    color: AppColors.success, size: 24),
                const SizedBox(width: 8),
                Text(
                  'Checklist completo! Bom trabalho!',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildWhatsAppShareButton(state, theme),
          ],
        ],
      ),
    );
  }

  // ── Compartilhar via WhatsApp ──────────────────────────────────────────

  Widget _buildWhatsAppShareButton(ChecklistState state, ThemeData theme) {
    final whatsappPhone = ref.watch(whatsappConfigProvider).phone;
    if (whatsappPhone.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => _compartilharChecklist(state),
        icon: const Icon(Icons.chat, size: 20),
        label: const Text('Compartilhar via WhatsApp'),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.success,
          side: const BorderSide(color: AppColors.success),
        ),
      ),
    );
  }

  Future<void> _compartilharChecklist(ChecklistState state) async {
    final whatsappPhone = ref.read(whatsappConfigProvider).phone;
    if (whatsappPhone.isEmpty || state.checklist == null) return;

    final homeState = ref.read(homeProvider);
    final lote = homeState.lotesAtivos.where(
      (l) => l.id == _selectedLoteId,
    );
    final galpaoNome = lote.isNotEmpty
        ? lote.first.galpaoNome
        : 'Galpao';

    final checklist = state.checklist!;
    final dataDisplay = _displayDateFormat.format(state.selectedDate);

    final itensDescricao = checklist.itens
        .map((item) => (
              descricao: item.descricao,
              completado: item.completado,
            ))
        .toList();

    final message = WhatsAppUtils.formatarChecklist(
      galpaoNome: galpaoNome,
      data: dataDisplay,
      completados: checklist.itensCompletados,
      total: checklist.totalItens,
      itensDescricao: itensDescricao,
    );

    final sent = await WhatsAppUtils.compartilhar(
      phone: whatsappPhone,
      message: message,
    );

    if (!sent && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Nao foi possivel abrir o WhatsApp.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ── Item do checklist ──────────────────────────────────────────────────

  Widget _buildChecklistItem(
    int index,
    ChecklistItem item,
    ChecklistState state,
    ThemeData theme,
  ) {
    final isEnabled = state.isToday && !state.isTogglingItem;
    final isExpanded = _expandedIndex == index;
    final hasDetails =
        (item.observacao != null && item.observacao!.isNotEmpty) ||
            (item.fotoUrl != null && item.fotoUrl!.isNotEmpty);

    return Column(
      children: [
        Material(
          color: item.completado
              ? AppColors.successLight
              : theme.colorScheme.surface,
          child: Column(
            children: [
              InkWell(
                onTap: isEnabled
                    ? () {
                        ref
                            .read(checklistProvider(_selectedLoteId).notifier)
                            .toggleItem(index, !item.completado);
                      }
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      // Checkbox grande (48x48 touch target minimo)
                      SizedBox(
                        width: 48,
                        height: 48,
                        child: Checkbox(
                          value: item.completado,
                          onChanged: isEnabled
                              ? (value) {
                                  if (value != null) {
                                    ref
                                        .read(checklistProvider(_selectedLoteId)
                                            .notifier)
                                        .toggleItem(index, value);
                                  }
                                }
                              : null,
                          activeColor: AppColors.success,
                          materialTapTargetSize: MaterialTapTargetSize.padded,
                          visualDensity: VisualDensity.standard,
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Descricao
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.descricao,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                decoration: item.completado
                                    ? TextDecoration.lineThrough
                                    : null,
                                color: item.completado
                                    ? AppColors.success
                                    : theme.colorScheme.onSurface,
                              ),
                            ),
                            // Indicator for attached details
                            if (hasDetails && !isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: Row(
                                  children: [
                                    if (item.observacao != null &&
                                        item.observacao!.isNotEmpty) ...[
                                      Icon(
                                        Icons.notes,
                                        size: 14,
                                        color: AppColors.gray500,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    if (item.fotoUrl != null &&
                                        item.fotoUrl!.isNotEmpty) ...[
                                      Icon(
                                        Icons.photo,
                                        size: 14,
                                        color: AppColors.gray500,
                                      ),
                                      const SizedBox(width: 4),
                                    ],
                                    Text(
                                      'Detalhes anexados',
                                      style:
                                          theme.textTheme.labelSmall?.copyWith(
                                        color: AppColors.gray500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                      // Camera icon - quick photo attach
                      if (isEnabled)
                        IconButton(
                          icon: Icon(
                            Icons.camera_alt_outlined,
                            color: item.fotoUrl != null
                                ? AppColors.success
                                : AppColors.gray400,
                            size: 20,
                          ),
                          onPressed: () => _pickPhoto(index),
                          tooltip: 'Anexar foto',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      // Expand/collapse toggle
                      IconButton(
                        icon: Icon(
                          isExpanded
                              ? Icons.expand_less
                              : Icons.expand_more,
                          color: AppColors.gray500,
                          size: 20,
                        ),
                        onPressed: () => _toggleExpanded(index, item),
                        tooltip:
                            isExpanded ? 'Ocultar detalhes' : 'Ver detalhes',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                      ),
                      // Check icon
                      if (item.completado)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 20,
                        ),
                    ],
                  ),
                ),
              ),

              // ── Expanded Details Section ────────────────────────────
              if (isExpanded)
                _buildDetailsSection(index, item, state, theme),
            ],
          ),
        ),
        const Divider(height: 1, indent: 64),
      ],
    );
  }

  /// Secao expansivel de detalhes (observacao + foto).
  Widget _buildDetailsSection(
    int index,
    ChecklistItem item,
    ChecklistState state,
    ThemeData theme,
  ) {
    final isEnabled = state.isToday;

    return Container(
      padding: const EdgeInsets.fromLTRB(64, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 8),

          // Observacao
          Text(
            'Observacao',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          if (isEnabled)
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _obsController,
                    decoration: InputDecoration(
                      hintText: 'Adicionar observacao...',
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium,
                    maxLines: 2,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => _saveObservacao(index),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.check, color: AppColors.success),
                  onPressed: () => _saveObservacao(index),
                  tooltip: 'Salvar observacao',
                ),
              ],
            )
          else if (item.observacao != null && item.observacao!.isNotEmpty)
            Text(
              item.observacao!,
              style: theme.textTheme.bodyMedium,
            )
          else
            Text(
              'Nenhuma observacao.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.gray400,
                fontStyle: FontStyle.italic,
              ),
            ),

          const SizedBox(height: 12),

          // Foto
          Text(
            'Foto',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          if (item.fotoUrl != null && item.fotoUrl!.isNotEmpty)
            GestureDetector(
              onTap: () => _viewPhoto(item.fotoUrl!),
              onLongPress: isEnabled
                  ? () => _showPhotoOptions(index, item.fotoUrl!)
                  : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        item.fotoUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Container(
                          color: AppColors.gray200,
                          child: const Icon(
                            Icons.broken_image,
                            color: AppColors.gray500,
                          ),
                        ),
                      ),
                      if (isEnabled)
                        Positioned(
                          top: 4,
                          right: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.black.withAlpha(120),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: AppColors.white,
                                size: 18,
                              ),
                              padding: const EdgeInsets.all(4),
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed: () => _deletePhoto(index),
                              tooltip: 'Remover foto',
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            )
          else if (isEnabled)
            OutlinedButton.icon(
              onPressed: () => _pickPhoto(index),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Anexar foto'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.gray600,
              ),
            )
          else
            Text(
              'Nenhuma foto anexada.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.gray400,
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }

  void _showPhotoOptions(int index, String url) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.fullscreen),
              title: const Text('Ver em tela cheia'),
              onTap: () {
                Navigator.pop(ctx);
                _viewPhoto(url);
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.delete_outline, color: AppColors.danger),
              title: const Text(
                'Remover foto',
                style: TextStyle(color: AppColors.danger),
              ),
              onTap: () {
                Navigator.pop(ctx);
                _deletePhoto(index);
              },
            ),
          ],
        ),
      ),
    );
  }
}
