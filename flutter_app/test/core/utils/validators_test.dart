import 'package:flutter_test/flutter_test.dart';
import 'package:egranja_flutter/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('requiredField', () {
      test('retorna erro quando valor e null', () {
        expect(Validators.requiredField(null), 'Campo obrigatorio');
      });

      test('retorna erro quando valor e vazio', () {
        expect(Validators.requiredField(''), 'Campo obrigatorio');
      });

      test('retorna erro quando valor e apenas espacos', () {
        expect(Validators.requiredField('   '), 'Campo obrigatorio');
      });

      test('retorna null quando valor e valido', () {
        expect(Validators.requiredField('texto valido'), isNull);
      });
    });

    group('positiveNumber', () {
      test('retorna erro quando valor e null', () {
        expect(Validators.positiveNumber(null), 'Campo obrigatorio');
      });

      test('retorna erro quando valor e vazio', () {
        expect(Validators.positiveNumber(''), 'Campo obrigatorio');
      });

      test('retorna erro quando valor nao e numero', () {
        expect(Validators.positiveNumber('abc'), 'Valor invalido');
      });

      test('retorna erro quando valor e zero', () {
        expect(Validators.positiveNumber('0'), 'Deve ser maior que zero');
      });

      test('retorna erro quando valor e negativo', () {
        expect(Validators.positiveNumber('-5'), 'Deve ser maior que zero');
      });

      test('retorna null quando valor e positivo', () {
        expect(Validators.positiveNumber('10'), isNull);
      });

      test('retorna null quando valor usa virgula como decimal', () {
        expect(Validators.positiveNumber('3,5'), isNull);
      });
    });

    group('minLength', () {
      test('retorna erro quando valor e null', () {
        final validator = Validators.minLength(6);
        expect(validator(null), 'Campo obrigatorio');
      });

      test('retorna erro quando valor e curto demais', () {
        final validator = Validators.minLength(6);
        expect(validator('abc'), 'Minimo 6 caracteres');
      });

      test('retorna null quando valor tem comprimento exato', () {
        final validator = Validators.minLength(6);
        expect(validator('abcdef'), isNull);
      });

      test('retorna null quando valor e maior que o minimo', () {
        final validator = Validators.minLength(6);
        expect(validator('abcdefgh'), isNull);
      });
    });

    group('email', () {
      test('retorna erro quando valor e null', () {
        expect(Validators.email(null), 'Campo obrigatorio');
      });

      test('retorna erro quando formato e invalido', () {
        expect(Validators.email('emailinvalido'), 'E-mail invalido');
      });

      test('retorna erro quando falta dominio', () {
        expect(Validators.email('user@'), 'E-mail invalido');
      });

      test('retorna null quando email e valido', () {
        expect(Validators.email('user@example.com'), isNull);
      });
    });

    group('numericValue', () {
      test('retorna erro quando valor e null', () {
        expect(Validators.numericValue(null), 'Campo obrigatorio');
      });

      test('retorna erro quando valor nao e numero', () {
        expect(Validators.numericValue('nao-numero'), 'Valor invalido');
      });

      test('retorna null quando valor e numero valido', () {
        expect(Validators.numericValue('42'), isNull);
      });

      test('retorna null quando valor e decimal com virgula', () {
        expect(Validators.numericValue('3,14'), isNull);
      });
    });
  });
}
