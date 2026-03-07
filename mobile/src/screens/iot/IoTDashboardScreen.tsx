/**
 * Dashboard IoT do eGranja.
 *
 * Funcionalidades:
 * - Cards de sensores em tempo real (Temperatura, Umidade, CO2, Amonia, Luminosidade, Pressao)
 * - Indicadores de status com cores semanticas (verde/amarelo/vermelho)
 * - Mini sparklines das ultimas 24h
 * - Seletor de galpao no topo
 * - Pull-to-refresh e auto-refresh a cada 30 segundos
 * - Timestamp da ultima leitura
 */

import React, { useState, useCallback, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  RefreshControl,
  ActivityIndicator,
  AppState,
  AppStateStatus,
} from 'react-native';
import { Appbar, IconButton } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { LineChart } from 'react-native-chart-kit';
import dayjs from 'dayjs';
import relativeTime from 'dayjs/plugin/relativeTime';
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
  components,
} from '@theme/index';

dayjs.extend(relativeTime);
dayjs.locale('pt-br');

// ==========================================
// TIPOS
// ==========================================

interface SensorData {
  tipo: string;
  valor: number;
  unidade: string;
  status: 'normal' | 'atencao' | 'critico';
  historico_24h: number[];
  timestamp: string;
}

interface IoTLatestResponse {
  galpao_id: string;
  galpao_nome: string;
  sensores: SensorData[];
  ultima_leitura: string;
}

// ==========================================
// CONFIGURACAO DE SENSORES
// ==========================================

interface SensorConfig {
  icone: string;
  label: string;
  unidade: string;
  min: number;
  max: number;
  idealMin: number;
  idealMax: number;
}

const SENSOR_CONFIG: Record<string, SensorConfig> = {
  temperatura: {
    icone: 'thermometer',
    label: 'Temperatura',
    unidade: '\u00B0C',
    min: 0,
    max: 50,
    idealMin: 20,
    idealMax: 32,
  },
  umidade: {
    icone: 'water-percent',
    label: 'Umidade',
    unidade: '%',
    min: 0,
    max: 100,
    idealMin: 40,
    idealMax: 80,
  },
  co2: {
    icone: 'molecule-co2',
    label: 'CO\u2082',
    unidade: 'ppm',
    min: 0,
    max: 5000,
    idealMin: 0,
    idealMax: 3000,
  },
  amonia: {
    icone: 'chemical-weapon',
    label: 'Amonia',
    unidade: 'ppm',
    min: 0,
    max: 50,
    idealMin: 0,
    idealMax: 20,
  },
  luminosidade: {
    icone: 'white-balance-sunny',
    label: 'Luminosidade',
    unidade: 'lux',
    min: 0,
    max: 500,
    idealMin: 20,
    idealMax: 200,
  },
  pressao: {
    icone: 'gauge',
    label: 'Pressao',
    unidade: 'Pa',
    min: -50,
    max: 50,
    idealMin: -10,
    idealMax: 10,
  },
};

// ==========================================
// FUNCOES AUXILIARES
// ==========================================

function getStatusColor(status: string): string {
  switch (status) {
    case 'normal':
      return colors.success;
    case 'atencao':
      return colors.warning;
    case 'critico':
      return colors.danger;
    default:
      return colors.gray500;
  }
}

function getStatusLabel(status: string): string {
  switch (status) {
    case 'normal':
      return 'Normal';
    case 'atencao':
      return 'Atencao';
    case 'critico':
      return 'Critico';
    default:
      return 'Sem dados';
  }
}

function formatarValor(valor: number, tipo: string): string {
  if (tipo === 'temperatura' || tipo === 'umidade') {
    return valor.toFixed(1).replace('.', ',');
  }
  return Math.round(valor).toLocaleString('pt-BR');
}

// ==========================================
// COMPONENTE DO CARD DE SENSOR
// ==========================================

interface SensorCardProps {
  sensor: SensorData;
}

