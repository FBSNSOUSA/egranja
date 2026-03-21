import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/indicator_card.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('IndicatorCard', () {
    testWidgets('renderiza o texto do label', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(label: 'IEP', valor: '350'),
      ));

      expect(find.text('IEP'), findsOneWidget);
    });

    testWidgets('renderiza o texto do valor', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(label: 'Mortalidade', valor: '2.3%'),
      ));

      expect(find.text('2.3%'), findsOneWidget);
    });

    testWidgets('renderiza icone quando fornecido', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(
          label: 'Peso',
          valor: '1680g',
          icone: Icons.monitor_weight,
        ),
      ));

      expect(find.byIcon(Icons.monitor_weight), findsOneWidget);
    });

    testWidgets('nao renderiza icone quando nao fornecido', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(label: 'IEP', valor: '350'),
      ));

      // Nao deve haver nenhum Icon widget
      expect(find.byType(Icon), findsNothing);
    });

    testWidgets('renderiza subtitulo quando fornecido', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(
          label: 'Peso',
          valor: '1680g',
          subtitulo: 'Benchmark: 1700g',
        ),
      ));

      expect(find.text('Benchmark: 1700g'), findsOneWidget);
    });

    testWidgets('nao renderiza subtitulo quando nao fornecido', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(label: 'IEP', valor: '350'),
      ));

      // Apenas label e valor - 2 Text widgets no total
      // (dentro do AnimatedDefaultTextStyle ha um Text)
      expect(find.text('IEP'), findsOneWidget);
      expect(find.text('350'), findsOneWidget);
    });

    testWidgets('possui Semantics label correto sem subtitulo',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(label: 'IEP', valor: '350'),
      ));

      expect(find.bySemanticsLabel('IEP: 350'), findsOneWidget);
    });

    testWidgets('possui Semantics label correto com subtitulo',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(
          label: 'Peso',
          valor: '1680g',
          subtitulo: 'meta: 1700g',
        ),
      ));

      expect(
        find.bySemanticsLabel('Peso: 1680g, meta: 1700g'),
        findsOneWidget,
      );
    });

    testWidgets('renderiza no modo compacto sem erros', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(
          label: 'IEP',
          valor: '350',
          icone: Icons.bar_chart,
          subtitulo: 'Bom',
          compacto: true,
        ),
      ));

      expect(find.text('IEP'), findsOneWidget);
      expect(find.text('350'), findsOneWidget);
      expect(find.text('Bom'), findsOneWidget);
    });

    testWidgets('aplica cor personalizada ao icone', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(
          label: 'Status',
          valor: 'OK',
          icone: Icons.check,
          cor: Colors.green,
        ),
      ));

      final icon = tester.widget<Icon>(find.byIcon(Icons.check));
      expect(icon.color, Colors.green);
    });

    testWidgets('contem Card widget', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const IndicatorCard(label: 'IEP', valor: '350'),
      ));

      expect(find.byType(Card), findsOneWidget);
    });
  });
}
