/**
 * Grafico de mortalidade diaria e acumulada.
 *
 * Exibe BarChart com barras (mortalidade diaria) sobreposto
 * com linha (mortalidade acumulada).
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
import { BarChart, LineChart } from 'react-native-chart-kit';
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

interface GraficoMortalidadeProps {
  /** Mortalidade diaria (quantidade por dia) */
  mortalidadeDiaria: PontoGrafico[];
  /** Mortalidade acumulada */
  mortalidadeAcumulada: PontoGrafico[];
}

// ==========================================
// COMPONENTE
// ==========================================

const screenWidth = Dimensions.get('window').width;

export const GraficoMortalidade: React.FC<GraficoMortalidadeProps> = ({
  mortalidadeDiaria,
  mortalidadeAcumulada,
}) => {
  const hasData = mortalidadeDiaria.length > 0;

  const barData = useMemo(() => {
    if (!hasData) return null;
    return {
      labels: mortalidadeDiaria.map((p) => p.label),
      datasets: [
        {
          data: mortalidadeDiaria.map((p) => p.valor),
        },
      ],
    };
  }, [mortalidadeDiaria, hasData]);

  const lineData = useMemo(() => {
    if (mortalidadeAcumulada.length === 0) return null;
    return {
      labels: mortalidadeAcumulada.map((p) => p.label),
      datasets: [
        {
          data: mortalidadeAcumulada.map((p) => p.valor),
          color: (opacity = 1) => `rgba(211, 47, 47, ${opacity})`, // Vermelho
          strokeWidth: 2,
        },
      ],
    };
  }, [mortalidadeAcumulada]);

  if (!hasData) {
    return (
      <View style={styles.emptyContainer}>
        <Text style={styles.emptyText}>
          Sem registros de mortalidade para exibir.
        </Text>
      </View>
    );
  }

  const chartWidth = Math.max(screenWidth - spacing.xxl * 2, mortalidadeDiaria.length * 50);

  return (
    <View style={styles.container}>
      <Text style={styles.titulo}>Mortalidade</Text>

      {/* Legenda */}
      <View style={styles.legenda}>
        <View style={styles.legendaItem}>
          <View style={[styles.legendaDot, { backgroundColor: colors.secondary }]} />
          <Text style={styles.legendaText}>Diaria</Text>
        </View>
        <View style={styles.legendaItem}>
          <View style={[styles.legendaDot, { backgroundColor: colors.danger }]} />
          <Text style={styles.legendaText}>Acumulada</Text>
        </View>
      </View>

      <ScrollView horizontal showsHorizontalScrollIndicator={false}>
        <View>
          {/* Barras: mortalidade diaria */}
          {barData && (
            <BarChart
              data={barData}
              width={chartWidth}
              height={200}
              chartConfig={{
                ...chartConfig,
                decimalCount: 0,
                color: (opacity = 1) => `rgba(21, 101, 192, ${opacity})`,
              }}
              style={styles.chart}
              fromZero
              showValuesOnTopOfBars
              yAxisLabel=""
              yAxisSuffix=""
            />
          )}

          {/* Linha: mortalidade acumulada (sobreposta) */}
          {lineData && (
            <View style={styles.lineOverlay}>
              <LineChart
                data={lineData}
                width={chartWidth}
                height={200}
                chartConfig={{
                  ...chartConfig,
                  decimalCount: 0,
                  color: (opacity = 1) => `rgba(211, 47, 47, ${opacity})`,
                  backgroundGradientFrom: 'transparent',
                  backgroundGradientTo: 'transparent',
                  backgroundColor: 'transparent',
                }}
                bezier
                withDots
                withInnerLines={false}
                withOuterLines={false}
                withVerticalLabels={false}
                withHorizontalLabels={false}
                transparent
                style={styles.chart}
              />
            </View>
          )}
        </View>
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
  lineOverlay: {
    position: 'absolute',
    top: 0,
    left: 0,
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

export default GraficoMortalidade;
