import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/fab_menu.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/lote_card.dart';
import 'package:egranja_flutter/core/widgets/offline_indicator.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:egranja_flutter/features/home/domain/entities/lote.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';

/// Tela principal do produtor.
///
/// Exibe lista de lotes ativos com pull-to-refresh, paginacao
/// e FAB para criacao de novo lote.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Carregar lotes na inicializacao
    Future.microtask(() {
      ref.read(homeProvider.notifier).fetchLotes();
    });
    // Listener para paginacao
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(homeProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final authState = ref.watch(authNotifierProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final theme = Theme.of(context);

    final userName = authState.user?.nome ?? 'Produtor';
    final firstName = userName.split(' ').first;

    final isOnline = connectivityAsync.when(
      data: (online) => online,
      loading: () => true,
      error: (e, s) => true,
    );

    return Scaffold(
      body: Column(
        children: [
          // Offline indicator
          const OfflineIndicator(),

          // Greeting header
          _buildGreetingHeader(theme, firstName, isOnline),

          // Content
          Expanded(
            child: _buildContent(state, theme),
          ),
        ],
      ),
      floatingActionButton: FABMenu(
        actions: [
          FABAction(
            label: 'Novo Lote',
            icon: Icons.add,
            onPress: () => context.goNamed(RouteNames.novoLote),
          ),
        ],
      ),
    );
  }

  Widget _buildGreetingHeader(ThemeData theme, String name, bool isOnline) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          // Online/Offline status dot
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.online : AppColors.offline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          // Messages icon
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: 'Mensagens',
            onPressed: () => context.goNamed(RouteNames.chatList),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(HomeState state, ThemeData theme) {
    // Loading state
    if (state.isLoading && state.lotesAtivos.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    // Error state (no data)
    if (state.error != null && state.lotesAtivos.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(homeProvider.notifier).fetchLotes(),
      );
    }

    // Empty state
    if (state.lotesAtivos.isEmpty) {
      return EmptyState(
        icon: Icons.inventory_2_outlined,
        titulo: 'Nenhum lote ativo',
        descricao: 'Crie um novo lote para comecar o acompanhamento.',
        actionLabel: 'Novo Lote',
        actionIcon: Icons.add,
        onAction: () => context.goNamed(RouteNames.novoLote),
      );
    }

    // Data loaded
    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: state.lotesAtivos.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          if (index >= state.lotesAtivos.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final lote = state.lotesAtivos[index];
          final cardData = _loteToCardData(lote);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LoteCard(
              data: cardData,
              onTap: () => context.goNamed(
                RouteNames.loteDetail,
                pathParameters: {'loteId': lote.id},
              ),
            ),
          );
        },
      ),
    );
  }

  /// Retorna saudacao baseada na hora do dia.
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia,';
    if (hour < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  /// Converte [Lote] da entidade de dominio para [LoteCardData] do widget.
  LoteCardData _loteToCardData(Lote lote) {
    DateTime dataAlojamento;
    try {
      dataAlojamento = DateTime.parse(lote.dataAlojamento);
    } catch (_) {
      // Tentar formato DD/MM/YYYY
      try {
        dataAlojamento = DateFormat('dd/MM/yyyy').parse(lote.dataAlojamento);
      } catch (_) {
        dataAlojamento = DateTime.now();
      }
    }

    DateTime? dataMortesRecentes;
    if (lote.dataMortesRecentes != null) {
      try {
        dataMortesRecentes = DateTime.parse(lote.dataMortesRecentes!);
      } catch (_) {
        try {
          dataMortesRecentes =
              DateFormat('dd/MM/yyyy').parse(lote.dataMortesRecentes!);
        } catch (_) {
          dataMortesRecentes = null;
        }
      }
    }

    return LoteCardData(
      id: lote.id,
      galpaoNome: lote.galpaoNome,
      dataAlojamento: dataAlojamento,
      tipo: lote.tipo,
      linhagem: lote.linhagem ?? 'N/A',
      quantidadeOriginal: lote.quantidade,
      mortalidadeAcumulada: lote.mortalidadeAcumulada ?? 0,
      ultimoPesoMedio: lote.ultimoPesoMedio,
      pesoBenchmark: lote.pesoBenchmark,
      mortesRecentes: lote.mortesRecentes,
      dataMortesRecentes: dataMortesRecentes,
      mortalidadeRecentePct: lote.mortalidadeRecentePct,
      temAlerta: lote.temAlerta ?? false,
      quantidadeAlertas: lote.quantidadeAlertas ?? 0,
    );
  }
}
