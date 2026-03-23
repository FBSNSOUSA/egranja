import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import '../providers/medicamentos_provider.dart';

/// Tela de registro de novo medicamento.
class NovoMedicamentoScreen extends ConsumerStatefulWidget {
  const NovoMedicamentoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovoMedicamentoScreen> createState() =>
      _NovoMedicamentoScreenState();
}

class _NovoMedicamentoScreenState
    extends ConsumerState<NovoMedicamentoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicamentoController = TextEditingController();
  final _dosagemController = TextEditingController();
  final _carenciaController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime _dataInicio = DateTime.now();
  DateTime _dataFim = DateTime.now();
  String? _via;

  static const _viasAdministracao = [
    DropdownOption(value: 'Oral', label: 'Oral (agua de bebida)'),
    DropdownOption(value: 'Racao', label: 'Via racao'),
    DropdownOption(value: 'Injetavel', label: 'Injetavel'),
    DropdownOption(value: 'Topica', label: 'Topica'),
    DropdownOption(value: 'Inalacao', label: 'Inalacao (nebulizacao)'),
    DropdownOption(value: 'Outra', label: 'Outra'),
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dataFim.isBefore(_dataInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data fim deve ser posterior a data inicio.'),
        ),
      );
      return;
    }

    String formatDate(DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final carencia = _carenciaController.text.isNotEmpty
        ? int.tryParse(_carenciaController.text)
        : null;

    final success = await ref
        .read(medicamentosProvider(widget.loteId).notifier)
        .criar(
          medicamento: _medicamentoController.text.trim(),
          dataInicio: formatDate(_dataInicio),
          dataFim: formatDate(_dataFim),
          dosagem: _dosagemController.text.trim(),
          via: _via,
          periodoCarenciaDias: carencia,
          responsavel: _responsavelController.text.trim(),
          observacao: _observacaoController.text.trim(),
        );

    if (success && mounted) {
      final message =
          ref.read(medicamentosProvider(widget.loteId)).successMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      context.pop();
    } else if (mounted) {
      final error =
          ref.read(medicamentosProvider(widget.loteId)).errorMessage;
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
    _medicamentoController.dispose();
    _dosagemController.dispose();
    _carenciaController.dispose();
    _responsavelController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(medicamentosProvider(widget.loteId));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DatePickerField(
            label: 'Data inicio',
            value: _dataInicio,
            required: true,
            maximumDate: DateTime.now(),
            onChange: (date) => setState(() => _dataInicio = date),
          ),
          const SizedBox(height: 16),

          DatePickerField(
            label: 'Data fim',
            value: _dataFim,
            required: true,
            minimumDate: _dataInicio,
            onChange: (date) => setState(() => _dataFim = date),
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Medicamento',
            placeholder: 'Nome do medicamento',
            controller: _medicamentoController,
            required: true,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Informe o nome do medicamento.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Dosagem',
            placeholder: 'Ex: 1ml/L de agua',
            controller: _dosagemController,
          ),
          const SizedBox(height: 16),

          DropdownField(
            label: 'Via de administracao',
            value: _via,
            options: _viasAdministracao,
            placeholder: 'Selecione a via...',
            onSelect: (option) =>
                setState(() => _via = option.value),
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Periodo de carencia',
            placeholder: 'Dias de carencia',
            controller: _carenciaController,
            keyboardType: TextInputType.number,
            suffix: 'dias',
            validator: (v) {
              if (v != null &&
                  v.isNotEmpty &&
                  int.tryParse(v) == null) {
                return 'Informe um numero valido.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Responsavel',
            placeholder: 'Nome do responsavel',
            controller: _responsavelController,
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
                  : const Text('Salvar medicamento'),
            ),
          ),
        ],
      ),
    );
  }
}
