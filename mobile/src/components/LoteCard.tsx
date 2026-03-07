/**
 * Card de lote para a tela Home do eGranja.
 *
 * Exibe resumo de um lote ativo com indicadores visuais:
 * - Nome do aviario (galpao), data alojamento, dias de vida
 * - Tipo (Femea/Macho/Misto) e linhagem
 * - Aves vivas (quantidade original - mortalidade acumulada)
 * - Ultimo peso medio com indicador visual (verde/amarelo/vermelho vs benchmark)
 * - Mortalidade recente (ex: "5 mortes ontem - 0,03%")
 * - Badge de alerta se mortalidade diaria > 0,5% ou peso < 90% do padrao
 *
 * Toque no card navega para "Detalhes do Lote".
 */

import React, { useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  TouchableOpacity,
} from 'react-native';
import { Badge, IconButton } from 'react-native-paper';
import dayjs from 'dayjs';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  getWeightIndicatorColor,
  getMortalityIndicatorColor,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

export interface LoteCardData {
  /** ID do lote */
  id: string;
  /** Nome do galpao/aviario */
  galpaoNome: string;
  /** Data de alojamento (ISO string) */
  dataAlojamento: string;
  /** Tipo de lote */
  tipo: 'Femea' | 'Macho' | 'Misto';
  /** Linhagem (ex: 'Cobb 500', 'Ross 308') */
  linhagem?: string;
  /** Quantidade original alojada */
  quantidadeOriginal: number;
  /** Total de mortalidade acumulada */
  mortalidadeAcumulada: number;
  /** Ultimo peso medio registrado (gramas) */
  ultimoPesoMedio?: number;
  /** Peso padrao da linhagem para a idade atual (gramas) */
  pesoBenchmark?: number;
  /** Quantidade de mortes recentes (ex: ontem) */
  mortesRecentes?: number;
  /** Data das mortes recentes (ISO string) */
  dataMortesRecentes?: string;
  /** Percentual de mortalidade recente */
  mortalidadeRecentePct?: number;
  /** Indica se ha alerta ativo no lote */
  temAlerta?: boolean;
  /** Quantidade de alertas ativos */
  quantidadeAlertas?: number;
}

interface LoteCardProps {
  /** Dados do lote para exibicao */
  lote: LoteCardData;
  /** Callback ao tocar no card (navega para detalhes) */
  onPress: (loteId: string) => void;
}

// ==========================================
// COMPONENTE
// ==========================================

