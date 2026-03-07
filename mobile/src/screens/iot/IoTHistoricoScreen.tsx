/**
 * Tela de Historico dos Sensores IoT do eGranja.
 *
 * Funcionalidades:
 * - Graficos de evolucao dos sensores (LineChart)
 * - Selecao de sensor (Temperatura/Umidade/CO2/Amonia) via SegmentedButtons
 * - Selecao de periodo (24h/7d/30d) via SegmentedButtons
 * - Linhas de referencia do range ideal (area verde translucida)
 * - Tabela de max/min/media abaixo do grafico
 * - Pull-to-refresh
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  ActivityIndicator,
  Dimensions,
} from 'react-native';
import { Appbar, SegmentedButtons, IconButton } from 'react-native-paper';
import { useNavigation, useRoute } from '@react-navigation/native';
import { LineChart } from 'react-native-chart-kit';
import dayjs from 'dayjs';
import { apiGet } from '@services/api';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  chartConfig,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface HistoricoDataPoint {
  timestamp: string;
  valor: number;
}

interface HistoricoResponse {
  sensor: string;
  periodo: string;
  dados: HistoricoDataPoint[];
  estatisticas: {
    minimo: number;
    maximo: number;
    media: number;
  };
  range_ideal: {
    min: number;
    max: number;
  };
}

// ==========================================
// CONFIGURACOES
// ==========================================

const SENSORES = [
  { value: 'temperatura', label: 'Temp' },
  { value: 'umidade', label: 'Umid' },
  { value: 'co2', label: 'CO\u2082' },
  { value: 'amonia', label: 'NH\u2083' },
];

const PERIODOS = [
  { value: '24h', label: '24h' },
  { value: '7d', label: '7 dias' },
  { value: '30d', label: '30 dias' },
];

const SENSOR_UNIDADES: Record<string, string> = {
  temperatura: '\u00B0C',
  umidade: '%',
  co2: 'ppm',
  amonia: 'ppm',
};

const SENSOR_ICONES: Record<string, string> = {
  temperatura: 'thermometer',
  umidade: 'water-percent',
  co2: 'molecule-co2',
  amonia: 'chemical-weapon',
};

const screenWidth = Dimensions.get('window').width;

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================

const IoTHistoricoScreen: React.FC = () => {
  const navigation = useNavigation();
  const route = useRoute<any>();
  const galpaoId = route.params?.galpaoId || '';

  const [sensorSelecionado, setSensorSelecionado] = useState('temperatura');
  const [periodoSelecionado, setPeriodoSelecionado] = useState('24h');
  const [historico, setHistorico] = useState<HistoricoResponse | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  // Carregar historico
  const carregarHistorico = useCallback(async () => {
    if (!galpaoId) return;
    try {
      const response = await apiGet<HistoricoResponse>(
        `/galpoes/${galpaoId}/iot/historico`,
        { sensor: sensorSelecionado, periodo: periodoSelecionado },
      );
      setHistorico(response.data);
    } catch {
      setHistorico(null);
    } finally {
      setIsLoading(false);
      setRefreshing(false);
    }
  }, [galpaoId, sensorSelecionado, periodoSelecionado]);

  useEffect(() => {
    setIsLoading(true);
    carregarHistorico();
  }, [carregarHistorico]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    carregarHistorico();
  }, [carregarHistorico]);

  // Preparar dados do grafico
  const chartData = historico && historico.dados.length > 0
    ? {
        labels: historico.dados
          .filter((_, i) => i % Math.max(1, Math.floor(historico.dados.length / 6)) === 0)
          .map((d) => {
            if (periodoSelecionado === '24h') {
              return dayjs(d.timestamp).format('HH:mm');
            }
            return dayjs(d.timestamp).format('DD/MM');
          }),
        datasets: [
          {
            data: historico.dados.map((d) => d.valor),
            color: () => colors.secondary,
            strokeWidth: 2,
          },
        ],
      }
    : null;

  const unidade = SENSOR_UNIDADES[sensorSelecionado] || '';

  // Formatador de valor
  const formatarValor = (valor: number): string => {
    return valor.toFixed(1).replace('.', ',');
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
        <Appbar.Content
          title="Historico Sensores"
          titleStyle={styles.headerTitle}
          color={colors.textOnPrimary}
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
        {/* Seletor de sensor */}
        <Text style={styles.seletorLabel}>Sensor</Text>
        <SegmentedButtons
          value={sensorSelecionado}
          onValueChange={setSensorSelecionado}
          buttons={SENSORES}
          style={styles.segmented}
        />

        {/* Seletor de periodo */}
        <Text style={styles.seletorLabel}>Periodo</Text>
        <SegmentedButtons
          value={periodoSelecionado}
          onValueChange={setPeriodoSelecionado}
          buttons={PERIODOS}
          style={styles.segmented}
        />

        {/* Loading */}
        {isLoading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color={colors.primary} />
            <Text style={styles.loadingText}>Carregando dados...</Text>
          </View>
        ) : !chartData ? (
          <View style={styles.emptyContainer}>
            <IconButton icon={SENSOR_ICONES[sensorSelecionado] || 'chart-line'} iconColor={colors.gray400} size={48} />
            <Text style={styles.emptyTitulo}>Sem dados para o periodo</Text>
            <Text style={styles.emptyTexto}>
              Nao ha leituras do sensor de {sensorSelecionado} para o periodo selecionado.
            </Text>
          </View>
        ) : (
          <>
            {/* Grafico */}
            <View style={styles.chartContainer}>
              <Text style={styles.chartTitulo}>
                <IconButton
                  icon={SENSOR_ICONES[sensorSelecionado] || 'chart-line'}
                  iconColor={colors.secondary}
                  size={18}
                  style={styles.chartTituloIcone}
                />
                {' '}Evolucao - {SENSORES.find(s => s.value === sensorSelecionado)?.label} ({unidade})
              </Text>

              <LineChart
                data={chartData}
                width={screenWidth - spacing.lg * 2 - spacing.md * 2}
                height={220}
                chartConfig={{
                  ...chartConfig,
                  color: () => colors.secondary,
                  decimalCount: 1,
                }}
                bezier
                style={styles.chart}
                withDots
                withInnerLines
                withOuterLines
                fromZero={false}
                yAxisSuffix={` ${unidade}`}
              />

              {/* Range ideal */}
              {historico?.range_ideal && (
                <View style={styles.rangeContainer}>
                  <View style={styles.rangeLegenda}>
                    <View style={styles.rangeLegendaDot} />
                    <Text style={styles.rangeLegendaText}>
                      Range ideal: {formatarValor(historico.range_ideal.min)} - {formatarValor(historico.range_ideal.max)} {unidade}
                    </Text>
                  </View>
                </View>
              )}
            </View>

            {/* Tabela de estatisticas */}
            {historico?.estatisticas && (
              <View style={styles.estatisticasContainer}>
                <Text style={styles.estatisticasTitulo}>Estatisticas do periodo</Text>
                <View style={styles.estatisticasGrid}>
                  <View style={styles.estatisticaItem}>
                    <IconButton icon="arrow-down" iconColor={colors.secondary} size={20} style={styles.estatisticaIcone} />
                    <Text style={styles.estatisticaLabel}>Minimo</Text>
                    <Text style={styles.estatisticaValor}>
                      {formatarValor(historico.estatisticas.minimo)} {unidade}
                    </Text>
                  </View>
                  <View style={[styles.estatisticaItem, styles.estatisticaItemCenter]}>
                    <IconButton icon="approximately-equal" iconColor={colors.secondary} size={20} style={styles.estatisticaIcone} />
                    <Text style={styles.estatisticaLabel}>Media</Text>
                    <Text style={styles.estatisticaValor}>
                      {formatarValor(historico.estatisticas.media)} {unidade}
                    </Text>
                  </View>
                  <View style={styles.estatisticaItem}>
                    <IconButton icon="arrow-up" iconColor={colors.danger} size={20} style={styles.estatisticaIcone} />
                    <Text style={styles.estatisticaLabel}>Maximo</Text>
                    <Text style={styles.estatisticaValor}>
                      {formatarValor(historico.estatisticas.maximo)} {unidade}
                    </Text>
                  </View>
                </View>
              </View>
            )}
          </>
        )}
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

  // Seletores
  seletorLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
    marginTop: spacing.md,
  },
  segmented: {
    marginBottom: spacing.sm,
  },

  // Loading
  loadingContainer: {
    paddingVertical: spacing.huge,
    alignItems: 'center',
    gap: spacing.md,
  },
  loadingText: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },

  // Empty
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: spacing.huge,
  },
  emptyTitulo: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  emptyTexto: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    textAlign: 'center',
  },

  // Grafico
  chartContainer: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.md,
    marginTop: spacing.lg,
    ...shadows.medium,
  },
  chartTitulo: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
  },
  chartTituloIcone: {
    margin: 0,
    padding: 0,
  },
  chart: {
    borderRadius: borders.radiusL,
  },
  rangeContainer: {
    marginTop: spacing.sm,
    paddingTop: spacing.sm,
    borderTopWidth: borders.widthThin,
    borderTopColor: colors.divider,
  },
  rangeLegenda: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  rangeLegendaDot: {
    width: 12,
    height: 12,
    borderRadius: 2,
    backgroundColor: colors.success + '40',
    borderWidth: 1,
    borderColor: colors.success,
    marginRight: spacing.sm,
  },
  rangeLegendaText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },

  // Estatisticas
  estatisticasContainer: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginTop: spacing.lg,
    ...shadows.small,
  },
  estatisticasTitulo: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.lg,
  },
  estatisticasGrid: {
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  estatisticaItem: {
    flex: 1,
    alignItems: 'center',
  },
  estatisticaItemCenter: {
    borderLeftWidth: borders.widthThin,
    borderRightWidth: borders.widthThin,
    borderColor: colors.divider,
  },
  estatisticaIcone: {
    margin: 0,
    padding: 0,
    marginBottom: spacing.xs,
  },
  estatisticaLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  estatisticaValor: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
});

export default IoTHistoricoScreen;
