import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';

// ══════════════════════════════════════════════════════════════════════
// PROVIDER
// ══════════════════════════════════════════════════════════════════════

class _ConversaoState {
  final Map<String, dynamic>? dados;
  final bool isLoading;
  final String? error;

  const _ConversaoState({
    this.dados,
    this.isLoading = false,
    this.error,
  });
}

final _conversaoReportProvider = StateNotifierProvider.family<
    _ConversaoNotifier, _ConversaoState, String>(
  (ref, loteId) {
    final api = ref.watch(apiClientProvider);
    return _ConversaoNotifier(api: api, loteId: loteId);
  },
);

class _ConversaoNotifier extends StateNotifier<_ConversaoState> {
  final dynamic _api;
  final String _loteId;

  _ConversaoNotifier({required dynamic api, required String loteId})
      : _api = api,
        _loteId = loteId,
        super(const _ConversaoState());

  Future<void> fetch() async {
    state = const _ConversaoState(isLoading: true);
    try {
      final response = await _api.apiGet<Map<String, dynamic>>(
        '/lotes/$_loteId/relatorio/conversao',
        fromJson: (json) {
          if (json == null) return <String, dynamic>{};
          return Map<String, dynamic>.from(json as Map);
        },
      );
      if (!mounted) return;
      state = _ConversaoState(dados: response.data);
    } on NetworkException {
      if (!mounted) return;
      state = const _ConversaoState(error: 'Sem conexao. Tente novamente.');
    } catch (e) {
      if (!mounted) return;
      state = const _ConversaoState(
          error: 'Erro ao carregar conversao alimentar.');
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// SCREEN
// ══════════════════════════════════════════════════════════════════════

/// Tela de relatorio de conversao alimentar (ICA / GPD).
class RelatorioConversaoScreen extends ConsumerStatefulWidget {
  const RelatorioConversaoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<RelatorioConversaoScreen> createState() =>
      _RelatorioConversaoScreenState();
}

class _RelatorioConversaoScreenState
    extends ConsumerState<RelatorioConversaoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(_conversaoReportProvider(widget.loteId).notifier).fetch();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(_conversaoReportProvider(widget.loteId));
    final theme = Theme.of(context);

    return _buildBody(state, theme);
  }

  Widget _buildBody(_ConversaoState state, ThemeData theme) {
    if (state.isLoading) {
      return const SkeletonList(itemCount: 3);
    }

    if (state.error != null) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref
            .read(_conversaoReportProvider(widget.loteId).notifier)
            .fetch(),
      );
    }

    final dados = state.dados;
    if (dados == null || dados.isEmpty) {
      return const Center(
        child: Text('Sem dados disponiveis para conversao alimentar.'),
      );
    }

    final consumoKg = (dados['consumo_total_kg'] as num?)?.toDouble() ?? 0.0;
    final pesoMedio = (dados['peso_medio'] as num?)?.toDouble();
    final pesoInicial = (dados['peso_inicial_g'] as num?)?.toDouble() ?? 0.0;
    final ganhoPeso = (dados['ganho_peso_g'] as num?)?.toDouble();
    final ica = (dados['ica'] as num?)?.toDouble();
    final gpd = (dados['gpd'] as num?)?.toDouble();
    final diasVida = (dados['dias_de_vida'] as num?)?.toInt() ?? 0;
    final avesVivas = (dados['aves_vivas'] as num?)?.toInt() ?? 0;

    return RefreshIndicator(
      onRefresh: () => ref
          .read(_conversaoReportProvider(widget.loteId).notifier)
          .fetch(),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Explicacao
          Card(
            color: AppColors.infoLight,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: AppColors.info, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'ICA (Indice de Conversao Alimentar) = Racao consumida (kg) / Ganho de peso (kg). '
                      'Quanto menor o ICA, melhor a eficiencia alimentar.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ICA card grande
          _buildMainIndicator(
            theme: theme,
            title: 'ICA',
            value: ica != null ? NumberUtils.formatDecimal(ica, 3) : '-',
            subtitle: 'Indice de Conversao Alimentar',
            icon: Icons.swap_vert,
            color: ica != null
                ? (ica < 1.7
                    ? AppColors.success
                    : ica < 2.0
                        ? AppColors.warning
                        : AppColors.danger)
                : AppColors.gray500,
          ),
          const SizedBox(height: 12),

          // GPD card grande
          _buildMainIndicator(
            theme: theme,
            title: 'GPD',
            value: gpd != null
                ? '${NumberUtils.formatDecimal(gpd, 1)} g/dia'
                : '-',
            subtitle: 'Ganho de Peso Diario',
            icon: Icons.trending_up,
            color: gpd != null
                ? (gpd > 60
                    ? AppColors.success
                    : gpd > 50
                        ? AppColors.warning
                        : AppColors.danger)
                : AppColors.gray500,
          ),
          const SizedBox(height: 16),

          // Detalhes
          Text(
            'Detalhes do Calculo',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          _buildDetailRow(theme, 'Dias de vida', '$diasVida dias'),
          _buildDetailRow(theme, 'Aves vivas', avesVivas.toString()),
          _buildDetailRow(
            theme,
            'Peso inicial',
            NumberUtils.formatWeight(pesoInicial),
          ),
          _buildDetailRow(
            theme,
            'Peso medio atual',
            pesoMedio != null ? NumberUtils.formatWeight(pesoMedio) : '-',
          ),
          _buildDetailRow(
            theme,
            'Ganho de peso',
            ganhoPeso != null ? NumberUtils.formatWeight(ganhoPeso) : '-',
          ),
          _buildDetailRow(
            theme,
            'Consumo total racao',
            '${NumberUtils.formatDecimal(consumoKg, 1)} kg',
          ),
        ],
      ),
    );
  }

  Widget _buildMainIndicator({
    required ThemeData theme,
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(ThemeData theme, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
