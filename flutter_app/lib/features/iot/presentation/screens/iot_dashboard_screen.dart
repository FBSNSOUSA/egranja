import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';
import 'package:egranja_flutter/features/home/domain/entities/galpao.dart';
import 'package:egranja_flutter/features/iot/domain/entities/sensor_data.dart';
import 'package:egranja_flutter/features/iot/presentation/providers/iot_dashboard_provider.dart';

/// Configuracao visual de cada tipo de sensor.
class _SensorConfig {
  final IconData icon;
  final String label;
  final String unit;

  const _SensorConfig({
    required this.icon,
    required this.label,
    required this.unit,
  });
}

/// Mapa de configuracoes por tipo de sensor.
const _sensorConfigs = <String, _SensorConfig>{
  'temperatura': _SensorConfig(
    icon: Icons.device_thermostat,
    label: 'Temperatura',
    unit: '\u00B0C',
  ),
  'umidade': _SensorConfig(
    icon: Icons.water_drop,
    label: 'Umidade',
    unit: '%',
  ),
  'co2': _SensorConfig(
    icon: Icons.co2,
    label: 'CO\u2082',
    unit: 'ppm',
  ),
  'amonia': _SensorConfig(
    icon: Icons.science,
    label: 'Amonia',
    unit: 'ppm',
  ),
  'luminosidade': _SensorConfig(
    icon: Icons.light_mode,
    label: 'Luminosidade',
    unit: 'lux',
  ),
  'pressao': _SensorConfig(
    icon: Icons.speed,
    label: 'Pressao',
    unit: 'Pa',
  ),
};

/// Tela principal de monitoramento de sensores IoT.
///
/// Exibe leituras em tempo real de ate 6 sensores de um galpao
/// selecionado, com auto-refresh a cada 30 segundos.
class IoTDashboardScreen extends ConsumerStatefulWidget {
  const IoTDashboardScreen({super.key, this.galpaoId});

  /// ID do galpao pre-selecionado (via query parameter).
  final String? galpaoId;

  @override
  ConsumerState<IoTDashboardScreen> createState() => _IoTDashboardScreenState();
}

class _IoTDashboardScreenState extends ConsumerState<IoTDashboardScreen> {
  String? _selectedGalpaoId;

  @override
  void initState() {
    super.initState();
    _selectedGalpaoId = widget.galpaoId;

    if (_selectedGalpaoId != null && _selectedGalpaoId!.isNotEmpty) {
      Future.microtask(() {
        final notifier =
            ref.read(iotDashboardProvider(_selectedGalpaoId!).notifier);
        notifier.fetch();
        notifier.startAutoRefresh();
      });
    }
  }

