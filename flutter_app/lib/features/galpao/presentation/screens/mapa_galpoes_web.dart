import 'package:flutter/material.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/features/galpao/domain/entities/galpao_mapa.dart';

/// Constroi um widget alternativo para web (lista de galpoes com informacoes).
/// GoogleMap nao esta disponivel na web, entao exibimos uma lista em cards.
Widget buildMapWidget({
  required BuildContext context,
  required GranjaInfo granja,
  required void Function(String galpaoId) onGalpaoTap,
}) {
  final theme = Theme.of(context);

  return ListView.builder(
    padding: const EdgeInsets.all(16),
    itemCount: granja.galpoes.length,
    itemBuilder: (context, index) {
      final galpao = granja.galpoes[index];
      return _GalpaoListCard(
        galpao: galpao,
        theme: theme,
        onTap: () => onGalpaoTap(galpao.id),
      );
    },
  );
}

class _GalpaoListCard extends StatelessWidget {
  const _GalpaoListCard({
    required this.galpao,
    required this.theme,
    required this.onTap,
  });

  final GalpaoMapa galpao;
  final ThemeData theme;
  final VoidCallback onTap;

  Color _statusColor(String? status) {
    switch (status) {
      case 'ok':
        return AppColors.success;
      case 'alerta':
        return AppColors.warning;
      case 'critico':
        return AppColors.danger;
      default:
        return AppColors.gray400;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = galpao.iot?.status;
    final statusColor = _statusColor(status);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: statusColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      galpao.nome,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.gray400,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${galpao.larguraM.toStringAsFixed(0)}x'
                '${galpao.comprimentoM.toStringAsFixed(0)}m',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              if (galpao.loteAtivo != null) ...[
                const SizedBox(height: 4),
                Text(
                  '${galpao.loteAtivo!.avesVivas} aves - '
                  'Dia ${galpao.loteAtivo!.diasDeVida}',
                  style: theme.textTheme.bodyMedium,
                ),
              ] else ...[
                const SizedBox(height: 4),
                Text(
                  'Sem lote ativo',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
              if (galpao.iot != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (galpao.iot!.temperatura != null) ...[
                      Icon(Icons.thermostat, size: 16, color: AppColors.gray500),
                      const SizedBox(width: 4),
                      Text(
                        '${galpao.iot!.temperatura!.toStringAsFixed(1)} C',
                        style: theme.textTheme.bodySmall,
                      ),
                      const SizedBox(width: 16),
                    ],
                    if (galpao.iot!.umidade != null) ...[
                      Icon(Icons.water_drop, size: 16, color: AppColors.gray500),
                      const SizedBox(width: 4),
                      Text(
                        '${galpao.iot!.umidade!.toStringAsFixed(0)}% UR',
                        style: theme.textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
