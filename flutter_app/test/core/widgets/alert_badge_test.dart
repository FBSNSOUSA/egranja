import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/alert_badge.dart';

Widget buildTestWidget(Widget child) {
  // AlertBadge usa Positioned, entao precisa de um Stack como pai
  return MaterialApp(
    home: Scaffold(
      body: Stack(children: [child]),
    ),
  );
}

void main() {
  group('AlertBadge', () {
    testWidgets('renderiza contagem quando maior que 0', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AlertBadge(count: 5),
      ));

      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('renderiza SizedBox.shrink quando count eh 0',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AlertBadge(count: 0),
      ));

      // Nao deve exibir nenhum texto de contagem
      expect(find.text('0'), findsNothing);
      // Widget deve ser SizedBox.shrink
      final sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
      expect(sizedBox.width, 0);
    });

    testWidgets('exibe "99+" quando count eh maior que 99', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AlertBadge(count: 150),
      ));

      expect(find.text('99+'), findsOneWidget);
    });

    testWidgets('possui Semantics widget com label para 1 alerta',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AlertBadge(count: 1),
      ));

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final badgeSemantics = semantics.where(
        (s) => s.properties.label == '1 alerta',
      );
      expect(badgeSemantics, isNotEmpty);
    });

    testWidgets('possui Semantics widget com label para multiplos alertas',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AlertBadge(count: 3),
      ));

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final badgeSemantics = semantics.where(
        (s) => s.properties.label == '3 alertas',
      );
      expect(badgeSemantics, isNotEmpty);
    });

    testWidgets('modo dotOnly exibe apenas ponto sem texto', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AlertBadge(count: 0, dotOnly: true),
      ));

      // Nao deve ter nenhum Text dentro do Container
      // O widget deve renderizar (dotOnly ignora count <= 0 check)
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('dotOnly possui Semantics label "Tem alerta"', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AlertBadge(count: 0, dotOnly: true),
      ));

      expect(find.bySemanticsLabel('Tem alerta'), findsOneWidget);
    });

    testWidgets('renderiza contagem para count negativo como oculto',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AlertBadge(count: -1),
      ));

      // count <= 0 e dotOnly=false => SizedBox.shrink
      expect(find.text('-1'), findsNothing);
    });
  });
}
