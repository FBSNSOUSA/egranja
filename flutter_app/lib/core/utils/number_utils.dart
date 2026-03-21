import 'package:intl/intl.dart';

/// Utilitarios de formatacao numerica para o contexto brasileiro.
///
/// Usa locale `pt_BR` (separador decimal = virgula, milhar = ponto).
class NumberUtils {
  NumberUtils._();

  static final _currencyFormat = NumberFormat.currency(
    locale: 'pt_BR',
    symbol: 'R\$',
    decimalDigits: 2,
  );

  static final _percentFormat = NumberFormat.decimalPattern('pt_BR');

  /// Formata peso em gramas ou quilogramas.
  ///
  /// - Ate 999 g → `'850 g'`
  /// - A partir de 1000 g → `'2,45 kg'`
  static String formatWeight(double grams) {
    if (grams < 1000) {
      return '${grams.toStringAsFixed(0)} g';
    }
    final kg = grams / 1000;
    final formatted = NumberFormat('#,##0.##', 'pt_BR').format(kg);
    return '$formatted kg';
  }

  /// Formata porcentagem com uma casa decimal.
  ///
  /// Exemplo: `formatPercentage(3.5)` → `'3,5%'`
  static String formatPercentage(double value) {
    final formatted = _percentFormat.format(
      double.parse(value.toStringAsFixed(1)),
    );
    return '$formatted%';
  }

  /// Formata valor monetario em Reais.
  ///
  /// Exemplo: `formatCurrency(1500.0)` → `'R$ 1.500,00'`
  static String formatCurrency(double value) {
    return _currencyFormat.format(value);
  }

  /// Formata numero decimal com quantidade especifica de casas.
  ///
  /// Exemplo: `formatDecimal(1234.567, 2)` → `'1.234,57'`
  static String formatDecimal(double value, int decimals) {
    final pattern = StringBuffer('#,##0');
    if (decimals > 0) {
      pattern.write('.');
      pattern.write('0' * decimals);
    }
    final formatter = NumberFormat(pattern.toString(), 'pt_BR');
    return formatter.format(value);
  }
}
