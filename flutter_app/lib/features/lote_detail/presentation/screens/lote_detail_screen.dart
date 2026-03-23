import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import '../providers/lote_detail_provider.dart';
import 'tabs/lote_resumo_tab.dart';
import 'tabs/lote_pesagens_tab.dart';
import 'tabs/lote_mortalidade_tab.dart';
import 'tabs/lote_racao_tab.dart';
import 'tabs/lote_agua_tab.dart';

/// Tela de detalhe de um lote com navegacao por abas.
///
/// Exibe barra de resumo com indicadores-chave no topo (dias, aves, mortalidade),
/// seguida de 5 abas: Resumo, Pesagens, Mortalidade, Racao e Agua.
/// Cada aba carrega seus dados de forma lazy ao ser selecionada.
/// Inclui acoes rapidas via FAB para as tarefas diarias mais comuns.
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

    final isAtivo = state.lote?.status == 'ativo';

    return Stack(
      children: [
        Column(
          children: [
            _buildQuickSummary(state, theme),
            Material(
              color: theme.colorScheme.primary,
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                padding: const EdgeInsets.symmetric(horizontal: 8),
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                indicatorColor: Colors.white,
                tabs: const [
                  Tab(text: 'Resumo'),
                  Tab(text: 'Pesagens'),
                  Tab(text: 'Mortalidade'),
                  Tab(text: 'Racao'),
                  Tab(text: 'Agua'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  LoteResumoTab(loteId: widget.loteId),
                  LotePesagensTab(loteId: widget.loteId),
                  LoteMortalidadeTab(loteId: widget.loteId),
                  LoteRacaoTab(loteId: widget.loteId),
                  LoteAguaTab(loteId: widget.loteId),
                ],
              ),
            ),
          ],
        ),
        if (isAtivo)
          Positioned(
            right: 16,
            bottom: 16,
            child: _QuickActionsFAB(loteId: widget.loteId),
          ),
      ],
    );
  }

  /// Barra compacta de resumo com indicadores-chave sempre visiveis.
  Widget _buildQuickSummary(LoteDetailState state, ThemeData theme) {
    final indicadores = state.indicadores;
    if (indicadores == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _SummaryChip(
            label: 'Dia',
            value: '${indicadores.diasDeVida}',
            color: AppColors.white,
          ),
          _SummaryChip(
            label: 'Aves',
            value: '${indicadores.avesVivas}',
            color: AppColors.white,
          ),
          _SummaryChip(
            label: 'Mort.',
            value: '${indicadores.mortalidadePct.toStringAsFixed(1)}%',
            color: indicadores.mortalidadePct > 5
                ? AppColors.dangerLight
                : indicadores.mortalidadePct > 3
                    ? AppColors.warningLight
                    : AppColors.successLight,
          ),
          if (indicadores.ultimoPesoMedio != null)
            _SummaryChip(
              label: 'Peso',
              value: '${indicadores.ultimoPesoMedio!.toStringAsFixed(0)}g',
              color: AppColors.white,
            ),
        ],
      ),
    );
  }
}

/// Chip compacto para exibicao de indicador na barra de resumo.
class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(50),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.white.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              color: AppColors.white,
              fontWeight: FontWeight.w800,
              fontSize: 15,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: AppColors.white.withValues(alpha: 0.8),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// FAB com acoes rapidas para tarefas diarias mais comuns.
/// Permite registrar mortalidade, pesagem, consumo de racao e agua
/// sem navegar pelas abas - acesso direto do ponto central.
class _QuickActionsFAB extends StatefulWidget {
  const _QuickActionsFAB({required this.loteId});

  final String loteId;

  @override
  State<_QuickActionsFAB> createState() => _QuickActionsFABState();
}

class _QuickActionsFABState extends State<_QuickActionsFAB>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _expandAnimation;
  bool _isOpen = false;

  static const _actions = [
    (label: 'Mortalidade', icon: Icons.warning_amber, route: RouteNames.novaMortalidade),
    (label: 'Pesagem', icon: Icons.monitor_weight, route: RouteNames.novaPesagem),
    (label: 'Consumo Racao', icon: Icons.restaurant, route: RouteNames.novoConsumo),
    (label: 'Consumo Agua', icon: Icons.water_drop, route: RouteNames.novoConsumoAgua),
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _expandAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
      if (_isOpen) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    });
  }

  void _close() {
    setState(() {
      _isOpen = false;
      _controller.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 240,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Action items
          ...List.generate(_actions.length, (index) {
            final action = _actions[index];
            final reverseIndex = _actions.length - 1 - index;

            return FadeTransition(
              opacity: _expandAnimation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset(0, (reverseIndex + 1) * 0.3),
                  end: Offset.zero,
                ).animate(_expandAnimation),
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 2,
                        borderRadius: BorderRadius.circular(6),
                        color: theme.colorScheme.surface,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          child: Text(
                            action.label,
                            style: theme.textTheme.labelMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton.small(
                        heroTag: 'quick_action_$index',
                        backgroundColor: theme.colorScheme.primary,
                        onPressed: () {
                          _close();
                          context.pushNamed(
                            action.route,
                            pathParameters: {'loteId': widget.loteId},
                          );
                        },
                        child: Icon(action.icon, size: 20),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const SizedBox(height: 4),

          // Main FAB
          FloatingActionButton(
            heroTag: 'quick_actions_main',
            backgroundColor: theme.colorScheme.primary,
            onPressed: _toggle,
            tooltip: 'Acoes rapidas',
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 250),
              child: const Icon(Icons.add),
            ),
          ),
        ],
      ),
    );
  }
}
