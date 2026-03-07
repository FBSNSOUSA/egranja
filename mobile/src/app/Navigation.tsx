/**
 * Configuracao de navegacao do eGranja.
 *
 * Estrutura:
 * - Stack Navigator principal: Login -> Main
 * - Drawer Navigator (menu lateral): Home, Lotes Finalizados, Mensagens, Checklist, Configuracoes, Sair
 * - Bottom Tabs no detalhe do lote: Resumo, Pesagens, Mortalidade, Racao, Agua
 *
 * Fluxo: Login -> Drawer(Home) -> Lote -> Tabs(Resumo|Pesagens|Mortalidade|Racao|Agua)
 */

import React, { useCallback } from 'react';
import { StyleSheet, View, Text, Alert } from 'react-native';
import { NavigationContainer } from '@react-navigation/native';
import { createNativeStackNavigator } from '@react-navigation/native-stack';
import { createDrawerNavigator, DrawerContentScrollView, DrawerItemList, DrawerItem } from '@react-navigation/drawer';
import { createBottomTabNavigator } from '@react-navigation/bottom-tabs';
import { IconButton } from 'react-native-paper';
import { useAuthStore } from '@stores/authStore';
import { useSyncStore } from '@stores/syncStore';
import { colors, typography, spacing, borders } from '@theme/index';

// Telas
import LoginScreen from '@screens/auth/LoginScreen';

// ==========================================
// TIPOS DE NAVEGACAO
// ==========================================

/** Parametros do Stack principal */
export type RootStackParamList = {
  Login: undefined;
  Main: undefined;
};

/** Parametros do Drawer */
export type DrawerParamList = {
  Home: undefined;
  LotesFinalizados: undefined;
  Mensagens: undefined;
  Checklist: undefined;
  Configuracoes: undefined;
};

/** Parametros das tabs do detalhe do lote */
export type LoteTabParamList = {
  Resumo: { loteId: string };
  Pesagens: { loteId: string };
  Mortalidade: { loteId: string };
  Racao: { loteId: string };
  Agua: { loteId: string };
};

/** Parametros do stack interno do Home */
export type HomeStackParamList = {
  HomeList: undefined;
  LoteDetail: { loteId: string; loteNome?: string };
  NovoLote: undefined;
};

// ==========================================
// TELAS PLACEHOLDER (serao substituidas pelos componentes reais)
// ==========================================

const PlaceholderScreen: React.FC<{ title: string }> = ({ title }) => (
  <View style={placeholderStyles.container}>
    <Text style={placeholderStyles.text}>{title}</Text>
    <Text style={placeholderStyles.subtext}>Em desenvolvimento</Text>
  </View>
);

const placeholderStyles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.background,
  },
  text: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  subtext: {
    fontSize: typography.fontSizeM,
    color: colors.textSecondary,
    marginTop: spacing.sm,
  },
});

// Telas placeholder para cada secao
const HomeListScreen: React.FC = () => <PlaceholderScreen title="Home - Lotes Ativos" />;
const LotesFinalizadosScreen: React.FC = () => <PlaceholderScreen title="Lotes Finalizados" />;
const MensagensScreen: React.FC = () => <PlaceholderScreen title="Mensagens" />;
const ChecklistScreen: React.FC = () => <PlaceholderScreen title="Checklist Diario" />;
const ConfiguracoesScreen: React.FC = () => <PlaceholderScreen title="Configuracoes" />;
const NovoLoteScreen: React.FC = () => <PlaceholderScreen title="Novo Lote" />;

// Tabs do detalhe do lote
const ResumoScreen: React.FC = () => <PlaceholderScreen title="Resumo do Lote" />;
const PesagensScreen: React.FC = () => <PlaceholderScreen title="Pesagens" />;
const MortalidadeScreen: React.FC = () => <PlaceholderScreen title="Mortalidade" />;
const RacaoScreen: React.FC = () => <PlaceholderScreen title="Racao" />;
const AguaScreen: React.FC = () => <PlaceholderScreen title="Agua" />;

// ==========================================
// BOTTOM TABS - DETALHE DO LOTE
// ==========================================

const Tab = createBottomTabNavigator<LoteTabParamList>();

