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
  final _vacinaOutraController = TextEditingController();
  final _loteProdutoController = TextEditingController();
  final _responsavelController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime _data = DateTime.now();
  String? _vacinaSelecionada;
  String? _viaAdministracao;

  /// Vacinas mais comuns na avicultura de corte brasileira.
  static const _vacinasComuns = [
    DropdownOption(value: 'Marek', label: 'Marek (HVT)'),
    DropdownOption(value: 'Gumboro', label: 'Gumboro (IBD)'),
    DropdownOption(value: 'Newcastle', label: 'Newcastle (ND)'),
    DropdownOption(value: 'Bronquite Infecciosa', label: 'Bronquite Infecciosa (IB)'),
    DropdownOption(value: 'Bouba Aviaria', label: 'Bouba Aviaria'),
    DropdownOption(value: 'Influenza Aviaria', label: 'Influenza Aviaria'),
    DropdownOption(value: 'Coccidiose', label: 'Coccidiose'),
    DropdownOption(value: 'Reovirus', label: 'Reovirus'),
    DropdownOption(value: 'Outra', label: 'Outra (especificar)'),
  ];

  /// Vias de administracao padrao para vacinas avicolas.
  static const _viasAdministracao = [
    DropdownOption(value: 'Agua de bebida', label: 'Agua de bebida'),
    DropdownOption(value: 'Spray ocular', label: 'Spray ocular (gota no olho)'),
    DropdownOption(value: 'Subcutanea', label: 'Subcutanea'),
    DropdownOption(value: 'Intramuscular', label: 'Intramuscular'),
    DropdownOption(value: 'Spray', label: 'Spray (nebulizacao)'),
    DropdownOption(value: 'Membrana alar', label: 'Membrana alar'),
    DropdownOption(value: 'In ovo', label: 'In ovo (incubatorio)'),
    DropdownOption(value: 'Outra', label: 'Outra'),
  ];

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_vacinaSelecionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione o tipo de vacina.')),
      );
      return;
    }

    // Se "Outra", usar o texto digitado; caso contrario, o valor do dropdown
    final nomeVacina = _vacinaSelecionada == 'Outra'
        ? _vacinaOutraController.text.trim()
        : _vacinaSelecionada!;

    if (nomeVacina.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Informe o nome da vacina.')),
      );
      return;
    }

    final dataFormatted =
        '${_data.year}-${_data.month.toString().padLeft(2, '0')}-${_data.day.toString().padLeft(2, '0')}';

    final success = await ref
        .read(vacinacoesProvider(widget.loteId).notifier)
        .criar(
          vacina: nomeVacina,
          data: dataFormatted,
          loteProduto: _loteProdutoController.text.trim(),
          viaAdministracao: _viaAdministracao,
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
    _vacinaOutraController.dispose();
    _loteProdutoController.dispose();
    _responsavelController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(vacinacoesProvider(widget.loteId));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          DatePickerField(
            label: 'Data de aplicacao',
            value: _data,
            required: true,
            maximumDate: DateTime.now(),
            onChange: (date) => setState(() => _data = date),
          ),
          const SizedBox(height: 16),

          DropdownField(
            label: 'Tipo de vacina',
            value: _vacinaSelecionada,
            options: _vacinasComuns,
            required: true,
            placeholder: 'Selecione a vacina...',
            onSelect: (option) =>
                setState(() => _vacinaSelecionada = option.value),
          ),
          if (_vacinaSelecionada == 'Outra') ...[
            const SizedBox(height: 16),
            FormFieldWidget(
              label: 'Nome da vacina',
              placeholder: 'Especifique o nome da vacina',
              controller: _vacinaOutraController,
              required: true,
              validator: (v) {
                if (_vacinaSelecionada == 'Outra' &&
                    (v == null || v.trim().isEmpty)) {
                  return 'Informe o nome da vacina.';
                }
                return null;
              },
            ),
          ],
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Lote do produto',
            placeholder: 'Numero do lote da vacina (opcional)',
            controller: _loteProdutoController,
          ),
          const SizedBox(height: 16),

          DropdownField(
            label: 'Via de administracao',
            value: _viaAdministracao,
            options: _viasAdministracao,
            placeholder: 'Selecione a via...',
            onSelect: (option) =>
                setState(() => _viaAdministracao = option.value),
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
    );
  }
}
