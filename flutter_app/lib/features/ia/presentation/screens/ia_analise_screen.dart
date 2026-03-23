import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';
import 'package:egranja_flutter/features/ia/domain/entities/analise_ia.dart';
import 'package:egranja_flutter/features/ia/presentation/providers/ia_analise_provider.dart';

/// Tela de analise IA do eGranja.
///
/// Exibe a analise gerada pela IA com pontos positivos,
/// pontos de atencao e acoes recomendadas, organizados em
/// secoes coloridas com icones.
class IAAnaliseScreen extends ConsumerStatefulWidget {
  const IAAnaliseScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<IAAnaliseScreen> createState() => _IAAnaliseScreenState();
}

class _IAAnaliseScreenState extends ConsumerState<IAAnaliseScreen> {
  late String _selectedLoteId;

  @override
  void initState() {
    super.initState();
    _selectedLoteId = widget.loteId;
    if (_selectedLoteId.isNotEmpty) {
      Future.microtask(() {
        ref
            .read(iaAnaliseProvider(_selectedLoteId).notifier)
            .carregarAnalise();
      });
    }
    Future.microtask(() {
      ref.read(homeProvider.notifier).fetchLotes();
    });
  }

  void _onLoteChanged(String loteId) {
    setState(() {
      _selectedLoteId = loteId;
    });
    if (loteId.isNotEmpty) {
      ref
          .read(iaAnaliseProvider(loteId).notifier)
          .carregarAnalise();
    }
  }

  void _gerarNovaAnalise() {
    if (_selectedLoteId.isEmpty) return;
    ref
        .read(iaAnaliseProvider(_selectedLoteId).notifier)
        .gerarNovaAnalise();
  }

  @override
  Widget build(BuildContext context) {
    final iaState = _selectedLoteId.isNotEmpty
        ? ref.watch(iaAnaliseProvider(_selectedLoteId))
        : const IAAnaliseState();
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        // Seletor de lote
        _buildLoteSelector(homeState, theme),

        // Conteudo
        Expanded(
          child: _selectedLoteId.isEmpty
              ? _buildSelectLotePrompt(theme)
              : _buildBody(iaState, theme),
        ),
      ],
    );
  }

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
        searchable: true,
        onSelect: (option) => _onLoteChanged(option.value),
      ),
    );
  }

  Widget _buildSelectLotePrompt(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: AppColors.secondary.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                size: 36,
                color: AppColors.secondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Selecione um lote',
              style: theme.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Escolha um lote para visualizar a analise IA.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(IAAnaliseState state, ThemeData theme) {
    // Loading
    if (state.isLoading && state.analise == null) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    // Error
    if (state.errorMessage != null && state.analise == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.errorMessage!,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () {
                  ref
                      .read(iaAnaliseProvider(_selectedLoteId).notifier)
                      .carregarAnalise();
                },
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (state.analise == null) {
      return Column(
        children: [
          Expanded(
            child: EmptyState(
              icon: Icons.analytics_outlined,
              titulo: 'Nenhuma analise disponivel',
              descricao:
                  'Gere uma analise IA para obter insights sobre o desempenho deste lote.',
              actionLabel: 'Gerar analise',
              actionIcon: Icons.auto_awesome,
              onAction: state.isGerando ? null : _gerarNovaAnalise,
            ),
          ),
        ],
      );
    }

    // Analysis content
    return _buildAnaliseContent(state, theme);
  }

  Widget _buildAnaliseContent(IAAnaliseState state, ThemeData theme) {
    final analise = state.analise!;

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(iaAnaliseProvider(_selectedLoteId).notifier)
            .carregarAnalise();
      },
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Summary card
          _buildSummaryCard(analise, theme),
          const SizedBox(height: 16),

          // Pontos Positivos
          _buildSection(
            title: 'Pontos Positivos',
            items: analise.pontosPositivos,
            icon: Icons.check_circle,
            borderColor: AppColors.success,
            headerBgColor: AppColors.successLight,
            iconColor: AppColors.success,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Pontos de Atencao
          _buildSection(
            title: 'Pontos de Atencao',
            items: analise.pontosAtencao,
            icon: Icons.warning_amber_rounded,
            borderColor: AppColors.warning,
            headerBgColor: AppColors.warningLight,
            iconColor: AppColors.warning,
            theme: theme,
          ),
          const SizedBox(height: 16),

          // Acoes Recomendadas
          _buildSection(
            title: 'Acoes Recomendadas',
            items: analise.acoesRecomendadas,
            icon: Icons.lightbulb_outline,
            borderColor: AppColors.secondary,
            headerBgColor: AppColors.secondary.withAlpha(20),
            iconColor: AppColors.secondary,
            theme: theme,
          ),
          const SizedBox(height: 24),

          // Gerar nova analise button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: state.isGerando ? null : _gerarNovaAnalise,
              icon: state.isGerando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.auto_awesome),
              label: Text(
                state.isGerando ? 'Gerando analise...' : 'Gerar nova analise',
              ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(AnaliseIA analise, ThemeData theme) {
    final dia = analise.geradaEm.day.toString().padLeft(2, '0');
    final mes = analise.geradaEm.month.toString().padLeft(2, '0');
    final ano = analise.geradaEm.year;
    final hora = analise.geradaEm.hour.toString().padLeft(2, '0');
    final minuto = analise.geradaEm.minute.toString().padLeft(2, '0');
    final dataStr = '$dia/$mes/$ano as $hora:$minuto';

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.smart_toy,
                    size: 22,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Analise do Lote',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Gerada em $dataStr',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (analise.resumo.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                analise.resumo,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<String> items,
    required IconData icon,
    required Color borderColor,
    required Color headerBgColor,
    required Color iconColor,
    required ThemeData theme,
  }) {
    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: borderColor.withAlpha(100)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: headerBgColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(11),
                topRight: Radius.circular(11),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: iconColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: iconColor.withAlpha(25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${items.length}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: iconColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Items
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022 ',
                        style: TextStyle(
                          fontSize: 16,
                          color: iconColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          item,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
