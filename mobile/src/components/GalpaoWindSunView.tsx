/**
 * Componente de Visualizacao Grafica SVG do Galpao com Vento e Sol.
 *
 * Funcionalidades:
 * - Retangulo representando o galpao na orientacao real (rotacionado)
 * - Seta de vento com direcao real e cor baseada na velocidade
 * - Arco solar mostrando trajetoria leste->oeste com posicao atual do sol
 * - Indicadores de cortinas (abertas/fechadas) nas laterais
 * - Legenda com direcao, velocidade e temperatura
 * - Proporcoes reais baseadas nas dimensoes do galpao
 *
 * Usa: react-native-svg (Svg, Rect, Line, Circle, Path, Text, G, Defs, LinearGradient)
 */

import React, { useMemo } from 'react';
import {
  View,
  Text as RNText,
  StyleSheet,
} from 'react-native';
import Svg, {
  Rect,
  Line,
  Circle,
  Path,
  Text as SvgText,
  G,
  Defs,
  LinearGradient,
  Stop,
  Polygon,
} from 'react-native-svg';
import {
  colors,
  typography,
  spacing,
  borders,
} from '@theme/index';

// ==========================================
// TIPOS
// ==========================================

interface GalpaoWindSunViewProps {
  /** Largura do galpao em metros */
  largura: number;
  /** Comprimento do galpao em metros */
  comprimento: number;
  /** Orientacao do galpao em graus (0=Norte, 90=Leste, etc) */
  orientacaoGraus: number;
  /** Velocidade do vento em km/h */
  ventoVelocidade: number;
  /** Direcao do vento em graus (de onde vem) */
  ventoDirecao: number;
  /** Temperatura externa em graus Celsius */
  temperaturaExterna: number;
  /** Se as cortinas estao abertas */
  cortinasAbertas: boolean;
}

// ==========================================
// CONSTANTES
// ==========================================

const SVG_WIDTH = 320;
const SVG_HEIGHT = 280;
const CENTER_X = SVG_WIDTH / 2;
const CENTER_Y = SVG_HEIGHT / 2 + 10;
const MAX_GALPAO_SIZE = 120;

// ==========================================
// FUNCOES AUXILIARES
// ==========================================

/** Cor da seta de vento baseada na velocidade */
function getVentoColor(velocidade: number): string {
  if (velocidade < 15) return colors.success;
  if (velocidade <= 30) return colors.warning;
  return colors.danger;
}

/** Texto da direcao do vento */
function getDirecaoTexto(graus: number): string {
  const direcoes = ['N', 'NE', 'L', 'SE', 'S', 'SO', 'O', 'NO'];
  const index = Math.round(graus / 45) % 8;
  return direcoes[index];
}

/** Converte graus para radianos */
function toRad(deg: number): number {
  return (deg * Math.PI) / 180;
}

/** Calcula posicao do sol baseada na hora do dia (arco de leste a oeste) */
function calcularPosicaoSol(): { x: number; y: number; progresso: number } {
  const agora = new Date();
  const hora = agora.getHours() + agora.getMinutes() / 60;
  // Sol visivel das 5h as 19h (aprox)
  const inicio = 5;
  const fim = 19;
  const progresso = Math.max(0, Math.min(1, (hora - inicio) / (fim - inicio)));

  // Arco de 180 graus (esquerda para direita)
  const angulo = Math.PI * (1 - progresso); // PI (esquerda) -> 0 (direita)
  const raio = 100;
  const x = CENTER_X + raio * Math.cos(angulo);
  const y = CENTER_Y - 60 - raio * Math.sin(angulo) * 0.6; // Achatado verticalmente

  return { x, y, progresso };
}

// ==========================================
// COMPONENTE
// ==========================================

