import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/fab_menu.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import '../../domain/entities/visitante.dart';
import '../providers/visitantes_provider.dart';

/// Tela de listagem de visitantes da granja.
///
/// Exibe cards com nome, origem, motivo, data de entrada/saida.
/// FAB para registrar novo visitante. Suporta pull-to-refresh.
///
/// Note: Visitantes are associated with a granja, not a lote.
/// The granjaId parameter is used to fetch and create visitantes.
class VisitantesScreen extends ConsumerStatefulWidget {
  const VisitantesScreen({super.key, this.granjaId});

  /// ID da granja. Quando nulo, auto-seleciona a primeira granja do usuario.
  final String? granjaId;

  @override
  ConsumerState<VisitantesScreen> createState() => _VisitantesScreenState();
}

class _VisitantesScreenState extends ConsumerState<VisitantesScreen> {
  late String _selectedGranjaId;

  @override
  void initState() {
    super.initState();
    _selectedGranjaId = widget.granjaId ?? '';
    // If we already have a granjaId, fetch data
    if (_selectedGranjaId.isNotEmpty) {
      Future.microtask(() {
        ref.read(visitantesProvider(_selectedGranjaId).notifier).fetch();
      });
    }
  }

  void _onGranjaChanged(String granjaId) {
    setState(() => _selectedGranjaId = granjaId);
    if (granjaId.isNotEmpty) {
      ref.read(visitantesProvider(granjaId).notifier).fetch();
    }
  }

  String _formatDate(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    return '$dia/$mes/${date.year}';
  }

  String _formatDateTime(String isoDate) {
    final date = DateTime.tryParse(isoDate);
    if (date == null) return isoDate;
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final hora = date.hour.toString().padLeft(2, '0');
    final min = date.minute.toString().padLeft(2, '0');
    return '$dia/$mes/${date.year} $hora:$min';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final granjasAsync = ref.watch(granjasProvider);

    // Auto-select first granja if none selected
    granjasAsync.whenData((granjas) {
      if (_selectedGranjaId.isEmpty && granjas.isNotEmpty) {
        Future.microtask(() {
          _onGranjaChanged(granjas.first.id);
        });
      }
    });

    return Stack(
      children: [
        Column(
          children: [
            // Seletor de granja
            _buildGranjaSelector(granjasAsync, theme),

            // Conteudo
            Expanded(
              child: _selectedGranjaId.isEmpty
                  ? const EmptyState(
                      icon: Icons.badge_outlined,
                      titulo: 'Selecione uma granja',
                      descricao:
                          'Acesse uma granja para visualizar e registrar visitantes.',
                    )
                  : _buildContent(theme),
            ),
          ],
        ),
        if (_selectedGranjaId.isNotEmpty)
          Positioned(
            right: 16,
            bottom: 16,
            child: FABMenu(
              actions: [
                FABAction(
                  label: 'Novo visitante',
                  icon: Icons.add,
                  onPress: () => context.pushNamed(
                    RouteNames.novoVisitante,
                    queryParameters: {'granjaId': _selectedGranjaId},
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  // ── Seletor de granja ─────────────────────────────────────────────────

  Widget _buildGranjaSelector(
    AsyncValue<List<dynamic>> granjasAsync,
    ThemeData theme,
  ) {
    final options = granjasAsync.when(
      data: (granjas) => granjas
          .map((g) => DropdownOption(
                value: g.id,
                label: g.nome,
              ))
          .toList(),
      loading: () => <DropdownOption>[],
      error: (_, _) => <DropdownOption>[],
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: DropdownField(
        label: 'Granja',
        value: _selectedGranjaId.isNotEmpty ? _selectedGranjaId : null,
        options: options,
        placeholder: granjasAsync.isLoading
            ? 'Carregando granjas...'
            : 'Selecione uma granja...',
        onSelect: (option) => _onGranjaChanged(option.value),
      ),
    );
  }

  // ── Conteudo ──────────────────────────────────────────────────────────

  Widget _buildContent(ThemeData theme) {
    final state = ref.watch(visitantesProvider(_selectedGranjaId));

    if (state.isLoading && state.visitantes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(visitantesProvider(_selectedGranjaId).notifier).fetch(),
      child: state.visitantes.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: EmptyState(
                    icon: Icons.badge_outlined,
                    titulo: 'Nenhum visitante registrado',
                    descricao:
                        'Registre a entrada de visitantes para controle de biosseguranca.',
                    actionLabel: 'Registrar visitante',
                    actionIcon: Icons.add,
                    onAction: () => context.pushNamed(
                      RouteNames.novoVisitante,
                      queryParameters: {'granjaId': _selectedGranjaId},
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
                  formatDateTime: _formatDateTime,
                  theme: theme,
                );
              },
            ),
    );
  }
}

class _VisitanteCard extends StatelessWidget {
  const _VisitanteCard({
    required this.visitante,
    required this.formatDate,
    required this.formatDateTime,
    required this.theme,
  });

  final Visitante visitante;
  final String Function(String) formatDate;
  final String Function(String) formatDateTime;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final hasSaida = visitante.dataSaida != null;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status badge
            Row(
              children: [
                if (!hasSaida)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.warningLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.login_outlined,
                            size: 14, color: AppColors.warning),
                        const SizedBox(width: 4),
                        Text(
                          'Na granja',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.warning,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (hasSaida)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_outline,
                            size: 14, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text(
                          'Saiu',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
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

            // Data de entrada
            Row(
              children: [
                Icon(
                  Icons.login_outlined,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  'Entrada: ${formatDateTime(visitante.dataEntrada)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            if (hasSaida) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.logout_outlined,
                    size: 16,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Saida: ${formatDateTime(visitante.dataSaida!)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 8),

            // Detalhes
            if (visitante.documento != null &&
                visitante.documento!.isNotEmpty)
              _DetailRow(label: 'Documento', value: visitante.documento!),
            if (visitante.origem != null && visitante.origem!.isNotEmpty)
              _DetailRow(label: 'Origem', value: visitante.origem!),
            if (visitante.motivo != null && visitante.motivo!.isNotEmpty)
              _DetailRow(label: 'Motivo', value: visitante.motivo!),
            if (visitante.placaVeiculo != null &&
                visitante.placaVeiculo!.isNotEmpty)
              _DetailRow(label: 'Placa', value: visitante.placaVeiculo!),

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
