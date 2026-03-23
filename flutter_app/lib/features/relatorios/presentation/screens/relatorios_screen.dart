import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import '../providers/relatorios_provider.dart';

/// Tela principal de relatorios.
///
/// Permite selecionar um lote e gerar relatorios de fechamento,
/// exportar CSV, financeiro em PDF ou navegar para comparativo.
class RelatoriosScreen extends ConsumerStatefulWidget {
  const RelatoriosScreen({super.key});

  @override
  ConsumerState<RelatoriosScreen> createState() => _RelatoriosScreenState();
}

class _RelatoriosScreenState extends ConsumerState<RelatoriosScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(relatoriosProvider.notifier).fetchLotes();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(relatoriosProvider.notifier).fetchLotes();
  }

  void _onGerarRelatorio(String tipo) {
    ref.read(relatoriosProvider.notifier).gerarRelatorio(tipo);
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(relatoriosProvider);
    final theme = Theme.of(context);

    // Exibir SnackBar para feedback
    ref.listen<RelatoriosState>(relatoriosProvider, (previous, next) {
      if (next.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.errorMessage!),
            backgroundColor: AppColors.danger,
          ),
        );
        ref.read(relatoriosProvider.notifier).clearMessages();
      }
      if (next.successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.successMessage!),
            backgroundColor: AppColors.success,
          ),
        );
        ref.read(relatoriosProvider.notifier).clearMessages();
      }
    });

    return _buildBody(state, theme);
  }

  Widget _buildBody(RelatoriosState state, ThemeData theme) {
    if (state.isLoading && state.lotes.isEmpty) {
      return const SkeletonList(itemCount: 4);
    }

    if (state.errorMessage != null && state.lotes.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: _onRefresh,
      );
    }

    if (state.lotes.isEmpty) {
      return const Center(
        child: Text('Nenhum lote disponivel.'),
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Seletor de Lote ────────────────────────────────────
          Text(
            'Selecione o Lote',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          DropdownMenu<String>(
            initialSelection: state.selectedLoteId,
            expandedInsets: EdgeInsets.zero,
            onSelected: (value) {
              if (value != null) {
                ref.read(relatoriosProvider.notifier).setSelectedLote(value);
              }
            },
            dropdownMenuEntries: state.lotes.map((lote) {
              final statusLabel =
                  lote.status == 'finalizado' ? ' (Finalizado)' : ' (Ativo)';
              final galpao =
                  lote.galpaoNome != null ? ' - ${lote.galpaoNome}' : '';
              return DropdownMenuEntry<String>(
                value: lote.id,
                label: '${lote.linhagem ?? 'Lote'}$galpao$statusLabel',
              );
            }).toList(),
          ),
          const SizedBox(height: 24),

          // ── Cards de Relatorio ─────────────────────────────────
          Text(
            'Tipos de Relatorio',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),

          _ReportCard(
            icon: Icons.description_outlined,
            title: 'Relatorio de Fechamento',
            description: 'Gera PDF completo com todos os indicadores do lote.',
            isLoading: state.loadingReport == 'fechamento',
            onTap: () => _onGerarRelatorio('fechamento'),
          ),
          const SizedBox(height: 12),

          _ReportCard(
            icon: Icons.monitor_weight_outlined,
            title: 'Relatorio de Pesagens',
            description:
                'Historico de peso do lote com grafico de evolucao.',
            isLoading: false,
            onTap: state.selectedLoteId != null
                ? () => context.pushNamed(
                      RouteNames.relatorioPesagens,
                      queryParameters: {'loteId': state.selectedLoteId!},
                    )
                : () {},
          ),
          const SizedBox(height: 12),

          _ReportCard(
            icon: Icons.trending_down,
            title: 'Relatorio de Mortalidade',
            description:
                'Taxas de mortalidade por periodo com grafico acumulado.',
            isLoading: false,
            onTap: state.selectedLoteId != null
                ? () => context.pushNamed(
                      RouteNames.relatorioMortalidade,
                      queryParameters: {'loteId': state.selectedLoteId!},
                    )
                : () {},
          ),
          const SizedBox(height: 12),

          _ReportCard(
            icon: Icons.swap_vert,
            title: 'Conversao Alimentar',
            description:
                'ICA (conversao alimentar) e ganho de peso diario (GPD).',
            isLoading: false,
            onTap: state.selectedLoteId != null
                ? () => context.pushNamed(
                      RouteNames.relatorioConversao,
                      queryParameters: {'loteId': state.selectedLoteId!},
                    )
                : () {},
          ),
          const SizedBox(height: 12),

          _ReportCard(
            icon: Icons.water_drop_outlined,
            title: 'Relatorio de Consumo',
            description:
                'Consumo diario de racao e agua com graficos.',
            isLoading: false,
            onTap: state.selectedLoteId != null
                ? () => context.pushNamed(
                      RouteNames.relatorioConsumo,
                      queryParameters: {'loteId': state.selectedLoteId!},
                    )
                : () {},
          ),
          const SizedBox(height: 12),

          _ReportCard(
            icon: Icons.compare_arrows,
            title: 'Comparativo de Lotes',
            description:
                'Compare indicadores de desempenho entre lotes diferentes.',
            isLoading: false,
            onTap: () => context.pushNamed(RouteNames.comparativoLotes),
          ),
          const SizedBox(height: 12),

          _ReportCard(
            icon: Icons.table_chart_outlined,
            title: 'Exportar CSV',
            description:
                'Exporta dados do lote em formato CSV para planilhas.',
            isLoading: state.loadingReport == 'csv',
            onTap: () => _onGerarRelatorio('csv'),
          ),
          const SizedBox(height: 12),

          _ReportCard(
            icon: Icons.attach_money,
            title: 'Relatorio Financeiro',
            description:
                'PDF detalhado com custos, receitas e margem do lote.',
            isLoading: state.loadingReport == 'financeiro',
            onTap: () => _onGerarRelatorio('financeiro'),
          ),
        ],
      ),
    );
  }
}

/// Card de opcao de relatorio com icone, titulo, descricao e chevron.
class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.isLoading,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool isLoading;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: isLoading ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: theme.colorScheme.primary,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (isLoading)
                const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: AppColors.gray400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
