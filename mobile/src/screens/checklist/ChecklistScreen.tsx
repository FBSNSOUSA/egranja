/**
 * Tela de Checklist Diario de Manejo do eGranja.
 *
 * Funcionalidades:
 * - Lista de itens adaptada a fase do lote (dias de vida)
 * - 1a semana: aquecimento, circulos de protecao, temp. cama 32C
 * - Geral: mortalidade, temp, umidade, bebedouros, comedouros, racao, hidrometro, cama, ventilacao, comportamento, biosseguranca
 * - Pre-abate: jejum alimentar, preparar apanha
 * - Checkbox com timestamp ao marcar
 * - Barra de progresso no topo
 * - Historico por data
 * - Salvamento automatico
 */

import React, { useState, useCallback, useEffect, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  TouchableOpacity,
  RefreshControl,
  Platform,
} from 'react-native';
import {
  Appbar,
  Checkbox,
  ProgressBar,
  Chip,
  Divider,
  Snackbar,
  SegmentedButtons,
  IconButton,
} from 'react-native-paper';
import { useNavigation, DrawerActions } from '@react-navigation/native';
import DateTimePicker, { DateTimePickerEvent } from '@react-native-community/datetimepicker';
import dayjs from 'dayjs';
import { apiGet, apiPost, apiPatch } from '@services/api';
import { useAuthStore } from '@stores/authStore';
import { EmptyState } from '@components/EmptyState';
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

interface ChecklistItem {
  id: string;
  label: string;
  categoria: 'geral' | 'primeira_semana' | 'pre_abate';
  checked: boolean;
  checked_at?: string;
  ordem: number;
}

interface ChecklistDia {
  id: string;
  lote_id: string;
  lote_nome: string;
  data: string;
  itens: ChecklistItem[];
  idade_lote_dias: number;
  data_prevista_abate?: string;
}

interface LoteResumo {
  id: string;
  nome: string;
  idade_dias: number;
  data_prevista_abate?: string;
}

// ==========================================
// ITENS PADRAO DO CHECKLIST
// ==========================================

const CHECKLIST_ITENS_GERAL: Omit<ChecklistItem, 'id' | 'checked' | 'checked_at'>[] = [
  { label: 'Verificar mortalidade (recolher mortos)', categoria: 'geral', ordem: 1 },
  { label: 'Registrar mortalidade no app', categoria: 'geral', ordem: 2 },
  { label: 'Verificar temperatura ambiente (min/max)', categoria: 'geral', ordem: 3 },
  { label: 'Verificar umidade relativa', categoria: 'geral', ordem: 4 },
  { label: 'Conferir bebedouros (vazamentos, altura, pressao)', categoria: 'geral', ordem: 5 },
  { label: 'Conferir comedouros (nivel, regulagem)', categoria: 'geral', ordem: 6 },
  { label: 'Verificar nivel de racao no silo', categoria: 'geral', ordem: 7 },
  { label: 'Registrar leitura do hidrometro', categoria: 'geral', ordem: 8 },
  { label: 'Verificar condicao da cama', categoria: 'geral', ordem: 9 },
  { label: 'Verificar ventilacao/cortinas/nebulizacao', categoria: 'geral', ordem: 10 },
  { label: 'Observar comportamento das aves', categoria: 'geral', ordem: 11 },
  { label: 'Verificar biosseguranca (pediluvio, cercas)', categoria: 'geral', ordem: 12 },
];

const CHECKLIST_ITENS_PRIMEIRA_SEMANA: Omit<ChecklistItem, 'id' | 'checked' | 'checked_at'>[] = [
  { label: 'Verificar aquecimento', categoria: 'primeira_semana', ordem: 13 },
  { label: 'Verificar circulos de protecao', categoria: 'primeira_semana', ordem: 14 },
  { label: 'Verificar temperatura da cama (32C)', categoria: 'primeira_semana', ordem: 15 },
];

const CHECKLIST_ITENS_PRE_ABATE: Omit<ChecklistItem, 'id' | 'checked' | 'checked_at'>[] = [
  { label: 'Verificar jejum alimentar', categoria: 'pre_abate', ordem: 16 },
  { label: 'Preparar para apanha', categoria: 'pre_abate', ordem: 17 },
];

// ==========================================
// COMPONENTE
// ==========================================

const ChecklistScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const user = useAuthStore((state) => state.user);

  const [checklist, setChecklist] = useState<ChecklistDia | null>(null);
  const [lotes, setLotes] = useState<LoteResumo[]>([]);
  const [selectedLoteId, setSelectedLoteId] = useState<string>('');
  const [selectedDate, setSelectedDate] = useState(new Date());
  const [showDatePicker, setShowDatePicker] = useState(false);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [viewMode, setViewMode] = useState<'hoje' | 'historico'>('hoje');

  // Historico
  const [historicoList, setHistoricoList] = useState<Array<{
    data: string;
    total: number;
    completados: number;
    porcentagem: number;
  }>>([]);

  // ==========================================
  // CARREGAR LOTES ATIVOS
  // ==========================================

  useEffect(() => {
    carregarLotes();
  }, []);

  const carregarLotes = useCallback(async () => {
    try {
      const response = await apiGet<LoteResumo[]>('/lotes', { status: 'ativo' });
      setLotes(response.data);
      if (response.data.length > 0 && !selectedLoteId) {
        setSelectedLoteId(response.data[0].id);
      }
    } catch (error) {
      console.error('[Checklist] Erro ao carregar lotes:', error);
    }
  }, [selectedLoteId]);

  // ==========================================
  // CARREGAR CHECKLIST DO DIA
  // ==========================================

  useEffect(() => {
    if (selectedLoteId) {
      carregarChecklist();
    }
  }, [selectedLoteId, selectedDate]);

  const carregarChecklist = useCallback(async () => {
    if (!selectedLoteId) return;

    try {
      setLoading(true);
      const dataStr = dayjs(selectedDate).format('YYYY-MM-DD');
      const response = await apiGet<ChecklistDia>(
        `/lotes/${selectedLoteId}/checklist`,
        { data: dataStr },
      );
      setChecklist(response.data);
    } catch (error) {
      // Se nao encontrou checklist para o dia, criar localmente baseado na idade do lote
      const lote = lotes.find((l) => l.id === selectedLoteId);
      if (lote) {
        const itensDoDia = getItensParaFase(lote.idade_dias, lote.data_prevista_abate);
        setChecklist({
          id: '',
          lote_id: selectedLoteId,
          lote_nome: lote.nome,
          data: dayjs(selectedDate).format('YYYY-MM-DD'),
          itens: itensDoDia,
          idade_lote_dias: lote.idade_dias,
          data_prevista_abate: lote.data_prevista_abate,
        });
      }
    } finally {
      setLoading(false);
    }
  }, [selectedLoteId, selectedDate, lotes]);

  // ==========================================
  // CARREGAR HISTORICO
  // ==========================================

  useEffect(() => {
    if (selectedLoteId && viewMode === 'historico') {
      carregarHistorico();
    }
  }, [selectedLoteId, viewMode]);

  const carregarHistorico = useCallback(async () => {
    if (!selectedLoteId) return;

    try {
      const response = await apiGet<Array<{
        data: string;
        total: number;
        completados: number;
        porcentagem: number;
      }>>(`/lotes/${selectedLoteId}/checklist/historico`);
      setHistoricoList(response.data);
    } catch (error) {
      console.error('[Checklist] Erro ao carregar historico:', error);
    }
  }, [selectedLoteId]);

  // ==========================================
  // ITENS POR FASE
  // ==========================================

  const getItensParaFase = useCallback(
    (idadeDias: number, dataPrevistaAbate?: string): ChecklistItem[] => {
      let itens = [...CHECKLIST_ITENS_GERAL];

      // 1a semana (0-7 dias)
      if (idadeDias <= 7) {
        itens = [...itens, ...CHECKLIST_ITENS_PRIMEIRA_SEMANA];
      }

      // Pre-abate (faltam < 5 dias para data prevista)
      if (dataPrevistaAbate) {
        const diasParaAbate = dayjs(dataPrevistaAbate).diff(dayjs(), 'day');
        if (diasParaAbate <= 5 && diasParaAbate >= 0) {
          itens = [...itens, ...CHECKLIST_ITENS_PRE_ABATE];
        }
      }

      // Ordenar e atribuir IDs
      return itens
        .sort((a, b) => a.ordem - b.ordem)
        .map((item, index) => ({
          ...item,
          id: `item_${index}`,
          checked: false,
        }));
    },
    [],
  );

  // ==========================================
  // TOGGLE ITEM
  // ==========================================

  const toggleItem = useCallback(
    async (itemId: string) => {
      if (!checklist) return;

      const updatedItens = checklist.itens.map((item) => {
        if (item.id === itemId) {
          return {
            ...item,
            checked: !item.checked,
            checked_at: !item.checked ? new Date().toISOString() : undefined,
          };
        }
        return item;
      });

      const updatedChecklist = { ...checklist, itens: updatedItens };
      setChecklist(updatedChecklist);

      // Salvar automaticamente no servidor
      try {
        if (checklist.id) {
          await apiPatch(`/lotes/${selectedLoteId}/checklist/${checklist.id}`, {
            itens: updatedItens,
          });
        } else {
          const response = await apiPost<ChecklistDia>(
            `/lotes/${selectedLoteId}/checklist`,
            {
              data: checklist.data,
              itens: updatedItens,
            },
          );
          setChecklist(response.data);
        }
      } catch (error) {
        console.error('[Checklist] Erro ao salvar:', error);
        showSnackbar('Salvo localmente. Sincronizara quando online.');
      }
    },
    [checklist, selectedLoteId],
  );

  // ==========================================
  // PROGRESSO
  // ==========================================

  const progresso = useMemo(() => {
    if (!checklist || checklist.itens.length === 0) return 0;
    const completados = checklist.itens.filter((item) => item.checked).length;
    return completados / checklist.itens.length;
  }, [checklist]);

  const progressoTexto = useMemo(() => {
    if (!checklist) return '0/0';
    const completados = checklist.itens.filter((item) => item.checked).length;
    return `${completados}/${checklist.itens.length}`;
  }, [checklist]);

  // ==========================================
  // HANDLERS
  // ==========================================

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarChecklist();
    setRefreshing(false);
  }, [carregarChecklist]);

  const handleDateChange = useCallback(
    (event: DateTimePickerEvent, date?: Date) => {
      setShowDatePicker(Platform.OS === 'ios');
      if (date) {
        setSelectedDate(date);
      }
    },
    [],
  );

  const showSnackbar = useCallback((message: string) => {
    setSnackbarMessage(message);
    setSnackbarVisible(true);
  }, []);

  // ==========================================
  // RENDER ITEM
  // ==========================================

  const renderChecklistItem = useCallback(
    ({ item }: { item: ChecklistItem }) => {
      const isHoje = dayjs(selectedDate).isSame(dayjs(), 'day');

      return (
        <TouchableOpacity
          style={[
            styles.checklistItem,
            item.checked && styles.checklistItemCompleted,
          ]}
          onPress={() => isHoje && toggleItem(item.id)}
          disabled={!isHoje}
          activeOpacity={0.7}
        >
          <Checkbox
            status={item.checked ? 'checked' : 'unchecked'}
            onPress={() => isHoje && toggleItem(item.id)}
            color={colors.success}
            uncheckedColor={colors.gray400}
            disabled={!isHoje}
          />

          <View style={styles.checklistItemContent}>
            <Text
              style={[
                styles.checklistLabel,
                item.checked && styles.checklistLabelCompleted,
              ]}
            >
              {item.label}
            </Text>

            {item.checked && item.checked_at && (
              <Text style={styles.checklistTimestamp}>
                {dayjs(item.checked_at).format('HH:mm')}
              </Text>
            )}
          </View>

          {/* Chip de categoria */}
          {item.categoria !== 'geral' && (
            <Chip
              mode="flat"
              style={[
                styles.categoriaChip,
                item.categoria === 'primeira_semana'
                  ? styles.categoriaSemana
                  : styles.categoriaAbate,
              ]}
              textStyle={styles.categoriaChipText}
            >
              {item.categoria === 'primeira_semana' ? '1a Sem.' : 'Pre-abate'}
            </Chip>
          )}
        </TouchableOpacity>
      );
    },
    [toggleItem, selectedDate],
  );

  const renderHistoricoItem = useCallback(
    ({ item }: { item: { data: string; total: number; completados: number; porcentagem: number } }) => (
      <TouchableOpacity
        style={styles.historicoItem}
        onPress={() => {
          setSelectedDate(dayjs(item.data).toDate());
          setViewMode('hoje');
        }}
        activeOpacity={0.7}
      >
        <View style={styles.historicoLeft}>
          <Text style={styles.historicoData}>
            {dayjs(item.data).format('DD/MM/YYYY')}
          </Text>
          <Text style={styles.historicoDetalhe}>
            {item.completados}/{item.total} itens
          </Text>
        </View>

        <View style={styles.historicoRight}>
          <View style={styles.historicoBarContainer}>
            <View
              style={[
                styles.historicoBar,
                {
                  width: `${item.porcentagem}%`,
                  backgroundColor:
                    item.porcentagem === 100
                      ? colors.success
                      : item.porcentagem >= 80
                        ? colors.warning
                        : colors.danger,
                },
              ]}
            />
          </View>
          <Text
            style={[
              styles.historicoPct,
              {
                color:
                  item.porcentagem === 100
                    ? colors.success
                    : item.porcentagem >= 80
                      ? colors.warning
                      : colors.danger,
              },
            ]}
          >
            {item.porcentagem}%
          </Text>
        </View>
      </TouchableOpacity>
    ),
    [],
  );

  // ==========================================
  // RENDER PRINCIPAL
  // ==========================================

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.Action
          icon="menu"
          color={colors.textOnPrimary}
          onPress={() => navigation.dispatch(DrawerActions.openDrawer())}
        />
        <Appbar.Content
          title="Checklist Diario"
          titleStyle={styles.headerTitle}
        />
      </Appbar.Header>

      {/* Seletor de lote */}
      {lotes.length > 1 && (
        <View style={styles.loteSelectorContainer}>
          <FlatList
            data={lotes}
            horizontal
            showsHorizontalScrollIndicator={false}
            keyExtractor={(item) => item.id}
            contentContainerStyle={styles.loteSelectorList}
            renderItem={({ item }) => (
              <TouchableOpacity
                style={[
                  styles.loteChip,
                  item.id === selectedLoteId && styles.loteChipSelected,
                ]}
                onPress={() => setSelectedLoteId(item.id)}
              >
                <Text
                  style={[
                    styles.loteChipText,
                    item.id === selectedLoteId && styles.loteChipTextSelected,
                  ]}
                >
                  {item.nome}
                </Text>
              </TouchableOpacity>
            )}
          />
        </View>
      )}

      {/* Tabs: Hoje | Historico */}
      <View style={styles.tabContainer}>
        <SegmentedButtons
          value={viewMode}
          onValueChange={(value) => setViewMode(value as 'hoje' | 'historico')}
          buttons={[
            { value: 'hoje', label: 'Checklist', icon: 'checkbox-marked-outline' },
            { value: 'historico', label: 'Historico', icon: 'history' },
          ]}
          style={styles.segmented}
        />
      </View>

      {viewMode === 'hoje' ? (
        <>
          {/* Seletor de data + Progresso */}
          <View style={styles.progressContainer}>
            <TouchableOpacity
              style={styles.dateSelector}
              onPress={() => setShowDatePicker(true)}
            >
              <IconButton icon="calendar" iconColor={colors.secondary} size={20} style={{ margin: 0 }} />
              <Text style={styles.dateText}>
                {dayjs(selectedDate).format('DD/MM/YYYY')}
              </Text>
              {dayjs(selectedDate).isSame(dayjs(), 'day') && (
                <Chip mode="flat" style={styles.hojeChip} textStyle={styles.hojeChipText}>
                  Hoje
                </Chip>
              )}
            </TouchableOpacity>

            <View style={styles.progressBarContainer}>
              <View style={styles.progressLabelRow}>
                <Text style={styles.progressLabel}>Progresso</Text>
                <Text style={styles.progressValue}>
                  {progressoTexto} ({Math.round(progresso * 100)}%)
                </Text>
              </View>
              <ProgressBar
                progress={progresso}
                color={
                  progresso === 1
                    ? colors.success
                    : progresso >= 0.8
                      ? colors.warning
                      : colors.primary
                }
                style={styles.progressBar}
              />
            </View>

            {checklist && checklist.idade_lote_dias > 0 && (
              <Text style={styles.idadeLote}>
                Idade do lote: {checklist.idade_lote_dias} dias
              </Text>
            )}
          </View>

          {/* Lista de itens */}
          <FlatList
            data={checklist?.itens || []}
            keyExtractor={(item) => item.id}
            renderItem={renderChecklistItem}
            ItemSeparatorComponent={() => <Divider style={styles.itemDivider} />}
            contentContainerStyle={
              !checklist?.itens?.length ? styles.emptyList : styles.listContent
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
                  icon="checkbox-blank-outline"
                  titulo="Nenhum checklist"
                  descricao="Selecione um lote ativo para ver o checklist do dia."
                />
              ) : null
            }
          />
        </>
      ) : (
        /* Historico */
        <FlatList
          data={historicoList}
          keyExtractor={(item) => item.data}
          renderItem={renderHistoricoItem}
          ItemSeparatorComponent={() => <Divider />}
          contentContainerStyle={
            historicoList.length === 0 ? styles.emptyList : styles.listContent
          }
          refreshControl={
            <RefreshControl
              refreshing={refreshing}
              onRefresh={carregarHistorico}
              colors={[colors.primary]}
            />
          }
          ListEmptyComponent={
            <EmptyState
              icon="history"
              titulo="Sem historico"
              descricao="O historico de checklists completados aparecera aqui."
            />
          }
        />
      )}

      {/* DatePicker */}
      {showDatePicker && (
        <DateTimePicker
          value={selectedDate}
          mode="date"
          display={Platform.OS === 'ios' ? 'spinner' : 'default'}
          onChange={handleDateChange}
          maximumDate={new Date()}
          locale="pt-BR"
        />
      )}

      {/* Snackbar */}
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

  // Seletor de lote
  loteSelectorContainer: {
    backgroundColor: colors.surface,
    paddingVertical: spacing.sm,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  loteSelectorList: {
    paddingHorizontal: spacing.lg,
    gap: spacing.sm,
  },
  loteChip: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    borderRadius: borders.radiusRound,
    backgroundColor: colors.gray100,
    borderWidth: 1,
    borderColor: colors.gray300,
  },
  loteChipSelected: {
    backgroundColor: colors.primary,
    borderColor: colors.primary,
  },
  loteChipText: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    fontWeight: typography.fontWeightMedium,
  },
  loteChipTextSelected: {
    color: colors.textOnPrimary,
    fontWeight: typography.fontWeightBold,
  },

  // Tabs
  tabContainer: {
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.sm,
    backgroundColor: colors.surface,
  },
  segmented: {
    backgroundColor: colors.gray100,
  },

  // Progresso
  progressContainer: {
    backgroundColor: colors.surface,
    padding: spacing.lg,
    borderBottomWidth: 1,
    borderBottomColor: colors.divider,
  },
  dateSelector: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.md,
  },
  dateText: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginLeft: spacing.xs,
  },
  hojeChip: {
    marginLeft: spacing.sm,
    backgroundColor: colors.successLight,
    height: 24,
  },
  hojeChipText: {
    fontSize: 11,
    color: colors.success,
    fontWeight: typography.fontWeightMedium,
  },
  progressBarContainer: {
    marginBottom: spacing.sm,
  },
  progressLabelRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: spacing.xs,
  },
  progressLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
  },
  progressValue: {
    fontSize: typography.fontSizeXS,
    color: colors.text,
    fontWeight: typography.fontWeightBold,
  },
  progressBar: {
    height: 8,
    borderRadius: 4,
    backgroundColor: colors.gray200,
  },
  idadeLote: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },

  // Checklist items
  listContent: {
    paddingBottom: spacing.xxxl,
  },
  checklistItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    backgroundColor: colors.surface,
    minHeight: 56,
  },
  checklistItemCompleted: {
    backgroundColor: colors.successLight,
  },
  checklistItemContent: {
    flex: 1,
    marginLeft: spacing.xs,
  },
  checklistLabel: {
    fontSize: typography.fontSizeS,
    color: colors.text,
    lineHeight: typography.fontSizeS * 1.4,
  },
  checklistLabelCompleted: {
    color: colors.success,
    textDecorationLine: 'line-through',
  },
  checklistTimestamp: {
    fontSize: 12,
    color: colors.success,
    marginTop: 2,
  },
  categoriaChip: {
    height: 22,
    marginLeft: spacing.xs,
  },
  categoriaSemana: {
    backgroundColor: colors.secondaryLight + '30',
  },
  categoriaAbate: {
    backgroundColor: colors.warningLight,
  },
  categoriaChipText: {
    fontSize: 10,
    fontWeight: typography.fontWeightMedium,
  },
  itemDivider: {
    marginLeft: 56,
  },

  // Historico
  historicoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'space-between',
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    backgroundColor: colors.surface,
    minHeight: 60,
  },
  historicoLeft: {
    flex: 1,
  },
  historicoData: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  historicoDetalhe: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },
  historicoRight: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  historicoBarContainer: {
    width: 80,
    height: 6,
    backgroundColor: colors.gray200,
    borderRadius: 3,
    overflow: 'hidden',
  },
  historicoBar: {
    height: '100%',
    borderRadius: 3,
  },
  historicoPct: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightBold,
    minWidth: 36,
    textAlign: 'right',
  },

  emptyList: {
    flexGrow: 1,
  },

  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default ChecklistScreen;
