import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/fab_menu.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/racao.dart';
import '../../providers/racao_provider.dart';

/// Aba de racao do lote.
///
/// Exibe seções de recebimentos e consumos de racao, com FABMenu
/// para adicionar novo recebimento ou consumo.
class LoteRacaoTab extends ConsumerStatefulWidget {
  const LoteRacaoTab({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<LoteRacaoTab> createState() => _LoteRacaoTabState();
}

class _LoteRacaoTabState extends ConsumerState<LoteRacaoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(racaoProvider(widget.loteId).notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(racaoProvider(widget.loteId));
    final theme = Theme.of(context);

    return Scaffold(
      body: _buildBody(state, theme),
      floatingActionButton: FABMenu(
        actions: [
          FABAction(
            label: 'Novo Recebimento',
            icon: Icons.move_to_inbox,
            onPress: () {
              context.pushNamed(
                RouteNames.novoRecebimento,
                pathParameters: {'loteId': widget.loteId},
              );
            },
          ),
          FABAction(
            label: 'Novo Consumo',
            icon: Icons.restaurant,
            onPress: () {
              context.pushNamed(
                RouteNames.novoConsumo,
                pathParameters: {'loteId': widget.loteId},
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBody(RacaoState state, ThemeData theme) {
    if (state.isLoading &&
        state.recebimentos.isEmpty &&
        state.consumos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    if (state.errorMessage != null &&
        state.recebimentos.isEmpty &&
        state.consumos.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(racaoProvider(widget.loteId).notifier).fetch(),
      );
    }

    if (state.recebimentos.isEmpty && state.consumos.isEmpty) {
      return EmptyState(
        icon: Icons.restaurant_outlined,
        titulo: 'Nenhum registro de racao',
        descricao:
            'Adicione recebimentos e consumos de racao para este lote.',
        actionLabel: 'Novo Recebimento',
        actionIcon: Icons.add,
        onAction: () {
          context.pushNamed(
            RouteNames.novoRecebimento,
            pathParameters: {'loteId': widget.loteId},
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(racaoProvider(widget.loteId).notifier).fetch();
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Recebimentos ─────────────────────────────────────
            if (state.recebimentos.isNotEmpty) ...[
              Text(
                'Recebimentos',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...state.recebimentos
                  .map((r) => _RecebimentoCard(recebimento: r)),
              const SizedBox(height: 24),
            ],

            // ── Consumo Diario ───────────────────────────────────
            if (state.consumos.isNotEmpty) ...[
              Text(
                'Consumo Diario',
                style: theme.textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              ...state.consumos.map((c) => _ConsumoCard(consumo: c)),
            ],
          ],
        ),
      ),
    );
  }
}

class _RecebimentoCard extends StatelessWidget {
  const _RecebimentoCard({required this.recebimento});

  final RecebimentoRacao recebimento;

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

  String _formatOrigem(String origem) {
    switch (origem) {
      case 'compra':
        return 'Compra';
      case 'remanescente_anterior':
        return 'Remanescente anterior';
      case 'sobra_final':
        return 'Sobra final';
      default:
        return origem;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(recebimento.dataRecebimento),
                  style: theme.textTheme.titleSmall,
                ),
                Text(
                  '${recebimento.quantidadeKg.toStringAsFixed(0)} kg',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              children: [
                if (recebimento.tipoRacaoNome != null)
                  Text(
                    recebimento.tipoRacaoNome!,
                    style: theme.textTheme.bodySmall,
                  ),
                Text(
                  _formatOrigem(recebimento.origem),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (recebimento.fornecedor != null)
                  Text(
                    recebimento.fornecedor!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ConsumoCard extends StatelessWidget {
  const _ConsumoCard({required this.consumo});

  final ConsumoRacao consumo;

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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(consumo.data),
              style: theme.textTheme.bodyMedium,
            ),
            Text(
              '${consumo.quantidadeKg.toStringAsFixed(1)} kg',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
