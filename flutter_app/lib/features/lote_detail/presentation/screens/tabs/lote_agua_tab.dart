import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/agua.dart';
import '../../providers/agua_provider.dart';

/// Aba de consumo de agua do lote.
///
/// Exibe lista de registros de consumo de agua com paginacao
/// e FAB para novo registro.
class LoteAguaTab extends ConsumerStatefulWidget {
  const LoteAguaTab({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<LoteAguaTab> createState() => _LoteAguaTabState();
}

class _LoteAguaTabState extends ConsumerState<LoteAguaTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(aguaProvider(widget.loteId).notifier).fetch();
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
      ref.read(aguaProvider(widget.loteId).notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final state = ref.watch(aguaProvider(widget.loteId));
    final theme = Theme.of(context);

    return _buildBody(state, theme);
  }

  Widget _buildBody(AguaState state, ThemeData theme) {
    if (state.isLoading && state.consumos.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: SkeletonList(itemCount: 3),
      );
    }

    if (state.errorMessage != null && state.consumos.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: () =>
            ref.read(aguaProvider(widget.loteId).notifier).fetch(),
      );
    }

    if (state.consumos.isEmpty) {
      return EmptyState(
        icon: Icons.water_drop_outlined,
        titulo: 'Nenhum consumo de agua registrado',
        descricao: 'Registre o consumo diario de agua do lote.',
        actionLabel: 'Novo Consumo',
        actionIcon: Icons.add,
        onAction: () {
          context.pushNamed(
            RouteNames.novoConsumoAgua,
            pathParameters: {'loteId': widget.loteId},
          );
        },
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(aguaProvider(widget.loteId).notifier).fetch();
      },
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        itemCount: state.consumos.length + (state.isLoading ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= state.consumos.length) {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          return _ConsumoAguaCard(consumo: state.consumos[index]);
        },
      ),
    );
  }
}

class _ConsumoAguaCard extends StatelessWidget {
  const _ConsumoAguaCard({required this.consumo});

  final ConsumoAgua consumo;

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
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _formatDate(consumo.data),
              style: theme.textTheme.titleSmall,
            ),
            Text(
              '${consumo.quantidadeLitros.toStringAsFixed(0)} L',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
