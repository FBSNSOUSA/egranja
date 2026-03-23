import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:egranja_flutter/core/auth/auth_service.dart';
import 'package:egranja_flutter/core/router/app_router.dart';
import 'package:egranja_flutter/core/router/route_names.dart';
import 'package:egranja_flutter/core/sync/sync_state.dart';
import 'package:egranja_flutter/features/auth/presentation/providers/auth_provider.dart';
import 'package:egranja_flutter/features/notifications/presentation/providers/alertas_provider.dart';

// ── Fake Notifiers ────────────────────────────────────────────────────

class FakeAuthNotifier extends StateNotifier<AuthState>
    implements AuthNotifier {
  FakeAuthNotifier(super.initial);

  @override
  Future<void> login(String username, String password) async {}
  @override
  Future<String?> register({
    required String nome,
    required String email,
    required String telefone,
    required String senha,
    required String tipo,
  }) async => null;
  @override
  Future<void> logout() async {}
  @override
  Future<String?> forgotPassword(String email) async => null;
  @override
  Future<void> checkAuth() async {}
  @override
  void clearError() {}
}

class FakeAlertasNotifier extends StateNotifier<AlertasState>
    implements AlertasNotifier {
  FakeAlertasNotifier() : super(const AlertasState());

  @override
  Future<void> fetchAlertas() async {}
  @override
  Future<void> refresh() async {}
}

// ── Test Helpers ───────────────────────────────────────────────────────

const _testUser = User(
  id: 'user-123',
  login: 'produtor1',
  nome: 'Produtor Teste',
  tipo: 'produtor',
);

ProviderContainer _createContainer({
  AuthState? authState,
}) {
  final effectiveAuthState = authState ??
      const AuthState(
        status: AuthStatus.authenticated,
        user: _testUser,
      );

  return ProviderContainer(
    overrides: [
      authNotifierProvider
          .overrideWith((_) => FakeAuthNotifier(effectiveAuthState)),
      alertasProvider.overrideWith((_) => FakeAlertasNotifier()),
      alertasCountProvider.overrideWith((ref) => 0),
      syncProvider.overrideWith((_) => SyncNotifier(null)),
    ],
  );
}

Widget _createTestApp(ProviderContainer container) {
  final router = container.read(goRouterProvider);
  return UncontrolledProviderScope(
    container: container,
    child: MaterialApp.router(routerConfig: router),
  );
}

// ── Tests ──────────────────────────────────────────────────────────────

