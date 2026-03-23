import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';
import 'package:egranja_flutter/features/iot/domain/entities/iot_device.dart';
import 'package:egranja_flutter/features/iot/presentation/providers/iot_config_provider.dart';

/// Tipos de sensor disponiveis para configuracao.
const _sensorTypes = <String, String>{
  'temperatura': 'Temperatura',
  'umidade': 'Umidade',
  'amonia': 'Amonia (NH\u2083)',
  'co2': 'CO\u2082',
  'luminosidade': 'Luminosidade',
  'pressao': 'Pressao',
};

/// Icones por tipo de sensor.
const _sensorIcons = <String, IconData>{
  'temperatura': Icons.device_thermostat,
  'umidade': Icons.water_drop,
  'amonia': Icons.science,
  'co2': Icons.co2,
  'luminosidade': Icons.light_mode,
  'pressao': Icons.speed,
};

/// Tela de configuracao de dispositivos/sensores IoT.
///
/// Permite listar, adicionar, editar, excluir e ativar/desativar sensores.
/// Exibe status de conexao e ultima leitura de cada sensor.
class IoTConfigScreen extends ConsumerStatefulWidget {
  const IoTConfigScreen({super.key});

  @override
  ConsumerState<IoTConfigScreen> createState() => _IoTConfigScreenState();
}

