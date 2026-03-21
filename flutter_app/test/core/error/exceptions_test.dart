import 'package:flutter_test/flutter_test.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';

void main() {
  group('Exceptions', () {
    group('ServerException', () {
      test('toString inclui code e message', () {
        const exception = ServerException(
          code: 'SERVER_ERROR',
          message: 'Erro interno',
        );
        expect(
          exception.toString(),
          'ServerException(SERVER_ERROR: Erro interno)',
        );
      });

      test('valores padrao funcionam corretamente', () {
        const exception = ServerException();
        expect(exception.code, 'SERVER_ERROR');
        expect(exception.message, contains('Erro interno'));
      });
    });

    group('CacheException', () {
      test('toString inclui code e message', () {
        const exception = CacheException(
          code: 'CACHE_MISS',
          message: 'Dados nao encontrados',
        );
        expect(
          exception.toString(),
          'CacheException(CACHE_MISS: Dados nao encontrados)',
        );
      });

      test('valores padrao funcionam corretamente', () {
        const exception = CacheException();
        expect(exception.code, 'CACHE_ERROR');
        expect(exception.message, contains('dados locais'));
      });
    });

    group('NetworkException', () {
      test('toString inclui code e message', () {
        const exception = NetworkException(
          code: 'TIMEOUT',
          message: 'Conexao expirou',
        );
        expect(
          exception.toString(),
          'NetworkException(TIMEOUT: Conexao expirou)',
        );
      });

      test('valores padrao funcionam corretamente', () {
        const exception = NetworkException();
        expect(exception.code, 'NETWORK_ERROR');
        expect(exception.message, contains('conexao'));
      });
    });

    group('AuthException', () {
      test('toString inclui code e message', () {
        const exception = AuthException(
          code: 'INVALID_CREDENTIALS',
          message: 'Credenciais invalidas',
        );
        expect(
          exception.toString(),
          'AuthException(INVALID_CREDENTIALS: Credenciais invalidas)',
        );
      });

      test('valores padrao funcionam corretamente', () {
        const exception = AuthException();
        expect(exception.code, 'AUTH_ERROR');
        expect(exception.message, contains('autenticacao'));
      });
    });
  });
}
