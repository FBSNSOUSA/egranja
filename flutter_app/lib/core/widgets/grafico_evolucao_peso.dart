import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Ponto de dados para graficos.
class PontoGrafico {
  const PontoGrafico({
    required this.label,
    required this.valor,
  });

  /// Rotulo do eixo X (ex: "Dia 7", "Sem 2").
  final String label;

  /// Valor numerico do ponto.
  final double valor;
}

/// Grafico de evolucao de peso com comparacao ao benchmark.
///
/// Exibe duas linhas: peso real (azul) e benchmark da linhagem
/// (verde tracejado). Usa fl_chart para renderizacao.
///
/// Portado do componente React Native `GraficoEvolucaoPeso.tsx`.
class GraficoEvolucaoPeso extends StatelessWidget {
  const GraficoEvolucaoPeso({
    super.key,
    required this.pesoReal,
    required this.pesoBenchmark,
    this.linhagem = '',
  });

  /// Pontos de peso real medido.
  final List<PontoGrafico> pesoReal;

  /// Pontos de peso esperado (benchmark da linhagem).
  final List<PontoGrafico> pesoBenchmark;

  /// Nome da linhagem para exibicao no titulo.
  final String linhagem;

  bool get _hasData => pesoReal.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: _hasData
          ? 'Grafico de evolucao de peso, mostrando ${pesoReal.length} pontos de dados'
          : 'Grafico de evolucao de peso, sem dados',
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titulo
              Text(
                'Evolucao de Peso',
                style: theme.textTheme.titleSmall,
              ),
              if (linhagem.isNotEmpty)
                Text(
                  'Linhagem: $linhagem',
                  style: theme.textTheme.labelSmall,
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
            Icon(
              Icons.show_chart_outlined,
              size: 40,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(100),
            ),
            const SizedBox(height: 8),
            Text(
              'Sem dados de pesagem',
              style: theme.textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChart(ThemeData theme) {
    final realSpots = pesoReal
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.valor))
        .toList();

    final benchmarkSpots = pesoBenchmark
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.valor))
        .toList();

    // Calcular max Y
    double maxY = 0;
    for (final p in pesoReal) {
      if (p.valor > maxY) maxY = p.valor;
    }
    for (final p in pesoBenchmark) {
      if (p.valor > maxY) maxY = p.valor;
    }
    maxY = (maxY * 1.1).ceilToDouble();
    if (maxY <= 0) maxY = 100;

    return LineChart(
      LineChartData(
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
              interval: _calculateBottomInterval(),
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx < 0 || idx >= pesoReal.length) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    pesoReal[idx].label,
                    style: const TextStyle(fontSize: 10),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 44,
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
        minX: 0,
        maxX: (pesoReal.length - 1).toDouble().clamp(0, double.infinity),
        minY: 0,
        maxY: maxY,
        lineBarsData: [
          // Peso real (azul, solido)
          LineChartBarData(
            spots: realSpots,
            isCurved: true,
            color: AppColors.secondary,
            barWidth: 3,
            dotData: const FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              color: AppColors.secondary.withAlpha(30),
            ),
          ),
          // Benchmark (verde, tracejado)
          if (benchmarkSpots.isNotEmpty)
            LineChartBarData(
              spots: benchmarkSpots,
              isCurved: true,
              color: AppColors.success,
              barWidth: 2,
              dashArray: [8, 4],
              dotData: const FlDotData(show: false),
            ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final isReal = spot.barIndex == 0;
                return LineTooltipItem(
                  '${spot.y.toStringAsFixed(0)} g',
                  TextStyle(
                    color: isReal ? AppColors.secondary : AppColors.success,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calculateBottomInterval() {
    if (pesoReal.length <= 7) return 1;
    if (pesoReal.length <= 14) return 2;
    return (pesoReal.length / 7).ceilToDouble();
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _LegendItem(
          color: AppColors.secondary,
          label: 'Peso real',
          dashed: false,
        ),
        const SizedBox(width: 20),
        _LegendItem(
          color: AppColors.success,
          label: 'Benchmark',
          dashed: true,
        ),
      ],
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({
    required this.color,
    required this.label,
    required this.dashed,
  });

  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: dashed ? null : color,
            shape: BoxShape.circle,
            border: dashed ? Border.all(color: color, width: 2) : null,
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
