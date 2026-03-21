import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/animated_counter.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('AnimatedCounter', () {
    testWidgets('renderiza valor inicial', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AnimatedCounter(value: 100),
      ));

      // Avancar animacao ate completar
      await tester.pumpAndSettle();

      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('renderiza valor com formatter customizado', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        AnimatedCounter(
          value: 1680,
          formatter: (v) => '${v.toStringAsFixed(0)} g',
        ),
      ));

      await tester.pumpAndSettle();

      expect(find.text('1680 g'), findsOneWidget);
    });

    testWidgets('atualiza display quando valor muda', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AnimatedCounter(value: 50),
      ));
      await tester.pumpAndSettle();
      expect(find.text('50'), findsOneWidget);

      // Atualizar valor
      await tester.pumpWidget(buildTestWidget(
        const AnimatedCounter(value: 200),
      ));
      await tester.pumpAndSettle();
      expect(find.text('200'), findsOneWidget);
    });

    testWidgets('usa textStyle fornecido', (tester) async {
      const style = TextStyle(fontSize: 24, fontWeight: FontWeight.bold);
      await tester.pumpWidget(buildTestWidget(
        const AnimatedCounter(
          value: 42,
          textStyle: style,
        ),
      ));

      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('42'));
      expect(text.style?.fontSize, 24);
      expect(text.style?.fontWeight, FontWeight.bold);
    });

    testWidgets('renderiza valor zero', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AnimatedCounter(value: 0),
      ));

      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('anima durante transicao de valor', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AnimatedCounter(
          value: 0,
          duration: Duration(milliseconds: 600),
        ),
      ));
      await tester.pumpAndSettle();

      // Mudar para 100
      await tester.pumpWidget(buildTestWidget(
        const AnimatedCounter(
          value: 100,
          duration: Duration(milliseconds: 600),
        ),
      ));

      // No meio da animacao, o valor deve estar entre 0 e 100
      await tester.pump(const Duration(milliseconds: 300));

      // Verificar que o widget existe (o valor intermediario eh animado)
      expect(find.byType(AnimatedCounter), findsOneWidget);

      // Completar animacao
      await tester.pumpAndSettle();
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('renderiza com textAlign', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const AnimatedCounter(
          value: 50,
          textAlign: TextAlign.center,
        ),
      ));

      await tester.pumpAndSettle();

      final text = tester.widget<Text>(find.text('50'));
      expect(text.textAlign, TextAlign.center);
    });
  });
}
