/**
 * Formulario de novo medicamento do eGranja.
 *
 * Campos: data inicio, data fim, medicamento, dosagem, via,
 * periodo de carencia (dias), responsavel.
 */

import React, { useState, useCallback, useRef } from 'react';
import {
  View,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
} from 'react-native';
import { Appbar, Button, Snackbar } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import dayjs from 'dayjs';
import { apiPost } from '@services/api';
import { FormField } from '@components/FormField';
import { DatePickerField } from '@components/DatePickerField';
import { DropdownField } from '@components/DropdownField';
import {
  colors,
  typography,
  spacing,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface NovoMedicamentoRouteParams {
  loteId: string;
}

interface FormErrors {
  medicamento?: string;
  dosagem?: string;
  via?: string;
  periodo_carencia?: string;
  responsavel?: string;
  datas?: string;
}

// ==========================================
// OPCOES
// ==========================================

const VIAS_MEDICAMENTO = [
  { value: 'oral', label: 'Oral (agua de bebida)' },
  { value: 'racao', label: 'Via racao' },
  { value: 'injetavel', label: 'Injetavel' },
  { value: 'topica', label: 'Topica' },
  { value: 'inalacao', label: 'Inalacao (nebulizacao)' },
  { value: 'outra', label: 'Outra' },
];

// ==========================================
// COMPONENTE
// ==========================================

const NovoMedicamentoScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ NovoMedicamento: NovoMedicamentoRouteParams }, 'NovoMedicamento'>>();
  const { loteId } = route.params;

  // Form state
  const [dataInicio, setDataInicio] = useState(new Date());
  const [dataFim, setDataFim] = useState(new Date());
  const [medicamento, setMedicamento] = useState('');
  const [dosagem, setDosagem] = useState('');
  const [via, setVia] = useState('');
  const [periodoCarencia, setPeriodoCarencia] = useState('');
  const [responsavel, setResponsavel] = useState('');
  const [observacao, setObservacao] = useState('');
  const [errors, setErrors] = useState<FormErrors>({});
  const [submitting, setSubmitting] = useState(false);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const dosagemRef = useRef<any>(null);
  const carenciaRef = useRef<any>(null);
  const responsavelRef = useRef<any>(null);
  const observacaoRef = useRef<any>(null);

  const validate = useCallback((): boolean => {
    const newErrors: FormErrors = {};

    if (!medicamento.trim()) {
      newErrors.medicamento = 'Informe o medicamento.';
    }
    if (!dosagem.trim()) {
      newErrors.dosagem = 'Informe a dosagem.';
    }
    if (!via) {
      newErrors.via = 'Selecione a via de administracao.';
    }
    if (!periodoCarencia.trim() || isNaN(Number(periodoCarencia))) {
      newErrors.periodo_carencia = 'Informe o periodo de carencia em dias.';
    }
    if (!responsavel.trim()) {
      newErrors.responsavel = 'Informe o responsavel.';
    }
    if (dayjs(dataFim).isBefore(dayjs(dataInicio))) {
      newErrors.datas = 'Data fim deve ser posterior a data inicio.';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [medicamento, dosagem, via, periodoCarencia, responsavel, dataInicio, dataFim]);

  const handleSubmit = useCallback(async () => {
    if (!validate()) return;

    setSubmitting(true);
    try {
      await apiPost(`/lotes/${loteId}/medicamentos`, {
        data_inicio: dayjs(dataInicio).format('YYYY-MM-DD'),
        data_fim: dayjs(dataFim).format('YYYY-MM-DD'),
        medicamento: medicamento.trim(),
        dosagem: dosagem.trim(),
        via,
        periodo_carencia_dias: Number(periodoCarencia),
        responsavel: responsavel.trim(),
        observacao: observacao.trim() || undefined,
      });

      setSnackbarMessage('Medicamento registrado com sucesso.');
      setSnackbarVisible(true);

      setTimeout(() => {
        navigation.goBack();
      }, 1000);
    } catch (error) {
      console.error('[NovoMedicamento] Erro ao salvar:', error);
      setSnackbarMessage('Erro ao salvar. Tente novamente.');
      setSnackbarVisible(true);
    } finally {
      setSubmitting(false);
    }
  }, [validate, loteId, dataInicio, dataFim, medicamento, dosagem, via, periodoCarencia, responsavel, observacao, navigation]);

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Novo Medicamento"
          titleStyle={styles.headerTitle}
        />
      </Appbar.Header>

      <KeyboardAvoidingView
        style={styles.flex}
        behavior={Platform.OS === 'ios' ? 'padding' : undefined}
      >
        <ScrollView
          style={styles.flex}
          contentContainerStyle={styles.formContent}
          keyboardShouldPersistTaps="handled"
        >
          <DatePickerField
            label="Data inicio"
            value={dataInicio}
            onChange={setDataInicio}
            required
            maximumDate={new Date()}
            error={errors.datas}
          />

          <DatePickerField
            label="Data fim"
            value={dataFim}
            onChange={setDataFim}
            required
            minimumDate={dataInicio}
          />

          <FormField
            label="Medicamento"
            value={medicamento}
            onChangeText={setMedicamento}
            placeholder="Nome do medicamento"
            required
            error={errors.medicamento}
            returnKeyType="next"
            onSubmitEditing={() => dosagemRef.current?.focus()}
          />

          <FormField
            label="Dosagem"
            value={dosagem}
            onChangeText={setDosagem}
            placeholder="Ex: 1ml/L de agua"
            required
            error={errors.dosagem}
            inputRef={dosagemRef}
            returnKeyType="next"
          />

          <DropdownField
            label="Via de administracao"
            value={via}
            options={VIAS_MEDICAMENTO}
            onSelect={setVia}
            placeholder="Selecione a via..."
            required
            error={errors.via}
          />

          <FormField
            label="Periodo de carencia"
            value={periodoCarencia}
            onChangeText={setPeriodoCarencia}
            placeholder="Dias de carencia"
            required
            error={errors.periodo_carencia}
            keyboardType="numeric"
            suffix="dias"
            inputRef={carenciaRef}
            returnKeyType="next"
            onSubmitEditing={() => responsavelRef.current?.focus()}
          />

          <FormField
            label="Responsavel"
            value={responsavel}
            onChangeText={setResponsavel}
            placeholder="Nome do responsavel"
            required
            error={errors.responsavel}
            inputRef={responsavelRef}
            returnKeyType="next"
            onSubmitEditing={() => observacaoRef.current?.focus()}
          />

          <FormField
            label="Observacao"
            value={observacao}
            onChangeText={setObservacao}
            placeholder="Observacoes adicionais (opcional)"
            multiline
            numberOfLines={3}
            inputRef={observacaoRef}
          />

          <Button
            mode="contained"
            onPress={handleSubmit}
            loading={submitting}
            disabled={submitting}
            style={styles.submitButton}
            contentStyle={styles.submitButtonContent}
            labelStyle={styles.submitButtonLabel}
            buttonColor={colors.primary}
            textColor={colors.textOnPrimary}
          >
            Salvar medicamento
          </Button>
        </ScrollView>
      </KeyboardAvoidingView>

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
  flex: {
    flex: 1,
  },
  header: {
    backgroundColor: colors.primary,
  },
  headerTitle: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  formContent: {
    padding: spacing.lg,
    paddingBottom: spacing.huge,
  },
  submitButton: {
    marginTop: spacing.xl,
    borderRadius: components.button.borderRadius,
  },
  submitButtonContent: {
    minHeight: components.buttonLarge.minHeight,
  },
  submitButtonLabel: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },
  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default NovoMedicamentoScreen;