class _IoTConfigScreenState extends ConsumerState<IoTConfigScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(iotConfigProvider.notifier).fetch();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(iotConfigProvider.notifier).fetch();
  }

  void _showAddDeviceDialog() {
    _showDeviceDialog(context, ref);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(iotConfigProvider);
    final theme = Theme.of(context);

    // Escutar mensagens de sucesso
    ref.listen<IoTConfigState>(iotConfigProvider, (prev, next) {
      if (next.successMessage != null &&
          next.successMessage != prev?.successMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(iotConfigProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null &&
          next.errorMessage != prev?.errorMessage &&
          next.devices.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.danger,
          ),
        );
        ref.read(iotConfigProvider.notifier).clearMessages();
      }
    });

    return Stack(
      children: [
        _buildBody(state, theme),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: _showAddDeviceDialog,
            icon: const Icon(Icons.add),
            label: const Text('Novo Sensor'),
          ),
        ),
      ],
    );
  }

  Widget _buildBody(IoTConfigState state, ThemeData theme) {
    if (state.isLoading && state.devices.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 4),
      );
    }

    if (state.errorMessage != null && state.devices.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: _onRefresh,
      );
    }

    if (state.devices.isEmpty) {
      return const EmptyState(
        icon: Icons.sensors_off,
        titulo: 'Nenhum sensor configurado',
        descricao:
            'Adicione sensores IoT para monitorar temperatura, '
            'umidade e outros parametros dos galpoes.',
      );
    }

    // Agrupar por status
    final ativos = state.devices.where((d) => d.ativo).toList();
    final inativos = state.devices.where((d) => !d.ativo).toList();
    final online = ativos.where((d) => !d.isOffline).length;

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        children: [
          // Resumo
          _buildSummaryCard(
            theme,
            total: state.devices.length,
            ativos: ativos.length,
            online: online,
          ),
          const SizedBox(height: 16),

          // Sensores ativos
          if (ativos.isNotEmpty) ...[
            _buildSectionHeader('Sensores Ativos', ativos.length, theme),
            const SizedBox(height: 8),
            ...ativos.map((d) => _DeviceCard(
                  device: d,
                  onEdit: () => _showDeviceDialog(context, ref, device: d),
                  onDelete: () => _confirmDelete(d),
                  onToggle: () =>
                      ref.read(iotConfigProvider.notifier).toggleDevice(d.id),
                )),
          ],

          // Sensores inativos
          if (inativos.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader('Sensores Inativos', inativos.length, theme),
            const SizedBox(height: 8),
            ...inativos.map((d) => _DeviceCard(
                  device: d,
                  onEdit: () => _showDeviceDialog(context, ref, device: d),
                  onDelete: () => _confirmDelete(d),
                  onToggle: () =>
                      ref.read(iotConfigProvider.notifier).toggleDevice(d.id),
                )),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryCard(
    ThemeData theme, {
    required int total,
    required int ativos,
    required int online,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _SummaryItem(
              icon: Icons.sensors,
              label: 'Total',
              value: total.toString(),
              color: AppColors.tertiary,
            ),
            _SummaryItem(
              icon: Icons.check_circle_outline,
              label: 'Ativos',
              value: ativos.toString(),
              color: AppColors.success,
            ),
            _SummaryItem(
              icon: Icons.wifi,
              label: 'Online',
              value: online.toString(),
              color: AppColors.primary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count, ThemeData theme) {
    return Row(
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.gray200,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            count.toString(),
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _confirmDelete(IoTDevice device) {
    showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Remover sensor'),
        content: Text(
          'Deseja remover o sensor "${device.nome}"? '
          'Esta acao nao pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop(true);
              ref.read(iotConfigProvider.notifier).deleteDevice(device.id);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.danger,
            ),
            child: const Text('Remover'),
          ),
        ],
      ),
    );
  }
}

// ── Dialog de Adicionar/Editar ──────────────────────────────────────────

void _showDeviceDialog(
  BuildContext context,
  WidgetRef ref, {
  IoTDevice? device,
}) {
  showDialog(
    context: context,
    builder: (dialogContext) => _DeviceFormDialog(
      ref: ref,
      device: device,
    ),
  );
}

class _DeviceFormDialog extends StatefulWidget {
  const _DeviceFormDialog({
    required this.ref,
    this.device,
  });

  final WidgetRef ref;
  final IoTDevice? device;

  @override
  State<_DeviceFormDialog> createState() => _DeviceFormDialogState();
}

class _DeviceFormDialogState extends State<_DeviceFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nomeController;
  late final TextEditingController _mqttTopicController;
  String _selectedTipo = 'temperatura';
  String? _selectedGalpaoId;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.device != null;
    _nomeController = TextEditingController(text: widget.device?.nome ?? '');
    _mqttTopicController =
        TextEditingController(text: widget.device?.mqttTopic ?? '');
    _selectedTipo = widget.device?.tipo ?? 'temperatura';
    _selectedGalpaoId = widget.device?.galpaoId;
    if (_selectedGalpaoId != null && _selectedGalpaoId!.isEmpty) {
      _selectedGalpaoId = null;
    }
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _mqttTopicController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final notifier = widget.ref.read(iotConfigProvider.notifier);
    bool success;

    if (_isEditing) {
      success = await notifier.updateDevice(
        deviceId: widget.device!.id,
        nome: _nomeController.text.trim(),
        tipo: _selectedTipo,
        galpaoId: _selectedGalpaoId ?? '',
        mqttTopic: _mqttTopicController.text.trim(),
        ativo: widget.device!.ativo,
      );
    } else {
      success = await notifier.addDevice(
        nome: _nomeController.text.trim(),
        tipo: _selectedTipo,
        galpaoId: _selectedGalpaoId ?? '',
        mqttTopic: _mqttTopicController.text.trim(),
      );
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final galpaosAsync = widget.ref.watch(galpaosProvider);
    final configState = widget.ref.watch(iotConfigProvider);
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(_isEditing ? 'Editar Sensor' : 'Novo Sensor'),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nome
                TextFormField(
                  controller: _nomeController,
                  decoration: const InputDecoration(
                    labelText: 'Nome do sensor',
                    hintText: 'Ex: Sensor Temp Galpao 1',
                    prefixIcon: Icon(Icons.label_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o nome do sensor';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Tipo de sensor
                DropdownButtonFormField<String>(
                  initialValue: _selectedTipo,
                  decoration: const InputDecoration(
                    labelText: 'Tipo',
                    prefixIcon: Icon(Icons.category_outlined),
                    border: OutlineInputBorder(),
                  ),
                  items: _sensorTypes.entries
                      .map((e) => DropdownMenuItem(
                            value: e.key,
                            child: Row(
                              children: [
                                Icon(
                                  _sensorIcons[e.key] ?? Icons.sensors,
                                  size: 18,
                                  color: AppColors.gray600,
                                ),
                                const SizedBox(width: 8),
                                Text(e.value),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTipo = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),

                // Galpao
                galpaosAsync.when(
                  data: (galpoes) {
                    return DropdownButtonFormField<String>(
                      initialValue: galpoes.any((g) => g.id == _selectedGalpaoId)
                          ? _selectedGalpaoId
                          : null,
                      decoration: const InputDecoration(
                        labelText: 'Galpao',
                        prefixIcon: Icon(Icons.warehouse_outlined),
                        border: OutlineInputBorder(),
                      ),
                      items: galpoes
                          .map((g) => DropdownMenuItem(
                                value: g.id,
                                child: Text(g.nome),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedGalpaoId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione um galpao';
                        }
                        return null;
                      },
                    );
                  },
                  loading: () => const LinearProgressIndicator(),
                  error: (_, _) => Text(
                    'Erro ao carregar galpoes',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.danger,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // MQTT Topic
                TextFormField(
                  controller: _mqttTopicController,
                  decoration: const InputDecoration(
                    labelText: 'Topico MQTT',
                    hintText: 'egranja/{galpaoId}/sensors',
                    prefixIcon: Icon(Icons.router_outlined),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o topico MQTT';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: configState.isSaving ? null : _onSave,
          child: configState.isSaving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Text(_isEditing ? 'Salvar' : 'Adicionar'),
        ),
      ],
    );
  }
}

// ── Card de Dispositivo ─────────────────────────────────────────────────

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({
    required this.device,
    required this.onEdit,
    required this.onDelete,
    required this.onToggle,
  });

  final IoTDevice device;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isOnline = !device.isOffline && device.ativo;
    final statusColor = isOnline ? AppColors.success : AppColors.gray400;
    final statusLabel = device.ativo
        ? (isOnline ? 'Online' : 'Offline')
        : 'Inativo';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          // Barra de status no topo
          Container(
            height: 3,
            color: device.ativo ? statusColor : AppColors.gray300,
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
            child: Row(
              children: [
                // Icone do tipo
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: device.ativo
                        ? statusColor.withAlpha(20)
                        : AppColors.gray100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _sensorIcons[device.tipo] ?? Icons.sensors,
                    color: device.ativo ? statusColor : AppColors.gray400,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nome + badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              device.nome,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: device.ativo
                                    ? null
                                    : AppColors.textSecondary,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: statusColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  statusLabel,
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: statusColor,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),

                      // Tipo + galpao
                      Text(
                        '${_sensorTypes[device.tipo] ?? device.tipo}'
                        '${device.galpaoNome.isNotEmpty ? ' - ${device.galpaoNome}' : ''}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),

                      // Ultima leitura
                      if (device.ultimaLeitura != null) ...[
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Text(
                              'Ultima: ${device.ultimaLeitura!.toStringAsFixed(1)} ${device.unidade}',
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            if (device.ultimaLeituraTimestamp != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                _formatTimestamp(device.ultimaLeituraTimestamp!),
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: AppColors.gray500,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],

                      // MQTT topic
                      if (device.mqttTopic.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'MQTT: ${device.mqttTopic}',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.gray500,
                            fontSize: 10,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Menu de acoes
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'edit':
                        onEdit();
                        break;
                      case 'toggle':
                        onToggle();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: ListTile(
                        leading: Icon(Icons.edit_outlined),
                        title: Text('Editar'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: ListTile(
                        leading: Icon(
                          device.ativo
                              ? Icons.pause_circle_outline
                              : Icons.play_circle_outline,
                        ),
                        title: Text(device.ativo ? 'Desativar' : 'Ativar'),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: ListTile(
                        leading: Icon(Icons.delete_outline, color: AppColors.danger),
                        title: Text(
                          'Remover',
                          style: TextStyle(color: AppColors.danger),
                        ),
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime ts) {
    final diff = DateTime.now().difference(ts);
    if (diff.inMinutes < 1) return 'agora';
    if (diff.inMinutes < 60) return 'ha ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'ha ${diff.inHours}h';
    return 'ha ${diff.inDays}d';
  }
}

// ── Widget auxiliar ─────────────────────────────────────────────────────

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
