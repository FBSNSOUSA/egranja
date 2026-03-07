/**
 * Tela de controle de visitantes (Livro de Registro Digital) do eGranja.
 *
 * Funcionalidades:
 * - Lista de visitantes com: nome, origem, entrada, saida
 * - Alerta se ultimo contato com aves < 48h (chip amarelo "VAZIO SANITARIO")
 * - FAB "+" para registrar entrada
 * - Botao "Registrar Saida" em visitantes sem saida
 * - Pull-to-refresh
 */

import React, { useState, useCallback, useEffect } from 'react';
import {
  View,
  Text,
  StyleSheet,
  FlatList,
  RefreshControl,
  Alert,
} from 'react-native';
import { Appbar, Button, Chip, Divider, Snackbar, IconButton } from 'react-native-paper';
import { useNavigation, useRoute, RouteProp } from '@react-navigation/native';
import dayjs from 'dayjs';
import { apiGet, apiPatch } from '@services/api';
import { EmptyState } from '@components/EmptyState';
import { FABMenu } from '@components/FABMenu';
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

interface Visitante {
  id: string;
  nome: string;
  documento?: string;
  origem: string;
  motivo?: string;
  ultimo_contato_aves?: string;
  placa_veiculo?: string;
  entrada_at: string;
  saida_at?: string;
}

interface VisitantesRouteParams {
  loteId: string;
  loteNome?: string;
}

// ==========================================
// COMPONENTE
// ==========================================

const VisitantesScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const route = useRoute<RouteProp<{ Visitantes: VisitantesRouteParams }, 'Visitantes'>>();
  const { loteId, loteNome } = route.params;

  const [visitantes, setVisitantes] = useState<Visitante[]>([]);
  const [refreshing, setRefreshing] = useState(false);
  const [loading, setLoading] = useState(true);
  const [snackbarVisible, setSnackbarVisible] = useState(false);
  const [snackbarMessage, setSnackbarMessage] = useState('');

  const carregarVisitantes = useCallback(async () => {
    try {
      const response = await apiGet<Visitante[]>(`/lotes/${loteId}/visitantes`);
      setVisitantes(response.data);
    } catch (error) {
      console.error('[Visitantes] Erro ao carregar:', error);
    } finally {
      setLoading(false);
    }
  }, [loteId]);

  useEffect(() => {
    carregarVisitantes();
  }, [carregarVisitantes]);

  const onRefresh = useCallback(async () => {
    setRefreshing(true);
    await carregarVisitantes();
    setRefreshing(false);
  }, [carregarVisitantes]);

  /** Verifica se ultimo contato com aves foi < 48h (risco de vazio sanitario) */
  const isVazioSanitario = useCallback((visitante: Visitante): boolean => {
    if (!visitante.ultimo_contato_aves) return false;
    const horasDesdeContato = dayjs().diff(dayjs(visitante.ultimo_contato_aves), 'hour');
    return horasDesdeContato < 48;
  }, []);

  /** Registrar saida do visitante */
  const registrarSaida = useCallback(
    async (visitanteId: string, visitanteNome: string) => {
      Alert.alert(
        'Registrar saida',
        `Confirmar saida de ${visitanteNome}?`,
        [
          { text: 'Cancelar', style: 'cancel' },
          {
            text: 'Confirmar',
            onPress: async () => {
              try {
                await apiPatch(`/lotes/${loteId}/visitantes/${visitanteId}`, {
                  saida_at: new Date().toISOString(),
                });

                // Atualizar localmente
                setVisitantes((prev) =>
                  prev.map((v) =>
                    v.id === visitanteId
                      ? { ...v, saida_at: new Date().toISOString() }
                      : v,
                  ),
                );

                setSnackbarMessage('Saida registrada com sucesso.');
                setSnackbarVisible(true);
              } catch (error) {
                console.error('[Visitantes] Erro ao registrar saida:', error);
                setSnackbarMessage('Erro ao registrar saida.');
                setSnackbarVisible(true);
              }
            },
          },
        ],
      );
    },
    [loteId],
  );

  const renderVisitante = useCallback(
    ({ item }: { item: Visitante }) => {
      const vazioSanitario = isVazioSanitario(item);
      const semSaida = !item.saida_at;

      return (
        <View
          style={[
            styles.card,
            vazioSanitario && styles.cardVazioSanitario,
            semSaida && styles.cardPresente,
          ]}
        >
          {/* Chips de alerta */}
          <View style={styles.chipContainer}>
            {semSaida && (
              <Chip
                mode="flat"
                icon="account-check"
                style={styles.presenteChip}
                textStyle={styles.presenteChipText}
              >
                Presente
              </Chip>
            )}
            {vazioSanitario && (
              <Chip
                mode="flat"
                icon="alert"
                style={styles.vazioChip}
                textStyle={styles.vazioChipText}
              >
                VAZIO SANITARIO
              </Chip>
            )}
          </View>

          {/* Nome */}
          <Text style={styles.visitanteNome}>{item.nome}</Text>

          {/* Detalhes */}
          <View style={styles.detailsContainer}>
            <View style={styles.detailRow}>
              <IconButton icon="map-marker" iconColor={colors.textSecondary} size={16} style={styles.detailIcon} />
              <Text style={styles.detailText}>Origem: {item.origem}</Text>
            </View>

            {item.documento && (
              <View style={styles.detailRow}>
                <IconButton icon="card-account-details" iconColor={colors.textSecondary} size={16} style={styles.detailIcon} />
                <Text style={styles.detailText}>Doc: {item.documento}</Text>
              </View>
            )}

            <View style={styles.detailRow}>
              <IconButton icon="clock-in" iconColor={colors.success} size={16} style={styles.detailIcon} />
              <Text style={styles.detailText}>
                Entrada: {dayjs(item.entrada_at).format('DD/MM/YYYY [as] HH:mm')}
              </Text>
            </View>

            {item.saida_at ? (
              <View style={styles.detailRow}>
                <IconButton icon="clock-out" iconColor={colors.danger} size={16} style={styles.detailIcon} />
                <Text style={styles.detailText}>
                  Saida: {dayjs(item.saida_at).format('DD/MM/YYYY [as] HH:mm')}
                </Text>
              </View>
            ) : null}

            {item.motivo && (
              <View style={styles.detailRow}>
                <IconButton icon="text" iconColor={colors.textSecondary} size={16} style={styles.detailIcon} />
                <Text style={styles.detailText}>Motivo: {item.motivo}</Text>
              </View>
            )}

            {item.ultimo_contato_aves && (
              <View style={styles.detailRow}>
                <IconButton
                  icon="bird"
                  iconColor={vazioSanitario ? colors.warning : colors.textSecondary}
                  size={16}
                  style={styles.detailIcon}
                />
                <Text
                  style={[
                    styles.detailText,
                    vazioSanitario && styles.detailTextWarning,
                  ]}
                >
                  Ultimo contato aves: {dayjs(item.ultimo_contato_aves).format('DD/MM/YYYY [as] HH:mm')}
                </Text>
              </View>
            )}

            {item.placa_veiculo && (
              <View style={styles.detailRow}>
                <IconButton icon="car" iconColor={colors.textSecondary} size={16} style={styles.detailIcon} />
                <Text style={styles.detailText}>Placa: {item.placa_veiculo}</Text>
              </View>
            )}
          </View>

          {/* Botao registrar saida */}
          {semSaida && (
            <Button
              mode="outlined"
              onPress={() => registrarSaida(item.id, item.nome)}
              icon="clock-out"
              style={styles.saidaButton}
              contentStyle={styles.saidaButtonContent}
              labelStyle={styles.saidaButtonLabel}
              textColor={colors.primary}
            >
              Registrar saida
            </Button>
          )}
        </View>
      );
    },
    [isVazioSanitario, registrarSaida],
  );

  return (
    <View style={styles.container}>
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction
          color={colors.textOnPrimary}
          onPress={() => navigation.goBack()}
        />
        <Appbar.Content
          title="Visitantes"
          subtitle={loteNome}
          titleStyle={styles.headerTitle}
          subtitleStyle={styles.headerSubtitle}
        />
      </Appbar.Header>

      <FlatList
        data={visitantes}
        keyExtractor={(item) => item.id}
        renderItem={renderVisitante}
        contentContainerStyle={
          visitantes.length === 0 ? styles.emptyList : styles.listContent
        }
        refreshControl={
          <RefreshControl
            refreshing={refreshing}
            onRefresh={onRefresh}
            colors={[colors.primary]}
          />
        }
        ListEmptyComponent={
          !loading ? (
            <EmptyState
              icon="account-group"
              titulo="Nenhum visitante registrado"
              descricao="Registre a entrada de visitantes para controle de biosseguranca."
              actionLabel="Registrar visitante"
              actionIcon="plus"
              onAction={() =>
                navigation.navigate('NovoVisitante', { loteId })
              }
            />
          ) : null
        }
      />

      <FABMenu
        actions={[
          {
            label: 'Novo visitante',
            icon: 'account-plus',
            onPress: () => navigation.navigate('NovoVisitante', { loteId }),
          },
        ]}
      />

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
  headerSubtitle: {
    fontSize: typography.fontSizeXS,
    color: colors.textOnPrimary,
    opacity: 0.85,
  },
  listContent: {
    padding: spacing.lg,
    paddingBottom: 80,
    gap: spacing.md,
  },
  card: {
    backgroundColor: colors.surface,
    borderRadius: borders.radiusL,
    padding: spacing.lg,
    ...shadows.small,
  },
  cardVazioSanitario: {
    borderLeftWidth: 4,
    borderLeftColor: colors.warning,
  },
  cardPresente: {
    borderLeftWidth: 4,
    borderLeftColor: colors.success,
  },
  chipContainer: {
    flexDirection: 'row',
    gap: spacing.sm,
    marginBottom: spacing.sm,
    flexWrap: 'wrap',
  },
  presenteChip: {
    backgroundColor: colors.successLight,
    height: 26,
  },
  presenteChipText: {
    fontSize: 11,
    color: colors.success,
    fontWeight: typography.fontWeightMedium,
  },
  vazioChip: {
    backgroundColor: colors.warningLight,
    height: 26,
  },
  vazioChipText: {
    fontSize: 11,
    color: '#E65100',
    fontWeight: typography.fontWeightBold,
  },
  visitanteNome: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: spacing.sm,
  },
  detailsContainer: {
    gap: spacing.xs,
  },
  detailRow: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  detailIcon: {
    margin: 0,
    padding: 0,
    marginRight: spacing.xs,
  },
  detailText: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    flex: 1,
  },
  detailTextWarning: {
    color: '#E65100',
    fontWeight: typography.fontWeightMedium,
  },
  saidaButton: {
    marginTop: spacing.md,
    borderRadius: components.button.borderRadius,
    borderColor: colors.primary,
  },
  saidaButtonContent: {
    minHeight: 44,
  },
  saidaButtonLabel: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
  },
  emptyList: {
    flexGrow: 1,
  },
  snackbar: {
    backgroundColor: colors.gray800,
  },
});

export default VisitantesScreen;
