/**
 * Tela de Detalhes do Galpao do eGranja.
 *
 * Funcionalidades:
 * - Informacoes do galpao: nome, dimensoes, orientacao, ventilacao, cortinas
 * - Card com lat/lon e link para Google Maps
 * - Componente GalpaoWindSunView com visualizacao de vento e sol
 * - Lista de lotes (ativo + historico)
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  ActivityIndicator,
  Linking,
} from 'react-native';
import { Appbar, Button, IconButton, Divider } from 'react-native-paper';
import { useNavigation, useRoute } from '@react-navigation/native';
import dayjs from 'dayjs';
import { apiGet } from '@services/api';
import { GalpaoWindSunView } from '@components/GalpaoWindSunView';
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

interface LoteHistorico {
  id: string;
  data_alojamento: string;
  data_finalizacao?: string;
  quantidade: number;
  aves_entregues?: number;
  status: 'ativo' | 'finalizado';
  mortalidade_pct?: number;
  peso_medio_final?: number;
}

interface GalpaoDetalhe {
  id: string;
  nome: string;
  largura_m: number;
  comprimento_m: number;
  orientacao_graus: number;
  orientacao_texto: string;
  ventilacao: string;
  cortinas: string;
  cortinas_abertas: boolean;
  latitude: number;
  longitude: number;
  capacidade: number;
  lotes: LoteHistorico[];
  clima?: {
    vento_velocidade: number;
    vento_direcao: number;
    temperatura_externa: number;
  };
}

// ==========================================
// COMPONENTE DE INFORMACAO
// ==========================================

interface InfoRowProps {
  icone: string;
  label: string;
  valor: string;
}

const InfoRow: React.FC<InfoRowProps> = ({ icone, label, valor }) => (
  <View style={styles.infoRow}>
    <IconButton icon={icone} iconColor={colors.secondary} size={20} style={styles.infoIcone} />
    <Text style={styles.infoLabel}>{label}</Text>
    <Text style={styles.infoValor}>{valor}</Text>
  </View>
);

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================

const GalpaoDetalheScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<any>();
  const galpaoId = route.params?.galpaoId || '';

  const [galpao, setGalpao] = useState<GalpaoDetalhe | null>(null);
  const [isLoading, setIsLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);

  const carregarDados = useCallback(async () => {
    if (!galpaoId) return;
    try {
      const response = await apiGet<GalpaoDetalhe>(`/galpoes/${galpaoId}`);
      setGalpao(response.data);
    } catch {
      setGalpao(null);
    } finally {
      setIsLoading(false);
      setRefreshing(false);
    }
  }, [galpaoId]);

  useEffect(() => {
    carregarDados();
  }, [carregarDados]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    carregarDados();
  }, [carregarDados]);

  // Abrir Google Maps
  const abrirGoogleMaps = useCallback(() => {
    if (!galpao) return;
    const url = `https://www.google.com/maps/search/?api=1&query=${galpao.latitude},${galpao.longitude}`;
    Linking.openURL(url);
  }, [galpao]);

  // Navegar para lote
  const navegarParaLote = useCallback((loteId: string, loteNome?: string) => {
    navigation.navigate('Home', {
      screen: 'LoteDetail',
      params: { loteId, loteNome },
    });
  }, [navigation]);

  if (isLoading) {
    return (
      <View style={styles.container}>
        <Appbar.Header style={styles.header}>
          <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
          <Appbar.Content title="Detalhes do Galpao" titleStyle={styles.headerTitle} color={colors.textOnPrimary} />
        </Appbar.Header>
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={styles.loadingText}>Carregando...</Text>
        </View>
      </View>
    );
  }

  if (!galpao) {
    return (
      <View style={styles.container}>
        <Appbar.Header style={styles.header}>
          <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
          <Appbar.Content title="Detalhes do Galpao" titleStyle={styles.headerTitle} color={colors.textOnPrimary} />
        </Appbar.Header>
        <View style={styles.emptyContainer}>
          <IconButton icon="barn" iconColor={colors.gray400} size={64} />
          <Text style={styles.emptyTitulo}>Galpao nao encontrado</Text>
        </View>
      </View>
    );
  }

  const loteAtivo = galpao.lotes.find((l) => l.status === 'ativo');
  const lotesFinalizados = galpao.lotes.filter((l) => l.status === 'finalizado');

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
        <Appbar.Content
          title={galpao.nome}
          titleStyle={styles.headerTitle}
          color={colors.textOnPrimary}
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
        {/* Informacoes do galpao */}
        <View style={styles.card}>
          <Text style={styles.cardTitulo}>Informacoes</Text>
          <InfoRow icone="resize" label="Dimensoes" valor={`${galpao.largura_m}m x ${galpao.comprimento_m}m`} />
          <InfoRow icone="compass" label="Orientacao" valor={`${galpao.orientacao_texto} (${galpao.orientacao_graus}\u00B0)`} />
          <InfoRow icone="fan" label="Ventilacao" valor={galpao.ventilacao} />
          <InfoRow icone="curtains" label="Cortinas" valor={galpao.cortinas} />
          <InfoRow icone="account-group" label="Capacidade" valor={`${galpao.capacidade.toLocaleString('pt-BR')} aves`} />
        </View>

        {/* Localizacao */}
        <View style={styles.card}>
          <Text style={styles.cardTitulo}>Localizacao</Text>
          <View style={styles.coordenadas}>
            <Text style={styles.coordenadaTexto}>
              Lat: {galpao.latitude.toFixed(6)} | Lon: {galpao.longitude.toFixed(6)}
            </Text>
          </View>
          <Button
            mode="outlined"
            onPress={abrirGoogleMaps}
            icon="google-maps"
            style={styles.botaoMaps}
            contentStyle={styles.botaoMapsContent}
            labelStyle={styles.botaoMapsLabel}
            textColor={colors.secondary}
          >
            Abrir no Google Maps
          </Button>
        </View>

        {/* Visualizacao Vento/Sol */}
        {galpao.clima && (
          <View style={styles.card}>
            <Text style={styles.cardTitulo}>Visualizacao Vento e Sol</Text>
            <GalpaoWindSunView
              largura={galpao.largura_m}
              comprimento={galpao.comprimento_m}
              orientacaoGraus={galpao.orientacao_graus}
              ventoVelocidade={galpao.clima.vento_velocidade}
              ventoDirecao={galpao.clima.vento_direcao}
              temperaturaExterna={galpao.clima.temperatura_externa}
              cortinasAbertas={galpao.cortinas_abertas}
            />
          </View>
        )}

        {/* Lote ativo */}
        {loteAtivo && (
          <View style={styles.card}>
            <View style={styles.cardTituloRow}>
              <Text style={styles.cardTitulo}>Lote Ativo</Text>
              <View style={[styles.statusBadge, { backgroundColor: colors.successLight }]}>
                <View style={[styles.statusDot, { backgroundColor: colors.success }]} />
                <Text style={[styles.statusTexto, { color: colors.success }]}>Ativo</Text>
              </View>
            </View>
            <InfoRow icone="calendar" label="Alojamento" valor={dayjs(loteAtivo.data_alojamento).format('DD/MM/YYYY')} />
            <InfoRow icone="bird" label="Quantidade" valor={loteAtivo.quantidade.toLocaleString('pt-BR')} />
            <Button
              mode="contained"
              onPress={() => navegarParaLote(loteAtivo.id)}
              icon="eye"
              style={styles.botaoVerLote}
              contentStyle={styles.botaoVerLoteContent}
              labelStyle={styles.botaoVerLoteLabel}
              buttonColor={colors.primary}
              textColor={colors.textOnPrimary}
            >
              Ver detalhes do lote
            </Button>
          </View>
        )}

        {/* Historico de lotes */}
        {lotesFinalizados.length > 0 && (
          <View style={styles.card}>
            <Text style={styles.cardTitulo}>Historico de Lotes</Text>
            {lotesFinalizados.map((lote, index) => (
              <View key={lote.id}>
                {index > 0 && <Divider style={styles.divider} />}
                <TouchableOpacityLote
                  lote={lote}
                  onPress={() => navegarParaLote(lote.id)}
                />
              </View>
            ))}
          </View>
        )}
      </ScrollView>
    </View>
  );
};

