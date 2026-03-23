import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/database/app_database.dart' hide PesagemItem;
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/pesagem.dart';
import '../../providers/pesagens_provider.dart';

/// Aba de pesagens do lote.
///
/// Exibe lista de pesagens com indicadores de cor, paginacao
/// e FAB para nova pesagem.
class LotePesagensTab extends ConsumerStatefulWidget {
  const LotePesagensTab({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<LotePesagensTab> createState() => _LotePesagensTabState();
}

class _LotePesagensTabState extends ConsumerState<LotePesagensTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  // ── Draft state ─────────────────────────────────────────────────────
  Pesagen? _draft;
  int _draftItemCount = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pesagensProvider(widget.loteId).notifier).fetch();
      _checkDraft();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _checkDraft() async {
    final dao = ref.read(pesagensDaoProvider);
    final draft = await dao.getDraft(widget.loteId, DateTime.now());
    if (!mounted) return;
    if (draft != null) {
      final items = await dao.getItemsByPesagemId(draft.id.toString());
      if (!mounted) return;
      setState(() {
        _draft = draft;
        _draftItemCount = items.length;
      });
    } else {
      setState(() {
        _draft = null;
        _draftItemCount = 0;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(pesagensProvider(widget.loteId).notifier).loadMore();
    }
  }

  void _navigateToForm() async {
    await context.pushNamed(
      RouteNames.novaPesagem,
      pathParameters: {'loteId': widget.loteId},
    );
    // Refresh draft state when returning from the form
    if (mounted) {
      _checkDraft();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(pesagensProvider(widget.loteId));
    final theme = Theme.of(context);

    return _buildBody(state, theme);
  }

  Widget _buildDraftBanner(ThemeData theme, {bool withMargin = false}) {
    return Card(
      margin: withMargin
          ? const EdgeInsets.fromLTRB(16, 12, 16, 0)
          : const EdgeInsets.only(bottom: 8),
      color: AppColors.warning.withAlpha(25),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.warning.withAlpha(80)),
      ),
      child: InkWell(
        onTap: _navigateToForm,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.edit_note, color: AppColors.warning, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    'Pesagem em andamento',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '$_draftItemCount amostra${_draftItemCount != 1 ? 's' : ''} registrada${_draftItemCount != 1 ? 's' : ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _navigateToForm,
                  child: const Text('Continuar Pesagem'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(PesagensState state, ThemeData theme) {
    if (state.isLoading && state.pesagens.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    if (state.errorMessage != null && state.pesagens.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(pesagensProvider(widget.loteId).notifier).fetch(),
      );
    }

    if (state.pesagens.isEmpty) {
      return Column(
        children: [
          if (_draft != null) _buildDraftBanner(theme, withMargin: true),
          Expanded(
            child: EmptyState(
              icon: Icons.monitor_weight_outlined,
              titulo: 'Nenhuma pesagem registrada',
              descricao: 'Adicione a primeira pesagem do lote.',
              actionLabel: 'Nova Pesagem',
              actionIcon: Icons.add,
              onAction: _navigateToForm,
            ),
          ),
        ],
      );
    }

    final hasDraft = _draft != null;
    final extraItemCount =
        (hasDraft ? 1 : 0) + (state.isLoading ? 1 : 0);

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(pesagensProvider(widget.loteId).notifier).fetch();
        await _checkDraft();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: state.pesagens.length + extraItemCount,
        itemBuilder: (context, index) {
          // Draft banner as first item
          if (hasDraft && index == 0) {
            return _buildDraftBanner(theme);
          }

          final pesagemIndex = hasDraft ? index - 1 : index;

          if (pesagemIndex >= state.pesagens.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final pesagem = state.pesagens[pesagemIndex];
          return _PesagemCard(
            pesagem: pesagem,
            onTap: () => _showPesagemDetail(context, pesagem),
          );
        },
      ),
    );
  }
}

void _showPesagemDetail(BuildContext context, Pesagem pesagem) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _PesagemDetailSheet(pesagem: pesagem),
  );
}

// ── Card da lista ──────────────────────────────────────────────────────

class _PesagemCard extends StatelessWidget {
  const _PesagemCard({required this.pesagem, this.onTap});

  final Pesagem pesagem;
  final VoidCallback? onTap;

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final ano = date.year;
      return '$dia/$mes/$ano';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: data + chevron
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDate(pesagem.data),
                    style: theme.textTheme.titleSmall,
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.gray500,
                    size: 20,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Peso medio
              Text(
                'Peso medio: ${pesagem.pesoMedio.toStringAsFixed(0)} g',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),

              // Detalhes
              Wrap(
                spacing: 16,
                runSpacing: 4,
                children: [
                  Text(
                    'Qtd: ${pesagem.quantidadeTotal}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    'Peso total: ${pesagem.pesoTotal.toStringAsFixed(0)} g',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (pesagem.items.isNotEmpty)
                    Text(
                      '${pesagem.items.length} amostra${pesagem.items.length != 1 ? 's' : ''}',
                      style: theme.textTheme.bodySmall,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Bottom sheet de detalhe ─────────────────────────────────────────────

class _PesagemDetailSheet extends StatelessWidget {
  const _PesagemDetailSheet({required this.pesagem});

  final Pesagem pesagem;

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final ano = date.year;
      return '$dia/$mes/$ano';
    } catch (_) {
      return isoDate;
    }
  }

  String _formatWeight(double grams) {
    if (grams >= 1000) {
      return '${(grams / 1000).toStringAsFixed(3).replaceAll('.', ',')} kg';
    }
    return '${grams.toStringAsFixed(0).replaceAll('.', ',')} g';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = pesagem.items;

    return DraggableScrollableSheet(
      initialChildSize: 0.55,
      minChildSize: 0.3,
      maxChildSize: 0.85,
      expand: false,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            // ── Header ─────────────────────────────────────────────
            Text(
              _formatDate(pesagem.data),
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatWeight(pesagem.pesoMedio),
              style: theme.textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            Text(
              'peso medio',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),

            // ── Summary chips ──────────────────────────────────────
            Row(
              children: [
                _SummaryChip(
                  label: '${pesagem.quantidadeTotal} aves',
                  icon: Icons.pets,
                ),
                const SizedBox(width: 8),
                _SummaryChip(
                  label: '${pesagem.pesoTotal.toStringAsFixed(0)} g total',
                  icon: Icons.scale,
                ),
                const SizedBox(width: 8),
                _SummaryChip(
                  label: '${items.length} amostra${items.length != 1 ? 's' : ''}',
                  icon: Icons.list_alt,
                ),
              ],
            ),
            const SizedBox(height: 16),

            const Divider(),
            const SizedBox(height: 12),

            // ── Items list title ───────────────────────────────────
            Text(
              'Amostras',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),

            // ── Items or empty state ───────────────────────────────
            if (items.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text(
                    'Nenhuma amostra registrada',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              )
            else
              ...List.generate(items.length, (index) {
                final item = items[index];
                return _SampleCard(
                  index: index + 1,
                  item: item,
                );
              }),
          ],
        );
      },
    );
  }
}

// ── Summary chip widget ─────────────────────────────────────────────────

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.primaryLight.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sample card widget ──────────────────────────────────────────────────

class _SampleCard extends StatelessWidget {
  const _SampleCard({required this.index, required this.item});

  final int index;
  final PesagemItem item;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 0,
      color: AppColors.gray100,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Amostra $index',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                _SampleDetail(
                  label: 'Quantidade',
                  value: '${item.quantidade} aves',
                ),
                const SizedBox(width: 16),
                _SampleDetail(
                  label: 'Peso',
                  value: '${item.peso.toStringAsFixed(0)} g',
                ),
                const SizedBox(width: 16),
                _SampleDetail(
                  label: 'Medio',
                  value: '${item.pesoMedio.toStringAsFixed(0)} g',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sample detail label+value ───────────────────────────────────────────

class _SampleDetail extends StatelessWidget {
  const _SampleDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
