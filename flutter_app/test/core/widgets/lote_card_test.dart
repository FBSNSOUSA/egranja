import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/lote_card.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

LoteCardData createTestData({
  String id = 'lote-1',
  String galpaoNome = 'Galpao A',
  DateTime? dataAlojamento,
  String tipo = 'Frango',
  String linhagem = 'Cobb 500',
  int quantidadeOriginal = 30000,
  int mortalidadeAcumulada = 150,
  int? diasDeVida,
  int? avesVivas,
}) {
  return LoteCardData(
    id: id,
    galpaoNome: galpaoNome,
    dataAlojamento: dataAlojamento ?? DateTime.now().subtract(const Duration(days: 21)),
    tipo: tipo,
    linhagem: linhagem,
    quantidadeOriginal: quantidadeOriginal,
    mortalidadeAcumulada: mortalidadeAcumulada,
    diasDeVida: diasDeVida,
    avesVivas: avesVivas,
  );
}

void main() {
  group('LoteCard', () {
    testWidgets('renderiza nome do galpao', (tester) async {
      final data = createTestData(galpaoNome: 'Galpao B');
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('Galpao B'), findsOneWidget);
    });

    testWidgets('renderiza tipo e linhagem como chips', (tester) async {
      final data = createTestData(tipo: 'Frango', linhagem: 'Cobb 500');
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('Frango'), findsOneWidget);
      expect(find.text('Cobb 500'), findsOneWidget);
    });

    testWidgets('renderiza dias de vida calculados', (tester) async {
      final data = createTestData(
        dataAlojamento: DateTime.now().subtract(const Duration(days: 25)),
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('25'), findsOneWidget);
      expect(find.text('dias'), findsOneWidget);
    });

    testWidgets('renderiza dias de vida do backend quando disponivel', (tester) async {
      final data = createTestData(
        dataAlojamento: DateTime.now().subtract(const Duration(days: 25)),
        diasDeVida: 24, // backend may differ from calculated
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('24'), findsOneWidget);
      expect(find.text('dias'), findsOneWidget);
    });

    testWidgets('renderiza aves vivas calculadas', (tester) async {
      final data = createTestData(
        quantidadeOriginal: 30000,
        mortalidadeAcumulada: 500,
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      // avesVivas = 30000 - 500 = 29500
      expect(find.text('29500'), findsOneWidget);
      expect(find.text('Aves vivas'), findsOneWidget);
    });

    testWidgets('renderiza aves vivas do backend quando disponivel', (tester) async {
      final data = createTestData(
        quantidadeOriginal: 30000,
        mortalidadeAcumulada: 500,
        avesVivas: 29400, // backend value takes precedence
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('29400'), findsOneWidget);
      expect(find.text('Aves vivas'), findsOneWidget);
    });

    testWidgets('tap dispara callback onTap', (tester) async {
      bool tapped = false;
      final data = createTestData();
      await tester.pumpWidget(buildTestWidget(
        LoteCard(data: data, onTap: () => tapped = true),
      ));

      await tester.tap(find.byType(LoteCard));
      expect(tapped, true);
    });

    testWidgets('possui Hero widget com tag correto', (tester) async {
      final data = createTestData(id: 'lote-42');
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      final hero = tester.widget<Hero>(find.byType(Hero));
      expect(hero.tag, 'lote_lote-42');
    });

    testWidgets('possui Semantics label com dados do lote', (tester) async {
      final data = createTestData(
        galpaoNome: 'Galpao C',
        dataAlojamento: DateTime.now().subtract(const Duration(days: 10)),
        quantidadeOriginal: 20000,
        mortalidadeAcumulada: 100,
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      // Semantics label: 'Lote Galpao C, 10 dias, 19900 aves vivas'
      expect(
        find.bySemanticsLabel(RegExp(r'Lote Galpao C, 10 dias, 19900 aves vivas')),
        findsOneWidget,
      );
    });

    testWidgets('renderiza data de alojamento formatada', (tester) async {
      final data = createTestData(
        dataAlojamento: DateTime(2025, 3, 15),
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('Alojamento: 15/03/2025'), findsOneWidget);
    });

    testWidgets('renderiza mortalidade total', (tester) async {
      final data = createTestData(
        mortalidadeAcumulada: 150,
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('150'), findsOneWidget);
      expect(find.text('Mortalidade'), findsOneWidget);
    });
  });

  group('LoteCardData', () {
    test('diasDeVidaEfetivo calcula a partir de dataAlojamento quando diasDeVida nulo', () {
      final data = createTestData(
        dataAlojamento: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(data.diasDeVidaEfetivo, 30);
    });

    test('diasDeVidaEfetivo usa valor do backend quando disponivel', () {
      final data = createTestData(
        dataAlojamento: DateTime.now().subtract(const Duration(days: 30)),
        diasDeVida: 28,
      );
      expect(data.diasDeVidaEfetivo, 28);
    });

    test('avesVivasEfetivo calcula quando avesVivas nulo', () {
      final data = createTestData(
        quantidadeOriginal: 25000,
        mortalidadeAcumulada: 200,
      );
      expect(data.avesVivasEfetivo, 24800);
    });

    test('avesVivasEfetivo usa valor do backend quando disponivel', () {
      final data = createTestData(
        quantidadeOriginal: 25000,
        mortalidadeAcumulada: 200,
        avesVivas: 24750,
      );
      expect(data.avesVivasEfetivo, 24750);
    });
  });
}
