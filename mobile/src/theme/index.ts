/**
 * Design System do eGranja
 *
 * Tema centralizado com cores, tipografia, espacamento e componentes reutilizaveis.
 * Segue principios de acessibilidade: textos minimo 16sp, botoes minimo 48dp,
 * contraste WCAG AA, otimizado para uso no campo.
 */

// ==========================================
// CORES
// ==========================================

export const colors = {
  // Cores principais da identidade visual
  primary: '#D32F2F',       // Vermelho eGranja
  primaryDark: '#B71C1C',   // Vermelho escuro (press/active)
  primaryLight: '#EF5350',  // Vermelho claro (hover/disabled)

  secondary: '#1565C0',     // Azul
  secondaryDark: '#0D47A1', // Azul escuro
  secondaryLight: '#42A5F5', // Azul claro

  white: '#FFFFFF',
  black: '#000000',

  // Cores semanticas para indicadores zootecnicos
  success: '#2E7D32',       // Verde - dentro do esperado (>95% benchmark)
  successLight: '#E8F5E9',  // Verde claro (background)
  warning: '#F9A825',       // Amarelo - atencao (90-95% benchmark)
  warningLight: '#FFF8E1',  // Amarelo claro (background)
  danger: '#D32F2F',        // Vermelho - critico (<90% benchmark ou mortalidade >0,5%/dia)
  dangerLight: '#FFEBEE',   // Vermelho claro (background)

  // Escala de cinza
  gray50: '#FAFAFA',
  gray100: '#F5F5F5',
  gray200: '#EEEEEE',
  gray300: '#E0E0E0',
  gray400: '#BDBDBD',
  gray500: '#9E9E9E',
  gray600: '#757575',
  gray700: '#616161',
  gray800: '#424242',
  gray900: '#212121',

  // Cores funcionais
  background: '#F5F5F5',     // Fundo da aplicacao
  surface: '#FFFFFF',        // Fundo de cards e modais
  text: '#212121',           // Texto principal
  textSecondary: '#757575',  // Texto secundario
  textOnPrimary: '#FFFFFF',  // Texto sobre fundo primario
  textOnSecondary: '#FFFFFF', // Texto sobre fundo secundario
  divider: '#E0E0E0',       // Linhas divisorias
  disabled: '#BDBDBD',      // Elementos desabilitados
  overlay: 'rgba(0, 0, 0, 0.5)', // Overlay de modais

  // Cores de status de conexao
  online: '#2E7D32',        // Online
  offline: '#F57C00',       // Offline
  syncing: '#1565C0',       // Sincronizando

  // Classificacao IEP
  iepRuim: '#D32F2F',       // < 260
  iepRegular: '#F9A825',    // 260-350
  iepBom: '#2E7D32',        // 350-400
  iepExcelente: '#1B5E20',  // > 400
} as const;

// ==========================================
// TIPOGRAFIA
// ==========================================

export const typography = {
  // Tamanhos de fonte (minimo 16sp para acessibilidade)
  fontSizeXS: 14,    // Usado apenas para labels secundarios, nunca para conteudo principal
  fontSizeS: 16,     // Minimo para corpo de texto
  fontSizeM: 18,     // Corpo de texto padrao
  fontSizeL: 20,     // Subtitulos
  fontSizeXL: 24,    // Titulos
  fontSizeXXL: 28,   // Titulos grandes
  fontSizeHero: 36,  // Numeros destacados (indicadores)

  // Pesos de fonte
  fontWeightRegular: '400' as const,
  fontWeightMedium: '500' as const,
  fontWeightSemiBold: '600' as const,
  fontWeightBold: '700' as const,

  // Alturas de linha
  lineHeightTight: 1.2,
  lineHeightNormal: 1.5,
  lineHeightRelaxed: 1.75,

  // Familias de fonte
  fontFamily: 'System',
  fontFamilyMono: 'monospace',
} as const;

