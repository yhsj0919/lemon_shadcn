import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('base card is flat and unpadded by default', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppCard(child: Text('Nested content')),
      ),
    );

    final card = tester.widget<shad.Card>(find.byType(shad.Card));
    expect(card.padding, EdgeInsets.zero);
    expect(card.boxShadow, isEmpty);
  });

  testWidgets('elevated card keeps theme padding and opts into shadow', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppCard.elevated(child: Text('Elevated content')),
      ),
    );

    final facade = tester.widget<AppCard>(find.byType(AppCard));
    final card = tester.widget<shad.Card>(find.byType(shad.Card));
    expect(facade.shadow, isTrue);
    expect(facade.shadowLevel, AppShadowLevel.card);
    expect(card.padding, isNull);
    expect(card.boxShadow, isNotEmpty);
  });
}
