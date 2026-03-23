import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/theme/indicator_colors.dart';
import 'package:egranja_flutter/core/widgets/indicator_card.dart';
import 'package:egranja_flutter/core/widgets/grafico_evolucao_peso.dart';
import 'package:egranja_flutter/core/widgets/grafico_mortalidade.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/indicadores.dart';
import '../../providers/lote_detail_provider.dart';

/// Aba de resumo/dashboard do lote.
///
/// Exibe grid de indicadores zootecnicos, graficos de peso e
/// mortalidade, projecao e botao de finalizacao.
class LoteResumoTab extends ConsumerStatefulWidget {
  const LoteResumoTab({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<LoteResumoTab> createState() => _LoteResumoTabState();
}

class _LoteResumoTabState extends ConsumerState<LoteResumoTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier =
          ref.read(loteDetailProvider(widget.loteId).notifier);
      notifier.fetchDadosGraficoPeso();
      notifier.fetchDadosGraficoMortalidade();
    });
  }

  Future<void> _onRefresh() async {
    final notifier =
        ref.read(loteDetailProvider(widget.loteId).notifier);
    notifier.invalidateCache();
    await notifier.fetchIndicadores(forceRefresh: true);
    await notifier.fetchDadosGraficoPeso();
    await notifier.fetchDadosGraficoMortalidade();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(loteDetailProvider(widget.loteId));
    final authState = ref.watch(authNotifierProvider);
    final theme = Theme.of(context);

    if (state.isLoading && state.indicadores == null) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            SkeletonList(itemCount: 4),
          ],
        ),
      );
    }

    if (state.errorMessage != null && state.indicadores == null) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () => ref
            .read(loteDetailProvider(widget.loteId).notifier)
            .fetchIndicadores(forceRefresh: true),
      );
    }

    final indicadores = state.indicadores;
    if (indicadores == null) {
      return const SizedBox.shrink();
    }

    final isProdutor = authState.user?.tipo == 'produtor';
    final isAtivo = state.lote?.status == 'ativo';

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Grid de indicadores ──────────────────────────────────
            _buildIndicadoresGrid(indicadores, theme),
            const SizedBox(height: 16),

            // ── Grafico de peso ──────────────────────────────────────
            _buildGraficoPeso(state),
            const SizedBox(height: 16),

            // ── Grafico de mortalidade ───────────────────────────────
            _buildGraficoMortalidade(state),
            const SizedBox(height: 16),

            // ── Botao Finalizar ──────────────────────────────────────
            if (isProdutor && isAtivo) ...[
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    context.pushNamed(
                      RouteNames.finalizarLote,
                      pathParameters: {'loteId': widget.loteId},
                    );
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Finalizar Lote'),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildIndicadoresGrid(Indicadores indicadores, ThemeData theme) {
    // Cor da viabilidade: verde se >=97%, amarelo 95-97%, vermelho <95%
    Color viabilidadeCor = AppColors.success;
    if (indicadores.viabilidade < 95) {
      viabilidadeCor = AppColors.danger;
    } else if (indicadores.viabilidade < 97) {
      viabilidadeCor = AppColors.warning;
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 1.3,
      children: [
        // -- Indicadores primarios (sempre visiveis) --
        IndicatorCard(
          label: 'Dias de Vida',
          valor: '${indicadores.diasDeVida}',
          icone: Icons.calendar_today,
          compacto: true,
        ),
        IndicatorCard(
          label: 'Aves Vivas',
          valor: '${indicadores.avesVivas}',
          subtitulo: 'de ${indicadores.avesAlojadas} alojadas',
          icone: Icons.pets,
          compacto: true,
        ),
        IndicatorCard(
          label: 'Mortalidade',
          valor: '${indicadores.mortalidadePct.toStringAsFixed(2)}%',
          subtitulo: '${indicadores.mortalidadeTotal} mortes',
          cor: IndicatorColors.getMortalityColor(
              indicadores.mortalidadePct),
          icone: Icons.warning_amber,
          compacto: true,
        ),
        IndicatorCard(
          label: 'Viabilidade',
          valor: '${indicadores.viabilidade.toStringAsFixed(1)}%',
          icone: Icons.check_circle_outline,
          cor: viabilidadeCor,
          compacto: true,
        ),

        // -- Indicadores de peso --
        if (indicadores.ultimoPesoMedio != null)
          IndicatorCard(
            label: 'Peso Medio',
            valor: '${indicadores.ultimoPesoMedio!.toStringAsFixed(0)} g',
            subtitulo: indicadores.pesoPadraoG != null
                ? 'Padrao: ${indicadores.pesoPadraoG!.toStringAsFixed(0)} g'
                : null,
            cor: indicadores.pesoPadraoG != null
                ? IndicatorColors.getWeightColor(
                    indicadores.ultimoPesoMedio!, indicadores.pesoPadraoG!)
                : null,
            icone: Icons.monitor_weight,
            compacto: true,
          ),
        if (indicadores.gpd != null)
          IndicatorCard(
            label: 'GPD',
            valor: '${indicadores.gpd!.toStringAsFixed(1)} g/dia',
            subtitulo: 'Ganho de peso diario',
            icone: Icons.trending_up,
            compacto: true,
          ),

        // -- Indices zootecnicos (ICA e IEP sao os mais importantes) --
        if (indicadores.ica != null)
          IndicatorCard(
            label: 'ICA',
            valor: indicadores.ica!.toStringAsFixed(3),
            subtitulo: 'Conversao alimentar',
            cor: IndicatorColors.getICAColor(indicadores.ica!),
            icone: Icons.swap_horiz,
            compacto: true,
          ),
        if (indicadores.iep != null)
          IndicatorCard(
            label: 'IEP',
            valor: indicadores.iep!.toStringAsFixed(0),
            subtitulo: indicadores.classificacaoIep,
            cor: IndicatorColors.getIEPColor(indicadores.iep!),
            icone: Icons.speed,
            compacto: true,
          ),

        // -- Consumo de racao --
        if (indicadores.consumoRacaoPorAve != null)
          IndicatorCard(
            label: 'Racao/Ave',
            valor: '${indicadores.consumoRacaoPorAve!.toStringAsFixed(2)} kg',
            subtitulo: 'Consumo acumulado',
            icone: Icons.restaurant,
            compacto: true,
          ),
        if (indicadores.saldoRacaoKg != null)
          IndicatorCard(
            label: 'Saldo Racao',
            valor: '${indicadores.saldoRacaoKg!.toStringAsFixed(0)} kg',
            subtitulo: indicadores.diasEstoqueRacao != null
                ? '~${indicadores.diasEstoqueRacao!.toStringAsFixed(0)} dias estoque'
                : null,
            cor: indicadores.diasEstoqueRacao != null && indicadores.diasEstoqueRacao! < 2
                ? AppColors.danger
                : indicadores.diasEstoqueRacao != null && indicadores.diasEstoqueRacao! < 4
                    ? AppColors.warning
                    : null,
            icone: Icons.inventory_2,
            compacto: true,
          ),

        // -- Consumo de agua e relacao agua/racao --
        if (indicadores.consumoAguaDiaL != null)
          IndicatorCard(
            label: 'Agua Hoje',
            valor: '${indicadores.consumoAguaDiaL!.toStringAsFixed(0)} L',
            subtitulo: 'Consumo do dia',
            icone: Icons.water_drop,
            compacto: true,
          ),
        if (indicadores.relacaoAguaRacao != null)
          IndicatorCard(
            label: 'Agua/Racao',
            valor: indicadores.relacaoAguaRacao!.toStringAsFixed(2),
            subtitulo: 'Ideal: 1.6 - 2.0',
            cor: IndicatorColors.getWaterFeedRatioColor(
                indicadores.relacaoAguaRacao!),
            icone: Icons.compare_arrows,
            compacto: true,
          ),
      ],
    );
  }

  Widget _buildGraficoPeso(LoteDetailState state) {
    final dados = state.dadosGraficoPeso;
    if (dados == null) {
      return const GraficoEvolucaoPeso(
        pesoReal: [],
        pesoBenchmark: [],
      );
    }

    // Converter PontoGrafico da entidade para o do widget
    final pesoReal = dados.pesoReal
        .map((p) => PontoGrafico(label: p.label, valor: p.valor))
        .toList();
    final pesoBenchmark = dados.pesoBenchmark
        .map((p) => PontoGrafico(label: p.label, valor: p.valor))
        .toList();

    return GraficoEvolucaoPeso(
      pesoReal: pesoReal,
      pesoBenchmark: pesoBenchmark,
      linhagem: state.lote?.linhagem ?? '',
    );
  }

  Widget _buildGraficoMortalidade(LoteDetailState state) {
    final dados = state.dadosGraficoMortalidade;
    if (dados == null) {
      return const GraficoMortalidade(
        mortalidadeDiaria: [],
        mortalidadeAcumulada: [],
      );
    }

    final diaria = dados.mortalidadeDiaria
        .map((p) => PontoGrafico(label: p.label, valor: p.valor))
        .toList();
    final acumulada = dados.mortalidadeAcumulada
        .map((p) => PontoGrafico(label: p.label, valor: p.valor))
        .toList();

    return GraficoMortalidade(
      mortalidadeDiaria: diaria,
      mortalidadeAcumulada: acumulada,
    );
  }

}
