/**
 * Aba Mortalidade do detalhe do lote no eGranja.
 *
 * Exibe:
 * - Resumo no topo: mortes hoje, ultimos 7 dias, total (com % e indicador)
 * - Lista de registros (data decrescente)
 * - Card: data, quantidade, causa, % do dia, observacao
 * - FAB "+" para novo registro
 * - Pull-to-refresh e paginacao
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
import dayjs from 'dayjs';
import { useLoteStore, Mortalidade } from '@stores/loteStore';
import { EmptyState } from '@components/EmptyState';
import { FABMenu } from '@components/FABMenu';
import { IndicadorCard } from '@components/IndicadorCard';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  getMortalityIndicatorColor,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface LoteMortalidadeTabProps {
  route: {
    params: {
      loteId: string;
    };
  };
  navigation: {
    navigate: (screen: string, params?: any) => void;
  };
}

// ==========================================
// COMPONENTE
// ==========================================

export const LoteMortalidadeTab: React.FC<LoteMortalidadeTabProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  const {
    mortalidades,
    isLoading,
    isLoadingMore,
    pagination,
    fetchMortalidades,
    loteSelecionado,
  } = useLoteStore();

  // Carregar mortalidades ao montar
  useEffect(() => {
    fetchMortalidades(loteId, 1);
  }, [loteId, fetchMortalidades]);

  // Pull-to-refresh
  const handleRefresh = useCallback(() => {
    fetchMortalidades(loteId, 1);
  }, [loteId, fetchMortalidades]);

  // Paginacao
  const handleEndReached = useCallback(() => {
    if (!isLoadingMore && pagination && pagination.page < pagination.total_pages) {
      fetchMortalidades(loteId, pagination.page + 1);
    }
  }, [loteId, isLoadingMore, pagination, fetchMortalidades]);

  // Nova mortalidade
  const handleNovaMortalidade = useCallback(() => {
    navigation.navigate('NovaMortalidade' as never, { loteId } as never);
  }, [navigation, loteId]);

  // Calculos de resumo
  const resumo = useMemo(() => {
    const hoje = dayjs().startOf('day');
    const seteDiasAtras = hoje.subtract(7, 'day');

    const mortesHoje = mortalidades
      .filter((m) => dayjs(m.data).isSame(hoje, 'day'))
      .reduce((acc, m) => acc + m.quantidade, 0);

    const mortes7Dias = mortalidades
      .filter((m) => dayjs(m.data).isAfter(seteDiasAtras))
      .reduce((acc, m) => acc + m.quantidade, 0);

    const totalMortes = mortalidades.reduce((acc, m) => acc + m.quantidade, 0);

    const qtdOriginal = loteSelecionado?.quantidade || 1;
    const pctHoje = (mortesHoje / qtdOriginal) * 100;
    const pctTotal = (totalMortes / qtdOriginal) * 100;

    return { mortesHoje, mortes7Dias, totalMortes, pctHoje, pctTotal };
  }, [mortalidades, loteSelecionado]);

  // Renderizar card de mortalidade
  const renderItem = useCallback(
    ({ item }: { item: Mortalidade }) => {
      const mortColor = item.percentualDia !== undefined
        ? getMortalityIndicatorColor(item.percentualDia)
        : colors.text;

      return (
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardData}>
              {dayjs(item.data).format('DD/MM/YYYY')}
            </Text>
            <View style={styles.cardQtdContainer}>
              <Text style={[styles.cardQtd, { color: mortColor }]}>
                {item.quantidade}
              </Text>
              <Text style={styles.cardQtdLabel}>morte{item.quantidade !== 1 ? 's' : ''}</Text>
            </View>
          </View>

          <View style={styles.cardBody}>
            <View style={styles.cardRow}>
              <Text style={styles.cardLabel}>Causa</Text>
              <Text style={styles.cardValue}>{item.causa}</Text>
            </View>
            {item.percentualDia !== undefined && (
              <View style={styles.cardRow}>
                <Text style={styles.cardLabel}>% do dia</Text>
                <Text style={[styles.cardValue, { color: mortColor }]}>
                  {item.percentualDia.toFixed(2)}%
                </Text>
              </View>
            )}
            {item.observacao && (
              <View style={styles.observacaoContainer}>
                <Text style={styles.cardLabel}>Observacao</Text>
                <Text style={styles.observacaoText}>{item.observacao}</Text>
              </View>
            )}
          </View>
        </View>
      );
    },
    [],
  );

  // Header da lista (resumo)
  const renderHeader = useCallback(() => {
    const corHoje = getMortalityIndicatorColor(resumo.pctHoje);

    return (
      <View style={styles.resumoContainer}>
        <View style={styles.resumoRow}>
          <View style={styles.resumoItem}>
            <IndicadorCard
              label="Mortes Hoje"
              valor={String(resumo.mortesHoje)}
              subtitulo={`${resumo.pctHoje.toFixed(2)}%`}
              cor={corHoje}
              icone="alert-circle"
              compacto
            />
          </View>
          <View style={styles.resumoItem}>
            <IndicadorCard
              label="Ultimos 7 dias"
              valor={String(resumo.mortes7Dias)}
              icone="calendar-week"
              compacto
            />
          </View>
          <View style={styles.resumoItem}>
            <IndicadorCard
              label="Total"
              valor={String(resumo.totalMortes)}
              subtitulo={`${resumo.pctTotal.toFixed(1)}%`}
              cor={resumo.pctTotal > 3 ? colors.danger : colors.success}
              icone="sigma"
              compacto
            />
          </View>
        </View>
      </View>
    );
  }, [resumo]);

  // Footer loading
  const renderFooter = useCallback(() => {
    if (!isLoadingMore) return null;
    return (
      <View style={styles.footerLoading}>
        <ActivityIndicator size="small" color={colors.primary} />
      </View>
    );
  }, [isLoadingMore]);

  return (
    <View style={styles.container}>
      <FlatList
        data={mortalidades}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        ListHeaderComponent={mortalidades.length > 0 ? renderHeader : null}
        refreshControl={
          <RefreshControl
            refreshing={isLoading && mortalidades.length > 0}
            onRefresh={handleRefresh}
            colors={[colors.primary]}
          />
        }
        onEndReached={handleEndReached}
        onEndReachedThreshold={0.3}
        ListFooterComponent={renderFooter}
        ListEmptyComponent={
          isLoading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={colors.primary} />
            </View>
          ) : (
            <EmptyState
              icon="alert-circle-outline"
              titulo="Nenhum registro de mortalidade"
              descricao="Registre a mortalidade diaria para acompanhar os indicadores do lote."
              actionLabel="Novo Registro"
              actionIcon="plus"
              onAction={handleNovaMortalidade}
            />
          )
        }
        contentContainerStyle={
          mortalidades.length === 0 ? styles.emptyList : styles.list
        }
        showsVerticalScrollIndicator={false}
      />

      {mortalidades.length > 0 && (
        <FABMenu
          actions={[{ label: 'Novo Registro', icon: 'plus', onPress: handleNovaMortalidade }]}
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
  list: {
    padding: spacing.md,
    paddingBottom: spacing.huge + spacing.xxl,
  },
  emptyList: {
    flexGrow: 1,
  },

  // Resumo
  resumoContainer: {
    marginBottom: spacing.md,
  },
  resumoRow: {
    flexDirection: 'row',
    gap: spacing.sm,
  },
  resumoItem: {
    flex: 1,
  },

  // Card
  card: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadows.small,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: spacing.sm,
  },
  cardData: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  cardQtdContainer: {
    alignItems: 'center',
  },
  cardQtd: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
  },
  cardQtdLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },
  cardBody: {
    gap: spacing.xs,
  },
  cardRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 2,
  },
  cardLabel: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  cardValue: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },
  observacaoContainer: {
    marginTop: spacing.xs,
    paddingTop: spacing.xs,
    borderTopWidth: 1,
    borderTopColor: colors.divider,
  },
  observacaoText: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    marginTop: 2,
    fontStyle: 'italic',
  },

  // Loading
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: spacing.huge,
  },
  footerLoading: {
    paddingVertical: spacing.xl,
    alignItems: 'center',
  },
});

export default LoteMortalidadeTab;
