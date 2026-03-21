import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/auth/auth_service.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';

// ── Mock ───────────────────────────────────────────────────────────────

class MockAuthRepository extends Mock implements AuthRepository {}

// ── Helpers ────────────────────────────────────────────────────────────

const testUser = User(
  id: 'user-123',
  login: 'produtor1',
  nome: 'Joao da Silva',
  tipo: 'produtor',
  ativo: true,
);

void main() {
  late MockAuthRepository mockRepository;
  late AuthNotifier notifier;

  setUp(() {
    mockRepository = MockAuthRepository();
    notifier = AuthNotifier(repository: mockRepository);
  });

  group('AuthNotifier', () {
    group('checkAuth', () {
      test('autenticado: define AuthStatus.authenticated com user', () async {
        when(() => mockRepository.isAuthenticated())
            .thenAnswer((_) async => true);
        when(() => mockRepository.getCurrentUser())
            .thenAnswer((_) async => testUser);

        await notifier.checkAuth();

        expect(notifier.state.status, AuthStatus.authenticated);
        expect(notifier.state.user, testUser);
      });

      test('nao autenticado: define AuthStatus.unauthenticated', () async {
        when(() => mockRepository.isAuthenticated())
            .thenAnswer((_) async => false);

        await notifier.checkAuth();

        expect(notifier.state.status, AuthStatus.unauthenticated);
        expect(notifier.state.user, isNull);
      });

      test('erro: define AuthStatus.unauthenticated', () async {
        when(() => mockRepository.isAuthenticated())
            .thenThrow(Exception('erro'));

        await notifier.checkAuth();

        expect(notifier.state.status, AuthStatus.unauthenticated);
      });
    });

    group('login', () {
      test('sucesso: define AuthStatus.authenticated', () async {
        when(() => mockRepository.login(any(), any()))
            .thenAnswer((_) async => testUser);

        await notifier.login('produtor1', 'senha123');

        expect(notifier.state.status, AuthStatus.authenticated);
        expect(notifier.state.user, testUser);
      });

      test('AuthException: define AuthStatus.error com mensagem', () async {
        when(() => mockRepository.login(any(), any())).thenThrow(
          const AuthException(
            code: 'INVALID_CREDENTIALS',
            message: 'Usuario ou senha incorretos.',
          ),
        );

        await notifier.login('user', 'wrong');

        expect(notifier.state.status, AuthStatus.error);
        expect(notifier.state.errorMessage, 'Usuario ou senha incorretos.');
      });

      test('NetworkException: define AuthStatus.error', () async {
        when(() => mockRepository.login(any(), any())).thenThrow(
          const NetworkException(),
        );

        await notifier.login('user', 'pass');

        expect(notifier.state.status, AuthStatus.error);
        expect(notifier.state.errorMessage, isNotNull);
      });

      test('ServerException: define AuthStatus.error', () async {
        when(() => mockRepository.login(any(), any())).thenThrow(
          const ServerException(),
        );

        await notifier.login('user', 'pass');

        expect(notifier.state.status, AuthStatus.error);
        expect(notifier.state.errorMessage, isNotNull);
      });
    });

    group('logout', () {
      test('define AuthStatus.unauthenticated', () async {
        // Primeiro fazer login
        when(() => mockRepository.login(any(), any()))
            .thenAnswer((_) async => testUser);
        await notifier.login('user', 'pass');
        expect(notifier.state.status, AuthStatus.authenticated);

        // Depois fazer logout
        when(() => mockRepository.logout()).thenAnswer((_) async {});

        await notifier.logout();

        expect(notifier.state.status, AuthStatus.unauthenticated);
        expect(notifier.state.user, isNull);
      });
    });

    group('clearError', () {
      test('muda de error para unauthenticated', () async {
        when(() => mockRepository.login(any(), any())).thenThrow(
          const AuthException(message: 'Erro'),
        );
        await notifier.login('user', 'pass');
        expect(notifier.state.status, AuthStatus.error);

        notifier.clearError();

        expect(notifier.state.status, AuthStatus.unauthenticated);
        expect(notifier.state.errorMessage, isNull);
      });

      test('nao altera estado se nao esta em error', () async {
        // Estado inicial
        expect(notifier.state.status, AuthStatus.initial);

        notifier.clearError();

        // Deve continuar initial, nao mudar para unauthenticated
        expect(notifier.state.status, AuthStatus.initial);
      });
    });
  });
}
