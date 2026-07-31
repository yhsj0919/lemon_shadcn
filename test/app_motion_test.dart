import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('lift keeps layout size and derives shadow from border color', (
    tester,
  ) async {
    const motionKey = ValueKey('motion');

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: AppVisualStyle(
            colors: AppVisualColors(
              background: Color(0xfffef2f2),
              border: Color(0xffef4444),
            ),
            child: AppMotion.lift(
              key: motionKey,
              child: SizedBox(width: 160, height: 80),
            ),
          ),
        ),
      ),
    );

    final sizeBefore = tester.getSize(find.byKey(motionKey));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(motionKey)));
    await tester.pumpAndSettle();

    final sizeAfter = tester.getSize(find.byKey(motionKey));
    final container = tester.widget<AnimatedContainer>(
      find.descendant(
        of: find.byKey(motionKey),
        matching: find.byType(AnimatedContainer),
      ),
    );
    final decoration = container.decoration! as BoxDecoration;

    expect(sizeAfter, sizeBefore);
    expect(decoration.boxShadow, hasLength(2));
    expect(decoration.boxShadow!.last.color, isNot(Colors.black));
    expect(decoration.boxShadow!.last.color, isNot(Colors.white));
  });

  testWidgets('depth combines upward Y and forward Z translation', (
    tester,
  ) async {
    const motionKey = ValueKey('depth-motion');
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: AppMotion.depth(
            key: motionKey,
            child: SizedBox(width: 200, height: 100),
          ),
        ),
      ),
    );

    final sizeBefore = tester.getSize(find.byKey(motionKey));
    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: Offset.zero);
    final bounds = tester.getRect(find.byKey(motionKey));
    final corner = Offset(bounds.right - 8, bounds.bottom - 8);
    await mouse.moveTo(corner);
    await tester.pumpAndSettle();

    var transform = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byKey(motionKey),
            matching: find.byType(Transform),
          ),
        )
        .last
        .transform;

    expect(tester.getSize(find.byKey(motionKey)), sizeBefore);
    expect(transform.entry(3, 2), isNonZero);
    expect(transform.entry(0, 2), isNonZero);
    expect(transform.entry(2, 1), isNonZero);
    expect(transform.entry(1, 3), lessThan(0));
    expect(transform.entry(2, 3), isNonZero);

    final liftedY = transform.entry(1, 3).abs();
    final liftedZ = transform.entry(2, 3).abs();
    await mouse.down(corner);
    await tester.pumpAndSettle();
    transform = tester
        .widgetList<Transform>(
          find.descendant(
            of: find.byKey(motionKey),
            matching: find.byType(Transform),
          ),
        )
        .last
        .transform;

    expect(transform.entry(1, 3).abs(), lessThan(liftedY));
    expect(transform.entry(1, 3).abs(), greaterThan(liftedY * 0.5));
    expect(transform.entry(2, 3).abs(), lessThan(liftedZ));
    expect(transform.entry(2, 3).abs(), greaterThan(liftedZ * 0.5));
  });
}
