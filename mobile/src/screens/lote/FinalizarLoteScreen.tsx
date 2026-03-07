/**
 * Tela de Finalizacao de Lote no eGranja.
 *
 * Campos:
 * - Data finalizacao
 * - Aves entregues ao abate
 * - Peso total entregue (kg)
 * - Sobra de racao (kg) - com opcao de transferir para proximo lote
 *
 * Exibe resumo dos indicadores finais apos confirmacao.
 */

import React, { useState, useCallback, useEffect, useMemo } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import { Button, Switch, Snackbar, Divider } from 'react-native-paper';
import dayjs from 'dayjs';
import { useLoteStore, FinalizarLotePayload } from '@stores/loteStore';
import { useIndicadoresStore } from '@stores/indicadoresStore';
import { FormField } from '@components/FormField';
import { DatePickerField } from '@components/DatePickerField';
import {
  colors,
  typography,
  spacing,
  borders,
  components,
  shadows,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface FinalizarLoteScreenProps {
  route: {
    params: {
      loteId: string;
    };
  };
  navigation: {
    goBack: () => void;
    navigate: (screen: string) => void;
  };
}

// ==========================================
// COMPONENTE
// ==========================================

export const FinalizarLoteScreen: React.FC<FinalizarLoteScreenProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  // Estado do formulario
  const [dataFinalizacao, setDataFinalizacao] = useState(new Date());
  const [avesEntregues, setAvesEntregues] = useState('');
  const [pesoTotalEntregue, setPesoTotalEntregue] = useState('');
  const [sobraRacao, setSobraRacao] = useState('');
  const [transferirSobra, setTransferirSobra] = useState(true);

  // Erros
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Snackbar
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarType, setSnackbarType] = useState<'success' | 'error'>('success');

  // Store
  const {
    isSaving,
    finalizarLote,
    clearMessages,
    errorMessage,
    successMessage,
    loteSelecionado,
  } = useLoteStore();

  const indicadores = useIndicadoresStore((state) => state.indicadores);

  // Pre-preencher com dados do lote
  useEffect(() => {
    if (indicadores) {
      setAvesEntregues(String(indicadores.avesVivas));
    }
    if (loteSelecionado) {
      if (loteSelecionado.saldoRacao) {
        setSobraRacao(String(loteSelecionado.saldoRacao));
      }
    }
  }, [indicadores, loteSelecionado]);

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
      setTimeout(() => {
        navigation.goBack();
      }, 2000);
    }
  }, [errorMessage, successMessage, navigation]);

  // Peso medio calculado
  const pesoMedioFinal = useMemo(() => {
    const aves = parseInt(avesEntregues, 10);
    const peso = parseFloat(pesoTotalEntregue.replace(',', '.'));
    if (isNaN(aves) || isNaN(peso) || aves <= 0) return null;
    return (peso / aves) * 1000; // Em gramas
  }, [avesEntregues, pesoTotalEntregue]);

  // Validacao
  const validate = useCallback((): boolean => {
    const newErrors: Record<string, string> = {};

    const aves = parseInt(avesEntregues, 10);
    if (!avesEntregues || isNaN(aves) || aves <= 0) {
      newErrors.avesEntregues = 'Informe a quantidade de aves entregues.';
    }

    const peso = parseFloat(pesoTotalEntregue.replace(',', '.'));
    if (!pesoTotalEntregue || isNaN(peso) || peso <= 0) {
      newErrors.pesoTotalEntregue = 'Informe o peso total entregue.';
    }

    const sobra = parseFloat(sobraRacao.replace(',', '.'));
    if (sobraRacao && (isNaN(sobra) || sobra < 0)) {
      newErrors.sobraRacao = 'Informe um valor valido para a sobra de racao.';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [avesEntregues, pesoTotalEntregue, sobraRacao]);

  // Confirmar e salvar
  const handleFinalizar = useCallback(() => {
    if (!validate()) return;

    Alert.alert(
      'Confirmar Finalizacao',
      'Ao finalizar, o lote ficara somente-leitura e sera movido para "Lotes Finalizados".\n\n' +
      'Tem certeza que deseja finalizar este lote?',
      [
        { text: 'Cancelar', style: 'cancel' },
        {
          text: 'Finalizar',
          style: 'destructive',
          onPress: async () => {
            clearMessages();

            const payload: FinalizarLotePayload = {
              dataFinalizacao: dayjs(dataFinalizacao).format('YYYY-MM-DD'),
              avesEntregues: parseInt(avesEntregues, 10),
              pesoTotalEntregue: parseFloat(pesoTotalEntregue.replace(',', '.')),
              sobraRacao: sobraRacao
                ? parseFloat(sobraRacao.replace(',', '.'))
                : undefined,
              transferirSobraProximoLote: transferirSobra,
            };

            await finalizarLote(loteId, payload);
          },
        },
      ],
    );
  }, [
    validate, dataFinalizacao, avesEntregues, pesoTotalEntregue,
    sobraRacao, transferirSobra, loteId, finalizarLote, clearMessages,
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
        {/* Aviso */}
        <View style={styles.warningContainer}>
          <Text style={styles.warningText}>
            Ao finalizar o lote, ele ficara em modo somente-leitura.
            Um relatorio de fechamento sera gerado automaticamente.
          </Text>
        </View>

        {/* Data Finalizacao */}
        <DatePickerField
          label="Data de Finalizacao"
          value={dataFinalizacao}
          onChange={setDataFinalizacao}
          required
          maximumDate={new Date()}
        />

        {/* Aves Entregues */}
        <FormField
          label="Aves entregues ao abate"
          value={avesEntregues}
          onChangeText={setAvesEntregues}
          keyboardType="number-pad"
          placeholder="Ex: 14500"
          error={errors.avesEntregues}
          required
          leftIcon="bird"
          helperText={
            indicadores
              ? `Aves vivas estimadas: ${indicadores.avesVivas.toLocaleString('pt-BR')}`
              : undefined
          }
        />

        {/* Peso Total Entregue */}
        <FormField
          label="Peso total entregue"
          value={pesoTotalEntregue}
          onChangeText={setPesoTotalEntregue}
          keyboardType="numeric"
          placeholder="Ex: 40250"
          error={errors.pesoTotalEntregue}
          required
          suffix="kg"
          leftIcon="scale"
        />

        {/* Peso medio calculado */}
        {pesoMedioFinal !== null && (
          <View style={styles.pesoMedioContainer}>
            <Text style={styles.pesoMedioLabel}>Peso medio final</Text>
            <Text style={styles.pesoMedioValue}>
              {pesoMedioFinal.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} g
            </Text>
          </View>
        )}

        <Divider style={styles.divider} />

        {/* Sobra de Racao */}
        <FormField
          label="Sobra de racao"
          value={sobraRacao}
          onChangeText={setSobraRacao}
          keyboardType="numeric"
          placeholder="Ex: 250"
          error={errors.sobraRacao}
          suffix="kg"
          leftIcon="sack"
          helperText={
            indicadores
              ? `Saldo estimado: ${indicadores.saldoRacao.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} kg`
              : undefined
          }
        />

        {/* Transferir sobra */}
        {sobraRacao && parseFloat(sobraRacao.replace(',', '.')) > 0 && (
          <View style={styles.switchRow}>
            <View style={styles.switchLabel}>
              <Text style={styles.switchTitle}>Transferir sobra</Text>
              <Text style={styles.switchSubtitle}>
                A sobra sera registrada como recebimento no proximo lote deste galpao.
              </Text>
            </View>
            <Switch
              value={transferirSobra}
              onValueChange={setTransferirSobra}
              color={colors.primary}
            />
          </View>
        )}

        {/* Botao Finalizar */}
        <Button
          mode="contained"
          onPress={handleFinalizar}
          loading={isSaving}
          disabled={isSaving}
          style={styles.finalizarButton}
          contentStyle={styles.finalizarButtonContent}
          labelStyle={styles.finalizarButtonLabel}
          buttonColor={colors.danger}
          textColor={colors.textOnPrimary}
          icon="check-circle"
        >
          {isSaving ? 'Finalizando...' : 'Finalizar Lote'}
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

  // Aviso
  warningContainer: {
    backgroundColor: colors.warningLight,
    borderRadius: borders.radiusM,
    padding: spacing.md,
    marginBottom: spacing.lg,
    borderLeftWidth: 4,
    borderLeftColor: colors.warning,
  },
  warningText: {
    fontSize: typography.fontSizeS,
    color: colors.gray800,
    lineHeight: typography.fontSizeS * 1.5,
  },

  // Peso medio
  pesoMedioContainer: {
    backgroundColor: colors.gray100,
    borderRadius: borders.radiusM,
    padding: spacing.md,
    marginBottom: spacing.md,
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
  },
  pesoMedioLabel: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  pesoMedioValue: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },

  // Divider
  divider: {
    marginVertical: spacing.lg,
  },

  // Switch
  switchRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    backgroundColor: colors.surface,
    borderRadius: borders.radiusM,
    padding: spacing.lg,
    marginBottom: spacing.lg,
    ...shadows.small,
  },
  switchLabel: {
    flex: 1,
    marginRight: spacing.md,
  },
  switchTitle: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  switchSubtitle: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
    lineHeight: typography.fontSizeXS * 1.5,
  },

  // Botao Finalizar
  finalizarButton: {
    marginTop: spacing.xl,
    borderRadius: components.button.borderRadius,
  },
  finalizarButtonContent: {
    minHeight: components.buttonLarge.minHeight,
  },
  finalizarButtonLabel: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },
});

export default FinalizarLoteScreen;
