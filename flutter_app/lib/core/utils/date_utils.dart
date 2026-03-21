import 'package:intl/intl.dart';

/// Utilitarios de formatacao de data/hora.
///
/// Substitui o uso do `dayjs` no React Native, usando o pacote `intl`
/// para formatacao e calculo relativo manual.
class AppDateUtils {
  AppDateUtils._();

  static final _dateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('dd/MM/yyyy HH:mm');

  /// Formata data como 'DD/MM/YYYY'.
  ///
  /// Exemplo: `formatDate(DateTime(2025, 3, 21))` → `'21/03/2025'`
  static String formatDate(DateTime date) => _dateFormat.format(date);

  /// Formata data e hora como 'DD/MM/YYYY HH:mm'.
  ///
  /// Exemplo: `formatDateTime(DateTime(2025, 3, 21, 14, 30))` → `'21/03/2025 14:30'`
  static String formatDateTime(DateTime date) => _dateTimeFormat.format(date);

  /// Formata data de forma relativa em portugues.
  ///
  /// Exemplos:
  /// - `'agora'` (menos de 1 minuto)
  /// - `'ha 5 minutos'`
  /// - `'ha 2 horas'`
  /// - `'ha 3 dias'`
  /// - `'ha 2 semanas'`
  /// - `'ha 1 mes'`
  /// - `'21/03/2025'` (mais de 1 ano)
  static String formatRelative(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.isNegative) return formatDate(date);

    if (diff.inSeconds < 60) return 'agora';
    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      return 'ha $m ${m == 1 ? 'minuto' : 'minutos'}';
    }
    if (diff.inHours < 24) {
      final h = diff.inHours;
      return 'ha $h ${h == 1 ? 'hora' : 'horas'}';
    }
    if (diff.inDays < 7) {
      final d = diff.inDays;
      return 'ha $d ${d == 1 ? 'dia' : 'dias'}';
    }
    if (diff.inDays < 30) {
      final w = diff.inDays ~/ 7;
      return 'ha $w ${w == 1 ? 'semana' : 'semanas'}';
    }
    if (diff.inDays < 365) {
      final months = diff.inDays ~/ 30;
      return 'ha $months ${months == 1 ? 'mes' : 'meses'}';
    }

    return formatDate(date);
  }

  /// Retorna o numero inteiro de dias entre duas datas.
  ///
  /// O resultado e sempre positivo (valor absoluto).
  static int daysBetween(DateTime a, DateTime b) {
    final aDate = DateTime(a.year, a.month, a.day);
    final bDate = DateTime(b.year, b.month, b.day);
    return aDate.difference(bDate).inDays.abs();
  }
}
