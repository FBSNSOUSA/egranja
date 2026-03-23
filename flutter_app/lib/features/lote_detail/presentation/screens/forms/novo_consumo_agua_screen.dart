import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import '../../providers/agua_provider.dart';
import '../../providers/lote_detail_provider.dart';

/// Tela de registro de novo consumo de agua.
class NovoConsumoAguaScreen extends ConsumerStatefulWidget {
  const NovoConsumoAguaScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovoConsumoAguaScreen> createState() =>
      _NovoConsumoAguaScreenState();
}

class _NovoConsumoAguaScreenState
    extends ConsumerState<NovoConsumoAguaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  DateTime _data = DateTime.now();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dataFormatted =
        '${_data.year}-${_data.month.toString().padLeft(2, '0')}-${_data.day.toString().padLeft(2, '0')}';

    final success = await ref
        .read(aguaProvider(widget.loteId).notifier)
        .criar(
          data: dataFormatted,
          quantidadeLitros: double.parse(_quantidadeController.text),
        );

    if (success && mounted) {
      ref
          .read(loteDetailProvider(widget.loteId).notifier)
          .invalidateCache();

      final message =
          ref.read(aguaProvider(widget.loteId)).successMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(message ?? 'Consumo de agua registrado com sucesso!'),
              ),
            ],
          ),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
      context.pop();
    } else if (mounted) {
      final error = ref.read(aguaProvider(widget.loteId)).errorMessage;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error_outline, color: AppColors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(error ?? 'Erro ao salvar consumo de agua.'),
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
    _quantidadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(aguaProvider(widget.loteId));

    return Form(
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
            placeholder: 'Quantidade em litros',
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            suffix: 'L',
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
            height: 52,
            child: FilledButton.icon(
              onPressed: state.isSaving ? null : _submit,
              icon: state.isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: Text(
                state.isSaving ? 'Salvando...' : 'Salvar Consumo',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