// Componente auxiliar para lote no historico
const TouchableOpacityLote: React.FC<{
  lote: LoteHistorico;
  onPress: () => void;
}> = ({ lote, onPress }) => {
  const { TouchableOpacity } = require('react-native');

  return (
    <TouchableOpacity onPress={onPress} style={styles.historicoItem} activeOpacity={0.7}>
      <View style={styles.historicoInfo}>
        <Text style={styles.historicoData}>
          {dayjs(lote.data_alojamento).format('DD/MM/YYYY')}
          {lote.data_finalizacao ? ` - ${dayjs(lote.data_finalizacao).format('DD/MM/YYYY')}` : ''}
        </Text>
        <Text style={styles.historicoDetalhe}>
          {lote.quantidade.toLocaleString('pt-BR')} aves alojadas
          {lote.aves_entregues ? ` | ${lote.aves_entregues.toLocaleString('pt-BR')} entregues` : ''}
        </Text>
        {lote.mortalidade_pct !== undefined && (
          <Text style={styles.historicoIndicador}>
            Mortalidade: {lote.mortalidade_pct.toFixed(2).replace('.', ',')}%
            {lote.peso_medio_final ? ` | Peso medio: ${lote.peso_medio_final.toFixed(0)}g` : ''}
          </Text>
        )}
      </View>
      <IconButton icon="chevron-right" iconColor={colors.gray500} size={20} />
    </TouchableOpacity>
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
    padding: spacing.lg,
    paddingBottom: spacing.huge,
  },

  // Card
  card: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    marginBottom: spacing.lg,
    ...shadows.medium,
  },
  cardTitulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.lg,
  },
  cardTituloRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    marginBottom: spacing.lg,
  },

  // Info row
  infoRow: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
  },
  infoIcone: {
    margin: 0,
    padding: 0,
    marginRight: spacing.sm,
  },
  infoLabel: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    flex: 1,
  },
  infoValor: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },

  // Coordenadas
  coordenadas: {
    backgroundColor: colors.gray100,
    borderRadius: borders.radiusM,
    padding: spacing.md,
    marginBottom: spacing.md,
  },
  coordenadaTexto: {
    fontSize: typography.fontSizeXS,
    fontFamily: 'monospace',
    color: colors.textSecondary,
    textAlign: 'center',
  },

  // Botoes
  botaoMaps: {
    borderRadius: components.button.borderRadius,
    borderColor: colors.secondary,
  },
  botaoMapsContent: {
    minHeight: components.button.minHeight,
  },
  botaoMapsLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
  },
  botaoVerLote: {
    borderRadius: components.button.borderRadius,
    marginTop: spacing.md,
  },
  botaoVerLoteContent: {
    minHeight: components.button.minHeight,
  },
  botaoVerLoteLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
  },

  // Status badge
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: borders.radiusRound,
  },
  statusDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    marginRight: spacing.xs,
  },
  statusTexto: {
    fontSize: 12,
    fontWeight: typography.fontWeightMedium,
  },

  // Historico
  divider: {
    marginVertical: spacing.sm,
  },
  historicoItem: {
    flexDirection: 'row',
    alignItems: 'center',
    paddingVertical: spacing.sm,
  },
  historicoInfo: {
    flex: 1,
  },
  historicoData: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
  },
  historicoDetalhe: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },
  historicoIndicador: {
    fontSize: typography.fontSizeXS,
    color: colors.secondary,
    marginTop: 2,
  },

  // Loading / Empty
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    gap: spacing.md,
  },
  loadingText: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
  },
  emptyTitulo: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
});

export default GalpaoDetalheScreen;