// Estilos pre-definidos de texto
export const textStyles = {
  // Titulos
  h1: {
    fontSize: typography.fontSizeXXL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    lineHeight: typography.fontSizeXXL * typography.lineHeightTight,
  },
  h2: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    color: colors.text,
    lineHeight: typography.fontSizeXL * typography.lineHeightTight,
  },
  h3: {
    fontSize: typography.fontSizeL,
    fontWeight: typography.fontWeightSemiBold,
    color: colors.text,
    lineHeight: typography.fontSizeL * typography.lineHeightTight,
  },

  // Corpo
  body: {
    fontSize: typography.fontSizeM,
    fontWeight: typography.fontWeightRegular,
    color: colors.text,
    lineHeight: typography.fontSizeM * typography.lineHeightNormal,
  },
  bodySmall: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightRegular,
    color: colors.textSecondary,
    lineHeight: typography.fontSizeS * typography.lineHeightNormal,
  },

  // Labels
  label: {
    fontSize: typography.fontSizeS,
    fontWeight: typography.fontWeightMedium,
    color: colors.text,
    lineHeight: typography.fontSizeS * typography.lineHeightNormal,
  },
  labelSmall: {
    fontSize: typography.fontSizeXS,
    fontWeight: typography.fontWeightMedium,
    color: colors.textSecondary,
    lineHeight: typography.fontSizeXS * typography.lineHeightNormal,
  },

  // Indicadores numericos (valores grandes em destaque)
  indicator: {
    fontSize: typography.fontSizeHero,
    fontWeight: typography.fontWeightBold,
    lineHeight: typography.fontSizeHero * typography.lineHeightTight,
  },
  indicatorSmall: {
    fontSize: typography.fontSizeXL,
    fontWeight: typography.fontWeightBold,
    lineHeight: typography.fontSizeXL * typography.lineHeightTight,
  },
} as const;

// ==========================================
// ESPACAMENTO
// ==========================================

export const spacing = {
  xs: 4,
  sm: 8,
  md: 12,
  lg: 16,
  xl: 20,
  xxl: 24,
  xxxl: 32,
  huge: 48,
} as const;

// ==========================================
// BORDAS
// ==========================================

export const borders = {
  radiusS: 4,
  radiusM: 8,
  radiusL: 12,
  radiusXL: 16,
  radiusRound: 9999,

  widthThin: 1,
  widthMedium: 2,
} as const;

// ==========================================
// SOMBRAS
// ==========================================

export const shadows = {
  small: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 1 },
    shadowOpacity: 0.18,
    shadowRadius: 1.0,
    elevation: 1,
  },
  medium: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.23,
    shadowRadius: 2.62,
    elevation: 4,
  },
  large: {
    shadowColor: colors.black,
    shadowOffset: { width: 0, height: 4 },
    shadowOpacity: 0.30,
    shadowRadius: 4.65,
    elevation: 8,
  },
} as const;

// ==========================================
// COMPONENTES (dimensoes padrao)
// ==========================================

export const components = {
  // Botoes - minimo 48dp de altura para acessibilidade (campo, luvas)
  button: {
    minHeight: 48,
    paddingHorizontal: spacing.xl,
    paddingVertical: spacing.md,
    borderRadius: borders.radiusM,
  },
  buttonLarge: {
    minHeight: 56,
    paddingHorizontal: spacing.xxl,
    paddingVertical: spacing.lg,
    borderRadius: borders.radiusM,
  },

  // Inputs
  input: {
    minHeight: 48,
    paddingHorizontal: spacing.lg,
    paddingVertical: spacing.md,
    borderRadius: borders.radiusM,
    borderWidth: borders.widthThin,
    fontSize: typography.fontSizeM,
  },

  // Cards
  card: {
    padding: spacing.lg,
    borderRadius: borders.radiusL,
    backgroundColor: colors.surface,
    ...shadows.medium,
  },

  // FAB (Floating Action Button)
  fab: {
    size: 56,
    iconSize: 24,
    borderRadius: borders.radiusRound,
    backgroundColor: colors.primary,
  },

  // Header
  header: {
    height: 56,
    paddingHorizontal: spacing.lg,
  },

  // Badge
  badge: {
    minWidth: 24,
    height: 24,
    borderRadius: borders.radiusRound,
    paddingHorizontal: spacing.sm,
  },

  // Indicador de status (online/offline)
  statusDot: {
    size: 10,
    borderRadius: borders.radiusRound,
  },
} as const;

// ==========================================
// FUNCOES HELPER
// ==========================================

/** Limites padrao para indicadores semanticos */
export interface IndicatorThresholds {
  /** Valor abaixo do qual o indicador e critico (vermelho) */
  criticalBelow?: number;
  /** Valor abaixo do qual o indicador requer atencao (amarelo) */
  warningBelow?: number;
  /** Valor acima do qual o indicador e critico (vermelho) */
  criticalAbove?: number;
  /** Valor acima do qual o indicador requer atencao (amarelo) */
  warningAbove?: number;
}

/**
 * Retorna a cor semantica baseada no valor e nos limites definidos.
 *
 * Usado para colorir indicadores zootecnicos:
 * - Verde: dentro do esperado
 * - Amarelo: atencao
 * - Vermelho: critico
 *
 * Exemplo de uso para peso vs benchmark:
 *   getIndicatorColor(pesoPercentual, { criticalBelow: 90, warningBelow: 95 })
 *
 * Exemplo de uso para mortalidade diaria:
 *   getIndicatorColor(mortalidadeDia, { criticalAbove: 0.5, warningAbove: 0.3 })
 */
