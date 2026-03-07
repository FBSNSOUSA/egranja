/**
 * Tela de listagem de vacinacoes do lote no eGranja.
 *
 * Funcionalidades:
 * - Cards com: data, vacina, lote produto, via, responsavel
 * - FAB "+" para nova vacinacao
 * - Calendario visual com proximas vacinacoes
 * - Pull-to-refresh
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
} from 'react-native';
import { Appbar, IconButton, Chip, Divider, Snackbar } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import dayjs from 'dayjs';
import { apiGet } from '@services/api';
import { EmptyState } from '@components/EmptyState';
import { FABMenu } from '@components/FABMenu';
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

interface Vacinacao {
  id: string;
  data: string;
  vacina: string;
  lote_produto: string;
  via_administracao: string;
  responsavel: string;
  observacao?: string;
}

interface ProximaVacinacao {
  vacina: string;
  data_prevista: string;
  idade_dias: number;
}

interface VacinacoesRouteParams {
  loteId: string;
  loteNome?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

const VacinacoesScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ Vacinacoes: VacinacoesRouteParams }, 'Vacinacoes'>>();
  const { loteId, loteNome } = route.params;

  const [vacinacoes, setVacinacoes] = useState<Vacinacao[]>([]);
  const [proximasVacinacoes, setProximasVacinacoes] = useState<ProximaVacinacao[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const carregarVacinacoes = useCallback(async () => {
    try {
      const [vacResponse, proxResponse] = await Promise.all([
        apiGet<Vacinacao[]>(`/lotes/${loteId}/vacinacoes`),
        apiGet<ProximaVacinacao[]>(`/lotes/${loteId}/vacinacoes/proximas`),
      ]);
      setVacinacoes(vacResponse.data);
      setProximasVacinacoes(proxResponse.data);
    } catch (error) {
      console.error('[Vacinacoes] Erro ao carregar:', error);
    } finally {
      setLoading(false);
    }
  }, [loteId]);

  useEffect(() => {
    carregarVacinacoes();
  }, [carregarVacinacoes]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarVacinacoes();
    setRefreshing(false);
  }, [carregarVacinacoes]);

  const renderProximasVacinacoes = useCallback(() => {
    if (proximasVacinacoes.length === 0) return null;

    return (
      <View style={styles.calendarioContainer}>
        <Text style={styles.calendarioTitulo}>Proximas Vacinacoes</Text>
        {proximasVacinacoes.map((prox, index) => {
          const diasPara = dayjs(prox.data_prevista).diff(dayjs(), 'day');
          const isProxima = diasPara <= 3;

          return (
            <View key={index} style={styles.calendarioItem}>
              <View style={styles.calendarioData}>
                <Text style={styles.calendarioDia}>
                  {dayjs(prox.data_prevista).format('DD')}
                </Text>
                <Text style={styles.calendarioMes}>
                  {dayjs(prox.data_prevista).format('MMM')}
                </Text>
              </View>

              <View style={styles.calendarioInfo}>
                <Text style={styles.calendarioVacina}>{prox.vacina}</Text>
                <Text style={styles.calendarioIdade}>
                  {prox.idade_dias} dias de vida
                </Text>
              </View>

              {isProxima && (
                <Chip
                  mode="flat"
                  style={styles.proximaChip}
                  textStyle={styles.proximaChipText}
                >
                  {diasPara === 0 ? 'Hoje' : diasPara === 1 ? 'Amanha' : `${diasPara} dias`}
                </Chip>
              )}
            </View>
          );
        })}
      </View>
    );
  }, [proximasVacinacoes]);

  const renderVacinacao = useCallback(
    ({ item }: { item: Vacinacao }) => (
      <View style={styles.card}>
        <View style={styles.cardHeader}>
          <View style={styles.cardDate}>
            <IconButton
              icon="calendar"
              iconColor={colors.secondary}
              size={18}
              style={styles.cardIcon}
            />
            <Text style={styles.cardDateText}>
              {dayjs(item.data).format('DD/MM/YYYY')}
            </Text>
          </View>
        </View>

        <Text style={styles.cardVacina}>{item.vacina}</Text>

        <View style={styles.cardDetails}>
          <View style={styles.cardDetailRow}>
            <Text style={styles.cardDetailLabel}>Lote produto:</Text>
            <Text style={styles.cardDetailValue}>{item.lote_produto}</Text>
          </View>
          <View style={styles.cardDetailRow}>
            <Text style={styles.cardDetailLabel}>Via:</Text>
            <Text style={styles.cardDetailValue}>{item.via_administracao}</Text>
          </View>
          <View style={styles.cardDetailRow}>
            <Text style={styles.cardDetailLabel}>Responsavel:</Text>
            <Text style={styles.cardDetailValue}>{item.responsavel}</Text>
          </View>
          {item.observacao && (
            <View style={styles.cardDetailRow}>
              <Text style={styles.cardDetailLabel}>Obs:</Text>
              <Text style={styles.cardDetailValue}>{item.observacao}</Text>
            </View>
          )}
        </View>
      </View>
    ),
    [],
  );

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Vacinacoes"
          subtitle={loteNome}
          titleStyle={styles.headerTitle}
          subtitleStyle={styles.headerSubtitle}
        />
      </Appbar.Header>

      <FlatList
        data={vacinacoes}
        keyExtractor={(item) => item.id}
        renderItem={renderVacinacao}
        ListHeaderComponent={renderProximasVacinacoes}
        contentContainerStyle={
          vacinacoes.length === 0 && proximasVacinacoes.length === 0
            ? styles.emptyList
            : styles.listContent
        }
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[colors.primary]}
          />
        }
        ListEmptyComponent={
          !loading ? (
            <EmptyState
              icon="needle"
              titulo="Nenhuma vacinacao registrada"
              descricao="Registre as vacinacoes do lote para manter o historico sanitario."
              actionLabel="Registrar vacinacao"
              actionIcon="plus"
              onAction={() =>
                navigation.navigate('NovaVacinacao', { loteId })
              }
            />
          ) : null
        }
      />

      <FABMenu
        actions={[
          {
            label: 'Nova vacinacao',
            icon: 'needle',
            onPress: () => navigation.navigate('NovaVacinacao', { loteId }),
          },
        ]}
      />

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

  // Calendario proximas
  calendarioContainer: {
    backgroundColor: colors.surface,
    margin: spacing.lg,
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.small,
  },
  calendarioTitulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
  },
  calendarioItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.gray200,
  },
  calendarioData: {
    width: 48,
    alignItems: 'center',
    marginRight: spacing.md,
  },
  calendarioDia: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.secondary,
  },
  calendarioMes: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    textTransform: 'uppercase',
  },
  calendarioInfo: {
    flex: 1,
  },
  calendarioVacina: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },
  calendarioIdade: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },
  proximaChip: {
    backgroundColor: colors.warningLight,
    height: 24,
  },
  proximaChipText: {
    fontSize: 11,
    color: '#E65100',
    fontWeight: typography.fontWeightMedium,
  },

  // Cards
  listContent: {
    paddingBottom: 80,
  },
  card: {
    backgroundColor: colors.surface,
    marginHorizontal: spacing.lg,
    marginTop: spacing.md,
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.small,
  },
  cardHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  cardDate: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  cardIcon: {
    margin: 0,
    padding: 0,
  },
  cardDateText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
  },
  cardVacina: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  cardDetails: {
    gap: spacing.xs,
  },
  cardDetailRow: {
    flexDirection: 'row',
  },
  cardDetailLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
    width: 100,
  },
  cardDetailValue: {
    fontSize: typography.fontSizeXS,
    color: colors.text,
    flex: 1,
  },

  emptyList: {
    flexGrow: 1,
  },
  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default VacinacoesScreen;
