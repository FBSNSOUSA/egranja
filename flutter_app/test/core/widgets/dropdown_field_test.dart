import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/dropdown_field.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  final testOptions = [
    const DropdownOption(value: '1', label: 'Galpao A'),
    const DropdownOption(value: '2', label: 'Galpao B'),
    const DropdownOption(value: '3', label: 'Galpao C', subtitle: 'Principal'),
  ];

  group('DropdownField', () {
    testWidgets('renderiza label', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
        ),
      ));

      expect(find.text('Galpao'), findsOneWidget);
    });

    testWidgets('renderiza label com asterisco quando required',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Tipo',
          options: testOptions,
          required: true,
        ),
      ));

      expect(find.text('Tipo *'), findsOneWidget);
    });

    testWidgets('exibe valor selecionado', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
          value: '2',
        ),
      ));

      expect(find.text('Galpao B'), findsOneWidget);
    });

    testWidgets('exibe placeholder quando nenhum valor selecionado',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
          placeholder: 'Escolha um galpao',
        ),
      ));

      expect(find.text('Escolha um galpao'), findsOneWidget);
    });

    testWidgets('exibe placeholder padrao "Selecione..."', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
        ),
      ));

      expect(find.text('Selecione...'), findsOneWidget);
    });

    testWidgets('renderiza icone de seta', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
        ),
      ));

      expect(find.byIcon(Icons.keyboard_arrow_down), findsOneWidget);
    });

    testWidgets('exibe mensagem de erro', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
          error: 'Campo obrigatorio',
        ),
      ));

      expect(find.text('Campo obrigatorio'), findsOneWidget);
    });

    testWidgets('possui Semantics widget com label correto', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
        ),
      ));

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final fieldSemantics = semantics.where(
        (s) => s.properties.label == 'Galpao, campo de selecao',
      );
      expect(fieldSemantics, isNotEmpty);
    });

    testWidgets('abre bottom sheet ao tocar', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
        ),
      ));

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Verifica que opcoes aparecem no bottom sheet
      expect(find.text('Galpao A'), findsOneWidget);
      expect(find.text('Galpao B'), findsOneWidget);
      expect(find.text('Galpao C'), findsOneWidget);
    });

    testWidgets('selecao no bottom sheet chama callback', (tester) async {
      DropdownOption? selectedOption;
      await tester.pumpWidget(buildTestWidget(
        DropdownField(
          label: 'Galpao',
          options: testOptions,
          onSelect: (option) => selectedOption = option,
        ),
      ));

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pumpAndSettle();

      // Selecionar opcao
      await tester.tap(find.text('Galpao B'));
      await tester.pumpAndSettle();

      expect(selectedOption?.value, '2');
      expect(selectedOption?.label, 'Galpao B');
    });
  });
}
