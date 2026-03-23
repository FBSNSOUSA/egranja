import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/lote_card.dart';
import 'package:egranja_flutter/features/home/domain/entities/lote.dart';
import 'package:egranja_flutter/features/produtores/presentation/providers/produtores_provider.dart';

/// Tela de produtores vinculados ao tecnico.
///
/// Exibe todos os lotes dos produtores vinculados, agrupados por
/// galpao/produtor, com resumo de indicadores.
class ProdutoresScreen extends ConsumerStatefulWidget {
  const ProdutoresScreen({super.key});

  @override
  ConsumerState<ProdutoresScreen> createState() =>
      _ProdutoresScreenState();
}

class _ProdutoresScreenState extends ConsumerState<ProdutoresScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(produtoresProvider.notifier).fetchLotes();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(produtoresProvider);
    final theme = Theme.of(context);

    return Column(
      children: [
        _buildHeader(theme, state),
        _buildSearchField(theme),
        Expanded(child: _buildContent(state, theme)),
      ],
    );
  }

  Widget _buildHeader(ThemeData theme, ProdutoresState state) {
    final totalLotes = state.lotes.length;
    final totalAves = state.lotes.fold<int>(
      0,
      (sum, l) => sum + (l.avesVivas ?? l.quantidade),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Produtores Vinculados',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (!state.isLoading)
            Text(
              '$totalLotes lote${totalLotes != 1 ? 's' : ''} '
              'ativo${totalLotes != 1 ? 's' : ''} - '
              '${NumberFormat.compact(locale: 'pt_BR').format(totalAves)} aves',
              style: theme.textTheme.bodySmall
                  ?.copyWith(color: AppColors.textSecondary),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchField(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Buscar por galpao...',
          prefixIcon: const Icon(Icons.search, size: 20),
          isDense: true,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
    );
  }

  Widget _buildContent(ProdutoresState state, ThemeData theme) {
    if (state.isLoading && state.lotes.isEmpty) {
      return const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    if (state.error != null && state.lotes.isEmpty) {
      return AppErrorWidget(
        message: state.error!,
        onRetry: () => ref.read(produtoresProvider.notifier).fetchLotes(),
      );
    }

    if (state.lotes.isEmpty) {
      return const EmptyState(
        icon: Icons.people_outlined,
        titulo: 'Nenhum produtor vinculado',
        descricao: 'Nao ha produtores vinculados a sua conta.',
      );
    }

    var filteredLotes = state.lotes;
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filteredLotes = filteredLotes
          .where((l) => l.galpaoNome.toLowerCase().contains(query))
          .toList();
    }

    if (filteredLotes.isEmpty) {
      return const EmptyState(
        icon: Icons.filter_list_off,
        titulo: 'Nenhum resultado',
        descricao: 'Nenhum lote corresponde a busca.',
      );
    }

    final grouped = <String, List<Lote>>{};
    for (final lote in filteredLotes) {
      grouped.putIfAbsent(lote.galpaoNome, () => []).add(lote);
    }
    final groupKeys = grouped.keys.toList()..sort();

    return RefreshIndicator(
      onRefresh: () => ref.read(produtoresProvider.notifier).refresh(),
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: _countGroupedItems(groupKeys, grouped),
        itemBuilder: (context, index) {
          final result = _getGroupedItem(index, groupKeys, grouped);

          if (result.isHeader) {
            final lotes = grouped[result.headerTitle]!;
            final totalAves = lotes.fold<int>(
              0,
              (sum, l) => sum + (l.avesVivas ?? l.quantidade),
            );
            return Padding(
              padding: EdgeInsets.only(
                top: index == 0 ? 0 : 16,
                bottom: 8,
              ),
              child: Row(
                children: [
                  const Icon(Icons.warehouse_outlined,
                      size: 18, color: AppColors.textSecondary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      result.headerTitle!,
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${lotes.length} lote${lotes.length != 1 ? 's' : ''}'
                    ' - $totalAves aves',
                    style: theme.textTheme.labelSmall
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            );
          }

          final lote = result.lote!;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LoteCard(
              data: _loteToCardData(lote),
              onTap: () => context.pushNamed(
                RouteNames.loteDetail,
                pathParameters: {'loteId': lote.id},
              ),
            ),
          );
        },
      ),
    );
  }

  int _countGroupedItems(
      List<String> keys, Map<String, List<Lote>> grouped) {
    int count = 0;
    for (final key in keys) {
      count += 1 + grouped[key]!.length;
    }
    return count;
  }

  _GroupedItem _getGroupedItem(
    int index,
    List<String> keys,
    Map<String, List<Lote>> grouped,
  ) {
    int current = 0;
    for (final key in keys) {
      if (current == index) return _GroupedItem.header(key);
      current++;
      final lotes = grouped[key]!;
      if (index < current + lotes.length) {
        return _GroupedItem.lote(lotes[index - current]);
      }
      current += lotes.length;
    }
    return _GroupedItem.header('');
  }

  LoteCardData _loteToCardData(Lote lote) {
    DateTime dataAlojamento;
    try {
      dataAlojamento = DateTime.parse(lote.dataAlojamento);
    } catch (_) {
      try {
        dataAlojamento =
            DateFormat('dd/MM/yyyy').parse(lote.dataAlojamento);
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

class _GroupedItem {
  final bool isHeader;
  final String? headerTitle;
  final Lote? lote;

  const _GroupedItem._({
    required this.isHeader,
    this.headerTitle,
    this.lote,
  });

  factory _GroupedItem.header(String title) =>
      _GroupedItem._(isHeader: true, headerTitle: title);

  factory _GroupedItem.lote(Lote lote) =>
      _GroupedItem._(isHeader: false, lote: lote);
}
