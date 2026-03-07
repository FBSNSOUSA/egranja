/**
 * Tela de comparativo entre lotes do eGranja.
 *
 * Funcionalidades:
 * - Multi-select de lotes para comparar
 * - Tabela com indicadores lado a lado: peso, mortalidade, CA, IEP, GPD
 * - Grafico de evolucao do IEP ao longo dos lotes
 */

import React, { useState, useCallback, useEffect, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  RefreshControl,
  Dimensions,
} from 'react-native';
import { Appbar, Checkbox, Button, Divider, Snackbar, Chip, IconButton } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { LineChart } from 'react-native-chart-kit';
import { apiGet } from '@services/api';
import { EmptyState } from '@components/EmptyState';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  chartConfig,
  getIEPClassification,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface LoteOption {
  id: string;
  nome: string;
  data_inicio: string;
  data_fim?: string;
  status: string;
}

interface LoteComparativo {
  lote_id: string;
  lote_nome: string;
  peso_medio_g: number;
  mortalidade_pct: number;
  conversao_alimentar: number;
  iep: number;
  gpd: number;
  viabilidade_pct: number;
  total_aves_alojadas: number;
  total_aves_abatidas: number;
}

// ==========================================
// CONSTANTES
// ==========================================

const SCREEN_WIDTH = Dimensions.get('window').width;

const INDICADORES = [
  { key: 'peso_medio_g', label: 'Peso medio (g)', format: (v: number) => v.toFixed(0) },
  { key: 'mortalidade_pct', label: 'Mortalidade (%)', format: (v: number) => v.toFixed(2).replace('.', ',') },
  { key: 'conversao_alimentar', label: 'Conv. Alimentar', format: (v: number) => v.toFixed(3).replace('.', ',') },
  { key: 'iep', label: 'IEP', format: (v: number) => v.toFixed(0) },
  { key: 'gpd', label: 'GPD (g/dia)', format: (v: number) => v.toFixed(1).replace('.', ',') },
  { key: 'viabilidade_pct', label: 'Viabilidade (%)', format: (v: number) => v.toFixed(2).replace('.', ',') },
] as const;

// ==========================================
// COMPONENTE
// ==========================================

