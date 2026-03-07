/**
 * Tela de resumo financeiro do lote no eGranja.
 *
 * Funcionalidades:
 * - Cards grandes: Receita (verde), Custos (vermelho), Resultado (azul/vermelho)
 * - Margem por kg, margem por ave
 * - Grafico pizza de custos por categoria
 * - Comparativo vs lotes anteriores (mini tabela)
 * - Botao "Exportar PDF"
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  Share,
} from 'react-native';
import { Appbar, Button, Divider, Snackbar, IconButton } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import { PieChart } from 'react-native-chart-kit';
import { Dimensions } from 'react-native';
import { apiGet, apiPost } from '@services/api';
import { IndicadorCard } from '@components/IndicadorCard';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  components,
  chartConfig,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface FinanceiroResumo {
  receita_total: number;
  custo_total: number;
  resultado: number;
  margem_por_kg: number;
  margem_por_ave: number;
  custos_por_categoria: CustoCategoria[];
  comparativo_lotes: ComparativoLote[];
}

interface CustoCategoria {
  categoria: string;
  valor: number;
  percentual: number;
}

interface ComparativoLote {
  lote_nome: string;
  receita: number;
  custo: number;
  resultado: number;
  margem_kg: number;
}

interface FinanceiroRouteParams {
  loteId: string;
  loteNome?: string;
}

// ==========================================
// CONSTANTES
// ==========================================

const SCREEN_WIDTH = Dimensions.get('window').width;

const CATEGORIA_CORES: Record<string, string> = {
  'mao_de_obra': '#1565C0',
  'energia': '#F9A825',
  'aquecimento': '#E65100',
  'cama': '#795548',
  'manutencao': '#616161',
  'depreciacao': '#9E9E9E',
  'agua': '#0288D1',
  'outros': '#7B1FA2',
};

const CATEGORIA_LABELS: Record<string, string> = {
  'mao_de_obra': 'Mao de obra',
  'energia': 'Energia',
  'aquecimento': 'Aquecimento',
  'cama': 'Cama',
  'manutencao': 'Manutencao',
  'depreciacao': 'Depreciacao',
  'agua': 'Agua',
  'outros': 'Outros',
};

// ==========================================
// HELPERS
// ==========================================

/** Formata valor monetario no padrao BR */
const formatCurrency = (value: number): string => {
  return value.toLocaleString('pt-BR', {
    style: 'currency',
    currency: 'BRL',
  });
};

/** Formata valor monetario curto (sem "R$" extra) */
const formatCurrencyShort = (value: number): string => {
  return `R$ ${value.toFixed(2).replace('.', ',')}`;
};

// ==========================================
// COMPONENTE
// ==========================================

const FinanceiroResumoScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ FinanceiroResumo: FinanceiroRouteParams }, 'FinanceiroResumo'>>();
  const { loteId, loteNome } = route.params;

  const [resumo, setResumo] = useState<FinanceiroResumo | null>(null);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [exportando, setExportando] = useState(false);

  const carregarResumo = useCallback(async () => {
    try {
      const response = await apiGet<FinanceiroResumo>(
        `/lotes/${loteId}/financeiro/resumo`,
      );
      setResumo(response.data);
    } catch (error) {
      console.error('[Financeiro] Erro ao carregar:', error);
    } finally {
      setLoading(false);
    }
  }, [loteId]);

  useEffect(() => {
    carregarResumo();
  }, [carregarResumo]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarResumo();
    setRefreshing(false);
  }, [carregarResumo]);

  const handleExportarPDF = useCallback(async () => {
    setExportando(true);
    try {
      const response = await apiPost<{ url: string }>(
        `/lotes/${loteId}/financeiro/relatorio-pdf`,
      );

      await Share.share({
        title: `Relatorio Financeiro - ${loteNome}`,
        url: response.data.url,
        message: `Relatorio financeiro do lote ${loteNome}`,
      });
    } catch (error) {
      console.error('[Financeiro] Erro ao exportar PDF:', error);
      setSnackbarMessage('Erro ao gerar relatorio PDF.');
      setSnackbarVisible(true);
    } finally {
      setExportando(false);
    }
  }, [loteId, loteNome]);

  /** Dados para o grafico pizza */
  const pieChartData = resumo?.custos_por_categoria.map((cat) => ({
    name: CATEGORIA_LABELS[cat.categoria] || cat.categoria,
    value: cat.valor,
    color: CATEGORIA_CORES[cat.categoria] || '#9E9E9E',
    legendFontColor: colors.text,
    legendFontSize: 12,
  })) || [];

  const resultadoPositivo = (resumo?.resultado || 0) >= 0;

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Financeiro"
          subtitle={loteNome}
          titleStyle={styles.headerTitle}
          subtitleStyle={styles.headerSubtitle}
        />
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
        {resumo && (
          <>
            {/* Cards de resumo */}
            <View style={styles.resumoCards}>
              {/* Receita */}
              <View style={[styles.resumoCard, styles.receitaCard]}>
                <View style={styles.resumoCardHeader}>
                  <IconButton icon="arrow-up-bold" iconColor={colors.success} size={24} style={styles.resumoIcon} />
                  <Text style={styles.resumoCardLabel}>Receita</Text>
                </View>
                <Text style={[styles.resumoCardValor, { color: colors.success }]}>
                  {formatCurrency(resumo.receita_total)}
                </Text>
              </View>

              {/* Custos */}
              <View style={[styles.resumoCard, styles.custosCard]}>
                <View style={styles.resumoCardHeader}>
                  <IconButton icon="arrow-down-bold" iconColor={colors.danger} size={24} style={styles.resumoIcon} />
                  <Text style={styles.resumoCardLabel}>Custos</Text>
                </View>
                <Text style={[styles.resumoCardValor, { color: colors.danger }]}>
                  {formatCurrency(resumo.custo_total)}
                </Text>
                <Button
                  mode="text"
                  onPress={() => navigation.navigate('Custos', { loteId, loteNome })}
                  labelStyle={styles.verDetalhesLabel}
                  textColor={colors.danger}
                  compact
                >
                  Ver detalhes
                </Button>
              </View>

              {/* Resultado */}
              <View
                style={[
                  styles.resumoCard,
                  styles.resultadoCard,
                  { borderLeftColor: resultadoPositivo ? colors.success : colors.danger },
                ]}
              >
                <View style={styles.resumoCardHeader}>
                  <IconButton
                    icon={resultadoPositivo ? 'check-circle' : 'alert-circle'}
                    iconColor={resultadoPositivo ? colors.success : colors.danger}
                    size={24}
                    style={styles.resumoIcon}
                  />
                  <Text style={styles.resumoCardLabel}>Resultado</Text>
                </View>
                <Text
                  style={[
                    styles.resultadoValor,
                    { color: resultadoPositivo ? colors.success : colors.danger },
                  ]}
                >
                  {formatCurrency(resumo.resultado)}
                </Text>
              </View>
            </View>

            {/* Indicadores de margem */}
            <View style={styles.margensContainer}>
              <IndicadorCard
                label="Margem/kg"
                valor={formatCurrencyShort(resumo.margem_por_kg)}
                cor={resumo.margem_por_kg >= 0 ? colors.success : colors.danger}
                icone="weight-kilogram"
                compacto
              />
              <IndicadorCard
                label="Margem/ave"
                valor={formatCurrencyShort(resumo.margem_por_ave)}
                cor={resumo.margem_por_ave >= 0 ? colors.success : colors.danger}
                icone="bird"
                compacto
              />
            </View>

            {/* Grafico pizza de custos */}
            {pieChartData.length > 0 && (
              <View style={styles.chartContainer}>
                <Text style={styles.sectionTitle}>Distribuicao de Custos</Text>
                <PieChart
                  data={pieChartData}
                  width={SCREEN_WIDTH - spacing.lg * 2}
                  height={200}
                  chartConfig={chartConfig}
                  accessor="value"
                  backgroundColor="transparent"
                  paddingLeft="0"
                  center={[0, 0]}
                  absolute={false}
                />
              </View>
            )}

            {/* Comparativo vs lotes anteriores */}
            {resumo.comparativo_lotes.length > 0 && (
              <View style={styles.comparativoContainer}>
                <Text style={styles.sectionTitle}>Comparativo com Lotes Anteriores</Text>

                {/* Cabecalho da tabela */}
                <View style={styles.tabelaHeader}>
                  <Text style={[styles.tabelaHeaderCell, styles.tabelaCellLote]}>Lote</Text>
                  <Text style={styles.tabelaHeaderCell}>Receita</Text>
                  <Text style={styles.tabelaHeaderCell}>Custo</Text>
                  <Text style={styles.tabelaHeaderCell}>Result.</Text>
                  <Text style={styles.tabelaHeaderCell}>R$/kg</Text>
                </View>

                <Divider />

                {resumo.comparativo_lotes.map((lote, index) => (
                  <View key={index}>
                    <View style={styles.tabelaRow}>
                      <Text style={[styles.tabelaCell, styles.tabelaCellLote]} numberOfLines={1}>
                        {lote.lote_nome}
                      </Text>
                      <Text style={styles.tabelaCell}>
                        {(lote.receita / 1000).toFixed(1)}k
                      </Text>
                      <Text style={styles.tabelaCell}>
                        {(lote.custo / 1000).toFixed(1)}k
                      </Text>
                      <Text
                        style={[
                          styles.tabelaCell,
                          { color: lote.resultado >= 0 ? colors.success : colors.danger },
                        ]}
                      >
                        {(lote.resultado / 1000).toFixed(1)}k
                      </Text>
                      <Text
                        style={[
                          styles.tabelaCell,
                          { color: lote.margem_kg >= 0 ? colors.success : colors.danger },
                        ]}
                      >
                        {lote.margem_kg.toFixed(2).replace('.', ',')}
                      </Text>
                    </View>
                    {index < resumo.comparativo_lotes.length - 1 && <Divider />}
                  </View>
                ))}
              </View>
            )}

            {/* Botoes de acao */}
            <View style={styles.actionsContainer}>
              <Button
                mode="contained"
                onPress={() => navigation.navigate('Custos', { loteId, loteNome })}
                icon="format-list-bulleted"
                style={styles.actionButton}
                contentStyle={styles.actionButtonContent}
                labelStyle={styles.actionButtonLabel}
                buttonColor={colors.secondary}
                textColor={colors.textOnSecondary}
              >
                Gerenciar custos
              </Button>

              <Button
                mode="contained"
                onPress={() => navigation.navigate('Remuneracao', { loteId, loteNome })}
                icon="cash"
                style={styles.actionButton}
                contentStyle={styles.actionButtonContent}
                labelStyle={styles.actionButtonLabel}
                buttonColor={colors.success}
                textColor={colors.white}
              >
                Remuneracao
              </Button>

              <Button
                mode="outlined"
                onPress={handleExportarPDF}
                loading={exportando}
                disabled={exportando}
                icon="file-pdf-box"
                style={styles.actionButton}
                contentStyle={styles.actionButtonContent}
                labelStyle={styles.actionButtonLabelOutlined}
                textColor={colors.primary}
              >
                Exportar PDF
              </Button>
            </View>
          </>
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
  headerSubtitle: {
    fontSize: typography.fontSizeXS,
    color: colors.textOnPrimary,
    opacity: 0.85,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: spacing.huge,
  },

  // Cards resumo
  resumoCards: {
    padding: spacing.lg,
    gap: spacing.md,
  },
  resumoCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    ...shadows.medium,
  },
  receitaCard: {
    borderLeftWidth: 4,
    borderLeftColor: colors.success,
  },
  custosCard: {
    borderLeftWidth: 4,
    borderLeftColor: colors.danger,
  },
  resultadoCard: {
    borderLeftWidth: 4,
  },
  resumoCardHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  resumoIcon: {
    margin: 0,
    padding: 0,
    marginRight: spacing.xs,
  },
  resumoCardLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.textSecondary,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  resumoCardValor: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    marginLeft: spacing.xxxl,
  },
  resultadoValor: {
    fontSize: typography.fontSizeXXL,
    fontWeight: typography.fontWeightBold,
    marginLeft: spacing.xxxl,
  },
  verDetalhesLabel: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
  },

  // Margens
  margensContainer: {
    flexDirection: 'row',
    paddingHorizontal: spacing.lg,
    gap: spacing.md,
    marginBottom: spacing.lg,
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
  sectionTitle: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
  },

  // Tabela comparativa
  comparativoContainer: {
    backgroundColor: colors.surface,
    marginHorizontal: spacing.lg,
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.small,
    marginBottom: spacing.lg,
  },
  tabelaHeader: {
    flexDirection: 'row',
    paddingVertical: spacing.sm,
  },
  tabelaHeaderCell: {
    flex: 1,
    fontSize: 12,
    fontWeight: typography.fontWeightBold,
    color: colors.textSecondary,
    textAlign: 'center',
  },
  tabelaRow: {
    flexDirection: 'row',
    paddingVertical: spacing.sm,
    alignItems: 'center',
  },
  tabelaCell: {
    flex: 1,
    fontSize: 12,
    color: colors.text,
    textAlign: 'center',
  },
  tabelaCellLote: {
    flex: 1.5,
    textAlign: 'left',
  },

  // Botoes
  actionsContainer: {
    paddingHorizontal: spacing.lg,
    gap: spacing.md,
  },
  actionButton: {
    borderRadius: components.button.borderRadius,
  },
  actionButtonContent: {
    minHeight: components.button.minHeight,
  },
  actionButtonLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
  },
  actionButtonLabelOutlined: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
  },

  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default FinanceiroResumoScreen;
