/**
 * Tela de Novo Registro de Mortalidade no eGranja.
 *
 * Campos:
 * - Data (padrao hoje)
 * - Quantidade (inteiro > 0)
 * - Causa (Dropdown): Indefinida, Ascite, Morte Subita, etc.
 * - Observacao (texto opcional)
 * - Botao opcional captura de foto
 * - Alerta pos-salvar se mortalidade > 0.5%
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  KeyboardAvoidingView,
  Platform,
  Alert,
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
  borders,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface NovaMortalidadeScreenProps {
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

const CAUSAS_OPTIONS: DropdownOption[] = [
  { value: 'Indefinida', label: 'Indefinida' },
  { value: 'Ascite', label: 'Ascite', subtitle: 'Acumulo de liquido abdominal' },
  { value: 'Morte Subita', label: 'Morte Subita', subtitle: 'Sindrome da morte subita' },
  { value: 'Problemas Locomotores', label: 'Problemas Locomotores', subtitle: 'Pernas tortas, artrite' },
  { value: 'Refugo', label: 'Refugo', subtitle: 'Aves abaixo do peso, fracas' },
  { value: 'Onfalite', label: 'Onfalite', subtitle: 'Infeccao do umbigo' },
  { value: 'Infecciosa', label: 'Infecciosa', subtitle: 'Doenca infecciosa' },
  { value: 'Outra', label: 'Outra' },
];

// ==========================================
// COMPONENTE
// ==========================================

export const NovaMortalidadeScreen: React.FC<NovaMortalidadeScreenProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  // Estado do formulario
  const [data, setData] = useState(new Date());
  const [quantidade, setQuantidade] = useState('');
  const [causa, setCausa] = useState('Indefinida');
  const [observacao, setObservacao] = useState('');
  const [fotoUrl, setFotoUrl] = useState<string | undefined>();

  // Erros
  const [errors, setErrors] = useState<Record<string, string>>({});

  // Snackbar
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarType, setSnackbarType] = useState<'success' | 'error' | 'warning'>('success');

  // Store
  const {
    isSaving,
    criarMortalidade,
    loteSelecionado,
    clearMessages,
    errorMessage,
    successMessage,
  } = useLoteStore();

  // Feedback do store
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
    }
  }, [errorMessage, successMessage]);

  // Capturar foto (placeholder - requer biblioteca de camera)
  const handleCapturarFoto = useCallback(() => {
    Alert.alert(
      'Capturar Foto',
      'Funcionalidade de camera sera implementada com react-native-camera.',
      [{ text: 'OK' }],
    );
  }, []);

  // Validacao
  const validate = useCallback((): boolean => {
    const newErrors: Record<string, string> = {};

    const qtd = parseInt(quantidade, 10);
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

    const qtd = parseInt(quantidade, 10);
    const success = await criarMortalidade(loteId, {
      data: dayjs(data).format('YYYY-MM-DD'),
      quantidade: qtd,
      causa,
      observacao: observacao.trim() || undefined,
      fotoUrl,
    });

    if (success) {
      // Verificar se mortalidade > 0.5%
      const avesVivas = (loteSelecionado?.quantidade || 1) - (loteSelecionado?.mortalidadeAcumulada || 0);
      const pctMortalidade = (qtd / avesVivas) * 100;

      if (pctMortalidade > 0.5) {
        Alert.alert(
          'Atencao - Mortalidade Alta',
          `A mortalidade registrada hoje (${pctMortalidade.toFixed(2)}%) esta acima de 0,5%.\n\n` +
          'Recomenda-se verificar:\n' +
          '- Qualidade da agua\n' +
          '- Ventilacao do galpao\n' +
          '- Sinais de doencas\n\n' +
          'Considere contatar o tecnico.',
          [
            {
              text: 'Entendi',
              onPress: () => navigation.goBack(),
            },
          ],
        );
      } else {
        setTimeout(() => navigation.goBack(), 1500);
      }
    }
  }, [
    quantidade, data, causa, observacao, fotoUrl, loteId,
    validate, criarMortalidade, clearMessages, loteSelecionado, navigation,
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
          label="Data"
          value={data}
          onChange={setData}
          required
          maximumDate={new Date()}
        />

        {/* Quantidade */}
        <FormField
          label="Quantidade de mortes"
          value={quantidade}
          onChangeText={setQuantidade}
          keyboardType="number-pad"
          placeholder="Ex: 5"
          error={errors.quantidade}
          required
          leftIcon="alert-circle"
        />

        {/* Causa */}
        <DropdownField
          label="Causa"
          value={causa}
          options={CAUSAS_OPTIONS}
          onSelect={setCausa}
          required
        />

        {/* Observacao */}
        <FormField
          label="Observacao"
          value={observacao}
          onChangeText={setObservacao}
          placeholder="Detalhes adicionais (opcional)"
          multiline
          numberOfLines={3}
          leftIcon="text"
        />

        {/* Botao de foto */}
        <Button
          mode="outlined"
          onPress={handleCapturarFoto}
          icon="camera"
          style={styles.fotoButton}
          contentStyle={styles.fotoButtonContent}
          labelStyle={styles.fotoButtonLabel}
          textColor={colors.secondary}
        >
          {fotoUrl ? 'Foto capturada' : 'Capturar Foto (opcional)'}
        </Button>

        {/* Info de mortalidade atual */}
        {loteSelecionado && (
          <View style={styles.infoContainer}>
            <Text style={styles.infoTitle}>Informacao do Lote</Text>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Aves alojadas</Text>
              <Text style={styles.infoValue}>
                {loteSelecionado.quantidade.toLocaleString('pt-BR')}
              </Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Mortalidade acumulada</Text>
              <Text style={styles.infoValue}>
                {(loteSelecionado.mortalidadeAcumulada || 0).toLocaleString('pt-BR')}
              </Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Aves vivas</Text>
              <Text style={styles.infoValue}>
                {((loteSelecionado.quantidade || 0) - (loteSelecionado.mortalidadeAcumulada || 0)).toLocaleString('pt-BR')}
              </Text>
            </View>
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
          {isSaving ? 'Salvando...' : 'Registrar Mortalidade'}
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
          backgroundColor:
            snackbarType === 'success' ? colors.success :
            snackbarType === 'warning' ? colors.warning :
            colors.danger,
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

  // Foto
  fotoButton: {
    borderColor: colors.secondary,
    borderRadius: components.button.borderRadius,
    marginBottom: spacing.lg,
  },
  fotoButtonContent: {
    minHeight: components.button.minHeight,
  },
  fotoButtonLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
  },

  // Info do lote
  infoContainer: {
    backgroundColor: colors.gray100,
    borderRadius: borders.radiusM,
    padding: spacing.md,
    marginBottom: spacing.xl,
  },
  infoTitle: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    paddingVertical: 2,
  },
  infoLabel: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },
  infoValue: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },

  // Botao Salvar
  saveButton: {
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

export default NovaMortalidadeScreen;
