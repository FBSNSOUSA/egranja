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
  double? ultimoPesoMedio,
  double? pesoBenchmark,
  int? mortesRecentes,
  DateTime? dataMortesRecentes,
  double? mortalidadeRecentePct,
  bool temAlerta = false,
  int quantidadeAlertas = 0,
}) {
  return LoteCardData(
    id: id,
    galpaoNome: galpaoNome,
    dataAlojamento: dataAlojamento ?? DateTime.now().subtract(const Duration(days: 21)),
    tipo: tipo,
    linhagem: linhagem,
    quantidadeOriginal: quantidadeOriginal,
    mortalidadeAcumulada: mortalidadeAcumulada,
    ultimoPesoMedio: ultimoPesoMedio,
    pesoBenchmark: pesoBenchmark,
    mortesRecentes: mortesRecentes,
    dataMortesRecentes: dataMortesRecentes,
    mortalidadeRecentePct: mortalidadeRecentePct,
    temAlerta: temAlerta,
    quantidadeAlertas: quantidadeAlertas,
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

    testWidgets('renderiza dias de vida', (tester) async {
      final data = createTestData(
        dataAlojamento: DateTime.now().subtract(const Duration(days: 25)),
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('25'), findsOneWidget);
      expect(find.text('dias'), findsOneWidget);
    });

    testWidgets('renderiza aves vivas', (tester) async {
      final data = createTestData(
        quantidadeOriginal: 30000,
        mortalidadeAcumulada: 500,
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      // avesVivas = 30000 - 500 = 29500
      expect(find.text('29500'), findsOneWidget);
      expect(find.text('Aves vivas'), findsOneWidget);
    });

    testWidgets('renderiza peso medio quando fornecido', (tester) async {
      final data = createTestData(ultimoPesoMedio: 1680);
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('1680 g'), findsOneWidget);
      expect(find.text('Peso medio'), findsOneWidget);
    });

    testWidgets('renderiza "--" quando peso medio nao disponivel',
        (tester) async {
      final data = createTestData(ultimoPesoMedio: null);
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('--'), findsOneWidget);
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

    testWidgets('exibe mortalidade recente quando ha mortes', (tester) async {
      final data = createTestData(
        mortesRecentes: 5,
        mortalidadeRecentePct: 0.25,
      );
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.text('5 mortes recentes'), findsOneWidget);
      expect(find.text('(0.25%)'), findsOneWidget);
    });

    testWidgets('nao exibe mortalidade recente quando nao ha mortes',
        (tester) async {
      final data = createTestData(mortesRecentes: null);
      await tester.pumpWidget(buildTestWidget(LoteCard(data: data)));

      expect(find.textContaining('mortes recentes'), findsNothing);
    });
  });

  group('LoteCardData', () {
    test('calcula diasDeVida corretamente', () {
      final data = createTestData(
        dataAlojamento: DateTime.now().subtract(const Duration(days: 30)),
      );
      expect(data.diasDeVida, 30);
    });

    test('calcula avesVivas corretamente', () {
      final data = createTestData(
        quantidadeOriginal: 25000,
        mortalidadeAcumulada: 200,
      );
      expect(data.avesVivas, 24800);
    });

    test('calcula desvioPeso quando ha benchmark', () {
      final data = createTestData(
        ultimoPesoMedio: 1700,
        pesoBenchmark: 1600,
      );
      // desvio = ((1700 - 1600) / 1600) * 100 = 6.25%
      expect(data.desvioPeso, closeTo(6.25, 0.01));
    });

    test('retorna null para desvioPeso sem benchmark', () {
      final data = createTestData(
        ultimoPesoMedio: 1700,
        pesoBenchmark: null,
      );
      expect(data.desvioPeso, isNull);
    });
  });
}
