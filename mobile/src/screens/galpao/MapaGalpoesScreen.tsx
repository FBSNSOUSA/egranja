/**
 * Tela de Mapa de Galpoes do eGranja.
 *
 * Funcionalidades:
 * - MapView (react-native-maps) centralizado na granja
 * - Markers para cada galpao com orientacao
 * - Callout com nome, dimensoes, lote ativo, temperatura IoT
 * - Botao "Ver detalhes" navega para GalpaoDetalhe
 */

import React, { useState, useCallback, useEffect, useRef } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ActivityIndicator,
  TouchableOpacity,
  Platform,
} from 'react-native';
import MapView, { Marker, Callout, PROVIDER_GOOGLE } from 'react-native-maps';
import { Appbar, IconButton, Button } from 'react-native-paper';
import { useNavigation } from '@react-navigation/native';
import { apiGet } from '@services/api';
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

interface GalpaoMapa {
  id: string;
  nome: string;
  latitude: number;
  longitude: number;
  orientacao_graus: number;
  largura_m: number;
  comprimento_m: number;
  ventilacao: string;
  cortinas: string;
  lote_ativo?: {
    id: string;
    aves_vivas: number;
    dias_de_vida: number;
  };
  iot?: {
    temperatura?: number;
    umidade?: number;
    status: string;
  };
}

interface GranjaInfo {
  nome: string;
  latitude: number;
  longitude: number;
  galpoes: GalpaoMapa[];
}

// ==========================================
// COMPONENTE PRINCIPAL
// ==========================================

const MapaGalpoesScreen: React.FC = () => {
  const navigation = useNavigation<any>();
  const mapRef = useRef<MapView>(null);

  const [granja, setGranja] = useState<GranjaInfo | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  // Carregar dados
  const carregarDados = useCallback(async () => {
    try {
      const response = await apiGet<GranjaInfo>('/galpoes/mapa');
      setGranja(response.data);
    } catch {
      setGranja(null);
    } finally {
      setIsLoading(false);
    }
  }, []);

  useEffect(() => {
    carregarDados();
  }, [carregarDados]);

  // Ajustar camera para mostrar todos os galpoes
  useEffect(() => {
    if (granja && granja.galpoes.length > 0 && mapRef.current) {
      const coords = granja.galpoes.map((g) => ({
        latitude: g.latitude,
        longitude: g.longitude,
      }));

      setTimeout(() => {
        mapRef.current?.fitToCoordinates(coords, {
          edgePadding: { top: 80, right: 80, bottom: 80, left: 80 },
          animated: true,
        });
      }, 500);
    }
  }, [granja]);

  // Cor do marker baseada no status IoT
  const getMarkerColor = (galpao: GalpaoMapa): string => {
    if (!galpao.iot) return colors.gray500;
    switch (galpao.iot.status) {
      case 'normal':
        return colors.success;
      case 'atencao':
        return colors.warning;
      case 'critico':
        return colors.danger;
      default:
        return colors.secondary;
    }
  };

  return (
    <View style={styles.container}>
      {/* Header */}
      <Appbar.Header style={styles.header}>
        <Appbar.BackAction onPress={() => navigation.goBack()} color={colors.textOnPrimary} />
        <Appbar.Content
          title="Mapa de Galpoes"
          titleStyle={styles.headerTitle}
          color={colors.textOnPrimary}
        />
      </Appbar.Header>

      {isLoading ? (
        <View style={styles.loadingContainer}>
          <ActivityIndicator size="large" color={colors.primary} />
          <Text style={styles.loadingText}>Carregando mapa...</Text>
        </View>
      ) : !granja ? (
        <View style={styles.emptyContainer}>
          <IconButton icon="map-marker-off" iconColor={colors.gray400} size={64} />
          <Text style={styles.emptyTitulo}>Mapa indisponivel</Text>
          <Text style={styles.emptyTexto}>
            Nao foi possivel carregar os dados dos galpoes.
          </Text>
        </View>
      ) : (
        <MapView
          ref={mapRef}
          style={styles.mapa}
          provider={Platform.OS === 'android' ? PROVIDER_GOOGLE : undefined}
          initialRegion={{
            latitude: granja.latitude,
            longitude: granja.longitude,
            latitudeDelta: 0.005,
            longitudeDelta: 0.005,
          }}
          showsUserLocation
          showsMyLocationButton
          showsCompass
        >
          {granja.galpoes.map((galpao) => (
            <Marker
              key={galpao.id}
              coordinate={{
                latitude: galpao.latitude,
                longitude: galpao.longitude,
              }}
              pinColor={getMarkerColor(galpao)}
              rotation={galpao.orientacao_graus}
            >
              <Callout
                onPress={() => navigation.navigate('GalpaoDetalhe', { galpaoId: galpao.id })}
                style={styles.callout}
              >
                <View style={styles.calloutContent}>
                  <Text style={styles.calloutTitulo}>{galpao.nome}</Text>
                  <Text style={styles.calloutDimensoes}>
                    {galpao.largura_m}m x {galpao.comprimento_m}m
                  </Text>

                  {galpao.lote_ativo && (
                    <View style={styles.calloutLote}>
                      <IconButton icon="bird" iconColor={colors.success} size={14} style={styles.calloutIcone} />
                      <Text style={styles.calloutLoteTexto}>
                        {galpao.lote_ativo.aves_vivas.toLocaleString('pt-BR')} aves | Dia {galpao.lote_ativo.dias_de_vida}
                      </Text>
                    </View>
                  )}

                  {galpao.iot?.temperatura !== undefined && (
                    <View style={styles.calloutIoT}>
                      <IconButton icon="thermometer" iconColor={colors.secondary} size={14} style={styles.calloutIcone} />
                      <Text style={styles.calloutIoTTexto}>
                        {galpao.iot.temperatura.toFixed(1).replace('.', ',')}{'\u00B0C'} | {galpao.iot.umidade}%
                      </Text>
                    </View>
                  )}

                  <TouchableOpacity style={styles.calloutBotao}>
                    <Text style={styles.calloutBotaoTexto}>Ver detalhes</Text>
                  </TouchableOpacity>
                </View>
              </Callout>
            </Marker>
          ))}
        </MapView>
      )}
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

  // Mapa
  mapa: {
    flex: 1,
  },

  // Loading
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

  // Empty
  emptyContainer: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
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
    paddingHorizontal: spacing.xxl,
  },

  // Callout
  callout: {
    minWidth: 200,
  },
  calloutContent: {
    padding: spacing.sm,
  },
  calloutTitulo: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    marginBottom: 2,
  },
  calloutDimensoes: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
    marginBottom: spacing.sm,
  },
  calloutLote: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.xs,
  },
  calloutIcone: {
    margin: 0,
    padding: 0,
    marginRight: spacing.xs,
  },
  calloutLoteTexto: {
    fontSize: typography.fontSizeXS,
    color: colors.success,
  },
  calloutIoT: {
    flexDirection: 'row',
    alignItems: 'center',
    marginBottom: spacing.sm,
  },
  calloutIoTTexto: {
    fontSize: typography.fontSizeXS,
    color: colors.secondary,
  },
  calloutBotao: {
    backgroundColor: colors.primary,
    borderRadius: borders.radiusM,
    paddingVertical: spacing.sm,
    paddingHorizontal: spacing.md,
    alignItems: 'center',
    minHeight: 36,
    justifyContent: 'center',
  },
  calloutBotaoTexto: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightBold,
    color: colors.textOnPrimary,
  },
});

export default MapaGalpoesScreen;
