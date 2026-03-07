/**
 * Tela de Previsao do Tempo do eGranja.
 *
 * Funcionalidades:
 * - Card de condicao atual: temperatura, umidade, vento, precipitacao
 * - Alertas climaticos com cores de severidade
 * - Previsao 7 dias em cards horizontais
 * - Previsao por hora (hoje) com grafico de temperatura a cada 3h
 * - Dados de Open-Meteo
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  ActivityIndicator,
  Dimensions,
} from 'react-native';
import { Appbar, IconButton } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { LineChart } from 'react-native-chart-kit';
import dayjs from 'dayjs';
import 'dayjs/locale/pt-br';
import { apiGet } from '@services/api';
import { useLoteStore } from '@stores/loteStore';
import { DropdownField, DropdownOption } from '@components/DropdownField';
import {
  colors,
  typography,
  spacing,
  borders,
  shadows,
  chartConfig,
} from '@theme/index';

dayjs.locale('pt-br');

// ==========================================
// TIPOS
// ==========================================

interface CondicaoAtual {
  temperatura: number;
  sensacao_termica: number;
  umidade: number;
  vento_velocidade: number;
  vento_direcao: number;
  vento_direcao_texto: string;
  precipitacao: number;
  descricao: string;
  icone: string;
}

interface PrevisaoDia {
  data: string;
  dia_semana: string;
  temp_max: number;
  temp_min: number;
  umidade: number;
  probabilidade_chuva: number;
  icone: string;
  descricao: string;
}

interface PrevisaoHora {
  hora: string;
  temperatura: number;
  umidade: number;
  precipitacao: number;
}

interface AlertaClimatico {
  tipo: 'temperatura' | 'vento' | 'chuva';
  severidade: 'baixa' | 'media' | 'alta';
  titulo: string;
  descricao: string;
}

interface PrevisaoResponse {
  atual: CondicaoAtual;
  previsao_7dias: PrevisaoDia[];
  previsao_horaria: PrevisaoHora[];
}

interface AlertasResponse {
  alertas: AlertaClimatico[];
}

// ==========================================
// MAPEAMENTO DE ICONES
// ==========================================

const ICONES_CLIMA: Record<string, string> = {
  sol: 'weather-sunny',
  parcial: 'weather-partly-cloudy',
  nublado: 'weather-cloudy',
  chuva: 'weather-rainy',
  tempestade: 'weather-lightning-rainy',
  neve: 'weather-snowy',
  nevoeiro: 'weather-fog',
  default: 'weather-partly-cloudy',
};

const ICONES_ALERTA: Record<string, string> = {
  temperatura: 'thermometer-alert',
  vento: 'weather-windy',
  chuva: 'weather-pouring',
};

const CORES_SEVERIDADE: Record<string, string> = {
  baixa: colors.warning,
  media: '#FF9800',
  alta: colors.danger,
};

const CORES_SEVERIDADE_FUNDO: Record<string, string> = {
  baixa: colors.warningLight,
  media: '#FFF3E0',
  alta: colors.dangerLight,
};

const screenWidth = Dimensions.get('window').width;

// ==========================================
// COMPONENTE DE ALERTA CLIMATICO
// ==========================================

const AlertaCard: React.FC<{ alerta: AlertaClimatico }> = ({ alerta }) => {
  const cor = CORES_SEVERIDADE[alerta.severidade] || colors.warning;
  const corFundo = CORES_SEVERIDADE_FUNDO[alerta.severidade] || colors.warningLight;
  const icone = ICONES_ALERTA[alerta.tipo] || 'alert';

  return (
    <View style={[styles.alertaCard, { backgroundColor: corFundo, borderLeftColor: cor }]}>
      <IconButton icon={icone} iconColor={cor} size={24} style={styles.alertaIcone} />
      <View style={styles.alertaTextoContainer}>
        <Text style={[styles.alertaTitulo, { color: cor }]}>{alerta.titulo}</Text>
        <Text style={styles.alertaDescricao}>{alerta.descricao}</Text>
      </View>
    </View>
  );
};

// ==========================================
// COMPONENTE DE CARD DIARIO
// ==========================================

const PrevisaoDiaCard: React.FC<{ dia: PrevisaoDia }> = ({ dia }) => {
  const icone = ICONES_CLIMA[dia.icone] || ICONES_CLIMA.default;

  return (
    <View style={styles.diaCard}>
      <Text style={styles.diaSemana}>
        {dayjs(dia.data).format('ddd').replace('.', '')}
      </Text>
      <Text style={styles.diaData}>{dayjs(dia.data).format('DD/MM')}</Text>
      <IconButton icon={icone} iconColor={colors.secondary} size={28} style={styles.diaIcone} />
      <View style={styles.diaTemps}>
        <Text style={styles.diaTempMax}>{Math.round(dia.temp_max)}\u00B0</Text>
        <Text style={styles.diaTempMin}>{Math.round(dia.temp_min)}\u00B0</Text>
      </View>
      {dia.probabilidade_chuva > 0 && (
        <View style={styles.diaChuva}>
          <IconButton icon="water" iconColor={colors.secondary} size={12} style={styles.diaChuvaIcone} />
          <Text style={styles.diaChuvaTexto}>{dia.probabilidade_chuva}%</Text>
        </View>
      )}
    </View>
  );
};

// ==========================================
// FUNCAO AUXILIAR PARA DIRECAO DO VENTO
// ==========================================

function getRotacaoVento(graus: number): string {
  return `${graus}deg`;
}

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================

const ClimaScreen: React.FC = () => {
  const navigation = useNavigation();
  const lotes = useLoteStore((state) => state.lotes);

  const [previsao, setPrevisao] = useState<PrevisaoResponse | null>(null);
  const [alertas, setAlertas] = useState<AlertaClimatico[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [galpaoId, setGalpaoId] = useState<string>('');

  const galpoesOptions: DropdownOption[] = lotes
    .filter((l) => l.status === 'ativo')
    .reduce<DropdownOption[]>((acc, l) => {
      if (!acc.find((o) => o.value === l.galpaoId)) {
        acc.push({
          value: l.galpaoId,
          label: l.galpaoNome,
        });
      }
      return acc;
    }, []);

  useEffect(() => {
    if (!galpaoId && galpoesOptions.length > 0) {
      setGalpaoId(galpoesOptions[0].value);
    }
  }, [galpoesOptions, galpaoId]);

  // Carregar dados
  const carregarDados = useCallback(async () => {
    if (!galpaoId) return;
    try {
      const [previsaoRes, alertasRes] = await Promise.all([
        apiGet<PrevisaoResponse>(`/galpoes/${galpaoId}/clima/previsao`),
        apiGet<AlertasResponse>(`/galpoes/${galpaoId}/clima/alertas`),
      ]);
      setPrevisao(previsaoRes.data);
      setAlertas(alertasRes.data.alertas || []);
    } catch {
      // Manter dados anteriores
    } finally {
      setIsLoading(false);
      setRefreshing(false);
    }
  }, [galpaoId]);

  useEffect(() => {
    setIsLoading(true);
    carregarDados();
  }, [carregarDados]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    carregarDados();
  }, [carregarDados]);

  // Dados do grafico horario
  const chartDataHorario = previsao && previsao.previsao_horaria.length > 0
    ? {
        labels: previsao.previsao_horaria.map((h) => dayjs(h.hora).format('HH:mm')),
        datasets: [
          {
            data: previsao.previsao_horaria.map((h) => h.temperatura),
            color: () => colors.danger,
            strokeWidth: 2,
          },
        ],
      }
    : null;

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
        <Appbar.Content
          title="Previsao do Tempo"
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
        {/* Seletor de galpao */}
        {galpoesOptions.length > 1 && (
          <View style={styles.seletorGalpao}>
            <DropdownField
              label="Galpao"
              value={galpaoId}
              options={galpoesOptions}
              onSelect={(val) => {
                setGalpaoId(val);
                setIsLoading(true);
              }}
              placeholder="Selecione o galpao"
            />
          </View>
        )}

        {isLoading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color={colors.primary} />
            <Text style={styles.loadingText}>Carregando previsao...</Text>
          </View>
        ) : previsao ? (
          <>
            {/* Card condicao atual */}
            <View style={styles.atualCard}>
              <View style={styles.atualHeader}>
                <IconButton
                  icon={ICONES_CLIMA[previsao.atual.icone] || ICONES_CLIMA.default}
                  iconColor={colors.secondary}
                  size={48}
                />
                <View style={styles.atualInfo}>
                  <Text style={styles.atualDescricao}>{previsao.atual.descricao}</Text>
                  <Text style={styles.atualTemp}>
                    {Math.round(previsao.atual.temperatura)}\u00B0C
                  </Text>
                  <Text style={styles.atualSensacao}>
                    Sensacao: {Math.round(previsao.atual.sensacao_termica)}\u00B0C
                  </Text>
                </View>
              </View>

              <View style={styles.atualDetalhes}>
                {/* Umidade */}
                <View style={styles.detalheItem}>
                  <IconButton icon="water-percent" iconColor={colors.secondary} size={20} style={styles.detalheIcone} />
                  <Text style={styles.detalheLabel}>Umidade</Text>
                  <Text style={styles.detalheValor}>{previsao.atual.umidade}%</Text>
                </View>

                {/* Vento */}
                <View style={styles.detalheItem}>
                  <View style={styles.ventoContainer}>
                    <IconButton icon="weather-windy" iconColor={colors.secondary} size={20} style={styles.detalheIcone} />
                    <View
                      style={[
                        styles.ventoSeta,
                        { transform: [{ rotate: getRotacaoVento(previsao.atual.vento_direcao) }] },
                      ]}
                    >
                      <IconButton icon="arrow-up" iconColor={colors.secondary} size={14} style={styles.ventoSetaIcone} />
                    </View>
                  </View>
                  <Text style={styles.detalheLabel}>Vento ({previsao.atual.vento_direcao_texto})</Text>
                  <Text style={styles.detalheValor}>{Math.round(previsao.atual.vento_velocidade)} km/h</Text>
                </View>

                {/* Precipitacao */}
                <View style={styles.detalheItem}>
                  <IconButton icon="weather-rainy" iconColor={colors.secondary} size={20} style={styles.detalheIcone} />
                  <Text style={styles.detalheLabel}>Precipitacao</Text>
                  <Text style={styles.detalheValor}>{previsao.atual.precipitacao.toFixed(1).replace('.', ',')} mm</Text>
                </View>
              </View>
            </View>

            {/* Alertas climaticos */}
            {alertas.length > 0 && (
              <View style={styles.alertasContainer}>
                <Text style={styles.secaoTitulo}>Alertas</Text>
                {alertas.map((alerta, index) => (
                  <AlertaCard key={index} alerta={alerta} />
                ))}
              </View>
            )}

            {/* Previsao 7 dias */}
            <Text style={styles.secaoTitulo}>Proximos 7 dias</Text>
            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              style={styles.diasScroll}
              contentContainerStyle={styles.diasScrollContent}
            >
              {previsao.previsao_7dias.map((dia, index) => (
                <PrevisaoDiaCard key={index} dia={dia} />
              ))}
            </ScrollView>

            {/* Previsao por hora */}
            {chartDataHorario && (
              <View style={styles.horarioContainer}>
                <Text style={styles.secaoTitulo}>Temperatura hoje (por hora)</Text>
                <View style={styles.chartCard}>
                  <LineChart
                    data={chartDataHorario}
                    width={screenWidth - spacing.lg * 2 - spacing.md * 2}
                    height={180}
                    chartConfig={{
                      ...chartConfig,
                      color: () => colors.danger,
                      decimalCount: 0,
                    }}
                    bezier
                    style={styles.chart}
                    withDots
                    withInnerLines
                    yAxisSuffix="\u00B0"
                  />
                </View>
              </View>
            )}

            {/* Fonte dos dados */}
            <View style={styles.fonteContainer}>
              <IconButton icon="information-outline" iconColor={colors.gray500} size={16} style={styles.fonteIcone} />
              <Text style={styles.fonteTexto}>Dados de Open-Meteo</Text>
            </View>
          </>
        ) : (
          <View style={styles.emptyContainer}>
            <IconButton icon="weather-cloudy-alert" iconColor={colors.gray400} size={64} />
            <Text style={styles.emptyTitulo}>Previsao indisponivel</Text>
            <Text style={styles.emptyTexto}>
              Nao foi possivel carregar a previsao do tempo. Verifique sua conexao e tente novamente.
            </Text>
          </View>
        )}
      </ScrollView>
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
    padding: spacing.lg,
    paddingBottom: spacing.huge,
  },

  // Seletor
  seletorGalpao: {
    marginBottom: spacing.md,
  },

  // Loading
  loadingContainer: {
    paddingVertical: spacing.huge,
    alignItems: 'center',
    gap: spacing.md,
  },
  loadingText: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },

  // Secao
  secaoTitulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.md,
    marginTop: spacing.lg,
  },

  // Card condicao atual
  atualCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    ...shadows.medium,
  },
  atualHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.lg,
  },
  atualInfo: {
    flex: 1,
    marginLeft: spacing.md,
  },
  atualDescricao: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    textTransform: 'capitalize',
  },
  atualTemp: {
    fontSize: typography.fontSizeHero,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  atualSensacao: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },
  atualDetalhes: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    borderTopWidth: borders.widthThin,
    borderTopColor: colors.divider,
    paddingTop: spacing.lg,
  },
  detalheItem: {
    alignItems: 'center',
    flex: 1,
  },
  detalheIcone: {
    margin: 0,
    padding: 0,
    marginBottom: spacing.xs,
  },
  detalheLabel: {
    fontSize: 12,
    color: colors.textSecondary,
    marginBottom: 2,
    textAlign: 'center',
  },
  detalheValor: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  ventoContainer: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  ventoSeta: {
    marginLeft: -8,
  },
  ventoSetaIcone: {
    margin: 0,
    padding: 0,
  },

  // Alertas
  alertasContainer: {
    marginTop: spacing.md,
  },
  alertaCard: {
    flexDirection: 'row',
    alignItems: 'center',
    borderRadius: borders.radiusL,
    padding: spacing.md,
    marginBottom: spacing.sm,
    borderLeftWidth: 4,
  },
  alertaIcone: {
    margin: 0,
    padding: 0,
  },
  alertaTextoContainer: {
    flex: 1,
    marginLeft: spacing.sm,
  },
  alertaTitulo: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
  },
  alertaDescricao: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginTop: 2,
  },

  // Previsao 7 dias
  diasScroll: {
    marginBottom: spacing.md,
  },
  diasScrollContent: {
    gap: spacing.sm,
  },
  diaCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.md,
    alignItems: 'center',
    minWidth: 80,
    ...shadows.small,
  },
  diaSemana: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    textTransform: 'capitalize',
  },
  diaData: {
    fontSize: 12,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  diaIcone: {
    margin: 0,
    padding: 0,
  },
  diaTemps: {
    flexDirection: 'row',
    gap: spacing.sm,
    marginTop: spacing.xs,
  },
  diaTempMax: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
  },
  diaTempMin: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
  },
  diaChuva: {
    flexDirection: 'row',
    alignItems: 'center',
    marginTop: spacing.xs,
  },
  diaChuvaIcone: {
    margin: 0,
    padding: 0,
  },
  diaChuvaTexto: {
    fontSize: 12,
    color: colors.secondary,
  },

  // Grafico horario
  horarioContainer: {
    marginTop: spacing.sm,
  },
  chartCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.md,
    ...shadows.small,
  },
  chart: {
    borderRadius: borders.radiusL,
  },

  // Fonte
  fonteContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    marginTop: spacing.xl,
  },
  fonteIcone: {
    margin: 0,
    padding: 0,
  },
  fonteTexto: {
    fontSize: 12,
    color: colors.gray500,
  },

  // Empty
  emptyContainer: {
    alignItems: 'center',
    paddingVertical: spacing.huge,
  },
  emptyTitulo: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  emptyTexto: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
    textAlign: 'center',
  },
});

export default ClimaScreen;
