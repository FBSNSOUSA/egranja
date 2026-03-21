import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/error_widget.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('AppErrorWidget', () {
    testWidgets('renderiza mensagem de erro', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppErrorWidget(message: 'Erro ao carregar dados'),
      ));

      expect(find.text('Erro ao carregar dados'), findsOneWidget);
    });

    testWidgets('renderiza icone padrao de erro', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppErrorWidget(message: 'Erro'),
      ));

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('renderiza icone personalizado', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppErrorWidget(
          message: 'Sem conexao',
          icon: Icons.wifi_off,
        ),
      ));

      expect(find.byIcon(Icons.wifi_off), findsOneWidget);
    });

    testWidgets('renderiza botao de retry quando onRetry fornecido',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppErrorWidget(
          message: 'Erro',
          onRetry: () {},
        ),
      ));

      expect(find.text('Tentar novamente'), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('botao de retry executa callback', (tester) async {
      bool retried = false;
      await tester.pumpWidget(buildTestWidget(
        AppErrorWidget(
          message: 'Erro',
          onRetry: () => retried = true,
        ),
      ));

      await tester.tap(find.text('Tentar novamente'));
      expect(retried, true);
    });

    testWidgets('nao renderiza botao quando onRetry eh null', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AppErrorWidget(message: 'Erro'),
      ));

      expect(find.byType(OutlinedButton), findsNothing);
      expect(find.text('Tentar novamente'), findsNothing);
    });

    testWidgets('usa retryLabel personalizado', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AppErrorWidget(
          message: 'Erro',
          onRetry: () {},
          retryLabel: 'Recarregar',
        ),
      ));

      expect(find.text('Recarregar'), findsOneWidget);
    });
  });
}
