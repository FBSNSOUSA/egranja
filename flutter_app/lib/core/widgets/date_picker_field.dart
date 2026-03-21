import 'package:flutter/material.dart';

/// Campo de formulario para selecao de data.
///
/// Exibe a data selecionada formatada como DD/MM/YYYY e abre o
/// `showDatePicker` nativo do Material 3 ao ser tocado.
///
/// Portado do componente React Native `DatePickerField.tsx`.
class DatePickerField extends StatelessWidget {
  const DatePickerField({
    super.key,
    required this.label,
    this.value,
    this.onChange,
    this.error,
    this.helperText,
    this.required = false,
    this.disabled = false,
    this.minimumDate,
    this.maximumDate,
  });

  /// Rotulo do campo.
  final String label;

  /// Data selecionada atualmente.
  final DateTime? value;

  /// Callback quando o usuario seleciona uma data.
  final ValueChanged<DateTime>? onChange;

  /// Mensagem de erro exibida abaixo do campo.
  final String? error;

  /// Texto auxiliar exibido abaixo do campo.
  final String? helperText;

  /// Se `true`, exibe asterisco no label.
  final bool required;

  /// Se `true`, desabilita interacao.
  final bool disabled;

  /// Data minima selecionavel.
  final DateTime? minimumDate;

  /// Data maxima selecionavel.
  final DateTime? maximumDate;

  String _formatDate(DateTime date) {
    final dia = date.day.toString().padLeft(2, '0');
    final mes = date.month.toString().padLeft(2, '0');
    final ano = date.year;
    return '$dia/$mes/$ano';
  }

  Future<void> _openDatePicker(BuildContext context) async {
    if (disabled) return;

    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: value ?? now,
      firstDate: minimumDate ?? DateTime(2000),
      lastDate: maximumDate ?? DateTime(2100),
      locale: const Locale('pt', 'BR'),
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
    );

    if (picked != null) {
      onChange?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = required ? '$label *' : label;

    return Semantics(
      label: '$label, campo de data${value != null ? ', ${_formatDate(value!)}' : ''}',
      child: GestureDetector(
        onTap: disabled ? null : () => _openDatePicker(context),
        child: AbsorbPointer(
          child: TextFormField(
            controller: TextEditingController(
              text: value != null ? _formatDate(value!) : '',
            ),
            readOnly: true,
            enabled: !disabled,
            decoration: InputDecoration(
              labelText: displayLabel,
              hintText: 'DD/MM/AAAA',
              errorText: error,
              helperText: helperText,
              suffixIcon: const Icon(Icons.calendar_today_outlined),
            ),
          ),
        ),
      ),
    );
  }
}
