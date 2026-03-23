import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/features/lote_detail/domain/entities/finalizar_lote_payload.dart';
import '../../providers/lote_detail_provider.dart';

/// Tela de finalizacao de lote.
///
/// Coleta dados de encerramento (aves entregues, peso, sobra de racao)
/// e exibe dialogo de confirmacao antes de submeter.
class FinalizarLoteScreen extends ConsumerStatefulWidget {
  const FinalizarLoteScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<FinalizarLoteScreen> createState() =>
      _FinalizarLoteScreenState();
}

class _FinalizarLoteScreenState
    extends ConsumerState<FinalizarLoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _avesController = TextEditingController();
  final _pesoTotalController = TextEditingController();
  final _sobraRacaoController = TextEditingController();
  DateTime _dataFinalizacao = DateTime.now();

  Future<void> _showConfirmDialog() async {
    if (!_formKey.currentState!.validate()) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmar Finalizacao'),
        content: const Text(
          'Tem certeza que deseja finalizar este lote? '
          'Esta acao nao pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
            ),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _submit();
    }
  }

  Future<void> _submit() async {
    final dataFormatted =
        '${_dataFinalizacao.year}-${_dataFinalizacao.month.toString().padLeft(2, '0')}-${_dataFinalizacao.day.toString().padLeft(2, '0')}';

    final sobraRacao = _sobraRacaoController.text.isNotEmpty
        ? double.tryParse(_sobraRacaoController.text)
        : null;

    final payload = FinalizarLotePayload(
      dataFinalizacao: dataFormatted,
      avesEntregues: int.parse(_avesController.text),
      pesoTotalEntregue: double.parse(_pesoTotalController.text),
      sobraRacaoKg: sobraRacao,
    );

    final success = await ref
        .read(loteDetailProvider(widget.loteId).notifier)
        .finalizarLote(payload);

    if (success && mounted) {
      final message =
          ref.read(loteDetailProvider(widget.loteId)).successMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message ?? 'Lote finalizado com sucesso!'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 3),
        ),
      );
      // Volta para a tela anterior (lote detail)
      context.pop();
    } else if (mounted) {
      final error =
          ref.read(loteDetailProvider(widget.loteId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error ?? 'Erro ao finalizar lote.'),
              ),
            ],
          ),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  void dispose() {
    _avesController.dispose();
    _pesoTotalController.dispose();
    _sobraRacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loteDetailProvider(widget.loteId));
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Aviso
          Card(
            color: AppColors.warningLight,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ao finalizar o lote, nao sera possivel adicionar novos registros.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          DatePickerField(
            label: 'Data da Finalizacao',
            value: _dataFinalizacao,
            required: true,
            maximumDate: DateTime.now(),
            onChange: (date) =>
                setState(() => _dataFinalizacao = date),
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Aves Entregues',
            placeholder: 'Quantidade de aves entregues ao abate',
            keyboardType: TextInputType.number,
            controller: _avesController,
            required: true,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Informe a quantidade de aves';
              }
              if (int.tryParse(v) == null || int.parse(v) <= 0) {
                return 'Quantidade invalida';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Peso Total Entregue',
            placeholder: 'Peso total em kg',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            suffix: 'kg',
            controller: _pesoTotalController,
            required: true,
            validator: (v) {
              if (v == null || v.isEmpty) {
                return 'Informe o peso total';
              }
              if (double.tryParse(v) == null || double.parse(v) <= 0) {
                return 'Peso invalido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Sobra de Racao',
            placeholder: 'Quantidade em kg (opcional)',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            suffix: 'kg',
            controller: _sobraRacaoController,
            validator: (v) {
              if (v != null && v.isNotEmpty) {
                if (double.tryParse(v) == null || double.parse(v) < 0) {
                  return 'Valor invalido';
                }
              }
              return null;
            },
          ),
          const SizedBox(height: 24),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed:
                  state.isFinalizando ? null : _showConfirmDialog,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              icon: state.isFinalizando
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.check_circle_outline),
              label: Text(
                state.isFinalizando ? 'Finalizando...' : 'Finalizar Lote',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
