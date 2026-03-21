import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/features/relatorios/domain/entities/lote_comparativo.dart';
import '../providers/relatorios_provider.dart';

/// Tela de comparativo entre lotes.
///
/// Permite selecionar multiplos lotes, comparar indicadores
/// lado a lado e exibir grafico de evolucao do IEP.
class ComparativoLotesScreen extends ConsumerStatefulWidget {
  const ComparativoLotesScreen({super.key});

  @override
  ConsumerState<ComparativoLotesScreen> createState() =>
      _ComparativoLotesScreenState();
}

class _ComparativoLotesScreenState
    extends ConsumerState<ComparativoLotesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      final state = ref.read(relatoriosProvider);
      if (state.lotes.isEmpty) {
        ref.read(relatoriosProvider.notifier).fetchLotes();
      }
    });
  }

  void _onComparar() {
    final selectedIds =
        ref.read(relatoriosProvider).selectedLoteIds.toList();
    ref.read(relatoriosProvider.notifier).fetchComparativo(selectedIds);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(relatoriosProvider);
    final theme = Theme.of(context);

    // Exibir SnackBar para feedback
    ref.listen<RelatoriosState>(relatoriosProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.danger,
          ),
        );
        ref.read(relatoriosProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Comparativo de Lotes'),
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(RelatoriosState state, ThemeData theme) {
    if (state.isLoading && state.lotes.isEmpty && state.comparativos.isEmpty) {
      return const SkeletonList(itemCount: 4);
    }

    if (state.errorMessage != null &&
        state.lotes.isEmpty &&
        state.comparativos.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref.read(relatoriosProvider.notifier).fetchLotes(),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ── Selecao de Lotes ─────────────────────────────────────
        Text(
          'Selecione os Lotes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Selecione pelo menos 2 lotes para comparar.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),

        // Lista de lotes com checkboxes
        ...state.lotes.map((lote) {
          final isSelected = state.selectedLoteIds.contains(lote.id);
          final statusLabel =
              lote.status == 'finalizado' ? ' (Finalizado)' : ' (Ativo)';
          final galpao =
              lote.galpaoNome != null ? ' - ${lote.galpaoNome}' : '';

          return CheckboxListTile(
            title: Text(
              '${lote.linhagem}$galpao$statusLabel',
              style: theme.textTheme.bodyMedium,
            ),
            value: isSelected,
            onChanged: (_) {
              ref
                  .read(relatoriosProvider.notifier)
                  .toggleLoteComparativo(lote.id);
            },
            dense: true,
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
          );
        }),

        const SizedBox(height: 12),

        // Chips dos selecionados
        if (state.selectedLoteIds.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: state.selectedLoteIds.map((id) {
              final lote = state.lotes.firstWhere(
                (l) => l.id == id,
                orElse: () => state.lotes.first,
              );
              return Chip(
                label: Text(lote.linhagem),
                onDeleted: () {
                  ref
                      .read(relatoriosProvider.notifier)
                      .toggleLoteComparativo(id);
                },
                deleteIconColor: AppColors.danger,
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
        ],

        // Botao Comparar
        FilledButton.icon(
          onPressed: state.selectedLoteIds.length >= 2 && !state.isLoading
              ? _onComparar
              : null,
          icon: state.isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.white,
                  ),
                )
              : const Icon(Icons.compare_arrows),
          label: Text(
            'Comparar (${state.selectedLoteIds.length} selecionados)',
          ),
          style: FilledButton.styleFrom(
            minimumSize: const Size(double.infinity, 48),
          ),
        ),
        const SizedBox(height: 24),

        // ── Resultado da Comparacao ──────────────────────────────
        if (state.comparativos.isNotEmpty) ...[
          Text(
            'Resultado da Comparacao',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          // Tabela de comparativo com scroll horizontal
          _ComparativoTable(comparativos: state.comparativos),
          const SizedBox(height: 24),

          // Grafico de evolucao do IEP
          _IepChart(comparativos: state.comparativos),
        ],
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TABELA DE COMPARATIVO
// ═══════════════════════════════════════════════════════════════════════

class _ComparativoTable extends StatelessWidget {
  const _ComparativoTable({required this.comparativos});

  final List<LoteComparativo> comparativos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Definir indicadores e funcoes de extracao
    final indicators = <_IndicatorDef>[
      _IndicatorDef(
        label: 'Peso Medio',
        getValue: (c) => c.pesoMedioG,
        format: (v) => NumberUtils.formatWeight(v),
        higherIsBetter: true,
      ),
      _IndicatorDef(
        label: 'Mortalidade %',
        getValue: (c) => c.mortalidadePct,
        format: (v) => NumberUtils.formatPercentage(v),
        higherIsBetter: false,
      ),
      _IndicatorDef(
        label: 'Conv. Alimentar',
        getValue: (c) => c.conversaoAlimentar,
        format: (v) => NumberUtils.formatDecimal(v, 2),
        higherIsBetter: false,
      ),
      _IndicatorDef(
        label: 'IEP',
        getValue: (c) => c.iep,
        format: (v) => NumberUtils.formatDecimal(v, 0),
        higherIsBetter: true,
      ),
      _IndicatorDef(
        label: 'GPD (g/dia)',
        getValue: (c) => c.gpd,
        format: (v) => NumberUtils.formatDecimal(v, 1),
        higherIsBetter: true,
      ),
      _IndicatorDef(
        label: 'Viabilidade %',
        getValue: (c) => c.viabilidadePct,
        format: (v) => NumberUtils.formatPercentage(v),
        higherIsBetter: true,
      ),
    ];

    return Card(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          headingRowColor: WidgetStateProperty.all(
            theme.colorScheme.primary.withAlpha(15),
          ),
          columns: [
            const DataColumn(label: Text('Indicador')),
            ...comparativos.map(
              (c) => DataColumn(
                label: Text(
                  c.loteNome,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
          rows: indicators.map((indicator) {
            final values =
                comparativos.map((c) => indicator.getValue(c)).toList();
            final best = indicator.higherIsBetter
                ? values.reduce(
                    (a, b) => a >= b ? a : b)
                : values.reduce(
                    (a, b) => a <= b ? a : b);
            final worst = indicator.higherIsBetter
                ? values.reduce(
                    (a, b) => a <= b ? a : b)
                : values.reduce(
                    (a, b) => a >= b ? a : b);

            return DataRow(
              cells: [
                DataCell(
                  Text(
                    indicator.label,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                ...comparativos.map((c) {
                  final val = indicator.getValue(c);
                  final isBest = val == best;
                  final isWorst = val == worst && comparativos.length > 1;

                  Color? color;
                  if (isBest) {
                    color = AppColors.success;
                  } else if (isWorst) {
                    color = AppColors.danger;
                  }

                  return DataCell(
                    Text(
                      indicator.format(val),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight:
                            isBest ? FontWeight.w700 : FontWeight.normal,
                        color: color,
                      ),
                    ),
                  );
                }),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

/// Definicao de indicador para a tabela de comparativo.
class _IndicatorDef {
  final String label;
  final double Function(LoteComparativo) getValue;
  final String Function(double) format;
  final bool higherIsBetter;

  const _IndicatorDef({
    required this.label,
    required this.getValue,
    required this.format,
    required this.higherIsBetter,
  });
}

// ═══════════════════════════════════════════════════════════════════════
// GRAFICO IEP
// ═══════════════════════════════════════════════════════════════════════

class _IepChart extends StatelessWidget {
  const _IepChart({required this.comparativos});

  final List<LoteComparativo> comparativos;

  /// Cores para cada linha do grafico.
  static const _chartColors = [
    AppColors.secondary,
    AppColors.success,
    AppColors.warning,
    AppColors.danger,
    AppColors.primaryLight,
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (comparativos.isEmpty) return const SizedBox.shrink();

    // Cada lote vira um ponto no eixo X; o eixo Y e o IEP.
    final spots = <LineChartBarData>[];
    for (var i = 0; i < comparativos.length; i++) {
      final color = _chartColors[i % _chartColors.length];
      spots.add(
        LineChartBarData(
          spots: [FlSpot(i.toDouble(), comparativos[i].iep)],
          isCurved: false,
          color: color,
          barWidth: 0,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
              radius: 6,
              color: color,
              strokeWidth: 2,
              strokeColor: AppColors.white,
            ),
          ),
        ),
      );
    }

    // Linha conectando todos os pontos
    final connectedSpots = comparativos
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.iep))
        .toList();

    double maxY = 0;
    double minY = double.infinity;
    for (final c in comparativos) {
      if (c.iep > maxY) maxY = c.iep;
      if (c.iep < minY) minY = c.iep;
    }
    maxY = (maxY * 1.15).ceilToDouble();
    minY = (minY * 0.85).floorToDouble();
    if (minY < 0) minY = 0;
    if (maxY <= minY) maxY = minY + 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Evolucao do IEP',
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: (maxY - minY) / 5,
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
                        reservedSize: 40,
                        interval: 1,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= comparativos.length) {
                            return const SizedBox.shrink();
                          }
                          return Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              comparativos[idx].loteNome,
                              style: const TextStyle(fontSize: 9),
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 44,
                        interval: (maxY - minY) / 5,
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
                  maxX: (comparativos.length - 1).toDouble().clamp(
                      0, double.infinity),
                  minY: minY,
                  maxY: maxY,
                  lineBarsData: [
                    // Linha principal conectando todos os lotes
                    LineChartBarData(
                      spots: connectedSpots,
                      isCurved: true,
                      color: AppColors.secondary,
                      barWidth: 2,
                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, bar, index) {
                          final color =
                              _chartColors[index % _chartColors.length];
                          return FlDotCirclePainter(
                            radius: 5,
                            color: color,
                            strokeWidth: 2,
                            strokeColor: AppColors.white,
                          );
                        },
                      ),
                      belowBarData: BarAreaData(
                        show: true,
                        color: AppColors.secondary.withAlpha(20),
                      ),
                    ),
                  ],
                  lineTouchData: LineTouchData(
                    touchTooltipData: LineTouchTooltipData(
                      getTooltipItems: (touchedSpots) {
                        return touchedSpots.map((spot) {
                          final idx = spot.x.toInt();
                          final nome = idx < comparativos.length
                              ? comparativos[idx].loteNome
                              : '';
                          return LineTooltipItem(
                            '$nome\nIEP: ${spot.y.toStringAsFixed(0)}',
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
            const SizedBox(height: 12),
            // Legenda
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: comparativos.asMap().entries.map((entry) {
                final color =
                    _chartColors[entry.key % _chartColors.length];
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      entry.value.loteNome,
                      style: theme.textTheme.labelSmall,
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
