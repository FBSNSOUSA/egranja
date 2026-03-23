import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';

// ══════════════════════════════════════════════════════════════════════
// PROVIDER
// ══════════════════════════════════════════════════════════════════════

/// Estado do relatorio de pesagens.
class _PesagensState {
  final List<Map<String, dynamic>> pontos;
  final bool isLoading;
  final String? error;

  const _PesagensState({
    this.pontos = const [],
    this.isLoading = false,
    this.error,
  });
}

/// Provider family para buscar pesagens por lote.
final _pesagensReportProvider = StateNotifierProvider.family<
    _PesagensNotifier, _PesagensState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return _PesagensNotifier(api: api, loteId: loteId);
  },
);

class _PesagensNotifier extends StateNotifier<_PesagensState> {
  final dynamic _api;
  final String _loteId;

  _PesagensNotifier({required dynamic api, required String loteId})
      : _api = api,
        _loteId = loteId,
        super(const _PesagensState());

  Future<void> fetch() async {
    state = const _PesagensState(isLoading: true);
    try {
      final response = await _api.apiGet<List<Map<String, dynamic>>>(
        '/lotes/$_loteId/relatorio/pesagens',
        fromJson: (json) {
          if (json == null) return <Map<String, dynamic>>[];
          return (json as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        },
      );
      if (!mounted) return;
      state = _PesagensState(pontos: response.data);
    } on NetworkException {
      if (!mounted) return;
      state = const _PesagensState(error: 'Sem conexao. Tente novamente.');
    } catch (e) {
      if (!mounted) return;
      state = const _PesagensState(error: 'Erro ao carregar pesagens.');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════

/// Tela de relatorio de pesagens com grafico de evolucao de peso.
class RelatorioPesagensScreen extends ConsumerStatefulWidget {
  const RelatorioPesagensScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<RelatorioPesagensScreen> createState() =>
      _RelatorioPesagensScreenState();
}

class _RelatorioPesagensScreenState
    extends ConsumerState<RelatorioPesagensScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_pesagensReportProvider(widget.loteId).notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_pesagensReportProvider(widget.loteId));
    final theme = Theme.of(context);

    return _buildBody(state, theme);
  }

  Widget _buildBody(_PesagensState state, ThemeData theme) {
    if (state.isLoading) {
      return const SkeletonList(itemCount: 3);
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () =>
            ref.read(_pesagensReportProvider(widget.loteId).notifier).fetch(),
      );
    }

    if (state.pontos.isEmpty) {
      return const EmptyState(
        icon: Icons.monitor_weight_outlined,
        titulo: 'Sem pesagens registradas',
        descricao: 'Nenhuma pesagem foi registrada para este lote.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(_pesagensReportProvider(widget.loteId).notifier).fetch(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildChart(state.pontos, theme),
          const SizedBox(height: 16),
          _buildTable(state.pontos, theme),
        ],
      ),
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> pontos, ThemeData theme) {
    final spots = pontos
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              (e.value['peso_medio'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    double maxY = 0;
    for (final p in pontos) {
      final v = (p['peso_medio'] as num?)?.toDouble() ?? 0.0;
      if (v > maxY) maxY = v;
    }
    maxY = (maxY * 1.15).ceilToDouble();
    if (maxY <= 0) maxY = 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, size: 20, color: AppColors.secondary),
                const SizedBox(width: 8),
                Text(
                  'Evolucao do Peso Medio',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
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
                        interval: pontos.length <= 7
                            ? 1
                            : (pontos.length / 6).ceilToDouble(),
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= pontos.length) {
                            return const SizedBox.shrink();
                          }
                          final dia =
                              pontos[idx]['dias_vida']?.toString() ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'D$dia',
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
                  maxX: (pontos.length - 1).toDouble().clamp(0, double.infinity),
                  minY: 0,
                  maxY: maxY,
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: AppColors.secondary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.secondary.withAlpha(30),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          return LineTooltipItem(
                            '${spot.y.toStringAsFixed(0)} g',
                            const TextStyle(
                              color: AppColors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          );
                        }).toList();
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTable(List<Map<String, dynamic>> pontos, ThemeData theme) {
    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.primary.withAlpha(15),
          ),
          columns: const [
            DataColumn(label: Text('Data')),
            DataColumn(label: Text('Dia')),
            DataColumn(label: Text('Peso Medio'), numeric: true),
            DataColumn(label: Text('Qtd.'), numeric: true),
          ],
          rows: pontos.map((p) {
            final data = p['data'] as String? ?? '';
            final diasVida = (p['dias_vida'] as num?)?.toInt() ?? 0;
            final pesoMedio = (p['peso_medio'] as num?)?.toDouble() ?? 0.0;
            final qtd = (p['quantidade'] as num?)?.toInt() ?? 0;

            return DataRow(cells: [
              DataCell(Text(data.length >= 10 ? data.substring(5) : data)),
              DataCell(Text('D$diasVida')),
              DataCell(Text(NumberUtils.formatWeight(pesoMedio))),
              DataCell(Text(qtd.toString())),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
