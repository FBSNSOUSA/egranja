import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import '../providers/vacinacoes_provider.dart';

/// Tela de registro de nova vacinacao.
class NovaVacinacaoScreen extends ConsumerStatefulWidget {
  const NovaVacinacaoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovaVacinacaoScreen> createState() =>
      _NovaVacinacaoScreenState();
}

class _NovaVacinacaoScreenState extends ConsumerState<NovaVacinacaoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _fabricanteController = TextEditingController();
  final _loteController = TextEditingController();
  final _doseMlController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime _dataAplicacao = DateTime.now();
  String? _viaAplicacao;

  static const _viasAplicacao = [
    DropdownOption(value: 'Ocular', label: 'Ocular (gota no olho)'),
    DropdownOption(value: 'Subcutanea', label: 'Subcutanea'),
    DropdownOption(value: 'Agua', label: 'Via agua de bebida'),
    DropdownOption(value: 'Spray', label: 'Spray (nebulizacao)'),
    DropdownOption(value: 'Intramuscular', label: 'Intramuscular'),
    DropdownOption(value: 'Membrana alar', label: 'Membrana alar'),
    DropdownOption(value: 'Outra', label: 'Outra'),
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dataFormatted =
        '${_dataAplicacao.year}-${_dataAplicacao.month.toString().padLeft(2, '0')}-${_dataAplicacao.day.toString().padLeft(2, '0')}';

    final doseMl = _doseMlController.text.isNotEmpty
        ? double.tryParse(_doseMlController.text)
        : null;

    final success = await ref
        .read(vacinacoesProvider(widget.loteId).notifier)
        .criar(
          nome: _nomeController.text.trim(),
          dataAplicacao: dataFormatted,
          fabricante: _fabricanteController.text.trim(),
          lote: _loteController.text.trim(),
          doseMl: doseMl,
          viaAplicacao: _viaAplicacao,
          responsavel: _responsavelController.text.trim(),
          observacao: _observacaoController.text.trim(),
        );

    if (success && mounted) {
      final message =
          ref.read(vacinacoesProvider(widget.loteId)).successMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      context.pop();
    } else if (mounted) {
      final error =
          ref.read(vacinacoesProvider(widget.loteId)).errorMessage;
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
    _nomeController.dispose();
    _fabricanteController.dispose();
    _loteController.dispose();
    _doseMlController.dispose();
    _responsavelController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vacinacoesProvider(widget.loteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nova Vacinacao'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            DatePickerField(
              label: 'Data de aplicacao',
              value: _dataAplicacao,
              required: true,
              maximumDate: DateTime.now(),
              onChange: (date) => setState(() => _dataAplicacao = date),
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Tipo de vacina',
              placeholder: 'Ex: Newcastle, Gumboro, Bronquite...',
              controller: _nomeController,
              required: true,
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return 'Informe o tipo de vacina.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Fabricante',
              placeholder: 'Fabricante da vacina (opcional)',
              controller: _fabricanteController,
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Lote do produto',
              placeholder: 'Numero do lote da vacina (opcional)',
              controller: _loteController,
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Dose (mL)',
              placeholder: 'Ex: 0.5',
              controller: _doseMlController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              suffix: 'mL',
              validator: (v) {
                if (v != null && v.isNotEmpty && double.tryParse(v) == null) {
                  return 'Informe um valor numerico valido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            DropdownField(
              label: 'Via de aplicacao',
              value: _viaAplicacao,
              options: _viasAplicacao,
              placeholder: 'Selecione a via...',
              onSelect: (option) =>
                  setState(() => _viaAplicacao = option.value),
            ),
            const SizedBox(height: 16),

            FormFieldWidget(
              label: 'Responsavel',
              placeholder: 'Nome do responsavel pela vacinacao',
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
                    : const Text('Salvar vacinacao'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
