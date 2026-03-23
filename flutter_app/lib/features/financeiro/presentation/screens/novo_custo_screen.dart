import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import 'package:egranja_flutter/core/widgets/dropdown_field.dart';
import '../providers/financeiro_provider.dart';

/// Opcoes de categoria de custo para o dropdown.
/// Valores correspondem as categorias aceitas pelo backend:
/// mao_de_obra, energia, aquecimento, cama, manutencao, depreciacao, agua, outros
const _categoriasCusto = [
  DropdownOption(value: 'mao_de_obra', label: 'Mao de obra'),
  DropdownOption(value: 'energia', label: 'Energia'),
  DropdownOption(value: 'aquecimento', label: 'Aquecimento'),
  DropdownOption(value: 'cama', label: 'Cama'),
  DropdownOption(value: 'manutencao', label: 'Manutencao'),
  DropdownOption(value: 'depreciacao', label: 'Depreciacao'),
  DropdownOption(value: 'agua', label: 'Agua'),
  DropdownOption(value: 'outros', label: 'Outros'),
];

/// Tela de formulario para registrar um novo custo.
///
/// Campos: categoria (dropdown), descricao (opcional), valor (R$), data.
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

  String? _categoria;
  DateTime _data = DateTime.now();
  String? _categoriaError;

  @override
  void dispose() {
    _descricaoController.dispose();
    _valorController.dispose();
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

    String? catErr;
    if (_categoria == null || _categoria!.isEmpty) {
      catErr = 'Selecione a categoria de custo.';
    }
    setState(() {
      _categoriaError = catErr;
    });

    return formValid && catErr == null;
  }

  Future<void> _submit() async {
    if (!_validate()) return;

    final dia = _data.day.toString().padLeft(2, '0');
    final mes = _data.month.toString().padLeft(2, '0');
    final ano = _data.year;
    final dataFormatted = '$ano-$mes-$dia';

    final payload = <String, dynamic>{
      'categoria': _categoria,
      'valor': _parseValor(_valorController.text),
      'data': dataFormatted,
    };

    final descricao = _descricaoController.text.trim();
    if (descricao.isNotEmpty) {
      payload['descricao'] = descricao;
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

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Categoria
          DropdownField(
            label: 'Categoria de custo',
            value: _categoria,
            options: _categoriasCusto,
            onSelect: (option) => setState(() {
              _categoria = option.value;
              _categoriaError = null;
            }),
            placeholder: 'Selecione a categoria...',
            required: true,
            error: _categoriaError,
          ),
          const SizedBox(height: 16),

          // Descricao (opcional)
          FormFieldWidget(
            label: 'Descricao',
            placeholder: 'Descricao do custo (opcional)',
            controller: _descricaoController,
            textInputAction: TextInputAction.next,
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
      );
  }
}
