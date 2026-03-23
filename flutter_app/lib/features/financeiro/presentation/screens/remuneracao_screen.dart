import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import 'package:egranja_flutter/core/widgets/empty_state.dart';
import 'package:egranja_flutter/core/widgets/error_widget.dart';
import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';
import 'package:egranja_flutter/features/financeiro/domain/entities/remuneracao.dart';
import 'package:egranja_flutter/features/home/presentation/providers/home_provider.dart';
import '../providers/financeiro_provider.dart';

/// Tela de remuneracao do lote.
///
/// Exibe lista de remuneracoes com detalhes: valor,
/// tipo, data de pagamento e observacao.
class RemuneracaoScreen extends ConsumerStatefulWidget {
  const RemuneracaoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<RemuneracaoScreen> createState() =>
      _RemuneracaoScreenState();
}

class _RemuneracaoScreenState extends ConsumerState<RemuneracaoScreen> {
  late String _selectedLoteId;

  @override
  void initState() {
    super.initState();
    _selectedLoteId = widget.loteId;
    Future.microtask(() {
      ref.read(homeProvider.notifier).fetchLotes();
    });
    if (_selectedLoteId.isNotEmpty) {
      Future.microtask(() {
        ref.read(remuneracaoProvider(_selectedLoteId).notifier).fetch();
      });
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(remuneracaoProvider(_selectedLoteId).notifier).fetch();
  }

  void _onLoteChanged(String loteId) {
    setState(() {
      _selectedLoteId = loteId;
    });
    if (loteId.isNotEmpty) {
      ref.read(remuneracaoProvider(loteId).notifier).fetch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);
    final theme = Theme.of(context);

    // Auto-select first lote if none selected and lotes are loaded
    final lotes = homeState.lotesAtivos;
    if (_selectedLoteId.isEmpty && lotes.isNotEmpty) {
      Future.microtask(() => _onLoteChanged(lotes.first.id));
    }

    final state = _selectedLoteId.isNotEmpty
        ? ref.watch(remuneracaoProvider(_selectedLoteId))
        : null;

    return Column(
      children: [
        _buildLoteSelector(homeState, theme),
        Expanded(
          child: _selectedLoteId.isEmpty
              ? const EmptyState(
                  icon: Icons.payments_outlined,
                  titulo: 'Selecione um lote',
                  descricao:
                      'Escolha um lote para visualizar as remuneracoes.',
                )
              : _buildBody(state!),
        ),
      ],
    );
  }

  Widget _buildLoteSelector(HomeState homeState, ThemeData theme) {
    final lotes = homeState.lotesAtivos;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: AppColors.divider),
        ),
      ),
      child: DropdownField(
        label: 'Lote',
        value: _selectedLoteId.isNotEmpty ? _selectedLoteId : null,
        options: lotes
            .map((l) => DropdownOption(
                  value: l.id,
                  label: '${l.galpaoNome} - Dia ${l.diasDeVida ?? 0}',
                ))
            .toList(),
        placeholder: 'Selecione um lote...',
        onSelect: (option) => _onLoteChanged(option.value),
      ),
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
            'As remuneracoes serao exibidas aqui quando disponiveis.',
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

/// Card detalhado de remuneracao com valor, tipo, data de
/// pagamento e observacao.
class _RemuneracaoCard extends StatelessWidget {
  const _RemuneracaoCard({required this.remuneracao});

  final Remuneracao remuneracao;

  String _formatData(String? dataStr) {
    if (dataStr == null || dataStr.isEmpty) return '';
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Valor + tipo badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  NumberUtils.formatCurrency(remuneracao.valor),
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.success,
                  ),
                ),
                if (remuneracao.tipo != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(30),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      Remuneracao.tipoLabel(remuneracao.tipo),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Valor',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),

            // Observacao
            if (remuneracao.observacao != null &&
                remuneracao.observacao!.isNotEmpty) ...[
              const Divider(height: 1),
              const SizedBox(height: 12),
              _DetalheRow(
                label: 'Observacao',
                valor: remuneracao.observacao!,
              ),
              const SizedBox(height: 6),
            ],

            // Data de pagamento
            if (remuneracao.dataPagamento != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pago em ${_formatData(remuneracao.dataPagamento)}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
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
  });

  final String label;
  final String valor;

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
            color: theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
