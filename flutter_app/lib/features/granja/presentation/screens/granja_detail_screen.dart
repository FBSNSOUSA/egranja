import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart' as ew;
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart'
    show SkeletonList;
import 'package:egranja_flutter/features/granja/domain/entities/granja.dart';
import 'package:egranja_flutter/features/granja/presentation/providers/granja_provider.dart';

/// Tela de detalhes de uma granja.
///
/// Exibe informacoes da granja, lista de galpoes e resumo de lotes ativos.
class GranjaDetailScreen extends ConsumerWidget {
  const GranjaDetailScreen({super.key, required this.granjaId});

  final String granjaId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final granjaAsync = ref.watch(granjaDetailProvider(granjaId));

    return granjaAsync.when(
      loading: () => const SkeletonList(itemCount: 4),
      error: (error, _) => ew.AppErrorWidget(
        message: error.toString(),
        onRetry: () => ref.invalidate(granjaDetailProvider(granjaId)),
      ),
      data: (granja) => _GranjaDetailContent(granja: granja),
    );
  }
}

class _GranjaDetailContent extends StatelessWidget {
  const _GranjaDetailContent({required this.granja});

  final Granja granja;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Cabecalho ────────────────────────────────────────────────
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(20),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.agriculture,
                          color: AppColors.primary,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              granja.nome,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            if (granja.enderecoFormatado.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: AppColors.gray500,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      granja.enderecoFormatado,
                                      style: theme.textTheme.bodyMedium
                                          ?.copyWith(color: AppColors.gray600),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Indicadores
                  Row(
                    children: [
                      Expanded(
                        child: _InfoTile(
                          label: 'Galpoes',
                          value: '${granja.totalGalpaos}',
                          icon: Icons.warehouse_outlined,
                        ),
                      ),
                      Expanded(
                        child: _InfoTile(
                          label: 'Lotes Ativos',
                          value: '${granja.totalLotesAtivos}',
                          icon: Icons.inventory_2_outlined,
                        ),
                      ),
                      Expanded(
                        child: _InfoTile(
                          label: 'Permissao',
                          value: _formatPermissao(granja.permissao),
                          icon: Icons.security_outlined,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Localizacao ─────────────────────────────────────────────
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Localizacao',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (granja.temLocalizacao)
                    Container(
                      height: 160,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gray300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.map_outlined,
                              size: 32,
                              color: AppColors.gray400,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${granja.latitude!.toStringAsFixed(4)}, ${granja.longitude!.toStringAsFixed(4)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppColors.gray600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppColors.gray100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.gray300,
                          style: BorderStyle.solid,
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Localizacao nao informada',
                          style: TextStyle(color: AppColors.gray500),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ── Acoes rapidas ───────────────────────────────────────────
          Card(
            elevation: 1,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.warehouse_outlined,
                      color: AppColors.primary),
                  title: const Text('Ver Galpoes'),
                  subtitle:
                      Text('${granja.totalGalpaos} galpoes nesta granja'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(RouteNames.mapaGalpoes),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.edit_outlined,
                      color: AppColors.secondary),
                  title: const Text('Editar Granja'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => context.goNamed(
                    RouteNames.granjaFormEdit,
                    pathParameters: {'granjaId': granja.id},
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatPermissao(String? permissao) {
    switch (permissao) {
      case 'proprietario':
        return 'Proprietario';
      case 'editor':
        return 'Editor';
      case 'visualizador':
        return 'Visualizador';
      default:
        return permissao ?? '-';
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppColors.gray500, size: 20),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.gray800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 11,
            color: AppColors.gray500,
          ),
        ),
      ],
    );
  }
}
