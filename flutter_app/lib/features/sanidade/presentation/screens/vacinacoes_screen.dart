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
import '../../domain/entities/vacinacao.dart';
import '../providers/vacinacoes_provider.dart';

/// Tela de listagem de vacinacoes do lote.
///
/// Exibe cards com data, vacina, lote do produto, via e responsavel.
/// FAB para adicionar nova vacinacao. Suporta pull-to-refresh.
class VacinacoesScreen extends ConsumerStatefulWidget {
  const VacinacoesScreen({super.key, this.loteId});

  /// ID do lote. Quando nulo, exibe seletor de lote.
  final String? loteId;

  @override
  ConsumerState<VacinacoesScreen> createState() => _VacinacoesScreenState();
}

class _VacinacoesScreenState extends ConsumerState<VacinacoesScreen> {
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
        ref.read(vacinacoesProvider(_selectedLoteId).notifier).fetch();
      });
    }
  }

  void _onLoteChanged(String loteId) {
    setState(() => _selectedLoteId = loteId);
    if (loteId.isNotEmpty) {
      ref.read(vacinacoesProvider(loteId).notifier).fetch();
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
                      icon: Icons.vaccines_outlined,
                      titulo: 'Selecione um lote',
                      descricao:
                          'Acesse um lote para visualizar e registrar vacinacoes.',
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
                  label: 'Nova vacinacao',
                  icon: Icons.add,
                  onPress: () => context.pushNamed(
                    RouteNames.novaVacinacao,
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
    final state = ref.watch(vacinacoesProvider(_selectedLoteId));

    if (state.isLoading && state.vacinacoes.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    return RefreshIndicator(
      onRefresh: () =>
          ref.read(vacinacoesProvider(_selectedLoteId).notifier).fetch(),
      child: state.vacinacoes.isEmpty
          ? ListView(
              children: [
                SizedBox(
                  height: MediaQuery.sizeOf(context).height * 0.5,
                  child: EmptyState(
                    icon: Icons.vaccines_outlined,
                    titulo: 'Nenhuma vacinacao registrada',
                    descricao:
                        'Registre as vacinacoes do lote para manter o historico sanitario.',
                    actionLabel: 'Registrar vacinacao',
                    actionIcon: Icons.add,
                    onAction: () => context.pushNamed(
                      RouteNames.novaVacinacao,
                      queryParameters: {'loteId': _selectedLoteId},
                    ),
                  ),
                ),
              ],
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: state.vacinacoes.length,
              separatorBuilder: (context, index) =>
                  const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final vacinacao = state.vacinacoes[index];
                return _VacinacaoCard(
                  vacinacao: vacinacao,
                  formatDate: _formatDate,
                  theme: theme,
                );
              },
            ),
    );
  }
}

class _VacinacaoCard extends StatelessWidget {
  const _VacinacaoCard({
    required this.vacinacao,
    required this.formatDate,
    required this.theme,
  });

  final Vacinacao vacinacao;
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
            // Data
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 6),
                Text(
                  formatDate(vacinacao.data),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nome da vacina
            Text(
              vacinacao.vacina,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Detalhes
            if (vacinacao.loteProduto != null &&
                vacinacao.loteProduto!.isNotEmpty)
              _DetailRow(
                label: 'Lote produto',
                value: vacinacao.loteProduto!,
              ),
            if (vacinacao.viaAdministracao != null &&
                vacinacao.viaAdministracao!.isNotEmpty)
              _DetailRow(
                label: 'Via',
                value: vacinacao.viaAdministracao!,
              ),
            if (vacinacao.responsavel != null &&
                vacinacao.responsavel!.isNotEmpty)
              _DetailRow(
                label: 'Responsavel',
                value: vacinacao.responsavel!,
              ),
            if (vacinacao.observacao != null &&
                vacinacao.observacao!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Obs: ${vacinacao.observacao}',
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
