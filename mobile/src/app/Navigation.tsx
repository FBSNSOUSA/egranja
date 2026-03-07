/**
 * Configuracao de navegacao do eGranja.
 *
 * Estrutura:
 * - Stack Navigator principal: Login -> Main
 * - Drawer Navigator (menu lateral): Home, Lotes Finalizados, Mensagens, Checklist, Sanidade, Financeiro, Relatorios, IA, IoT, Clima, MapaGalpoes, Configuracoes, Sair
 * - Bottom Tabs no detalhe do lote: Resumo, Pesagens, Mortalidade, Racao, Agua
 * - Stacks dedicados: Chat, Sanidade, Financeiro, Relatorios, IA, IoT
 * - Stacks de formularios: NovaPesagem, NovaMortalidade, NovoRecebimento, NovoConsumo, NovoConsumoAgua, FinalizarLote
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

// ==========================================
// IMPORTS DE TELAS
// ==========================================

// Auth
import LoginScreen from '@screens/auth/LoginScreen';

// Home
import HomeScreen from '@screens/home/HomeScreen';
import HomeTecnicoScreen from '@screens/home/HomeTecnicoScreen';

// Lote
import NovoLoteScreen from '@screens/lote/NovoLoteScreen';
import LoteResumoTab from '@screens/lote/LoteResumoTab';
import LotePesagensTab from '@screens/lote/LotePesagensTab';
import LoteMortalidadeTab from '@screens/lote/LoteMortalidadeTab';
import LoteRacaoTab from '@screens/lote/LoteRacaoTab';
import LoteAguaTab from '@screens/lote/LoteAguaTab';
import FinalizarLoteScreen from '@screens/lote/FinalizarLoteScreen';

// Formularios existentes
import NovaPesagemScreen from '@screens/pesagem/NovaPesagemScreen';
import NovaMortalidadeScreen from '@screens/mortalidade/NovaMortalidadeScreen';
import NovoRecebimentoScreen from '@screens/racao/NovoRecebimentoScreen';
import NovoConsumoScreen from '@screens/racao/NovoConsumoScreen';
import NovoConsumoAguaScreen from '@screens/agua/NovoConsumoAguaScreen';

// Chat
import ChatListScreen from '@screens/chat/ChatListScreen';
import ChatScreen from '@screens/chat/ChatScreen';

// Checklist
import ChecklistScreenImpl from '@screens/checklist/ChecklistScreen';

// Sanidade
import VacinacoesScreen from '@screens/sanidade/VacinacoesScreen';
import NovaVacinacaoScreen from '@screens/sanidade/NovaVacinacaoScreen';
import MedicamentosScreen from '@screens/sanidade/MedicamentosScreen';
import NovoMedicamentoScreen from '@screens/sanidade/NovoMedicamentoScreen';
import VisitantesScreen from '@screens/sanidade/VisitantesScreen';
import NovoVisitanteScreen from '@screens/sanidade/NovoVisitanteScreen';

// Financeiro
import FinanceiroResumoScreen from '@screens/financeiro/FinanceiroResumoScreen';
import CustosScreen from '@screens/financeiro/CustosScreen';
import NovoCustoScreen from '@screens/financeiro/NovoCustoScreen';
import RemuneracaoScreen from '@screens/financeiro/RemuneracaoScreen';

// Relatorios
import RelatoriosScreen from '@screens/relatorios/RelatoriosScreen';
import ComparativoLotesScreen from '@screens/relatorios/ComparativoLotesScreen';

// IA (Fase 4)
import IAAssistenteScreen from '@screens/ia/IAAssistenteScreen';
import IAAnaliseScreen from '@screens/ia/IAAnaliseScreen';

// IoT (Fase 4)
import IoTDashboardScreen from '@screens/iot/IoTDashboardScreen';
import IoTHistoricoScreen from '@screens/iot/IoTHistoricoScreen';

// Clima (Fase 4)
import ClimaScreen from '@screens/clima/ClimaScreen';

// Galpao/Mapa (Fase 4)
import MapaGalpoesScreen from '@screens/galpao/MapaGalpoesScreen';
import GalpaoDetalheScreen from '@screens/galpao/GalpaoDetalheScreen';

// Configuracoes (Fase 4)
import ConfiguracoesScreen from '@screens/config/ConfiguracoesScreen';

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
  Sanidade: undefined;
  Financeiro: undefined;
  Relatorios: undefined;
  IA: undefined;
  IoT: undefined;
  Clima: undefined;
  MapaGalpoes: undefined;
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
  NovaPesagem: { loteId: string };
  NovaMortalidade: { loteId: string };
  NovoRecebimentoRacao: { loteId: string };
  NovoConsumoRacao: { loteId: string };
  NovoConsumoAgua: { loteId: string };
  FinalizarLote: { loteId: string };
};

/** Parametros do stack de Chat */
export type ChatStackParamList = {
  ChatList: undefined;
  Chat: { loteId: string; loteNome: string };
};

