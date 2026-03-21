import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:egranja_flutter/core/di/providers.dart';
import 'package:egranja_flutter/core/sync/sync_service.dart';
import 'package:egranja_flutter/core/sync/sync_state.dart';
import 'package:egranja_flutter/core/widgets/offline_indicator.dart';

class MockSyncService extends Mock implements SyncService {}

Widget buildTestWidgetWithProviders(
  Widget child, {
  List<Override> overrides = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(home: Scaffold(body: child)),
  );
}

void main() {
  late MockSyncService mockSyncService;

  setUp(() {
    mockSyncService = MockSyncService();
  });

  /// Cria override de syncProvider com pendingCount que o mock retorna
  Override syncOverride(SyncState targetState) {
    when(() => mockSyncService.getPendingCount())
        .thenAnswer((_) async => targetState.pendingCount);
    return syncProvider.overrideWith((ref) {
      final notifier = SyncNotifier(mockSyncService);
      // Aguardar que o construtor termine, depois sobreescrever
      return notifier;
    });
  }

  group('OfflineIndicator', () {
    testWidgets('exibe mensagem "Sem conexao" quando offline', (tester) async {
      await tester.pumpWidget(buildTestWidgetWithProviders(
        const OfflineIndicator(),
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
          syncOverride(const SyncState()),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.text('Sem conexao com a internet'), findsOneWidget);
    });

    testWidgets('exibe icone wifi_off quando offline', (tester) async {
      await tester.pumpWidget(buildTestWidgetWithProviders(
        const OfflineIndicator(),
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
          syncOverride(const SyncState()),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.wifi_off_outlined), findsOneWidget);
    });

    testWidgets('oculto quando online sem pendencias', (tester) async {
      await tester.pumpWidget(buildTestWidgetWithProviders(
        const OfflineIndicator(),
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value(true),
          ),
          syncOverride(const SyncState(pendingCount: 0)),
        ],
      ));

      await tester.pumpAndSettle();

      expect(find.text('Sem conexao com a internet'), findsNothing);
      expect(find.text('Sincronizando dados...'), findsNothing);
    });

    testWidgets('contem AnimatedContainer para transicoes', (tester) async {
      await tester.pumpWidget(buildTestWidgetWithProviders(
        const OfflineIndicator(),
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value(true),
          ),
          syncOverride(const SyncState(pendingCount: 0)),
        ],
      ));

      await tester.pumpAndSettle();

      // O OfflineIndicator usa AnimatedContainer para transicoes
      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('exibe texto de hint quando offline', (tester) async {
      await tester.pumpWidget(buildTestWidgetWithProviders(
        const OfflineIndicator(),
        overrides: [
          connectivityProvider.overrideWith(
            (ref) => Stream.value(false),
          ),
          syncOverride(const SyncState()),
        ],
      ));

      await tester.pumpAndSettle();

      expect(
        find.text('Os dados serao sincronizados quando a conexao retornar'),
        findsOneWidget,
      );
    });
  });
}
