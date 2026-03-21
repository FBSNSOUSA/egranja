import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import '../providers/financeiro_provider.dart';

/// Opcoes de tipo de custo para o dropdown.
const _tiposCusto = [
  DropdownOption(value: 'racao', label: 'Racao'),
  DropdownOption(value: 'medicamento', label: 'Medicamento'),
  DropdownOption(value: 'pinto', label: 'Pinto'),
  DropdownOption(value: 'mao_obra', label: 'Mao de obra'),
  DropdownOption(value: 'outros', label: 'Outros'),
];

/// Tela de formulario para registrar um novo custo.
///
/// Campos: tipo (dropdown), descricao, valor (R$), data,
/// nota fiscal (opcional), fornecedor (opcional).
class NovoCustoScreen extends ConsumerStatefulWidget {
  const NovoCustoScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovoCustoScreen> createState() => _NovoCustoScreenState();
}

class _NovoCustoScreenState extends ConsumerState<NovoCustoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _valorController = TextEditingController();
  final _notaFiscalController = TextEditingController();
  final _fornecedorController = TextEditingController();

  String? _tipo;
  DateTime _data = DateTime.now();
  String? _tipoError;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
    _notaFiscalController.dispose();
    _fornecedorController.dispose();
    super.dispose();
  }

  /// Converte string monetaria BR para numero.
  double _parseValor(String text) {
    final cleaned = text
        .replaceAll('R\$', '')
        .replaceAll(' ', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  bool _validate() {
    final formValid = _formKey.currentState!.validate();

    String? tipoErr;
    if (_tipo == null || _tipo!.isEmpty) {
      tipoErr = 'Selecione o tipo de custo.';
    }
    setState(() {
      _tipoError = tipoErr;
    });

    return formValid && tipoErr == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final dia = _data.day.toString().padLeft(2, '0');
    final mes = _data.month.toString().padLeft(2, '0');
    final ano = _data.year;
    final dataFormatted = '$ano-$mes-$dia';

    final payload = <String, dynamic>{
      'tipo': _tipo,
      'descricao': _descricaoController.text.trim(),
      'valor': _parseValor(_valorController.text),
      'data': dataFormatted,
    };

    final notaFiscal = _notaFiscalController.text.trim();
    if (notaFiscal.isNotEmpty) {
      payload['nota_fiscal'] = notaFiscal;
    }

    final fornecedor = _fornecedorController.text.trim();
    if (fornecedor.isNotEmpty) {
      payload['fornecedor'] = fornecedor;
    }

    final success = await ref
        .read(custosProvider(widget.loteId).notifier)
        .criar(data: payload);

    if (!mounted) return;

    if (success) {
      final message =
          ref.read(custosProvider(widget.loteId)).successMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      context.pop();
    } else {
      final error = ref.read(custosProvider(widget.loteId)).errorMessage;
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
  Widget build(BuildContext context) {
    final state = ref.watch(custosProvider(widget.loteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Custo'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Tipo
            DropdownField(
              label: 'Tipo de custo',
              value: _tipo,
              options: _tiposCusto,
              onSelect: (option) => setState(() {
                _tipo = option.value;
                _tipoError = null;
              }),
              placeholder: 'Selecione o tipo...',
              required: true,
              error: _tipoError,
            ),
            const SizedBox(height: 16),

            // Descricao
            FormFieldWidget(
              label: 'Descricao',
              placeholder: 'Descricao do custo',
              required: true,
              controller: _descricaoController,
              textInputAction: TextInputAction.next,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe a descricao.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Valor
            FormFieldWidget(
              label: 'Valor',
              placeholder: '0,00',
              required: true,
              controller: _valorController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              leftIcon: Icons.attach_money,
              helperText: 'Informe o valor em reais (R\$)',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Informe o valor.';
                }
                if (_parseValor(value) <= 0) {
                  return 'Informe um valor valido.';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Data
            DatePickerField(
              label: 'Data',
              value: _data,
              onChange: (date) => setState(() => _data = date),
              required: true,
              maximumDate: DateTime.now(),
            ),
            const SizedBox(height: 16),

            // Nota fiscal (opcional)
            FormFieldWidget(
              label: 'Nota fiscal',
              placeholder: 'Numero da nota fiscal',
              controller: _notaFiscalController,
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 16),

            // Fornecedor (opcional)
            FormFieldWidget(
              label: 'Fornecedor',
              placeholder: 'Nome do fornecedor',
              controller: _fornecedorController,
              textInputAction: TextInputAction.done,
            ),
            const SizedBox(height: 24),

            // Botao salvar
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
                    : const Text('Salvar custo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
