import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/features/checklist/domain/entities/checklist_item.dart';
import 'package:egranja_flutter/features/checklist/presentation/providers/checklist_provider.dart';

/// Tela de Checklist Diario de Manejo.
///
/// Exibe os itens de verificacao diaria agrupados por categoria,
/// com barra de progresso, navegacao por data e toggle de itens.
/// Portada do componente React Native `ChecklistScreen.tsx`.
class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key, this.loteId = ''});

  /// ID do lote. Quando vazio, exibe estado vazio com instrucoes.
  final String loteId;

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  static final _displayDateFormat = DateFormat('dd/MM/yyyy');
  static final _timeFormat = DateFormat('HH:mm');

  /// Mapa de observacoes em edicao (itemId -> texto).
  final Map<String, TextEditingController> _observationControllers = {};

  /// Item cujo campo de observacao esta expandido.
  String? _expandedItemId;

  @override
  void initState() {
    super.initState();
    if (widget.loteId.isNotEmpty) {
      Future.microtask(() {
        ref.read(checklistProvider(widget.loteId).notifier).fetchChecklist();
      });
    }
  }

  @override
  void dispose() {
    for (final controller in _observationControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.loteId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Checklist Diario')),
        body: const EmptyState(
          icon: Icons.check_box_outline_blank,
          titulo: 'Nenhum lote selecionado',
          descricao: 'Selecione um lote ativo para ver o checklist do dia.',
        ),
      );
    }

    final checklistState = ref.watch(checklistProvider(widget.loteId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: _buildAppBar(checklistState, theme),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(checklistProvider(widget.loteId).notifier).fetchChecklist(),
        child: _buildBody(checklistState, theme),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────────

  PreferredSizeWidget _buildAppBar(ChecklistState state, ThemeData theme) {
    return AppBar(
      title: const Text('Checklist Diario'),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: _buildDateSelector(state, theme),
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
                  .read(checklistProvider(widget.loteId).notifier)
                  .previousDay();
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
                        .read(checklistProvider(widget.loteId).notifier)
                        .nextDay();
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
      ref.read(checklistProvider(widget.loteId).notifier).selectDate(picked);
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
          ref.read(checklistProvider(widget.loteId).notifier).fetchChecklist();
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

    // Agrupar itens por categoria
    final groupedItems = <String, List<ChecklistItem>>{};
    for (final item in checklist.itens) {
      groupedItems.putIfAbsent(item.categoria, () => []).add(item);
    }

    // Ordenar categorias: geral primeiro, depois primeira_semana, pre_abate
    final sortedCategories = groupedItems.keys.toList()
      ..sort((a, b) => _categoriaOrder(a).compareTo(_categoriaOrder(b)));

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Barra de progresso
        _buildProgressSection(state, theme),

        // Itens agrupados por categoria
        ...sortedCategories.map((categoria) {
          return _buildCategoryGroup(
            categoria,
            groupedItems[categoria]!,
            state,
            theme,
          );
        }),
      ],
    );
  }

  // ── Progresso ──────────────────────────────────────────────────────────

  Widget _buildProgressSection(ChecklistState state, ThemeData theme) {
    final fraction = state.progressFraction;
    final progressColor = fraction >= 1.0
        ? AppColors.success
        : fraction >= 0.8
            ? AppColors.warning
            : theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
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
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '${state.progressText} (${(fraction * 100).round()}%)',
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: fraction,
              backgroundColor: AppColors.gray200,
              color: progressColor,
              minHeight: 8,
            ),
          ),
          if (fraction >= 1.0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                const SizedBox(width: 4),
                Text(
                  'Checklist completo!',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  // ── Grupo de categoria ─────────────────────────────────────────────────

  Widget _buildCategoryGroup(
    String categoria,
    List<ChecklistItem> items,
    ChecklistState state,
    ThemeData theme,
  ) {
    final label = _categoriaLabel(categoria);
    final icon = _categoriaIcon(categoria);
    final color = _categoriaColor(categoria);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header da categoria
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: color.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.where((i) => i.concluido).length}/${items.length}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Itens da categoria
        ...items.map((item) => _buildChecklistItem(item, state, theme)),
      ],
    );
  }

  // ── Item do checklist ──────────────────────────────────────────────────

  Widget _buildChecklistItem(
    ChecklistItem item,
    ChecklistState state,
    ThemeData theme,
  ) {
    final isExpanded = _expandedItemId == item.id;

    return Column(
      children: [
        Material(
          color: item.concluido
              ? AppColors.successLight
              : theme.colorScheme.surface,
          child: CheckboxListTile(
            value: item.concluido,
            onChanged: state.isToday && !state.isTogglingItem
                ? (value) {
                    if (value != null) {
                      final controller = _getOrCreateController(item.id);
                      ref
                          .read(checklistProvider(widget.loteId).notifier)
                          .toggleItem(
                            item.id,
                            value,
                            observacao: controller.text.isNotEmpty
                                ? controller.text
                                : null,
                          );
                    }
                  }
                : null,
            activeColor: AppColors.success,
            title: Text(
              item.descricao,
              style: theme.textTheme.bodyMedium?.copyWith(
                decoration:
                    item.concluido ? TextDecoration.lineThrough : null,
                color: item.concluido
                    ? AppColors.success
                    : theme.colorScheme.onSurface,
              ),
            ),
            subtitle: item.concluido && item.concluidoEm != null
                ? Text(
                    _formatTimestamp(item.concluidoEm!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.success,
                    ),
                  )
                : null,
            secondary: state.isToday
                ? IconButton(
                    icon: Icon(
                      isExpanded
                          ? Icons.expand_less
                          : Icons.comment_outlined,
                      size: 20,
                      color: item.observacao != null && item.observacao!.isNotEmpty
                          ? AppColors.secondary
                          : AppColors.gray400,
                    ),
                    onPressed: () {
                      setState(() {
                        _expandedItemId =
                            isExpanded ? null : item.id;
                      });
                    },
                    tooltip: 'Observacao',
                  )
                : null,
            controlAffinity: ListTileControlAffinity.leading,
          ),
        ),

        // Campo de observacao expandivel
        if (isExpanded) _buildObservationField(item, theme),

        const Divider(height: 1, indent: 56),
      ],
    );
  }

  // ── Campo de observacao ────────────────────────────────────────────────

  Widget _buildObservationField(ChecklistItem item, ThemeData theme) {
    final controller = _getOrCreateController(item.id);
    if (controller.text.isEmpty && item.observacao != null) {
      controller.text = item.observacao!;
    }

    return Container(
      color: theme.colorScheme.surfaceContainerLowest,
      padding: const EdgeInsets.fromLTRB(56, 0, 16, 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Adicionar observacao...',
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        ),
        maxLines: 2,
        style: theme.textTheme.bodySmall,
        textInputAction: TextInputAction.done,
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  TextEditingController _getOrCreateController(String itemId) {
    return _observationControllers.putIfAbsent(
      itemId,
      () => TextEditingController(),
    );
  }

  String _formatTimestamp(String isoTimestamp) {
    try {
      final date = DateTime.parse(isoTimestamp);
      return 'Concluido as ${_timeFormat.format(date)}';
    } catch (e) {
      return isoTimestamp;
    }
  }

  int _categoriaOrder(String categoria) {
    switch (categoria) {
      case 'geral':
        return 0;
      case 'primeira_semana':
        return 1;
      case 'pre_abate':
        return 2;
      default:
        return 3;
    }
  }

  String _categoriaLabel(String categoria) {
    switch (categoria) {
      case 'geral':
        return 'Geral';
      case 'primeira_semana':
        return '1a Semana';
      case 'pre_abate':
        return 'Pre-abate';
      default:
        return categoria;
    }
  }

  IconData _categoriaIcon(String categoria) {
    switch (categoria) {
      case 'geral':
        return Icons.checklist;
      case 'primeira_semana':
        return Icons.child_care;
      case 'pre_abate':
        return Icons.local_shipping;
      default:
        return Icons.list;
    }
  }

  Color _categoriaColor(String categoria) {
    switch (categoria) {
      case 'geral':
        return AppColors.secondary;
      case 'primeira_semana':
        return AppColors.warning;
      case 'pre_abate':
        return AppColors.danger;
      default:
        return AppColors.gray600;
    }
  }
}
