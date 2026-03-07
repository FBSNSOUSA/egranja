/**
 * Aba Racao do detalhe do lote no eGranja.
 *
 * Exibe:
 * - Saldo atual no topo (Recebido - Consumido = Saldo, dias restantes)
 * - Abas internas: Recebimentos | Consumos
 * - Lista de recebimentos e consumos
 * - FAB "+" com opcoes: "Recebimento" ou "Consumo"
 * - Pull-to-refresh e paginacao
 */

import React, { useEffect, useState, useCallback, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  RefreshControl,
  ActivityIndicator,
  TouchableOpacity,
} from 'react-native';
import dayjs from 'dayjs';
import { useLoteStore, RecebimentoRacao, ConsumoRacao } from '@stores/loteStore';
import { EmptyState } from '@components/EmptyState';
import { FABMenu, FABAction } from '@components/FABMenu';
import { IndicadorCard } from '@components/IndicadorCard';
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

interface LoteRacaoTabProps {
  route: {
    params: {
      loteId: string;
    };
  };
  navigation: {
    navigate: (screen: string, params?: any) => void;
  };
}

type AbaInterna = 'recebimentos' | 'consumos';

// ==========================================
// COMPONENTE
// ==========================================

export const LoteRacaoTab: React.FC<LoteRacaoTabProps> = ({ route, navigation }) => {
  const { loteId } = route.params;
  const [abaAtiva, setAbaAtiva] = useState<AbaInterna>('recebimentos');

  const {
    recebimentosRacao,
    consumosRacao,
    isLoading,
    isLoadingMore,
    pagination,
    fetchRecebimentosRacao,
    fetchConsumosRacao,
  } = useLoteStore();

  // Carregar dados ao montar
  useEffect(() => {
    fetchRecebimentosRacao(loteId, 1);
    fetchConsumosRacao(loteId, 1);
  }, [loteId, fetchRecebimentosRacao, fetchConsumosRacao]);

  // Pull-to-refresh
  const handleRefresh = useCallback(() => {
    fetchRecebimentosRacao(loteId, 1);
    fetchConsumosRacao(loteId, 1);
  }, [loteId, fetchRecebimentosRacao, fetchConsumosRacao]);

  // Calculos de saldo
  const saldo = useMemo(() => {
    const totalRecebido = recebimentosRacao.reduce((acc, r) => acc + r.quantidadeKg, 0);
    const totalConsumido = consumosRacao.reduce((acc, c) => acc + c.quantidadeKg, 0);
    const saldoKg = totalRecebido - totalConsumido;

    // Calculo de dias restantes baseado no consumo medio dos ultimos 7 dias
    const seteDiasAtras = dayjs().subtract(7, 'day');
    const consumosRecentes = consumosRacao.filter((c) => dayjs(c.data).isAfter(seteDiasAtras));
    const consumoMedioDiario = consumosRecentes.length > 0
      ? consumosRecentes.reduce((acc, c) => acc + c.quantidadeKg, 0) / 7
      : 0;
    const diasRestantes = consumoMedioDiario > 0
      ? Math.floor(saldoKg / consumoMedioDiario)
      : 0;

    return { totalRecebido, totalConsumido, saldoKg, diasRestantes, consumoMedioDiario };
  }, [recebimentosRacao, consumosRacao]);

  // Navegacao
  const handleNovoRecebimento = useCallback(() => {
    navigation.navigate('NovoRecebimentoRacao' as never, { loteId } as never);
  }, [navigation, loteId]);

  const handleNovoConsumo = useCallback(() => {
    navigation.navigate('NovoConsumoRacao' as never, { loteId } as never);
  }, [navigation, loteId]);

  // Acoes do FAB
  const fabActions: FABAction[] = [
    {
      label: 'Recebimento',
      icon: 'package-down',
      onPress: handleNovoRecebimento,
      color: colors.success,
    },
    {
      label: 'Consumo',
      icon: 'package-up',
      onPress: handleNovoConsumo,
      color: colors.secondary,
    },
  ];

  // Renderizar card de recebimento
  const renderRecebimento = useCallback(
    ({ item }: { item: RecebimentoRacao }) => (
      <View style={styles.card}>
        <View style={styles.cardHeader}>
          <Text style={styles.cardData}>
            {dayjs(item.dataRecebimento).format('DD/MM/YYYY')}
          </Text>
          <Text style={styles.cardQtd}>
            +{item.quantidadeKg.toLocaleString('pt-BR', { maximumFractionDigits: 1 })} kg
          </Text>
        </View>
        <View style={styles.cardBody}>
          {item.tipoRacaoNome && (
            <View style={styles.cardRow}>
              <Text style={styles.cardLabel}>Tipo</Text>
              <Text style={styles.cardValue}>{item.tipoRacaoNome}</Text>
            </View>
          )}
          {item.fornecedor && (
            <View style={styles.cardRow}>
              <Text style={styles.cardLabel}>Fornecedor</Text>
              <Text style={styles.cardValue}>{item.fornecedor}</Text>
            </View>
          )}
          {item.loteRacao && (
            <View style={styles.cardRow}>
              <Text style={styles.cardLabel}>Lote racao</Text>
              <Text style={styles.cardValue}>{item.loteRacao}</Text>
            </View>
          )}
          <View style={styles.cardRow}>
            <Text style={styles.cardLabel}>Origem</Text>
            <View style={styles.tagContainer}>
              <Text style={styles.tagText}>
                {item.origem === 'compra' ? 'Compra' : item.origem === 'remanescente_anterior' ? 'Remanescente' : 'Sobra final'}
              </Text>
            </View>
          </View>
        </View>
      </View>
    ),
    [],
  );

  // Renderizar card de consumo
  const renderConsumo = useCallback(
    ({ item }: { item: ConsumoRacao }) => (
      <View style={styles.card}>
        <View style={styles.cardHeader}>
          <Text style={styles.cardData}>
            {dayjs(item.data).format('DD/MM/YYYY')}
          </Text>
          <Text style={[styles.cardQtd, { color: colors.danger }]}>
            -{item.quantidadeKg.toLocaleString('pt-BR', { maximumFractionDigits: 1 })} kg
          </Text>
        </View>
      </View>
    ),
    [],
  );

  // Footer loading
  const renderFooter = useCallback(() => {
    if (!isLoadingMore) return null;
    return (
      <View style={styles.footerLoading}>
        <ActivityIndicator size="small" color={colors.primary} />
      </View>
    );
  }, [isLoadingMore]);

  const currentData = abaAtiva === 'recebimentos' ? recebimentosRacao : consumosRacao;

  return (
    <View style={styles.container}>
      {/* Saldo no topo */}
      <View style={styles.saldoContainer}>
        <View style={styles.saldoRow}>
          <View style={styles.saldoItem}>
            <Text style={styles.saldoLabel}>Recebido</Text>
            <Text style={[styles.saldoValue, { color: colors.success }]}>
              {saldo.totalRecebido.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} kg
            </Text>
          </View>
          <Text style={styles.saldoOperator}>-</Text>
          <View style={styles.saldoItem}>
            <Text style={styles.saldoLabel}>Consumido</Text>
            <Text style={[styles.saldoValue, { color: colors.danger }]}>
              {saldo.totalConsumido.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} kg
            </Text>
          </View>
          <Text style={styles.saldoOperator}>=</Text>
          <View style={styles.saldoItem}>
            <Text style={styles.saldoLabel}>Saldo</Text>
            <Text
              style={[
                styles.saldoValueBold,
                { color: saldo.diasRestantes < 2 ? colors.danger : colors.success },
              ]}
            >
              {saldo.saldoKg.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} kg
            </Text>
            <Text style={styles.saldoSub}>
              ~{saldo.diasRestantes} dias
            </Text>
          </View>
        </View>
      </View>

      {/* Abas internas */}
      <View style={styles.tabsContainer}>
        <TouchableOpacity
          style={[styles.tab, abaAtiva === 'recebimentos' && styles.tabActive]}
          onPress={() => setAbaAtiva('recebimentos')}
        >
          <Text
            style={[styles.tabText, abaAtiva === 'recebimentos' && styles.tabTextActive]}
          >
            Recebimentos
          </Text>
        </TouchableOpacity>
        <TouchableOpacity
          style={[styles.tab, abaAtiva === 'consumos' && styles.tabActive]}
          onPress={() => setAbaAtiva('consumos')}
        >
          <Text
            style={[styles.tabText, abaAtiva === 'consumos' && styles.tabTextActive]}
          >
            Consumos
          </Text>
        </TouchableOpacity>
      </View>

      {/* Lista */}
      <FlatList
        data={currentData as any[]}
        keyExtractor={(item: any) => item.id}
        renderItem={abaAtiva === 'recebimentos' ? renderRecebimento as any : renderConsumo as any}
        refreshControl={
          <RefreshControl
            refreshing={isLoading && currentData.length > 0}
            onRefresh={handleRefresh}
            colors={[colors.primary]}
          />
        }
        ListFooterComponent={renderFooter}
        ListEmptyComponent={
          isLoading ? (
            <View style={styles.loadingContainer}>
              <ActivityIndicator size="large" color={colors.primary} />
            </View>
          ) : (
            <EmptyState
              icon={abaAtiva === 'recebimentos' ? 'package-down' : 'package-up'}
              titulo={
                abaAtiva === 'recebimentos'
                  ? 'Nenhum recebimento registrado'
                  : 'Nenhum consumo registrado'
              }
              descricao="Registre os movimentos de racao para controlar o saldo."
            />
          )
        }
        contentContainerStyle={
          currentData.length === 0 ? styles.emptyList : styles.list
        }
        showsVerticalScrollIndicator={false}
      />

      {/* FAB com menu */}
      <FABMenu actions={fabActions} />
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

  // Saldo
  saldoContainer: {
    backgroundColor: colors.surface,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  saldoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-around',
  },
  saldoItem: {
    alignItems: 'center',
    flex: 1,
  },
  saldoLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
    marginBottom: 2,
  },
  saldoValue: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },
  saldoValueBold: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
  },
  saldoSub: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },
  saldoOperator: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.gray400,
    marginHorizontal: spacing.xs,
  },

  // Abas internas
  tabsContainer: {
    flexDirection: 'row',
    backgroundColor: colors.surface,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  tab: {
    flex: 1,
    paddingVertical: spacing.md,
    alignItems: 'center',
    borderBottomWidth: 2,
    borderBottomColor: 'transparent',
  },
  tabActive: {
    borderBottomColor: colors.primary,
  },
  tabText: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.textSecondary,
  },
  tabTextActive: {
    color: colors.primary,
    fontWeight: typography.fontWeightBold,
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
    color: colors.success,
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
  tagContainer: {
    backgroundColor: colors.gray200,
    borderRadius: borders.radiusS,
    paddingHorizontal: spacing.sm,
    paddingVertical: 2,
  },
  tagText: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    color: colors.gray700,
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

export default LoteRacaoTab;
