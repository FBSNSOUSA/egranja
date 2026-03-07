/**
 * Indicador de status online/offline do eGranja.
 *
 * Banner persistente exibido no topo do app quando:
 * - O dispositivo esta offline (sem conexao de rede)
 * - Ha operacoes pendentes de sincronizacao
 * - Esta sincronizando dados
 *
 * Feedback claro e nao-bloqueante para o usuario saber que
 * esta operando em modo offline e que seus dados serao
 * sincronizados quando a conexao for restaurada.
 */

import React from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import { IconButton } from 'react-native-paper';
import { useSyncStore } from '@stores/syncStore';
import { colors, typography, spacing } from '@theme/index';

// ==========================================
// COMPONENTE
// ==========================================

export const OfflineIndicator: React.FC = () => {
  const isOnline = useSyncStore((state) => state.isOnline);
  const pendingCount = useSyncStore((state) => state.pendingCount);
  const isSyncing = useSyncStore((state) => state.isSyncing);
  const syncAll = useSyncStore((state) => state.syncAll);

  // Nao exibir se esta online e sem pendencias
  if (isOnline && pendingCount === 0 && !isSyncing) {
    return null;
  }

  // Determinar estado visual
  const isOffline = !isOnline;
  const hasPending = pendingCount > 0;

  // Determinar cor e icone do banner
  let backgroundColor = colors.online;
  let icon = 'cloud-check';
  let message = '';

  if (isSyncing) {
    backgroundColor = colors.syncing;
    icon = 'cloud-sync';
    message = `Sincronizando ${pendingCount} operacao(oes)...`;
  } else if (isOffline) {
    backgroundColor = colors.offline;
    icon = 'cloud-off-outline';
    message = hasPending
      ? `Offline - ${pendingCount} operacao(oes) pendente(s)`
      : 'Voce esta offline';
  } else if (hasPending) {
    // Online mas com pendencias (aguardando sync)
    backgroundColor = colors.syncing;
    icon = 'cloud-upload';
    message = `${pendingCount} operacao(oes) aguardando sincronizacao`;
  }

  return (
    <TouchableOpacity
      activeOpacity={0.8}
      onPress={isOnline && hasPending ? syncAll : undefined}
      disabled={!isOnline || !hasPending}
      style={[styles.container, { backgroundColor }]}
      accessibilityRole="alert"
      accessibilityLabel={message}
    >
      <View style={styles.content}>
        <IconButton
          icon={icon}
          iconColor={colors.white}
          size={18}
          style={styles.icon}
        />
        <Text style={styles.message} numberOfLines={1}>
          {message}
        </Text>
        {isOnline && hasPending && !isSyncing && (
          <Text style={styles.tapHint}>
            Toque para sincronizar
          </Text>
        )}
      </View>
    </TouchableOpacity>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    width: '100%',
    paddingVertical: spacing.xs,
    paddingHorizontal: spacing.md,
    zIndex: 1000,
  },
  content: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
  },
  icon: {
    margin: 0,
    padding: 0,
    marginRight: spacing.xs,
  },
  message: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    color: colors.white,
    flexShrink: 1,
  },
  tapHint: {
    fontSize: typography.fontSizeXS,
    color: colors.white,
    opacity: 0.85,
    marginLeft: spacing.sm,
    fontStyle: 'italic',
  },
});

export default OfflineIndicator;
