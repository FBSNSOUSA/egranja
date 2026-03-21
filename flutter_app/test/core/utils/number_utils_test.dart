import 'package:flutter_test/flutter_test.dart';
import 'package:egranja_flutter/core/utils/number_utils.dart';

void main() {
  group('NumberUtils', () {
    group('formatWeight', () {
      test('formata gramas menores que 1000 como "X g"', () {
        expect(NumberUtils.formatWeight(850), '850 g');
      });

      test('formata gramas iguais a zero', () {
        expect(NumberUtils.formatWeight(0), '0 g');
      });

      test('formata quilogramas com virgula decimal', () {
        expect(NumberUtils.formatWeight(2450), '2,45 kg');
      });

      test('formata quilogramas inteiros sem decimais desnecessarias', () {
        expect(NumberUtils.formatWeight(3000), '3 kg');
      });

      test('formata gramas no limite (999)', () {
        expect(NumberUtils.formatWeight(999), '999 g');
      });

      test('formata exatamente 1000 g como kg', () {
        expect(NumberUtils.formatWeight(1000), '1 kg');
      });
    });

    group('formatCurrency', () {
      test('formata valor monetario em reais', () {
        final result = NumberUtils.formatCurrency(1500.0);
        // Aceita variacao de espaco (normal ou non-breaking space)
        expect(result.replaceAll(RegExp(r'\s'), ' '), 'R\$ 1.500,00');
      });

      test('formata valor com centavos', () {
        final result = NumberUtils.formatCurrency(42.5);
        expect(result.replaceAll(RegExp(r'\s'), ' '), 'R\$ 42,50');
      });

      test('formata valor zero', () {
        final result = NumberUtils.formatCurrency(0);
        expect(result.replaceAll(RegExp(r'\s'), ' '), 'R\$ 0,00');
      });
    });

    group('formatPercentage', () {
      test('formata porcentagem com uma casa decimal', () {
        expect(NumberUtils.formatPercentage(3.5), '3,5%');
      });

      test('formata porcentagem inteira', () {
        expect(NumberUtils.formatPercentage(10.0), '10%');
      });
    });

    group('formatDecimal', () {
      test('formata com 2 casas decimais', () {
        expect(NumberUtils.formatDecimal(1234.567, 2), '1.234,57');
      });

      test('formata sem casas decimais', () {
        expect(NumberUtils.formatDecimal(1234.567, 0), '1.235');
      });

      test('formata com 3 casas decimais', () {
        expect(NumberUtils.formatDecimal(1.5, 3), '1,500');
      });
    });
  });
}
