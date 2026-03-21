import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/indicator_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/fab_menu.dart';
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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(pesagensProvider(widget.loteId).notifier).fetch();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(pesagensProvider(widget.loteId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(pesagensProvider(widget.loteId));
    final theme = Theme.of(context);

    return Scaffold(
      body: _buildBody(state, theme),
      floatingActionButton: FABMenu(
        actions: [
          FABAction(
            label: 'Nova Pesagem',
            icon: Icons.monitor_weight,
            onPress: () {
              context.pushNamed(
                RouteNames.novaPesagem,
                pathParameters: {'loteId': widget.loteId},
              );
            },
          ),
        ],
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
      return EmptyState(
        icon: Icons.monitor_weight_outlined,
        titulo: 'Nenhuma pesagem registrada',
        descricao: 'Adicione a primeira pesagem do lote.',
        actionLabel: 'Nova Pesagem',
        actionIcon: Icons.add,
        onAction: () {
          context.pushNamed(
            RouteNames.novaPesagem,
            pathParameters: {'loteId': widget.loteId},
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(pesagensProvider(widget.loteId).notifier).fetch();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: state.pesagens.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.pesagens.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _PesagemCard(pesagem: state.pesagens[index]);
        },
      ),
    );
  }
}

class _PesagemCard extends StatelessWidget {
  const _PesagemCard({required this.pesagem});

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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final pesoColor = pesagem.pesoBenchmark != null && pesagem.pesoBenchmark! > 0
        ? IndicatorColors.getWeightColor(
            pesagem.pesoMedio, pesagem.pesoBenchmark!)
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: data + idade
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(pesagem.data),
                  style: theme.textTheme.titleSmall,
                ),
                if (pesagem.idade != null)
                  Chip(
                    label: Text(
                      '${pesagem.idade} dias',
                      style: theme.textTheme.labelSmall,
                    ),
                    padding: EdgeInsets.zero,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Peso medio com cor
            Row(
              children: [
                if (pesoColor != null)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: pesoColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                Text(
                  'Peso medio: ${pesagem.pesoMedio.toStringAsFixed(0)} g',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: pesoColor,
                  ),
                ),
              ],
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
                if (pesagem.pesoBenchmark != null)
                  Text(
                    'Bench: ${pesagem.pesoBenchmark!.toStringAsFixed(0)} g',
                    style: theme.textTheme.bodySmall,
                  ),
                if (pesagem.desvioPct != null)
                  Text(
                    'Desvio: ${pesagem.desvioPct! >= 0 ? '+' : ''}${pesagem.desvioPct!.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: pesoColor,
                    ),
                  ),
                if (pesagem.uniformidadeCV != null)
                  Text(
                    'CV: ${pesagem.uniformidadeCV!.toStringAsFixed(1)}%',
                    style: theme.textTheme.bodySmall,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
