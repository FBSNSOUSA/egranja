import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/theme/app_colors.dart';
import 'package:egranja_flutter/core/widgets/form_field_widget.dart';
import 'package:egranja_flutter/core/widgets/date_picker_field.dart';
import '../providers/visitantes_provider.dart';

/// Tela de registro de novo visitante.
class NovoVisitanteScreen extends ConsumerStatefulWidget {
  const NovoVisitanteScreen({super.key, required this.loteId});

  final String loteId;

  @override
  ConsumerState<NovoVisitanteScreen> createState() =>
      _NovoVisitanteScreenState();
}

class _NovoVisitanteScreenState extends ConsumerState<NovoVisitanteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeController = TextEditingController();
  final _empresaController = TextEditingController();
  final _motivoController = TextEditingController();
  final _horaEntradaController = TextEditingController();
  final _horaSaidaController = TextEditingController();
  final _observacaoController = TextEditingController();
  DateTime _dataVisita = DateTime.now();
  bool _usouEpi = false;

  Future<void> _pickTime({
    required TextEditingController controller,
    required String helpText,
  }) async {
    final now = TimeOfDay.now();
    final picked = await showTimePicker(
      context: context,
      initialTime: now,
      helpText: helpText,
    );
    if (picked != null) {
      final hora = picked.hour.toString().padLeft(2, '0');
      final minuto = picked.minute.toString().padLeft(2, '0');
      setState(() {
        controller.text = '$hora:$minuto';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dataFormatted =
        '${_dataVisita.year}-${_dataVisita.month.toString().padLeft(2, '0')}-${_dataVisita.day.toString().padLeft(2, '0')}';

    final success = await ref
        .read(visitantesProvider(widget.loteId).notifier)
        .criar(
          nome: _nomeController.text.trim(),
          dataVisita: dataFormatted,
          empresa: _empresaController.text.trim(),
          motivo: _motivoController.text.trim(),
          horaEntrada: _horaEntradaController.text.trim(),
          horaSaida: _horaSaidaController.text.trim(),
          usouEpi: _usouEpi,
          observacao: _observacaoController.text.trim(),
        );

    if (success && mounted) {
      final message =
          ref.read(visitantesProvider(widget.loteId)).successMessage;
      if (message != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
      context.pop();
    } else if (mounted) {
      final error =
          ref.read(visitantesProvider(widget.loteId)).errorMessage;
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
    _empresaController.dispose();
    _motivoController.dispose();
    _horaEntradaController.dispose();
    _horaSaidaController.dispose();
    _observacaoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(visitantesProvider(widget.loteId));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Visitante'),
      ),
      body: Form(
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
              label: 'Empresa',
              placeholder: 'Empresa ou origem (opcional)',
              controller: _empresaController,
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
              label: 'Data da visita',
              value: _dataVisita,
              required: true,
              maximumDate: DateTime.now(),
              onChange: (date) => setState(() => _dataVisita = date),
            ),
            const SizedBox(height: 16),

            // Hora de entrada
            GestureDetector(
              onTap: () => _pickTime(
                controller: _horaEntradaController,
                helpText: 'Hora de entrada',
              ),
              child: AbsorbPointer(
                child: FormFieldWidget(
                  label: 'Hora de entrada',
                  placeholder: 'HH:MM',
                  controller: _horaEntradaController,
                  leftIcon: Icons.login_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Hora de saida
            GestureDetector(
              onTap: () => _pickTime(
                controller: _horaSaidaController,
                helpText: 'Hora de saida',
              ),
              child: AbsorbPointer(
                child: FormFieldWidget(
                  label: 'Hora de saida',
                  placeholder: 'HH:MM',
                  controller: _horaSaidaController,
                  leftIcon: Icons.logout_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Switch EPI
            SwitchListTile(
              title: const Text('Utilizou EPI?'),
              subtitle: const Text(
                'Equipamento de Protecao Individual',
              ),
              value: _usouEpi,
              onChanged: (value) => setState(() => _usouEpi = value),
              activeTrackColor: AppColors.successLight,
              thumbColor: WidgetStatePropertyAll(AppColors.success),
              contentPadding: EdgeInsets.zero,
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
      ),
    );
  }
}
