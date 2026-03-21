import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/fab_menu.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import '../../domain/entities/visitante.dart';
import '../providers/visitantes_provider.dart';

/// Tela de listagem de visitantes do lote.
///
/// Exibe cards com nome, empresa, motivo, horarios e badge de EPI.
/// FAB para registrar novo visitante. Suporta pull-to-refresh.
class VisitantesScreen extends ConsumerStatefulWidget {
  const VisitantesScreen({super.key, this.loteId});

  /// ID do lote. Quando nulo, exibe estado vazio orientando a selecionar um lote.
  final String? loteId;

  @override
  ConsumerState<VisitantesScreen> createState() => _VisitantesScreenState();
}

class _VisitantesScreenState extends ConsumerState<VisitantesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.loteId != null) {
      Future.microtask(
        () =>
            ref.read(visitantesProvider(widget.loteId!).notifier).fetch(),
      );
    }
  }

  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    return '$dia/$mes/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final loteId = widget.loteId;

    if (loteId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visitantes')),
        body: const EmptyState(
          icon: Icons.badge_outlined,
          titulo: 'Selecione um lote',
          descricao:
              'Acesse um lote para visualizar e registrar visitantes.',
        ),
      );
    }

    final state = ref.watch(visitantesProvider(loteId));

    return Scaffold(
      appBar: AppBar(title: const Text('Visitantes')),
      floatingActionButton: FABMenu(
        actions: [
          FABAction(
            label: 'Novo visitante',
            icon: Icons.add,
            onPress: () => context.pushNamed(
              RouteNames.novoVisitante,
              queryParameters: {'loteId': loteId},
            ),
          ),
        ],
      ),
      body: state.isLoading && state.visitantes.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: SkeletonList(itemCount: 3),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(visitantesProvider(loteId).notifier)
                  .fetch(),
              child: state.visitantes.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          child: EmptyState(
                            icon: Icons.badge_outlined,
                            titulo: 'Nenhum visitante registrado',
                            descricao:
                                'Registre a entrada de visitantes para controle de biosseguranca.',
                            actionLabel: 'Registrar visitante',
                            actionIcon: Icons.add,
                            onAction: () => context.pushNamed(
                              RouteNames.novoVisitante,
                              queryParameters: {'loteId': loteId},
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: state.visitantes.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final visitante = state.visitantes[index];
                        return _VisitanteCard(
                          visitante: visitante,
                          formatDate: _formatDate,
                          theme: theme,
                        );
                      },
                    ),
            ),
    );
  }
}

class _VisitanteCard extends StatelessWidget {
  const _VisitanteCard({
    required this.visitante,
    required this.formatDate,
    required this.theme,
  });

  final Visitante visitante;
  final String Function(String) formatDate;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Badges
            Row(
              children: [
                if (visitante.usouEpi)
                  _EpiBadge(
                    label: 'EPI Utilizado',
                    color: AppColors.success,
                    backgroundColor: AppColors.successLight,
                    icon: Icons.check_circle_outline,
                  ),
                if (!visitante.usouEpi)
                  _EpiBadge(
                    label: 'Sem EPI',
                    color: AppColors.warning,
                    backgroundColor: AppColors.warningLight,
                    icon: Icons.warning_amber_outlined,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Nome
            Text(
              visitante.nome,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Data da visita
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  formatDate(visitante.dataVisita),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Detalhes
            if (visitante.empresa != null &&
                visitante.empresa!.isNotEmpty)
              _DetailRow(label: 'Empresa', value: visitante.empresa!),
            if (visitante.motivo != null && visitante.motivo!.isNotEmpty)
              _DetailRow(label: 'Motivo', value: visitante.motivo!),
            if (visitante.horaEntrada != null &&
                visitante.horaEntrada!.isNotEmpty)
              _DetailRow(label: 'Entrada', value: visitante.horaEntrada!),
            if (visitante.horaSaida != null &&
                visitante.horaSaida!.isNotEmpty)
              _DetailRow(label: 'Saida', value: visitante.horaSaida!),

            if (visitante.observacao != null &&
                visitante.observacao!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Obs: ${visitante.observacao}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _EpiBadge extends StatelessWidget {
  const _EpiBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
    required this.icon,
  });

  final String label;
  final Color color;
  final Color backgroundColor;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Row(
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}
