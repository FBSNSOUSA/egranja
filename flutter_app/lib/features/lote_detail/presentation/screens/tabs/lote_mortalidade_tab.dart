import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/mortalidade.dart';
import '../../providers/mortalidade_provider.dart';

/// Aba de mortalidade do lote.
///
/// Exibe lista de registros de mortalidade com paginacao e FAB
/// para novo registro.
class LoteMortalidadeTab extends ConsumerStatefulWidget {
  const LoteMortalidadeTab({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<LoteMortalidadeTab> createState() =>
      _LoteMortalidadeTabState();
}

class _LoteMortalidadeTabState extends ConsumerState<LoteMortalidadeTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mortalidadeProvider(widget.loteId).notifier).fetch();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(mortalidadeProvider(widget.loteId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(mortalidadeProvider(widget.loteId));
    final theme = Theme.of(context);

    return _buildBody(state, theme);
  }

  Widget _buildBody(MortalidadeState state, ThemeData theme) {
    if (state.isLoading && state.mortalidades.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    if (state.errorMessage != null && state.mortalidades.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(mortalidadeProvider(widget.loteId).notifier).fetch(),
      );
    }

    if (state.mortalidades.isEmpty) {
      return EmptyState(
        icon: Icons.warning_amber_outlined,
        titulo: 'Nenhuma mortalidade registrada',
        descricao: 'Registre a mortalidade diaria do lote.',
        actionLabel: 'Nova Mortalidade',
        actionIcon: Icons.add,
        onAction: () {
          context.pushNamed(
            RouteNames.novaMortalidade,
            pathParameters: {'loteId': widget.loteId},
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref
            .read(mortalidadeProvider(widget.loteId).notifier)
            .fetch();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount:
            state.mortalidades.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.mortalidades.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _MortalidadeCard(
              mortalidade: state.mortalidades[index]);
        },
      ),
    );
  }
}

class _MortalidadeCard extends StatelessWidget {
  const _MortalidadeCard({required this.mortalidade});

  final Mortalidade mortalidade;

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final ano = date.year;
      return '$dia/$mes/$ano';
    } catch (_) {
      return isoDate;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: data
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _formatDate(mortalidade.data),
                  style: theme.textTheme.titleSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Quantidade
            Text(
              '${mortalidade.quantidade} aves',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),

            // Causa
            Chip(
              label: Text(
                mortalidade.causa,
                style: theme.textTheme.labelSmall,
              ),
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),

            // Observacao
            if (mortalidade.observacao != null &&
                mortalidade.observacao!.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                mortalidade.observacao!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
