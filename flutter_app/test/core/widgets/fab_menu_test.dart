import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/fab_menu.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(
      floatingActionButton: child,
    ),
  );
}

void main() {
  group('FABMenu', () {
    testWidgets('renderiza FAB com icone padrao', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        FABMenu(
          actions: [
            FABAction(label: 'Acao', icon: Icons.add, onPress: () {}),
          ],
        ),
      ));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('acao unica executa direto ao pressionar', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(buildTestWidget(
        FABMenu(
          actions: [
            FABAction(
              label: 'Adicionar',
              icon: Icons.add,
              onPress: () => pressed = true,
            ),
          ],
        ),
      ));

      await tester.tap(find.byType(FloatingActionButton));
      expect(pressed, true);
    });

    testWidgets('multiplas acoes exibem menu ao pressionar', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        FABMenu(
          actions: [
            FABAction(label: 'Mortalidade', icon: Icons.warning, onPress: () {}),
            FABAction(label: 'Pesagem', icon: Icons.scale, onPress: () {}),
          ],
        ),
      ));

      // Pressionar FAB principal
      await tester.tap(find.byType(FloatingActionButton).last);
      await tester.pumpAndSettle();

      // Labels das acoes devem aparecer
      expect(find.text('Mortalidade'), findsOneWidget);
      expect(find.text('Pesagem'), findsOneWidget);
    });

    testWidgets('acoes do menu executam callback e fecham', (tester) async {
      bool actionExecuted = false;
      await tester.pumpWidget(buildTestWidget(
        FABMenu(
          actions: [
            FABAction(
              label: 'Mortalidade',
              icon: Icons.warning,
              onPress: () => actionExecuted = true,
            ),
            FABAction(label: 'Pesagem', icon: Icons.scale, onPress: () {}),
          ],
        ),
      ));

      // Abrir menu
      await tester.tap(find.byType(FloatingActionButton).last);
      await tester.pumpAndSettle();

      // Pressionar acao especifica (mini-FAB)
      await tester.tap(find.byIcon(Icons.warning));
      await tester.pumpAndSettle();

      expect(actionExecuted, true);
    });

    testWidgets('usa icone personalizado', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        FABMenu(
          mainIcon: Icons.menu,
          actions: [
            FABAction(label: 'Teste', icon: Icons.star, onPress: () {}),
          ],
        ),
      ));

      expect(find.byIcon(Icons.menu), findsOneWidget);
    });

    testWidgets('sem acoes renderiza FAB simples', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FABMenu(actions: []),
      ));

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
