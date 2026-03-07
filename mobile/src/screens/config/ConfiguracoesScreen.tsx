/**
 * Tela de Configuracoes do eGranja.
 *
 * Funcionalidades:
 * - Perfil: nome, email, telefone, tipo de conta
 * - Notificacoes: switches para cada tipo
 * - Dados: botao de sincronizacao, espaco offline
 * - Sobre: versao, suporte, termos
 */

import React, { useState, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  Alert,
  Linking,
} from 'react-native';
import { Appbar, Switch, Button, Divider, IconButton } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { useAuthStore } from '@stores/authStore';
import { useSyncStore } from '@stores/syncStore';
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

interface NotificacaoConfig {
  key: string;
  label: string;
  descricao: string;
  icone: string;
}

// ==========================================
// CONFIGURACOES DE NOTIFICACAO
// ==========================================

const NOTIFICACOES: NotificacaoConfig[] = [
  {
    key: 'mortalidade',
    label: 'Mortalidade',
    descricao: 'Alertas de mortalidade acima do esperado',
    icone: 'alert-circle',
  },
  {
    key: 'peso',
    label: 'Peso',
    descricao: 'Alertas de peso abaixo do benchmark',
    icone: 'scale',
  },
  {
    key: 'racao',
    label: 'Racao',
    descricao: 'Alertas de estoque baixo de racao',
    icone: 'food-drumstick',
  },
  {
    key: 'agua',
    label: 'Agua',
    descricao: 'Alertas de consumo de agua anormal',
    icone: 'water',
  },
  {
    key: 'clima',
    label: 'Clima',
    descricao: 'Alertas de condicoes climaticas extremas',
    icone: 'weather-partly-cloudy',
  },
  {
    key: 'iot',
    label: 'Sensores IoT',
    descricao: 'Alertas de sensores fora do range ideal',
    icone: 'chip',
  },
];

// ==========================================
// COMPONENTES AUXILIARES
// ==========================================

interface SecaoProps {
  titulo: string;
  icone: string;
  children: React.ReactNode;
}

const Secao: React.FC<SecaoProps> = ({ titulo, icone, children }) => (
  <View style={styles.secao}>
    <View style={styles.secaoHeader}>
      <IconButton icon={icone} iconColor={colors.primary} size={22} style={styles.secaoIcone} />
      <Text style={styles.secaoTitulo}>{titulo}</Text>
    </View>
    <View style={styles.secaoConteudo}>
      {children}
    </View>
  </View>
);

interface PerfilRowProps {
  label: string;
  valor: string;
}

const PerfilRow: React.FC<PerfilRowProps> = ({ label, valor }) => (
  <View style={styles.perfilRow}>
    <Text style={styles.perfilLabel}>{label}</Text>
    <Text style={styles.perfilValor}>{valor}</Text>
  </View>
);

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================

