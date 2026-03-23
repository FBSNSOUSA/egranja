import 'dart:ui';

/// Paleta de cores do eGranja.
///
/// Paleta profissional para agronegocio/avicultura.
/// Verde primario representa agricultura/crescimento, dourado/ambar
/// secundario representa graos/colheita, azul terciario para informacoes.
/// Vermelho reservado exclusivamente para erros e alertas criticos.
class AppColors {
  AppColors._();

  // ── Identidade visual ────────────────────────────────────────────────
  static const Color primary = Color(0xFF2E7D32); // Verde agricultura
  static const Color primaryDark = Color(0xFF1B5E20); // press/active
  static const Color primaryLight = Color(0xFF66BB6A); // hover/disabled

  static const Color secondary = Color(0xFFF9A825); // Dourado/ambar colheita
  static const Color secondaryDark = Color(0xFFF57F17);
  static const Color secondaryLight = Color(0xFFFDD835);

  static const Color tertiary = Color(0xFF1976D2); // Azul informativo
  static const Color tertiaryDark = Color(0xFF0D47A1);
  static const Color tertiaryLight = Color(0xFF42A5F5);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);

  // ── Cores semanticas (indicadores zootecnicos) ───────────────────────
  static const Color success = Color(0xFF388E3C); // Verde - dentro do esperado
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color warning = Color(0xFFEF6C00); // Laranja - atencao
  static const Color warningLight = Color(0xFFFFF3E0);
  static const Color danger = Color(0xFFC62828); // Vermelho escuro - critico
  static const Color dangerLight = Color(0xFFFFEBEE);
  static const Color info = Color(0xFF1976D2); // Azul - informativo
  static const Color infoLight = Color(0xFFE3F2FD);

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
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF616161);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnSecondary = Color(0xFF212121);
  static const Color divider = Color(0xFFE0E0E0);
  static const Color disabled = Color(0xFFBDBDBD);

  // ── Status de conexao ────────────────────────────────────────────────
  static const Color online = Color(0xFF388E3C);
  static const Color offline = Color(0xFFEF6C00);
  static const Color syncing = Color(0xFF1976D2);

  // ── Classificacao IEP ────────────────────────────────────────────────
  static const Color iepRuim = Color(0xFFC62828); // < 260
  static const Color iepRegular = Color(0xFFEF6C00); // 260-350
  static const Color iepBom = Color(0xFF388E3C); // 350-400
  static const Color iepExcelente = Color(0xFF1B5E20); // > 400
}