/** Icones das tabs do detalhe do lote */
const TAB_ICONS: Record<keyof LoteTabParamList, string> = {
  Resumo: 'view-dashboard',
  Pesagens: 'scale',
  Mortalidade: 'alert-circle',
  Racao: 'food-drumstick',
  Agua: 'water',
};

const LoteDetailTabs: React.FC<{ route: { params: { loteId: string } } }> = ({ route }) => {
  const { loteId } = route.params;

  return (
    <Tab.Navigator
      screenOptions={({ route: tabRoute }) => ({
        headerShown: false,
        tabBarIcon: ({ color, size }) => (
          <IconButton
            icon={TAB_ICONS[tabRoute.name as keyof LoteTabParamList] || 'circle'}
            iconColor={color}
            size={size}
          />
        ),
        tabBarActiveTintColor: colors.primary,
        tabBarInactiveTintColor: colors.gray500,
        tabBarStyle: styles.tabBar,
        tabBarLabelStyle: styles.tabBarLabel,
        tabBarItemStyle: styles.tabBarItem,
      })}
    >
      <Tab.Screen
        name="Resumo"
        component={ResumoScreen}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Resumo' }}
      />
      <Tab.Screen
        name="Pesagens"
        component={PesagensScreen}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Pesagens' }}
      />
      <Tab.Screen
        name="Mortalidade"
        component={MortalidadeScreen}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Mortalidade' }}
      />
      <Tab.Screen
        name="Racao"
        component={RacaoScreen}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Racao' }}
      />
      <Tab.Screen
        name="Agua"
        component={AguaScreen}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Agua' }}
      />
    </Tab.Navigator>
  );
};

// ==========================================
// HOME STACK (lista de lotes + detalhe)
// ==========================================

const HomeStack = createNativeStackNavigator<HomeStackParamList>();

const HomeStackNavigator: React.FC = () => {
  return (
    <HomeStack.Navigator
      screenOptions={{
        headerStyle: styles.header,
        headerTintColor: colors.textOnPrimary,
        headerTitleStyle: styles.headerTitle,
      }}
    >
      <HomeStack.Screen
        name="HomeList"
        component={HomeListScreen}
        options={{ title: 'eGranja' }}
      />
      <HomeStack.Screen
        name="LoteDetail"
        component={LoteDetailTabs}
        options={({ route }) => ({
          title: route.params.loteNome || 'Detalhes do Lote',
        })}
      />
      <HomeStack.Screen
        name="NovoLote"
        component={NovoLoteScreen}
        options={{ title: 'Novo Lote' }}
      />
    </HomeStack.Navigator>
  );
};

// ==========================================
// DRAWER NAVIGATOR (menu lateral)
// ==========================================

const Drawer = createDrawerNavigator<DrawerParamList>();

/** Icones do menu lateral */
const DRAWER_ICONS: Record<keyof DrawerParamList, string> = {
  Home: 'home',
  LotesFinalizados: 'archive',
  Mensagens: 'message-text',
  Checklist: 'checkbox-marked-outline',
  Configuracoes: 'cog',
};

/** Conteudo personalizado do drawer com botao de sair */
const CustomDrawerContent: React.FC<any> = (props) => {
  const logout = useAuthStore((state) => state.logout);
  const pendingCount = useSyncStore((state) => state.pendingCount);

  const handleLogout = useCallback(() => {
    if (pendingCount > 0) {
      Alert.alert(
        'Operacoes pendentes',
        `Voce tem ${pendingCount} operacao(oes) aguardando sincronizacao. ` +
        'Se sair agora, esses dados serao perdidos. Deseja continuar?',
        [
          { text: 'Cancelar', style: 'cancel' },
          {
            text: 'Sair mesmo assim',
            style: 'destructive',
            onPress: () => logout(),
          },
        ],
      );
    } else {
      Alert.alert(
        'Sair',
        'Deseja sair do eGranja?',
        [
          { text: 'Cancelar', style: 'cancel' },
          {
            text: 'Sair',
            style: 'destructive',
            onPress: () => logout(),
          },
        ],
      );
    }
  }, [logout, pendingCount]);

  return (
    <DrawerContentScrollView {...props}>
      {/* Header do drawer com dados do usuario */}
      <View style={styles.drawerHeader}>
        <View style={styles.drawerAvatar}>
          <Text style={styles.drawerAvatarText}>
            {useAuthStore.getState().user?.nome?.charAt(0)?.toUpperCase() || 'U'}
          </Text>
        </View>
        <Text style={styles.drawerUserName}>
          {useAuthStore.getState().user?.nome || 'Usuario'}
        </Text>
        <Text style={styles.drawerUserType}>
          {useAuthStore.getState().user?.tipo === 'tecnico' ? 'Tecnico' : 'Produtor'}
        </Text>
      </View>

      {/* Itens do menu */}
      <DrawerItemList {...props} />

      {/* Separador */}
      <View style={styles.drawerDivider} />

      {/* Botao Sair */}
      <DrawerItem
        label="Sair"
        icon={({ size }) => (
          <IconButton icon="logout" size={size} iconColor={colors.danger} />
        )}
        labelStyle={styles.drawerLogoutLabel}
        onPress={handleLogout}
      />
    </DrawerContentScrollView>
  );
};

