import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import '../providers/financeiro_provider.dart';

/// Tela de resumo financeiro do lote.
///
/// Exibe cards de custo total, receita estimada e margem,
/// detalhamento por categoria, custo por kg vivo e links
/// rapidos para custos e remuneracao.
class FinanceiroResumoScreen extends ConsumerStatefulWidget {
  const FinanceiroResumoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<FinanceiroResumoScreen> createState() =>
      _FinanceiroResumoScreenState();
}

class _FinanceiroResumoScreenState
    extends ConsumerState<FinanceiroResumoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(resumoFinanceiroProvider(widget.loteId).notifier).fetch();
    });
  }

  Future<void> _onRefresh() async {
    await ref
        .read(resumoFinanceiroProvider(widget.loteId).notifier)
        .fetch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(resumoFinanceiroProvider(widget.loteId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(ResumoFinanceiroState state, ThemeData theme) {
    if (state.isLoading && state.resumo == null) {
      return const SkeletonList(itemCount: 4);
    }

    if (state.errorMessage != null && state.resumo == null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: _onRefresh,
      );
    }

    final resumo = state.resumo;
    if (resumo == null) {
      return const Center(
        child: Text('Nenhum dado financeiro disponivel.'),
      );
    }

    final margemPositiva = resumo.margemEstimada >= 0;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Cards de resumo ───────────────────────────────────
          _ResumoCard(
            label: 'Custo Total',
            valor: NumberUtils.formatCurrency(resumo.custoTotal),
            icon: Icons.arrow_downward,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          _ResumoCard(
            label: 'Receita Estimada',
            valor: NumberUtils.formatCurrency(resumo.receitaEstimada),
            icon: Icons.arrow_upward,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _ResumoCard(
            label: 'Margem Estimada',
            valor: NumberUtils.formatCurrency(resumo.margemEstimada),
            icon: margemPositiva
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            color: margemPositiva ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(height: 24),

          // ── Custo por kg vivo ─────────────────────────────────
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.monitor_weight_outlined,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Custo por kg vivo',
                        style: theme.textTheme.titleSmall,
                      ),
                    ],
                  ),
                  Text(
                    NumberUtils.formatCurrency(resumo.custoKgVivo),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Detalhamento por categoria ────────────────────────
          Text(
            'Detalhamento de Custos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _CategoriaItem(
            label: 'Racao',
            valor: resumo.custoRacao,
            icon: Icons.grain,
            color: AppColors.warning,
          ),
          _CategoriaItem(
            label: 'Medicamentos',
            valor: resumo.custoMedicamentos,
            icon: Icons.medical_services_outlined,
            color: AppColors.danger,
          ),
          _CategoriaItem(
            label: 'Pintos',
            valor: resumo.custoPintos,
            icon: Icons.egg_outlined,
            color: AppColors.secondary,
          ),
          _CategoriaItem(
            label: 'Mao de obra',
            valor: resumo.custoMaoObra,
            icon: Icons.engineering_outlined,
            color: AppColors.gray700,
          ),
          _CategoriaItem(
            label: 'Outros',
            valor: resumo.custoOutros,
            icon: Icons.more_horiz,
            color: AppColors.gray500,
          ),
          const SizedBox(height: 24),

          // ── Links rapidos ─────────────────────────────────────
          Text(
            'Acoes',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => context.pushNamed(
              RouteNames.custos,
              queryParameters: {'loteId': widget.loteId},
            ),
            icon: const Icon(Icons.list_alt),
            label: const Text('Gerenciar Custos'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: () => context.pushNamed(
              RouteNames.remuneracao,
              queryParameters: {'loteId': widget.loteId},
            ),
            icon: const Icon(Icons.payments_outlined),
            label: const Text('Remuneracao'),
            style: FilledButton.styleFrom(
              minimumSize: const Size(double.infinity, 48),
            ),
          ),
        ],
      ),
    );
  }
}

/// Card de resumo com icone, label e valor formatado.
class _ResumoCard extends StatelessWidget {
  const _ResumoCard({
    required this.label,
    required this.valor,
    required this.icon,
    required this.color,
  });

  final String label;
  final String valor;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    valor,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
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
}

/// Item de detalhamento por categoria de custo.
class _CategoriaItem extends StatelessWidget {
  const _CategoriaItem({
    required this.label,
    required this.valor,
    required this.icon,
    required this.color,
  });

  final String label;
  final double valor;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label),
      trailing: Text(
        NumberUtils.formatCurrency(valor),
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.danger,
        ),
      ),
      dense: true,
    );
  }
}
