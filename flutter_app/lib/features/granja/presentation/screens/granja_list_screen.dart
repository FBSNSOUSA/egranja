import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart' as ew;
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart'
    show SkeletonList;
import 'package:egranja_flutter/features/granja/domain/entities/granja.dart';
import 'package:egranja_flutter/features/granja/presentation/providers/granja_provider.dart';

/// Tela de listagem de granjas.
///
/// Exibe todas as granjas acessiveis pelo usuario autenticado,
/// com pull-to-refresh e FAB para criar nova granja.
class GranjaListScreen extends ConsumerStatefulWidget {
  const GranjaListScreen({super.key});

  @override
  ConsumerState<GranjaListScreen> createState() => _GranjaListScreenState();
}

class _GranjaListScreenState extends ConsumerState<GranjaListScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(granjaListProvider.notifier).fetchGranjas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(granjaListProvider);

    return Stack(
      children: [
        _buildBody(state),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () => context.goNamed(RouteNames.granjaForm),
            icon: const Icon(Icons.add),
            label: const Text('Nova Granja'),
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildBody(GranjaListState state) {
    if (state.isLoading && state.granjas.isEmpty) {
      return const SkeletonList(itemCount: 3);
    }

    if (state.error != null && state.granjas.isEmpty) {
      return ew.AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(granjaListProvider.notifier).fetchGranjas(),
      );
    }

    if (state.granjas.isEmpty) {
      return EmptyState(
        icon: Icons.agriculture_outlined,
        titulo: 'Nenhuma granja cadastrada',
        descricao: 'Cadastre sua primeira granja para comecar.',
        actionLabel: 'Nova Granja',
        onAction: () => context.goNamed(RouteNames.granjaForm),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(granjaListProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.granjas.length,
        itemBuilder: (context, index) {
          final granja = state.granjas[index];
          return _GranjaCard(
            granja: granja,
            onTap: () => context.goNamed(
              RouteNames.granjaDetail,
              pathParameters: {'granjaId': granja.id},
            ),
          );
        },
      ),
    );
  }
}

/// Card que exibe informacoes resumidas de uma granja.
class _GranjaCard extends StatelessWidget {
  const _GranjaCard({
    required this.granja,
    required this.onTap,
  });

  final Granja granja;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cabecalho: nome + badge de permissao
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.agriculture,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          granja.nome,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (granja.enderecoFormatado.isNotEmpty)
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: AppColors.gray500,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  granja.enderecoFormatado,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.gray600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  if (granja.permissao != null)
                    _PermissaoBadge(permissao: granja.permissao!),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Indicadores resumidos
              Row(
                children: [
                  _IndicadorResumo(
                    icon: Icons.warehouse_outlined,
                    label: 'Galpoes',
                    value: '${granja.totalGalpaos}',
                  ),
                  const SizedBox(width: 24),
                  _IndicadorResumo(
                    icon: Icons.inventory_2_outlined,
                    label: 'Lotes Ativos',
                    value: '${granja.totalLotesAtivos}',
                    valueColor: granja.totalLotesAtivos > 0
                        ? AppColors.success
                        : AppColors.gray500,
                  ),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    color: AppColors.gray400,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissaoBadge extends StatelessWidget {
  const _PermissaoBadge({required this.permissao});

  final String permissao;

  @override
  Widget build(BuildContext context) {
    final Color bgColor;
    final Color textColor;
    final String label;

    switch (permissao) {
      case 'proprietario':
        bgColor = AppColors.primaryLight.withAlpha(40);
        textColor = AppColors.primaryDark;
        label = 'Proprietario';
      case 'editor':
        bgColor = AppColors.infoLight;
        textColor = AppColors.info;
        label = 'Editor';
      case 'visualizador':
        bgColor = AppColors.gray200;
        textColor = AppColors.gray700;
        label = 'Visualizador';
      default:
        bgColor = AppColors.gray200;
        textColor = AppColors.gray700;
        label = permissao;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _IndicadorResumo extends StatelessWidget {
  const _IndicadorResumo({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: AppColors.gray500),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.gray600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.gray800,
          ),
        ),
      ],
    );
  }
}
