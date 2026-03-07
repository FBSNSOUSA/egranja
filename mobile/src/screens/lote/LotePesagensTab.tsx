/**
 * Aba Pesagens do detalhe do lote no eGranja.
 *
 * Exibe:
 * - Lista de pesagens (data decrescente)
 * - Card com: data, idade, qtd pesada, peso medio, peso padrao, desvio %, uniformidade CV%
 * - Botao "Enviar via WhatsApp" em cada card
 * - FAB "+" para nova pesagem
 * - Pull-to-refresh e paginacao infinita
 */

import React, { useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  RefreshControl,
  ActivityIndicator,
  Linking,
  Alert,
} from 'react-native';
import { IconButton } from 'react-native-paper';
import dayjs from 'dayjs';
import { useLoteStore, Pesagem } from '@stores/loteStore';
import { EmptyState } from '@components/EmptyState';
import { FABMenu } from '@components/FABMenu';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  getWeightIndicatorColor,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface LotePesagensTabProps {
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

export const LotePesagensTab: React.FC<LotePesagensTabProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  const {
    pesagens,
    isLoading,
    isLoadingMore,
    pagination,
    fetchPesagens,
    loteSelecionado,
  } = useLoteStore();

  // Carregar pesagens ao montar
  useEffect(() => {
    fetchPesagens(loteId, 1);
  }, [loteId, fetchPesagens]);

  // Pull-to-refresh
  const handleRefresh = useCallback(() => {
    fetchPesagens(loteId, 1);
  }, [loteId, fetchPesagens]);

  // Paginacao infinita
  const handleEndReached = useCallback(() => {
    if (!isLoadingMore && pagination && pagination.page < pagination.total_pages) {
      fetchPesagens(loteId, pagination.page + 1);
    }
  }, [loteId, isLoadingMore, pagination, fetchPesagens]);

  // Nova pesagem
  const handleNovaPesagem = useCallback(() => {
    navigation.navigate('NovaPesagem' as never, { loteId } as never);
  }, [navigation, loteId]);

  // Enviar via WhatsApp
  const handleWhatsApp = useCallback(
    (pesagem: Pesagem) => {
      const lote = loteSelecionado;
      const desvio = pesagem.desvioPct !== undefined
        ? `${pesagem.desvioPct >= 0 ? '+' : ''}${pesagem.desvioPct.toFixed(1)}%`
        : 'N/A';

      const mensagem =
        `*PESAGEM SEMANAL - eGranja*\n` +
        `Aviario: ${lote?.galpaoNome || ''}\n` +
        `Data: ${dayjs(pesagem.data).format('DD/MM/YYYY')} | Idade: ${pesagem.idade || '?'} dias\n\n` +
        `Aves pesadas: ${pesagem.quantidadeTotal}\n` +
        `*Peso medio:* ${pesagem.pesoMedio.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} g\n` +
        `Padrao ${lote?.linhagem || ''}: ${pesagem.pesoBenchmark?.toLocaleString('pt-BR', { maximumFractionDigits: 0 }) || 'N/A'} g\n` +
        `Diferenca: ${desvio}\n` +
        `Uniformidade: ${pesagem.uniformidadeCV?.toFixed(1) || 'N/A'}%`;

      const url = `whatsapp://send?text=${encodeURIComponent(mensagem)}`;
      Linking.canOpenURL(url).then((supported) => {
        if (supported) {
          Linking.openURL(url);
        } else {
          Linking.openURL(`https://api.whatsapp.com/send?text=${encodeURIComponent(mensagem)}`);
        }
      });
    },
    [loteSelecionado],
  );

  // Renderizar card de pesagem
  const renderItem = useCallback(
    ({ item }: { item: Pesagem }) => {
      const pesoColor = item.pesoBenchmark
        ? getWeightIndicatorColor(item.pesoMedio, item.pesoBenchmark)
        : colors.text;

      return (
        <View style={styles.card}>
          {/* Cabecalho do card */}
          <View style={styles.cardHeader}>
            <View>
              <Text style={styles.cardData}>
                {dayjs(item.data).format('DD/MM/YYYY')}
              </Text>
              {item.idade !== undefined && (
                <Text style={styles.cardIdade}>{item.idade} dias de idade</Text>
              )}
            </View>
            <IconButton
              icon="whatsapp"
              iconColor={colors.success}
              size={24}
              onPress={() => handleWhatsApp(item)}
              style={styles.whatsappButton}
            />
          </View>

          {/* Dados */}
          <View style={styles.cardBody}>
            <View style={styles.cardRow}>
              <Text style={styles.cardLabel}>Aves pesadas</Text>
              <Text style={styles.cardValue}>
                {item.quantidadeTotal.toLocaleString('pt-BR')}
              </Text>
            </View>
            <View style={styles.cardRow}>
              <Text style={styles.cardLabel}>Peso medio</Text>
              <Text style={[styles.cardValueBold, { color: pesoColor }]}>
                {item.pesoMedio.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} g
              </Text>
            </View>
            {item.pesoBenchmark !== undefined && (
              <View style={styles.cardRow}>
                <Text style={styles.cardLabel}>Peso padrao</Text>
                <Text style={styles.cardValue}>
                  {item.pesoBenchmark.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} g
                </Text>
              </View>
            )}
            {item.desvioPct !== undefined && (
              <View style={styles.cardRow}>
                <Text style={styles.cardLabel}>Desvio</Text>
                <Text style={[styles.cardValue, { color: pesoColor }]}>
                  {item.desvioPct >= 0 ? '+' : ''}{item.desvioPct.toFixed(1)}%
                </Text>
              </View>
            )}
            {item.uniformidadeCV !== undefined && (
              <View style={styles.cardRow}>
                <Text style={styles.cardLabel}>Uniformidade CV%</Text>
                <Text style={styles.cardValue}>
                  {item.uniformidadeCV.toFixed(1)}%
                </Text>
              </View>
            )}
          </View>
        </View>
      );
    },
    [handleWhatsApp],
  );

  // Footer de loading
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
        data={pesagens}
        keyExtractor={(item) => item.id}
        renderItem={renderItem}
        refreshControl={
          <RefreshControl
            refreshing={isLoading && pesagens.length > 0}
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
              icon="scale"
              titulo="Nenhuma pesagem registrada"
              descricao="Registre a primeira pesagem para acompanhar a evolucao de peso do lote."
              actionLabel="Nova Pesagem"
              actionIcon="plus"
              onAction={handleNovaPesagem}
            />
          )
        }
        contentContainerStyle={
          pesagens.length === 0 ? styles.emptyList : styles.list
        }
        showsVerticalScrollIndicator={false}
      />

      {pesagens.length > 0 && (
        <FABMenu
          actions={[{ label: 'Nova Pesagem', icon: 'plus', onPress: handleNovaPesagem }]}
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
    alignItems: 'flex-start',
    marginBottom: spacing.sm,
  },
  cardData: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  cardIdade: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },
  whatsappButton: {
    margin: 0,
    padding: 0,
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
  cardValueBold: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
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

export default LotePesagensTab;
