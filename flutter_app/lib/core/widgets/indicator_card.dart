import 'package:flutter/material.dart';

/// Direcao de tendencia para exibicao de seta no [IndicatorCard].
enum TrendDirection {
  up,
  down,
  stable,
}

/// Card para exibicao de indicadores zootecnicos.
///
/// Exibe label, valor (com animacao implicita), subtitulo opcional,
/// cor semantica, icone e indicador de tendencia (seta up/down).
/// Suporta modo compacto para uso em grids.
/// Inclui barra de cor na borda superior para scanning rapido.
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
    this.trend,
    this.trendPositive = true,
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

  /// Quando `true`, reduz tamanhos de fonte e espacamento.
  final bool compacto;

  /// Direcao de tendencia opcional (up/down/stable).
  final TrendDirection? trend;

  /// Se `true`, tendencia "up" e positiva (verde). Se `false`, "up" e negativa
  /// (vermelho) - util para indicadores como mortalidade onde subir e ruim.
  final bool trendPositive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = cor ?? theme.colorScheme.primary;

    return Semantics(
      label: '$label: $valor${subtitulo != null ? ', $subtitulo' : ''}'
          '${trend != null ? ', tendencia ${trend == TrendDirection.up ? 'subindo' : trend == TrendDirection.down ? 'descendo' : 'estavel'}' : ''}',
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top color accent bar for quick visual scanning
            Container(
              height: 3,
              decoration: BoxDecoration(
                color: indicatorColor,
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: compacto ? 8 : 16,
                vertical: compacto ? 8 : 14,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icone
                  if (icone != null) ...[
                    Icon(
                      icone,
                      size: compacto ? 22 : 28,
                      color: indicatorColor.withValues(alpha: 0.8),
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

                  // Valor + trend arrow
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: AnimatedDefaultTextStyle(
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
                      ),
                      if (trend != null && trend != TrendDirection.stable) ...[
                        const SizedBox(width: 2),
                        _TrendArrow(
                          trend: trend!,
                          positive: trendPositive,
                          size: compacto ? 14 : 18,
                        ),
                      ],
                    ],
                  ),

                  // Subtitulo
                  if (subtitulo != null) ...[
                    SizedBox(height: compacto ? 1 : 4),
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
          ],
        ),
      ),
    );
  }
}

/// Seta de tendencia com cor semantica.
class _TrendArrow extends StatelessWidget {
  const _TrendArrow({
    required this.trend,
    required this.positive,
    this.size = 16,
  });

  final TrendDirection trend;
  final bool positive;
  final double size;

  @override
  Widget build(BuildContext context) {
    final isUp = trend == TrendDirection.up;
    // Se trendPositive=true, up=verde; se trendPositive=false, up=vermelho
    final color = isUp
        ? (positive ? const Color(0xFF388E3C) : const Color(0xFFC62828))
        : (positive ? const Color(0xFFC62828) : const Color(0xFF388E3C));

    return Icon(
      isUp ? Icons.trending_up : Icons.trending_down,
      color: color,
      size: size,
    );
  }
}
