import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import '../providers/visitantes_provider.dart';

/// Tela de registro de novo visitante.
///
/// Visitantes are associated with a granja (not a lote).
/// Backend endpoint: POST /granjas/:id/visitantes
class NovoVisitanteScreen extends ConsumerStatefulWidget {
  const NovoVisitanteScreen({super.key, required this.granjaId});

  final String granjaId;

  @override
  ConsumerState<NovoVisitanteScreen> createState() =>
      _NovoVisitanteScreenState();
}

class _NovoVisitanteScreenState extends ConsumerState<NovoVisitanteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _documentoController = TextEditingController();
  final _origemController = TextEditingController();
  final _motivoController = TextEditingController();
  final _placaVeiculoController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime _dataEntrada = DateTime.now();

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Format as ISO datetime for the backend
    final dataFormatted =
        '${_dataEntrada.year}-${_dataEntrada.month.toString().padLeft(2, '0')}-${_dataEntrada.day.toString().padLeft(2, '0')}T${_dataEntrada.hour.toString().padLeft(2, '0')}:${_dataEntrada.minute.toString().padLeft(2, '0')}:00';

    final success = await ref
        .read(visitantesProvider(widget.granjaId).notifier)
        .criar(
          nome: _nomeController.text.trim(),
          dataEntrada: dataFormatted,
          documento: _documentoController.text.trim(),
          origem: _origemController.text.trim(),
          motivo: _motivoController.text.trim(),
          placaVeiculo: _placaVeiculoController.text.trim(),
          observacao: _observacaoController.text.trim(),
        );

    if (success && mounted) {
      final message =
          ref.read(visitantesProvider(widget.granjaId)).successMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      context.pop();
    } else if (mounted) {
      final error =
          ref.read(visitantesProvider(widget.granjaId)).errorMessage;
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
    _documentoController.dispose();
    _origemController.dispose();
    _motivoController.dispose();
    _placaVeiculoController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitantesProvider(widget.granjaId));

    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          FormFieldWidget(
            label: 'Nome',
            placeholder: 'Nome completo do visitante',
            controller: _nomeController,
            required: true,
            leftIcon: Icons.person_outlined,
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Informe o nome do visitante.';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Documento',
            placeholder: 'CPF ou documento (opcional)',
            controller: _documentoController,
            leftIcon: Icons.badge_outlined,
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Origem',
            placeholder: 'Empresa ou origem (opcional)',
            controller: _origemController,
            leftIcon: Icons.business_outlined,
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Motivo da visita',
            placeholder: 'Motivo da visita (opcional)',
            controller: _motivoController,
            leftIcon: Icons.description_outlined,
          ),
          const SizedBox(height: 16),

          DatePickerField(
            label: 'Data de entrada',
            value: _dataEntrada,
            required: true,
            maximumDate: DateTime.now(),
            onChange: (date) => setState(() => _dataEntrada = date),
          ),
          const SizedBox(height: 16),

          FormFieldWidget(
            label: 'Placa do veiculo',
            placeholder: 'Placa do veiculo (opcional)',
            controller: _placaVeiculoController,
            leftIcon: Icons.directions_car_outlined,
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
                  : const Text('Registrar visitante'),
            ),
          ),
        ],
      ),
    );
  }
}