const SensorCard: React.FC<SensorCardProps> = ({ sensor }) => {
  const config = SENSOR_CONFIG[sensor.tipo] || SENSOR_CONFIG.temperatura;
  const statusColor = getStatusColor(sensor.status);
  const statusLabel = getStatusLabel(sensor.status);

  // Dados para mini sparkline
  const sparklineData = sensor.historico_24h.length > 0 ? sensor.historico_24h : [0];

  return (
    <View style={styles.sensorCard}>
      {/* Indicador de status */}
      <View style={[styles.statusIndicator, { backgroundColor: statusColor }]} />

      {/* Header do card */}
      <View style={styles.sensorHeader}>
        <IconButton
          icon={config.icone}
          iconColor={statusColor}
          size={22}
          style={styles.sensorIcone}
        />
        <Text style={styles.sensorLabel}>{config.label}</Text>
      </View>

      {/* Valor atual */}
      <View style={styles.sensorValorContainer}>
        <Text style={[styles.sensorValor, { color: statusColor }]}>
          {formatarValor(sensor.valor, sensor.tipo)}
        </Text>
        <Text style={styles.sensorUnidade}>{sensor.unidade || config.unidade}</Text>
      </View>

      {/* Status label */}
      <View style={[styles.statusBadge, { backgroundColor: statusColor + '20' }]}>
        <View style={[styles.statusDot, { backgroundColor: statusColor }]} />
        <Text style={[styles.statusText, { color: statusColor }]}>{statusLabel}</Text>
      </View>

      {/* Mini sparkline */}
      {sparklineData.length > 1 && (
        <View style={styles.sparklineContainer}>
          <LineChart
            data={{
              labels: [],
              datasets: [{ data: sparklineData }],
            }}
            width={130}
            height={40}
            withDots={false}
            withInnerLines={false}
            withOuterLines={false}
            withHorizontalLabels={false}
            withVerticalLabels={false}
            withShadow={false}
            chartConfig={{
              backgroundColor: 'transparent',
              backgroundGradientFrom: colors.surface,
              backgroundGradientTo: colors.surface,
              color: () => statusColor,
              strokeWidth: 2,
              propsForLabels: { fontSize: 0 },
            }}
            bezier
            style={styles.sparkline}
          />
        </View>
      )}
    </View>
  );
};

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================