const DrawerNavigator: React.FC = () => {
  return (
    <Drawer.Navigator
      drawerContent={(props) => <CustomDrawerContent {...props} />}
      screenOptions={{
        headerShown: false,
        drawerActiveTintColor: colors.primary,
        drawerInactiveTintColor: colors.text,
        drawerLabelStyle: styles.drawerLabel,
        drawerStyle: styles.drawer,
        drawerItemStyle: styles.drawerItem,
      }}
    >
      <Drawer.Screen
        name="Home"
        component={HomeStackNavigator}
        options={{
          drawerLabel: 'Home',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Home} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="LotesFinalizados"
        component={LotesFinalizadosScreen}
        options={{
          drawerLabel: 'Lotes Finalizados',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.LotesFinalizados} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Mensagens"
        component={MensagensScreen}
        options={{
          drawerLabel: 'Mensagens',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Mensagens} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Checklist"
        component={ChecklistScreen}
        options={{
          drawerLabel: 'Checklist Diario',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Checklist} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Configuracoes"
        component={ConfiguracoesScreen}
        options={{
          drawerLabel: 'Configuracoes',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Configuracoes} iconColor={color} size={size} />
          ),
        }}
      />
    </Drawer.Navigator>
  );
};

// ==========================================
// ROOT STACK (Login -> Main)
// ==========================================

const RootStack = createNativeStackNavigator<RootStackParamList>();

/**
 * Componente de navegacao raiz.
 * Gerencia o fluxo Login -> App principal.
 */
export const Navigation: React.FC = () => {
  const isAuthenticated = useAuthStore((state) => state.isAuthenticated);

  return (
    <NavigationContainer>
      <RootStack.Navigator screenOptions={{ headerShown: false }}>
        {isAuthenticated ? (
          <RootStack.Screen
            name="Main"
            component={DrawerNavigator}
          />
        ) : (
          <RootStack.Screen
            name="Login"
            component={LoginScreen}
            options={{
              animationTypeForReplace: 'pop', // Animacao de "voltar" ao deslogar
            }}
          />
        )}
      </RootStack.Navigator>
    </NavigationContainer>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  // Header
  header: {
    backgroundColor: colors.primary,
  },
  headerTitle: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },

  // Tab bar (detalhe do lote)
  tabBar: {
    backgroundColor: colors.surface,
    borderTopWidth: 1,
    borderTopColor: colors.divider,
    height: 60,
    paddingBottom: spacing.xs,
  },
  tabBarLabel: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
  },
  tabBarItem: {
    paddingTop: spacing.xs,
  },

  // Drawer
  drawer: {
    width: 280,
    backgroundColor: colors.surface,
  },
  drawerHeader: {
    padding: spacing.xxl,
    paddingTop: spacing.xxxl,
    backgroundColor: colors.primary,
    marginBottom: spacing.sm,
  },
  drawerAvatar: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: colors.primaryDark,
    justifyContent: 'center',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  drawerAvatarText: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  drawerUserName: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  drawerUserType: {
    fontSize: typography.fontSizeS,
    color: colors.textOnPrimary,
    opacity: 0.85,
    marginTop: spacing.xs,
  },
  drawerLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
  },
  drawerItem: {
    borderRadius: borders.radiusM,
    marginHorizontal: spacing.sm,
  },
  drawerDivider: {
    height: 1,
    backgroundColor: colors.divider,
    marginVertical: spacing.md,
    marginHorizontal: spacing.lg,
  },
  drawerLogoutLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.danger,
  },
});

export default Navigation;