/** Parametros do stack de Sanidade */
export type SanidadeStackParamList = {
  SanidadeMenu: undefined;
  Vacinacoes: { loteId: string; loteNome?: string };
  NovaVacinacao: { loteId: string };
  Medicamentos: { loteId: string; loteNome?: string };
  NovoMedicamento: { loteId: string };
  Visitantes: { loteId: string; loteNome?: string };
  NovoVisitante: { loteId: string };
};

/** Parametros do stack Financeiro */
export type FinanceiroStackParamList = {
  FinanceiroResumo: { loteId: string; loteNome?: string };
  Custos: { loteId: string; loteNome?: string };
  NovoCusto: { loteId: string };
  Remuneracao: { loteId: string; loteNome?: string };
};

/** Parametros do stack de Relatorios */
export type RelatoriosStackParamList = {
  RelatoriosList: undefined;
  ComparativoLotes: undefined;
};

/** Parametros do stack de IA */
export type IAStackParamList = {
  IAAssistente: undefined;
  IAAnalise: undefined;
};

/** Parametros do stack de IoT */
export type IoTStackParamList = {
  IoTDashboard: undefined;
  IoTHistorico: { galpaoId: string };
};

/** Parametros do stack de Galpao/Mapa */
export type GalpaoStackParamList = {
  MapaGalpoes: undefined;
  GalpaoDetalhe: { galpaoId: string };
};

// ==========================================
// TELAS PLACEHOLDER (para secoes ainda nao implementadas)
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

const LotesFinalizadosScreen: React.FC = () => <PlaceholderScreen title="Lotes Finalizados" />;

/**
 * Menu inicial de Sanidade — permite selecionar lote e modulo (Vacinacoes, Medicamentos, Visitantes).
 * Tela simples de hub para direcionar ao modulo correto.
 */
const SanidadeMenuScreen: React.FC = () => <PlaceholderScreen title="Sanidade e Rastreabilidade" />;

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
        component={LoteResumoTab}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Resumo' }}
      />
      <Tab.Screen
        name="Pesagens"
        component={LotePesagensTab}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Pesagens' }}
      />
      <Tab.Screen
        name="Mortalidade"
        component={LoteMortalidadeTab}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Mortalidade' }}
      />
      <Tab.Screen
        name="Racao"
        component={LoteRacaoTab}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Racao' }}
      />
      <Tab.Screen
        name="Agua"
        component={LoteAguaTab}
        initialParams={{ loteId }}
        options={{ tabBarLabel: 'Agua' }}
      />
    </Tab.Navigator>
  );
};

// ==========================================
// HOME STACK (lista de lotes + detalhe + formularios)
// ==========================================

const HomeStack = createNativeStackNavigator<HomeStackParamList>();

