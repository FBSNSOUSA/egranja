import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'grafico_evolucao_peso.dart';

/// Grafico combinado de mortalidade: barras diarias + linha acumulada.
///
/// Exibe um BarChart para mortalidade diaria e uma linha sobreposta
/// para mortalidade acumulada. Usa fl_chart para renderizacao.
///
/// Portado do componente React Native `GraficoMortalidade.tsx`.
class GraficoMortalidade extends StatelessWidget {
  const GraficoMortalidade({
    super.key,
    required this.mortalidadeDiaria,
    required this.mortalidadeAcumulada,
  });

  /// Pontos de mortalidade diaria (barras).
  final List<PontoGrafico> mortalidadeDiaria;

  /// Pontos de mortalidade acumulada (linha).
  final List<PontoGrafico> mortalidadeAcumulada;

  bool get _hasData => mortalidadeDiaria.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: _hasData
          ? 'Grafico de mortalidade, mostrando ${mortalidadeDiaria.length} pontos de dados'
          : 'Grafico de mortalidade, sem dados',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titulo with icon
              Row(
                children: [
                  Icon(
                    Icons.bar_chart,
                    size: 20,
                    color: AppColors.danger.withAlpha(180),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Mortalidade',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Padding(
                padding: const EdgeInsets.only(left: 28),
                child: Text(
                  'Aves mortas x Idade (dias)',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Grafico ou estado vazio
              if (!_hasData)
                _buildEmptyState(theme)
              else ...[
                SizedBox(
                  height: 220,
                  child: ExcludeSemantics(child: _buildChart(theme)),
                ),
                const SizedBox(height: 12),
                _buildLegend(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return SizedBox(
      height: 160,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.gray100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_outlined,
                size: 28,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Sem dados de mortalidade',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    // Calcular max Y para barras
    double maxBarY = 0;
    for (final p in mortalidadeDiaria) {
      if (p.valor > maxBarY) maxBarY = p.valor;
    }
    maxBarY = (maxBarY * 1.3).ceilToDouble();
    if (maxBarY <= 0) maxBarY = 10;

    // Calcular max Y para linha acumulada
    double maxLineY = 0;
    for (final p in mortalidadeAcumulada) {
      if (p.valor > maxLineY) maxLineY = p.valor;
    }
    maxLineY = (maxLineY * 1.1).ceilToDouble();
    if (maxLineY <= 0) maxLineY = 10;

    // Usar o maior maxY para escala uniforme
    final maxY = maxBarY > maxLineY ? maxBarY : maxLineY;

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: maxY / 5,
          getDrawingHorizontalLine: (value) => FlLine(
            color: AppColors.gray200,
            strokeWidth: 1,
          ),
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= mortalidadeDiaria.length) {
                  return const SizedBox.shrink();
                }
                // Show every Nth label to avoid overlap
                final interval = _calculateBottomInterval();
                if (idx % interval != 0) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    mortalidadeDiaria[idx].label,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 36,
              interval: maxY / 5,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
        ),
        borderData: FlBorderData(show: false),
        barGroups: mortalidadeDiaria.asMap().entries.map((e) {
          return BarChartGroupData(
            x: e.key,
            barRods: [
              BarChartRodData(
                toY: e.value.valor,
                color: AppColors.danger.withAlpha(180),
                width: _calculateBarWidth(),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(3),
                ),
              ),
            ],
          );
        }).toList(),
        extraLinesData: ExtraLinesData(
          extraLinesOnTop: true,
          horizontalLines: [],
        ),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final label = groupIndex < mortalidadeDiaria.length
                  ? mortalidadeDiaria[groupIndex].label
                  : '';
              final acumulado = groupIndex < mortalidadeAcumulada.length
                  ? mortalidadeAcumulada[groupIndex].valor
                  : 0.0;
              return BarTooltipItem(
                '$label\nDiaria: ${rod.toY.toInt()}\nAcum.: ${acumulado.toInt()}',
                const TextStyle(
                  color: AppColors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  int _calculateBottomInterval() {
    if (mortalidadeDiaria.length <= 7) return 1;
    if (mortalidadeDiaria.length <= 14) return 2;
    return (mortalidadeDiaria.length / 7).ceil();
  }

  double _calculateBarWidth() {
    if (mortalidadeDiaria.length <= 7) return 16;
    if (mortalidadeDiaria.length <= 14) return 10;
    if (mortalidadeDiaria.length <= 30) return 6;
    return 4;
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppColors.danger.withAlpha(180),
          label: 'Mort. diaria',
          isBar: true,
        ),
        const SizedBox(width: 20),
        _LegendItem(
          color: AppColors.primaryDark,
          label: 'Mort. acumulada',
          isBar: false,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.isBar,
  });

  final Color color;
  final String label;
  final bool isBar;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: isBar ? BoxShape.rectangle : BoxShape.circle,
            borderRadius: isBar ? BorderRadius.circular(2) : null,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall,
        ),
      ],
    );
  }
}
