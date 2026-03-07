/**
 * Formulario de novo visitante do eGranja.
 *
 * Campos: nome, documento, origem, motivo, ultimo contato com aves
 * (DatePicker), placa do veiculo.
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
import {
  colors,
  typography,
  spacing,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface NovoVisitanteRouteParams {
  loteId: string;
}

interface FormErrors {
  nome?: string;
  origem?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

const NovoVisitanteScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ NovoVisitante: NovoVisitanteRouteParams }, 'NovoVisitante'>>();
  const { loteId } = route.params;

  // Form state
  const [nome, setNome] = useState('');
  const [documento, setDocumento] = useState('');
  const [origem, setOrigem] = useState('');
  const [motivo, setMotivo] = useState('');
  const [ultimoContatoAves, setUltimoContatoAves] = useState<Date | undefined>(undefined);
  const [hasContatoAves, setHasContatoAves] = useState(false);
  const [placaVeiculo, setPlacaVeiculo] = useState('');
  const [errors, setErrors] = useState<FormErrors>({});
  const [submitting, setSubmitting] = useState(false);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const documentoRef = useRef<any>(null);
  const origemRef = useRef<any>(null);
  const motivoRef = useRef<any>(null);
  const placaRef = useRef<any>(null);

  const validate = useCallback((): boolean => {
    const newErrors: FormErrors = {};

    if (!nome.trim()) {
      newErrors.nome = 'Informe o nome do visitante.';
    }
    if (!origem.trim()) {
      newErrors.origem = 'Informe a origem do visitante.';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [nome, origem]);

  const handleSubmit = useCallback(async () => {
    if (!validate()) return;

    setSubmitting(true);
    try {
      await apiPost(`/lotes/${loteId}/visitantes`, {
        nome: nome.trim(),
        documento: documento.trim() || undefined,
        origem: origem.trim(),
        motivo: motivo.trim() || undefined,
        ultimo_contato_aves: hasContatoAves && ultimoContatoAves
          ? ultimoContatoAves.toISOString()
          : undefined,
        placa_veiculo: placaVeiculo.trim().toUpperCase() || undefined,
        entrada_at: new Date().toISOString(),
      });

      setSnackbarMessage('Visitante registrado com sucesso.');
      setSnackbarVisible(true);

      setTimeout(() => {
        navigation.goBack();
      }, 1000);
    } catch (error) {
      console.error('[NovoVisitante] Erro ao salvar:', error);
      setSnackbarMessage('Erro ao salvar. Tente novamente.');
      setSnackbarVisible(true);
    } finally {
      setSubmitting(false);
    }
  }, [validate, loteId, nome, documento, origem, motivo, hasContatoAves, ultimoContatoAves, placaVeiculo, navigation]);

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Registrar Visitante"
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
          <FormField
            label="Nome"
            value={nome}
            onChangeText={setNome}
            placeholder="Nome completo do visitante"
            required
            error={errors.nome}
            leftIcon="account"
            returnKeyType="next"
            onSubmitEditing={() => documentoRef.current?.focus()}
          />

          <FormField
            label="Documento"
            value={documento}
            onChangeText={setDocumento}
            placeholder="CPF, RG ou outro (opcional)"
            leftIcon="card-account-details"
            inputRef={documentoRef}
            returnKeyType="next"
            onSubmitEditing={() => origemRef.current?.focus()}
          />

          <FormField
            label="Origem"
            value={origem}
            onChangeText={setOrigem}
            placeholder="Empresa ou cidade de origem"
            required
            error={errors.origem}
            leftIcon="map-marker"
            inputRef={origemRef}
            returnKeyType="next"
            onSubmitEditing={() => motivoRef.current?.focus()}
          />

          <FormField
            label="Motivo da visita"
            value={motivo}
            onChangeText={setMotivo}
            placeholder="Motivo da visita (opcional)"
            leftIcon="text"
            inputRef={motivoRef}
            returnKeyType="next"
            onSubmitEditing={() => placaRef.current?.focus()}
          />

          <DatePickerField
            label="Ultimo contato com aves"
            value={ultimoContatoAves || new Date()}
            onChange={(date) => {
              setUltimoContatoAves(date);
              setHasContatoAves(true);
            }}
            maximumDate={new Date()}
            helperText="Selecione a data do ultimo contato com aves. Se < 48h, um alerta de vazio sanitario sera exibido."
          />

          <FormField
            label="Placa do veiculo"
            value={placaVeiculo}
            onChangeText={setPlacaVeiculo}
            placeholder="ABC-1234 (opcional)"
            leftIcon="car"
            inputRef={placaRef}
            autoCapitalize="characters"
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
            Registrar entrada
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

export default NovoVisitanteScreen;
