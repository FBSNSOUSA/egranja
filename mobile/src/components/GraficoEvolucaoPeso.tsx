/**
 * Grafico de evolucao de peso real vs benchmark da linhagem.
 *
 * Exibe LineChart com duas linhas:
 * - Linha azul: peso real do lote (baseado em pesagens)
 * - Linha verde tracejada: peso padrao da linhagem (Cobb 500, Ross 308)
 *
 * Usado na aba Resumo do detalhe do lote.
 */

import React, { useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  Dimensions,
  ScrollView,
} from 'react-native';
import { LineChart } from 'react-native-chart-kit';
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

interface PontoGrafico {
  label: string;
  valor: number;
}

interface GraficoEvolucaoPesoProps {
  /** Dados reais de peso (por pesagem) */
  pesoReal: PontoGrafico[];
  /** Dados do benchmark da linhagem */
  pesoBenchmark: PontoGrafico[];
  /** Nome da linhagem para legenda */
  linhagem?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

const screenWidth = Dimensions.get('window').width;

export const GraficoEvolucaoPeso: React.FC<GraficoEvolucaoPesoProps> = ({
  pesoReal,
  pesoBenchmark,
  linhagem = 'Linhagem',
}) => {
  const chartData = useMemo(() => {
    if (pesoReal.length === 0 && pesoBenchmark.length === 0) {
      return null;
    }

    // Pegar labels dos dados reais ou benchmark (o que tiver mais pontos)
    const labels = pesoReal.length >= pesoBenchmark.length
      ? pesoReal.map((p) => p.label)
      : pesoBenchmark.map((p) => p.label);

    const datasets = [];

    // Dados reais
    if (pesoReal.length > 0) {
      datasets.push({
        data: pesoReal.map((p) => p.valor),
        color: (opacity = 1) => `rgba(21, 101, 192, ${opacity})`, // Azul
        strokeWidth: 3,
      });
    }

    // Benchmark
    if (pesoBenchmark.length > 0) {
      datasets.push({
        data: pesoBenchmark.map((p) => p.valor),
        color: (opacity = 1) => `rgba(46, 125, 50, ${opacity})`, // Verde
        strokeWidth: 2,
      });
    }

    return { labels, datasets };
  }, [pesoReal, pesoBenchmark]);

  if (!chartData) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>
          Sem dados de pesagem para exibir o grafico.
        </Text>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.titulo}>Evolucao de Peso</Text>

      {/* Legenda */}
      <View style={styles.legenda}>
        <View style={styles.legendaItem}>
          <View style={[styles.legendaDot, { backgroundColor: colors.secondary }]} />
          <Text style={styles.legendaText}>Peso Real (g)</Text>
        </View>
        <View style={styles.legendaItem}>
          <View style={[styles.legendaDot, { backgroundColor: colors.success }]} />
          <Text style={styles.legendaText}>{linhagem}</Text>
        </View>
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        <LineChart
          data={{
            labels: chartData.labels,
            datasets: chartData.datasets,
          }}
          width={Math.max(screenWidth - spacing.xxl * 2, chartData.labels.length * 60)}
          height={220}
          chartConfig={{
            ...chartConfig,
            decimalCount: 0,
          }}
          bezier
          style={styles.chart}
          withDots
          withInnerLines
          withOuterLines
          withVerticalLabels
          withHorizontalLabels
          fromZero
          yAxisSuffix="g"
        />
      </ScrollView>
    </View>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginVertical: spacing.sm,
    ...shadows.small,
  },
  titulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  legenda: {
    flexDirection: 'row',
    justifyContent: 'center',
    gap: spacing.xl,
    marginBottom: spacing.md,
  },
  legendaItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  legendaDot: {
    width: 12,
    height: 12,
    borderRadius: 6,
  },
  legendaText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
  },
  chart: {
    borderRadius: borders.radiusM,
  },
  emptyContainer: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.xxl,
    alignItems: 'center',
    ...shadows.small,
  },
  emptyText: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    textAlign: 'center',
  },
});

export default GraficoEvolucaoPeso;