/**
 * Componente que escolhe entre HomeScreen (produtor) e HomeTecnicoScreen (tecnico)
 * baseado no tipo do usuario logado.
 */
const HomeListScreen: React.FC<any> = (props) => {
  const userType = useAuthStore((state) => state.user?.tipo);

  if (userType === 'tecnico') {
    return <HomeTecnicoScreen {...props} />;
  }
  return <HomeScreen {...props} />;
};

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
        options={{ title: 'eGranja', headerShown: false }}
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
      <HomeStack.Screen
        name="NovaPesagem"
        component={NovaPesagemScreen}
        options={{ title: 'Nova Pesagem' }}
      />
      <HomeStack.Screen
        name="NovaMortalidade"
        component={NovaMortalidadeScreen}
        options={{ title: 'Registrar Mortalidade' }}
      />
      <HomeStack.Screen
        name="NovoRecebimentoRacao"
        component={NovoRecebimentoScreen}
        options={{ title: 'Recebimento de Racao' }}
      />
      <HomeStack.Screen
        name="NovoConsumoRacao"
        component={NovoConsumoScreen}
        options={{ title: 'Consumo de Racao' }}
      />
      <HomeStack.Screen
        name="NovoConsumoAgua"
        component={NovoConsumoAguaScreen}
        options={{ title: 'Consumo de Agua' }}
      />
      <HomeStack.Screen
        name="FinalizarLote"
        component={FinalizarLoteScreen}
        options={{ title: 'Finalizar Lote' }}
      />
    </HomeStack.Navigator>
  );
};

// ==========================================
// CHAT STACK
// ==========================================

const ChatStackNav = createNativeStackNavigator<ChatStackParamList>();

const ChatStackNavigator: React.FC = () => {
  return (
    <ChatStackNav.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <ChatStackNav.Screen
        name="ChatList"
        component={ChatListScreen}
      />
      <ChatStackNav.Screen
        name="Chat"
        component={ChatScreen}
      />
    </ChatStackNav.Navigator>
  );
};

// ==========================================
// SANIDADE STACK
// ==========================================

const SanidadeStackNav = createNativeStackNavigator<SanidadeStackParamList>();

const SanidadeStackNavigator: React.FC = () => {
  return (
    <SanidadeStackNav.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <SanidadeStackNav.Screen
        name="SanidadeMenu"
        component={SanidadeMenuScreen}
      />
      <SanidadeStackNav.Screen
        name="Vacinacoes"
        component={VacinacoesScreen}
      />
      <SanidadeStackNav.Screen
        name="NovaVacinacao"
        component={NovaVacinacaoScreen}
      />
      <SanidadeStackNav.Screen
        name="Medicamentos"
        component={MedicamentosScreen}
      />
      <SanidadeStackNav.Screen
        name="NovoMedicamento"
        component={NovoMedicamentoScreen}
      />
      <SanidadeStackNav.Screen
        name="Visitantes"
        component={VisitantesScreen}
      />
      <SanidadeStackNav.Screen
        name="NovoVisitante"
        component={NovoVisitanteScreen}
      />
    </SanidadeStackNav.Navigator>
  );
};

// ==========================================
// FINANCEIRO STACK
// ==========================================

const FinanceiroStackNav = createNativeStackNavigator<FinanceiroStackParamList>();

const FinanceiroStackNavigator: React.FC = () => {
  return (
    <FinanceiroStackNav.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <FinanceiroStackNav.Screen
        name="FinanceiroResumo"
        component={FinanceiroResumoScreen}
      />
      <FinanceiroStackNav.Screen
        name="Custos"
        component={CustosScreen}
      />
      <FinanceiroStackNav.Screen
        name="NovoCusto"
        component={NovoCustoScreen}
      />
      <FinanceiroStackNav.Screen
        name="Remuneracao"
        component={RemuneracaoScreen}
      />
    </FinanceiroStackNav.Navigator>
  );
};

