import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/financeiro/domain/entities/custo.dart';
import '../providers/financeiro_provider.dart';

/// Tela de listagem de custos do lote.
///
/// Exibe custos com badge de tipo, valor e data.
/// Suporta pull-to-refresh, paginacao e FAB para adicionar.
class CustosScreen extends ConsumerStatefulWidget {
  const CustosScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<CustosScreen> createState() => _CustosScreenState();
}

class _CustosScreenState extends ConsumerState<CustosScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(custosProvider(widget.loteId).notifier).fetch();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(custosProvider(widget.loteId).notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(custosProvider(widget.loteId).notifier).fetch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(custosProvider(widget.loteId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Custos'),
      ),
      body: _buildBody(state, theme),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed(
          RouteNames.novoCusto,
          queryParameters: {'loteId': widget.loteId},
        ),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(CustosState state, ThemeData theme) {
    if (state.isLoading && state.custos.isEmpty) {
      return const SkeletonList(itemCount: 5);
    }

    if (state.errorMessage != null && state.custos.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: _onRefresh,
      );
    }

    if (state.custos.isEmpty) {
      return EmptyState(
        icon: Icons.money_off,
        titulo: 'Nenhum custo registrado',
        descricao:
            'Registre os custos de producao do lote para calcular o resultado financeiro.',
        actionLabel: 'Registrar custo',
        actionIcon: Icons.add,
        onAction: () => context.pushNamed(
          RouteNames.novoCusto,
          queryParameters: {'loteId': widget.loteId},
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: 80,
        ),
        itemCount: state.custos.length + (state.hasMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          if (index >= state.custos.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final custo = state.custos[index];
          return _CustoCard(custo: custo);
        },
      ),
    );
  }
}

/// Card de custo individual com badge de tipo, descricao, valor e data.
class _CustoCard extends StatelessWidget {
  const _CustoCard({required this.custo});

  final Custo custo;

  Color _tipoBadgeColor(String tipo) {
    const colors = {
      'racao': AppColors.warning,
      'medicamento': AppColors.danger,
      'pinto': AppColors.secondary,
      'mao_obra': AppColors.gray700,
      'outros': AppColors.gray500,
    };
    return colors[tipo] ?? AppColors.gray500;
  }

  String _formatData(String dataStr) {
    try {
      final date = DateTime.parse(dataStr);
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final ano = date.year;
      return '$dia/$mes/$ano';
    } catch (_) {
      return dataStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = _tipoBadgeColor(custo.tipo);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Badge de tipo
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: badgeColor.withAlpha(30),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                Custo.tipoLabel(custo.tipo),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: badgeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Descricao e data
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    custo.descricao,
                    style: theme.textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _formatData(custo.data),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            // Valor
            Text(
              NumberUtils.formatCurrency(custo.valor),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
