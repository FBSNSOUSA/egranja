/**
 * Tela de Cadastro de Novo Lote no eGranja.
 *
 * Campos:
 * - Aviario (dropdown de galpoes)
 * - Data alojamento (DatePicker, padrao hoje)
 * - Data prevista abate (calculada +42 dias, editavel)
 * - Quantidade (inteiro > 0)
 * - Tipo: Femea/Macho/Misto (SegmentedButtons)
 * - Linhagem: Cobb 500, Ross 308, Hubbard, Outra (Dropdown)
 * - Peso inicial (padrao 42g)
 * - Salvar offline se sem internet
 */

import React, { useState, useEffect, useCallback } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Alert,
} from 'react-native';
import {
  Button,
  SegmentedButtons,
  Snackbar,
  ActivityIndicator,
} from 'react-native-paper';
import dayjs from 'dayjs';
import { useLoteStore, NovoLotePayload } from '@stores/loteStore';
import { useSyncStore } from '@stores/syncStore';
import { FormField } from '@components/FormField';
import { DatePickerField } from '@components/DatePickerField';
import { DropdownField, DropdownOption } from '@components/DropdownField';
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

interface NovoLoteScreenProps {
  navigation: {
    goBack: () => void;
  };
}

// ==========================================
// CONSTANTES
// ==========================================

const LINHAGEM_OPTIONS: DropdownOption[] = [
  { value: 'Cobb 500', label: 'Cobb 500', subtitle: 'Peso inicial padrao: 42g' },
  { value: 'Ross 308', label: 'Ross 308', subtitle: 'Peso inicial padrao: 42g' },
  { value: 'Hubbard', label: 'Hubbard', subtitle: 'Peso inicial padrao: 40g' },
  { value: 'Outra', label: 'Outra' },
];

const TIPO_OPTIONS = [
  { value: 'Femea', label: 'Femea' },
  { value: 'Macho', label: 'Macho' },
  { value: 'Misto', label: 'Misto' },
];

const PESO_INICIAL_PADRAO: Record<string, number> = {
  'Cobb 500': 42,
  'Ross 308': 42,
  'Hubbard': 40,
  'Outra': 42,
};

// ==========================================
// COMPONENTE
// ==========================================

