import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/lote_detail_provider.dart';
import 'tabs/lote_resumo_tab.dart';
import 'tabs/lote_pesagens_tab.dart';
import 'tabs/lote_mortalidade_tab.dart';
import 'tabs/lote_racao_tab.dart';
import 'tabs/lote_agua_tab.dart';

/// Tela de detalhe de um lote com navegacao por abas.
///
/// Exibe 5 abas: Resumo, Pesagens, Mortalidade, Racao e Agua.
/// Cada aba carrega seus dados de forma lazy ao ser selecionada.
class LoteDetailScreen extends ConsumerStatefulWidget {
  const LoteDetailScreen({
    super.key,
    required this.loteId,
  });

  final String loteId;

  @override
  ConsumerState<LoteDetailScreen> createState() => _LoteDetailScreenState();
}

class _LoteDetailScreenState extends ConsumerState<LoteDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);

    // Buscar indicadores ao abrir a tela
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(loteDetailProvider(widget.loteId).notifier)
          .fetchIndicadores();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loteDetailProvider(widget.loteId));
    final theme = Theme.of(context);

    // Titulo: nome do galpao ou "Lote"
    final title = state.lote != null
        ? '${state.lote!.galpaoNome ?? 'Galpao'} - ${state.lote!.linhagem}'
        : 'Detalhes do Lote';

    return Scaffold(
      appBar: AppBar(
        title: Hero(
          tag: 'lote_${widget.loteId}',
          flightShuttleBuilder: (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            return Material(
              type: MaterialType.transparency,
              child: toHeroContext.widget,
            );
          },
          child: Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onPrimary,
            ),
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(
              icon: Icon(Icons.dashboard),
              text: 'Resumo',
            ),
            Tab(
              icon: Icon(Icons.monitor_weight),
              text: 'Pesagens',
            ),
            Tab(
              icon: Icon(Icons.warning_amber),
              text: 'Mortalidade',
            ),
            Tab(
              icon: Icon(Icons.restaurant),
              text: 'Racao',
            ),
            Tab(
              icon: Icon(Icons.water_drop),
              text: 'Agua',
            ),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          LoteResumoTab(loteId: widget.loteId),
          LotePesagensTab(loteId: widget.loteId),
          LoteMortalidadeTab(loteId: widget.loteId),
          LoteRacaoTab(loteId: widget.loteId),
          LoteAguaTab(loteId: widget.loteId),
        ],
      ),
    );
  }
}
