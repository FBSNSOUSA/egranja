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
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Circular background behind icon for visual weight
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              titulo,
              style: theme.textTheme.titleMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (descricao != null) ...[
              const SizedBox(height: 8),
              Text(
                descricao!,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 32),
              SizedBox(
                height: 52,
                child: FilledButton.icon(
                  onPressed: onAction,
                  icon: actionIcon != null ? Icon(actionIcon) : null,
                  label: Text(
                    actionLabel!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