export const LoteCard: React.FC<LoteCardProps> = ({ lote, onPress }) => {
  // Calculos derivados
  const diasDeVida = useMemo(() => {
    const alojamento = dayjs(lote.dataAlojamento);
    return dayjs().diff(alojamento, 'day');
  }, [lote.dataAlojamento]);

  const avesVivas = useMemo(() => {
    return lote.quantidadeOriginal - lote.mortalidadeAcumulada;
  }, [lote.quantidadeOriginal, lote.mortalidadeAcumulada]);

  const mortalidadeAcumuladaPct = useMemo(() => {
    if (lote.quantidadeOriginal <= 0) return 0;
    return (lote.mortalidadeAcumulada / lote.quantidadeOriginal) * 100;
  }, [lote.mortalidadeAcumulada, lote.quantidadeOriginal]);

  // Cor do indicador de peso vs benchmark
  const pesoIndicatorColor = useMemo(() => {
    if (!lote.ultimoPesoMedio || !lote.pesoBenchmark) return colors.gray500;
    return getWeightIndicatorColor(lote.ultimoPesoMedio, lote.pesoBenchmark);
  }, [lote.ultimoPesoMedio, lote.pesoBenchmark]);

  // Percentual de desvio do peso vs benchmark
  const pesoDesvioPct = useMemo(() => {
    if (!lote.ultimoPesoMedio || !lote.pesoBenchmark || lote.pesoBenchmark <= 0) return null;
    return ((lote.ultimoPesoMedio / lote.pesoBenchmark) * 100 - 100);
  }, [lote.ultimoPesoMedio, lote.pesoBenchmark]);

  // Cor do indicador de mortalidade recente
  const mortalidadeIndicatorColor = useMemo(() => {
    if (lote.mortalidadeRecentePct === undefined) return colors.gray500;
    return getMortalityIndicatorColor(lote.mortalidadeRecentePct);
  }, [lote.mortalidadeRecentePct]);

  // Formatar mortalidade recente
  const mortalidadeRecenteText = useMemo(() => {
    if (!lote.mortesRecentes || lote.mortesRecentes === 0) return null;
    const pctText = lote.mortalidadeRecentePct !== undefined
      ? ` - ${lote.mortalidadeRecentePct.toFixed(2)}%`
      : '';
    const dataText = lote.dataMortesRecentes
      ? dayjs(lote.dataMortesRecentes).format('DD/MM')
      : 'recente';
    return `${lote.mortesRecentes} morte(s) em ${dataText}${pctText}`;
  }, [lote.mortesRecentes, lote.mortalidadeRecentePct, lote.dataMortesRecentes]);

  return (
    <TouchableOpacity
      style={styles.container}
      onPress={() => onPress(lote.id)}
      activeOpacity={0.7}
      accessibilityRole="button"
      accessibilityLabel={`Lote ${lote.galpaoNome}, ${diasDeVida} dias de vida, ${avesVivas} aves vivas`}
    >
      {/* Badge de alerta */}
      {lote.temAlerta && (
        <View style={styles.alertBadgeContainer}>
          <Badge
            size={24}
            style={styles.alertBadge}
          >
            {lote.quantidadeAlertas || '!'}
          </Badge>
        </View>
      )}

      {/* Cabecalho: nome do galpao + tipo/linhagem */}
      <View style={styles.header}>
        <View style={styles.headerLeft}>
          <Text style={styles.galpaoNome} numberOfLines={1}>
            {lote.galpaoNome}
          </Text>
          <View style={styles.tagsRow}>
            <View style={styles.tag}>
              <Text style={styles.tagText}>{lote.tipo}</Text>
            </View>
            {lote.linhagem && (
              <View style={[styles.tag, styles.tagLinhagem]}>
                <Text style={styles.tagText}>{lote.linhagem}</Text>
              </View>
            )}
          </View>
        </View>
        <View style={styles.headerRight}>
          <Text style={styles.diasVida}>{diasDeVida}</Text>
          <Text style={styles.diasVidaLabel}>dias</Text>
        </View>
      </View>

      {/* Data de alojamento */}
      <Text style={styles.dataAlojamento}>
        Alojamento: {dayjs(lote.dataAlojamento).format('DD/MM/YYYY')}
      </Text>

      {/* Separador */}
      <View style={styles.divider} />

      {/* Indicadores */}
      <View style={styles.indicatorsRow}>
        {/* Aves vivas */}
        <View style={styles.indicator}>
          <Text style={styles.indicatorLabel}>Aves vivas</Text>
          <Text style={styles.indicatorValue}>
            {avesVivas.toLocaleString('pt-BR')}
          </Text>
          <Text style={styles.indicatorSub}>
            {mortalidadeAcumuladaPct.toFixed(1)}% mortalidade
          </Text>
        </View>

        {/* Ultimo peso medio */}
        <View style={styles.indicator}>
          <Text style={styles.indicatorLabel}>Peso medio</Text>
          {lote.ultimoPesoMedio ? (
            <>
              <View style={styles.pesoRow}>
                <View
                  style={[
                    styles.pesoIndicatorDot,
                    { backgroundColor: pesoIndicatorColor },
                  ]}
                />
                <Text style={[styles.indicatorValue, { color: pesoIndicatorColor }]}>
                  {lote.ultimoPesoMedio.toLocaleString('pt-BR', {
                    maximumFractionDigits: 0,
                  })}g
                </Text>
              </View>
              {pesoDesvioPct !== null && (
                <Text
                  style={[
                    styles.indicatorSub,
                    { color: pesoIndicatorColor },
                  ]}
                >
                  {pesoDesvioPct >= 0 ? '+' : ''}{pesoDesvioPct.toFixed(1)}% vs padrao
                </Text>
              )}
            </>
          ) : (
            <Text style={styles.indicatorValueMuted}>Sem registro</Text>
          )}
        </View>
      </View>

      {/* Mortalidade recente */}
      {mortalidadeRecenteText && (
        <View style={styles.mortalidadeRow}>
          <IconButton
            icon="alert-circle-outline"
            iconColor={mortalidadeIndicatorColor}
            size={18}
            style={styles.mortalidadeIcon}
          />
          <Text
            style={[
              styles.mortalidadeText,
              { color: mortalidadeIndicatorColor },
            ]}
          >
            {mortalidadeRecenteText}
          </Text>
        </View>
      )}
    </TouchableOpacity>
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
    marginHorizontal: spacing.lg,
    marginVertical: spacing.sm,
    ...shadows.medium,
    position: 'relative',
  },

  // Badge de alerta
  alertBadgeContainer: {
    position: 'absolute',
    top: -8,
    right: -4,
    zIndex: 10,
  },
  alertBadge: {
    backgroundColor: colors.danger,
    color: colors.white,
    fontWeight: typography.fontWeightBold,
    fontSize: typography.fontSizeXS,
  },

  // Cabecalho
  header: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'flex-start',
    marginBottom: spacing.xs,
  },
  headerLeft: {
    flex: 1,
    marginRight: spacing.md,
  },
  headerRight: {
    alignItems: 'center',
    minWidth: 50,
  },
  galpaoNome: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.xs,
  },
  diasVida: {
    fontSize: typography.fontSizeXXL,
    fontWeight: typography.fontWeightBold,
    color: colors.primary,
    lineHeight: typography.fontSizeXXL * 1.1,
  },
  diasVidaLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
  },

  // Tags (tipo + linhagem)
  tagsRow: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.xs,
  },
  tag: {
    backgroundColor: colors.gray200,
    borderRadius: borders.radiusS,
    paddingHorizontal: spacing.sm,
    paddingVertical: 2,
  },
  tagLinhagem: {
    backgroundColor: colors.secondaryLight + '30', // 30% opacidade
  },
  tagText: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    color: colors.gray700,
  },

  // Data
  dataAlojamento: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },

  // Separador
  divider: {
    height: 1,
    backgroundColor: colors.divider,
    marginVertical: spacing.md,
  },

  // Indicadores
  indicatorsRow: {
    flexDirection: 'row',
    justifyContent: 'space-around',
  },
  indicator: {
    alignItems: 'center',
    flex: 1,
  },
  indicatorLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
    marginBottom: spacing.xs,
  },
  indicatorValue: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  indicatorValueMuted: {
    fontSize: typography.fontSizeS,
    color: colors.gray500,
    fontStyle: 'italic',
  },
  indicatorSub: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },

  // Peso com indicador colorido
  pesoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.xs,
  },
  pesoIndicatorDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
  },

  // Mortalidade recente
  mortalidadeRow: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.md,
    paddingTop: spacing.sm,
    borderTopWidth: 1,
    borderTopColor: colors.divider,
  },
  mortalidadeIcon: {
    margin: 0,
    padding: 0,
    marginRight: spacing.xs,
  },
  mortalidadeText: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    flex: 1,
  },
});

export default LoteCard;
