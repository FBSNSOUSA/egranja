import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/features/financeiro/domain/entities/remuneracao.dart';
import '../providers/financeiro_provider.dart';

/// Tela de remuneracao do lote.
///
/// Exibe lista de remuneracoes com detalhes: valor base,
/// bonificacoes, descontos, valor liquido, periodo e status.
class RemuneracaoScreen extends ConsumerStatefulWidget {
  const RemuneracaoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<RemuneracaoScreen> createState() =>
      _RemuneracaoScreenState();
}

class _RemuneracaoScreenState extends ConsumerState<RemuneracaoScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(remuneracaoProvider(widget.loteId).notifier).fetch();
    });
  }

  Future<void> _onRefresh() async {
    await ref.read(remuneracaoProvider(widget.loteId).notifier).fetch();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(remuneracaoProvider(widget.loteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Remuneracao'),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(RemuneracaoState state) {
    if (state.isLoading && state.remuneracoes.isEmpty) {
      return const SkeletonList(itemCount: 3);
    }

    if (state.errorMessage != null && state.remuneracoes.isEmpty) {
      return AppErrorWidget(
        message: state.errorMessage!,
        onRetry: _onRefresh,
      );
    }

    if (state.remuneracoes.isEmpty) {
      return const EmptyState(
        icon: Icons.payments_outlined,
        titulo: 'Nenhuma remuneracao registrada',
        descricao:
            'As remuneracoes serao exibidas aqui quando disponiveris.',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.remuneracoes.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final remuneracao = state.remuneracoes[index];
          return _RemuneracaoCard(remuneracao: remuneracao);
        },
      ),
    );
  }
}

/// Card detalhado de remuneracao com valor base, bonificacoes,
/// descontos, valor liquido, periodo e badge de status.
class _RemuneracaoCard extends StatelessWidget {
  const _RemuneracaoCard({required this.remuneracao});

  final Remuneracao remuneracao;

  String _formatData(String dataStr) {
    try {
      final date = DateTime.parse(dataStr);
      final dia = date.day.toString().padLeft(2, '0');
      final mes = date.month.toString().padLeft(2, '0');
      final ano = date.year;
      return '$dia/$mes/$ano';
    } catch (_) {
      return dataStr;
    }
  }

  Color _statusColor(String status) {
    const colors = {
      'pago': AppColors.success,
      'pendente': AppColors.warning,
      'atrasado': AppColors.danger,
      'cancelado': AppColors.gray500,
    };
    return colors[status] ?? AppColors.gray500;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statusColor = _statusColor(remuneracao.status);
    final periodo =
        '${_formatData(remuneracao.periodoInicio)} - ${_formatData(remuneracao.periodoFim)}';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Valor liquido + status badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberUtils.formatCurrency(remuneracao.valorLiquido),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    Remuneracao.statusLabel(remuneracao.status),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Valor liquido',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Detalhamento
            _DetalheRow(
              label: 'Valor base',
              valor: NumberUtils.formatCurrency(remuneracao.valorBase),
            ),
            const SizedBox(height: 6),
            _DetalheRow(
              label: 'Bonificacoes',
              valor:
                  '+ ${NumberUtils.formatCurrency(remuneracao.bonificacoes)}',
              valorColor: AppColors.success,
            ),
            const SizedBox(height: 6),
            _DetalheRow(
              label: 'Descontos',
              valor:
                  '- ${NumberUtils.formatCurrency(remuneracao.descontos)}',
              valorColor: AppColors.danger,
            ),
            const SizedBox(height: 12),

            // Periodo
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 14,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  periodo,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Linha de detalhe com label e valor alinhados.
class _DetalheRow extends StatelessWidget {
  const _DetalheRow({
    required this.label,
    required this.valor,
    this.valorColor,
  });

  final String label;
  final String valor;
  final Color? valorColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          valor,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: valorColor,
          ),
        ),
      ],
    );
  }
}
