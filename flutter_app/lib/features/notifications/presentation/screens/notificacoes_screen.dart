import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/features/notifications/domain/entities/alerta.dart';
import 'package:egranja_flutter/features/notifications/presentation/providers/alertas_provider.dart';

/// Tela de alertas/notificacoes do sistema.
///
/// Exibe todos os alertas do usuario (produtor: seus lotes,
/// tecnico: lotes vinculados) organizados por prioridade.
class NotificacoesScreen extends ConsumerStatefulWidget {
  const NotificacoesScreen({super.key});

  @override
  ConsumerState<NotificacoesScreen> createState() =>
      _NotificacoesScreenState();
}

class _NotificacoesScreenState extends ConsumerState<NotificacoesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(alertasProvider.notifier).fetchAlertas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(alertasProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildHeader(theme, state),
        Expanded(child: _buildContent(state, theme)),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, AlertasState state) {
    final medios =
        state.alertas.length - state.totalCriticos - state.totalAltos;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Alertas do Sistema',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          if (!state.isLoading && state.alertas.isNotEmpty)
            Row(
              children: [
                _CountBadge(
                  label:
                      '${state.totalCriticos} Critico${state.totalCriticos != 1 ? 's' : ''}',
                  color: AppColors.danger,
                ),
                const SizedBox(width: 8),
                _CountBadge(
                  label:
                      '${state.totalAltos} Alto${state.totalAltos != 1 ? 's' : ''}',
                  color: AppColors.warning,
                ),
                const SizedBox(width: 8),
                _CountBadge(
                  label: '$medios Medio${medios != 1 ? 's' : ''}',
                  color: AppColors.info,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildContent(AlertasState state, ThemeData theme) {
    if (state.isLoading && state.alertas.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 4),
      );
    }

    if (state.error != null && state.alertas.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(alertasProvider.notifier).fetchAlertas(),
      );
    }

    if (state.alertas.isEmpty) {
      return const EmptyState(
        icon: Icons.check_circle_outline,
        titulo: 'Nenhum alerta ativo',
        descricao:
            'Todos os indicadores estao dentro dos parametros normais.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(alertasProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        itemCount: state.alertas.length,
        itemBuilder: (context, index) {
          final alerta = state.alertas[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _AlertaCard(
              alerta: alerta,
              onTap: alerta.loteId.isNotEmpty
                  ? () => context.goNamed(
                        RouteNames.loteDetail,
                        pathParameters: {'loteId': alerta.loteId},
                      )
                  : null,
            ),
          );
        },
      ),
    );
  }
}

/// Badge com contagem por prioridade.
class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
      ),
    );
  }
}

/// Card individual de alerta com indicador de prioridade.
class _AlertaCard extends StatelessWidget {
  const _AlertaCard({required this.alerta, this.onTap});

  final Alerta alerta;
  final VoidCallback? onTap;

  Color get _prioridadeColor {
    switch (alerta.prioridade) {
      case AlertaPrioridade.critica:
        return AppColors.danger;
      case AlertaPrioridade.alta:
        return AppColors.warning;
      case AlertaPrioridade.media:
        return AppColors.info;
    }
  }

  IconData get _tipoIcon {
    switch (alerta.tipo) {
      case 'mortalidade_diaria':
      case 'mortalidade_acumulada':
        return Icons.warning_amber_rounded;
      case 'peso_abaixo':
      case 'peso_muito_abaixo':
        return Icons.monitor_weight_outlined;
      case 'queda_consumo_agua':
        return Icons.water_drop_outlined;
      case 'relacao_agua_racao':
        return Icons.balance_outlined;
      case 'racao_acabando':
        return Icons.inventory_outlined;
      case 'pesagem_atrasada':
        return Icons.scale_outlined;
      case 'checklist_pendente':
      case 'checklist_incompleto':
        return Icons.checklist_outlined;
      case 'proximo_abate':
        return Icons.event_outlined;
      default:
        return Icons.info_outlined;
    }
  }

  String get _prioridadeLabel {
    switch (alerta.prioridade) {
      case AlertaPrioridade.critica:
        return 'CRITICO';
      case AlertaPrioridade.alta:
        return 'ALTO';
      case AlertaPrioridade.media:
        return 'MEDIO';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Semantics(
      label: 'Alerta $_prioridadeLabel: ${alerta.mensagem}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 4, color: _prioridadeColor),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _prioridadeColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(_tipoIcon,
                          color: _prioridadeColor, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _prioridadeColor,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  _prioridadeLabel,
                                  style: const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                              if (alerta.galpaoNome != null) ...[
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    alerta.galpaoNome!,
                                    style: theme.textTheme.labelSmall
                                        ?.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                              Text(
                                '${alerta.diasDeVida}d',
                                style: theme.textTheme.labelSmall?.copyWith(
                                    color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            alerta.mensagem,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            alerta.condicao,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Icon(Icons.chevron_right,
                          color: AppColors.gray400, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
