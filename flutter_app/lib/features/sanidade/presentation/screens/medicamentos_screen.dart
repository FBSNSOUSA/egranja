import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/fab_menu.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import '../../domain/entities/medicamento.dart';
import '../providers/medicamentos_provider.dart';

/// Tela de listagem de medicamentos do lote.
///
/// Exibe cards com nome, dosagem, via, periodo e status (Ativo/Concluido).
/// FAB para adicionar novo medicamento. Suporta pull-to-refresh.
class MedicamentosScreen extends ConsumerStatefulWidget {
  const MedicamentosScreen({super.key, this.loteId});

  /// ID do lote. Quando nulo, exibe estado vazio orientando a selecionar um lote.
  final String? loteId;

  @override
  ConsumerState<MedicamentosScreen> createState() =>
      _MedicamentosScreenState();
}

class _MedicamentosScreenState extends ConsumerState<MedicamentosScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.loteId != null) {
      Future.microtask(
        () =>
            ref.read(medicamentosProvider(widget.loteId!).notifier).fetch(),
      );
    }
  }

  String _formatDate(String? isoDate) {
    if (isoDate == null) return '--';
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
        appBar: AppBar(title: const Text('Medicamentos')),
        body: const EmptyState(
          icon: Icons.medication_outlined,
          titulo: 'Selecione um lote',
          descricao:
              'Acesse um lote para visualizar e registrar medicamentos.',
        ),
      );
    }

    final state = ref.watch(medicamentosProvider(loteId));

    return Scaffold(
      appBar: AppBar(title: const Text('Medicamentos')),
      floatingActionButton: FABMenu(
        actions: [
          FABAction(
            label: 'Novo medicamento',
            icon: Icons.add,
            onPress: () => context.pushNamed(
              RouteNames.novoMedicamento,
              queryParameters: {'loteId': loteId},
            ),
          ),
        ],
      ),
      body: state.isLoading && state.medicamentos.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: SkeletonList(itemCount: 3),
            )
          : RefreshIndicator(
              onRefresh: () => ref
                  .read(medicamentosProvider(loteId).notifier)
                  .fetch(),
              child: state.medicamentos.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          child: EmptyState(
                            icon: Icons.medication_outlined,
                            titulo: 'Nenhum medicamento registrado',
                            descricao:
                                'Registre os medicamentos aplicados no lote para controle de carencia.',
                            actionLabel: 'Registrar medicamento',
                            actionIcon: Icons.add,
                            onAction: () => context.pushNamed(
                              RouteNames.novoMedicamento,
                              queryParameters: {'loteId': loteId},
                            ),
                          ),
                        ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                      itemCount: state.medicamentos.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final med = state.medicamentos[index];
                        return _MedicamentoCard(
                          medicamento: med,
                          formatDate: _formatDate,
                          theme: theme,
                        );
                      },
                    ),
            ),
    );
  }
}

class _MedicamentoCard extends StatelessWidget {
  const _MedicamentoCard({
    required this.medicamento,
    required this.formatDate,
    required this.theme,
  });

  final Medicamento medicamento;
  final String Function(String?) formatDate;
  final ThemeData theme;

  bool get _isAtivo {
    final status = medicamento.status?.toLowerCase();
    return status == 'ativo' || status == 'em_tratamento';
  }

  bool get _emCarencia {
    if (medicamento.periodoCarenciaDias == null ||
        medicamento.periodoCarenciaDias! <= 0 ||
        medicamento.dataFim == null) {
      return false;
    }
    final dataFim = DateTime.tryParse(medicamento.dataFim!);
    if (dataFim == null) return false;
    final fimCarencia =
        dataFim.add(Duration(days: medicamento.periodoCarenciaDias!));
    return DateTime.now().isBefore(fimCarencia);
  }

  @override
  Widget build(BuildContext context) {
    final isAtivo = _isAtivo;
    final emCarencia = _emCarencia;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: emCarencia
            ? const BorderSide(color: AppColors.danger, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badges
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (isAtivo)
                  _StatusBadge(
                    label: 'Ativo',
                    color: AppColors.success,
                    backgroundColor: AppColors.successLight,
                  ),
                if (!isAtivo)
                  _StatusBadge(
                    label: 'Concluido',
                    color: AppColors.textSecondary,
                    backgroundColor: AppColors.gray200,
                  ),
                if (emCarencia)
                  _StatusBadge(
                    label: 'EM CARENCIA',
                    color: AppColors.danger,
                    backgroundColor: AppColors.dangerLight,
                  ),
              ],
            ),
            const SizedBox(height: 8),

            // Nome do medicamento
            Text(
              medicamento.nome,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Periodo
            if (medicamento.dataInicio != null ||
                medicamento.dataFim != null)
              Row(
                children: [
                  Icon(
                    Icons.date_range_outlined,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${formatDate(medicamento.dataInicio)} a ${formatDate(medicamento.dataFim)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 8),

            // Detalhes em grid
            Wrap(
              spacing: 24,
              runSpacing: 8,
              children: [
                if (medicamento.dosagem != null &&
                    medicamento.dosagem!.isNotEmpty)
                  _DetailItem(label: 'Dosagem', value: medicamento.dosagem!),
                if (medicamento.viaAdministracao != null &&
                    medicamento.viaAdministracao!.isNotEmpty)
                  _DetailItem(
                    label: 'Via',
                    value: medicamento.viaAdministracao!,
                  ),
                if (medicamento.periodoCarenciaDias != null)
                  _DetailItem(
                    label: 'Carencia',
                    value: '${medicamento.periodoCarenciaDias} dias',
                  ),
                if (medicamento.responsavel != null &&
                    medicamento.responsavel!.isNotEmpty)
                  _DetailItem(
                    label: 'Responsavel',
                    value: medicamento.responsavel!,
                  ),
              ],
            ),

            if (medicamento.observacao != null &&
                medicamento.observacao!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Obs: ${medicamento.observacao}',
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

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  final String label;
  final Color color;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

class _DetailItem extends StatelessWidget {
  const _DetailItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
