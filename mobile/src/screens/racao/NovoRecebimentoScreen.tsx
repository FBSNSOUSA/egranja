/**
 * Tela de Novo Recebimento de Racao no eGranja.
 *
 * Campos:
 * - Data (padrao hoje)
 * - Quantidade kg
 * - Tipo racao (dropdown)
 * - Fornecedor (opcional)
 * - Lote da racao (opcional, rastreabilidade)
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { Button, Snackbar } from 'react-native-paper';
import dayjs from 'dayjs';
import { useLoteStore } from '@stores/loteStore';
import { FormField } from '@components/FormField';
import { DatePickerField } from '@components/DatePickerField';
import { DropdownField, DropdownOption } from '@components/DropdownField';
import {
  colors,
  typography,
  spacing,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface NovoRecebimentoScreenProps {
  route: {
    params: {
      loteId: string;
    };
  };
  navigation: {
    goBack: () => void;
  };
}

// ==========================================
// CONSTANTES
// ==========================================

const TIPOS_RACAO: DropdownOption[] = [
  { value: 'Pre-Inicial', label: 'Pre-Inicial', subtitle: '1 a 7 dias' },
  { value: 'Inicial', label: 'Inicial', subtitle: '8 a 21 dias' },
  { value: 'Crescimento', label: 'Crescimento', subtitle: '22 a 35 dias' },
  { value: 'Finalizacao', label: 'Finalizacao', subtitle: '36+ dias' },
];

// ==========================================
// COMPONENTE
// ==========================================

export const NovoRecebimentoScreen: React.FC<NovoRecebimentoScreenProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  // Estado do formulario
  const [data, setData] = useState(new Date());
  const [quantidade, setQuantidade] = useState('');
  const [tipoRacao, setTipoRacao] = useState('');
  const [fornecedor, setFornecedor] = useState('');
  const [loteRacao, setLoteRacao] = useState('');

  // Erros
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Snackbar
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarType, setSnackbarType] = useState<'success' | 'error'>('success');

  // Store
  const {
    isSaving,
    criarRecebimentoRacao,
    clearMessages,
    errorMessage,
    successMessage,
  } = useLoteStore();

  // Feedback
  useEffect(() => {
    if (errorMessage) {
      setSnackbarMessage(errorMessage);
      setSnackbarType('error');
      setSnackbarVisible(true);
    }
    if (successMessage) {
      setSnackbarMessage(successMessage);
      setSnackbarType('success');
      setSnackbarVisible(true);
      setTimeout(() => navigation.goBack(), 1500);
    }
  }, [errorMessage, successMessage, navigation]);

  // Validacao
  const validate = useCallback((): boolean => {
    const newErrors: Record<string, string> = {};

    const qtd = parseFloat(quantidade.replace(',', '.'));
    if (!quantidade || isNaN(qtd) || qtd <= 0) {
      newErrors.quantidade = 'Informe uma quantidade valida (maior que zero).';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [quantidade]);

  // Salvar
  const handleSalvar = useCallback(async () => {
    clearMessages();

    if (!validate()) return;

    await criarRecebimentoRacao(loteId, {
      dataRecebimento: dayjs(data).format('YYYY-MM-DD'),
      quantidadeKg: parseFloat(quantidade.replace(',', '.')),
      tipoRacaoNome: tipoRacao || undefined,
      fornecedor: fornecedor.trim() || undefined,
      loteRacao: loteRacao.trim() || undefined,
    });
  }, [
    data, quantidade, tipoRacao, fornecedor, loteRacao, loteId,
    validate, criarRecebimentoRacao, clearMessages,
  ]);

  return (
    <KeyboardAvoidingView
      style={styles.container}
      behavior={Platform.OS === 'ios' ? 'padding' : 'height'}
    >
      <ScrollView
        contentContainerStyle={styles.scrollContent}
        keyboardShouldPersistTaps="handled"
        showsVerticalScrollIndicator={false}
      >
        {/* Data */}
        <DatePickerField
          label="Data do Recebimento"
          value={data}
          onChange={setData}
          required
          maximumDate={new Date()}
        />

        {/* Quantidade */}
        <FormField
          label="Quantidade"
          value={quantidade}
          onChangeText={setQuantidade}
          keyboardType="numeric"
          placeholder="Ex: 5000"
          error={errors.quantidade}
          required
          suffix="kg"
          leftIcon="sack"
        />

        {/* Tipo de racao */}
        <DropdownField
          label="Tipo de Racao"
          value={tipoRacao}
          options={TIPOS_RACAO}
          onSelect={setTipoRacao}
          placeholder="Selecione o tipo"
        />

        {/* Fornecedor */}
        <FormField
          label="Fornecedor"
          value={fornecedor}
          onChangeText={setFornecedor}
          placeholder="Nome do fornecedor (opcional)"
          leftIcon="truck"
        />

        {/* Lote da racao */}
        <FormField
          label="Lote da Racao"
          value={loteRacao}
          onChangeText={setLoteRacao}
          placeholder="Codigo do lote (rastreabilidade)"
          helperText="Conforme Portaria SDA 798/2023"
          leftIcon="barcode"
        />

        {/* Botao Salvar */}
        <Button
          mode="contained"
          onPress={handleSalvar}
          loading={isSaving}
          disabled={isSaving}
          style={styles.saveButton}
          contentStyle={styles.saveButtonContent}
          labelStyle={styles.saveButtonLabel}
          buttonColor={colors.primary}
          textColor={colors.textOnPrimary}
          icon="content-save"
        >
          {isSaving ? 'Salvando...' : 'Registrar Recebimento'}
        </Button>
      </ScrollView>

      {/* Snackbar */}
      <Snackbar
        visible={snackbarVisible}
        onDismiss={() => {
          setSnackbarVisible(false);
          clearMessages();
        }}
        duration={3000}
        style={{
          backgroundColor: snackbarType === 'success' ? colors.success : colors.danger,
        }}
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
  scrollContent: {
    padding: spacing.lg,
    paddingBottom: spacing.huge,
  },
  saveButton: {
    marginTop: spacing.xl,
    borderRadius: components.button.borderRadius,
  },
  saveButtonContent: {
    minHeight: components.buttonLarge.minHeight,
  },
  saveButtonLabel: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },
});

export default NovoRecebimentoScreen;
