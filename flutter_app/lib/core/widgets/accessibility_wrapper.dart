import 'package:flutter/material.dart';

/// Widget wrapper que adiciona semanticas de acessibilidade ao conteudo.
///
/// Simplifica a adicao de [Semantics] e [MergeSemantics] em cards
/// e elementos interativos, garantindo que leitores de tela anunciem
/// corretamente o proposito do widget.
///
/// Exemplo de uso:
/// ```dart
/// AccessibleCard(
///   label: 'Peso medio do lote',
///   hint: 'Toque para ver detalhes',
///   button: true,
///   child: MyCardContent(),
/// )
/// ```
class AccessibleCard extends StatelessWidget {
  const AccessibleCard({
    super.key,
    required this.label,
    required this.child,
    this.hint,
    this.button = false,
    this.enabled = true,
  });

  /// Rotulo lido pelo leitor de tela.
  final String label;

  /// Widget filho a ser envolto com semanticas.
  final Widget child;

  /// Dica adicional para o leitor de tela (ex: "Toque para abrir").
  final String? hint;

  /// Se `true`, marca o widget como botao para leitores de tela.
  final bool button;

  /// Se `false`, marca o widget como desabilitado para leitores de tela.
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return MergeSemantics(
      child: Semantics(
        label: label,
        hint: hint,
        button: button,
        enabled: enabled,
        child: child,
      ),
    );
  }
}
