/**
 * Tela Home do Produtor no eGranja.
 *
 * Funcionalidades:
 * - Cabecalho: nome do usuario + indicador online/offline + badge mensagens
 * - Lista de lotes ativos usando LoteCard
 * - Pull-to-refresh para sincronizar dados
 * - FAB "+" para cadastro de novo lote
 * - Empty state quando sem lotes
 * - Paginacao infinita (FlatList onEndReached)
 */

import React, { useEffect, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { Badge, IconButton } from 'react-native-paper';
import { useAuthStore } from '@stores/authStore';
import { useSyncStore } from '@stores/syncStore';
import { useLoteStore, Lote } from '@stores/loteStore';
import { LoteCard, LoteCardData } from '@components/LoteCard';
import { EmptyState } from '@components/EmptyState';
import { FABMenu } from '@components/FABMenu';
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

interface HomeScreenProps {
  navigation: {
    navigate: (screen: string, params?: any) => void;
  };
}

// ==========================================
// COMPONENTE
// ==========================================

export const HomeScreen: React.FC<HomeScreenProps> = ({ navigation }) => {
  const user = useAuthStore((state) => state.user);
  const isOnline = useSyncStore((state) => state.isOnline);
  const pendingCount = useSyncStore((state) => state.pendingCount);

  const {
    lotesAtivos,
    isLoading,
    isLoadingMore,
    pagination,
    fetchLotesAtivos,
    errorMessage,
  } = useLoteStore();

  // Carregar lotes ao montar
  useEffect(() => {
    fetchLotesAtivos(1);
  }, [fetchLotesAtivos]);

  // Pull-to-refresh
  const handleRefresh = useCallback(() => {
    fetchLotesAtivos(1);
  }, [fetchLotesAtivos]);

  // Paginacao infinita
  const handleEndReached = useCallback(() => {
    if (
      !isLoadingMore &&
      pagination &&
      pagination.page < pagination.total_pages
    ) {
      fetchLotesAtivos(pagination.page + 1);
    }
  }, [isLoadingMore, pagination, fetchLotesAtivos]);

  // Navegar para detalhes do lote
  const handleLotePress = useCallback(
    (loteId: string) => {
      const lote = lotesAtivos.find((l) => l.id === loteId);
      navigation.navigate('LoteDetail', {
        loteId,
        loteNome: lote?.galpaoNome || 'Detalhes do Lote',
      });
    },
    [navigation, lotesAtivos],
  );

  // Navegar para novo lote
  const handleNovoLote = useCallback(() => {
    navigation.navigate('NovoLote');
  }, [navigation]);

  // Converter Lote para LoteCardData
  const lotesCardData: LoteCardData[] = useMemo(() => {
    return lotesAtivos.map((lote) => ({
      id: lote.id,
      galpaoNome: lote.galpaoNome,
      dataAlojamento: lote.dataAlojamento,
      tipo: lote.tipo,
      linhagem: lote.linhagem,
      quantidadeOriginal: lote.quantidade,
      mortalidadeAcumulada: lote.mortalidadeAcumulada || 0,
      ultimoPesoMedio: lote.ultimoPesoMedio,
      pesoBenchmark: lote.pesoBenchmark,
      mortesRecentes: lote.mortesRecentes,
      dataMortesRecentes: lote.dataMortesRecentes,
      mortalidadeRecentePct: lote.mortalidadeRecentePct,
      temAlerta: lote.temAlerta,
      quantidadeAlertas: lote.quantidadeAlertas,
    }));
  }, [lotesAtivos]);

  // Renderizar item da lista
  const renderItem = useCallback(
    ({ item }: { item: LoteCardData }) => (
      <LoteCard lote={item} onPress={handleLotePress} />
    ),
    [handleLotePress],
  );

  // Footer com loading da paginacao
  const renderFooter = useCallback(() => {
    if (!isLoadingMore) return null;
    return (
      <View style={styles.footerLoading}>
        <ActivityIndicator size="small" color={colors.primary} />
      </View>
    );
  }, [isLoadingMore]);

  // Numero de mensagens nao lidas (placeholder)
  const mensagensNaoLidas = 0;

  return (
    <View style={styles.container}>
      {/* Cabecalho */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <Text style={styles.greeting}>
            Ola, {user?.nome?.split(' ')[0] || 'Produtor'}
          </Text>
          <View style={styles.statusRow}>
            <View
              style={[
                styles.statusDot,
                { backgroundColor: isOnline ? colors.online : colors.offline },
              ]}
            />
            <Text style={styles.statusText}>
              {isOnline ? 'Online' : 'Offline'}
            </Text>
            {pendingCount > 0 && (
              <Text style={styles.pendingText}>
                ({pendingCount} pendente{pendingCount > 1 ? 's' : ''})
              </Text>
            )}
          </View>
        </View>

        <View style={styles.headerRight}>
          <View>
            <IconButton
              icon="message-text-outline"
              iconColor={colors.textOnPrimary}
              size={24}
              onPress={() => navigation.navigate('Mensagens' as never)}
            />
            {mensagensNaoLidas > 0 && (
              <Badge style={styles.messageBadge} size={18}>
                {mensagensNaoLidas}
              </Badge>
            )}
          </View>
        </View>
      </View>

      {/* Titulo da secao */}
      <View style={styles.sectionHeader}>
        <Text style={styles.sectionTitle}>Lotes Ativos</Text>
        <Text style={styles.sectionCount}>
          {lotesAtivos.length} lote{lotesAtivos.length !== 1 ? 's' : ''}
        </Text>
      </View>

      {/* Lista de lotes */}
      <FlatList
        data={lotesCardData}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        refreshControl={
          <RefreshControl
            refreshing={isLoading && lotesAtivos.length > 0}
            onRefresh={handleRefresh}
            colors={[colors.primary]}
            tintColor={colors.primary}
          />
        }
        onEndReached={handleEndReached}
        onEndReachedThreshold={0.3}
        ListFooterComponent={renderFooter}
        ListEmptyComponent={
          isLoading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={colors.primary} />
              <Text style={styles.loadingText}>Carregando lotes...</Text>
            </View>
          ) : (
            <EmptyState
              icon="barn"
              titulo="Nenhum lote ativo"
              descricao="Comece cadastrando seu primeiro lote para acompanhar os indicadores do aviario."
              actionLabel="Novo Lote"
              actionIcon="plus"
              onAction={handleNovoLote}
            />
          )
        }
        contentContainerStyle={
          lotesCardData.length === 0 ? styles.emptyList : styles.list
        }
        showsVerticalScrollIndicator={false}
      />

      {/* FAB para novo lote */}
      {lotesAtivos.length > 0 && (
        <FABMenu
          actions={[
            {
              label: 'Novo Lote',
              icon: 'plus',
              onPress: handleNovoLote,
            },
          ]}
          testID="fab-novo-lote"
        />
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
    backgroundColor: colors.background,
  },

  // Cabecalho
  header: {
    backgroundColor: colors.primary,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    paddingTop: spacing.lg,
  },
  headerLeft: {
    flex: 1,
  },
  headerRight: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  greeting: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  statusRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.xs,
    gap: spacing.xs,
  },
  statusDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },
  statusText: {
    fontSize: typography.fontSizeXS,
    color: colors.textOnPrimary,
    opacity: 0.9,
  },
  pendingText: {
    fontSize: typography.fontSizeXS,
    color: colors.textOnPrimary,
    opacity: 0.7,
  },
  messageBadge: {
    position: 'absolute',
    top: 4,
    right: 4,
    backgroundColor: colors.warning,
  },

  // Secao
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
  },
  sectionTitle: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  sectionCount: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
  },

  // Lista
  list: {
    paddingBottom: spacing.huge + spacing.xxl,
  },
  emptyList: {
    flexGrow: 1,
  },

  // Loading
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: spacing.huge,
  },
  loadingText: {
    marginTop: spacing.md,
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  footerLoading: {
    paddingVertical: spacing.xl,
    alignItems: 'center',
  },
});

export default HomeScreen;
