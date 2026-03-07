/**
 * Tela de remuneracao da integradora do eGranja.
 *
 * Funcionalidades:
 * - Valor recebido, tipo (por kg, por ave, por IEP, outro), data pagamento
 * - Formulario inline (sem tela separada)
 * - Lista de remuneracoes registradas
 * - Pull-to-refresh
 */

import React, { useState, useCallback, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  RefreshControl,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { Appbar, Button, Divider, Snackbar, IconButton, Chip } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import dayjs from 'dayjs';
import { apiGet, apiPost } from '@services/api';
import { FormField } from '@components/FormField';
import { DatePickerField } from '@components/DatePickerField';
import { DropdownField } from '@components/DropdownField';
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

interface Remuneracao {
  id: string;
  valor: number;
  tipo: string;
  data_pagamento: string;
  observacao?: string;
}

interface RemuneracaoRouteParams {
  loteId: string;
  loteNome?: string;
}

interface FormErrors {
  valor?: string;
  tipo?: string;
}

// ==========================================
// OPCOES
// ==========================================

const TIPOS_REMUNERACAO = [
  { value: 'por_kg', label: 'Por kg produzido' },
  { value: 'por_ave', label: 'Por ave entregue' },
  { value: 'por_iep', label: 'Por IEP' },
  { value: 'fixo', label: 'Valor fixo' },
  { value: 'outro', label: 'Outro' },
];

const TIPO_LABELS: Record<string, string> = {
  'por_kg': 'Por kg',
  'por_ave': 'Por ave',
  'por_iep': 'Por IEP',
  'fixo': 'Fixo',
  'outro': 'Outro',
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

const RemuneracaoScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ Remuneracao: RemuneracaoRouteParams }, 'Remuneracao'>>();
  const { loteId, loteNome } = route.params;

  // Lista
  const [remuneracoes, setRemuneracoes] = useState<Remuneracao[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);

  // Formulario inline
  const [showForm, setShowForm] = useState(false);
  const [valor, setValor] = useState('');
  const [tipo, setTipo] = useState('');
  const [dataPagamento, setDataPagamento] = useState(new Date());
  const [observacao, setObservacao] = useState('');
  const [errors, setErrors] = useState<FormErrors>({});
  const [submitting, setSubmitting] = useState(false);

  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const valorRef = useRef<any>(null);

  // ==========================================
  // CARREGAR
  // ==========================================

  const carregarRemuneracoes = useCallback(async () => {
    try {
      const response = await apiGet<Remuneracao[]>(
        `/lotes/${loteId}/financeiro/remuneracoes`,
      );
      setRemuneracoes(response.data);
    } catch (error) {
      console.error('[Remuneracao] Erro ao carregar:', error);
    } finally {
      setLoading(false);
    }
  }, [loteId]);

  useEffect(() => {
    carregarRemuneracoes();
  }, [carregarRemuneracoes]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarRemuneracoes();
    setRefreshing(false);
  }, [carregarRemuneracoes]);

  // ==========================================
  // FORMULARIO
  // ==========================================

  const parseValor = useCallback((text: string): number => {
    const cleaned = text
      .replace(/R\$\s?/, '')
      .replace(/\./g, '')
      .replace(',', '.');
    return parseFloat(cleaned) || 0;
  }, []);

  const handleValorChange = useCallback((text: string) => {
    const cleaned = text.replace(/[^0-9,]/g, '');
    setValor(cleaned);
  }, []);

  const validate = useCallback((): boolean => {
    const newErrors: FormErrors = {};

    const valorNum = parseValor(valor);
    if (!valor.trim() || valorNum <= 0) {
      newErrors.valor = 'Informe um valor valido.';
    }
    if (!tipo) {
      newErrors.tipo = 'Selecione o tipo.';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [valor, tipo, parseValor]);

  const handleSubmit = useCallback(async () => {
    if (!validate()) return;

    setSubmitting(true);
    try {
      await apiPost(`/lotes/${loteId}/financeiro/remuneracoes`, {
        valor: parseValor(valor),
        tipo,
        data_pagamento: dayjs(dataPagamento).format('YYYY-MM-DD'),
        observacao: observacao.trim() || undefined,
      });

      setSnackbarMessage('Remuneracao registrada com sucesso.');
      setSnackbarVisible(true);

      // Limpar formulario
      setValor('');
      setTipo('');
      setDataPagamento(new Date());
      setObservacao('');
      setShowForm(false);
      setErrors({});

      // Recarregar lista
      carregarRemuneracoes();
    } catch (error) {
      console.error('[Remuneracao] Erro ao salvar:', error);
      setSnackbarMessage('Erro ao salvar. Tente novamente.');
      setSnackbarVisible(true);
    } finally {
      setSubmitting(false);
    }
  }, [validate, loteId, valor, tipo, dataPagamento, observacao, parseValor, carregarRemuneracoes]);

  // ==========================================
  // TOTAL
  // ==========================================

  const totalRemuneracoes = remuneracoes.reduce((sum, r) => sum + r.valor, 0);

  // ==========================================
  // RENDER
  // ==========================================

  const renderRemuneracao = useCallback(
    ({ item }: { item: Remuneracao }) => (
      <View style={styles.remItem}>
        <View style={styles.remItemLeft}>
          <View style={styles.remItemHeader}>
            <Chip
              mode="flat"
              style={styles.tipoChip}
              textStyle={styles.tipoChipText}
            >
              {TIPO_LABELS[item.tipo] || item.tipo}
            </Chip>
            <Text style={styles.remData}>
              {dayjs(item.data_pagamento).format('DD/MM/YYYY')}
            </Text>
          </View>
          {item.observacao && (
            <Text style={styles.remObs} numberOfLines={2}>
              {item.observacao}
            </Text>
          )}
        </View>
        <Text style={styles.remValor}>
          {formatCurrency(item.valor)}
        </Text>
      </View>
    ),
    [],
  );

  const renderHeader = useCallback(() => {
    return (
      <View>
        {/* Total */}
        <View style={styles.totalContainer}>
          <IconButton icon="cash-multiple" iconColor={colors.success} size={28} style={styles.totalIcon} />
          <View>
            <Text style={styles.totalLabel}>Total recebido</Text>
            <Text style={styles.totalValor}>{formatCurrency(totalRemuneracoes)}</Text>
          </View>
        </View>

        {/* Formulario inline */}
        {showForm && (
          <View style={styles.formContainer}>
            <Text style={styles.formTitle}>Nova remuneracao</Text>

            <FormField
              label="Valor recebido"
              value={valor}
              onChangeText={handleValorChange}
              placeholder="0,00"
              required
              error={errors.valor}
              keyboardType="decimal-pad"
              leftIcon="currency-brl"
              inputRef={valorRef}
            />

            <DropdownField
              label="Tipo de remuneracao"
              value={tipo}
              options={TIPOS_REMUNERACAO}
              onSelect={setTipo}
              placeholder="Selecione..."
              required
              error={errors.tipo}
            />

            <DatePickerField
              label="Data do pagamento"
              value={dataPagamento}
              onChange={setDataPagamento}
              maximumDate={new Date()}
            />

            <FormField
              label="Observacao"
              value={observacao}
              onChangeText={setObservacao}
              placeholder="Observacao (opcional)"
              multiline
              numberOfLines={2}
            />

            <View style={styles.formActions}>
              <Button
                mode="text"
                onPress={() => {
                  setShowForm(false);
                  setErrors({});
                }}
                labelStyle={styles.cancelLabel}
                textColor={colors.textSecondary}
              >
                Cancelar
              </Button>
              <Button
                mode="contained"
                onPress={handleSubmit}
                loading={submitting}
                disabled={submitting}
                style={styles.salvarButton}
                contentStyle={styles.salvarButtonContent}
                labelStyle={styles.salvarButtonLabel}
                buttonColor={colors.success}
                textColor={colors.white}
              >
                Salvar
              </Button>
            </View>
          </View>
        )}

        {/* Botao adicionar */}
        {!showForm && (
          <Button
            mode="contained"
            onPress={() => setShowForm(true)}
            icon="plus"
            style={styles.addButton}
            contentStyle={styles.addButtonContent}
            labelStyle={styles.addButtonLabel}
            buttonColor={colors.success}
            textColor={colors.white}
          >
            Registrar remuneracao
          </Button>
        )}

        {/* Titulo da lista */}
        {remuneracoes.length > 0 && (
          <Text style={styles.listTitle}>Historico de pagamentos</Text>
        )}
      </View>
    );
  }, [showForm, valor, tipo, dataPagamento, observacao, errors, submitting, totalRemuneracoes, remuneracoes.length, handleValorChange, handleSubmit]);

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : undefined}
    >
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Remuneracao"
          subtitle={loteNome}
          titleStyle={styles.headerTitle}
          subtitleStyle={styles.headerSubtitle}
        />
      </Appbar.Header>

      <FlatList
        data={remuneracoes}
        keyExtractor={(item) => item.id}
        renderItem={renderRemuneracao}
        ListHeaderComponent={renderHeader}
        ItemSeparatorComponent={() => <Divider />}
        contentContainerStyle={
          remuneracoes.length === 0 && !showForm ? styles.emptyList : styles.listContent
        }
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[colors.primary]}
          />
        }
        ListEmptyComponent={
          !loading && !showForm ? (
            <EmptyState
              icon="cash"
              titulo="Nenhuma remuneracao registrada"
              descricao="Registre os valores recebidos da integradora."
            />
          ) : null
        }
        keyboardShouldPersistTaps="handled"
      />

      <Snackbar
        visible={snackbarVisible}
        onDismiss={() => setSnackbarVisible(false)}
        duration={3000}
        style={styles.snackbar}
      >
        {snackbarMessage}
      </Snackbar>
    </KeyboardAvoidingView>
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
    paddingBottom: spacing.huge,
  },

  // Total
  totalContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.successLight,
    padding: spacing.lg,
    margin: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.small,
  },
  totalIcon: {
    margin: 0,
    marginRight: spacing.md,
  },
  totalLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.success,
    fontWeight: typography.fontWeightMedium,
    textTransform: 'uppercase',
    letterSpacing: 0.5,
  },
  totalValor: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    color: colors.success,
  },

  // Formulario
  formContainer: {
    backgroundColor: colors.surface,
    marginHorizontal: spacing.lg,
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.medium,
    marginBottom: spacing.lg,
  },
  formTitle: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
  },
  formActions: {
    flexDirection: 'row',
    justifyContent: 'flex-end',
    gap: spacing.md,
    marginTop: spacing.sm,
  },
  cancelLabel: {
    fontSize: typography.fontSizeS,
  },
  salvarButton: {
    borderRadius: components.button.borderRadius,
  },
  salvarButtonContent: {
    minHeight: 44,
  },
  salvarButtonLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
  },

  // Botao adicionar
  addButton: {
    marginHorizontal: spacing.lg,
    marginBottom: spacing.lg,
    borderRadius: components.button.borderRadius,
  },
  addButtonContent: {
    minHeight: components.button.minHeight,
  },
  addButtonLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
  },

  // Lista
  listTitle: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    paddingHorizontal: spacing.lg,
    paddingTop: spacing.md,
    paddingBottom: spacing.sm,
  },
  remItem: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.lg,
    backgroundColor: colors.surface,
    minHeight: 56,
  },
  remItemLeft: {
    flex: 1,
    marginRight: spacing.md,
  },
  remItemHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  tipoChip: {
    backgroundColor: colors.secondaryLight + '30',
    height: 24,
  },
  tipoChipText: {
    fontSize: 11,
    color: colors.secondary,
    fontWeight: typography.fontWeightMedium,
  },
  remData: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },
  remObs: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: spacing.xs,
  },
  remValor: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.success,
  },

  emptyList: {
    flexGrow: 1,
  },
  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default RemuneracaoScreen;