export const GalpaoWindSunView: React.FC<GalpaoWindSunViewProps> = ({
  largura,
  comprimento,
  orientacaoGraus,
  ventoVelocidade,
  ventoDirecao,
  temperaturaExterna,
  cortinasAbertas,
}) => {
  // Calcular dimensoes proporcionais do galpao no SVG
  const proporcao = useMemo(() => {
    const maxDim = Math.max(largura, comprimento);
    const escala = MAX_GALPAO_SIZE / maxDim;
    return {
      w: largura * escala,
      h: comprimento * escala,
    };
  }, [largura, comprimento]);

  // Posicao do sol
  const sol = useMemo(() => calcularPosicaoSol(), []);

  // Cor do vento
  const ventoCor = getVentoColor(ventoVelocidade);
  const direcaoTexto = getDirecaoTexto(ventoDirecao);

  // Coordenadas da seta de vento
  const ventoArrow = useMemo(() => {
    const angulo = toRad(ventoDirecao + 180); // Vento vem de X, seta aponta para onde vai
    const dist = MAX_GALPAO_SIZE + 30;
    const startX = CENTER_X + dist * Math.sin(toRad(ventoDirecao));
    const startY = CENTER_Y - dist * Math.cos(toRad(ventoDirecao));
    const endX = CENTER_X + (dist - 50) * Math.sin(toRad(ventoDirecao));
    const endY = CENTER_Y - (dist - 50) * Math.cos(toRad(ventoDirecao));

    // Pontas da seta
    const arrowSize = 10;
    const arrowAngle = toRad(ventoDirecao + 180);
    const tip1X = endX + arrowSize * Math.sin(arrowAngle - 0.5);
    const tip1Y = endY - arrowSize * Math.cos(arrowAngle - 0.5);
    const tip2X = endX + arrowSize * Math.sin(arrowAngle + 0.5);
    const tip2Y = endY - arrowSize * Math.cos(arrowAngle + 0.5);

    return { startX, startY, endX, endY, tip1X, tip1Y, tip2X, tip2Y };
  }, [ventoDirecao]);

  // Caminho do arco solar
  const arcoSolar = useMemo(() => {
    const raio = 100;
    const startX = CENTER_X - raio;
    const startY = CENTER_Y - 60;
    const endX = CENTER_X + raio;
    const endY = CENTER_Y - 60;
    return `M ${startX} ${startY} A ${raio} ${raio * 0.6} 0 0 1 ${endX} ${endY}`;
  }, []);

  // Indicadores de cortinas
  const cortinasCor = cortinasAbertas ? colors.success : colors.danger;
  const cortinasTexto = cortinasAbertas ? 'Abertas' : 'Fechadas';

  // Se e dia (sol visivel)
  const isDia = sol.progresso > 0 && sol.progresso < 1;

  return (
    <View style={styles.container}>
      <Svg width={SVG_WIDTH} height={SVG_HEIGHT} viewBox={`0 0 ${SVG_WIDTH} ${SVG_HEIGHT}`}>
        <Defs>
          <LinearGradient id="skyGrad" x1="0" y1="0" x2="0" y2="1">
            <Stop offset="0" stopColor="#87CEEB" stopOpacity="0.3" />
            <Stop offset="1" stopColor="#FFFFFF" stopOpacity="0.1" />
          </LinearGradient>
          <LinearGradient id="galpaoGrad" x1="0" y1="0" x2="0" y2="1">
            <Stop offset="0" stopColor={colors.gray300} stopOpacity="1" />
            <Stop offset="1" stopColor={colors.gray200} stopOpacity="1" />
          </LinearGradient>
        </Defs>

        {/* Fundo */}
        <Rect x="0" y="0" width={SVG_WIDTH} height={SVG_HEIGHT} fill="url(#skyGrad)" rx={borders.radiusL} />

        {/* Pontos cardeais */}
        <SvgText x={CENTER_X} y="18" fontSize="12" fill={colors.textSecondary} textAnchor="middle" fontWeight="bold">N</SvgText>
        <SvgText x={CENTER_X} y={SVG_HEIGHT - 6} fontSize="12" fill={colors.textSecondary} textAnchor="middle" fontWeight="bold">S</SvgText>
        <SvgText x="10" y={CENTER_Y + 4} fontSize="12" fill={colors.textSecondary} textAnchor="start" fontWeight="bold">O</SvgText>
        <SvgText x={SVG_WIDTH - 10} y={CENTER_Y + 4} fontSize="12" fill={colors.textSecondary} textAnchor="end" fontWeight="bold">L</SvgText>

        {/* Arco solar (trajetoria) */}
        <Path
          d={arcoSolar}
          fill="none"
          stroke="#FFC107"
          strokeWidth="1.5"
          strokeDasharray="4,4"
          opacity={0.5}
        />

        {/* Labels Leste/Oeste no arco */}
        <SvgText x={CENTER_X - 105} y={CENTER_Y - 55} fontSize="10" fill="#FFC107" textAnchor="middle">Nasc.</SvgText>
        <SvgText x={CENTER_X + 105} y={CENTER_Y - 55} fontSize="10" fill="#FFC107" textAnchor="middle">Poente</SvgText>

        {/* Sol (posicao atual) */}
        {isDia && (
          <G>
            <Circle cx={sol.x} cy={sol.y} r="14" fill="#FFC107" opacity={0.3} />
            <Circle cx={sol.x} cy={sol.y} r="10" fill="#FFC107" />
            <Circle cx={sol.x} cy={sol.y} r="6" fill="#FFD54F" />
          </G>
        )}

        {/* Galpao (retangulo rotacionado) */}
        <G
          rotation={orientacaoGraus}
          origin={`${CENTER_X}, ${CENTER_Y}`}
        >
          {/* Sombra do galpao */}
          <Rect
            x={CENTER_X - proporcao.w / 2 + 3}
            y={CENTER_Y - proporcao.h / 2 + 3}
            width={proporcao.w}
            height={proporcao.h}
            fill={colors.gray400}
            opacity={0.3}
            rx={4}
          />

          {/* Corpo do galpao */}
          <Rect
            x={CENTER_X - proporcao.w / 2}
            y={CENTER_Y - proporcao.h / 2}
            width={proporcao.w}
            height={proporcao.h}
            fill="url(#galpaoGrad)"
            stroke={colors.gray600}
            strokeWidth="2"
            rx={4}
          />

          {/* Linha central (cumeeira) */}
          <Line
            x1={CENTER_X}
            y1={CENTER_Y - proporcao.h / 2 + 5}
            x2={CENTER_X}
            y2={CENTER_Y + proporcao.h / 2 - 5}
            stroke={colors.gray500}
            strokeWidth="1"
            strokeDasharray="3,3"
          />

          {/* Cortinas laterais (esquerda) */}
          <Line
            x1={CENTER_X - proporcao.w / 2}
            y1={CENTER_Y - proporcao.h / 2 + 10}
            x2={CENTER_X - proporcao.w / 2}
            y2={CENTER_Y + proporcao.h / 2 - 10}
            stroke={cortinasCor}
            strokeWidth="4"
          />

          {/* Cortinas laterais (direita) */}
          <Line
            x1={CENTER_X + proporcao.w / 2}
            y1={CENTER_Y - proporcao.h / 2 + 10}
            x2={CENTER_X + proporcao.w / 2}
            y2={CENTER_Y + proporcao.h / 2 - 10}
            stroke={cortinasCor}
            strokeWidth="4"
          />

          {/* Label do galpao */}
          <SvgText
            x={CENTER_X}
            y={CENTER_Y + 4}
            fontSize="11"
            fill={colors.gray700}
            textAnchor="middle"
            fontWeight="bold"
          >
            {largura}x{comprimento}m
          </SvgText>
        </G>

        {/* Seta de vento */}
        <Line
          x1={ventoArrow.startX}
          y1={ventoArrow.startY}
          x2={ventoArrow.endX}
          y2={ventoArrow.endY}
          stroke={ventoCor}
          strokeWidth="3"
        />
        <Polygon
          points={`${ventoArrow.endX},${ventoArrow.endY} ${ventoArrow.tip1X},${ventoArrow.tip1Y} ${ventoArrow.tip2X},${ventoArrow.tip2Y}`}
          fill={ventoCor}
        />

        {/* Label do vento */}
        <SvgText
          x={ventoArrow.startX}
          y={ventoArrow.startY - 8}
          fontSize="10"
          fill={ventoCor}
          textAnchor="middle"
          fontWeight="bold"
        >
          {Math.round(ventoVelocidade)} km/h
        </SvgText>
      </Svg>

      {/* Legenda */}
      <View style={styles.legendaContainer}>
        <View style={styles.legendaItem}>
          <View style={[styles.legendaDot, { backgroundColor: ventoCor }]} />
          <RNText style={styles.legendaTexto}>
            Vento: {direcaoTexto} {Math.round(ventoVelocidade)} km/h
          </RNText>
        </View>
        <View style={styles.legendaItem}>
          <View style={[styles.legendaDot, { backgroundColor: cortinasCor }]} />
          <RNText style={styles.legendaTexto}>
            Cortinas: {cortinasTexto}
          </RNText>
        </View>
        <View style={styles.legendaItem}>
          <View style={[styles.legendaDot, { backgroundColor: colors.secondary }]} />
          <RNText style={styles.legendaTexto}>
            Temp. ext.: {temperaturaExterna.toFixed(1).replace('.', ',')}{'\u00B0C'}
          </RNText>
        </View>
      </View>

      {/* Escala de vento */}
      <View style={styles.escalaContainer}>
        <RNText style={styles.escalaLabel}>Velocidade do vento:</RNText>
        <View style={styles.escalaItens}>
          <View style={styles.escalaItem}>
            <View style={[styles.escalaBar, { backgroundColor: colors.success }]} />
            <RNText style={styles.escalaTexto}>&lt;15</RNText>
          </View>
          <View style={styles.escalaItem}>
            <View style={[styles.escalaBar, { backgroundColor: colors.warning }]} />
            <RNText style={styles.escalaTexto}>15-30</RNText>
          </View>
          <View style={styles.escalaItem}>
            <View style={[styles.escalaBar, { backgroundColor: colors.danger }]} />
            <RNText style={styles.escalaTexto}>&gt;30</RNText>
          </View>
          <RNText style={styles.escalaUnidade}>km/h</RNText>
        </View>
      </View>
    </View>
  );
};

// ==========================================
// ESTILOS
// ==========================================

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
  },

  // Legenda
  legendaContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    justifyContent: 'center',
    marginTop: spacing.md,
    gap: spacing.lg,
  },
  legendaItem: {
    flexDirection: 'row',
    alignItems: 'center',
  },
  legendaDot: {
    width: 10,
    height: 10,
    borderRadius: 5,
    marginRight: spacing.xs,
  },
  legendaTexto: {
    fontSize: typography.fontSizeXS,
    color: colors.textSecondary,
  },

  // Escala
  escalaContainer: {
    marginTop: spacing.md,
    alignItems: 'center',
  },
  escalaLabel: {
    fontSize: 12,
    color: colors.textSecondary,
    marginBottom: spacing.xs,
  },
  escalaItens: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  escalaItem: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 3,
  },
  escalaBar: {
    width: 20,
    height: 8,
    borderRadius: 2,
  },
  escalaTexto: {
    fontSize: 10,
    color: colors.textSecondary,
  },
  escalaUnidade: {
    fontSize: 10,
    color: colors.textSecondary,
    marginLeft: spacing.xs,
  },
});

export default GalpaoWindSunView;
