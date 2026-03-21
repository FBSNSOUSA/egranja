import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import '../../providers/racao_provider.dart';
import '../../providers/lote_detail_provider.dart';

/// Tela de registro de novo recebimento de racao.
class NovoRecebimentoScreen extends ConsumerStatefulWidget {
  const NovoRecebimentoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovoRecebimentoScreen> createState() =>
      _NovoRecebimentoScreenState();
}

class _NovoRecebimentoScreenState
    extends ConsumerState<NovoRecebimentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _tipoRacaoController = TextEditingController();
  final _fornecedorController = TextEditingController();
  final _loteRacaoController = TextEditingController();
  DateTime _dataRecebimento = DateTime.now();
  String? _origem;

  static const _origens = [
    DropdownOption(value: 'compra', label: 'Compra'),
    DropdownOption(
        value: 'remanescente_anterior', label: 'Remanescente anterior'),
    DropdownOption(value: 'sobra_final', label: 'Sobra final'),
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_origem == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a origem.')),
      );
      return;
    }

    final dataFormatted =
        '${_dataRecebimento.year}-${_dataRecebimento.month.toString().padLeft(2, '0')}-${_dataRecebimento.day.toString().padLeft(2, '0')}';

    final success = await ref
        .read(racaoProvider(widget.loteId).notifier)
        .criarRecebimento(
          dataRecebimento: dataFormatted,
          quantidadeKg: double.parse(_quantidadeController.text),
          tipoRacao: _tipoRacaoController.text,
          fornecedor: _fornecedorController.text.isNotEmpty
              ? _fornecedorController.text
              : null,
          loteRacao: _loteRacaoController.text.isNotEmpty
              ? _loteRacaoController.text
              : null,
          origem: _origem!,
        );

    if (success && mounted) {
      ref
          .read(loteDetailProvider(widget.loteId).notifier)
          .invalidateCache();

      final message =
          ref.read(racaoProvider(widget.loteId)).successMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      context.pop();
    } else if (mounted) {
      final error = ref.read(racaoProvider(widget.loteId)).errorMessage;
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _quantidadeController.dispose();
    _tipoRacaoController.dispose();
    _fornecedorController.dispose();
    _loteRacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(racaoProvider(widget.loteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Recebimento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DatePickerField(
              label: 'Data do Recebimento',
              value: _dataRecebimento,
              required: true,
              maximumDate: DateTime.now(),
              onChange: (date) =>
                  setState(() => _dataRecebimento = date),
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Quantidade',
              placeholder: 'Quantidade em kg',
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: 'kg',
              controller: _quantidadeController,
              required: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Informe a quantidade';
                }
                if (double.tryParse(v) == null || double.parse(v) <= 0) {
                  return 'Quantidade invalida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Tipo de Racao',
              placeholder: 'Ex: Pre-inicial, Inicial, Crescimento',
              controller: _tipoRacaoController,
              required: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Informe o tipo de racao';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Fornecedor',
              placeholder: 'Nome do fornecedor (opcional)',
              controller: _fornecedorController,
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Lote da Racao',
              placeholder: 'Numero do lote (opcional)',
              controller: _loteRacaoController,
            ),
            const SizedBox(height: 16),

            DropdownField(
              label: 'Origem',
              value: _origem,
              options: _origens,
              required: true,
              placeholder: 'Selecione a origem',
              onSelect: (option) =>
                  setState(() => _origem = option.value),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: state.isSaving ? null : _submit,
                child: state.isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Text('Salvar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
