import 'package:flutter_test/flutter_test.dart';
import 'package:egranja_flutter/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils', () {
    group('formatDate', () {
      test('formata data como DD/MM/YYYY', () {
        final date = DateTime(2025, 3, 21);
        expect(AppDateUtils.formatDate(date), '21/03/2025');
      });

      test('formata data com dia e mes de um digito', () {
        final date = DateTime(2025, 1, 5);
        expect(AppDateUtils.formatDate(date), '05/01/2025');
      });
    });

    group('formatDateTime', () {
      test('formata data e hora como DD/MM/YYYY HH:mm', () {
        final date = DateTime(2025, 3, 21, 14, 30);
        expect(AppDateUtils.formatDateTime(date), '21/03/2025 14:30');
      });

      test('formata hora com zeros a esquerda', () {
        final date = DateTime(2025, 1, 5, 8, 5);
        expect(AppDateUtils.formatDateTime(date), '05/01/2025 08:05');
      });
    });

    group('formatRelative', () {
      test('retorna "agora" para menos de 1 minuto atras', () {
        final date = DateTime.now().subtract(const Duration(seconds: 30));
        expect(AppDateUtils.formatRelative(date), 'agora');
      });

      test('retorna "ha X minutos" para menos de 1 hora', () {
        final date = DateTime.now().subtract(const Duration(minutes: 5));
        expect(AppDateUtils.formatRelative(date), 'ha 5 minutos');
      });

      test('retorna "ha 1 minuto" no singular', () {
        final date = DateTime.now().subtract(const Duration(minutes: 1));
        expect(AppDateUtils.formatRelative(date), 'ha 1 minuto');
      });

      test('retorna "ha X horas" para menos de 1 dia', () {
        final date = DateTime.now().subtract(const Duration(hours: 3));
        expect(AppDateUtils.formatRelative(date), 'ha 3 horas');
      });

      test('retorna "ha 1 hora" no singular', () {
        final date = DateTime.now().subtract(const Duration(hours: 1));
        expect(AppDateUtils.formatRelative(date), 'ha 1 hora');
      });

      test('retorna "ha X dias" para menos de 1 semana', () {
        final date = DateTime.now().subtract(const Duration(days: 3));
        expect(AppDateUtils.formatRelative(date), 'ha 3 dias');
      });

      test('retorna "ha X semanas" para menos de 1 mes', () {
        final date = DateTime.now().subtract(const Duration(days: 14));
        expect(AppDateUtils.formatRelative(date), 'ha 2 semanas');
      });

      test('retorna "ha X meses" para menos de 1 ano', () {
        final date = DateTime.now().subtract(const Duration(days: 60));
        expect(AppDateUtils.formatRelative(date), 'ha 2 meses');
      });

      test('retorna data formatada para mais de 1 ano', () {
        final date = DateTime.now().subtract(const Duration(days: 400));
        expect(AppDateUtils.formatRelative(date), AppDateUtils.formatDate(date));
      });
    });

    group('daysBetween', () {
      test('calcula numero correto de dias entre duas datas', () {
        final a = DateTime(2025, 3, 21);
        final b = DateTime(2025, 3, 25);
        expect(AppDateUtils.daysBetween(a, b), 4);
      });

      test('retorna valor absoluto independente da ordem', () {
        final a = DateTime(2025, 3, 25);
        final b = DateTime(2025, 3, 21);
        expect(AppDateUtils.daysBetween(a, b), 4);
      });

      test('retorna zero para mesma data', () {
        final date = DateTime(2025, 3, 21);
        expect(AppDateUtils.daysBetween(date, date), 0);
      });
    });
  });
}
