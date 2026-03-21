import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/auth/auth_service.dart';
import 'package:egranja_flutter/core/auth/secure_storage.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';

// ── Mocks ──────────────────────────────────────────────────────────────

class MockSecureStorage extends Mock implements SecureStorage {}

class MockDio extends Mock implements Dio {}

// ── Helpers ────────────────────────────────────────────────────────────

/// Cria um JWT de teste com payload customizavel.
/// Nao verifica assinatura — apenas para decodificacao local.
String createTestJWT({
  required String sub,
  required int exp,
  String tipo = 'produtor',
}) {
  final header = base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}'));
  final payload = base64Url.encode(utf8.encode(jsonEncode({
    'sub': sub,
    'exp': exp,
    'iat': DateTime.now().millisecondsSinceEpoch ~/ 1000,
    'tipo': tipo,
  })));
  return '$header.$payload.fake_signature';
}

/// Token valido que expira em 1 hora.
String get validAccessToken => createTestJWT(
      sub: 'user-123',
      exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
    );

/// Token expirado (expirou ha 1 hora).
String get expiredToken => createTestJWT(
      sub: 'user-123',
      exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 - 3600,
    );

/// JSON do usuario retornado pela API no login.
Map<String, dynamic> get userJson => {
      'id': 'user-123',
      'login': 'produtor1',
      'nome': 'Joao da Silva',
      'tipo': 'produtor',
      'ativo': true,
    };

/// Resposta de login bem-sucedida.
Map<String, dynamic> get loginSuccessBody => {
      'success': true,
      'data': {
        'access_token': validAccessToken,
        'refresh_token': validAccessToken,
        'user': userJson,
      },
    };

void main() {
  late MockSecureStorage mockStorage;
  late MockDio mockDio;
  late AuthService authService;

  setUp(() {
    mockStorage = MockSecureStorage();
    mockDio = MockDio();
    authService = AuthService(storage: mockStorage, dio: mockDio);

    // Stubs padrao para storage
    when(() => mockStorage.saveAccessToken(any())).thenAnswer((_) async {});
    when(() => mockStorage.saveRefreshToken(any())).thenAnswer((_) async {});
    when(() => mockStorage.clearTokens()).thenAnswer((_) async {});
  });

  group('AuthService', () {
    group('login', () {
      test('sucesso: armazena tokens e retorna User', () async {
        when(() => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => Response(
              data: loginSuccessBody,
              statusCode: 200,
              requestOptions: RequestOptions(path: '/auth/login'),
            ));

        final user = await authService.login('produtor1', 'senha123');

        expect(user.id, 'user-123');
        expect(user.login, 'produtor1');
        expect(user.nome, 'Joao da Silva');
        expect(user.tipo, 'produtor');
        verify(() => mockStorage.saveAccessToken(any())).called(1);
        verify(() => mockStorage.saveRefreshToken(any())).called(1);
      });

      test('401: lanca AuthException', () async {
        when(() => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 401,
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
          requestOptions: RequestOptions(path: '/auth/login'),
        ));

        expect(
          () => authService.login('user', 'wrong'),
          throwsA(isA<AuthException>()),
        );
      });

      test('erro de rede: lanca NetworkException', () async {
        when(() => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
          type: DioExceptionType.connectionError,
          requestOptions: RequestOptions(path: '/auth/login'),
        ));

        expect(
          () => authService.login('user', 'pass'),
          throwsA(isA<NetworkException>()),
        );
      });

      test('429: lanca AuthException com RATE_LIMITED', () async {
        when(() => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 429,
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
          requestOptions: RequestOptions(path: '/auth/login'),
        ));

        try {
          await authService.login('user', 'pass');
          fail('Deveria ter lancado AuthException');
        } on AuthException catch (e) {
          expect(e.code, 'RATE_LIMITED');
        }
      });

      test('500: lanca ServerException', () async {
        when(() => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenThrow(DioException(
          type: DioExceptionType.badResponse,
          response: Response(
            statusCode: 500,
            requestOptions: RequestOptions(path: '/auth/login'),
          ),
          requestOptions: RequestOptions(path: '/auth/login'),
        ));

        expect(
          () => authService.login('user', 'pass'),
          throwsA(isA<ServerException>()),
        );
      });
    });

    group('logout', () {
      test('chama clearTokens no storage', () async {
        await authService.logout();
        verify(() => mockStorage.clearTokens()).called(greaterThanOrEqualTo(1));
      });
    });

    group('refreshToken', () {
      test('sucesso: retorna novo access token', () async {
        final validRefresh = validAccessToken;
        when(() => mockStorage.getRefreshToken())
            .thenAnswer((_) async => validRefresh);

        when(() => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => Response(
              data: {
                'success': true,
                'data': {
                  'access_token': validAccessToken,
                },
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/auth/refresh'),
            ));

        final newToken = await authService.refreshToken();
        expect(newToken, isNotNull);
        verify(() => mockStorage.saveAccessToken(any())).called(1);
      });

      test('refresh token expirado: retorna null', () async {
        when(() => mockStorage.getRefreshToken())
            .thenAnswer((_) async => expiredToken);

        final result = await authService.refreshToken();
        expect(result, isNull);
        verify(() => mockStorage.clearTokens()).called(1);
      });

      test('sem refresh token: retorna null', () async {
        when(() => mockStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        final result = await authService.refreshToken();
        expect(result, isNull);
      });
    });

    group('isAuthenticated', () {
      test('token valido retorna true', () async {
        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => validAccessToken);

        final result = await authService.isAuthenticated();
        expect(result, true);
      });

      test('token expirado com refresh valido: tenta refresh', () async {
        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => expiredToken);
        when(() => mockStorage.getRefreshToken())
            .thenAnswer((_) async => validAccessToken);
        when(() => mockDio.post<Map<String, dynamic>>(
              any(),
              data: any(named: 'data'),
              options: any(named: 'options'),
            )).thenAnswer((_) async => Response(
              data: {
                'success': true,
                'data': {'access_token': validAccessToken},
              },
              statusCode: 200,
              requestOptions: RequestOptions(path: '/auth/refresh'),
            ));

        final result = await authService.isAuthenticated();
        expect(result, true);
      });

      test('sem tokens: retorna false', () async {
        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => null);
        when(() => mockStorage.getRefreshToken())
            .thenAnswer((_) async => null);

        final result = await authService.isAuthenticated();
        expect(result, false);
      });
    });

    group('getUserFromToken', () {
      test('retorna User com dados do JWT', () async {
        final token = createTestJWT(
          sub: 'user-abc',
          exp: DateTime.now().millisecondsSinceEpoch ~/ 1000 + 3600,
          tipo: 'tecnico',
        );
        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => token);

        final user = await authService.getUserFromToken();

        expect(user, isNotNull);
        expect(user!.id, 'user-abc');
        expect(user.tipo, 'tecnico');
      });

      test('retorna null quando nao ha token', () async {
        when(() => mockStorage.getAccessToken())
            .thenAnswer((_) async => null);

        final user = await authService.getUserFromToken();
        expect(user, isNull);
      });
    });
  });
}
