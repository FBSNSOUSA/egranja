/**
 * Tela de Nova Pesagem no eGranja.
 *
 * Funcionalidades:
 * - Lista de amostras (quantidade + peso total por amostra)
 * - Peso medio calculado automaticamente por amostra
 * - Botao "+" para adicionar amostra
 * - Rodape: peso medio total recalculado, indicador vs benchmark
 * - Botao "Finalizar Pesagem"
 * - KeyboardAvoidingView e teclado numerico
 */

import React, { useState, useCallback, useMemo } from 'react';
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
  IconButton,
  Snackbar,
  Divider,
} from 'react-native-paper';
import { useLoteStore } from '@stores/loteStore';
import { useIndicadoresStore } from '@stores/indicadoresStore';
import { FormField } from '@components/FormField';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  components,
  getWeightIndicatorColor,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface NovaPesagemScreenProps {
  route: {
    params: {
      loteId: string;
    };
  };
  navigation: {
    goBack: () => void;
  };
}

interface Amostra {
  id: string;
  quantidade: string;
  peso: string;
}

// ==========================================
// COMPONENTE
// ==========================================

export const NovaPesagemScreen: React.FC<NovaPesagemScreenProps> = ({ route, navigation }) => {
  const { loteId } = route.params;

  // Estado das amostras
  const [amostras, setAmostras] = useState<Amostra[]>([
    { id: '1', quantidade: '', peso: '' },
  ]);

  // Snackbar
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [snackbarType, setSnackbarType] = useState<'success' | 'error'>('success');

  // Store
  const { isSaving, criarPesagem, loteSelecionado, clearMessages } = useLoteStore();
  const indicadores = useIndicadoresStore((state) => state.indicadores);

  // Adicionar amostra
  const handleAdicionarAmostra = useCallback(() => {
    const novaId = String(Date.now());
    setAmostras((prev) => [...prev, { id: novaId, quantidade: '', peso: '' }]);
  }, []);

  // Remover amostra
  const handleRemoverAmostra = useCallback(
    (id: string) => {
      if (amostras.length <= 1) {
        Alert.alert('Atencao', 'E necessario pelo menos uma amostra.');
        return;
      }
      setAmostras((prev) => prev.filter((a) => a.id !== id));
    },
    [amostras.length],
  );

  // Atualizar campo da amostra
  const handleUpdateAmostra = useCallback(
    (id: string, field: 'quantidade' | 'peso', value: string) => {
      setAmostras((prev) =>
        prev.map((a) => (a.id === id ? { ...a, [field]: value } : a)),
      );
    },
    [],
  );

  // Calcular peso medio por amostra
  const calcularPesoMedioAmostra = useCallback(
    (amostra: Amostra): number | null => {
      const qtd = parseInt(amostra.quantidade, 10);
      const peso = parseFloat(amostra.peso.replace(',', '.'));
      if (isNaN(qtd) || isNaN(peso) || qtd <= 0) return null;
      return peso / qtd;
    },
    [],
  );

  // Calcular totais
  const totais = useMemo(() => {
    let totalQuantidade = 0;
    let totalPeso = 0;

    amostras.forEach((a) => {
      const qtd = parseInt(a.quantidade, 10);
      const peso = parseFloat(a.peso.replace(',', '.'));
      if (!isNaN(qtd) && !isNaN(peso) && qtd > 0) {
        totalQuantidade += qtd;
        totalPeso += peso;
      }
    });

    const pesoMedio = totalQuantidade > 0 ? totalPeso / totalQuantidade : 0;
    return { totalQuantidade, totalPeso, pesoMedio };
  }, [amostras]);

  // Cor do indicador vs benchmark
  const pesoColor = useMemo(() => {
    if (totais.pesoMedio <= 0 || !indicadores?.pesoBenchmark) return colors.text;
    return getWeightIndicatorColor(totais.pesoMedio * 1000, indicadores.pesoBenchmark);
  }, [totais.pesoMedio, indicadores]);

  // Desvio vs benchmark
  const desvioPct = useMemo(() => {
    if (totais.pesoMedio <= 0 || !indicadores?.pesoBenchmark || indicadores.pesoBenchmark <= 0) {
      return null;
    }
    return ((totais.pesoMedio * 1000) / indicadores.pesoBenchmark * 100 - 100);
  }, [totais.pesoMedio, indicadores]);

  // Validar e salvar
  const handleFinalizar = useCallback(async () => {
    clearMessages();

    // Validar amostras
    const itensValidos: Array<{ quantidade: number; peso: number }> = [];
    let hasError = false;

    amostras.forEach((a, index) => {
      const qtd = parseInt(a.quantidade, 10);
      const peso = parseFloat(a.peso.replace(',', '.'));

      if (isNaN(qtd) || qtd <= 0) {
        hasError = true;
      } else if (isNaN(peso) || peso <= 0) {
        hasError = true;
      } else {
        itensValidos.push({ quantidade: qtd, peso: peso * 1000 }); // Converter kg para g
      }
    });

    if (hasError || itensValidos.length === 0) {
      setSnackbarMessage('Preencha todas as amostras com valores validos.');
      setSnackbarType('error');
      setSnackbarVisible(true);
      return;
    }

    const success = await criarPesagem(loteId, itensValidos);
    if (success) {
      setSnackbarMessage('Pesagem registrada com sucesso!');
      setSnackbarType('success');
      setSnackbarVisible(true);
      setTimeout(() => navigation.goBack(), 1500);
    } else {
      const error = useLoteStore.getState().errorMessage;
      const successMsg = useLoteStore.getState().successMessage;
      if (successMsg) {
        setSnackbarMessage(successMsg);
        setSnackbarType('success');
        setSnackbarVisible(true);
        setTimeout(() => navigation.goBack(), 1500);
      } else {
        setSnackbarMessage(error || 'Erro ao registrar pesagem.');
        setSnackbarType('error');
        setSnackbarVisible(true);
      }
    }
  }, [amostras, loteId, criarPesagem, clearMessages, navigation]);

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
        {/* Instrucoes */}
        <View style={styles.instrucoes}>
          <Text style={styles.instrucoesText}>
            Informe a quantidade de aves e o peso total (em kg) de cada amostra.
            O peso medio sera calculado automaticamente.
          </Text>
        </View>

        {/* Lista de amostras */}
        {amostras.map((amostra, index) => {
          const pesoMedioAmostra = calcularPesoMedioAmostra(amostra);

          return (
            <View key={amostra.id} style={styles.amostraContainer}>
              <View style={styles.amostraHeader}>
                <Text style={styles.amostraTitle}>
                  Amostra {index + 1}
                </Text>
                {amostras.length > 1 && (
                  <IconButton
                    icon="close-circle"
                    iconColor={colors.danger}
                    size={22}
                    onPress={() => handleRemoverAmostra(amostra.id)}
                    style={styles.removeButton}
                  />
                )}
              </View>

              <View style={styles.amostraFields}>
                <View style={styles.fieldHalf}>
                  <FormField
                    label="Qtd. aves"
                    value={amostra.quantidade}
                    onChangeText={(v) => handleUpdateAmostra(amostra.id, 'quantidade', v)}
                    keyboardType="number-pad"
                    placeholder="Ex: 50"
                    leftIcon="bird"
                  />
                </View>
                <View style={styles.fieldHalf}>
                  <FormField
                    label="Peso total (kg)"
                    value={amostra.peso}
                    onChangeText={(v) => handleUpdateAmostra(amostra.id, 'peso', v)}
                    keyboardType="numeric"
                    placeholder="Ex: 75,5"
                    leftIcon="scale"
                  />
                </View>
              </View>

              {pesoMedioAmostra !== null && (
                <Text style={styles.pesoMedioAmostra}>
                  Peso medio: {(pesoMedioAmostra * 1000).toLocaleString('pt-BR', { maximumFractionDigits: 0 })} g
                </Text>
              )}
            </View>
          );
        })}

        {/* Botao adicionar amostra */}
        <Button
          mode="outlined"
          onPress={handleAdicionarAmostra}
          icon="plus"
          style={styles.addButton}
          contentStyle={styles.addButtonContent}
          labelStyle={styles.addButtonLabel}
          textColor={colors.primary}
        >
          Adicionar Amostra
        </Button>

        <Divider style={styles.divider} />

        {/* Rodape com totais */}
        <View style={styles.totaisContainer}>
          <Text style={styles.totaisTitle}>Resultado da Pesagem</Text>

          <View style={styles.totaisRow}>
            <Text style={styles.totaisLabel}>Aves pesadas</Text>
            <Text style={styles.totaisValue}>
              {totais.totalQuantidade.toLocaleString('pt-BR')}
            </Text>
          </View>
          <View style={styles.totaisRow}>
            <Text style={styles.totaisLabel}>Peso total</Text>
            <Text style={styles.totaisValue}>
              {totais.totalPeso.toLocaleString('pt-BR', { maximumFractionDigits: 1 })} kg
            </Text>
          </View>
          <View style={styles.totaisRow}>
            <Text style={styles.totaisLabel}>Peso medio</Text>
            <Text style={[styles.totaisValueBold, { color: pesoColor }]}>
              {totais.pesoMedio > 0
                ? `${(totais.pesoMedio * 1000).toLocaleString('pt-BR', { maximumFractionDigits: 0 })} g`
                : '-'
              }
            </Text>
          </View>

          {/* Benchmark */}
          {indicadores?.pesoBenchmark && totais.pesoMedio > 0 && (
            <>
              <View style={styles.totaisRow}>
                <Text style={styles.totaisLabel}>Peso padrao ({loteSelecionado?.linhagem || 'linhagem'})</Text>
                <Text style={styles.totaisValue}>
                  {indicadores.pesoBenchmark.toLocaleString('pt-BR', { maximumFractionDigits: 0 })} g
                </Text>
              </View>
              {desvioPct !== null && (
                <View style={styles.totaisRow}>
                  <Text style={styles.totaisLabel}>Desvio</Text>
                  <Text style={[styles.totaisValueBold, { color: pesoColor }]}>
                    {desvioPct >= 0 ? '+' : ''}{desvioPct.toFixed(1)}%
                  </Text>
                </View>
              )}
            </>
          )}
        </View>

        {/* Botao Finalizar */}
        <Button
          mode="contained"
          onPress={handleFinalizar}
          loading={isSaving}
          disabled={isSaving || totais.totalQuantidade === 0}
          style={styles.finalizarButton}
          contentStyle={styles.finalizarButtonContent}
          labelStyle={styles.finalizarButtonLabel}
          buttonColor={colors.primary}
          textColor={colors.textOnPrimary}
          icon="check"
        >
          {isSaving ? 'Salvando...' : 'Finalizar Pesagem'}
        </Button>
      </ScrollView>

      {/* Snackbar */}
      <Snackbar
        visible={snackbarVisible}
        onDismiss={() => setSnackbarVisible(false)}
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

  // Instrucoes
  instrucoes: {
    backgroundColor: colors.secondaryLight + '20',
    borderRadius: borders.radiusM,
    padding: spacing.md,
    marginBottom: spacing.lg,
  },
  instrucoesText: {
    fontSize: typography.fontSizeS,
    color: colors.secondary,
    lineHeight: typography.fontSizeS * 1.5,
  },

  // Amostra
  amostraContainer: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginBottom: spacing.md,
    ...shadows.small,
  },
  amostraHeader: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  amostraTitle: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  removeButton: {
    margin: 0,
    padding: 0,
  },
  amostraFields: {
    flexDirection: 'row',
    gap: spacing.md,
  },
  fieldHalf: {
    flex: 1,
  },
  pesoMedioAmostra: {
    fontSize: typography.fontSizeXS,
    color: colors.secondary,
    fontWeight: typography.fontWeightMedium,
    textAlign: 'right',
    marginTop: -spacing.sm,
  },

  // Botao adicionar
  addButton: {
    borderColor: colors.primary,
    borderStyle: 'dashed',
    borderRadius: borders.radiusM,
    marginBottom: spacing.lg,
  },
  addButtonContent: {
    minHeight: components.button.minHeight,
  },
  addButtonLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
  },

  // Divider
  divider: {
    marginVertical: spacing.md,
  },

  // Totais
  totaisContainer: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginBottom: spacing.xl,
    ...shadows.medium,
  },
  totaisTitle: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
  },
  totaisRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: spacing.xs,
  },
  totaisLabel: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  totaisValue: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },
  totaisValueBold: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
  },

  // Finalizar
  finalizarButton: {
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

export default NovaPesagemScreen;
