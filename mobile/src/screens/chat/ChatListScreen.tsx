/**
 * Lista de conversas por lote do eGranja.
 *
 * Cada item exibe:
 * - Nome do lote
 * - Ultima mensagem (preview)
 * - Timestamp da ultima mensagem
 * - Badge de mensagens nao lidas
 *
 * Filtro: Todas | Com pendencias
 * Pull-to-refresh para atualizar.
 */

import React, { useState, useCallback, useEffect, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { Appbar, Badge, SegmentedButtons, Divider, IconButton } from 'react-native-paper';
import { useNavigation, DrawerActions } from '@react-navigation/native';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
import 'dayjs/locale/pt-br';
import { apiGet } from '@services/api';
import { EmptyState } from '@components/EmptyState';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  components,
} from '@theme/index';

dayjs.extend(relativeTime);
dayjs.locale('pt-br');

// ==========================================
// TIPOS
// ==========================================

interface ConversaResumo {
  lote_id: string;
  lote_nome: string;
  ultima_mensagem: string;
  ultima_mensagem_tipo: 'text' | 'photo' | 'audio' | 'solicitacao' | 'system';
  ultima_mensagem_at: string;
  nao_lidas: number;
  tem_pendencia: boolean;
  participante_nome: string;
  participante_tipo: 'produtor' | 'tecnico';
}

type Filtro = 'todas' | 'pendencias';

// ==========================================
// COMPONENTE
// ==========================================

const ChatListScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const [conversas, setConversas] = useState<ConversaResumo[]>([]);
  const [filtro, setFiltro] = useState<Filtro>('todas');
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);

  const carregarConversas = useCallback(async () => {
    try {
      const response = await apiGet<ConversaResumo[]>('/chat/conversas');
      setConversas(response.data);
    } catch (error) {
      console.error('[ChatList] Erro ao carregar conversas:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => {
    carregarConversas();
  }, [carregarConversas]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarConversas();
    setRefreshing(false);
  }, [carregarConversas]);

  const conversasFiltradas = useMemo(() => {
    if (filtro === 'pendencias') {
      return conversas.filter((c) => c.tem_pendencia);
    }
    return conversas;
  }, [conversas, filtro]);

  const getMessagePreview = useCallback((conversa: ConversaResumo): string => {
    switch (conversa.ultima_mensagem_tipo) {
      case 'photo':
        return 'Foto enviada';
      case 'audio':
        return 'Audio enviado';
      case 'solicitacao':
        return 'Solicitacao formal';
      case 'system':
        return 'Alerta do sistema';
      default:
        return conversa.ultima_mensagem || '';
    }
  }, []);

  const getTimeLabel = useCallback((dateStr: string): string => {
    const date = dayjs(dateStr);
    const now = dayjs();

    if (now.diff(date, 'day') === 0) {
      return date.format('HH:mm');
    }
    if (now.diff(date, 'day') === 1) {
      return 'Ontem';
    }
    if (now.diff(date, 'day') < 7) {
      return date.format('ddd');
    }
    return date.format('DD/MM/YY');
  }, []);

  const handleConversaPress = useCallback(
    (conversa: ConversaResumo) => {
      navigation.navigate('Chat', {
        loteId: conversa.lote_id,
        loteNome: conversa.lote_nome,
      });
    },
    [navigation],
  );

  const renderConversa = useCallback(
    ({ item }: { item: ConversaResumo }) => (
      <TouchableOpacity
        style={styles.conversaItem}
        onPress={() => handleConversaPress(item)}
        activeOpacity={0.7}
      >
        {/* Avatar do lote */}
        <View style={styles.avatar}>
          <Text style={styles.avatarText}>
            {item.lote_nome.charAt(0).toUpperCase()}
          </Text>
          {item.tem_pendencia && <View style={styles.pendenciaDot} />}
        </View>

        {/* Conteudo */}
        <View style={styles.conversaContent}>
          <View style={styles.conversaHeader}>
            <Text
              style={[
                styles.loteNome,
                item.nao_lidas > 0 && styles.loteNomeBold,
              ]}
              numberOfLines={1}
            >
              {item.lote_nome}
            </Text>
            <Text
              style={[
                styles.timeLabel,
                item.nao_lidas > 0 && styles.timeLabelUnread,
              ]}
            >
              {getTimeLabel(item.ultima_mensagem_at)}
            </Text>
          </View>

          <View style={styles.conversaFooter}>
            <Text
              style={[
                styles.messagePreview,
                item.nao_lidas > 0 && styles.messagePreviewUnread,
              ]}
              numberOfLines={1}
            >
              {item.participante_nome}: {getMessagePreview(item)}
            </Text>
            {item.nao_lidas > 0 && (
              <Badge style={styles.badge} size={22}>
                {item.nao_lidas > 99 ? '99+' : item.nao_lidas}
              </Badge>
            )}
          </View>
        </View>
      </TouchableOpacity>
    ),
    [handleConversaPress, getMessagePreview, getTimeLabel],
  );

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.Action
          icon="menu"
          color={colors.textOnPrimary}
          onPress={() => navigation.dispatch(DrawerActions.openDrawer())}
        />
        <Appbar.Content
          title="Mensagens"
          titleStyle={styles.headerTitle}
        />
      </Appbar.Header>

      {/* Filtros */}
      <View style={styles.filtroContainer}>
        <SegmentedButtons
          value={filtro}
          onValueChange={(value) => setFiltro(value as Filtro)}
          buttons={[
            { value: 'todas', label: 'Todas' },
            { value: 'pendencias', label: 'Com pendencias' },
          ]}
          style={styles.segmented}
        />
      </View>

      {/* Lista de conversas */}
      <FlatList
        data={conversasFiltradas}
        keyExtractor={(item) => item.lote_id}
        renderItem={renderConversa}
        ItemSeparatorComponent={() => (
          <Divider style={styles.divider} />
        )}
        contentContainerStyle={
          conversasFiltradas.length === 0 ? styles.emptyList : undefined
        }
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[colors.primary]}
          />
        }
        ListEmptyComponent={
          !loading ? (
            <EmptyState
              icon="message-text-outline"
              titulo="Nenhuma conversa"
              descricao={
                filtro === 'pendencias'
                  ? 'Nenhuma conversa com pendencias no momento.'
                  : 'Suas conversas com o tecnico aparecerao aqui.'
              }
            />
          ) : null
        }
      />
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
  filtroContainer: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    backgroundColor: colors.surface,
  },
  segmented: {
    backgroundColor: colors.gray100,
  },
  conversaItem: {
    flexDirection: 'row',
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    backgroundColor: colors.surface,
    minHeight: 72,
    alignItems: 'center',
  },
  avatar: {
    width: 52,
    height: 52,
    borderRadius: 26,
    backgroundColor: colors.secondary,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  avatarText: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnSecondary,
  },
  pendenciaDot: {
    position: 'absolute',
    top: 0,
    right: 0,
    width: 14,
    height: 14,
    borderRadius: 7,
    backgroundColor: colors.warning,
    borderWidth: 2,
    borderColor: colors.surface,
  },
  conversaContent: {
    flex: 1,
  },
  conversaHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.xs,
  },
  loteNome: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightRegular,
    color: colors.text,
    flex: 1,
    marginRight: spacing.sm,
  },
  loteNomeBold: {
    fontWeight: typography.fontWeightBold,
  },
  timeLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },
  timeLabelUnread: {
    color: colors.primary,
    fontWeight: typography.fontWeightBold,
  },
  conversaFooter: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  messagePreview: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    flex: 1,
    marginRight: spacing.sm,
  },
  messagePreviewUnread: {
    color: colors.text,
    fontWeight: typography.fontWeightMedium,
  },
  badge: {
    backgroundColor: colors.primary,
    color: colors.textOnPrimary,
    fontWeight: typography.fontWeightBold,
  },
  divider: {
    marginLeft: 76, // avatar width + margin
  },
  emptyList: {
    flexGrow: 1,
  },
});

export default ChatListScreen;
