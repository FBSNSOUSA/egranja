import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import '../../providers/racao_provider.dart';
import '../../providers/lote_detail_provider.dart';

/// Tela de registro de novo consumo de racao.
class NovoConsumoScreen extends ConsumerStatefulWidget {
  const NovoConsumoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovoConsumoScreen> createState() =>
      _NovoConsumoScreenState();
}

class _NovoConsumoScreenState extends ConsumerState<NovoConsumoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  DateTime _data = DateTime.now();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dataFormatted =
        '${_data.year}-${_data.month.toString().padLeft(2, '0')}-${_data.day.toString().padLeft(2, '0')}';

    final success = await ref
        .read(racaoProvider(widget.loteId).notifier)
        .criarConsumo(
          data: dataFormatted,
          quantidadeKg: double.parse(_quantidadeController.text),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(racaoProvider(widget.loteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Consumo de Racao'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DatePickerField(
              label: 'Data',
              value: _data,
              required: true,
              maximumDate: DateTime.now(),
              onChange: (date) => setState(() => _data = date),
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Quantidade',
              placeholder: 'Quantidade consumida em kg',
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
