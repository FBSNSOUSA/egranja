import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/features/iot/domain/entities/historico_iot.dart';
import 'package:egranja_flutter/features/iot/presentation/providers/iot_historico_provider.dart';

/// Opcoes de sensor para o seletor segmentado.
const _sensorOptions = <String, String>{
  'temperatura': 'Temp',
  'umidade': 'Umid',
  'co2': 'CO\u2082',
  'amonia': 'NH\u2083',
};

/// Opcoes de periodo para o seletor segmentado.
const _periodoOptions = <String, String>{
  '24h': '24h',
  '7d': '7 dias',
  '30d': '30 dias',
};

/// Tela de historico dos sensores IoT.
///
/// Exibe um grafico de linha com dados historicos de um sensor
/// selecionado, com filtros de tipo de sensor e periodo.
class IoTHistoricoScreen extends ConsumerStatefulWidget {
  const IoTHistoricoScreen({super.key, required this.galpaoId});

  /// ID do galpao cujos sensores serao exibidos.
  final String galpaoId;

  @override
  ConsumerState<IoTHistoricoScreen> createState() =>
      _IoTHistoricoScreenState();
}

class _IoTHistoricoScreenState extends ConsumerState<IoTHistoricoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(iotHistoricoProvider(widget.galpaoId).notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(iotHistoricoProvider(widget.galpaoId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historico Sensores'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Seletor de sensor
            _buildSensorSelector(state, theme),
            const SizedBox(height: 12),

            // Seletor de periodo
            _buildPeriodoSelector(state, theme),
            const SizedBox(height: 20),

            // Conteudo principal
            _buildContent(state, theme),
          ],
        ),
      ),
    );
  }

  /// Seletor segmentado de tipo de sensor.
  Widget _buildSensorSelector(IoTHistoricoState state, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        segments: _sensorOptions.entries
            .map((e) => ButtonSegment<String>(
                  value: e.key,
                  label: Text(e.value),
                ))
            .toList(),
        selected: {state.sensorSelecionado},
        onSelectionChanged: (selected) {
          ref
              .read(iotHistoricoProvider(widget.galpaoId).notifier)
              .setSensor(selected.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            theme.textTheme.labelMedium,
          ),
        ),
      ),
    );
  }

  /// Seletor segmentado de periodo.
  Widget _buildPeriodoSelector(IoTHistoricoState state, ThemeData theme) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<String>(
        segments: _periodoOptions.entries
            .map((e) => ButtonSegment<String>(
                  value: e.key,
                  label: Text(e.value),
                ))
            .toList(),
        selected: {state.periodoSelecionado},
        onSelectionChanged: (selected) {
          ref
              .read(iotHistoricoProvider(widget.galpaoId).notifier)
              .setPeriodo(selected.first);
        },
        style: ButtonStyle(
          visualDensity: VisualDensity.compact,
          textStyle: WidgetStatePropertyAll(
            theme.textTheme.labelMedium,
          ),
        ),
      ),
    );
  }

  /// Corpo principal com grafico, legenda e estatisticas.
  Widget _buildContent(IoTHistoricoState state, ThemeData theme) {
    // Loading
    if (state.isLoading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // Erro
    if (state.errorMessage != null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref
            .read(iotHistoricoProvider(widget.galpaoId).notifier)
            .fetch(),
      );
    }

    // Sem dados
    if (state.historico == null || state.historico!.dados.isEmpty) {
      return const EmptyState(
        icon: Icons.show_chart,
        titulo: 'Sem dados historicos',
        descricao:
            'Nao ha registros para o sensor e periodo selecionados.',
      );
    }

    final historico = state.historico!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Grafico
        _buildChart(historico, theme),
        const SizedBox(height: 12),

        // Legenda do range ideal
        _buildRangeLegend(historico.rangeIdeal, theme),
        const SizedBox(height: 20),

        // Card de estatisticas
        _buildStatisticsCard(historico.estatisticas, theme),
      ],
    );
  }

  /// Grafico de linha com dados historicos e faixa ideal.
  Widget _buildChart(HistoricoResponse historico, ThemeData theme) {
    final dados = historico.dados;
    if (dados.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (var i = 0; i < dados.length; i++) {
      spots.add(FlSpot(i.toDouble(), dados[i].valor));
    }

    // Calcular limites do eixo Y
    final valores = dados.map((d) => d.valor).toList();
    final rangeMin = historico.rangeIdeal.min;
    final rangeMax = historico.rangeIdeal.max;

    double minY = valores.reduce((a, b) => a < b ? a : b);
    double maxY = valores.reduce((a, b) => a > b ? a : b);

    // Incluir range ideal nos limites
    if (rangeMin < minY) minY = rangeMin;
    if (rangeMax > maxY) maxY = rangeMax;

    // Adicionar margem
    final margin = (maxY - minY) * 0.1;
    minY -= margin;
    maxY += margin;

    // Labels do eixo X (timestamps simplificados)
    final is24h = historico.periodo == '24h';

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 16, 8),
        child: SizedBox(
          height: 250,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY - minY) / 4,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: AppColors.gray200,
                    strokeWidth: 0.5,
                  );
                },
              ),
              titlesData: FlTitlesData(
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 40,
                    getTitlesWidget: (value, meta) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: Text(
                          value.toStringAsFixed(0),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 10,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: _calculateBottomInterval(dados.length),
                    getTitlesWidget: (value, meta) {
                      final idx = value.toInt();
                      if (idx < 0 || idx >= dados.length) {
                        return const SizedBox.shrink();
                      }
                      final ts = dados[idx].timestamp;
                      final label = is24h
                          ? DateFormat('HH:mm').format(ts)
                          : DateFormat('dd/MM').format(ts);
                      return Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          label,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary,
                            fontSize: 9,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (touchedSpots) {
                    return touchedSpots.map((spot) {
                      final idx = spot.x.toInt();
                      final ts = idx >= 0 && idx < dados.length
                          ? dados[idx].timestamp
                          : DateTime.now();
                      final timeStr =
                          DateFormat('dd/MM HH:mm').format(ts);
                      return LineTooltipItem(
                        '${spot.y.toStringAsFixed(1)}\n$timeStr',
                        TextStyle(
                          color: AppColors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              // Faixa ideal (area sombreada)
              rangeAnnotations: RangeAnnotations(
                horizontalRangeAnnotations: [
                  HorizontalRangeAnnotation(
                    y1: historico.rangeIdeal.min,
                    y2: historico.rangeIdeal.max,
                    color: AppColors.success.withAlpha(20),
                  ),
                ],
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppColors.secondary,
                  barWidth: 2,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.secondary.withAlpha(20),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Calcula o intervalo de labels do eixo X.
  double _calculateBottomInterval(int totalPoints) {
    if (totalPoints <= 6) return 1;
    return (totalPoints / 5).ceilToDouble();
  }

  /// Legenda da faixa ideal.
  Widget _buildRangeLegend(RangeIdeal range, ThemeData theme) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: const BoxDecoration(
            color: AppColors.success,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          'Faixa ideal: ${range.min.toStringAsFixed(0)} - ${range.max.toStringAsFixed(0)}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Card com estatisticas (minimo, media, maximo).
  Widget _buildStatisticsCard(
    EstatisticasSensor estatisticas,
    ThemeData theme,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estatisticas do periodo',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Minimo
                Expanded(
                  child: _StatColumn(
                    icon: Icons.arrow_downward,
                    iconColor: AppColors.secondary,
                    label: 'Minimo',
                    value: estatisticas.minimo.toStringAsFixed(1),
                  ),
                ),
                // Media
                Expanded(
                  child: _StatColumn(
                    icon: Icons.remove,
                    iconColor: AppColors.warning,
                    label: 'Media',
                    value: estatisticas.media.toStringAsFixed(1),
                  ),
                ),
                // Maximo
                Expanded(
                  child: _StatColumn(
                    icon: Icons.arrow_upward,
                    iconColor: AppColors.danger,
                    label: 'Maximo',
                    value: estatisticas.maximo.toStringAsFixed(1),
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

/// Coluna individual de estatistica com icone, label e valor.
class _StatColumn extends StatelessWidget {
  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
