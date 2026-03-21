import 'package:flutter/material.dart';

/// Widget para estado vazio de listas e telas.
///
/// Exibe um layout centralizado com icone grande, titulo,
/// descricao opcional e botao de acao opcional.
///
/// Portado do componente React Native `EmptyState.tsx`.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.titulo,
    this.descricao,
    this.actionLabel,
    this.onAction,
    this.actionIcon,
  });

  /// Icone principal exibido no topo.
  final IconData icon;

  /// Titulo do estado vazio.
  final String titulo;

  /// Descricao complementar.
  final String? descricao;

  /// Texto do botao de acao.
  final String? actionLabel;

  /// Callback do botao de acao.
  final VoidCallback? onAction;

  /// Icone opcional para o botao de acao.
  final IconData? actionIcon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant.withAlpha(120),
            ),
            const SizedBox(height: 16),
            Text(
              titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (descricao != null) ...[
              const SizedBox(height: 8),
              Text(
                descricao!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant.withAlpha(180),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: actionIcon != null ? Icon(actionIcon) : null,
                label: Text(actionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
