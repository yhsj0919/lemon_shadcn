import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('custom overlay fills child and follows pointer hover', (
    tester,
  ) async {
    const childKey = Key('child');
    const overlayKey = Key('overlay');
    final changes = <bool>[];

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 240,
            height: 120,
            child: AppHoverOverlay(
              onHoverChanged: changes.add,
              overlay: const ColoredBox(key: overlayKey, color: Colors.red),
              child: const ColoredBox(key: childKey, color: Colors.white),
            ),
          ),
        ),
      ),
    );

    expect(find.byKey(overlayKey).hitTestable(), findsNothing);
    expect(tester.getSize(find.byKey(childKey)), const Size(240, 120));
    expect(tester.getSize(find.byKey(overlayKey)), const Size(240, 120));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(childKey)));
    await tester.pumpAndSettle();

    expect(find.byKey(overlayKey).hitTestable(), findsOneWidget);
    expect(changes, [true]);

    await mouse.moveTo(Offset.zero);
    await tester.pumpAndSettle();

    expect(find.byKey(overlayKey).hitTestable(), findsNothing);
    expect(changes, [true, false]);
  });

  testWidgets('visible overlay handles taps without hitting child', (
    tester,
  ) async {
    var childTaps = 0;
    var overlayTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: SizedBox(
            width: 240,
            height: 120,
            child: AppHoverOverlay(
              overlay: ColoredBox(
                color: Colors.red,
                child: Center(
                  child: TextButton(
                    key: const Key('action'),
                    onPressed: () => overlayTaps++,
                    child: const Text('Action'),
                  ),
                ),
              ),
              child: GestureDetector(
                onTap: () => childTaps++,
                child: const ColoredBox(color: Colors.white),
              ),
            ),
          ),
        ),
      ),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(const Key('action'))));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('action')));

    expect(overlayTaps, 1);
    expect(childTaps, 0);
  });
}