export const NovoLoteScreen: React.FC<NovoLoteScreenProps> = ({ navigation }) => {
  // Estado do formulario
  const [galpaoId, setGalpaoId] = useState('');
  const [dataAlojamento, setDataAlojamento] = useState(new Date());
  const [dataPrevistaAbate, setDataPrevistaAbate] = useState(dayjs().add(42, 'day').toDate());
  const [quantidade, setQuantidade] = useState('');
  const [tipo, setTipo] = useState<'Femea' | 'Macho' | 'Misto'>('Misto');
  const [linhagem, setLinhagem] = useState('Cobb 500');
  const [pesoInicial, setPesoInicial] = useState('42');

  // Erros de validacao
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Snackbar
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarType, setSnackbarType] = useState<'success' | 'error'>('success');

  // Store
  const {
    galpaos,
    isSaving,
    errorMessage,
    successMessage,
    fetchGalpaos,
    criarLote,
    clearMessages,
  } = useLoteStore();
  const isOnline = useSyncStore((state) => state.isOnline);

  // Carregar galpoes ao montar
  useEffect(() => {
    fetchGalpaos();
  }, [fetchGalpaos]);

  // Recalcular data prevista quando data alojamento mudar
  useEffect(() => {
    setDataPrevistaAbate(dayjs(dataAlojamento).add(42, 'day').toDate());
  }, [dataAlojamento]);

  // Atualizar peso inicial ao mudar linhagem
  useEffect(() => {
    const peso = PESO_INICIAL_PADRAO[linhagem] || 42;
    setPesoInicial(String(peso));
  }, [linhagem]);

  // Exibir feedback do store
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
      // Voltar apos sucesso
      setTimeout(() => navigation.goBack(), 1500);
    }
  }, [errorMessage, successMessage, navigation]);

  // Opcoes de galpoes para o dropdown
  const galpaoOptions: DropdownOption[] = galpaos.map((g) => ({
    value: g.id,
    label: g.nome,
    subtitle: g.capacidade ? `Capacidade: ${g.capacidade.toLocaleString('pt-BR')} aves` : undefined,
  }));

  // Validacao
  const validate = useCallback((): boolean => {
    const newErrors: Record<string, string> = {};

    if (!galpaoId) {
      newErrors.galpao = 'Selecione um aviario.';
    }

    const qtd = parseInt(quantidade, 10);
    if (!quantidade || isNaN(qtd) || qtd <= 0) {
      newErrors.quantidade = 'Informe uma quantidade valida (maior que zero).';
    }

    const peso = parseFloat(pesoInicial.replace(',', '.'));
    if (!pesoInicial || isNaN(peso) || peso <= 0) {
      newErrors.pesoInicial = 'Informe um peso valido.';
    }

    setErrors(newErrors);
    return Object.keys(newErrors).length === 0;
  }, [galpaoId, quantidade, pesoInicial]);

  // Salvar
  const handleSalvar = useCallback(async () => {
    clearMessages();

    if (!validate()) return;

    const payload: NovoLotePayload = {
      galpaoId,
      dataAlojamento: dayjs(dataAlojamento).format('YYYY-MM-DD'),
      dataPrevistaAbate: dayjs(dataPrevistaAbate).format('YYYY-MM-DD'),
      quantidade: parseInt(quantidade, 10),
      tipo,
      linhagem: linhagem || undefined,
      pesoInicialG: parseFloat(pesoInicial.replace(',', '.')),
    };

    await criarLote(payload);
  }, [
    galpaoId, dataAlojamento, dataPrevistaAbate, quantidade,
    tipo, linhagem, pesoInicial, validate, criarLote, clearMessages,
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
        {/* Aviso offline */}
        {!isOnline && (
          <View style={styles.offlineWarning}>
            <Text style={styles.offlineText}>
              Voce esta offline. O lote sera salvo localmente e sincronizado quando houver conexao.
            </Text>
          </View>
        )}

        {/* Aviario */}
        <DropdownField
          label="Aviario"
          value={galpaoId}
          options={galpaoOptions}
          onSelect={setGalpaoId}
          placeholder="Selecione o galpao"
          error={errors.galpao}
          required
          searchable={galpaoOptions.length > 5}
        />

        {/* Data Alojamento */}
        <DatePickerField
          label="Data de Alojamento"
          value={dataAlojamento}
          onChange={setDataAlojamento}
          required
          maximumDate={new Date()}
        />

        {/* Data Prevista Abate */}
        <DatePickerField
          label="Data Prevista de Abate"
          value={dataPrevistaAbate}
          onChange={setDataPrevistaAbate}
          helperText="Calculada automaticamente (+42 dias). Editavel."
          minimumDate={dataAlojamento}
        />

        {/* Quantidade */}
        <FormField
          label="Quantidade de aves"
          value={quantidade}
          onChangeText={setQuantidade}
          keyboardType="number-pad"
          placeholder="Ex: 15000"
          error={errors.quantidade}
          required
          leftIcon="counter"
        />

        {/* Tipo */}
        <View style={styles.segmentedContainer}>
          <Text style={styles.segmentedLabel}>Tipo *</Text>
          <SegmentedButtons
            value={tipo}
            onValueChange={(value) => setTipo(value as 'Femea' | 'Macho' | 'Misto')}
            buttons={TIPO_OPTIONS}
            style={styles.segmentedButtons}
          />
        </View>

        {/* Linhagem */}
        <DropdownField
          label="Linhagem"
          value={linhagem}
          options={LINHAGEM_OPTIONS}
          onSelect={setLinhagem}
          helperText="A linhagem ativa comparacao automatica com benchmarks."
        />

        {/* Peso Inicial */}
        <FormField
          label="Peso Inicial"
          value={pesoInicial}
          onChangeText={setPesoInicial}
          keyboardType="numeric"
          error={errors.pesoInicial}
          suffix="g"
          helperText={`Padrao para ${linhagem}: ${PESO_INICIAL_PADRAO[linhagem] || 42}g`}
          leftIcon="scale"
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
          {isSaving ? 'Salvando...' : 'Salvar Lote'}
        </Button>
      </ScrollView>

      {/* Snackbar de feedback */}
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
        action={{
          label: 'Fechar',
          textColor: colors.white,
          onPress: () => setSnackbarVisible(false),
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

  // Aviso offline
  offlineWarning: {
    backgroundColor: colors.warningLight,
    borderRadius: borders.radiusM,
    padding: spacing.md,
    marginBottom: spacing.lg,
    borderLeftWidth: 4,
    borderLeftColor: colors.warning,
  },
  offlineText: {
    fontSize: typography.fontSizeS,
    color: colors.gray800,
    lineHeight: typography.fontSizeS * 1.5,
  },

  // Tipo (SegmentedButtons)
  segmentedContainer: {
    marginBottom: spacing.lg,
  },
  segmentedLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  segmentedButtons: {
    // Estilo padrao
  },

  // Botao Salvar
  saveButton: {
    marginTop: spacing.xl,
    borderRadius: components.button.borderRadius,
  },
  saveButtonContent: {
    minHeight: components.buttonLarge.minHeight,
    paddingVertical: spacing.sm,
  },
  saveButtonLabel: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },
});

export default NovoLoteScreen;
