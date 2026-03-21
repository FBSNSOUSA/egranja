/// Validadores de formulario reutilizaveis.
///
/// Cada funcao retorna `null` quando o valor e valido ou uma `String`
/// com a mensagem de erro para exibicao no `TextFormField.validator`.
class Validators {
  Validators._();

  /// Valida que o campo nao esta vazio.
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    return null;
  }

  /// Valida que o valor e um numero positivo (> 0).
  static String? positiveNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null) {
      return 'Valor invalido';
    }
    if (number <= 0) {
      return 'Deve ser maior que zero';
    }
    return null;
  }

  /// Retorna um validador que exige comprimento minimo.
  ///
  /// Uso:
  /// ```dart
  /// TextFormField(validator: Validators.minLength(6));
  /// ```
  static String? Function(String?) minLength(int min) {
    return (String? value) {
      if (value == null || value.trim().isEmpty) {
        return 'Campo obrigatorio';
      }
      if (value.trim().length < min) {
        return 'Minimo $min caracteres';
      }
      return null;
    };
  }

  /// Valida formato de e-mail simplificado.
  static String? email(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailRegex.hasMatch(value.trim())) {
      return 'E-mail invalido';
    }
    return null;
  }

  /// Valida que o valor e um numero (inteiro ou decimal).
  static String? numericValue(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obrigatorio';
    }
    final number = double.tryParse(value.replaceAll(',', '.'));
    if (number == null) {
      return 'Valor invalido';
    }
    return null;
  }
}