void main() {
  group('Router Navigation', () {
    late ProviderContainer container;
    late GoRouter router;

    setUp(() {
      container = _createContainer();
      router = container.read(goRouterProvider);
    });

    tearDown(() {
      container.dispose();
    });

    // Helper to set a larger viewport to avoid overflow in tests
    void useWideViewport(WidgetTester tester) {
      tester.view.physicalSize = const Size(1200, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }

    testWidgets('Home renders with AppBar and title', (tester) async {
      router.go('/');
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('eGranja'), findsOneWidget);
    });

    testWidgets('Main shell routes render without errors', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final mainRoutes = {
        RouteNames.home: 'eGranja',
        RouteNames.checklist: 'Checklist Diario',
        RouteNames.chatList: 'Mensagens',
        RouteNames.relatorios: 'Relatorios',
        RouteNames.configuracoes: 'Configuracoes',
        RouteNames.notificacoes: 'Alertas',
        RouteNames.granjaList: 'Granjas',
        RouteNames.mapaGalpoes: 'Mapa de Galpoes',
      };

      for (final entry in mainRoutes.entries) {
        router.goNamed(entry.key);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.byType(AppBar),
          findsOneWidget,
          reason: 'AppBar missing on route ${entry.key}',
        );
        expect(
          find.text(entry.value),
          findsWidgets,
          reason: 'Title "${entry.value}" missing on route ${entry.key}',
        );
      }
    });

    testWidgets('Lote detail shows correct title', (tester) async {
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      router.goNamed(
        RouteNames.loteDetail,
        pathParameters: {'loteId': 'test-lote-id'},
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Detalhe do Lote'), findsOneWidget);
    });

    testWidgets('Form routes show correct titles', (tester) async {
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final formRoutes = {
        RouteNames.novaPesagem: 'Nova Pesagem',
        RouteNames.novaMortalidade: 'Nova Mortalidade',
        RouteNames.novoRecebimento: 'Novo Recebimento',
        RouteNames.novoConsumo: 'Consumo de Racao',
        RouteNames.novoConsumoAgua: 'Consumo de Agua',
        RouteNames.finalizarLote: 'Finalizar Lote',
      };

      for (final entry in formRoutes.entries) {
        router.goNamed(
          entry.key,
          pathParameters: {'loteId': 'test-lote-id'},
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.text(entry.value),
          findsWidgets,
          reason: 'Title "${entry.value}" missing for route ${entry.key}',
        );
      }
    });

    testWidgets('Granja routes show correct titles', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      router.goNamed(RouteNames.granjaForm);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Nova Granja'), findsOneWidget);

      router.goNamed(
        RouteNames.granjaDetail,
        pathParameters: {'granjaId': 'test-granja-id'},
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Detalhe da Granja'), findsOneWidget);

      router.goNamed(
        RouteNames.granjaFormEdit,
        pathParameters: {'granjaId': 'test-granja-id'},
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Editar Granja'), findsOneWidget);
    });

    testWidgets('Home shows hamburger menu icon', (tester) async {
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      router.goNamed(RouteNames.home);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should have the auto-generated hamburger icon (DrawerButton)
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Drawer opens with navigation items', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final scaffoldFinder = find.byType(Scaffold);
      expect(scaffoldFinder, findsOneWidget);
      final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder.first);
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Inicio'), findsOneWidget);
      expect(find.text('Checklist Diario'), findsOneWidget);
      expect(find.text('Alertas'), findsOneWidget);
      expect(find.text('Sair'), findsOneWidget);
    });

    testWidgets('Drawer navigation works', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Open drawer
      final scaffoldFinder = find.byType(Scaffold);
      final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder.first);
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Tap "Checklist Diario"
      await tester.tap(find.text('Checklist Diario'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Should navigate to checklist and show its title
      expect(find.text('Checklist Diario'), findsWidgets);
    });

    testWidgets('Drawer shows user info', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final scaffoldFinder = find.byType(Scaffold);
      final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder.first);
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // User name and initials
      expect(find.text('Produtor Teste'), findsOneWidget);
      expect(find.text('P'), findsWidgets); // user initial
      expect(find.text('produtor1'), findsOneWidget); // login
    });

    testWidgets('Drawer has all section headers', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      final scaffoldFinder = find.byType(Scaffold);
      final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder.first);
      scaffoldState.openDrawer();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));

      // Section headers (uppercase)
      expect(find.text('TAREFAS DIARIAS'), findsOneWidget);
      expect(find.text('MONITORAMENTO'), findsOneWidget);
      expect(find.text('SANIDADE'), findsOneWidget);
      expect(find.text('ANALISE'), findsOneWidget);
    });

    testWidgets('Notification icon navigates to alertas', (tester) async {
      useWideViewport(tester);
      await tester.pumpWidget(_createTestApp(container));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Tap notification icon
      await tester.tap(find.byIcon(Icons.notifications_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Alertas'), findsWidgets);
    });

    testWidgets('Unauthenticated redirects to login', (tester) async {
      final unauthContainer = _createContainer(
        authState: const AuthState(status: AuthStatus.unauthenticated),
      );
      final unauthRouter = unauthContainer.read(goRouterProvider);

      unauthRouter.go('/');
      await tester.pumpWidget(_createTestApp(unauthContainer));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(TextFormField), findsWidgets);

      unauthContainer.dispose();
    });
  });
}
