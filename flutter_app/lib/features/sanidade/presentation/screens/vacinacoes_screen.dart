import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/fab_menu.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import '../../domain/entities/vacinacao.dart';
import '../providers/vacinacoes_provider.dart';

/// Tela de listagem de vacinacoes do lote.
///
/// Exibe cards com data, vacina, lote do produto, via e responsavel.
/// FAB para adicionar nova vacinacao. Suporta pull-to-refresh.
class VacinacoesScreen extends ConsumerStatefulWidget {
  const VacinacoesScreen({super.key, this.loteId});

  /// ID do lote. Quando nulo, exibe estado vazio orientando a selecionar um lote.
  final String? loteId;

  @override
  ConsumerState<VacinacoesScreen> createState() => _VacinacoesScreenState();
}

class _VacinacoesScreenState extends ConsumerState<VacinacoesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.loteId != null) {
      Future.microtask(
        () => ref.read(vacinacoesProvider(widget.loteId!).notifier).fetch(),
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
        appBar: AppBar(title: const Text('Vacinacoes')),
        body: const EmptyState(
          icon: Icons.vaccines_outlined,
          titulo: 'Selecione um lote',
          descricao:
              'Acesse um lote para visualizar e registrar vacinacoes.',
        ),
      );
    }

    final state = ref.watch(vacinacoesProvider(loteId));

    return Scaffold(
      appBar: AppBar(title: const Text('Vacinacoes')),
      floatingActionButton: FABMenu(
        actions: [
          FABAction(
            label: 'Nova vacinacao',
            icon: Icons.add,
            onPress: () => context.pushNamed(
              RouteNames.novaVacinacao,
              queryParameters: {'loteId': loteId},
            ),
          ),
        ],
      ),
      body: state.isLoading && state.vacinacoes.isEmpty
          ? const Padding(
              padding: EdgeInsets.all(16),
              child: SkeletonList(itemCount: 3),
            )
          : RefreshIndicator(
              onRefresh: () =>
                  ref.read(vacinacoesProvider(loteId).notifier).fetch(),
              child: state.vacinacoes.isEmpty
                  ? ListView(
                      children: [
                        SizedBox(
                          height: MediaQuery.sizeOf(context).height * 0.6,
                          child: EmptyState(
                            icon: Icons.vaccines_outlined,
                            titulo: 'Nenhuma vacinacao registrada',
                            descricao:
                                'Registre as vacinacoes do lote para manter o historico sanitario.',
                            actionLabel: 'Registrar vacinacao',
                            actionIcon: Icons.add,
                            onAction: () => context.pushNamed(
                              RouteNames.novaVacinacao,
                              queryParameters: {'loteId': loteId},
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
                  formatDate(vacinacao.dataAplicacao),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nome da vacina
            Text(
              vacinacao.nome,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Detalhes
            if (vacinacao.lote != null && vacinacao.lote!.isNotEmpty)
              _DetailRow(
                label: 'Lote produto',
                value: vacinacao.lote!,
              ),
            if (vacinacao.fabricante != null &&
                vacinacao.fabricante!.isNotEmpty)
              _DetailRow(
                label: 'Fabricante',
                value: vacinacao.fabricante!,
              ),
            if (vacinacao.viaAplicacao != null &&
                vacinacao.viaAplicacao!.isNotEmpty)
              _DetailRow(
                label: 'Via',
                value: vacinacao.viaAplicacao!,
              ),
            if (vacinacao.doseMl != null)
              _DetailRow(
                label: 'Dose',
                value: '${vacinacao.doseMl} mL',
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
