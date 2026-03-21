import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/form_field_widget.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  group('FormFieldWidget', () {
    testWidgets('renderiza label', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(label: 'Nome'),
      ));

      expect(find.text('Nome'), findsOneWidget);
    });

    testWidgets('renderiza label com asterisco quando required', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(label: 'Email', required: true),
      ));

      expect(find.text('Email *'), findsOneWidget);
    });

    testWidgets('aceita entrada de texto', (tester) async {
      String? changedValue;
      await tester.pumpWidget(buildTestWidget(
        FormFieldWidget(
          label: 'Nome',
          onChanged: (v) => changedValue = v,
        ),
      ));

      await tester.enterText(find.byType(TextFormField), 'Joao');
      expect(changedValue, 'Joao');
    });

    testWidgets('exibe erro de validacao via error property', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(
          label: 'Email',
          error: 'Email invalido',
        ),
      ));

      expect(find.text('Email invalido'), findsOneWidget);
    });

    testWidgets('exibe helperText', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(
          label: 'Peso',
          helperText: 'Informe o peso em gramas',
        ),
      ));

      expect(find.text('Informe o peso em gramas'), findsOneWidget);
    });

    testWidgets('renderiza icone esquerdo', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(
          label: 'Email',
          leftIcon: Icons.email,
        ),
      ));

      expect(find.byIcon(Icons.email), findsOneWidget);
    });

    testWidgets('renderiza icone direito com callback', (tester) async {
      bool iconPressed = false;
      await tester.pumpWidget(buildTestWidget(
        FormFieldWidget(
          label: 'Senha',
          rightIcon: Icons.visibility,
          onRightIconPress: () => iconPressed = true,
        ),
      ));

      expect(find.byIcon(Icons.visibility), findsOneWidget);
      await tester.tap(find.byIcon(Icons.visibility));
      expect(iconPressed, true);
    });

    testWidgets('renderiza sufixo textual', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(
          label: 'Peso',
          suffix: 'kg',
        ),
      ));

      expect(find.text('kg'), findsOneWidget);
    });

    testWidgets('exibe placeholder', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(
          label: 'Nome',
          placeholder: 'Digite seu nome',
        ),
      ));

      expect(find.text('Digite seu nome'), findsOneWidget);
    });

    testWidgets('campo desabilitado nao aceita input', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(
          label: 'Nome',
          disabled: true,
          value: 'Fixo',
        ),
      ));

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.enabled, false);
    });

    testWidgets('validator funciona com Form', (tester) async {
      final formKey = GlobalKey<FormState>();
      await tester.pumpWidget(buildTestWidget(
        Form(
          key: formKey,
          child: FormFieldWidget(
            label: 'Nome',
            validator: (value) {
              if (value == null || value.isEmpty) return 'Campo obrigatorio';
              return null;
            },
          ),
        ),
      ));

      formKey.currentState!.validate();
      await tester.pump();

      expect(find.text('Campo obrigatorio'), findsOneWidget);
    });

    testWidgets('possui Semantics widget com label correto', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const FormFieldWidget(label: 'Usuario'),
      ));

      final semantics = tester.widgetList<Semantics>(find.byType(Semantics));
      final fieldSemantics = semantics.where(
        (s) => s.properties.label == 'Usuario',
      );
      expect(fieldSemantics, isNotEmpty);
    });
  });
}
