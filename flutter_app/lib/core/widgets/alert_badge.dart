import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Tipo de severidade do alerta.
enum AlertBadgeTipo {
  /// Alerta critico (vermelho).
  critico,

  /// Alerta de alta prioridade (laranja/warning).
  alto,

  /// Alerta de media prioridade (azul/secondary).
  medio,
}

/// Posicao do badge no widget pai.
enum AlertBadgePosition {
  /// Canto superior direito.
  topRight,

  /// Canto superior esquerdo.
  topLeft,
}

/// Badge de alerta para sobreposicao em cards e widgets.
///
/// Exibe um circulo colorido com contagem ou apenas um ponto
/// indicativo. Portado do componente React Native `AlertBadge.tsx`.
class AlertBadge extends StatelessWidget {
  const AlertBadge({
    super.key,
    required this.count,
    this.tipo = AlertBadgeTipo.critico,
    this.position = AlertBadgePosition.topRight,
    this.dotOnly = false,
  });

  /// Numero de alertas a exibir.
  final int count;

  /// Severidade do alerta, determina a cor.
  final AlertBadgeTipo tipo;

  /// Posicao do badge.
  final AlertBadgePosition position;

  /// Se `true`, exibe apenas um ponto sem numero.
  final bool dotOnly;

  /// Retorna a cor do badge baseada no tipo.
  Color get _badgeColor {
    switch (tipo) {
      case AlertBadgeTipo.critico:
        return AppColors.danger;
      case AlertBadgeTipo.alto:
        return AppColors.warning;
      case AlertBadgeTipo.medio:
        return AppColors.secondary;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (count <= 0 && !dotOnly) return const SizedBox.shrink();

    final size = dotOnly ? 10.0 : 20.0;
    final displayText = count > 99 ? '99+' : count.toString();

    return Positioned(
      top: -4,
      right: position == AlertBadgePosition.topRight ? -4 : null,
      left: position == AlertBadgePosition.topLeft ? -4 : null,
      child: Semantics(
        label: dotOnly
            ? 'Tem alerta'
            : '$count alerta${count != 1 ? 's' : ''}',
        child: Container(
          constraints: BoxConstraints(
            minWidth: size,
            minHeight: size,
          ),
          padding: dotOnly
              ? EdgeInsets.zero
              : const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: _badgeColor,
            shape: dotOnly ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: dotOnly ? null : BorderRadius.circular(10),
          ),
          alignment: Alignment.center,
          child: dotOnly
              ? null
              : Text(
                  displayText,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
        ),
      ),
    );
  }
}
