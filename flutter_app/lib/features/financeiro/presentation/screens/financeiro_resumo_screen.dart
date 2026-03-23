import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/financeiro/domain/entities/custo.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';
import '../providers/financeiro_provider.dart';

/// Retorna label legivel para a categoria.
String _categoriaDisplayLabel(String categoria) {
  return Custo.categoriaLabel(categoria);
}

/// Retorna icone associado a categoria de custo avicola.
IconData _categoriaIcon(String categoria) {
  const icons = {
    'pintinhos': Icons.egg_outlined,
    'racao': Icons.restaurant_outlined,
    'mao_de_obra': Icons.engineering_outlined,
    'energia': Icons.bolt_outlined,
    'aquecimento': Icons.local_fire_department_outlined,
    'sanidade': Icons.vaccines_outlined,
    'cama': Icons.layers_outlined,
    'manutencao': Icons.build_outlined,
    'depreciacao': Icons.trending_down,
    'agua': Icons.water_drop_outlined,
    'outros': Icons.more_horiz,
  };
  return icons[categoria] ?? Icons.attach_money;
}

/// Retorna cor associada a categoria de custo avicola.
Color _categoriaColor(String categoria) {
  const colors = {
    'pintinhos': AppColors.warning,
    'racao': AppColors.danger,
    'mao_de_obra': AppColors.gray700,
    'energia': AppColors.warning,
    'aquecimento': AppColors.primaryLight,
    'sanidade': AppColors.success,
    'cama': AppColors.secondary,
    'manutencao': AppColors.primaryLight,
    'depreciacao': AppColors.gray500,
    'agua': AppColors.secondaryLight,
    'outros': AppColors.gray500,
  };
  return colors[categoria] ?? AppColors.gray500;
}

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
  late String _selectedLoteId;

  @override
  void initState() {
    super.initState();
    _selectedLoteId = widget.loteId;
    Future.microtask(() {
      ref.read(homeProvider.notifier).fetchLotes();
    });
    if (_selectedLoteId.isNotEmpty) {
      Future.microtask(() {
        ref.read(resumoFinanceiroProvider(_selectedLoteId).notifier).fetch();
      });
    }
  }

  Future<void> _onRefresh() async {
    await ref
        .read(resumoFinanceiroProvider(_selectedLoteId).notifier)
        .fetch();
  }

  void _onLoteChanged(String loteId) {
    setState(() {
      _selectedLoteId = loteId;
    });
    if (loteId.isNotEmpty) {
      ref.read(resumoFinanceiroProvider(loteId).notifier).fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);

    // Auto-select first lote if none selected and lotes are loaded
    final lotes = homeState.lotesAtivos;
    if (_selectedLoteId.isEmpty && lotes.isNotEmpty) {
      Future.microtask(() => _onLoteChanged(lotes.first.id));
    }

    final state = _selectedLoteId.isNotEmpty
        ? ref.watch(resumoFinanceiroProvider(_selectedLoteId))
        : null;

    return Column(
      children: [
        _buildLoteSelector(homeState, theme),
        Expanded(
          child: _selectedLoteId.isEmpty
              ? const EmptyState(
                  icon: Icons.attach_money,
                  titulo: 'Selecione um lote',
                  descricao:
                      'Escolha um lote para visualizar o resumo financeiro.',
                )
              : _buildBody(state!, theme),
        ),
      ],
    );
  }

  Widget _buildLoteSelector(HomeState homeState, ThemeData theme) {
    final lotes = homeState.lotesAtivos;

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
        options: lotes
            .map((l) => DropdownOption(
                  value: l.id,
                  label: '${l.galpaoNome} - Dia ${l.diasDeVida ?? 0}',
                ))
            .toList(),
        placeholder: 'Selecione um lote...',
        onSelect: (option) => _onLoteChanged(option.value),
      ),
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

    final resultadoPositivo = resumo.resultadoLiquido >= 0;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -- Cards de resumo -------------------------------------------
          _ResumoCard(
            label: 'Custo Total',
            valor: NumberUtils.formatCurrency(resumo.custoTotal),
            icon: Icons.arrow_downward,
            color: AppColors.danger,
          ),
          const SizedBox(height: 12),
          _ResumoCard(
            label: 'Receita Total',
            valor: NumberUtils.formatCurrency(resumo.receitaTotal),
            icon: Icons.arrow_upward,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          _ResumoCard(
            label: 'Resultado Liquido',
            valor: NumberUtils.formatCurrency(resumo.resultadoLiquido),
            icon: resultadoPositivo
                ? Icons.check_circle_outline
                : Icons.warning_amber_outlined,
            color: resultadoPositivo ? AppColors.success : AppColors.danger,
          ),
          const SizedBox(height: 24),

          // -- Indicadores por ave / kg ------------------------------------
          if (resumo.custoPorAve != null || resumo.custoPorKg != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    if (resumo.custoPorAve != null)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pest_control_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Custo por ave',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Text(
                            NumberUtils.formatCurrency(resumo.custoPorAve!),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    if (resumo.custoPorAve != null && resumo.custoPorKg != null)
                      const SizedBox(height: 12),
                    if (resumo.custoPorKg != null)
                      Row(
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
                            NumberUtils.formatCurrency(resumo.custoPorKg!),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    if (resumo.margemPorAve != null) ...[
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.trending_up,
                                color: resumo.margemPorAve! >= 0
                                    ? AppColors.success
                                    : AppColors.danger,
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Margem por ave',
                                style: theme.textTheme.titleSmall,
                              ),
                            ],
                          ),
                          Text(
                            NumberUtils.formatCurrency(resumo.margemPorAve!),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: resumo.margemPorAve! >= 0
                                  ? AppColors.success
                                  : AppColors.danger,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],

          // -- Detalhamento por categoria ----------------------------------
          Text(
            'Detalhamento de Custos',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          if (resumo.custosPorCategoria.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text('Nenhum custo registrado.'),
            )
          else
            ...resumo.custosPorCategoria.map(
              (cat) => _CategoriaItem(
                label: _categoriaDisplayLabel(cat.categoria),
                valor: cat.total,
                icon: _categoriaIcon(cat.categoria),
                color: _categoriaColor(cat.categoria),
              ),
            ),
          const SizedBox(height: 24),

          // -- Links rapidos -----------------------------------------------
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
              queryParameters: {'loteId': _selectedLoteId},
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
              queryParameters: {'loteId': _selectedLoteId},
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
