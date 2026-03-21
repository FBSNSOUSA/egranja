import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/staggered_list.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('StaggeredListView', () {
    testWidgets('renderiza todos os filhos', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        StaggeredListView(
          children: const [
            Text('Item 1'),
            Text('Item 2'),
            Text('Item 3'),
          ],
        ),
      ));

      // Avancar animacao
      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('renderiza lista vazia sem erros', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const StaggeredListView(children: []),
      ));

      await tester.pumpAndSettle();

      expect(find.byType(StaggeredListView), findsOneWidget);
    });

    testWidgets('anima ao construir (fade + slide)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        StaggeredListView(
          children: const [
            Text('Animado'),
          ],
        ),
      ));

      // No frame inicial, FadeTransition e SlideTransition devem existir
      expect(find.byType(FadeTransition), findsWidgets);
      expect(find.byType(SlideTransition), findsWidgets);

      // Avancar animacao
      await tester.pumpAndSettle();

      // Apos animacao, os widgets continuam visiveis
      expect(find.text('Animado'), findsOneWidget);
    });

    testWidgets('suporta shrinkWrap', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        Column(
          children: [
            StaggeredListView(
              shrinkWrap: true,
              children: const [
                Text('A'),
                Text('B'),
              ],
            ),
          ],
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('A'), findsOneWidget);
      expect(find.text('B'), findsOneWidget);
    });

    testWidgets('usa padding fornecido', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        StaggeredListView(
          padding: const EdgeInsets.all(16),
          children: const [
            Text('Com padding'),
          ],
        ),
      ));

      await tester.pumpAndSettle();
      expect(find.text('Com padding'), findsOneWidget);
    });
  });
}
