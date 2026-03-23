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

class _ConsumoState {
  final double totalRacaoKg;
  final double totalAguaL;
  final List<Map<String, dynamic>> pontos;
  final bool isLoading;
  final String? error;

  const _ConsumoState({
    this.totalRacaoKg = 0,
    this.totalAguaL = 0,
    this.pontos = const [],
    this.isLoading = false,
    this.error,
  });
}

final _consumoReportProvider = StateNotifierProvider.family<
    _ConsumoNotifier, _ConsumoState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return _ConsumoNotifier(api: api, loteId: loteId);
  },
);

class _ConsumoNotifier extends StateNotifier<_ConsumoState> {
  final dynamic _api;
  final String _loteId;

  _ConsumoNotifier({required dynamic api, required String loteId})
      : _api = api,
        _loteId = loteId,
        super(const _ConsumoState());

  Future<void> fetch() async {
    state = const _ConsumoState(isLoading: true);
    try {
      final response = await _api.apiGet<Map<String, dynamic>>(
        '/lotes/$_loteId/relatorio/consumo',
        fromJson: (json) {
          if (json == null) return <String, dynamic>{};
          return Map<String, dynamic>.from(json as Map);
        },
      );
      if (!mounted) return;
      final data = response.data;
      final pontosRaw = data['pontos'];
      final pontos = pontosRaw == null
          ? <Map<String, dynamic>>[]
          : (pontosRaw as List<dynamic>)
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();

      state = _ConsumoState(
        totalRacaoKg: (data['total_racao_kg'] as num?)?.toDouble() ?? 0.0,
        totalAguaL: (data['total_agua_l'] as num?)?.toDouble() ?? 0.0,
        pontos: pontos,
      );
    } on NetworkException {
      if (!mounted) return;
      state = const _ConsumoState(error: 'Sem conexao. Tente novamente.');
    } catch (e) {
      if (!mounted) return;
      state = const _ConsumoState(error: 'Erro ao carregar consumo.');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════

/// Tela de relatorio de consumo de racao e agua.
class RelatorioConsumoScreen extends ConsumerStatefulWidget {
  const RelatorioConsumoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<RelatorioConsumoScreen> createState() =>
      _RelatorioConsumoScreenState();
}

class _RelatorioConsumoScreenState
    extends ConsumerState<RelatorioConsumoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_consumoReportProvider(widget.loteId).notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_consumoReportProvider(widget.loteId));
    final theme = Theme.of(context);

    return _buildBody(state, theme);
  }

  Widget _buildBody(_ConsumoState state, ThemeData theme) {
    if (state.isLoading) {
      return const SkeletonList(itemCount: 3);
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () =>
            ref.read(_consumoReportProvider(widget.loteId).notifier).fetch(),
      );
    }

    if (state.pontos.isEmpty) {
      return const EmptyState(
        icon: Icons.water_drop_outlined,
        titulo: 'Sem registros de consumo',
        descricao: 'Nenhum consumo de racao ou agua foi registrado.',
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(_consumoReportProvider(widget.loteId).notifier).fetch(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSummaryCards(state, theme),
          const SizedBox(height: 16),
          _buildRacaoChart(state.pontos, theme),
          const SizedBox(height: 16),
          _buildAguaChart(state.pontos, theme),
          const SizedBox(height: 16),
          _buildTable(state.pontos, theme),
        ],
      ),
    );
  }

  Widget _buildSummaryCards(_ConsumoState state, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Icon(Icons.restaurant, color: AppColors.secondary, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'Total Racao',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberUtils.formatDecimal(state.totalRacaoKg, 1)} kg',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
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
                  Icon(Icons.water_drop, color: AppColors.tertiary, size: 28),
                  const SizedBox(height: 8),
                  Text(
                    'Total Agua',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${NumberUtils.formatDecimal(state.totalAguaL, 1)} L',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.tertiary,
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

  Widget _buildRacaoChart(
      List<Map<String, dynamic>> pontos, ThemeData theme) {
    final spots = pontos
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              (e.value['racao_kg'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    return _buildLineChart(
      pontos: pontos,
      spots: spots,
      title: 'Consumo de Racao (kg/dia)',
      icon: Icons.restaurant,
      color: AppColors.secondary,
      theme: theme,
      yLabel: 'kg',
    );
  }

  Widget _buildAguaChart(
      List<Map<String, dynamic>> pontos, ThemeData theme) {
    final spots = pontos
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              (e.value['agua_l'] as num?)?.toDouble() ?? 0.0,
            ))
        .toList();

    return _buildLineChart(
      pontos: pontos,
      spots: spots,
      title: 'Consumo de Agua (L/dia)',
      icon: Icons.water_drop,
      color: AppColors.tertiary,
      theme: theme,
      yLabel: 'L',
    );
  }

  Widget _buildLineChart({
    required List<Map<String, dynamic>> pontos,
    required List<FlSpot> spots,
    required String title,
    required IconData icon,
    required Color color,
    required ThemeData theme,
    required String yLabel,
  }) {
    double maxY = 0;
    for (final s in spots) {
      if (s.y > maxY) maxY = s.y;
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
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
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
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= pontos.length) {
                            return const SizedBox.shrink();
                          }
                          // Show every Nth label to avoid crowding
                          final interval = pontos.length <= 10
                              ? 1
                              : (pontos.length / 8).ceil();
                          if (idx % interval != 0 &&
                              idx != pontos.length - 1) {
                            return const SizedBox.shrink();
                          }
                          final dia =
                              pontos[idx]['dias_vida']?.toString() ?? '';
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              'D$dia',
                              style: const TextStyle(fontSize: 9),
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
                            value.toStringAsFixed(0),
                            style: const TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  maxY: maxY,
                  barGroups: pontos.asMap().entries.map((e) {
                    final idx = e.key;
                    final val = spots[idx].y;
                    return BarChartGroupData(
                      x: idx,
                      barRods: [
                        BarChartRodData(
                          toY: val,
                          color: color,
                          width: pontos.length > 20 ? 4 : 8,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(3),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                  barTouchData: BarTouchData(
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, gIdx, rod, rIdx) {
                        final idx = group.x;
                        final data = idx < pontos.length
                            ? pontos[idx]['data'] as String? ?? ''
                            : '';
                        return BarTooltipItem(
                          '$data\n${rod.toY.toStringAsFixed(1)} $yLabel',
                          const TextStyle(
                            color: AppColors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        );
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
            DataColumn(label: Text('Racao (kg)'), numeric: true),
            DataColumn(label: Text('Agua (L)'), numeric: true),
          ],
          rows: pontos.map((p) {
            final data = p['data'] as String? ?? '';
            final diasVida = (p['dias_vida'] as num?)?.toInt() ?? 0;
            final racao = (p['racao_kg'] as num?)?.toDouble() ?? 0.0;
            final agua = (p['agua_l'] as num?)?.toDouble() ?? 0.0;

            return DataRow(cells: [
              DataCell(Text(data.length >= 10 ? data.substring(5) : data)),
              DataCell(Text('D$diasVida')),
              DataCell(Text(NumberUtils.formatDecimal(racao, 1))),
              DataCell(Text(NumberUtils.formatDecimal(agua, 1))),
            ]);
          }).toList(),
        ),
      ),
    );
  }
}
