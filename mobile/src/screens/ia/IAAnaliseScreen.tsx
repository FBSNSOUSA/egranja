/**
 * Tela de Analise Proativa por IA do eGranja.
 *
 * Funcionalidades:
 * - Analise automatica dos indicadores do lote pela IA
 * - Secoes coloridas: Pontos Positivos (verde), Atencao (amarelo), Acoes Recomendadas (azul)
 * - Botao para gerar nova analise
 * - Loading skeleton enquanto carrega
 * - Seletor de lote
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  ActivityIndicator,
} from 'react-native';
import { Appbar, Button, IconButton, Card } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import dayjs from 'dayjs';
import { apiGet, apiPost } from '@services/api';
import { useLoteStore } from '@stores/loteStore';
import { DropdownField, DropdownOption } from '@components/DropdownField';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface AnaliseIA {
  id: string;
  gerada_em: string;
  pontos_positivos: string[];
  pontos_atencao: string[];
  acoes_recomendadas: string[];
  resumo: string;
}

// ==========================================
// COMPONENTE SKELETON
// ==========================================

const SkeletonBlock: React.FC<{ width?: string | number; height?: number }> = ({
  width = '100%',
  height = 20,
}) => (
  <View
    style={[
      styles.skeleton,
      {
        width: width as any,
        height,
      },
    ]}
  />
);

const SkeletonCard: React.FC = () => (
  <View style={styles.skeletonCard}>
    <SkeletonBlock width="60%" height={22} />
    <View style={styles.skeletonSpacer} />
    <SkeletonBlock width="100%" height={16} />
    <View style={styles.skeletonSpacerSm} />
    <SkeletonBlock width="90%" height={16} />
    <View style={styles.skeletonSpacerSm} />
    <SkeletonBlock width="80%" height={16} />
  </View>
);

// ==========================================
// COMPONENTE DE SECAO
// ==========================================

interface SecaoAnaliseProps {
  titulo: string;
  icone: string;
  cor: string;
  corFundo: string;
  itens: string[];
}

const SecaoAnalise: React.FC<SecaoAnaliseProps> = ({ titulo, icone, cor, corFundo, itens }) => {
  if (itens.length === 0) return null;

  return (
    <View style={[styles.secaoCard, { borderLeftColor: cor }]}>
      <View style={[styles.secaoHeader, { backgroundColor: corFundo }]}>
        <IconButton icon={icone} iconColor={cor} size={22} style={styles.secaoIcone} />
        <Text style={[styles.secaoTitulo, { color: cor }]}>{titulo}</Text>
      </View>
      <View style={styles.secaoConteudo}>
        {itens.map((item, index) => (
          <View key={index} style={styles.secaoItem}>
            <Text style={[styles.secaoBullet, { color: cor }]}>{'\u2022'}</Text>
            <Text style={styles.secaoTexto}>{item}</Text>
          </View>
        ))}
      </View>
    </View>
  );
};

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================

const IAAnaliseScreen: React.FC = () => {
  const navigation = useNavigation();
  const lotes = useLoteStore((state) => state.lotes);

  const [analise, setAnalise] = useState<AnaliseIA | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [isGerando, setIsGerando] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [loteId, setLoteId] = useState<string>(lotes[0]?.id || '');

  const lotesOptions: DropdownOption[] = lotes
    .filter((l) => l.status === 'ativo')
    .map((l) => ({
      value: l.id,
      label: `${l.galpaoNome} - Lote ${l.id.slice(0, 6)}`,
      subtitle: `${l.avesVivas || l.quantidade} aves | Dia ${l.diasDeVida || 0}`,
    }));

  // Carregar ultima analise
  const carregarAnalise = useCallback(async () => {
    if (!loteId) return;
    try {
      const response = await apiGet<AnaliseIA>(`/lotes/${loteId}/ia/analisar`);
      setAnalise(response.data);
    } catch {
      setAnalise(null);
    } finally {
      setIsLoading(false);
      setRefreshing(false);
    }
  }, [loteId]);

  useEffect(() => {
    setIsLoading(true);
    carregarAnalise();
  }, [carregarAnalise]);

  // Gerar nova analise
  const gerarNovaAnalise = useCallback(async () => {
    if (!loteId) return;
    setIsGerando(true);
    try {
      const response = await apiPost<AnaliseIA>(`/lotes/${loteId}/ia/analisar`);
      setAnalise(response.data);
    } catch {
      // Manter analise anterior se falhar
    } finally {
      setIsGerando(false);
    }
  }, [loteId]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    carregarAnalise();
  }, [carregarAnalise]);

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
        <Appbar.Content
          title="Analise IA"
          titleStyle={styles.headerTitle}
          color={colors.textOnPrimary}
        />
        <IconButton icon="brain" iconColor={colors.textOnPrimary} size={24} />
      </Appbar.Header>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[colors.secondary]}
          />
        }
      >
        {/* Seletor de lote */}
        {lotesOptions.length > 1 && (
          <View style={styles.seletorLote}>
            <DropdownField
              label="Lote"
              value={loteId}
              options={lotesOptions}
              onSelect={setLoteId}
              placeholder="Selecione o lote"
            />
          </View>
        )}

        {/* Loading skeleton */}
        {isLoading ? (
          <View style={styles.skeletonContainer}>
            <SkeletonCard />
            <SkeletonCard />
            <SkeletonCard />
          </View>
        ) : analise ? (
          <>
            {/* Card de resumo */}
            <View style={styles.resumoCard}>
              <View style={styles.resumoHeader}>
                <IconButton icon="robot" iconColor={colors.secondary} size={32} />
                <View style={styles.resumoHeaderTexto}>
                  <Text style={styles.resumoTitulo}>Analise do Lote</Text>
                  <Text style={styles.resumoData}>
                    Gerada em {dayjs(analise.gerada_em).format('DD/MM/YYYY [as] HH:mm')}
                  </Text>
                </View>
              </View>
              <Text style={styles.resumoTexto}>{analise.resumo}</Text>
            </View>

            {/* Secoes */}
            <SecaoAnalise
              titulo="Pontos Positivos"
              icone="check-circle"
              cor={colors.success}
              corFundo={colors.successLight}
              itens={analise.pontos_positivos}
            />

            <SecaoAnalise
              titulo="Pontos de Atencao"
              icone="alert"
              cor={colors.warning}
              corFundo={colors.warningLight}
              itens={analise.pontos_atencao}
            />

            <SecaoAnalise
              titulo="Acoes Recomendadas"
              icone="lightbulb-on"
              cor={colors.secondary}
              corFundo="#E3F2FD"
              itens={analise.acoes_recomendadas}
            />
          </>
        ) : (
          /* Sem analise */
          <View style={styles.semAnaliseContainer}>
            <IconButton icon="brain" iconColor={colors.gray400} size={64} />
            <Text style={styles.semAnaliseTitulo}>Nenhuma analise disponivel</Text>
            <Text style={styles.semAnaliseTexto}>
              Clique no botao abaixo para gerar uma analise completa dos indicadores do seu lote.
            </Text>
          </View>
        )}

        {/* Botao gerar nova analise */}
        <Button
          mode="contained"
          onPress={gerarNovaAnalise}
          loading={isGerando}
          disabled={isGerando || !loteId}
          icon="auto-fix"
          style={styles.botaoGerar}
          contentStyle={styles.botaoGerarContent}
          labelStyle={styles.botaoGerarLabel}
          buttonColor={colors.secondary}
          textColor={colors.textOnSecondary}
        >
          {isGerando ? 'Gerando analise...' : 'Gerar nova analise'}
        </Button>
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
    backgroundColor: colors.secondary,
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

  // Seletor de lote
  seletorLote: {
    marginBottom: spacing.md,
  },

  // Skeleton
  skeletonContainer: {
    gap: spacing.lg,
  },
  skeletonCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    ...shadows.small,
  },
  skeleton: {
    backgroundColor: colors.gray200,
    borderRadius: borders.radiusS,
  },
  skeletonSpacer: {
    height: spacing.md,
  },
  skeletonSpacerSm: {
    height: spacing.sm,
  },

  // Resumo
  resumoCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginBottom: spacing.lg,
    ...shadows.medium,
  },
  resumoHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  resumoHeaderTexto: {
    flex: 1,
    marginLeft: spacing.sm,
  },
  resumoTitulo: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  resumoData: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },
  resumoTexto: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    lineHeight: typography.fontSizeS * 1.5,
  },

  // Secoes
  secaoCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    marginBottom: spacing.lg,
    borderLeftWidth: 4,
    overflow: 'hidden',
    ...shadows.small,
  },
  secaoHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.sm,
  },
  secaoIcone: {
    margin: 0,
    padding: 0,
  },
  secaoTitulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    marginLeft: spacing.xs,
  },
  secaoConteudo: {
    padding: spacing.lg,
    paddingTop: spacing.sm,
  },
  secaoItem: {
    flexDirection: 'row',
    alignItems: 'flex-start',
    marginBottom: spacing.sm,
  },
  secaoBullet: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    marginRight: spacing.sm,
    lineHeight: typography.fontSizeS * 1.5,
  },
  secaoTexto: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    lineHeight: typography.fontSizeS * 1.5,
    flex: 1,
  },

  // Sem analise
  semAnaliseContainer: {
    alignItems: 'center',
    paddingVertical: spacing.huge,
  },
  semAnaliseTitulo: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  semAnaliseTexto: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    textAlign: 'center',
    lineHeight: typography.fontSizeS * 1.5,
    paddingHorizontal: spacing.xxl,
  },

  // Botao
  botaoGerar: {
    borderRadius: components.button.borderRadius,
    marginTop: spacing.md,
  },
  botaoGerarContent: {
    minHeight: components.button.minHeight,
  },
  botaoGerarLabel: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },
});

export default IAAnaliseScreen;
