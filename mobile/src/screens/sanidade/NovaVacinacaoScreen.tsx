/**
 * Formulario de nova vacinacao do eGranja.
 *
 * Campos: data, tipo vacina, lote do produto, via administracao,
 * responsavel, observacao.
 */

import React, { useState, useCallback, useRef } from 'react';
import {
  View,
  Text,
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

interface NovaVacinacaoRouteParams {
  loteId: string;
}

interface FormErrors {
  vacina?: string;
  lote_produto?: string;
  via?: string;
  responsavel?: string;
}

// ==========================================
// OPCOES
// ==========================================

const VIAS_ADMINISTRACAO = [
  { value: 'ocular', label: 'Ocular (gota no olho)' },
  { value: 'bico', label: 'Via bico (agua de bebida)' },
  { value: 'spray', label: 'Spray (nebulizacao)' },
  { value: 'subcutanea', label: 'Subcutanea' },
  { value: 'intramuscular', label: 'Intramuscular' },
  { value: 'membrana_alar', label: 'Membrana alar' },
  { value: 'outra', label: 'Outra' },
];

// ==========================================
// COMPONENTE
// ==========================================

const NovaVacinacaoScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ NovaVacinacao: NovaVacinacaoRouteParams }, 'NovaVacinacao'>>();
  const { loteId } = route.params;

  // Form state
  const [data, setData] = useState(new Date());
  const [vacina, setVacina] = useState('');
  const [loteProduto, setLoteProduto] = useState('');
  const [via, setVia] = useState('');
  const [responsavel, setResponsavel] = useState('');
  const [observacao, setObservacao] = useState('');
  const [errors, setErrors] = useState<FormErrors>({});
  const [submitting, setSubmitting] = useState(false);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  // Refs para navegacao entre campos
  const loteProdutoRef = useRef<any>(null);
  const responsavelRef = useRef<any>(null);
  const observacaoRef = useRef<any>(null);

  const validate = useCallback((): boolean => {
    const newErrors: FormErrors = {};

    if (!vacina.trim()) {
      newErrors.vacina = 'Informe o tipo de vacina.';
    }
    if (!loteProduto.trim()) {
      newErrors.lote_produto = 'Informe o lote do produto.';
    }
    if (!via) {
      newErrors.via = 'Selecione a via de administracao.';
    }
    if (!responsavel.trim()) {
      newErrors.responsavel = 'Informe o responsavel.';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [vacina, loteProduto, via, responsavel]);

  const handleSubmit = useCallback(async () => {
    if (!validate()) return;

    setSubmitting(true);
    try {
      await apiPost(`/lotes/${loteId}/vacinacoes`, {
        data: dayjs(data).format('YYYY-MM-DD'),
        vacina: vacina.trim(),
        lote_produto: loteProduto.trim(),
        via_administracao: via,
        responsavel: responsavel.trim(),
        observacao: observacao.trim() || undefined,
      });

      setSnackbarMessage('Vacinacao registrada com sucesso.');
      setSnackbarVisible(true);

      setTimeout(() => {
        navigation.goBack();
      }, 1000);
    } catch (error) {
      console.error('[NovaVacinacao] Erro ao salvar:', error);
      setSnackbarMessage('Erro ao salvar. Tente novamente.');
      setSnackbarVisible(true);
    } finally {
      setSubmitting(false);
    }
  }, [validate, loteId, data, vacina, loteProduto, via, responsavel, observacao, navigation]);

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Nova Vacinacao"
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
            label="Data"
            value={data}
            onChange={setData}
            required
            maximumDate={new Date()}
          />

          <FormField
            label="Tipo de vacina"
            value={vacina}
            onChangeText={setVacina}
            placeholder="Ex: Newcastle, Gumboro, Bronquite..."
            required
            error={errors.vacina}
            returnKeyType="next"
            onSubmitEditing={() => loteProdutoRef.current?.focus()}
          />

          <FormField
            label="Lote do produto"
            value={loteProduto}
            onChangeText={setLoteProduto}
            placeholder="Numero do lote da vacina"
            required
            error={errors.lote_produto}
            inputRef={loteProdutoRef}
            returnKeyType="next"
            onSubmitEditing={() => responsavelRef.current?.focus()}
          />

          <DropdownField
            label="Via de administracao"
            value={via}
            options={VIAS_ADMINISTRACAO}
            onSelect={setVia}
            placeholder="Selecione a via..."
            required
            error={errors.via}
          />

          <FormField
            label="Responsavel"
            value={responsavel}
            onChangeText={setResponsavel}
            placeholder="Nome do responsavel pela vacinacao"
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
            Salvar vacinacao
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

export default NovaVacinacaoScreen;
