import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/date_picker_field.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('DatePickerField', () {
    testWidgets('renderiza label', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const DatePickerField(label: 'Data de Alojamento'),
      ));

      expect(find.text('Data de Alojamento'), findsOneWidget);
    });

    testWidgets('renderiza label com asterisco quando required',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const DatePickerField(label: 'Data', required: true),
      ));

      expect(find.text('Data *'), findsOneWidget);
    });

    testWidgets('renderiza data selecionada formatada', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DatePickerField(
          label: 'Data',
          value: DateTime(2025, 6, 15),
        ),
      ));

      expect(find.text('15/06/2025'), findsOneWidget);
    });

    testWidgets('exibe placeholder quando nenhuma data selecionada',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const DatePickerField(label: 'Data'),
      ));

      expect(find.text('DD/MM/AAAA'), findsOneWidget);
    });

    testWidgets('renderiza icone de calendario', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const DatePickerField(label: 'Data'),
      ));

      expect(find.byIcon(Icons.calendar_today_outlined), findsOneWidget);
    });

    testWidgets('exibe mensagem de erro', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const DatePickerField(
          label: 'Data',
          error: 'Selecione uma data',
        ),
      ));

      expect(find.text('Selecione uma data'), findsOneWidget);
    });

    testWidgets('exibe helperText', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const DatePickerField(
          label: 'Data',
          helperText: 'Data de inicio do lote',
        ),
      ));

      expect(find.text('Data de inicio do lote'), findsOneWidget);
    });

    testWidgets('possui Semantics widget com label correto com data',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        DatePickerField(
          label: 'Alojamento',
          value: DateTime(2025, 1, 10),
        ),
      ));

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final fieldSemantics = semantics.where(
        (s) => s.properties.label == 'Alojamento, campo de data, 10/01/2025',
      );
      expect(fieldSemantics, isNotEmpty);
    });

    testWidgets('possui Semantics widget com label correto sem data',
        (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const DatePickerField(label: 'Alojamento'),
      ));

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final fieldSemantics = semantics.where(
        (s) => s.properties.label == 'Alojamento, campo de data',
      );
      expect(fieldSemantics, isNotEmpty);
    });
  });
}
