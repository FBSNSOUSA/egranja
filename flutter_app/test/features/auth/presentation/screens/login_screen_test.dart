import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/auth/auth_service.dart';
import 'package:egranja_flutter/core/error/exceptions.dart';
import 'package:egranja_flutter/features/auth/domain/repositories/auth_repository.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:egranja_flutter/features/auth/presentation/screens/login_screen.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

Widget buildLoginScreen({
  required AuthRepository mockRepo,
}) {
  return ProviderScope(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ],
    child: const MaterialApp(
      home: LoginScreen(),
    ),
  );
}

void main() {
  late MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = MockAuthRepository();
    // Por padrao, checkAuth retorna false (nao autenticado)
    when(() => mockRepo.isAuthenticated()).thenAnswer((_) async => false);
  });

  group('LoginScreen', () {
    testWidgets('renderiza logo "eGranja"', (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('eGranja'), findsOneWidget);
    });

    testWidgets('renderiza subtitulo', (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Gestao completa de aviarios'), findsOneWidget);
    });

    testWidgets('renderiza campo de usuario', (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Usuario'), findsOneWidget);
      expect(find.text('Digite seu usuario'), findsOneWidget);
    });

    testWidgets('renderiza campo de senha', (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Senha'), findsOneWidget);
      expect(find.text('Digite sua senha'), findsOneWidget);
    });

    testWidgets('renderiza botao "Entrar"', (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('Entrar'), findsOneWidget);
    });

    testWidgets('renderiza footer com versao', (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.text('eGranja v1.0.0'), findsOneWidget);
    });

    testWidgets('renderiza icone de usuario no campo login', (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_outline), findsOneWidget);
    });

    testWidgets('renderiza icone de cadeado no campo senha', (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    });

    testWidgets('exibe erro de validacao ao submeter usuario vazio',
        (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Tap no botao Entrar sem preencher campos
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe seu usuario'), findsOneWidget);
    });

    testWidgets('exibe erro de validacao ao submeter senha vazia',
        (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Preencher apenas usuario
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Usuario'),
        'admin',
      );

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Informe sua senha'), findsOneWidget);
    });

    testWidgets('chama login no repositorio ao submeter dados validos',
        (tester) async {
      final testUser = User(
        id: '1',
        login: 'admin',
        nome: 'Admin',
        tipo: 'produtor',
        ativo: true,
      );

      when(() => mockRepo.login('admin', 'senha123'))
          .thenAnswer((_) async => testUser);

      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Preencher campos
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Usuario'),
        'admin',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'senha123',
      );

      // Submeter
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      verify(() => mockRepo.login('admin', 'senha123')).called(1);
    });

    testWidgets('exibe CircularProgressIndicator durante loading',
        (tester) async {
      // Usar Completer para controlar quando o login termina
      final completer = Completer<User>();
      when(() => mockRepo.login(any(), any()))
          .thenAnswer((_) => completer.future);

      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Preencher campos
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Usuario'),
        'admin',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'senha123',
      );

      // Submeter
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Deve exibir indicador de loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Completar o future para limpar o estado
      completer.complete(User(
        id: '1',
        login: 'admin',
        nome: 'Admin',
        tipo: 'produtor',
        ativo: true,
      ));
      await tester.pumpAndSettle();
    });

    testWidgets('exibe mensagem de erro do repositorio na tela',
        (tester) async {
      when(() => mockRepo.login(any(), any())).thenThrow(
        const AuthException(
          code: 'INVALID_CREDENTIALS',
          message: 'Usuario ou senha incorretos.',
        ),
      );

      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Preencher campos
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Usuario'),
        'admin',
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, 'Senha'),
        'errada',
      );

      // Submeter
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // A mensagem de erro deve aparecer na tela (e/ou como SnackBar)
      expect(find.text('Usuario ou senha incorretos.'), findsWidgets);
    });

    testWidgets('botao de visibilidade alterna obscureText da senha',
        (tester) async {
      await tester.pumpWidget(buildLoginScreen(mockRepo: mockRepo));
      await tester.pumpAndSettle();

      // Inicialmente, deve ter icone de visibilidade (senha oculta)
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      // Tap no icone para revelar senha
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();

      // Agora deve ter icone de visibilidade_off (senha visivel)
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });
  });
}
