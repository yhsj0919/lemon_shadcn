import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('badge facade maps semantic variants to upstream widgets', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
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

    expect(find.byType(PrimaryBadge), findsOneWidget);
    expect(find.byType(SecondaryBadge), findsOneWidget);
    expect(find.byType(OutlineBadge), findsOneWidget);
    expect(find.byType(DestructiveBadge), findsOneWidget);
  });
}
