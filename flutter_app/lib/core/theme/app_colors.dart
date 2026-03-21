import 'dart:ui';

/// Paleta de cores do eGranja.
///
/// Portada fielmente do design system React Native original
/// (`mobile/src/theme/index.ts`). Inclui cores de identidade visual,
/// semanticas para indicadores zootecnicos, escala de cinza e cores
/// funcionais de superficie.
class AppColors {
  AppColors._();

  // ── Identidade visual ────────────────────────────────────────────────
  static const Color primary = Color(0xFFD32F2F); // Vermelho eGranja
  static const Color primaryDark = Color(0xFFB71C1C); // press/active
  static const Color primaryLight = Color(0xFFEF5350); // hover/disabled

  static const Color secondary = Color(0xFF1565C0); // Azul
  static const Color secondaryDark = Color(0xFF0D47A1);
  static const Color secondaryLight = Color(0xFF42A5F5);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ── Cores semanticas (indicadores zootecnicos) ───────────────────────
  static const Color success = Color(0xFF2E7D32); // Verde - dentro do esperado
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFF9A825); // Amarelo - atencao
  static const Color warningLight = Color(0xFFFFF8E1);
  static const Color danger = Color(0xFFD32F2F); // Vermelho - critico
  static const Color dangerLight = Color(0xFFFFEBEE);

  // ── Escala de cinza ──────────────────────────────────────────────────
  static const Color gray50 = Color(0xFFFAFAFA);
  static const Color gray100 = Color(0xFFF5F5F5);
  static const Color gray200 = Color(0xFFEEEEEE);
  static const Color gray300 = Color(0xFFE0E0E0);
  static const Color gray400 = Color(0xFFBDBDBD);
  static const Color gray500 = Color(0xFF9E9E9E);
  static const Color gray600 = Color(0xFF757575);
  static const Color gray700 = Color(0xFF616161);
  static const Color gray800 = Color(0xFF424242);
  static const Color gray900 = Color(0xFF212121);

  // ── Cores funcionais ─────────────────────────────────────────────────
  static const Color background = Color(0xFFF5F5F5);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFFFFFFFF);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);

  // ── Status de conexao ────────────────────────────────────────────────
  static const Color online = Color(0xFF2E7D32);
  static const Color offline = Color(0xFFF57C00);
  static const Color syncing = Color(0xFF1565C0);

  // ── Classificacao IEP ────────────────────────────────────────────────
  static const Color iepRuim = Color(0xFFD32F2F); // < 260
  static const Color iepRegular = Color(0xFFF9A825); // 260-350
  static const Color iepBom = Color(0xFF2E7D32); // 350-400
  static const Color iepExcelente = Color(0xFF1B5E20); // > 400
}