const ConfiguracoesScreen: React.FC = () => {
  const navigation = useNavigation();
  const user = useAuthStore((state) => state.user);
  const pendingCount = useSyncStore((state) => state.pendingCount);

  const [notificacoes, setNotificacoes] = useState<Record<string, boolean>>({
    mortalidade: true,
    peso: true,
    racao: true,
    agua: true,
    clima: true,
    iot: true,
  });
  const [isSyncing, setIsSyncing] = useState(false);

  // Toggle notificacao
  const toggleNotificacao = useCallback((key: string) => {
    setNotificacoes((prev) => ({
      ...prev,
      [key]: !prev[key],
    }));
  }, []);

  // Forcar sincronizacao
  const forcarSincronizacao = useCallback(async () => {
    setIsSyncing(true);
    try {
      // Simula sincronizacao
      await new Promise((resolve) => setTimeout(resolve, 2000));
      Alert.alert('Sincronizacao', 'Dados sincronizados com sucesso!');
    } catch {
      Alert.alert('Erro', 'Nao foi possivel sincronizar os dados. Verifique sua conexao.');
    } finally {
      setIsSyncing(false);
    }
  }, []);

  // Tipo de conta formatado
  const tipoConta = user?.tipo === 'tecnico' ? 'Tecnico' : 'Produtor';

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
        <Appbar.Content
          title="Configuracoes"
          titleStyle={styles.headerTitle}
          color={colors.textOnPrimary}
        />
      </Appbar.Header>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
      >
        {/* Perfil */}
        <Secao titulo="Perfil" icone="account-circle">
          <View style={styles.perfilAvatar}>
            <View style={styles.avatarCircle}>
              <Text style={styles.avatarText}>
                {user?.nome?.charAt(0)?.toUpperCase() || 'U'}
              </Text>
            </View>
            <View style={styles.perfilNomeContainer}>
              <Text style={styles.perfilNome}>{user?.nome || 'Usuario'}</Text>
              <View style={styles.tipoBadge}>
                <Text style={styles.tipoTexto}>{tipoConta}</Text>
              </View>
            </View>
          </View>
          <Divider style={styles.divider} />
          <PerfilRow label="Email" valor={user?.email || 'Nao informado'} />
          <PerfilRow label="Telefone" valor={user?.telefone || 'Nao informado'} />
          <PerfilRow label="Tipo de conta" valor={tipoConta} />
        </Secao>

        {/* Notificacoes */}
        <Secao titulo="Notificacoes" icone="bell">
          {NOTIFICACOES.map((notif, index) => (
            <View key={notif.key}>
              {index > 0 && <Divider style={styles.dividerSm} />}
              <View style={styles.notifRow}>
                <IconButton
                  icon={notif.icone}
                  iconColor={notificacoes[notif.key] ? colors.primary : colors.gray400}
                  size={20}
                  style={styles.notifIcone}
                />
                <View style={styles.notifTextoContainer}>
                  <Text style={styles.notifLabel}>{notif.label}</Text>
                  <Text style={styles.notifDescricao}>{notif.descricao}</Text>
                </View>
                <Switch
                  value={notificacoes[notif.key]}
                  onValueChange={() => toggleNotificacao(notif.key)}
                  color={colors.primary}
                />
              </View>
            </View>
          ))}
        </Secao>

        {/* Dados */}
        <Secao titulo="Dados" icone="database">
          <View style={styles.dadosRow}>
            <View style={styles.dadosInfo}>
              <Text style={styles.dadosLabel}>Operacoes pendentes</Text>
              <Text style={[styles.dadosValor, pendingCount > 0 ? { color: colors.warning } : {}]}>
                {pendingCount} {pendingCount === 1 ? 'operacao' : 'operacoes'}
              </Text>
            </View>
          </View>
          <Divider style={styles.dividerSm} />
          <Button
            mode="outlined"
            onPress={forcarSincronizacao}
            loading={isSyncing}
            disabled={isSyncing}
            icon="sync"
            style={styles.botaoSync}
            contentStyle={styles.botaoSyncContent}
            labelStyle={styles.botaoSyncLabel}
            textColor={colors.secondary}
          >
            {isSyncing ? 'Sincronizando...' : 'Forcar sincronizacao'}
          </Button>
        </Secao>

        {/* Sobre */}
        <Secao titulo="Sobre" icone="information">
          <PerfilRow label="Versao do app" valor="1.0.0" />
          <Divider style={styles.dividerSm} />
          <Button
            mode="text"
            onPress={() => Linking.openURL('mailto:suporte@egranja.com.br')}
            icon="headset"
            style={styles.botaoLink}
            contentStyle={styles.botaoLinkContent}
            labelStyle={styles.botaoLinkLabel}
            textColor={colors.secondary}
          >
            Contatar suporte
          </Button>
          <Button
            mode="text"
            onPress={() => Linking.openURL('https://egranja.com.br/termos')}
            icon="file-document"
            style={styles.botaoLink}
            contentStyle={styles.botaoLinkContent}
            labelStyle={styles.botaoLinkLabel}
            textColor={colors.secondary}
          >
            Termos de uso
          </Button>
        </Secao>
      </ScrollView>
    </View>
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
  header: {
    backgroundColor: colors.primary,
  },
  headerTitle: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: spacing.lg,
    paddingBottom: spacing.huge,
  },

  // Secao
  secao: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    marginBottom: spacing.lg,
    overflow: 'hidden',
    ...shadows.small,
  },
  secaoHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: spacing.lg,
    paddingBottom: spacing.sm,
  },
  secaoIcone: {
    margin: 0,
    padding: 0,
    marginRight: spacing.sm,
  },
  secaoTitulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  secaoConteudo: {
    padding: spacing.lg,
    paddingTop: spacing.sm,
  },

  // Perfil
  perfilAvatar: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  avatarCircle: {
    width: 56,
    height: 56,
    borderRadius: 28,
    backgroundColor: colors.primary,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.lg,
  },
  avatarText: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  perfilNomeContainer: {
    flex: 1,
  },
  perfilNome: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  tipoBadge: {
    backgroundColor: colors.primaryLight + '20',
    paddingHorizontal: spacing.sm,
    paddingVertical: 2,
    borderRadius: borders.radiusRound,
    alignSelf: 'flex-start',
    marginTop: spacing.xs,
  },
  tipoTexto: {
    fontSize: 12,
    color: colors.primary,
    fontWeight: typography.fontWeightMedium,
  },
  perfilRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.sm,
  },
  perfilLabel: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  perfilValor: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },

  // Dividers
  divider: {
    marginVertical: spacing.md,
  },
  dividerSm: {
    marginVertical: spacing.sm,
  },

  // Notificacoes
  notifRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
  },
  notifIcone: {
    margin: 0,
    padding: 0,
    marginRight: spacing.sm,
  },
  notifTextoContainer: {
    flex: 1,
  },
  notifLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },
  notifDescricao: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 1,
  },

  // Dados
  dadosRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
  },
  dadosInfo: {
    flex: 1,
  },
  dadosLabel: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  dadosValor: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginTop: 2,
  },
  botaoSync: {
    borderRadius: components.button.borderRadius,
    borderColor: colors.secondary,
    marginTop: spacing.md,
  },
  botaoSyncContent: {
    minHeight: components.button.minHeight,
  },
  botaoSyncLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
  },

  // Links
  botaoLink: {
    marginTop: spacing.xs,
    alignSelf: 'flex-start',
  },
  botaoLinkContent: {
    minHeight: 40,
  },
  botaoLinkLabel: {
    fontSize: typography.fontSizeS,
  },
});

export default ConfiguracoesScreen;
