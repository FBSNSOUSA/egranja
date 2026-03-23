import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/indicator_card.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/lote_card.dart';
import 'package:egranja_flutter/core/widgets/offline_indicator.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:egranja_flutter/features/home/domain/entities/lote.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';

/// Filtro de alertas para a tela do tecnico.
enum _AlertFilter {
  todos,
  comAlertas,
  semAlertas,
}

/// Tela principal do tecnico.
///
/// Exibe barra de estatisticas, filtros por alerta, busca por produtor
/// e lista de lotes agrupados por produtor.
class HomeTecnicoScreen extends ConsumerStatefulWidget {
  const HomeTecnicoScreen({super.key});

  @override
  ConsumerState<HomeTecnicoScreen> createState() => _HomeTecnicoScreenState();
}

class _HomeTecnicoScreenState extends ConsumerState<HomeTecnicoScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  _AlertFilter _alertFilter = _AlertFilter.todos;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(homeProvider.notifier).fetchLotes();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(homeProvider.notifier).loadMore();
    }
  }

  /// Filtra lotes baseado no filtro de alerta e busca.
  List<Lote> _filterLotes(List<Lote> lotes) {
    var filtered = lotes;

    // Filtro de alertas (based on mortalidade_total for now,
    // since the backend doesn't return a dedicated alert field)
    switch (_alertFilter) {
      case _AlertFilter.comAlertas:
        filtered = filtered
            .where((l) => (l.mortalidadeTotal ?? 0) > 0)
            .toList();
      case _AlertFilter.semAlertas:
        filtered = filtered
            .where((l) => (l.mortalidadeTotal ?? 0) == 0)
            .toList();
      case _AlertFilter.todos:
        break;
    }

    // Filtro de busca por produtor (galpao nome como proxy)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered
          .where((l) => l.galpaoNome.toLowerCase().contains(query))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeProvider);
    final authState = ref.watch(authNotifierProvider);
    final connectivityAsync = ref.watch(connectivityProvider);
    final theme = Theme.of(context);

    final userName = authState.user?.nome ?? 'Tecnico';
    final firstName = userName.split(' ').first;

    final isOnline = connectivityAsync.when(
      data: (online) => online,
      loading: () => true,
      error: (e, s) => true,
    );

    final filteredLotes = _filterLotes(state.lotesAtivos);

    return Column(
      children: [
        const OfflineIndicator(),
        _buildGreetingHeader(theme, firstName, isOnline),

        // Stats bar
        if (!state.isLoading || state.lotesAtivos.isNotEmpty)
          _buildStatsBar(theme, state.lotesAtivos),

        // Search and filter
        _buildSearchAndFilter(theme),

        // Content
        Expanded(
          child: _buildContent(state, filteredLotes, theme),
        ),
      ],
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
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isOnline ? AppColors.online : AppColors.offline,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chat_outlined),
            tooltip: 'Mensagens',
            onPressed: () => context.goNamed(RouteNames.chatList),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsBar(ThemeData theme, List<Lote> lotes) {
    final totalLotes = lotes.length;
    final totalAlertas =
        lotes.where((l) => (l.mortalidadeTotal ?? 0) > 0).length;
    final totalAves = lotes.fold<int>(
      0,
      (sum, l) => sum + (l.avesVivas ?? l.quantidade),
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: IndicatorCard(
              label: 'Lotes Ativos',
              valor: '$totalLotes',
              icone: Icons.inventory_2_outlined,
              compacto: true,
            ),
          ),
          Expanded(
            child: IndicatorCard(
              label: 'Alertas',
              valor: '$totalAlertas',
              icone: Icons.warning_amber_rounded,
              cor: totalAlertas > 0 ? AppColors.danger : AppColors.success,
              compacto: true,
            ),
          ),
          Expanded(
            child: IndicatorCard(
              label: 'Aves Vivas',
              valor: _formatNumber(totalAves),
              icone: Icons.pets_outlined,
              compacto: true,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Column(
        children: [
          // Search field
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Buscar por galpao...',
              prefixIcon: const Icon(Icons.search, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
            ),
            onChanged: (value) => setState(() => _searchQuery = value),
          ),
          const SizedBox(height: 8),

          // Filter chips
          Row(
            children: [
              _buildFilterChip(
                'Todos',
                _AlertFilter.todos,
                theme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Com Alertas',
                _AlertFilter.comAlertas,
                theme,
              ),
              const SizedBox(width: 8),
              _buildFilterChip(
                'Sem Alertas',
                _AlertFilter.semAlertas,
                theme,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String label,
    _AlertFilter filter,
    ThemeData theme,
  ) {
    final isSelected = _alertFilter == filter;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) {
        setState(() => _alertFilter = filter);
      },
      visualDensity: VisualDensity.compact,
      selectedColor: theme.colorScheme.primaryContainer,
    );
  }

  Widget _buildContent(
    HomeState state,
    List<Lote> filteredLotes,
    ThemeData theme,
  ) {
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

    // Empty state (no lotes at all)
    if (state.lotesAtivos.isEmpty) {
      return const EmptyState(
        icon: Icons.inventory_2_outlined,
        titulo: 'Nenhum lote ativo',
        descricao: 'Nenhum produtor possui lotes ativos no momento.',
      );
    }

    // Empty filtered results
    if (filteredLotes.isEmpty) {
      return const EmptyState(
        icon: Icons.filter_list_off,
        titulo: 'Nenhum resultado',
        descricao: 'Nenhum lote corresponde aos filtros selecionados.',
      );
    }

    // Group lotes by galpao name
    final grouped = <String, List<Lote>>{};
    for (final lote in filteredLotes) {
      grouped.putIfAbsent(lote.galpaoNome, () => []).add(lote);
    }
    final groupKeys = grouped.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: () => ref.read(homeProvider.notifier).refresh(),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _countGroupedItems(groupKeys, grouped) +
            (state.hasMore ? 1 : 0),
        itemBuilder: (context, index) {
          // Loading more indicator
          final totalItems = _countGroupedItems(groupKeys, grouped);
          if (index >= totalItems) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }

          // Find which group/lote this index corresponds to
          final result = _getGroupedItem(index, groupKeys, grouped);

          if (result.isHeader) {
            return Padding(
              padding: EdgeInsets.only(
                top: index == 0 ? 0 : 16,
                bottom: 8,
              ),
              child: Text(
                result.headerTitle!,
                style: theme.textTheme.titleSmall?.copyWith(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final lote = result.lote!;
          final cardData = _loteToCardData(lote);

          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
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

  /// Conta o total de itens (headers + lotes) nas secoes agrupadas.
  int _countGroupedItems(
    List<String> keys,
    Map<String, List<Lote>> grouped,
  ) {
    int count = 0;
    for (final key in keys) {
      count += 1; // header
      count += grouped[key]!.length; // lotes
    }
    return count;
  }

  /// Retorna o item (header ou lote) correspondente ao indice na lista flat.
  _GroupedItem _getGroupedItem(
    int index,
    List<String> keys,
    Map<String, List<Lote>> grouped,
  ) {
    int current = 0;
    for (final key in keys) {
      if (current == index) {
        return _GroupedItem.header(key);
      }
      current++;
      final lotes = grouped[key]!;
      if (index < current + lotes.length) {
        return _GroupedItem.lote(lotes[index - current]);
      }
      current += lotes.length;
    }
    return _GroupedItem.header('');
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bom dia,';
    if (hour < 18) return 'Boa tarde,';
    return 'Boa noite,';
  }

  String _formatNumber(int number) {
    if (number >= 1000) {
      return NumberFormat.compact(locale: 'pt_BR').format(number);
    }
    return '$number';
  }

  LoteCardData _loteToCardData(Lote lote) {
    DateTime dataAlojamento;
    try {
      dataAlojamento = DateTime.parse(lote.dataAlojamento);
    } catch (_) {
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
    );
  }
}

/// Item auxiliar para a lista agrupada (header ou lote).
class _GroupedItem {
  final bool isHeader;
  final String? headerTitle;
  final Lote? lote;

  const _GroupedItem._({
    required this.isHeader,
    this.headerTitle,
    this.lote,
  });

  factory _GroupedItem.header(String title) => _GroupedItem._(
        isHeader: true,
        headerTitle: title,
      );

  factory _GroupedItem.lote(Lote lote) => _GroupedItem._(
        isHeader: false,
        lote: lote,
      );
}
