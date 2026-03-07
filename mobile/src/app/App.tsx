/**
 * Componente raiz do eGranja.
 *
 * Responsabilidades:
 * - PaperProvider com tema personalizado
 * - NavigationContainer (via Navigation.tsx)
 * - Verificacao inicial de autenticacao
 * - NetInfo listener para status online/offline
 * - Inicializacao do banco de dados local (WatermelonDB)
 * - StatusBar configurada
 */

import React, { useEffect, useCallback } from 'react';
import { StatusBar, StyleSheet, View, LogBox } from 'react-native';
import { Provider as PaperProvider } from 'react-native-paper';
import NetInfo, { NetInfoState } from '@react-native-community/netinfo';
import { Navigation } from './Navigation';
import { useAuthStore } from '@stores/authStore';
import { useSyncStore } from '@stores/syncStore';
import { paperTheme, colors } from '@theme/index';
import { OfflineIndicator } from '@components/OfflineIndicator';

// Ignorar warnings conhecidos em desenvolvimento
LogBox.ignoreLogs([
  'Non-serializable values were found in the navigation state',
]);

// ==========================================
// COMPONENTE RAIZ
// ==========================================

const App: React.FC = () => {
  const refreshUser = useAuthStore((state) => state.refreshUser);
  const setOnline = useSyncStore((state) => state.setOnline);
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);

  // Verificar autenticacao ao iniciar o app
  useEffect(() => {
    refreshUser();
  }, [refreshUser]);

  // Listener de conectividade (NetInfo)
  const handleConnectivityChange = useCallback(
    (state: NetInfoState) => {
      const isConnected = state.isConnected ?? false;
      const isInternetReachable = state.isInternetReachable ?? false;

      // Considerar online apenas se ha conexao E internet acessivel
      const online = isConnected && isInternetReachable;

      console.log(
        `[App] Conectividade: connected=${isConnected}, ` +
        `reachable=${isInternetReachable}, online=${online}, ` +
        `type=${state.type}`,
      );

      setOnline(online);
    },
    [setOnline],
  );

  useEffect(() => {
    // Obter estado inicial de conectividade
    NetInfo.fetch().then(handleConnectivityChange);

    // Subscrever a mudancas de conectividade
    const unsubscribe = NetInfo.addEventListener(handleConnectivityChange);

    return () => {
      unsubscribe();
    };
  }, [handleConnectivityChange]);

  return (
    <PaperProvider theme={paperTheme}>
      <View style={styles.container}>
        <StatusBar
          barStyle="light-content"
          backgroundColor={colors.primaryDark}
          translucent={false}
        />

        {/* Indicador de status offline (visivel quando sem conexao) */}
        {isAuthenticated && <OfflineIndicator />}

        {/* Arvore de navegacao */}
        <Navigation />
      </View>
    </PaperProvider>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: colors.background,
  },
});

export default App;
