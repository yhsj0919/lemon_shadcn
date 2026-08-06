import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('utility display aliases render inside a Material host', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Column(
          children: [
            AppSkeleton(enabled: false, child: Text('Loaded')),
            AppDotIndicator(index: 1, length: 3),
            SizedBox(
              width: 180,
              child: AppOverflowMarquee(child: Text('Short text')),
            ),
            AppSelectableText('Copy me'),
          ],
        ),
      ),
    );

    expect(find.text('Loaded'), findsOneWidget);
    expect(find.byType(AppDotIndicator), findsOneWidget);
    expect(find.byType(AppOverflowMarquee), findsOneWidget);
    expect(find.byType(AppSelectableText), findsOneWidget);
  });

  testWidgets('hover marquee stays still until pointer enters and resets', (
    tester,
  ) async {
    const marqueeKey = Key('hover-marquee');
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: SizedBox(
            width: 120,
            child: AppOverflowMarquee.hover(
              key: marqueeKey,
              child: Text('A long line that overflows its available width'),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(shad.OverflowMarquee), findsNothing);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(marqueeKey)));
    await tester.pump();

    expect(find.byType(shad.OverflowMarquee), findsOneWidget);

    await mouse.moveTo(Offset.zero);
    await tester.pump();

    expect(find.byType(shad.OverflowMarquee), findsNothing);
  });
}
