/**
 * Tela de listagem de medicamentos do lote no eGranja.
 *
 * Funcionalidades:
 * - Cards com: data inicio/fim, medicamento, dosagem, via, carencia
 * - Alerta visual se periodo de carencia ativo (chip vermelho "EM CARENCIA")
 * - FAB "+" para novo medicamento
 * - Pull-to-refresh
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  RefreshControl,
} from 'react-native';
import { Appbar, Chip, Divider, Snackbar, IconButton } from 'react-native-paper';
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
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface Medicamento {
  id: string;
  data_inicio: string;
  data_fim: string;
  medicamento: string;
  dosagem: string;
  via: string;
  periodo_carencia_dias: number;
  responsavel: string;
  observacao?: string;
}

interface MedicamentosRouteParams {
  loteId: string;
  loteNome?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

const MedicamentosScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ Medicamentos: MedicamentosRouteParams }, 'Medicamentos'>>();
  const { loteId, loteNome } = route.params;

  const [medicamentos, setMedicamentos] = useState<Medicamento[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const carregarMedicamentos = useCallback(async () => {
    try {
      const response = await apiGet<Medicamento[]>(`/lotes/${loteId}/medicamentos`);
      setMedicamentos(response.data);
    } catch (error) {
      console.error('[Medicamentos] Erro ao carregar:', error);
    } finally {
      setLoading(false);
    }
  }, [loteId]);

  useEffect(() => {
    carregarMedicamentos();
  }, [carregarMedicamentos]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarMedicamentos();
    setRefreshing(false);
  }, [carregarMedicamentos]);

  /** Verifica se o medicamento esta em periodo de carencia */
  const isEmCarencia = useCallback((med: Medicamento): boolean => {
    if (!med.periodo_carencia_dias || med.periodo_carencia_dias <= 0) return false;
    const fimCarencia = dayjs(med.data_fim).add(med.periodo_carencia_dias, 'day');
    return dayjs().isBefore(fimCarencia);
  }, []);

  /** Calcula dias restantes de carencia */
  const diasCarenciaRestantes = useCallback((med: Medicamento): number => {
    const fimCarencia = dayjs(med.data_fim).add(med.periodo_carencia_dias, 'day');
    return fimCarencia.diff(dayjs(), 'day');
  }, []);

  /** Verifica se o tratamento esta ativo (entre data inicio e data fim) */
  const isTratamentoAtivo = useCallback((med: Medicamento): boolean => {
    return dayjs().isBefore(dayjs(med.data_fim)) && dayjs().isAfter(dayjs(med.data_inicio));
  }, []);

  const renderMedicamento = useCallback(
    ({ item }: { item: Medicamento }) => {
      const emCarencia = isEmCarencia(item);
      const ativo = isTratamentoAtivo(item);
      const diasRestantes = emCarencia ? diasCarenciaRestantes(item) : 0;

      return (
        <View
          style={[
            styles.card,
            emCarencia && styles.cardCarencia,
          ]}
        >
          {/* Chips de status */}
          <View style={styles.chipContainer}>
            {ativo && (
              <Chip
                mode="flat"
                icon="pill"
                style={styles.ativoChip}
                textStyle={styles.ativoChipText}
              >
                Em tratamento
              </Chip>
            )}
            {emCarencia && (
              <Chip
                mode="flat"
                icon="alert-circle"
                style={styles.carenciaChip}
                textStyle={styles.carenciaChipText}
              >
                EM CARENCIA ({diasRestantes}d)
              </Chip>
            )}
          </View>

          {/* Nome do medicamento */}
          <Text style={styles.medicamentoNome}>{item.medicamento}</Text>

          {/* Periodo */}
          <View style={styles.periodoContainer}>
            <IconButton icon="calendar-range" iconColor={colors.secondary} size={16} style={styles.icon} />
            <Text style={styles.periodoText}>
              {dayjs(item.data_inicio).format('DD/MM/YYYY')} a {dayjs(item.data_fim).format('DD/MM/YYYY')}
            </Text>
          </View>

          {/* Detalhes */}
          <View style={styles.detailsGrid}>
            <View style={styles.detailItem}>
              <Text style={styles.detailLabel}>Dosagem</Text>
              <Text style={styles.detailValue}>{item.dosagem}</Text>
            </View>
            <View style={styles.detailItem}>
              <Text style={styles.detailLabel}>Via</Text>
              <Text style={styles.detailValue}>{item.via}</Text>
            </View>
            <View style={styles.detailItem}>
              <Text style={styles.detailLabel}>Carencia</Text>
              <Text style={styles.detailValue}>
                {item.periodo_carencia_dias} dias
              </Text>
            </View>
            <View style={styles.detailItem}>
              <Text style={styles.detailLabel}>Responsavel</Text>
              <Text style={styles.detailValue}>{item.responsavel}</Text>
            </View>
          </View>

          {item.observacao && (
            <Text style={styles.observacao}>Obs: {item.observacao}</Text>
          )}
        </View>
      );
    },
    [isEmCarencia, isTratamentoAtivo, diasCarenciaRestantes],
  );

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Medicamentos"
          subtitle={loteNome}
          titleStyle={styles.headerTitle}
          subtitleStyle={styles.headerSubtitle}
        />
      </Appbar.Header>

      <FlatList
        data={medicamentos}
        keyExtractor={(item) => item.id}
        renderItem={renderMedicamento}
        contentContainerStyle={
          medicamentos.length === 0 ? styles.emptyList : styles.listContent
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
              icon="pill"
              titulo="Nenhum medicamento registrado"
              descricao="Registre os medicamentos aplicados no lote para controle de carencia."
              actionLabel="Registrar medicamento"
              actionIcon="plus"
              onAction={() =>
                navigation.navigate('NovoMedicamento', { loteId })
              }
            />
          ) : null
        }
      />

      <FABMenu
        actions={[
          {
            label: 'Novo medicamento',
            icon: 'pill',
            onPress: () => navigation.navigate('NovoMedicamento', { loteId }),
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
  listContent: {
    padding: spacing.lg,
    paddingBottom: 80,
    gap: spacing.md,
  },
  card: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    ...shadows.small,
  },
  cardCarencia: {
    borderLeftWidth: 4,
    borderLeftColor: colors.danger,
  },
  chipContainer: {
    flexDirection: 'row',
    gap: spacing.sm,
    marginBottom: spacing.sm,
    flexWrap: 'wrap',
  },
  ativoChip: {
    backgroundColor: colors.secondaryLight + '30',
    height: 26,
  },
  ativoChipText: {
    fontSize: 11,
    color: colors.secondary,
    fontWeight: typography.fontWeightMedium,
  },
  carenciaChip: {
    backgroundColor: colors.dangerLight,
    height: 26,
  },
  carenciaChipText: {
    fontSize: 11,
    color: colors.danger,
    fontWeight: typography.fontWeightBold,
  },
  medicamentoNome: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  periodoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  icon: {
    margin: 0,
    padding: 0,
    marginRight: spacing.xs,
  },
  periodoText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },
  detailsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: spacing.md,
  },
  detailItem: {
    width: '45%',
  },
  detailLabel: {
    fontSize: 12,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
    marginBottom: 2,
  },
  detailValue: {
    fontSize: typography.fontSizeS,
    color: colors.text,
  },
  observacao: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontStyle: 'italic',
    marginTop: spacing.sm,
  },
  emptyList: {
    flexGrow: 1,
  },
  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default MedicamentosScreen;
