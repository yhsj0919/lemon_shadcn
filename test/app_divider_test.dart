import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('horizontal divider preserves the existing API', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: SizedBox(
            width: 240,
            child: AppDivider.horizontal(height: 8, thickness: 2),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppDivider)), const Size(240, 8));
  });

  testWidgets('vertical divider fills the available height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: SizedBox(
            width: 120,
            height: 100,
            child: Row(
              children: [
                Expanded(child: SizedBox()),
                AppDivider.vertical(width: 8, thickness: 2),
                Expanded(child: SizedBox()),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppDivider)), const Size(8, 100));
  });

  testWidgets('text divider places a label between two lines', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: SizedBox(width: 240, child: AppDivider.text('OR')),
        ),
      ),
    );

    expect(find.text('OR'), findsOneWidget);
    expect(tester.widget<Text>(find.text('OR')).style?.fontSize, 12);
    expect(
      tester.getCenter(find.text('OR')).dx,
      closeTo(tester.getCenter(find.byType(AppDivider)).dx, 1),
    );
  });
}
