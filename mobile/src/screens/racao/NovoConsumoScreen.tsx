/**
 * Tela de Novo Consumo de Racao no eGranja.
 *
 * Campos:
 * - Data (padrao hoje)
 * - Quantidade kg consumida
 * - Saldo atualizado automaticamente (exibido em tempo real)
 */

import React, { useState, useCallback, useEffect, useMemo } from 'react';
import {
  View,
  Text,
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
import {
  colors,
  typography,
  spacing,
  borders,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface NovoConsumoScreenProps {
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
// COMPONENTE
// ==========================================

export const NovoConsumoScreen: React.FC<NovoConsumoScreenProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  // Estado do formulario
  const [data, setData] = useState(new Date());
  const [quantidade, setQuantidade] = useState('');

  // Erros
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Snackbar
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarType, setSnackbarType] = useState<'success' | 'error'>('success');

  // Store
  const {
    isSaving,
    criarConsumoRacao,
    clearMessages,
    errorMessage,
    successMessage,
    recebimentosRacao,
    consumosRacao,
  } = useLoteStore();

  // Saldo atual
  const saldoAtual = useMemo(() => {
    const totalRecebido = recebimentosRacao.reduce((acc, r) => acc + r.quantidadeKg, 0);
    const totalConsumido = consumosRacao.reduce((acc, c) => acc + c.quantidadeKg, 0);
    return totalRecebido - totalConsumido;
  }, [recebimentosRacao, consumosRacao]);

  // Saldo apos registro
  const saldoPosRegistro = useMemo(() => {
    const qtd = parseFloat(quantidade.replace(',', '.'));
    if (isNaN(qtd) || qtd <= 0) return saldoAtual;
    return saldoAtual - qtd;
  }, [saldoAtual, quantidade]);

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

    await criarConsumoRacao(loteId, {
      data: dayjs(data).format('YYYY-MM-DD'),
      quantidadeKg: parseFloat(quantidade.replace(',', '.')),
    });
  }, [data, quantidade, loteId, validate, criarConsumoRacao, clearMessages]);

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
        {/* Saldo atual */}
        <View style={styles.saldoContainer}>
          <Text style={styles.saldoLabel}>Saldo Atual de Racao</Text>
          <Text style={styles.saldoValue}>
            {saldoAtual.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} kg
          </Text>
        </View>

        {/* Data */}
        <DatePickerField
          label="Data do Consumo"
          value={data}
          onChange={setData}
          required
          maximumDate={new Date()}
        />

        {/* Quantidade */}
        <FormField
          label="Quantidade consumida"
          value={quantidade}
          onChangeText={setQuantidade}
          keyboardType="numeric"
          placeholder="Ex: 350"
          error={errors.quantidade}
          required
          suffix="kg"
          leftIcon="package-up"
        />

        {/* Saldo pos-registro */}
        {quantidade && !isNaN(parseFloat(quantidade.replace(',', '.'))) && (
          <View style={styles.saldoPosContainer}>
            <Text style={styles.saldoPosLabel}>Saldo apos registro</Text>
            <Text
              style={[
                styles.saldoPosValue,
                { color: saldoPosRegistro < 0 ? colors.danger : colors.success },
              ]}
            >
              {saldoPosRegistro.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} kg
            </Text>
            {saldoPosRegistro < 0 && (
              <Text style={styles.saldoPosWarning}>
                Atencao: o saldo ficara negativo!
              </Text>
            )}
          </View>
        )}

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
          {isSaving ? 'Salvando...' : 'Registrar Consumo'}
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

  // Saldo atual
  saldoContainer: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginBottom: spacing.lg,
    alignItems: 'center',
    borderWidth: 1,
    borderColor: colors.divider,
  },
  saldoLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
    marginBottom: spacing.xs,
  },
  saldoValue: {
    fontSize: typography.fontSizeXXL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },

  // Saldo pos-registro
  saldoPosContainer: {
    backgroundColor: colors.gray100,
    borderRadius: borders.radiusM,
    padding: spacing.md,
    marginBottom: spacing.lg,
    alignItems: 'center',
  },
  saldoPosLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontWeight: typography.fontWeightMedium,
    marginBottom: spacing.xs,
  },
  saldoPosValue: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
  },
  saldoPosWarning: {
    fontSize: typography.fontSizeXS,
    color: colors.danger,
    fontWeight: typography.fontWeightMedium,
    marginTop: spacing.xs,
  },

  // Botao Salvar
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

export default NovoConsumoScreen;
