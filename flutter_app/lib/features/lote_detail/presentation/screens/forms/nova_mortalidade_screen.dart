import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import '../../providers/mortalidade_provider.dart';
import '../../providers/lote_detail_provider.dart';

/// Tela de registro de nova mortalidade.
class NovaMortalidadeScreen extends ConsumerStatefulWidget {
  const NovaMortalidadeScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovaMortalidadeScreen> createState() =>
      _NovaMortalidadeScreenState();
}

class _NovaMortalidadeScreenState
    extends ConsumerState<NovaMortalidadeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantidadeController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime _data = DateTime.now();
  String? _causa;

  static const _causas = [
    DropdownOption(value: 'Ascite', label: 'Ascite'),
    DropdownOption(value: 'Morte Subita', label: 'Morte Subita'),
    DropdownOption(value: 'Descarte', label: 'Descarte'),
    DropdownOption(value: 'Onfalite', label: 'Onfalite'),
    DropdownOption(value: 'Esmagamento', label: 'Esmagamento'),
    DropdownOption(value: 'Outras', label: 'Outras'),
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_causa == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione a causa da mortalidade.')),
      );
      return;
    }

    final dataFormatted =
        '${_data.year}-${_data.month.toString().padLeft(2, '0')}-${_data.day.toString().padLeft(2, '0')}';

    final success = await ref
        .read(mortalidadeProvider(widget.loteId).notifier)
        .criar(
          data: dataFormatted,
          quantidade: int.parse(_quantidadeController.text),
          causa: _causa!,
          observacao: _observacaoController.text.isNotEmpty
              ? _observacaoController.text
              : null,
        );

    if (success && mounted) {
      ref
          .read(loteDetailProvider(widget.loteId).notifier)
          .invalidateCache();

      final message =
          ref.read(mortalidadeProvider(widget.loteId)).successMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      context.pop();
    } else if (mounted) {
      final error =
          ref.read(mortalidadeProvider(widget.loteId)).errorMessage;
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
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mortalidadeProvider(widget.loteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Mortalidade'),
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
              placeholder: 'Numero de aves mortas',
              keyboardType: TextInputType.number,
              controller: _quantidadeController,
              required: true,
              validator: (v) {
                if (v == null || v.isEmpty) {
                  return 'Informe a quantidade';
                }
                if (int.tryParse(v) == null || int.parse(v) <= 0) {
                  return 'Quantidade invalida';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownField(
              label: 'Causa',
              value: _causa,
              options: _causas,
              required: true,
              placeholder: 'Selecione a causa',
              onSelect: (option) =>
                  setState(() => _causa = option.value),
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Observacao',
              placeholder: 'Observacoes adicionais (opcional)',
              controller: _observacaoController,
              multiline: true,
              numberOfLines: 3,
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
