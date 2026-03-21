import 'package:flutter/material.dart';

/// Campo de formulario padrao com suporte a multiplas configuracoes.
///
/// Wrapper sobre [TextFormField] com decoracao consistente, suporte
/// a sufixos textuais (unidades), icones e modo multiline.
///
/// Portado do componente React Native `FormField.tsx`.
class FormFieldWidget extends StatelessWidget {
  const FormFieldWidget({
    super.key,
    required this.label,
    this.value,
    this.onChanged,
    this.placeholder,
    this.error,
    this.helperText,
    this.keyboardType,
    this.required = false,
    this.disabled = false,
    this.multiline = false,
    this.numberOfLines = 1,
    this.leftIcon,
    this.rightIcon,
    this.onRightIconPress,
    this.suffix,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.focusNode,
    this.textInputAction,
    this.onFieldSubmitted,
  });

  /// Rotulo do campo.
  final String label;

  /// Valor inicial do campo (ignorado se [controller] for fornecido).
  final String? value;

  /// Callback ao alterar o texto.
  final ValueChanged<String>? onChanged;

  /// Texto placeholder.
  final String? placeholder;

  /// Mensagem de erro exibida abaixo do campo.
  final String? error;

  /// Texto auxiliar exibido abaixo do campo.
  final String? helperText;

  /// Tipo de teclado (numerico, email, etc).
  final TextInputType? keyboardType;

  /// Se `true`, exibe asterisco no label.
  final bool required;

  /// Se `true`, desabilita interacao.
  final bool disabled;

  /// Se `true`, permite multiplas linhas.
  final bool multiline;

  /// Numero de linhas visiveis (para multiline).
  final int numberOfLines;

  /// Icone exibido no lado esquerdo.
  final IconData? leftIcon;

  /// Icone exibido no lado direito.
  final IconData? rightIcon;

  /// Callback ao pressionar o icone direito.
  final VoidCallback? onRightIconPress;

  /// Texto de sufixo (ex: "g", "kg", "L").
  final String? suffix;

  /// Se `true`, oculta o texto (para senhas).
  final bool obscureText;

  /// Controller externo opcional.
  final TextEditingController? controller;

  /// Funcao de validacao.
  final String? Function(String?)? validator;

  /// FocusNode externo opcional.
  final FocusNode? focusNode;

  /// Acao do teclado (next, done, etc).
  final TextInputAction? textInputAction;

  /// Callback ao submeter o campo.
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    final displayLabel = required ? '$label *' : label;

    return Semantics(
      label: label,
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? value : null,
        onChanged: onChanged,
        enabled: !disabled,
        readOnly: disabled,
        obscureText: obscureText,
        keyboardType: multiline ? TextInputType.multiline : keyboardType,
        maxLines: multiline ? numberOfLines : 1,
        minLines: multiline ? numberOfLines : 1,
        focusNode: focusNode,
        textInputAction: textInputAction,
        onFieldSubmitted: onFieldSubmitted,
        validator: validator,
        decoration: InputDecoration(
          labelText: displayLabel,
          hintText: placeholder,
          errorText: error,
          helperText: helperText,
          prefixIcon: leftIcon != null ? Icon(leftIcon) : null,
          suffixIcon: rightIcon != null
              ? IconButton(
                  icon: Icon(rightIcon),
                  onPressed: onRightIconPress,
                )
              : null,
          suffixText: suffix,
        ),
      ),
    );
  }
}