export function getIndicatorColor(
  value: number,
  thresholds: IndicatorThresholds,
): string {
  // Verificar limites inferiores (valor baixo = ruim, ex: peso)
  if (thresholds.criticalBelow !== undefined && value < thresholds.criticalBelow) {
    return colors.danger;
  }
  if (thresholds.warningBelow !== undefined && value < thresholds.warningBelow) {
    return colors.warning;
  }

  // Verificar limites superiores (valor alto = ruim, ex: mortalidade)
  if (thresholds.criticalAbove !== undefined && value > thresholds.criticalAbove) {
    return colors.danger;
  }
  if (thresholds.warningAbove !== undefined && value > thresholds.warningAbove) {
    return colors.warning;
  }

  return colors.success;
}

/**
 * Retorna a cor e label da classificacao do IEP (Indice de Eficiencia Produtiva).
 *
 * Classificacao baseada em Embrapa/EPEF:
 * - < 260: Ruim
 * - 260-350: Regular
 * - 350-400: Bom
 * - > 400: Excelente
 */
export function getIEPClassification(iep: number): { color: string; label: string } {
  if (iep < 260) {
    return { color: colors.iepRuim, label: 'Ruim' };
  }
  if (iep < 350) {
    return { color: colors.iepRegular, label: 'Regular' };
  }
  if (iep < 400) {
    return { color: colors.iepBom, label: 'Bom' };
  }
  return { color: colors.iepExcelente, label: 'Excelente' };
}

/**
 * Retorna a cor do indicador de peso comparado ao benchmark da linhagem.
 *
 * - Verde: peso >= 95% do benchmark
 * - Amarelo: peso entre 90-95% do benchmark
 * - Vermelho: peso < 90% do benchmark
 */
export function getWeightIndicatorColor(pesoReal: number, pesoBenchmark: number): string {
  if (pesoBenchmark <= 0) return colors.gray500;
  const percentual = (pesoReal / pesoBenchmark) * 100;
  return getIndicatorColor(percentual, { criticalBelow: 90, warningBelow: 95 });
}

/**
 * Retorna a cor do indicador de mortalidade diaria.
 *
 * - Verde: mortalidade <= 0.3%
 * - Amarelo: mortalidade entre 0.3-0.5%
 * - Vermelho: mortalidade > 0.5%
 */
export function getMortalityIndicatorColor(mortalidadePctDia: number): string {
  return getIndicatorColor(mortalidadePctDia, { criticalAbove: 0.5, warningAbove: 0.3 });
}

/**
 * Retorna a cor do indicador de relacao agua/racao.
 *
 * Normal: entre 1.6 e 2.0
 * Fora: qualquer valor fora dessa faixa
 */
export function getWaterFeedRatioColor(ratio: number): string {
  if (ratio < 1.6 || ratio > 2.0) {
    return colors.danger;
  }
  return colors.success;
}

// ==========================================
// TEMA PARA REACT NATIVE PAPER
// ==========================================

export const paperTheme = {
  colors: {
    primary: colors.primary,
    accent: colors.secondary,
    background: colors.background,
    surface: colors.surface,
    text: colors.text,
    disabled: colors.disabled,
    placeholder: colors.gray500,
    backdrop: colors.overlay,
    error: colors.danger,
    notification: colors.primary,
    onSurface: colors.text,
  },
  roundness: borders.radiusM,
} as const;

// ==========================================
// CONFIGURACAO DE GRAFICOS (react-native-chart-kit)
// ==========================================

export const chartConfig = {
  backgroundColor: colors.surface,
  backgroundGradientFrom: colors.surface,
  backgroundGradientTo: colors.surface,
  decimalCount: 1,
  color: (opacity = 1) => `rgba(21, 101, 192, ${opacity})`,  // Azul secundario
  labelColor: (opacity = 1) => `rgba(33, 33, 33, ${opacity})`,
  style: {
    borderRadius: borders.radiusL,
  },
  propsForDots: {
    r: '5',
    strokeWidth: '2',
    stroke: colors.secondary,
  },
  propsForLabels: {
    fontSize: typography.fontSizeXS,
  },
} as const;

// Configuracao alternativa para graficos com linha de benchmark
export const chartConfigBenchmark = {
  ...chartConfig,
  color: (opacity = 1) => `rgba(46, 125, 50, ${opacity})`,  // Verde para benchmark
} as const;

export default {
  colors,
  typography,
  textStyles,
  spacing,
  borders,
  shadows,
  components,
  paperTheme,
  chartConfig,
  chartConfigBenchmark,
  getIndicatorColor,
  getIEPClassification,
  getWeightIndicatorColor,
  getMortalityIndicatorColor,
  getWaterFeedRatioColor,
};
