import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:egranja_flutter/core/widgets/loading_skeleton.dart';

Widget buildTestWidget(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('SkeletonIndicator', () {
    testWidgets('renderiza sem erro', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const SkeletonIndicator(),
      ));

      expect(find.byType(SkeletonIndicator), findsOneWidget);
    });

    testWidgets('contem Card', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const SkeletonIndicator(),
      ));

      expect(find.byType(Card), findsOneWidget);
    });

    testWidgets('contem ShimmerEffect (animacao)', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const SkeletonIndicator(),
      ));

      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
  });

  group('SkeletonCard', () {
    testWidgets('renderiza sem erro', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const SkeletonCard(),
      ));

      expect(find.byType(SkeletonCard), findsOneWidget);
    });

    testWidgets('contem ShimmerEffect', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const SkeletonCard(),
      ));

      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
  });

  group('SkeletonList', () {
    testWidgets('renderiza quantidade padrao de 3 cards', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const SingleChildScrollView(
          child: SkeletonList(),
        ),
      ));

      expect(find.byType(SkeletonCard), findsNWidgets(3));
    });

    testWidgets('renderiza quantidade customizada de cards', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const SingleChildScrollView(
          child: SkeletonList(itemCount: 5),
        ),
      ));

      expect(find.byType(SkeletonCard), findsNWidgets(5));
    });
  });

  group('ShimmerEffect', () {
    testWidgets('renderiza widget filho', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerEffect(
          child: SizedBox(width: 100, height: 20),
        ),
      ));

      expect(find.byType(ShimmerEffect), findsOneWidget);
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('possui animacao em andamento', (tester) async {
      await tester.pumpWidget(buildTestWidget(
        const ShimmerEffect(
          child: SizedBox(width: 100, height: 20),
        ),
      ));

      // Avanca um frame para verificar que a animacao nao causa erro
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(ShimmerEffect), findsOneWidget);
    });
  });
}
