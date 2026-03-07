/**
 * Aba Agua do detalhe do lote no eGranja.
 *
 * Exibe:
 * - Lista de registros diarios de consumo de agua
 * - Calculos: consumo/ave/dia, relacao agua/racao
 * - Alerta se relacao fora de 1.6-2.0 ou variacao > 15%
 * - Grafico de evolucao de consumo
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
  Dimensions,
  ScrollView,
} from 'react-native';
import { LineChart } from 'react-native-chart-kit';
import dayjs from 'dayjs';
import { useLoteStore, ConsumoAgua } from '@stores/loteStore';
import { EmptyState } from '@components/EmptyState';
import { FABMenu } from '@components/FABMenu';
import { IndicadorCard } from '@components/IndicadorCard';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  chartConfig,
  getWaterFeedRatioColor,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface LoteAguaTabProps {
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

const screenWidth = Dimensions.get('window').width;

export const LoteAguaTab: React.FC<LoteAguaTabProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  const {
    consumosAgua,
    isLoading,
    isLoadingMore,
    pagination,
    fetchConsumosAgua,
    loteSelecionado,
  } = useLoteStore();

  // Carregar dados ao montar
  useEffect(() => {
    fetchConsumosAgua(loteId, 1);
  }, [loteId, fetchConsumosAgua]);

  // Pull-to-refresh
  const handleRefresh = useCallback(() => {
    fetchConsumosAgua(loteId, 1);
  }, [loteId, fetchConsumosAgua]);

  // Paginacao
  const handleEndReached = useCallback(() => {
    if (!isLoadingMore && pagination && pagination.page < pagination.total_pages) {
      fetchConsumosAgua(loteId, pagination.page + 1);
    }
  }, [loteId, isLoadingMore, pagination, fetchConsumosAgua]);

  // Novo consumo
  const handleNovoConsumo = useCallback(() => {
    navigation.navigate('NovoConsumoAgua' as never, { loteId } as never);
  }, [navigation, loteId]);

  // Dados do grafico
  const chartData = useMemo(() => {
    if (consumosAgua.length < 2) return null;
    const sorted = [...consumosAgua].sort(
      (a, b) => new Date(a.data).getTime() - new Date(b.data).getTime(),
    );
    const ultimos = sorted.slice(-14); // Ultimos 14 dias

    return {
      labels: ultimos.map((c) => dayjs(c.data).format('DD/MM')),
      datasets: [
        {
          data: ultimos.map((c) => c.quantidadeLitros),
          color: (opacity = 1) => `rgba(21, 101, 192, ${opacity})`,
          strokeWidth: 2,
        },
      ],
    };
  }, [consumosAgua]);

  // Verificar alertas
  const alertas = useMemo(() => {
    const result: string[] = [];
    if (consumosAgua.length < 2) return result;

    const sorted = [...consumosAgua].sort(
      (a, b) => new Date(b.data).getTime() - new Date(a.data).getTime(),
    );

    // Verificar relacao agua/racao
    const ultimo = sorted[0];
    if (ultimo?.relacaoAguaRacao !== undefined) {
      if (ultimo.relacaoAguaRacao < 1.6 || ultimo.relacaoAguaRacao > 2.0) {
        result.push(
          `Relacao agua/racao fora do normal: ${ultimo.relacaoAguaRacao.toFixed(1)} (ideal: 1,6 a 2,0)`,
        );
      }
    }

    // Verificar variacao > 15%
    if (sorted.length >= 2) {
      const hoje = sorted[0].quantidadeLitros;
      const ontem = sorted[1].quantidadeLitros;
      if (ontem > 0) {
        const variacao = Math.abs((hoje - ontem) / ontem) * 100;
        if (variacao > 15) {
          result.push(
            `Variacao de ${variacao.toFixed(0)}% no consumo de agua vs dia anterior.`,
          );
        }
      }
    }

    return result;
  }, [consumosAgua]);

  // Renderizar card
  const renderItem = useCallback(
    ({ item }: { item: ConsumoAgua }) => {
      const aguaRacaoColor = item.relacaoAguaRacao !== undefined
        ? getWaterFeedRatioColor(item.relacaoAguaRacao)
        : colors.text;

      return (
        <View style={styles.card}>
          <View style={styles.cardHeader}>
            <Text style={styles.cardData}>
              {dayjs(item.data).format('DD/MM/YYYY')}
            </Text>
            <Text style={styles.cardQtd}>
              {item.quantidadeLitros.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} L
            </Text>
          </View>
          <View style={styles.cardBody}>
            {item.consumoPorAve !== undefined && (
              <View style={styles.cardRow}>
                <Text style={styles.cardLabel}>Consumo/ave</Text>
                <Text style={styles.cardValue}>
                  {item.consumoPorAve.toFixed(0)} mL
                </Text>
              </View>
            )}
            {item.relacaoAguaRacao !== undefined && (
              <View style={styles.cardRow}>
                <Text style={styles.cardLabel}>Relacao agua/racao</Text>
                <Text style={[styles.cardValue, { color: aguaRacaoColor }]}>
                  {item.relacaoAguaRacao.toFixed(1)}
                </Text>
              </View>
            )}
          </View>
        </View>
      );
    },
    [],
  );

  // Header com grafico e alertas
  const renderHeader = useCallback(() => (
    <View>
      {/* Alertas */}
      {alertas.length > 0 && (
        <View style={styles.alertasContainer}>
          {alertas.map((alerta, index) => (
            <View key={index} style={styles.alertaItem}>
              <Text style={styles.alertaText}>{alerta}</Text>
            </View>
          ))}
        </View>
      )}

      {/* Grafico */}
      {chartData && (
        <View style={styles.chartContainer}>
          <Text style={styles.chartTitulo}>Evolucao do Consumo de Agua</Text>
          <ScrollView horizontal showsHorizontalScrollIndicator={false}>
            <LineChart
              data={chartData}
              width={Math.max(screenWidth - spacing.xxl * 2, chartData.labels.length * 50)}
              height={180}
              chartConfig={{
                ...chartConfig,
                decimalCount: 0,
              }}
              bezier
              style={styles.chart}
              yAxisSuffix="L"
            />
          </ScrollView>
        </View>
      )}
    </View>
  ), [alertas, chartData]);

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
        data={consumosAgua}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        ListHeaderComponent={consumosAgua.length > 0 ? renderHeader : null}
        refreshControl={
          <RefreshControl
            refreshing={isLoading && consumosAgua.length > 0}
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
              icon="water"
              titulo="Nenhum registro de agua"
              descricao="Registre o consumo diario de agua para monitorar a relacao agua/racao."
              actionLabel="Registrar Consumo"
              actionIcon="plus"
              onAction={handleNovoConsumo}
            />
          )
        }
        contentContainerStyle={
          consumosAgua.length === 0 ? styles.emptyList : styles.list
        }
        showsVerticalScrollIndicator={false}
      />

      {consumosAgua.length > 0 && (
        <FABMenu
          actions={[{ label: 'Registrar Consumo', icon: 'plus', onPress: handleNovoConsumo }]}
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

  // Alertas
  alertasContainer: {
    marginBottom: spacing.md,
    gap: spacing.sm,
  },
  alertaItem: {
    backgroundColor: colors.dangerLight,
    borderRadius: borders.radiusM,
    padding: spacing.md,
    borderLeftWidth: 4,
    borderLeftColor: colors.danger,
  },
  alertaText: {
    fontSize: typography.fontSizeS,
    color: colors.danger,
    fontWeight: typography.fontWeightMedium,
  },

  // Grafico
  chartContainer: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadows.small,
  },
  chartTitulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
  },
  chart: {
    borderRadius: borders.radiusM,
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
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  cardData: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  cardQtd: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.secondary,
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

export default LoteAguaTab;
