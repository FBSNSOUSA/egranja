import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Widget de exibicao de erro com opcao de retry.
///
/// Apresenta um layout centralizado com icone de erro, mensagem
/// descritiva e botao opcional para tentar novamente.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    this.icon = Icons.error_outline,
    required this.message,
    this.onRetry,
    this.retryLabel = 'Tentar novamente',
  });

  /// Icone de erro. Padrao: `Icons.error_outline`.
  final IconData icon;

  /// Mensagem de erro descritiva.
  final String message;

  /// Callback ao pressionar o botao de retry.
  /// Quando nulo, o botao nao e exibido.
  final VoidCallback? onRetry;

  /// Texto do botao de retry.
  final String retryLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Friendly circular background - less alarming than raw red icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Algo deu errado',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 32),
              FilledButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: Text(retryLabel),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
