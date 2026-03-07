/**
 * Hub de relatorios do eGranja.
 *
 * Funcionalidades:
 * - Card "Fechamento de Lote" - gera PDF via API, compartilha
 * - Card "Comparativo entre Lotes" - tabela comparativa
 * - Card "Exportar CSV" - download dados brutos
 * - Card "Relatorio Financeiro" - PDF financeiro
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  Share,
  RefreshControl,
} from 'react-native';
import { Appbar, IconButton, Snackbar, ActivityIndicator } from 'react-native-paper';
import { useNavigation, DrawerActions } from '@react-navigation/native';
import * as FileSystem from 'expo-file-system';
import * as Sharing from 'expo-sharing';
import { apiGet, apiPost } from '@services/api';
import { DropdownField } from '@components/DropdownField';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  components,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface LoteOption {
  id: string;
  nome: string;
  status: string;
}

interface ReportCard {
  id: string;
  titulo: string;
  descricao: string;
  icone: string;
  cor: string;
  corFundo: string;
  tipo: 'fechamento' | 'comparativo' | 'csv' | 'financeiro';
}

// ==========================================
// CONSTANTES
// ==========================================

const REPORTS: ReportCard[] = [
  {
    id: 'fechamento',
    titulo: 'Fechamento de Lote',
    descricao: 'Relatorio completo com todos os indicadores consolidados. Formato aceito por integradoras.',
    icone: 'file-document',
    cor: colors.primary,
    corFundo: colors.dangerLight,
    tipo: 'fechamento',
  },
  {
    id: 'comparativo',
    titulo: 'Comparativo entre Lotes',
    descricao: 'Tabela comparativa de indicadores lado a lado: peso, mortalidade, CA, IEP, GPD.',
    icone: 'table',
    cor: colors.secondary,
    corFundo: '#E3F2FD',
    tipo: 'comparativo',
  },
  {
    id: 'csv',
    titulo: 'Exportar CSV',
    descricao: 'Dados brutos de pesagens, mortalidade, consumo de racao e agua para analise em planilhas.',
    icone: 'file-delimited',
    cor: colors.success,
    corFundo: colors.successLight,
    tipo: 'csv',
  },
  {
    id: 'financeiro',
    titulo: 'Relatorio Financeiro',
    descricao: 'PDF com breakdown de custos e receitas. Grafico de evolucao de resultado por lote.',
    icone: 'cash-register',
    cor: '#E65100',
    corFundo: colors.warningLight,
    tipo: 'financeiro',
  },
];

// ==========================================
// COMPONENTE
// ==========================================

const RelatoriosScreen: React.FC = () => {
  const navigation = useNavigation<any>();

  const [lotes, setLotes] = useState<LoteOption[]>([]);
  const [selectedLoteId, setSelectedLoteId] = useState('');
  const [loadingReport, setLoadingReport] = useState<string | null>(null);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');
  const [refreshing, setRefreshing] = useState(false);

  // Carregar lotes
  useEffect(() => {
    carregarLotes();
  }, []);

  const carregarLotes = useCallback(async () => {
    try {
      const response = await apiGet<LoteOption[]>('/lotes', {
        incluir_finalizados: true,
      });
      setLotes(response.data);
      if (response.data.length > 0 && !selectedLoteId) {
        setSelectedLoteId(response.data[0].id);
      }
    } catch (error) {
      console.error('[Relatorios] Erro ao carregar lotes:', error);
    }
  }, [selectedLoteId]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarLotes();
    setRefreshing(false);
  }, [carregarLotes]);

  const showSnackbar = useCallback((message: string) => {
    setSnackbarMessage(message);
    setSnackbarVisible(true);
  }, []);

  /** Gera e compartilha relatorio PDF */
  const gerarPDF = useCallback(
    async (tipo: string) => {
      if (!selectedLoteId) {
        showSnackbar('Selecione um lote primeiro.');
        return;
      }

      setLoadingReport(tipo);
      try {
        const endpoint =
          tipo === 'financeiro'
            ? `/lotes/${selectedLoteId}/financeiro/relatorio-pdf`
            : `/lotes/${selectedLoteId}/relatorios/${tipo}`;

        const response = await apiPost<{ url: string; nome: string }>(endpoint);

        // Compartilhar
        await Share.share({
          title: response.data.nome,
          url: response.data.url,
          message: `Relatorio eGranja: ${response.data.nome}`,
        });

        showSnackbar('Relatorio gerado com sucesso.');
      } catch (error) {
        console.error(`[Relatorios] Erro ao gerar ${tipo}:`, error);
        showSnackbar('Erro ao gerar relatorio.');
      } finally {
        setLoadingReport(null);
      }
    },
    [selectedLoteId, showSnackbar],
  );

  /** Exporta CSV */
  const exportarCSV = useCallback(async () => {
    if (!selectedLoteId) {
      showSnackbar('Selecione um lote primeiro.');
      return;
    }

    setLoadingReport('csv');
    try {
      const response = await apiPost<{ url: string; nome: string }>(
        `/lotes/${selectedLoteId}/relatorios/csv`,
      );

      await Share.share({
        title: response.data.nome,
        url: response.data.url,
        message: `Dados eGranja: ${response.data.nome}`,
      });

      showSnackbar('CSV exportado com sucesso.');
    } catch (error) {
      console.error('[Relatorios] Erro ao exportar CSV:', error);
      showSnackbar('Erro ao exportar CSV.');
    } finally {
      setLoadingReport(null);
    }
  }, [selectedLoteId, showSnackbar]);

  /** Navega para tela de comparativo */
  const abrirComparativo = useCallback(() => {
    navigation.navigate('ComparativoLotes');
  }, [navigation]);

  /** Handler de clique no card */
  const handleCardPress = useCallback(
    (report: ReportCard) => {
      switch (report.tipo) {
        case 'fechamento':
          gerarPDF('fechamento');
          break;
        case 'comparativo':
          abrirComparativo();
          break;
        case 'csv':
          exportarCSV();
          break;
        case 'financeiro':
          gerarPDF('financeiro');
          break;
      }
    },
    [gerarPDF, abrirComparativo, exportarCSV],
  );

  const lotesOptions = lotes.map((l) => ({
    value: l.id,
    label: l.nome,
    subtitle: l.status === 'ativo' ? 'Ativo' : 'Finalizado',
  }));

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.Action
          icon="menu"
          color={colors.textOnPrimary}
          onPress={() => navigation.dispatch(DrawerActions.openDrawer())}
        />
        <Appbar.Content
          title="Relatorios"
          titleStyle={styles.headerTitle}
        />
      </Appbar.Header>

      <ScrollView
        style={styles.scrollView}
        contentContainerStyle={styles.scrollContent}
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[colors.primary]}
          />
        }
      >
        {/* Seletor de lote */}
        <View style={styles.selectorContainer}>
          <DropdownField
            label="Lote"
            value={selectedLoteId}
            options={lotesOptions}
            onSelect={setSelectedLoteId}
            placeholder="Selecione o lote..."
            searchable={lotes.length > 5}
          />
        </View>

        {/* Cards de relatorios */}
        {REPORTS.map((report) => {
          const isLoading = loadingReport === report.tipo;

          return (
            <TouchableOpacity
              key={report.id}
              style={styles.reportCard}
              onPress={() => handleCardPress(report)}
              activeOpacity={0.7}
              disabled={isLoading}
            >
              <View
                style={[
                  styles.reportIconContainer,
                  { backgroundColor: report.corFundo },
                ]}
              >
                {isLoading ? (
                  <ActivityIndicator size={28} color={report.cor} />
                ) : (
                  <IconButton
                    icon={report.icone}
                    iconColor={report.cor}
                    size={28}
                    style={styles.reportIcon}
                  />
                )}
              </View>

              <View style={styles.reportContent}>
                <Text style={styles.reportTitulo}>{report.titulo}</Text>
                <Text style={styles.reportDescricao}>{report.descricao}</Text>
              </View>

              <IconButton
                icon="chevron-right"
                iconColor={colors.gray400}
                size={24}
                style={styles.reportArrow}
              />
            </TouchableOpacity>
          );
        })}
      </ScrollView>

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
  header: {
    backgroundColor: colors.primary,
  },
  headerTitle: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    paddingBottom: spacing.huge,
  },
  selectorContainer: {
    padding: spacing.lg,
    backgroundColor: colors.surface,
    marginBottom: spacing.sm,
  },

  // Report cards
  reportCard: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.surface,
    marginHorizontal: spacing.lg,
    marginTop: spacing.md,
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    ...shadows.small,
    minHeight: 88,
  },
  reportIconContainer: {
    width: 56,
    height: 56,
    borderRadius: borders.radiusL,
    justifyContent: 'center',
    alignItems: 'center',
    marginRight: spacing.md,
  },
  reportIcon: {
    margin: 0,
    padding: 0,
  },
  reportContent: {
    flex: 1,
  },
  reportTitulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.xs,
  },
  reportDescricao: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    lineHeight: typography.fontSizeXS * 1.4,
  },
  reportArrow: {
    margin: 0,
  },

  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default RelatoriosScreen;
