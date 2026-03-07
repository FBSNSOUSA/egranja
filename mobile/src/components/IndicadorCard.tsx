/**
 * Card de indicador zootecnico reutilizavel.
 *
 * Exibe um valor numerico com label, cor semantica e icone opcional.
 * Usado no dashboard de resumo do lote para GPD, ICA, IEP, etc.
 *
 * Cores semanticas:
 * - Verde: dentro do esperado
 * - Amarelo: atencao
 * - Vermelho: critico
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
} from 'react-native';
import { IconButton } from 'react-native-paper';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface IndicadorCardProps {
  /** Label descritivo do indicador */
  label: string;
  /** Valor principal formatado (string para permitir unidades) */
  valor: string;
  /** Subtitulo opcional (ex: "Bom", "+3,2%") */
  subtitulo?: string;
  /** Cor semantica do indicador */
  cor?: string;
  /** Nome do icone (MaterialCommunityIcons) */
  icone?: string;
  /** Cor de fundo customizada */
  backgroundColor?: string;
  /** Se o card ocupa meia largura (2 colunas) ou largura total */
  compacto?: boolean;
  /** Tamanho do texto do valor */
  tamanhoValor?: 'pequeno' | 'medio' | 'grande';
}

// ==========================================
// COMPONENTE
// ==========================================

export const IndicadorCard: React.FC<IndicadorCardProps> = ({
  label,
  valor,
  subtitulo,
  cor = colors.text,
  icone,
  backgroundColor,
  compacto = false,
  tamanhoValor = 'medio',
}) => {
  const valorFontSize = {
    pequeno: typography.fontSizeL,
    medio: typography.fontSizeXL,
    grande: typography.fontSizeHero,
  }[tamanhoValor];

  return (
    <View
      style={[
        styles.container,
        compacto && styles.containerCompacto,
        backgroundColor ? { backgroundColor } : undefined,
      ]}
      accessibilityLabel={`${label}: ${valor}${subtitulo ? `, ${subtitulo}` : ''}`}
    >
      {icone && (
        <IconButton
          icon={icone}
          iconColor={cor}
          size={22}
          style={styles.icone}
        />
      )}

      <Text style={styles.label} numberOfLines={1}>
        {label}
      </Text>

      <Text
        style={[
          styles.valor,
          { fontSize: valorFontSize, color: cor },
        ]}
        numberOfLines={1}
        adjustsFontSizeToFit
      >
        {valor}
      </Text>

      {subtitulo && (
        <Text
          style={[styles.subtitulo, { color: cor }]}
          numberOfLines={1}
        >
          {subtitulo}
        </Text>
      )}
    </View>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.md,
    alignItems: 'center',
    justifyContent: 'center',
    minHeight: 100,
    ...shadows.small,
  },
  containerCompacto: {
    minHeight: 80,
    padding: spacing.sm,
  },
  icone: {
    margin: 0,
    padding: 0,
    marginBottom: spacing.xs,
  },
  label: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    color: colors.textSecondary,
    textAlign: 'center',
    marginBottom: spacing.xs,
  },
  valor: {
    fontWeight: typography.fontWeightBold,
    textAlign: 'center',
    lineHeight: 32,
  },
  subtitulo: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    textAlign: 'center',
    marginTop: 2,
  },
});

export default IndicadorCard;
