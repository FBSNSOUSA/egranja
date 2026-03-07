/**
 * Tela de Novo Consumo de Agua no eGranja.
 *
 * Campos:
 * - Data (padrao hoje)
 * - Leitura hidrometro (L) ou quantidade direta
 * - Calculos automaticos exibidos: consumo/ave, relacao agua/racao
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
import { useIndicadoresStore } from '@stores/indicadoresStore';
import { FormField } from '@components/FormField';
import { DatePickerField } from '@components/DatePickerField';
import {
  colors,
  typography,
  spacing,
  borders,
  components,
  getWaterFeedRatioColor,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface NovoConsumoAguaScreenProps {
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

export const NovoConsumoAguaScreen: React.FC<NovoConsumoAguaScreenProps> = ({ route, navigation }) => {
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
    criarConsumoAgua,
    clearMessages,
    errorMessage,
    successMessage,
    loteSelecionado,
    consumosRacao,
  } = useLoteStore();

  const indicadores = useIndicadoresStore((state) => state.indicadores);

  // Calculos automaticos
  const calculos = useMemo(() => {
    const qtd = parseFloat(quantidade.replace(',', '.'));
    if (isNaN(qtd) || qtd <= 0) return null;

    const avesVivas = indicadores?.avesVivas || (loteSelecionado?.quantidade || 1);

    // Consumo por ave em mL
    const consumoPorAve = (qtd * 1000) / avesVivas;

    // Relacao agua/racao (consumo de agua do dia / consumo de racao do dia)
    const hoje = dayjs(data).format('YYYY-MM-DD');
    const consumoRacaoDia = consumosRacao
      .filter((c) => dayjs(c.data).format('YYYY-MM-DD') === hoje)
      .reduce((acc, c) => acc + c.quantidadeKg, 0);

    const relacaoAguaRacao = consumoRacaoDia > 0 ? qtd / consumoRacaoDia : 0;

    return { consumoPorAve, relacaoAguaRacao, consumoRacaoDia };
  }, [quantidade, data, indicadores, loteSelecionado, consumosRacao]);

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

    await criarConsumoAgua(loteId, {
      data: dayjs(data).format('YYYY-MM-DD'),
      quantidadeLitros: parseFloat(quantidade.replace(',', '.')),
    });
  }, [data, quantidade, loteId, validate, criarConsumoAgua, clearMessages]);

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
          label="Data"
          value={data}
          onChange={setData}
          required
          maximumDate={new Date()}
        />

        {/* Quantidade */}
        <FormField
          label="Leitura do Hidrometro / Consumo"
          value={quantidade}
          onChangeText={setQuantidade}
          keyboardType="numeric"
          placeholder="Ex: 3500"
          error={errors.quantidade}
          required
          suffix="L"
          leftIcon="water"
          helperText="Informe a leitura do hidrometro em litros ou o consumo direto do dia."
        />

        {/* Calculos automaticos */}
        {calculos && (
          <View style={styles.calculosContainer}>
            <Text style={styles.calculosTitulo}>Calculos Automaticos</Text>

            <View style={styles.calculoRow}>
              <Text style={styles.calculoLabel}>Consumo por ave</Text>
              <Text style={styles.calculoValue}>
                {calculos.consumoPorAve.toFixed(0)} mL/ave
              </Text>
            </View>

            {calculos.consumoRacaoDia > 0 && (
              <View style={styles.calculoRow}>
                <Text style={styles.calculoLabel}>Consumo racao do dia</Text>
                <Text style={styles.calculoValue}>
                  {calculos.consumoRacaoDia.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} kg
                </Text>
              </View>
            )}

            {calculos.relacaoAguaRacao > 0 && (
              <View style={styles.calculoRow}>
                <Text style={styles.calculoLabel}>Relacao agua/racao</Text>
                <Text
                  style={[
                    styles.calculoValueBold,
                    { color: getWaterFeedRatioColor(calculos.relacaoAguaRacao) },
                  ]}
                >
                  {calculos.relacaoAguaRacao.toFixed(1)}
                </Text>
              </View>
            )}

            {calculos.relacaoAguaRacao > 0 &&
              (calculos.relacaoAguaRacao < 1.6 || calculos.relacaoAguaRacao > 2.0) && (
              <View style={styles.alertaContainer}>
                <Text style={styles.alertaText}>
                  Relacao agua/racao fora da faixa ideal (1,6 a 2,0).
                  Verifique possivel problema sanitario ou de equipamento.
                </Text>
              </View>
            )}

            {calculos.relacaoAguaRacao === 0 && (
              <Text style={styles.calculoHint}>
                Registre o consumo de racao do dia para calcular a relacao agua/racao.
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

  // Calculos
  calculosContainer: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginBottom: spacing.lg,
    borderWidth: 1,
    borderColor: colors.divider,
  },
  calculosTitulo: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
  },
  calculoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.xs,
  },
  calculoLabel: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  calculoValue: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },
  calculoValueBold: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },
  calculoHint: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    fontStyle: 'italic',
    marginTop: spacing.sm,
  },

  // Alerta
  alertaContainer: {
    backgroundColor: colors.dangerLight,
    borderRadius: borders.radiusM,
    padding: spacing.md,
    marginTop: spacing.sm,
    borderLeftWidth: 3,
    borderLeftColor: colors.danger,
  },
  alertaText: {
    fontSize: typography.fontSizeXS,
    color: colors.danger,
    lineHeight: typography.fontSizeXS * 1.5,
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

export default NovoConsumoAguaScreen;