const ComparativoLotesScreen: React.FC = () => {
  const navigation = useNavigation<any>();

  const [lotes, setLotes] = useState<LoteOption[]>([]);
  const [selectedLoteIds, setSelectedLoteIds] = useState<Set<string>>(new Set());
  const [comparativos, setComparativos] = useState<LoteComparativo[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [showSelector, setShowSelector] = useState(true);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  // Carregar lotes
  useEffect(() => {
    carregarLotes();
  }, []);

  const carregarLotes = useCallback(async () => {
    try {
      const response = await apiGet<LoteOption[]>('/lotes', {
        incluir_finalizados: true,
      });
      setLotes(response.data);
    } catch (error) {
      console.error('[Comparativo] Erro ao carregar lotes:', error);
    } finally {
      setLoading(false);
    }
  }, []);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarLotes();
    setRefreshing(false);
  }, [carregarLotes]);

  // Toggle selecao de lote
  const toggleLote = useCallback((loteId: string) => {
    setSelectedLoteIds((prev) => {
      const next = new Set(prev);
      if (next.has(loteId)) {
        next.delete(loteId);
      } else {
        next.add(loteId);
      }
      return next;
    });
  }, []);

  // Buscar comparativo
  const buscarComparativo = useCallback(async () => {
    if (selectedLoteIds.size < 2) {
      setSnackbarMessage('Selecione ao menos 2 lotes para comparar.');
      setSnackbarVisible(true);
      return;
    }

    try {
      setLoading(true);
      const ids = Array.from(selectedLoteIds).join(',');
      const response = await apiGet<LoteComparativo[]>(
        '/relatorios/comparativo',
        { lote_ids: ids },
      );
      setComparativos(response.data);
      setShowSelector(false);
    } catch (error) {
      console.error('[Comparativo] Erro ao buscar:', error);
      setSnackbarMessage('Erro ao carregar comparativo.');
      setSnackbarVisible(true);
    } finally {
      setLoading(false);
    }
  }, [selectedLoteIds]);

  // Dados do grafico IEP
  const chartData = useMemo(() => {
    if (comparativos.length === 0) return null;

    return {
      labels: comparativos.map((c) => {
        // Abreviar nome do lote
        const nome = c.lote_nome;
        return nome.length > 8 ? nome.substring(0, 8) + '...' : nome;
      }),
      datasets: [
        {
          data: comparativos.map((c) => c.iep),
          strokeWidth: 3,
          color: (opacity = 1) => `rgba(21, 101, 192, ${opacity})`,
        },
      ],
    };
  }, [comparativos]);

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Comparativo de Lotes"
          titleStyle={styles.headerTitle}
        />
        {!showSelector && (
          <Appbar.Action
            icon="filter"
            color={colors.textOnPrimary}
            onPress={() => setShowSelector(true)}
          />
        )}
      </Appbar.Header>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[colors.primary]}
          />
        }
      >
        {/* Seletor de lotes */}
        {showSelector && (
          <View style={styles.selectorContainer}>
            <Text style={styles.selectorTitle}>
              Selecione os lotes para comparar:
            </Text>
            <Text style={styles.selectorHint}>
              Selecione ao menos 2 lotes
            </Text>

            {lotes.map((lote) => (
              <TouchableOpacity
                key={lote.id}
                style={[
                  styles.loteCheckItem,
                  selectedLoteIds.has(lote.id) && styles.loteCheckItemSelected,
                ]}
                onPress={() => toggleLote(lote.id)}
                activeOpacity={0.7}
              >
                <Checkbox
                  status={selectedLoteIds.has(lote.id) ? 'checked' : 'unchecked'}
                  onPress={() => toggleLote(lote.id)}
                  color={colors.primary}
                />
                <View style={styles.loteCheckInfo}>
                  <Text style={styles.loteCheckNome}>{lote.nome}</Text>
                  <Text style={styles.loteCheckDetalhe}>
                    {lote.status === 'ativo' ? 'Ativo' : 'Finalizado'}
                    {lote.data_fim ? ` - ${lote.data_fim}` : ''}
                  </Text>
                </View>
              </TouchableOpacity>
            ))}

            <Button
              mode="contained"
              onPress={buscarComparativo}
              disabled={selectedLoteIds.size < 2}
              style={styles.compararButton}
              contentStyle={styles.compararButtonContent}
              labelStyle={styles.compararButtonLabel}
              buttonColor={colors.primary}
              textColor={colors.textOnPrimary}
              icon="table"
            >
              Comparar ({selectedLoteIds.size} selecionados)
            </Button>
          </View>
        )}

        {/* Tabela comparativa */}
        {comparativos.length > 0 && !showSelector && (
          <>
            {/* Chips dos lotes selecionados */}
            <View style={styles.chipsContainer}>
              {comparativos.map((comp) => (
                <Chip
                  key={comp.lote_id}
                  mode="flat"
                  style={styles.loteChip}
                  textStyle={styles.loteChipText}
                >
                  {comp.lote_nome}
                </Chip>
              ))}
            </View>

            {/* Tabela */}
            <View style={styles.tableContainer}>
              <Text style={styles.sectionTitle}>Indicadores</Text>

              <ScrollView horizontal showsHorizontalScrollIndicator={true}>
                <View>
                  {/* Cabecalho */}
                  <View style={styles.tableRow}>
                    <View style={styles.tableHeaderCell}>
                      <Text style={styles.tableHeaderText}>Indicador</Text>
                    </View>
                    {comparativos.map((comp) => (
                      <View key={comp.lote_id} style={styles.tableValueCell}>
                        <Text style={styles.tableHeaderText} numberOfLines={2}>
                          {comp.lote_nome}
                        </Text>
                      </View>
                    ))}
                  </View>

                  <Divider style={styles.tableDivider} />

                  {/* Linhas de indicadores */}
                  {INDICADORES.map((ind, index) => {
                    // Encontrar melhor e pior valor para colorir
                    const values = comparativos.map(
                      (c) => c[ind.key as keyof LoteComparativo] as number,
                    );
                    const maxVal = Math.max(...values);
                    const minVal = Math.min(...values);
                    const isBetterHigher = !['mortalidade_pct', 'conversao_alimentar'].includes(ind.key);

                    return (
                      <View key={ind.key}>
                        <View style={[styles.tableRow, index % 2 === 0 && styles.tableRowAlt]}>
                          <View style={styles.tableHeaderCell}>
                            <Text style={styles.tableLabelText}>{ind.label}</Text>
                          </View>
                          {comparativos.map((comp) => {
                            const val = comp[ind.key as keyof LoteComparativo] as number;
                            const isBest = isBetterHigher ? val === maxVal : val === minVal;
                            const isWorst = isBetterHigher ? val === minVal : val === maxVal;

                            return (
                              <View key={comp.lote_id} style={styles.tableValueCell}>
                                <Text
                                  style={[
                                    styles.tableValueText,
                                    isBest && styles.tableValueBest,
                                    isWorst && comparativos.length > 1 && styles.tableValueWorst,
                                  ]}
                                >
                                  {ind.format(val)}
                                </Text>
                              </View>
                            );
                          })}
                        </View>
                        <Divider />
                      </View>
                    );
                  })}
                </View>
              </ScrollView>
            </View>

            {/* Grafico evolucao IEP */}
            {chartData && (
              <View style={styles.chartContainer}>
                <Text style={styles.sectionTitle}>Evolucao do IEP</Text>
                <LineChart
                  data={chartData}
                  width={SCREEN_WIDTH - spacing.lg * 4}
                  height={220}
                  chartConfig={{
                    ...chartConfig,
                    decimalCount: 0,
                  }}
                  bezier
                  style={styles.chart}
                  fromZero={false}
                  yAxisSuffix=""
                  yAxisInterval={1}
                />

                {/* Legenda IEP */}
                <View style={styles.iepLegend}>
                  {comparativos.map((comp) => {
                    const classification = getIEPClassification(comp.iep);
                    return (
                      <View key={comp.lote_id} style={styles.iepLegendItem}>
                        <View style={[styles.iepDot, { backgroundColor: classification.color }]} />
                        <Text style={styles.iepLegendText}>
                          {comp.lote_nome}: {comp.iep.toFixed(0)} ({classification.label})
                        </Text>
                      </View>
                    );
                  })}
                </View>
              </View>
            )}
          </>
        )}

        {comparativos.length === 0 && !showSelector && (
          <EmptyState
            icon="table-off"
            titulo="Nenhum dado"
            descricao="Nao foi possivel carregar os dados comparativos."
          />
        )}
      </ScrollView>

      <Snackbar
        visible={snackbarVisible}
        onDismiss={() => setSnackbarVisible(false)}
        duration={3000}
        style={styles.snackbar}
      >
        {snackbarMessage}
      </Snackbar>
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
    paddingBottom: spacing.huge,
  },

  // Seletor
  selectorContainer: {
    backgroundColor: colors.surface,
    margin: spacing.lg,
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.small,
  },
  selectorTitle: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.xs,
  },
  selectorHint: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginBottom: spacing.md,
  },
  loteCheckItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    borderRadius: borders.radiusM,
    marginBottom: spacing.xs,
  },
  loteCheckItemSelected: {
    backgroundColor: colors.primaryLight + '15',
  },
  loteCheckInfo: {
    flex: 1,
    marginLeft: spacing.xs,
  },
  loteCheckNome: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },
  loteCheckDetalhe: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },
  compararButton: {
    marginTop: spacing.lg,
    borderRadius: components.button.borderRadius,
  },
  compararButtonContent: {
    minHeight: components.button.minHeight,
  },
  compararButtonLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
  },

  // Chips
  chipsContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    paddingHorizontal: spacing.lg,
    gap: spacing.sm,
    marginBottom: spacing.md,
  },
  loteChip: {
    backgroundColor: colors.secondaryLight + '30',
  },
  loteChipText: {
    fontSize: 12,
    color: colors.secondary,
    fontWeight: typography.fontWeightMedium,
  },

  // Tabela
  tableContainer: {
    backgroundColor: colors.surface,
    marginHorizontal: spacing.lg,
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.small,
    marginBottom: spacing.lg,
  },
  sectionTitle: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
  },
  tableRow: {
    flexDirection: 'row',
    alignItems: 'center',
    minHeight: 44,
  },
  tableRowAlt: {
    backgroundColor: colors.gray50,
  },
  tableHeaderCell: {
    width: 120,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.sm,
  },
  tableValueCell: {
    width: 90,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.xs,
    alignItems: 'center',
  },
  tableHeaderText: {
    fontSize: 12,
    fontWeight: typography.fontWeightBold,
    color: colors.textSecondary,
  },
  tableLabelText: {
    fontSize: 12,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },
  tableValueText: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    fontWeight: typography.fontWeightRegular,
    textAlign: 'center',
  },
  tableValueBest: {
    color: colors.success,
    fontWeight: typography.fontWeightBold,
  },
  tableValueWorst: {
    color: colors.danger,
  },
  tableDivider: {
    backgroundColor: colors.gray400,
    height: 2,
  },

  // Grafico
  chartContainer: {
    backgroundColor: colors.surface,
    marginHorizontal: spacing.lg,
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.small,
    marginBottom: spacing.lg,
  },
  chart: {
    borderRadius: borders.radiusL,
  },
  iepLegend: {
    marginTop: spacing.md,
    gap: spacing.xs,
  },
  iepLegendItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  iepDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: spacing.sm,
  },
  iepLegendText: {
    fontSize: typography.fontSizeXS,
    color: colors.text,
  },

  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default ComparativoLotesScreen;
