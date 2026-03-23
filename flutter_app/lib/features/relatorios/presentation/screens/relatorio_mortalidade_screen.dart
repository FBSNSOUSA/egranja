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

class _MortalidadeState {
  final List<Map<String, dynamic>> pontos;
  final bool isLoading;
  final String? error;

  const _MortalidadeState({
    this.pontos = const [],
    this.isLoading = false,
    this.error,
  });
}

final _mortalidadeReportProvider = StateNotifierProvider.family<
    _MortalidadeNotifier, _MortalidadeState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return _MortalidadeNotifier(api: api, loteId: loteId);
  },
);

class _MortalidadeNotifier extends StateNotifier<_MortalidadeState> {
  final dynamic _api;
  final String _loteId;

  _MortalidadeNotifier({required dynamic api, required String loteId})
      : _api = api,
        _loteId = loteId,
        super(const _MortalidadeState());

  Future<void> fetch() async {
    state = const _MortalidadeState(isLoading: true);
    try {
      final response = await _api.apiGet<List<Map<String, dynamic>>>(
        '/lotes/$_loteId/relatorio/mortalidade',
        fromJson: (json) {
          if (json == null) return <Map<String, dynamic>>[];
          return (json as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        },
      );
      if (!mounted) return;
      state = _MortalidadeState(pontos: response.data);
    } on NetworkException {
      if (!mounted) return;
      state = const _MortalidadeState(error: 'Sem conexao. Tente novamente.');
    } catch (e) {
      if (!mounted) return;
      state = const _MortalidadeState(error: 'Erro ao carregar mortalidade.');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════

/// Tela de relatorio de mortalidade com grafico acumulado.
class RelatorioMortalidadeScreen extends ConsumerStatefulWidget {
  const RelatorioMortalidadeScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<RelatorioMortalidadeScreen> createState() =>
      _RelatorioMortalidadeScreenState();
}

class _RelatorioMortalidadeScreenState
    extends ConsumerState<RelatorioMortalidadeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_mortalidadeReportProvider(widget.loteId).notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_mortalidadeReportProvider(widget.loteId));
    final theme = Theme.of(context);

    return _buildBody(state, theme);
  }

  Widget _buildBody(_MortalidadeState state, ThemeData theme) {
    if (state.isLoading) {
      return const SkeletonList(itemCount: 3);
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref
            .read(_mortalidadeReportProvider(widget.loteId).notifier)
            .fetch(),
      );
    }

    if (state.pontos.isEmpty) {
      return const EmptyState(
        icon: Icons.trending_down,
        titulo: 'Sem registros de mortalidade',
        descricao: 'Nenhuma mortalidade foi registrada para este lote.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref
          .read(_mortalidadeReportProvider(widget.loteId).notifier)
          .fetch(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(state.pontos, theme),
          const SizedBox(height: 16),
          _buildChart(state.pontos, theme),
          const SizedBox(height: 16),
          _buildTable(state.pontos, theme),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(
      List<Map<String, dynamic>> pontos, ThemeData theme) {
    final totalMortes = pontos.isNotEmpty
        ? (pontos.last['acumulado'] as num?)?.toInt() ?? 0
        : 0;
    final pctFinal = pontos.isNotEmpty
        ? (pontos.last['percentual'] as num?)?.toDouble() ?? 0.0
        : 0.0;

    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Total Mortes',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    totalMortes.toString(),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'Mortalidade %',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberUtils.formatPercentage(pctFinal),
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: pctFinal > 5 ? AppColors.danger : AppColors.success,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChart(List<Map<String, dynamic>> pontos, ThemeData theme) {
    final acumSpots = pontos
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              (e.value['acumulado'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    double maxY = 0;
    for (final p in pontos) {
      final v = (p['acumulado'] as num?)?.toDouble() ?? 0.0;
      if (v > maxY) maxY = v;
    }
    maxY = (maxY * 1.2).ceilToDouble();
    if (maxY <= 0) maxY = 10;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_down, size: 20, color: AppColors.danger),
                const SizedBox(width: 8),
                Text(
                  'Mortalidade Acumulada',
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
                      spots: acumSpots,
                      isCurved: true,
                      color: AppColors.danger,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.danger.withAlpha(30),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          final pct = idx < pontos.length
                              ? (pontos[idx]['percentual'] as num?)
                                      ?.toDouble() ??
                                  0.0
                              : 0.0;
                          return LineTooltipItem(
                            'Acum: ${spot.y.toInt()}\n${NumberUtils.formatPercentage(pct)}',
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
            DataColumn(label: Text('Qtd.'), numeric: true),
            DataColumn(label: Text('Acum.'), numeric: true),
            DataColumn(label: Text('Causa')),
            DataColumn(label: Text('%'), numeric: true),
          ],
          rows: pontos.map((p) {
            final data = p['data'] as String? ?? '';
            final diasVida = (p['dias_vida'] as num?)?.toInt() ?? 0;
            final qtd = (p['quantidade'] as num?)?.toInt() ?? 0;
            final acum = (p['acumulado'] as num?)?.toInt() ?? 0;
            final causa = p['causa'] as String? ?? '';
            final pct = (p['percentual'] as num?)?.toDouble() ?? 0.0;

            return DataRow(cells: [
              DataCell(Text(data.length >= 10 ? data.substring(5) : data)),
              DataCell(Text('D$diasVida')),
              DataCell(Text(qtd.toString())),
              DataCell(Text(
                acum.toString(),
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: pct > 5 ? AppColors.danger : null,
                ),
              )),
              DataCell(Text(causa)),
              DataCell(Text(NumberUtils.formatPercentage(pct))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
