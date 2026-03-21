import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/features/clima/domain/entities/previsao.dart';
import 'package:egranja_flutter/features/clima/presentation/providers/clima_provider.dart';

/// Tela de Previsao do Tempo.
///
/// Exibe condicoes climaticas atuais, alertas, previsao de 7 dias
/// e grafico de temperatura horaria para o galpao selecionado.
/// Portada do componente React Native `ClimaScreen.tsx`.
class ClimaScreen extends ConsumerStatefulWidget {
  const ClimaScreen({super.key, this.galpaoId = ''});

  /// ID do galpao para consulta climatica.
  final String galpaoId;

  @override
  ConsumerState<ClimaScreen> createState() => _ClimaScreenState();
}

class _ClimaScreenState extends ConsumerState<ClimaScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.galpaoId.isNotEmpty) {
      Future.microtask(() {
        ref.read(climaProvider(widget.galpaoId).notifier).fetch();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.galpaoId.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Previsao do Tempo')),
        body: const EmptyState(
          icon: Icons.cloud_off,
          titulo: 'Nenhum galpao selecionado',
          descricao:
              'Selecione um galpao para ver a previsao do tempo da regiao.',
        ),
      );
    }

    final climaState = ref.watch(climaProvider(widget.galpaoId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Previsao do Tempo'),
      ),
      body: RefreshIndicator(
        onRefresh: () =>
            ref.read(climaProvider(widget.galpaoId).notifier).fetch(),
        child: _buildBody(climaState),
      ),
    );
  }

  // ── Body ────────────────────────────────────────────────────────────────

  Widget _buildBody(ClimaState climaState) {
    if (climaState.isLoading && climaState.previsao == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (climaState.errorMessage != null && climaState.previsao == null) {
      return AppErrorWidget(
        message: climaState.errorMessage!,
        onRetry: () {
          ref.read(climaProvider(widget.galpaoId).notifier).fetch();
        },
      );
    }

    if (climaState.previsao == null) {
      return ListView(
        children: const [
          SizedBox(height: 48),
          EmptyState(
            icon: Icons.cloud_off,
            titulo: 'Sem dados climaticos',
            descricao:
                'Nao foi possivel obter dados de previsao do tempo '
                'para este galpao.',
          ),
        ],
      );
    }

    final previsao = climaState.previsao!;
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        // Condicoes atuais
        _buildCurrentConditions(previsao.atual, theme),

        // Alertas climaticos
        if (climaState.alertas.isNotEmpty)
          _buildAlertasSection(climaState.alertas, theme),

        // Previsao 7 dias
        if (previsao.previsao7dias.isNotEmpty)
          _buildPrevisao7Dias(previsao.previsao7dias, theme),

        // Grafico de temperatura horaria
        if (previsao.previsaoHoraria.isNotEmpty)
          _buildHourlyChart(previsao.previsaoHoraria, theme),

        // Footer de dados
        _buildDataSourceFooter(theme),
      ],
    );
  }

  // ── Condicoes atuais ────────────────────────────────────────────────────

  Widget _buildCurrentConditions(CondicaoAtual atual, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Icone + descricao + temperatura hero
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _weatherIcon(atual.icone),
                size: 64,
                color: _weatherIconColor(atual.icone),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${atual.temperatura.toStringAsFixed(0)}\u00B0C',
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    atual.descricao,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 4),

          // Sensacao termica
          Text(
            'Sensacao termica: ${atual.sensacaoTermica.toStringAsFixed(0)}\u00B0C',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 12),

          // 3-column detail row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildDetailColumn(
                icon: Icons.water_drop,
                label: 'Umidade',
                value: '${atual.umidade.toStringAsFixed(0)}%',
                theme: theme,
              ),
              _buildDetailColumn(
                icon: Icons.air,
                label: 'Vento',
                value:
                    '${atual.ventoVelocidade.toStringAsFixed(0)} km/h ${atual.ventoDirecaoTexto}',
                theme: theme,
              ),
              _buildDetailColumn(
                icon: Icons.grain,
                label: 'Precipitacao',
                value: '${atual.precipitacao.toStringAsFixed(1)} mm',
                theme: theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailColumn({
    required IconData icon,
    required String label,
    required String value,
    required ThemeData theme,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: AppColors.secondary),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ── Alertas ────────────────────────────────────────────────────────────

  Widget _buildAlertasSection(
      List<AlertaClimatico> alertas, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Alertas',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          ...alertas.map((alerta) => _buildAlertaCard(alerta, theme)),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildAlertaCard(AlertaClimatico alerta, ThemeData theme) {
    final color = _alertaSeveridadeColor(alerta.severidade);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(color: color, width: 4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(10),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(
          _alertaIcon(alerta.tipo),
          color: color,
        ),
        title: Text(
          alerta.titulo,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          alerta.descricao,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  // ── Previsao 7 dias ────────────────────────────────────────────────────

  Widget _buildPrevisao7Dias(List<PrevisaoDia> dias, ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Text(
            'Proximos 7 dias',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: dias.length,
            itemBuilder: (context, index) {
              return _buildDayCard(dias[index], theme);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayCard(PrevisaoDia dia, ThemeData theme) {
    return SizedBox(
      width: 80,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Dia da semana
              Text(
                dia.diaSemana,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              // Data
              Text(
                _formatDayDate(dia.data),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),

              const SizedBox(height: 4),

              // Icone do tempo
              Icon(
                _weatherIcon(dia.icone),
                size: 28,
                color: _weatherIconColor(dia.icone),
              ),

              const SizedBox(height: 4),

              // Temperaturas max / min
              Text(
                '${dia.tempMax.toStringAsFixed(0)}\u00B0',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${dia.tempMin.toStringAsFixed(0)}\u00B0',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.secondary,
                ),
              ),

              const SizedBox(height: 4),

              // Probabilidade de chuva
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.water_drop,
                    size: 10,
                    color: AppColors.secondary,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    '${dia.probabilidadeChuva}%',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.secondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Grafico de temperatura horaria ─────────────────────────────────────

  Widget _buildHourlyChart(List<PrevisaoHora> horas, ThemeData theme) {
    final spots = horas
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.temperatura))
        .toList();

    // Calcular min e max Y
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    for (final h in horas) {
      if (h.temperatura < minY) minY = h.temperatura;
      if (h.temperatura > maxY) maxY = h.temperatura;
    }
    // Margem de 2 graus
    minY = (minY - 2).floorToDouble();
    maxY = (maxY + 2).ceilToDouble();
    if (minY >= maxY) {
      minY = 0;
      maxY = 40;
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Temperatura por hora',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: ((maxY - minY) / 4).clamp(1, 100),
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
                      interval: _calculateHourInterval(horas.length),
                      getTitlesWidget: (value, meta) {
                        final idx = value.toInt();
                        if (idx < 0 || idx >= horas.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            horas[idx].hora,
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
                      interval: ((maxY - minY) / 4).clamp(1, 100),
                      getTitlesWidget: (value, meta) {
                        return Text(
                          '${value.toInt()}\u00B0',
                          style: const TextStyle(fontSize: 10),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                minX: 0,
                maxX: (horas.length - 1).toDouble().clamp(0, double.infinity),
                minY: minY,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.danger,
                    barWidth: 3,
                    dotData: const FlDotData(show: false),
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
                        final hora =
                            idx >= 0 && idx < horas.length
                                ? horas[idx].hora
                                : '';
                        return LineTooltipItem(
                          '$hora\n${spot.y.toStringAsFixed(1)}\u00B0C',
                          const TextStyle(
                            color: AppColors.danger,
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
    );
  }

  double _calculateHourInterval(int count) {
    if (count <= 12) return 1;
    if (count <= 24) return 3;
    return (count / 8).ceilToDouble();
  }

  // ── Data source footer ────────────────────────────────────────────────

  Widget _buildDataSourceFooter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Text(
        'Dados de Open-Meteo',
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // ── Helpers de formatacao ─────────────────────────────────────────────

  /// Formata data "2025-01-15" para "15/01".
  String _formatDayDate(String isoDate) {
    try {
      final parts = isoDate.split('-');
      if (parts.length >= 3) {
        return '${parts[2]}/${parts[1]}';
      }
      return isoDate;
    } catch (_) {
      return isoDate;
    }
  }

  // ── Mapeamento de icones de clima ─────────────────────────────────────

  IconData _weatherIcon(String icone) {
    switch (icone) {
      case 'sol':
        return Icons.wb_sunny;
      case 'parcial':
        return Icons.wb_cloudy;
      case 'nublado':
        return Icons.cloud;
      case 'chuva':
        return Icons.grain;
      case 'tempestade':
        return Icons.thunderstorm;
      case 'neve':
        return Icons.ac_unit;
      case 'nevoeiro':
        return Icons.foggy;
      default:
        return Icons.wb_sunny;
    }
  }

  Color _weatherIconColor(String icone) {
    switch (icone) {
      case 'sol':
        return const Color(0xFFFFA726);
      case 'parcial':
        return const Color(0xFFFFB74D);
      case 'nublado':
        return AppColors.gray500;
      case 'chuva':
        return AppColors.secondary;
      case 'tempestade':
        return AppColors.gray700;
      case 'neve':
        return AppColors.secondaryLight;
      case 'nevoeiro':
        return AppColors.gray400;
      default:
        return const Color(0xFFFFA726);
    }
  }

  // ── Mapeamento de icones de alerta ────────────────────────────────────

  IconData _alertaIcon(String tipo) {
    switch (tipo) {
      case 'temperatura':
        return Icons.thermostat;
      case 'vento':
        return Icons.air;
      case 'chuva':
        return Icons.water;
      default:
        return Icons.warning_amber;
    }
  }

  Color _alertaSeveridadeColor(String severidade) {
    switch (severidade) {
      case 'baixa':
        return AppColors.warning;
      case 'media':
        return const Color(0xFFFF9800);
      case 'alta':
        return AppColors.danger;
      default:
        return AppColors.warning;
    }
  }
}
