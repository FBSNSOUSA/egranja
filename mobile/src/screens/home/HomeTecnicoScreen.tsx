/**
 * Tela Home do Tecnico no eGranja.
 *
 * Funcionalidades:
 * - Visao consolidada de todos os produtores vinculados
 * - Lotes agrupados por produtor
 * - Filtros: por produtor, por alerta
 * - Acesso rapido a lotes com alertas
 * - Pull-to-refresh
 */

import React, { useEffect, useState, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SectionList,
  RefreshControl,
  ActivityIndicator,
  TouchableOpacity,
} from 'react-native';
import { Chip, IconButton, Badge, Searchbar } from 'react-native-paper';
import { useAuthStore } from '@stores/authStore';
import { useSyncStore } from '@stores/syncStore';
import { useLoteStore, Lote } from '@stores/loteStore';
import { LoteCard, LoteCardData } from '@components/LoteCard';
import { EmptyState } from '@components/EmptyState';
import { AlertBadge } from '@components/AlertBadge';
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

interface HomeTecnicoScreenProps {
  navigation: {
    navigate: (screen: string, params?: any) => void;
  };
}

interface ProdutorSection {
  title: string;
  produtorId: string;
  totalAlertas: number;
  data: LoteCardData[];
}

type FiltroAlerta = 'todos' | 'com_alerta' | 'sem_alerta';

// ==========================================
// COMPONENTE
// ==========================================