  void _onGalpaoChanged(String? galpaoId) {
    if (galpaoId == null || galpaoId == _selectedGalpaoId) return;
    setState(() {
      _selectedGalpaoId = galpaoId;
    });
    final notifier = ref.read(iotDashboardProvider(galpaoId).notifier);
    notifier.fetch();
    notifier.startAutoRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final galpaosAsync = ref.watch(galpaosProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Barra de acoes (anteriormente no AppBar)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            border: const Border(
              bottom: BorderSide(color: AppColors.divider),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                tooltip: 'Configuracao',
                onPressed: () => context.pushNamed(RouteNames.iotConfig),
              ),
              IconButton(
                icon: const Icon(Icons.history),
                tooltip: 'Historico',
                onPressed: _selectedGalpaoId != null &&
                        _selectedGalpaoId!.isNotEmpty
                    ? () => context.pushNamed(
                          RouteNames.iotHistorico,
                          queryParameters: {'galpaoId': _selectedGalpaoId!},
                        )
                    : null,
              ),
            ],
          ),
        ),

        // Seletor de galpao
        _buildGalpaoSelector(galpaosAsync, theme),

        // Conteudo principal
        Expanded(
          child: _buildBody(theme),
        ),
      ],
    );
  }

  /// Dropdown para selecao de galpao.
  Widget _buildGalpaoSelector(
    AsyncValue<List<Galpao>> galpaosAsync,
    ThemeData theme,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: const Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: galpaosAsync.when(
        data: (galpoes) {
          // Se veio com galpaoId mas nao esta na lista, limpar
          if (_selectedGalpaoId != null &&
              _selectedGalpaoId!.isNotEmpty &&
              galpoes.isNotEmpty &&
              !galpoes.any((g) => g.id == _selectedGalpaoId)) {
            Future.microtask(() {
              setState(() {
                _selectedGalpaoId = galpoes.first.id;
              });
              final notifier =
                  ref.read(iotDashboardProvider(galpoes.first.id).notifier);
              notifier.fetch();
              notifier.startAutoRefresh();
            });
          }

          // Se nenhum foi selecionado e ha galpoes, selecionar o primeiro
          if ((_selectedGalpaoId == null || _selectedGalpaoId!.isEmpty) &&
              galpoes.isNotEmpty) {
            Future.microtask(() {
              setState(() {
                _selectedGalpaoId = galpoes.first.id;
              });
              final notifier =
                  ref.read(iotDashboardProvider(galpoes.first.id).notifier);
              notifier.fetch();
              notifier.startAutoRefresh();
            });
          }

          final currentValue = galpoes.any((g) => g.id == _selectedGalpaoId)
              ? _selectedGalpaoId
              : null;
          return DropdownMenu<String>(
            initialSelection: currentValue,
            expandedInsets: EdgeInsets.zero,
            label: const Text('Galpao'),
            inputDecorationTheme: const InputDecorationTheme(
              border: OutlineInputBorder(),
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              isDense: true,
            ),
            dropdownMenuEntries: galpoes
                .map((g) => DropdownMenuEntry<String>(
                      value: g.id,
                      label: g.nome,
                    ))
                .toList(),
            onSelected: _onGalpaoChanged,
          );
        },
        loading: () => const LinearProgressIndicator(),
        error: (e, _) => Text(
          'Erro ao carregar galpoes',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: AppColors.danger,
          ),
        ),
      ),
    );
  }

  /// Corpo principal com sensores ou estados alternativos.
  Widget _buildBody(ThemeData theme) {
    if (_selectedGalpaoId == null || _selectedGalpaoId!.isEmpty) {
      return const EmptyState(
        icon: Icons.sensors,
        titulo: 'Selecione um galpao',
        descricao: 'Escolha um galpao para visualizar os sensores IoT.',
      );
    }

    final state = ref.watch(iotDashboardProvider(_selectedGalpaoId!));

    // Loading
    if (state.isLoading && state.sensores.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    // Erro sem dados
    if (state.errorMessage != null && state.sensores.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref
            .read(iotDashboardProvider(_selectedGalpaoId!).notifier)
            .fetch(),
      );
    }

    // Sem sensores
    if (state.sensores.isEmpty) {
      return const EmptyState(
        icon: Icons.sensors_off,
        titulo: 'Nenhum sensor encontrado',
        descricao:
            'Este galpao nao possui sensores IoT configurados.',
      );
    }

    // Dados carregados
    return RefreshIndicator(
      onRefresh: () => ref
          .read(iotDashboardProvider(_selectedGalpaoId!).notifier)
          .fetch(),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badge "Ao vivo" + ultima leitura
            _buildLiveHeader(state, theme),
            const SizedBox(height: 16),

            // Grid de sensores (2 colunas)
            _buildSensorGrid(state.sensores),
          ],
        ),
      ),
    );
  }

  /// Header com indicador "Ao vivo" e timestamp da ultima leitura.
  Widget _buildLiveHeader(IoTDashboardState state, ThemeData theme) {
    final minutosAtras = state.ultimaLeitura != null
        ? DateTime.now().difference(state.ultimaLeitura!).inMinutes
        : 0;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.successLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Pulsing "Ao vivo" badge
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: AppColors.success,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.success.withValues(alpha: 0.4),
                  blurRadius: 6,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'Ao vivo',
            style: theme.textTheme.labelMedium?.copyWith(
              color: AppColors.success,
              fontWeight: FontWeight.w700,
            ),
          ),
          const Spacer(),
          // Timestamp
          if (state.ultimaLeitura != null)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: AppColors.success.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  '$minutosAtras min atras',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.success.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  /// Grid 2 colunas de cards de sensores.
  Widget _buildSensorGrid(List<SensorData> sensores) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: sensores.length,
      itemBuilder: (context, index) {
        return _SensorCard(sensor: sensores[index]);
      },
    );
  }
}

/// Card individual de sensor com barra de status, valor, badge e sparkline.
class _SensorCard extends StatelessWidget {
  const _SensorCard({required this.sensor});

  final SensorData sensor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final config = _sensorConfigs[sensor.tipo];
    final statusColor = _getStatusColor(sensor.status);
    final statusLabel = _getStatusLabel(sensor.status);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Barra de status no topo
          Container(
            height: 4,
            color: statusColor,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icone + label
                  Row(
                    children: [
                      Icon(
                        config?.icon ?? Icons.sensors,
                        size: 18,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          config?.label ?? sensor.tipo,
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Valor grande + unidade
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        sensor.valor.toStringAsFixed(1),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: statusColor,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        config?.unit ?? sensor.unidade,
                        style: theme.textTheme.labelMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Badge de status
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withAlpha(30),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      statusLabel,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Mini sparkline (ultimas 24h)
                  if (sensor.historico24h.isNotEmpty)
                    SizedBox(
                      height: 36,
                      child: _MiniSparkline(
                        data: sensor.historico24h,
                        color: statusColor,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna a cor correspondente ao status do sensor.
  Color _getStatusColor(String status) {
    switch (status) {
      case 'atencao':
        return AppColors.warning;
      case 'critico':
        return AppColors.danger;
      case 'normal':
      default:
        return AppColors.success;
    }
  }

  /// Retorna o label exibido no badge de status.
  String _getStatusLabel(String status) {
    switch (status) {
      case 'atencao':
        return 'Atencao';
      case 'critico':
        return 'Critico';
      case 'normal':
      default:
        return 'Normal';
    }
  }
}

/// Sparkline simplificado usando fl_chart.
class _MiniSparkline extends StatelessWidget {
  const _MiniSparkline({
    required this.data,
    required this.color,
  });

  final List<double> data;
  final Color color;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();

    final spots = <FlSpot>[];
    for (var i = 0; i < data.length; i++) {
      spots.add(FlSpot(i.toDouble(), data[i]));
    }

    return LineChart(
      LineChartData(
        gridData: const FlGridData(show: false),
        titlesData: const FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
        clipData: const FlClipData.all(),
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 2,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: color.withAlpha(40),
            ),
          ),
        ],
      ),
    );
  }
}
