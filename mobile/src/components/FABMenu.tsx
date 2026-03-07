/**
 * FAB (Floating Action Button) com menu de opcoes para o eGranja.
 *
 * Quando ha apenas uma acao, funciona como FAB simples.
 * Quando ha multiplas acoes (ex: racao com recebimento/consumo),
 * exibe um menu com opcoes ao ser pressionado.
 *
 * Tamanho minimo 56dp para acessibilidade no campo.
 */

import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
  Animated,
  Modal,
} from 'react-native';
import { IconButton } from 'react-native-paper';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

export interface FABAction {
  /** Label da acao */
  label: string;
  /** Icone (MaterialCommunityIcons) */
  icon: string;
  /** Callback ao pressionar */
  onPress: () => void;
  /** Cor customizada */
  color?: string;
}

interface FABMenuProps {
  /** Acoes disponiveis. Se apenas uma, FAB simples. */
  actions: FABAction[];
  /** Icone principal do FAB */
  icon?: string;
  /** Cor de fundo do FAB */
  backgroundColor?: string;
  /** Cor do icone */
  iconColor?: string;
  /** testID */
  testID?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

export const FABMenu: React.FC<FABMenuProps> = ({
  actions,
  icon = 'plus',
  backgroundColor = colors.primary,
  iconColor = colors.white,
  testID,
}) => {
  const [menuVisible, setMenuVisible] = useState(false);

  const handlePress = useCallback(() => {
    if (actions.length === 1) {
      actions[0].onPress();
    } else {
      setMenuVisible(true);
    }
  }, [actions]);

  const handleActionPress = useCallback(
    (action: FABAction) => {
      setMenuVisible(false);
      // Pequeno delay para fechar o modal antes de navegar
      setTimeout(() => {
        action.onPress();
      }, 150);
    },
    [],
  );

  return (
    <>
      {/* FAB principal */}
      <TouchableOpacity
        style={[styles.fab, { backgroundColor }]}
        onPress={handlePress}
        activeOpacity={0.8}
        accessibilityRole="button"
        accessibilityLabel={
          actions.length === 1
            ? actions[0].label
            : 'Abrir menu de acoes'
        }
        testID={testID}
      >
        <IconButton
          icon={icon}
          iconColor={iconColor}
          size={components.fab.iconSize}
          style={styles.fabIcon}
        />
      </TouchableOpacity>

      {/* Menu de acoes (modal) */}
      {actions.length > 1 && (
        <Modal
          visible={menuVisible}
          transparent
          animationType="fade"
          onRequestClose={() => setMenuVisible(false)}
        >
          <TouchableOpacity
            style={styles.menuOverlay}
            activeOpacity={1}
            onPress={() => setMenuVisible(false)}
          >
            <View style={styles.menuContainer}>
              {actions.map((action, index) => (
                <TouchableOpacity
                  key={index}
                  style={styles.menuItem}
                  onPress={() => handleActionPress(action)}
                  activeOpacity={0.7}
                >
                  <View style={styles.menuItemContent}>
                    <Text style={styles.menuItemLabel}>{action.label}</Text>
                    <View
                      style={[
                        styles.menuItemIcon,
                        { backgroundColor: action.color || colors.primary },
                      ]}
                    >
                      <IconButton
                        icon={action.icon}
                        iconColor={colors.white}
                        size={20}
                        style={styles.menuItemIconButton}
                      />
                    </View>
                  </View>
                </TouchableOpacity>
              ))}
            </View>
          </TouchableOpacity>
        </Modal>
      )}
    </>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  fab: {
    position: 'absolute',
    bottom: spacing.xxl,
    right: spacing.xxl,
    width: components.fab.size,
    height: components.fab.size,
    borderRadius: components.fab.borderRadius,
    justifyContent: 'center',
    alignItems: 'center',
    ...shadows.large,
    zIndex: 100,
  },
  fabIcon: {
    margin: 0,
    padding: 0,
  },

  // Menu overlay
  menuOverlay: {
    flex: 1,
    backgroundColor: colors.overlay,
    justifyContent: 'flex-end',
    alignItems: 'flex-end',
    paddingBottom: spacing.xxl + components.fab.size + spacing.md,
    paddingRight: spacing.xxl,
  },
  menuContainer: {
    gap: spacing.sm,
  },
  menuItem: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    alignItems: 'center',
  },
  menuItemContent: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  menuItemLabel: {
    backgroundColor: colors.surface,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
    borderRadius: borders.radiusS,
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
    ...shadows.small,
  },
  menuItemIcon: {
    width: 44,
    height: 44,
    borderRadius: 22,
    justifyContent: 'center',
    alignItems: 'center',
    ...shadows.medium,
  },
  menuItemIconButton: {
    margin: 0,
    padding: 0,
  },
});

export default FABMenu;
