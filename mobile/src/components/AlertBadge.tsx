/**
 * Badge de alerta posicionado no canto do card.
 *
 * Exibe um indicador visual quando ha alertas ativos
 * (mortalidade alta, peso baixo, racao acabando, etc).
 *
 * Pode ser usado em qualquer card (lote, produtor, etc).
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
} from 'react-native';
import {
  colors,
  typography,
  spacing,
  borders,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface AlertBadgeProps {
  /** Quantidade de alertas (exibido dentro do badge) */
  count?: number;
  /** Tipo de alerta para cor */
  tipo?: 'critico' | 'alto' | 'medio';
  /** Posicao do badge */
  position?: 'topRight' | 'topLeft';
  /** Se verdadeiro, exibe apenas o ponto (sem texto) */
  dotOnly?: boolean;
}

// ==========================================
// COMPONENTE
// ==========================================

export const AlertBadge: React.FC<AlertBadgeProps> = ({
  count = 1,
  tipo = 'critico',
  position = 'topRight',
  dotOnly = false,
}) => {
  const badgeColor = {
    critico: colors.danger,
    alto: colors.warning,
    medio: colors.secondary,
  }[tipo];

  if (dotOnly) {
    return (
      <View
        style={[
          styles.dot,
          { backgroundColor: badgeColor },
          position === 'topRight' ? styles.positionTopRight : styles.positionTopLeft,
        ]}
        accessibilityLabel={`Alerta ${tipo}`}
      />
    );
  }

  return (
    <View
      style={[
        styles.badge,
        { backgroundColor: badgeColor },
        position === 'topRight' ? styles.positionTopRight : styles.positionTopLeft,
      ]}
      accessibilityLabel={`${count} alerta(s) ${tipo}(s)`}
    >
      <Text style={styles.badgeText}>
        {count > 99 ? '99+' : count}
      </Text>
    </View>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  badge: {
    position: 'absolute',
    minWidth: 24,
    height: 24,
    borderRadius: borders.radiusRound,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.xs,
    zIndex: 10,
  },
  dot: {
    position: 'absolute',
    width: 12,
    height: 12,
    borderRadius: 6,
    zIndex: 10,
  },
  positionTopRight: {
    top: -6,
    right: -6,
  },
  positionTopLeft: {
    top: -6,
    left: -6,
  },
  badgeText: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightBold,
    color: colors.white,
    textAlign: 'center',
  },
});

export default AlertBadge;
