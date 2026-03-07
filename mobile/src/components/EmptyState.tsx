/**
 * Componente de estado vazio (Empty State) do eGranja.
 *
 * Exibido quando uma lista nao tem itens. Mostra:
 * - Icone ilustrativo
 * - Titulo descritivo
 * - Descricao ou instrucao
 * - Botao de acao opcional
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
} from 'react-native';
import { Button, IconButton } from 'react-native-paper';
import {
  colors,
  typography,
  spacing,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface EmptyStateProps {
  /** Icone (MaterialCommunityIcons) */
  icon: string;
  /** Titulo principal */
  titulo: string;
  /** Descricao ou instrucao */
  descricao?: string;
  /** Label do botao de acao */
  actionLabel?: string;
  /** Callback do botao de acao */
  onAction?: () => void;
  /** Icone do botao de acao */
  actionIcon?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

export const EmptyState: React.FC<EmptyStateProps> = ({
  icon,
  titulo,
  descricao,
  actionLabel,
  onAction,
  actionIcon,
}) => {
  return (
    <View style={styles.container}>
      <IconButton
        icon={icon}
        iconColor={colors.gray400}
        size={64}
        style={styles.icon}
      />

      <Text style={styles.titulo}>{titulo}</Text>

      {descricao && (
        <Text style={styles.descricao}>{descricao}</Text>
      )}

      {actionLabel && onAction && (
        <Button
          mode="contained"
          onPress={onAction}
          icon={actionIcon}
          style={styles.actionButton}
          contentStyle={styles.actionButtonContent}
          labelStyle={styles.actionButtonLabel}
          buttonColor={colors.primary}
          textColor={colors.textOnPrimary}
        >
          {actionLabel}
        </Button>
      )}
    </View>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingHorizontal: spacing.xxxl,
    paddingVertical: spacing.huge,
  },
  icon: {
    marginBottom: spacing.lg,
  },
  titulo: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    textAlign: 'center',
    marginBottom: spacing.sm,
  },
  descricao: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    textAlign: 'center',
    lineHeight: typography.fontSizeS * 1.5,
    marginBottom: spacing.xl,
  },
  actionButton: {
    borderRadius: components.button.borderRadius,
    marginTop: spacing.md,
  },
  actionButtonContent: {
    minHeight: components.button.minHeight,
    paddingHorizontal: spacing.xl,
  },
  actionButtonLabel: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },
});

export default EmptyState;