const IoTDashboardScreen: React.FC = () => {
  const navigation = useNavigation();
  const lotes = useLoteStore((state) => state.lotes);

  const [sensores, setSensores] = useState<SensorData[]>([]);
  const [ultimaLeitura, setUltimaLeitura] = useState<string>('');
  const [isLoading, setIsLoading] = useState(true);
  const [refreshing, setRefreshing] = useState(false);
  const [galpaoId, setGalpaoId] = useState<string>('');
  const intervalRef = useRef<NodeJS.Timeout | null>(null);
  const appStateRef = useRef(AppState.currentState);

  // Opcoes de galpao
  const galpoesOptions: DropdownOption[] = lotes
    .filter((l) => l.status === 'ativo')
    .reduce<DropdownOption[]>((acc, l) => {
      if (!acc.find((o) => o.value === l.galpaoId)) {
        acc.push({
          value: l.galpaoId,
          label: l.galpaoNome,
          subtitle: `Lote ativo - ${l.avesVivas || l.quantidade} aves`,
        });
      }
      return acc;
    }, []);

  // Selecionar primeiro galpao automaticamente
  useEffect(() => {
    if (!galpaoId && galpoesOptions.length > 0) {
      setGalpaoId(galpoesOptions[0].value);
    }
  }, [galpoesOptions, galpaoId]);

  // Carregar dados dos sensores
  const carregarDados = useCallback(async () => {
    if (!galpaoId) return;
    try {
      const response = await apiGet<IoTLatestResponse>(`/galpoes/${galpaoId}/iot/latest`);
      setSensores(response.data.sensores);
      setUltimaLeitura(response.data.ultima_leitura);
    } catch {
      // Manter dados anteriores se falhar
    } finally {
      setIsLoading(false);
      setRefreshing(false);
    }
  }, [galpaoId]);

  // Auto-refresh a cada 30 segundos
  useEffect(() => {
    carregarDados();

    intervalRef.current = setInterval(carregarDados, 30000);

    // Pausar quando app esta em background
    const subscription = AppState.addEventListener('change', (nextState: AppStateStatus) => {
      if (appStateRef.current.match(/active/) && nextState.match(/inactive|background/)) {
        // App foi para background - parar refresh
        if (intervalRef.current) {
          clearInterval(intervalRef.current);
          intervalRef.current = null;
        }
      } else if (appStateRef.current.match(/inactive|background/) && nextState === 'active') {
        // App voltou para foreground - recarregar e reiniciar refresh
        carregarDados();
        intervalRef.current = setInterval(carregarDados, 30000);
      }
      appStateRef.current = nextState;
    });

    return () => {
      if (intervalRef.current) {
        clearInterval(intervalRef.current);
      }
      subscription.remove();
    };
  }, [carregarDados]);

  const onRefresh = useCallback(() => {
    setRefreshing(true);
    carregarDados();
  }, [carregarDados]);

  // Texto de ultima leitura
  const ultimaLeituraTexto = ultimaLeitura
    ? `Ultima leitura: ${dayjs(ultimaLeitura).fromNow()}`
    : '';

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
        <Appbar.Content
          title="Sensores IoT"
          titleStyle={styles.headerTitle}
          color={colors.textOnPrimary}
        />
        <Appbar.Action
          icon="history"
          color={colors.textOnPrimary}
          onPress={() => (navigation as any).navigate('IoTHistorico', { galpaoId })}
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

        {/* Timestamp */}
        {ultimaLeituraTexto && (
          <View style={styles.timestampContainer}>
            <IconButton icon="clock-outline" iconColor={colors.textSecondary} size={16} style={styles.timestampIcone} />
            <Text style={styles.timestampText}>{ultimaLeituraTexto}</Text>
            <View style={styles.autoRefreshBadge}>
              <View style={styles.autoRefreshDot} />
              <Text style={styles.autoRefreshText}>Ao vivo</Text>
            </View>
          </View>
        )}

        {/* Loading */}
        {isLoading ? (
          <View style={styles.loadingContainer}>
            <ActivityIndicator size="large" color={colors.primary} />
            <Text style={styles.loadingText}>Carregando sensores...</Text>
          </View>
        ) : sensores.length === 0 ? (
          <View style={styles.emptyContainer}>
            <IconButton icon="chip" iconColor={colors.gray400} size={64} />
            <Text style={styles.emptyTitulo}>Sem sensores configurados</Text>
            <Text style={styles.emptyTexto}>
              Nenhum sensor IoT esta vinculado a este galpao.
            </Text>
          </View>
        ) : (
          /* Grid de sensores */
          <View style={styles.sensoresGrid}>
            {sensores.map((sensor) => (
              <SensorCard key={sensor.tipo} sensor={sensor} />
            ))}
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

  // Seletor de galpao
  seletorGalpao: {
    marginBottom: spacing.sm,
  },

  // Timestamp
  timestampContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.lg,
  },
  timestampIcone: {
    margin: 0,
    padding: 0,
  },
  timestampText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    flex: 1,
  },
  autoRefreshBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    backgroundColor: colors.successLight,
    paddingHorizontal: spacing.sm,
    paddingVertical: spacing.xs,
    borderRadius: borders.radiusRound,
  },
  autoRefreshDot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: colors.success,
    marginRight: spacing.xs,
  },
  autoRefreshText: {
    fontSize: 12,
    color: colors.success,
    fontWeight: typography.fontWeightMedium,
  },

  // Grid de sensores
  sensoresGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'space-between',
    gap: spacing.md,
  },

  // Card de sensor
  sensorCard: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    width: '48%',
    minHeight: 180,
    overflow: 'hidden',
    ...shadows.medium,
  },
  statusIndicator: {
    position: 'absolute',
    top: 0,
    left: 0,
    right: 0,
    height: 3,
    borderTopLeftRadius: borders.radiusL,
    borderTopRightRadius: borders.radiusL,
  },
  sensorHeader: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  sensorIcone: {
    margin: 0,
    padding: 0,
    marginRight: spacing.xs,
  },
  sensorLabel: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    color: colors.textSecondary,
    flex: 1,
  },
  sensorValorContainer: {
    flexDirection: 'row',
    alignItems: 'baseline',
    marginBottom: spacing.sm,
  },
  sensorValor: {
    fontSize: typography.fontSizeXXL,
    fontWeight: typography.fontWeightBold,
  },
  sensorUnidade: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginLeft: spacing.xs,
  },
  statusBadge: {
    flexDirection: 'row',
    alignItems: 'center',
    alignSelf: 'flex-start',
    paddingHorizontal: spacing.sm,
    paddingVertical: 2,
    borderRadius: borders.radiusRound,
    marginBottom: spacing.sm,
  },
  statusDot: {
    width: 6,
    height: 6,
    borderRadius: 3,
    marginRight: spacing.xs,
  },
  statusText: {
    fontSize: 12,
    fontWeight: typography.fontWeightMedium,
  },
  sparklineContainer: {
    alignItems: 'center',
    marginTop: spacing.xs,
  },
  sparkline: {
    paddingRight: 0,
    paddingLeft: 0,
  },

  // Loading
  loadingContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    paddingVertical: spacing.huge,
    gap: spacing.md,
  },
  loadingText: {
    fontSize: typography.fontSizeS,
    color: colors.textSecondary,
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

export default IoTDashboardScreen;
