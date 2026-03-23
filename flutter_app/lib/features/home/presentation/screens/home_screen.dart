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

    return Stack(
      children: [
        Column(
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
        Positioned(
          right: 16,
          bottom: 16,
          child: FABMenu(
            actions: [
              FABAction(
                label: 'Registrar Pesagem',
                icon: Icons.monitor_weight_outlined,
                onPress: () =>
                    _quickAction(context, state, RouteNames.novaPesagem),
              ),
              FABAction(
                label: 'Registrar Mortalidade',
                icon: Icons.warning_amber_rounded,
                onPress: () =>
                    _quickAction(context, state, RouteNames.novaMortalidade),
              ),
              FABAction(
                label: 'Novo Lote',
                icon: Icons.add,
                onPress: () => context.pushNamed(RouteNames.novoLote),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGreetingHeader(ThemeData theme, String name, bool isOnline) {
    final state = ref.watch(homeProvider);
    final loteCount = state.lotesAtivos.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar circle with user initial
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : 'P',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getGreeting(),
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (loteCount > 0)
                  Text(
                    '$loteCount lote${loteCount != 1 ? 's' : ''} ativo${loteCount != 1 ? 's' : ''}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
          // Online/Offline status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isOnline
                  ? AppColors.successLight
                  : AppColors.warningLight,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isOnline ? AppColors.online : AppColors.offline,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  isOnline ? 'Online' : 'Offline',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: isOnline ? AppColors.online : AppColors.offline,
                    fontWeight: FontWeight.w600,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
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
        onAction: () => context.pushNamed(RouteNames.novoLote),
      );
    }

    // Data loaded
    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        // +1 for the section header, +1 for loading more
        itemCount: 1 + state.lotesAtivos.length + (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Section header
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(4, 8, 4, 12),
              child: Row(
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 20,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Lotes Ativos',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${state.lotesAtivos.length}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }

          final itemIndex = index - 1;

          // Loading more indicator
          if (itemIndex >= state.lotesAtivos.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          final lote = state.lotesAtivos[itemIndex];
          final cardData = _loteToCardData(lote);

          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: LoteCard(
              data: cardData,
              onTap: () => context.pushNamed(
                RouteNames.loteDetail,
                pathParameters: {'loteId': lote.id},
              ),
              onPesagem: lote.status == 'ativo'
                  ? () => context.pushNamed(
                        RouteNames.novaPesagem,
                        pathParameters: {'loteId': lote.id},
                      )
                  : null,
              onMortalidade: lote.status == 'ativo'
                  ? () => context.pushNamed(
                        RouteNames.novaMortalidade,
                        pathParameters: {'loteId': lote.id},
                      )
                  : null,
            ),
          );
        },
      ),
    );
  }

  /// Navega para um formulario de acao rapida (pesagem ou mortalidade).
  ///
  /// Se houver apenas 1 lote ativo, navega direto. Se houver mais,
  /// exibe um bottom sheet para o usuario escolher o lote.
  void _quickAction(
      BuildContext context, HomeState state, String routeName) {
    final lotes = state.lotesAtivos;
    if (lotes.isEmpty) return;

    if (lotes.length == 1) {
      context.pushNamed(
        routeName,
        pathParameters: {'loteId': lotes.first.id},
      );
      return;
    }

    // Multiplos lotes: mostrar seletor
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) {
        final theme = Theme.of(ctx);
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Text(
                  'Selecione o lote',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const Divider(),
              ...lotes.map((lote) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          theme.colorScheme.primary.withAlpha(30),
                      child: Text(
                        '${lote.diasDeVida ?? 0}d',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    title: Text(lote.galpaoNome),
                    subtitle: Text(
                      '${lote.tipo} - ${lote.linhagem ?? "N/A"}',
                      style: theme.textTheme.bodySmall,
                    ),
                    onTap: () {
                      Navigator.of(ctx).pop();
                      context.pushNamed(
                        routeName,
                        pathParameters: {'loteId': lote.id},
                      );
                    },
                  )),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
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

    return LoteCardData(
      id: lote.id,
      galpaoNome: lote.galpaoNome,
      dataAlojamento: dataAlojamento,
      tipo: lote.tipo,
      linhagem: lote.linhagem ?? 'N/A',
      quantidadeOriginal: lote.quantidade,
      mortalidadeAcumulada: lote.mortalidadeTotal ?? 0,
      diasDeVida: lote.diasDeVida,
      avesVivas: lote.avesVivas,
      ultimoPesoMedio: lote.ultimoPesoMedio,
      status: lote.status,
    );
  }
}
