import 'dart:ui';

import 'app_colors.dart';

/// Funcoes helper para cores semanticas de indicadores zootecnicos.
///
/// Porta fielmente as funcoes `getIndicatorColor`, `getIEPClassification`,
/// `getWeightIndicatorColor`, `getMortalityIndicatorColor` e
/// `getWaterFeedRatioColor` do design system original.
class IndicatorColors {
  IndicatorColors._();

  // ── IEP (Indice de Eficiencia Produtiva) ─────────────────────────────

  /// Retorna a cor da classificacao do IEP.
  ///
  /// Classificacao baseada em Embrapa/EPEF:
  /// - < 260: Ruim (vermelho)
  /// - 260-350: Regular (amarelo)
  /// - 350-400: Bom (verde)
  /// - > 400: Excelente (verde escuro)
  static Color getIEPColor(double iep) {
    if (iep < 260) return AppColors.iepRuim;
    if (iep < 350) return AppColors.iepRegular;
    if (iep < 400) return AppColors.iepBom;
    return AppColors.iepExcelente;
  }

  /// Retorna o label textual da classificacao do IEP.
  static String getIEPClassification(double iep) {
    if (iep < 260) return 'Ruim';
    if (iep < 350) return 'Regular';
    if (iep < 400) return 'Bom';
    return 'Excelente';
  }

  // ── Peso vs Benchmark ────────────────────────────────────────────────

  /// Retorna a cor do indicador de peso comparado ao benchmark da linhagem.
  ///
  /// - Verde: peso >= 95% do benchmark
  /// - Amarelo: peso entre 90-95% do benchmark
  /// - Vermelho: peso < 90% do benchmark
  static Color getWeightColor(double pesoReal, double pesoBenchmark) {
    if (pesoBenchmark <= 0) return AppColors.gray500;
    final percentual = (pesoReal / pesoBenchmark) * 100;
    return getIndicatorColor(
      percentual,
      warningThreshold: 95,
      dangerThreshold: 90,
    );
  }

  // ── Mortalidade diaria ───────────────────────────────────────────────

  /// Retorna a cor do indicador de mortalidade diaria.
  ///
  /// - Verde: mortalidade <= 0.3%
  /// - Amarelo: mortalidade entre 0.3-0.5%
  /// - Vermelho: mortalidade > 0.5%
  static Color getMortalityColor(double mortalidadePctDia) {
    return getIndicatorColor(
      mortalidadePctDia,
      warningThreshold: 0.3,
      dangerThreshold: 0.5,
      invertScale: true,
    );
  }

  // ── Relacao agua/racao ───────────────────────────────────────────────

  /// Retorna a cor do indicador de relacao agua/racao.
  ///
  /// Normal: entre 1.6 e 2.0. Fora dessa faixa = perigo.
  static Color getWaterFeedRatioColor(double ratio) {
    if (ratio < 1.6 || ratio > 2.0) return AppColors.danger;
    return AppColors.success;
  }

  // ── Indicador generico ───────────────────────────────────────────────

  /// Retorna a cor semantica baseada no valor e nos limites definidos.
  ///
  /// Quando [invertScale] e `false` (padrao), valores **abaixo** dos
  /// thresholds sao ruins (ex: peso). Quando [invertScale] e `true`,
  /// valores **acima** dos thresholds sao ruins (ex: mortalidade).
  ///
  /// Exemplos:
  /// ```dart
  /// // Peso: abaixo de 90% = perigo, abaixo de 95% = atencao
  /// getIndicatorColor(pesoPercentual, warningThreshold: 95, dangerThreshold: 90);
  ///
  /// // Mortalidade: acima de 0.5% = perigo, acima de 0.3% = atencao
  /// getIndicatorColor(mortalidade, warningThreshold: 0.3, dangerThreshold: 0.5, invertScale: true);
  /// ```
  static Color getIndicatorColor(
    double value, {
    required double warningThreshold,
    required double dangerThreshold,
    bool invertScale = false,
  }) {
    if (invertScale) {
      // Valor alto = ruim (ex: mortalidade)
      if (value > dangerThreshold) return AppColors.danger;
      if (value > warningThreshold) return AppColors.warning;
      return AppColors.success;
    } else {
      // Valor baixo = ruim (ex: peso)
      if (value < dangerThreshold) return AppColors.danger;
      if (value < warningThreshold) return AppColors.warning;
      return AppColors.success;
    }
  }
}