// ==========================================
// RELATORIOS STACK
// ==========================================

const RelatoriosStackNav = createNativeStackNavigator<RelatoriosStackParamList>();

const RelatoriosStackNavigator: React.FC = () => {
  return (
    <RelatoriosStackNav.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <RelatoriosStackNav.Screen
        name="RelatoriosList"
        component={RelatoriosScreen}
      />
      <RelatoriosStackNav.Screen
        name="ComparativoLotes"
        component={ComparativoLotesScreen}
      />
    </RelatoriosStackNav.Navigator>
  );
};

// ==========================================
// IA STACK (Fase 4)
// ==========================================

const IAStackNav = createNativeStackNavigator<IAStackParamList>();

const IAStackNavigator: React.FC = () => {
  return (
    <IAStackNav.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <IAStackNav.Screen
        name="IAAssistente"
        component={IAAssistenteScreen}
      />
      <IAStackNav.Screen
        name="IAAnalise"
        component={IAAnaliseScreen}
      />
    </IAStackNav.Navigator>
  );
};

// ==========================================
// IoT STACK (Fase 4)
// ==========================================

const IoTStackNav = createNativeStackNavigator<IoTStackParamList>();

const IoTStackNavigator: React.FC = () => {
  return (
    <IoTStackNav.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <IoTStackNav.Screen
        name="IoTDashboard"
        component={IoTDashboardScreen}
      />
      <IoTStackNav.Screen
        name="IoTHistorico"
        component={IoTHistoricoScreen}
      />
    </IoTStackNav.Navigator>
  );
};

// ==========================================
// GALPAO/MAPA STACK (Fase 4)
// ==========================================

const GalpaoStackNav = createNativeStackNavigator<GalpaoStackParamList>();

const GalpaoStackNavigator: React.FC = () => {
  return (
    <GalpaoStackNav.Navigator
      screenOptions={{
        headerShown: false,
      }}
    >
      <GalpaoStackNav.Screen
        name="MapaGalpoes"
        component={MapaGalpoesScreen}
      />
      <GalpaoStackNav.Screen
        name="GalpaoDetalhe"
        component={GalpaoDetalheScreen}
      />
    </GalpaoStackNav.Navigator>
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
  Sanidade: 'shield-plus',
  Financeiro: 'cash-multiple',
  Relatorios: 'chart-box',
  IA: 'robot',
  IoT: 'chip',
  Clima: 'weather-partly-cloudy',
  MapaGalpoes: 'map-marker-multiple',
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
        component={ChatStackNavigator}
        options={{
          drawerLabel: 'Mensagens',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Mensagens} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Checklist"
        component={ChecklistScreenImpl}
        options={{
          drawerLabel: 'Checklist Diario',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Checklist} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Sanidade"
        component={SanidadeStackNavigator}
        options={{
          drawerLabel: 'Sanidade',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Sanidade} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Financeiro"
        component={FinanceiroStackNavigator}
        options={{
          drawerLabel: 'Financeiro',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Financeiro} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Relatorios"
        component={RelatoriosStackNavigator}
        options={{
          drawerLabel: 'Relatorios',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Relatorios} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="IA"
        component={IAStackNavigator}
        options={{
          drawerLabel: 'Assistente IA',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.IA} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="IoT"
        component={IoTStackNavigator}
        options={{
          drawerLabel: 'Sensores IoT',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.IoT} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="Clima"
        component={ClimaScreen}
        options={{
          drawerLabel: 'Previsao do Tempo',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.Clima} iconColor={color} size={size} />
          ),
        }}
      />
      <Drawer.Screen
        name="MapaGalpoes"
        component={GalpaoStackNavigator}
        options={{
          drawerLabel: 'Mapa de Galpoes',
          drawerIcon: ({ color, size }) => (
            <IconButton icon={DRAWER_ICONS.MapaGalpoes} iconColor={color} size={size} />
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
