/**
 * Aba Resumo (Dashboard) do detalhe do lote no eGranja.
 *
 * Exibe:
 * - Indicadores com cores semanticas (verde/amarelo/vermelho)
 * - Graficos: evolucao peso vs benchmark, mortalidade
 * - Projecao de peso ao abate
 * - Botao "Finalizar Lote" (se produtor)
 */

import React, { useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { Button } from 'react-native-paper';
import { useAuthStore } from '@stores/authStore';
import { useLoteStore } from '@stores/loteStore';
import { useIndicadoresStore, Indicadores } from '@stores/indicadoresStore';
import { IndicadorCard } from '@components/IndicadorCard';
import { GraficoEvolucaoPeso } from '@components/GraficoEvolucaoPeso';
import { GraficoMortalidade } from '@components/GraficoMortalidade';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  getWeightIndicatorColor,
  getMortalityIndicatorColor,
  getIEPClassification,
  getWaterFeedRatioColor,
  getIndicatorColor,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface LoteResumoTabProps {
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

export const LoteResumoTab: React.FC<LoteResumoTabProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  const user = useAuthStore((state) => state.user);
  const loteSelecionado = useLoteStore((state) => state.loteSelecionado);
  const isProdutor = user?.tipo === 'produtor';

  const {
    indicadores,
    dadosGraficoPeso,
    dadosGraficoMortalidade,
    isLoading,
    fetchIndicadores,
    fetchDadosGraficoPeso,
    fetchDadosGraficoMortalidade,
  } = useIndicadoresStore();

  // Carregar dados ao montar
  useEffect(() => {
    fetchIndicadores(loteId);
    fetchDadosGraficoPeso(loteId);
    fetchDadosGraficoMortalidade(loteId);
  }, [loteId, fetchIndicadores, fetchDadosGraficoPeso, fetchDadosGraficoMortalidade]);

  // Pull-to-refresh
  const handleRefresh = useCallback(() => {
    fetchIndicadores(loteId, true);
    fetchDadosGraficoPeso(loteId);
    fetchDadosGraficoMortalidade(loteId);
  }, [loteId, fetchIndicadores, fetchDadosGraficoPeso, fetchDadosGraficoMortalidade]);

  // Navegar para finalizar lote
  const handleFinalizarLote = useCallback(() => {
    navigation.navigate('FinalizarLote' as never, { loteId } as never);
  }, [navigation, loteId]);

  if (isLoading && !indicadores) {
    return (
      <View style={styles.loadingContainer}>
        <ActivityIndicator size="large" color={colors.primary} />
        <Text style={styles.loadingText}>Carregando indicadores...</Text>
      </View>
    );
  }

  if (!indicadores) {
    return (
      <View style={styles.loadingContainer}>
        <Text style={styles.loadingText}>Sem dados disponiveis.</Text>
      </View>
    );
  }

  const iepClass = getIEPClassification(indicadores.iep);
  const pesoColor = getWeightIndicatorColor(indicadores.ultimoPesoMedio, indicadores.pesoBenchmark);
  const mortColor = getMortalityIndicatorColor(indicadores.mortalidadeDiaPct);
  const aguaRacaoColor = getWaterFeedRatioColor(indicadores.relacaoAguaRacao);
  const icaColor = getIndicatorColor(indicadores.ica, { criticalAbove: 2.0, warningAbove: 1.8 });

  return (
    <ScrollView
      style={styles.container}
      contentContainerStyle={styles.scrollContent}
      refreshControl={
        <RefreshControl
          refreshing={isLoading}
          onRefresh={handleRefresh}
          colors={[colors.primary]}
        />
      }
      showsVerticalScrollIndicator={false}
    >
      {/* Linha 1: Dias, Aves Vivas, Mortalidade */}
      <View style={styles.indicadoresRow}>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="Dias de Vida"
            valor={String(indicadores.diasDeVida)}
            icone="calendar-clock"
            compacto
          />
        </View>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="Aves Vivas"
            valor={indicadores.avesVivas.toLocaleString('pt-BR')}
            subtitulo={`${indicadores.mortalidadeAcumuladaPct.toFixed(1)}% mort.`}
            cor={indicadores.mortalidadeAcumuladaPct > 3 ? colors.danger : colors.success}
            icone="bird"
            compacto
          />
        </View>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="Mort. Dia"
            valor={String(indicadores.mortalidadeDia)}
            subtitulo={`${indicadores.mortalidadeDiaPct.toFixed(2)}%`}
            cor={mortColor}
            icone="alert-circle"
            compacto
          />
        </View>
      </View>

      {/* Linha 2: Peso, GPD, ICA */}
      <View style={styles.indicadoresRow}>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="Peso Medio"
            valor={`${indicadores.ultimoPesoMedio.toLocaleString('pt-BR', { maximumFractionDigits: 0 })}g`}
            subtitulo={`${indicadores.pesoDesvioPct >= 0 ? '+' : ''}${indicadores.pesoDesvioPct.toFixed(1)}%`}
            cor={pesoColor}
            icone="scale"
            compacto
          />
        </View>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="GPD"
            valor={`${indicadores.gpd.toFixed(1)}g`}
            subtitulo="g/dia"
            icone="trending-up"
            compacto
          />
        </View>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="ICA"
            valor={indicadores.ica.toFixed(2)}
            cor={icaColor}
            icone="food-drumstick"
            compacto
          />
        </View>
      </View>

      {/* Linha 3: IEA, IEP, Viabilidade */}
      <View style={styles.indicadoresRow}>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="IEA"
            valor={indicadores.iea.toFixed(2)}
            icone="chart-line"
            compacto
          />
        </View>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="IEP"
            valor={indicadores.iep.toFixed(0)}
            subtitulo={iepClass.label}
            cor={iepClass.color}
            icone="star"
            compacto
          />
        </View>
        <View style={styles.indicadorWrapper}>
          <IndicadorCard
            label="Viabilidade"
            valor={`${indicadores.viabilidade.toFixed(1)}%`}
            icone="shield-check"
            cor={indicadores.viabilidade >= 95 ? colors.success : colors.warning}
            compacto
          />
        </View>
      </View>

      {/* Linha 4: Racao e Agua */}
      <View style={styles.indicadoresRow}>
        <View style={[styles.indicadorWrapper, { flex: 1 }]}>
          <IndicadorCard
            label="Saldo Racao"
            valor={`${indicadores.saldoRacao.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} kg`}
            subtitulo={`~${indicadores.diasRestantesRacao} dias`}
            cor={indicadores.diasRestantesRacao < 2 ? colors.danger : colors.success}
            icone="sack"
          />
        </View>
        <View style={[styles.indicadorWrapper, { flex: 1 }]}>
          <IndicadorCard
            label="Agua/Racao"
            valor={indicadores.relacaoAguaRacao.toFixed(1)}
            subtitulo={`${indicadores.consumoAguaPorAve.toFixed(0)} mL/ave`}
            cor={aguaRacaoColor}
            icone="water"
          />
        </View>
      </View>

      {/* Grafico de peso */}
      {dadosGraficoPeso && (
        <GraficoEvolucaoPeso
          pesoReal={dadosGraficoPeso.pesoReal}
          pesoBenchmark={dadosGraficoPeso.pesoBenchmark}
          linhagem={loteSelecionado?.linhagem || 'Benchmark'}
        />
      )}

      {/* Grafico de mortalidade */}
      {dadosGraficoMortalidade && (
        <GraficoMortalidade
          mortalidadeDiaria={dadosGraficoMortalidade.mortalidadeDiaria}
          mortalidadeAcumulada={dadosGraficoMortalidade.mortalidadeAcumulada}
        />
      )}

      {/* Projecao */}
      {indicadores.projecaoTexto && (
        <View style={styles.projecaoCard}>
          <Text style={styles.projecaoTitulo}>Projecao</Text>
          <Text style={styles.projecaoTexto}>{indicadores.projecaoTexto}</Text>
        </View>
      )}

      {/* Botao Finalizar Lote */}
      {isProdutor && loteSelecionado?.status === 'ativo' && (
        <Button
          mode="outlined"
          onPress={handleFinalizarLote}
          style={styles.finalizarButton}
          contentStyle={styles.finalizarButtonContent}
          labelStyle={styles.finalizarButtonLabel}
          textColor={colors.danger}
          icon="check-circle"
        >
          Finalizar Lote
        </Button>
      )}
    </ScrollView>
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
  scrollContent: {
    padding: spacing.md,
    paddingBottom: spacing.huge,
  },

  // Indicadores
  indicadoresRow: {
    flexDirection: 'row',
    gap: spacing.sm,
    marginBottom: spacing.sm,
  },
  indicadorWrapper: {
    flex: 1,
  },

  // Projecao
  projecaoCard: {
    backgroundColor: colors.secondaryLight + '20',
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginVertical: spacing.sm,
    borderLeftWidth: 4,
    borderLeftColor: colors.secondary,
  },
  projecaoTitulo: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.secondary,
    marginBottom: spacing.xs,
  },
  projecaoTexto: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    lineHeight: typography.fontSizeS * 1.5,
  },

  // Finalizar
  finalizarButton: {
    marginTop: spacing.xl,
    borderColor: colors.danger,
    borderWidth: 2,
    borderRadius: components.button.borderRadius,
  },
  finalizarButtonContent: {
    minHeight: components.button.minHeight,
  },
  finalizarButtonLabel: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },

  // Loading
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: colors.background,
  },
  loadingText: {
    marginTop: spacing.md,
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
});

export default LoteResumoTab;
