import 'package:flutter/material.dart';

/// Card para exibicao de indicadores zootecnicos.
///
/// Exibe label, valor (com animacao implicita), subtitulo opcional,
/// cor semantica e icone. Suporta modo compacto para uso em grids.
///
/// Portado do componente React Native `IndicadorCard.tsx`.
class IndicatorCard extends StatelessWidget {
  const IndicatorCard({
    super.key,
    required this.label,
    required this.valor,
    this.subtitulo,
    this.cor,
    this.icone,
    this.compacto = false,
  });

  /// Rotulo do indicador (ex: "IEP", "Mortalidade").
  final String label;

  /// Valor formatado do indicador (ex: "350", "2.3%").
  final String valor;

  /// Texto complementar exibido abaixo do valor.
  final String? subtitulo;

  /// Cor semantica do indicador. Quando nula, usa cor primaria do tema.
  final Color? cor;

  /// Icone exibido acima do label.
  final IconData? icone;

  /// Quando `true`, reduz tamanhos de fonte e espaçamento.
  final bool compacto;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = cor ?? theme.colorScheme.primary;

    return Semantics(
      label: '$label: $valor${subtitulo != null ? ', $subtitulo' : ''}',
      child: Card(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compacto ? 8 : 16,
            vertical: compacto ? 8 : 12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icone
              if (icone != null) ...[
                Icon(
                  icone,
                  size: compacto ? 20 : 28,
                  color: indicatorColor,
                ),
                SizedBox(height: compacto ? 4 : 8),
              ],

              // Label
              Text(
                label,
                style: (compacto
                        ? theme.textTheme.labelSmall
                        : theme.textTheme.labelMedium)
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: compacto ? 2 : 4),

              // Valor com animacao implicita
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: (compacto
                        ? theme.textTheme.titleMedium
                        : theme.textTheme.headlineSmall)!
                    .copyWith(
                  color: indicatorColor,
                  fontWeight: FontWeight.w700,
                ),
                child: Text(
                  valor,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Subtitulo
              if (subtitulo != null) ...[
                SizedBox(height: compacto ? 2 : 4),
                Text(
                  subtitulo!,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
