/**
 * Tela de custos do lote no eGranja.
 *
 * Funcionalidades:
 * - Custos agrupados por categoria
 * - Total por categoria + total geral
 * - FAB "+" para novo custo
 * - Pull-to-refresh
 */

import React, { useState, useCallback, useEffect, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  SectionList,
  RefreshControl,
} from 'react-native';
import { Appbar, Divider, Snackbar, IconButton } from 'react-native-paper';
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

interface Custo {
  id: string;
  categoria: string;
  descricao: string;
  valor: number;
  data: string;
}

interface CustoSection {
  title: string;
  total: number;
  data: Custo[];
}

interface CustosRouteParams {
  loteId: string;
  loteNome?: string;
}

// ==========================================
// CONSTANTES
// ==========================================

const CATEGORIA_LABELS: Record<string, string> = {
  'mao_de_obra': 'Mao de obra',
  'energia': 'Energia eletrica',
  'aquecimento': 'Aquecimento (gas/lenha)',
  'cama': 'Cama do aviario',
  'manutencao': 'Manutencao',
  'depreciacao': 'Depreciacao',
  'agua': 'Agua',
  'outros': 'Outros',
};

const CATEGORIA_ICONES: Record<string, string> = {
  'mao_de_obra': 'account-hard-hat',
  'energia': 'flash',
  'aquecimento': 'fire',
  'cama': 'layers',
  'manutencao': 'wrench',
  'depreciacao': 'trending-down',
  'agua': 'water',
  'outros': 'dots-horizontal',
};

// ==========================================
// HELPERS
// ==========================================

const formatCurrency = (value: number): string => {
  return `R$ ${value.toFixed(2).replace('.', ',').replace(/\B(?=(\d{3})+(?!\d))/g, '.')}`;
};

// ==========================================
// COMPONENTE
// ==========================================

const CustosScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ Custos: CustosRouteParams }, 'Custos'>>();
  const { loteId, loteNome } = route.params;

  const [custos, setCustos] = useState<Custo[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const carregarCustos = useCallback(async () => {
    try {
      const response = await apiGet<Custo[]>(`/lotes/${loteId}/financeiro/custos`);
      setCustos(response.data);
    } catch (error) {
      console.error('[Custos] Erro ao carregar:', error);
    } finally {
      setLoading(false);
    }
  }, [loteId]);

  useEffect(() => {
    carregarCustos();
  }, [carregarCustos]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarCustos();
    setRefreshing(false);
  }, [carregarCustos]);

  /** Agrupa custos por categoria */
  const sections: CustoSection[] = useMemo(() => {
    const grouped: Record<string, Custo[]> = {};

    custos.forEach((custo) => {
      if (!grouped[custo.categoria]) {
        grouped[custo.categoria] = [];
      }
      grouped[custo.categoria].push(custo);
    });

    return Object.entries(grouped)
      .map(([categoria, itens]) => ({
        title: CATEGORIA_LABELS[categoria] || categoria,
        total: itens.reduce((sum, c) => sum + c.valor, 0),
        data: itens.sort((a, b) => dayjs(b.data).diff(dayjs(a.data))),
      }))
      .sort((a, b) => b.total - a.total);
  }, [custos]);

  /** Total geral */
  const totalGeral = useMemo(() => {
    return custos.reduce((sum, c) => sum + c.valor, 0);
  }, [custos]);

  const renderSectionHeader = useCallback(
    ({ section }: { section: CustoSection }) => {
      const categoriaKey = Object.entries(CATEGORIA_LABELS).find(
        ([, label]) => label === section.title,
      )?.[0] || 'outros';

      return (
        <View style={styles.sectionHeader}>
          <View style={styles.sectionHeaderLeft}>
            <IconButton
              icon={CATEGORIA_ICONES[categoriaKey] || 'circle'}
              iconColor={colors.secondary}
              size={20}
              style={styles.sectionIcon}
            />
            <Text style={styles.sectionTitle}>{section.title}</Text>
          </View>
          <Text style={styles.sectionTotal}>
            {formatCurrency(section.total)}
          </Text>
        </View>
      );
    },
    [],
  );

  const renderCusto = useCallback(
    ({ item }: { item: Custo }) => (
      <View style={styles.custoItem}>
        <View style={styles.custoInfo}>
          <Text style={styles.custoDescricao}>{item.descricao}</Text>
          <Text style={styles.custoData}>
            {dayjs(item.data).format('DD/MM/YYYY')}
          </Text>
        </View>
        <Text style={styles.custoValor}>
          {formatCurrency(item.valor)}
        </Text>
      </View>
    ),
    [],
  );

  const renderFooter = useCallback(() => {
    if (custos.length === 0) return null;

    return (
      <View style={styles.totalContainer}>
        <Divider style={styles.totalDivider} />
        <View style={styles.totalRow}>
          <Text style={styles.totalLabel}>TOTAL GERAL</Text>
          <Text style={styles.totalValor}>
            {formatCurrency(totalGeral)}
          </Text>
        </View>
      </View>
    );
  }, [custos.length, totalGeral]);

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Custos"
          subtitle={loteNome}
          titleStyle={styles.headerTitle}
          subtitleStyle={styles.headerSubtitle}
        />
      </Appbar.Header>

      <SectionList
        sections={sections}
        keyExtractor={(item) => item.id}
        renderSectionHeader={renderSectionHeader}
        renderItem={renderCusto}
        SectionSeparatorComponent={() => <View style={styles.sectionSeparator} />}
        ItemSeparatorComponent={() => <Divider style={styles.itemDivider} />}
        ListFooterComponent={renderFooter}
        contentContainerStyle={
          custos.length === 0 ? styles.emptyList : styles.listContent
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
              icon="cash-remove"
              titulo="Nenhum custo registrado"
              descricao="Registre os custos de producao do lote para calcular o resultado financeiro."
              actionLabel="Registrar custo"
              actionIcon="plus"
              onAction={() =>
                navigation.navigate('NovoCusto', { loteId })
              }
            />
          ) : null
        }
        stickySectionHeadersEnabled
      />

      <FABMenu
        actions={[
          {
            label: 'Novo custo',
            icon: 'cash-plus',
            onPress: () => navigation.navigate('NovoCusto', { loteId }),
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
    paddingBottom: 80,
  },

  // Section header
  sectionHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    backgroundColor: colors.gray100,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  sectionHeaderLeft: {
    flexDirection: 'row',
    alignItems: 'center',
    flex: 1,
  },
  sectionIcon: {
    margin: 0,
    padding: 0,
    marginRight: spacing.xs,
  },
  sectionTitle: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  sectionTotal: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.danger,
  },
  sectionSeparator: {
    height: spacing.sm,
  },

  // Custo item
  custoItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    paddingLeft: spacing.xxxl + spacing.lg,
    backgroundColor: colors.surface,
    minHeight: 52,
  },
  custoInfo: {
    flex: 1,
    marginRight: spacing.md,
  },
  custoDescricao: {
    fontSize: typography.fontSizeS,
    color: colors.text,
  },
  custoData: {
    fontSize: 12,
    color: colors.textSecondary,
    marginTop: 2,
  },
  custoValor: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.danger,
  },
  itemDivider: {
    marginLeft: spacing.xxxl + spacing.lg,
  },

  // Total
  totalContainer: {
    padding: spacing.lg,
    backgroundColor: colors.surface,
    marginTop: spacing.sm,
  },
  totalDivider: {
    backgroundColor: colors.text,
    height: 2,
    marginBottom: spacing.md,
  },
  totalRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  totalLabel: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    letterSpacing: 0.5,
  },
  totalValor: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.danger,
  },

  emptyList: {
    flexGrow: 1,
  },
  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default CustosScreen;
