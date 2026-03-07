/**
 * Formulario de novo custo do eGranja.
 *
 * Campos: categoria (dropdown com 8 opcoes), descricao, valor (R$), data.
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

interface NovoCustoRouteParams {
  loteId: string;
}

interface FormErrors {
  categoria?: string;
  descricao?: string;
  valor?: string;
}

// ==========================================
// OPCOES
// ==========================================

const CATEGORIAS_CUSTO = [
  { value: 'mao_de_obra', label: 'Mao de obra' },
  { value: 'energia', label: 'Energia eletrica' },
  { value: 'aquecimento', label: 'Aquecimento (gas/lenha)' },
  { value: 'cama', label: 'Cama do aviario' },
  { value: 'manutencao', label: 'Manutencao' },
  { value: 'depreciacao', label: 'Depreciacao' },
  { value: 'agua', label: 'Agua' },
  { value: 'outros', label: 'Outros' },
];

// ==========================================
// COMPONENTE
// ==========================================

const NovoCustoScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ NovoCusto: NovoCustoRouteParams }, 'NovoCusto'>>();
  const { loteId } = route.params;

  const [categoria, setCategoria] = useState('');
  const [descricao, setDescricao] = useState('');
  const [valor, setValor] = useState('');
  const [data, setData] = useState(new Date());
  const [errors, setErrors] = useState<FormErrors>({});
  const [submitting, setSubmitting] = useState(false);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const descricaoRef = useRef<any>(null);
  const valorRef = useRef<any>(null);

  /** Converte string monetaria BR para numero */
  const parseValor = useCallback((text: string): number => {
    // Remove R$, pontos de milhar e troca virgula por ponto
    const cleaned = text
      .replace(/R\$\s?/, '')
      .replace(/\./g, '')
      .replace(',', '.');
    return parseFloat(cleaned) || 0;
  }, []);

  /** Formata entrada de valor monetario */
  const handleValorChange = useCallback((text: string) => {
    // Permitir apenas digitos e virgula
    const cleaned = text.replace(/[^0-9,]/g, '');
    setValor(cleaned);
  }, []);

  const validate = useCallback((): boolean => {
    const newErrors: FormErrors = {};

    if (!categoria) {
      newErrors.categoria = 'Selecione a categoria.';
    }
    if (!descricao.trim()) {
      newErrors.descricao = 'Informe a descricao.';
    }
    const valorNum = parseValor(valor);
    if (!valor.trim() || valorNum <= 0) {
      newErrors.valor = 'Informe um valor valido.';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [categoria, descricao, valor, parseValor]);

  const handleSubmit = useCallback(async () => {
    if (!validate()) return;

    setSubmitting(true);
    try {
      await apiPost(`/lotes/${loteId}/financeiro/custos`, {
        categoria,
        descricao: descricao.trim(),
        valor: parseValor(valor),
        data: dayjs(data).format('YYYY-MM-DD'),
      });

      setSnackbarMessage('Custo registrado com sucesso.');
      setSnackbarVisible(true);

      setTimeout(() => {
        navigation.goBack();
      }, 1000);
    } catch (error) {
      console.error('[NovoCusto] Erro ao salvar:', error);
      setSnackbarMessage('Erro ao salvar. Tente novamente.');
      setSnackbarVisible(true);
    } finally {
      setSubmitting(false);
    }
  }, [validate, loteId, categoria, descricao, valor, data, parseValor, navigation]);

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Novo Custo"
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
          <DropdownField
            label="Categoria"
            value={categoria}
            options={CATEGORIAS_CUSTO}
            onSelect={setCategoria}
            placeholder="Selecione a categoria..."
            required
            error={errors.categoria}
          />

          <FormField
            label="Descricao"
            value={descricao}
            onChangeText={setDescricao}
            placeholder="Descricao do custo"
            required
            error={errors.descricao}
            inputRef={descricaoRef}
            returnKeyType="next"
            onSubmitEditing={() => valorRef.current?.focus()}
          />

          <FormField
            label="Valor"
            value={valor}
            onChangeText={handleValorChange}
            placeholder="0,00"
            required
            error={errors.valor}
            keyboardType="decimal-pad"
            leftIcon="currency-brl"
            inputRef={valorRef}
            helperText="Informe o valor em reais (R$)"
          />

          <DatePickerField
            label="Data"
            value={data}
            onChange={setData}
            required
            maximumDate={new Date()}
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
            Salvar custo
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

export default NovoCustoScreen;
