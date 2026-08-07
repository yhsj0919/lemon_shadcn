import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('count badge formats overflow and defaults to top right', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Center(
          child: AppCornerBadge.count(
            count: 120,
            child: SizedBox.square(dimension: 48),
          ),
        ),
      ),
    );

    expect(find.text('99+'), findsOneWidget);
    final align = tester.widget<Align>(
      find.descendant(
        of: find.byType(AppCornerBadge),
        matching: find.byType(Align),
      ),
    );
    expect(align.alignment, Alignment.topRight);
  });

  testWidgets('all four badge positions resolve to their matching corners', (
    tester,
  ) async {
    for (final position in AppCornerBadgePosition.values) {
      await tester.pumpWidget(
        MaterialApp(
          builder: AppShadcnScope.builder(),
          home: Center(
            child: AppCornerBadge.dot(
              position: position,
              child: const SizedBox.square(dimension: 48),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets('overlap is the fraction of the badge covering the child', (
    tester,
  ) async {
    Future<Offset> translationFor(double overlap) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: AppShadcnScope.builder(),
          home: Center(
            child: AppCornerBadge.dot(
              overlap: overlap,
              child: const SizedBox.square(dimension: 48),
            ),
          ),
        ),
      );
      return tester
          .widget<FractionalTranslation>(
            find.descendant(
              of: find.byType(AppCornerBadge),
              matching: find.byType(FractionalTranslation),
            ),
          )
          .translation;
    }

    expect(await translationFor(0), const Offset(1, -1));
    expect(await translationFor(0.5), const Offset(0.5, -0.5));
    expect(await translationFor(1), Offset.zero);
  });

  testWidgets('count badge supports square and custom corner radii', (
    tester,
  ) async {
    Future<BoxDecoration> decorationFor({
      AppBadgeShape shape = AppBadgeShape.pill,
      BorderRadiusGeometry? borderRadius,
    }) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: AppShadcnScope.builder(),
          home: Center(
            child: AppCornerBadge.count(
              count: 7,
              shape: shape,
              borderRadius: borderRadius,
              child: const SizedBox.square(dimension: 48),
            ),
          ),
        ),
      );
      return tester
              .widget<DecoratedBox>(
                find.descendant(
                  of: find.byType(AppCornerBadge),
                  matching: find.byType(DecoratedBox),
                ),
              )
              .decoration
          as BoxDecoration;
    }

    expect(
      (await decorationFor(shape: AppBadgeShape.square)).borderRadius,
      BorderRadius.circular(6),
    );
    expect(
      (await decorationFor(
        shape: AppBadgeShape.square,
        borderRadius: BorderRadius.circular(2),
      )).borderRadius,
      BorderRadius.circular(2),
    );
  });
}
