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
    final firstDate = minimumDate ?? DateTime(2000);
    final lastDate = maximumDate ?? DateTime(2100);

    // Garantir que initialDate esta dentro do range valido
    DateTime initialDate = value ?? now;
    if (initialDate.isBefore(firstDate)) {
      initialDate = firstDate;
    }
    if (initialDate.isAfter(lastDate)) {
      initialDate = lastDate;
    }

    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      // Nao usar locale explicitamente — o MaterialApp.router herda
      // o locale do sistema automaticamente. Usar locale: sem delegates
      // configurados causa tela cinza/crash.
      helpText: 'Selecione a data',
      cancelText: 'Cancelar',
      confirmText: 'Confirmar',
      builder: (BuildContext context, Widget? child) {
        // Aplicar tema do app ao date picker, garantindo que o dialog
        // aparece sobre a tela atual com as cores corretas.
        return Theme(
          data: Theme.of(context).copyWith(
            datePickerTheme: DatePickerThemeData(
              backgroundColor: Theme.of(context).colorScheme.surface,
              surfaceTintColor: Colors.transparent,
              headerBackgroundColor: Theme.of(context).colorScheme.primary,
              headerForegroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      onChange?.call(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = required ? '$label *' : label;
    final theme = Theme.of(context);

    return Semantics(
      label: '$label, campo de data${value != null ? ', ${_formatDate(value!)}' : ''}',
      child: InkWell(
        onTap: disabled ? null : () => _openDatePicker(context),
        borderRadius: BorderRadius.circular(12),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: displayLabel,
            hintText: 'DD/MM/AAAA',
            errorText: error,
            helperText: helperText,
            suffixIcon: Icon(
              Icons.calendar_today_outlined,
              color: disabled
                  ? theme.disabledColor
                  : theme.colorScheme.onSurfaceVariant,
            ),
            enabled: !disabled,
          ),
          child: Text(
            value != null ? _formatDate(value!) : '',
            style: value != null
                ? theme.textTheme.bodyMedium
                : theme.textTheme.bodyMedium?.copyWith(
                    color: theme.hintColor,
                  ),
          ),
        ),
      ),
    );
  }
}