export const HomeTecnicoScreen: React.FC<HomeTecnicoScreenProps> = ({ navigation }) => {
  const user = useAuthStore((state) => state.user);
  const isOnline = useSyncStore((state) => state.isOnline);

  const {
    lotesAtivos,
    isLoading,
    fetchLotesAtivos,
  } = useLoteStore();

  const [filtroAlerta, setFiltroAlerta] = useState<FiltroAlerta>('todos');
  const [filtroProdutorQuery, setFiltroProdutorQuery] = useState('');
  const [showSearch, setShowSearch] = useState(false);

  // Carregar lotes ao montar
  useEffect(() => {
    fetchLotesAtivos(1);
  }, [fetchLotesAtivos]);

  // Pull-to-refresh
  const handleRefresh = useCallback(() => {
    fetchLotesAtivos(1);
  }, [fetchLotesAtivos]);

  // Agrupar lotes por produtor e aplicar filtros
  const sections: ProdutorSection[] = useMemo(() => {
    let filteredLotes = [...lotesAtivos];

    // Filtro por alerta
    if (filtroAlerta === 'com_alerta') {
      filteredLotes = filteredLotes.filter((l) => l.temAlerta);
    } else if (filtroAlerta === 'sem_alerta') {
      filteredLotes = filteredLotes.filter((l) => !l.temAlerta);
    }

    // Agrupar por galpao (na pratica seria por produtor - usando galpaoNome como proxy)
    const groups: Record<string, Lote[]> = {};
    filteredLotes.forEach((lote) => {
      const key = lote.galpaoNome.split(' ')[0] || 'Produtor';
      if (!groups[key]) {
        groups[key] = [];
      }
      groups[key].push(lote);
    });

    // Filtro por texto
    const query = filtroProdutorQuery.toLowerCase().trim();

    return Object.entries(groups)
      .filter(([title]) => !query || title.toLowerCase().includes(query))
      .map(([title, lotes]) => ({
        title,
        produtorId: title,
        totalAlertas: lotes.filter((l) => l.temAlerta).length,
        data: lotes.map((lote) => ({
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
        })),
      }))
      .sort((a, b) => b.totalAlertas - a.totalAlertas); // Produtores com alertas primeiro
  }, [lotesAtivos, filtroAlerta, filtroProdutorQuery]);

  // Estatisticas gerais
  const stats = useMemo(() => {
    const totalLotes = lotesAtivos.length;
    const lotesComAlerta = lotesAtivos.filter((l) => l.temAlerta).length;
    const totalAves = lotesAtivos.reduce(
      (acc, l) => acc + (l.quantidade - (l.mortalidadeAcumulada || 0)),
      0,
    );
    return { totalLotes, lotesComAlerta, totalAves };
  }, [lotesAtivos]);

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

  // Renderizar item
  const renderItem = useCallback(
    ({ item }: { item: LoteCardData }) => (
      <LoteCard lote={item} onPress={handleLotePress} />
    ),
    [handleLotePress],
  );

  // Renderizar cabecalho de secao (produtor)
  const renderSectionHeader = useCallback(
    ({ section }: { section: ProdutorSection }) => (
      <View style={styles.sectionHeader}>
        <View style={styles.sectionHeaderLeft}>
          <IconButton
            icon="account"
            iconColor={colors.textSecondary}
            size={20}
            style={styles.sectionIcon}
          />
          <Text style={styles.sectionTitle}>{section.title}</Text>
          <Text style={styles.sectionCount}>
            ({section.data.length} lote{section.data.length !== 1 ? 's' : ''})
          </Text>
        </View>
        {section.totalAlertas > 0 && (
          <View style={styles.sectionAlertBadge}>
            <Text style={styles.sectionAlertText}>
              {section.totalAlertas} alerta{section.totalAlertas !== 1 ? 's' : ''}
            </Text>
          </View>
        )}
      </View>
    ),
    [],
  );

  return (
    <View style={styles.container}>
      {/* Cabecalho */}
      <View style={styles.header}>
        <View style={styles.headerTop}>
          <View>
            <Text style={styles.greeting}>
              Ola, {user?.nome?.split(' ')[0] || 'Tecnico'}
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
            </View>
          </View>
          <IconButton
            icon={showSearch ? 'close' : 'magnify'}
            iconColor={colors.textOnPrimary}
            size={24}
            onPress={() => {
              setShowSearch(!showSearch);
              if (showSearch) setFiltroProdutorQuery('');
            }}
          />
        </View>

        {/* Resumo geral */}
        <View style={styles.statsRow}>
          <View style={styles.statItem}>
            <Text style={styles.statValue}>{stats.totalLotes}</Text>
            <Text style={styles.statLabel}>Lotes</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.statItem}>
            <Text
              style={[
                styles.statValue,
                stats.lotesComAlerta > 0 && { color: colors.warning },
              ]}
            >
              {stats.lotesComAlerta}
            </Text>
            <Text style={styles.statLabel}>Alertas</Text>
          </View>
          <View style={styles.statDivider} />
          <View style={styles.statItem}>
            <Text style={styles.statValue}>
              {stats.totalAves.toLocaleString('pt-BR')}
            </Text>
            <Text style={styles.statLabel}>Aves</Text>
          </View>
        </View>
      </View>

      {/* Barra de busca */}
      {showSearch && (
        <Searchbar
          placeholder="Buscar produtor..."
          onChangeText={setFiltroProdutorQuery}
          value={filtroProdutorQuery}
          style={styles.searchBar}
          inputStyle={styles.searchInput}
        />
      )}

      {/* Filtros */}
      <View style={styles.filtros}>
        <Chip
          selected={filtroAlerta === 'todos'}
          onPress={() => setFiltroAlerta('todos')}
          style={[styles.chip, filtroAlerta === 'todos' && styles.chipSelected]}
          textStyle={[styles.chipText, filtroAlerta === 'todos' && styles.chipTextSelected]}
        >
          Todos
        </Chip>
        <Chip
          selected={filtroAlerta === 'com_alerta'}
          onPress={() => setFiltroAlerta('com_alerta')}
          style={[styles.chip, filtroAlerta === 'com_alerta' && styles.chipSelected]}
          textStyle={[styles.chipText, filtroAlerta === 'com_alerta' && styles.chipTextSelected]}
          icon="alert-circle"
        >
          Com Alertas
        </Chip>
        <Chip
          selected={filtroAlerta === 'sem_alerta'}
          onPress={() => setFiltroAlerta('sem_alerta')}
          style={[styles.chip, filtroAlerta === 'sem_alerta' && styles.chipSelected]}
          textStyle={[styles.chipText, filtroAlerta === 'sem_alerta' && styles.chipTextSelected]}
          icon="check-circle"
        >
          Sem Alertas
        </Chip>
      </View>

      {/* Lista agrupada */}
      <SectionList
        sections={sections}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        renderSectionHeader={renderSectionHeader}
        refreshControl={
          <RefreshControl
            refreshing={isLoading && lotesAtivos.length > 0}
            onRefresh={handleRefresh}
            colors={[colors.primary]}
          />
        }
        ListEmptyComponent={
          isLoading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={colors.primary} />
              <Text style={styles.loadingText}>Carregando lotes...</Text>
            </View>
          ) : (
            <EmptyState
              icon="account-group"
              titulo="Nenhum lote encontrado"
              descricao={
                filtroAlerta !== 'todos'
                  ? 'Nenhum lote corresponde ao filtro selecionado.'
                  : 'Nenhum produtor vinculado ou sem lotes ativos.'
              }
            />
          )
        }
        contentContainerStyle={
          sections.length === 0 ? styles.emptyList : styles.list
        }
        stickySectionHeadersEnabled
        showsVerticalScrollIndicator={false}
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

  // Cabecalho
  header: {
    backgroundColor: colors.primary,
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.lg,
    paddingBottom: spacing.md,
  },
  headerTop: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
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

  // Estatisticas
  statsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
    alignItems: 'center',
    backgroundColor: colors.primaryDark,
    borderRadius: borders.radiusM,
    paddingVertical: spacing.md,
    marginTop: spacing.md,
  },
  statItem: {
    alignItems: 'center',
    flex: 1,
  },
  statValue: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  statLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textOnPrimary,
    opacity: 0.8,
    marginTop: 2,
  },
  statDivider: {
    width: 1,
    height: 30,
    backgroundColor: colors.textOnPrimary,
    opacity: 0.3,
  },

  // Busca
  searchBar: {
    margin: spacing.md,
    backgroundColor: colors.surface,
    elevation: 2,
  },
  searchInput: {
    fontSize: typography.fontSizeS,
  },

  // Filtros
  filtros: {
    flexDirection: 'row',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    gap: spacing.sm,
  },
  chip: {
    backgroundColor: colors.gray200,
  },
  chipSelected: {
    backgroundColor: colors.primary,
  },
  chipText: {
    fontSize: typography.fontSizeXS,
    color: colors.text,
  },
  chipTextSelected: {
    color: colors.textOnPrimary,
  },

  // Cabecalho de secao
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: colors.gray100,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  sectionHeaderLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  sectionIcon: {
    margin: 0,
    padding: 0,
  },
  sectionTitle: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  sectionCount: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },
  sectionAlertBadge: {
    backgroundColor: colors.dangerLight,
    paddingHorizontal: spacing.sm,
    paddingVertical: 2,
    borderRadius: borders.radiusS,
  },
  sectionAlertText: {
    fontSize: typography.fontSizeXS,
    color: colors.danger,
    fontWeight: typography.fontWeightMedium,
  },

  // Lista
  list: {
    paddingBottom: spacing.xxl,
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
});

export default HomeTecnicoScreen;
