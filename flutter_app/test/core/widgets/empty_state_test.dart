import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/empty_state.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('EmptyState', () {
    testWidgets('renderiza icone', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          titulo: 'Nenhum lote',
        ),
      ));

      expect(find.byIcon(Icons.inbox), findsOneWidget);
    });

    testWidgets('renderiza titulo', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          titulo: 'Nenhum lote encontrado',
        ),
      ));

      expect(find.text('Nenhum lote encontrado'), findsOneWidget);
    });

    testWidgets('renderiza descricao quando fornecida', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          titulo: 'Nenhum lote',
          descricao: 'Crie um novo lote para comecar',
        ),
      ));

      expect(find.text('Crie um novo lote para comecar'), findsOneWidget);
    });

    testWidgets('nao renderiza descricao quando nao fornecida', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          titulo: 'Vazio',
        ),
      ));

      // Apenas o titulo e exibido (alem do icone)
      final textWidgets = find.byType(Text);
      expect(textWidgets, findsOneWidget);
    });

    testWidgets('renderiza botao de acao quando label e callback fornecidos',
        (tester) async {
      bool actionPressed = false;
      await tester.pumpWidget(buildTestWidget(
        EmptyState(
          icon: Icons.add,
          titulo: 'Vazio',
          actionLabel: 'Criar novo',
          onAction: () => actionPressed = true,
        ),
      ));

      expect(find.text('Criar novo'), findsOneWidget);
      await tester.tap(find.text('Criar novo'));
      expect(actionPressed, true);
    });

    testWidgets('nao renderiza botao quando actionLabel eh null',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const EmptyState(
          icon: Icons.inbox,
          titulo: 'Vazio',
        ),
      ));

      expect(find.byType(FilledButton), findsNothing);
    });

    testWidgets('botao possui icone quando actionIcon fornecido',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        EmptyState(
          icon: Icons.inbox,
          titulo: 'Vazio',
          actionLabel: 'Adicionar',
          onAction: () {},
          actionIcon: Icons.add,
        ),
      ));

      expect(find.byIcon(Icons.add), findsOneWidget);
    });
  });
}
