import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/fab_menu.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';
import '../../domain/entities/medicamento.dart';
import '../providers/medicamentos_provider.dart';

/// Tela de listagem de medicamentos do lote.
///
/// Exibe cards com nome, dosagem, via, periodo e status (em carencia ou nao).
/// FAB para adicionar novo medicamento. Suporta pull-to-refresh.
class MedicamentosScreen extends ConsumerStatefulWidget {
  const MedicamentosScreen({super.key, this.loteId});

  /// ID do lote. Quando nulo, exibe seletor de lote.
  final String? loteId;

  @override
  ConsumerState<MedicamentosScreen> createState() =>
      _MedicamentosScreenState();
}

class _MedicamentosScreenState extends ConsumerState<MedicamentosScreen> {
  late String _selectedLoteId;

  @override
  void initState() {
    super.initState();
    _selectedLoteId = widget.loteId ?? '';
    // Fetch lotes list for the dropdown
    Future.microtask(() {
      ref.read(homeProvider.notifier).fetchLotes();
    });
    // If we already have a loteId, fetch data
    if (_selectedLoteId.isNotEmpty) {
      Future.microtask(() {
        ref.read(medicamentosProvider(_selectedLoteId).notifier).fetch();
      });
    }
  }

  void _onLoteChanged(String loteId) {
    setState(() => _selectedLoteId = loteId);
    if (loteId.isNotEmpty) {
      ref.read(medicamentosProvider(loteId).notifier).fetch();
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
    final homeState = ref.watch(homeProvider);

    // Auto-select first lote if none selected
    final lotes = homeState.lotesAtivos;
    if (_selectedLoteId.isEmpty && lotes.isNotEmpty) {
      Future.microtask(() {
        _onLoteChanged(lotes.first.id);
      });
    }

    return Stack(
      children: [
        Column(
          children: [
            // Seletor de lote
            _buildLoteSelector(homeState, theme),

            // Conteudo
            Expanded(
              child: _selectedLoteId.isEmpty
                  ? const EmptyState(
                      icon: Icons.medication_outlined,
                      titulo: 'Selecione um lote',
                      descricao:
                          'Acesse um lote para visualizar e registrar medicamentos.',
                    )
                  : _buildContent(theme),
            ),
          ],
        ),
        if (_selectedLoteId.isNotEmpty)
          Positioned(
            right: 16,
            bottom: 16,
            child: FABMenu(
              actions: [
                FABAction(
                  label: 'Novo medicamento',
                  icon: Icons.add,
                  onPress: () => context.pushNamed(
                    RouteNames.novoMedicamento,
                    queryParameters: {'loteId': _selectedLoteId},
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Seletor de lote ───────────────────────────────────────────────────

  Widget _buildLoteSelector(HomeState homeState, ThemeData theme) {
    final lotes = homeState.lotesAtivos;
    final options = lotes
        .map((l) => DropdownOption(
              value: l.id,
              label: '${l.galpaoNome} - Dia ${l.diasDeVida ?? 0}',
              subtitle: 'Alojado: ${l.dataAlojamento}',
            ))
        .toList();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: DropdownField(
        label: 'Lote',
        value: _selectedLoteId.isNotEmpty ? _selectedLoteId : null,
        options: options,
        placeholder: 'Selecione um lote...',
        onSelect: (option) => _onLoteChanged(option.value),
      ),
    );
  }

  // ── Conteudo ──────────────────────────────────────────────────────────

  Widget _buildContent(ThemeData theme) {
    final state = ref.watch(medicamentosProvider(_selectedLoteId));

    if (state.isLoading && state.medicamentos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(medicamentosProvider(_selectedLoteId).notifier).fetch(),
      child: state.medicamentos.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: EmptyState(
                    icon: Icons.medication_outlined,
                    titulo: 'Nenhum medicamento registrado',
                    descricao:
                        'Registre os medicamentos aplicados no lote para controle de carencia.',
                    actionLabel: 'Registrar medicamento',
                    actionIcon: Icons.add,
                    onAction: () => context.pushNamed(
                      RouteNames.novoMedicamento,
                      queryParameters: {'loteId': _selectedLoteId},
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

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: medicamento.emCarencia
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
                if (medicamento.emCarencia)
                  _StatusBadge(
                    label: 'EM CARENCIA',
                    color: AppColors.danger,
                    backgroundColor: AppColors.dangerLight,
                  ),
              ],
            ),
            if (medicamento.emCarencia) const SizedBox(height: 8),

            // Nome do medicamento
            Text(
              medicamento.medicamento,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Periodo
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
                if (medicamento.via != null && medicamento.via!.isNotEmpty)
                  _DetailItem(
                    label: 'Via',
                    value: medicamento.via!,
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
