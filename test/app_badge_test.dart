import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('badge facade maps semantic variants to upstream widgets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Wrap(
          children: [
            AppBadge.primary(child: const Text('Primary')),
            AppBadge.secondary(child: const Text('Secondary')),
            AppBadge.outline(child: const Text('Outline')),
            AppBadge.destructive(child: const Text('Destructive')),
          ],
        ),
      ),
    );

    expect(find.byType(shad.PrimaryBadge), findsOneWidget);
    expect(find.byType(shad.SecondaryBadge), findsOneWidget);
    expect(find.byType(shad.OutlineBadge), findsOneWidget);
    expect(find.byType(shad.DestructiveBadge), findsOneWidget);

    for (final label in ['Primary', 'Secondary', 'Outline', 'Destructive']) {
      final context = tester.element(find.text(label));
      expect(DefaultTextStyle.of(context).style.fontSize, 14);
    }
  });
}
