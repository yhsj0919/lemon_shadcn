import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('manual anchored overlay wraps arbitrary anchor and content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppAnchoredOverlay(
            triggers: const <AppAnchoredOverlayTrigger>{
              AppAnchoredOverlayTrigger.manual,
            },
            placement: AppAnchoredOverlayPlacement.bottom,
            width: AppAnchoredOverlayWidth.matchAnchor,
            anchorBuilder: (context, actions) => SizedBox(
              width: 180,
              child: ElevatedButton(
                onPressed: actions.open,
                child: const Text('Open'),
              ),
            ),
            overlayBuilder: (context, actions) => GestureDetector(
              key: const ValueKey<String>('overlay-content'),
              onTap: actions.close,
              child: const Text('Close'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('overlay-content')),
      findsOneWidget,
    );
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('overlay-content')))
          .width,
      180,
    );

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('overlay-content')), findsNothing);
  });

  testWidgets('click trigger toggles overlay', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppAnchoredOverlay(
          anchorBuilder: (context, actions) => const Text('Anchor'),
          overlayBuilder: (context, actions) => const Text('Popup'),
        ),
      ),
    );

    await tester.tap(find.text('Anchor'));
    await tester.pumpAndSettle();
    expect(find.text('Popup'), findsOneWidget);
  });

  testWidgets('overlay stays inside viewport near an edge', (tester) async {
    tester.view.physicalSize = const Size(400, 300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topRight,
          child: AppAnchoredOverlay(
            placement: AppAnchoredOverlayPlacement.bottom,
            width: AppAnchoredOverlayWidth.fixed,
            fixedWidth: 300,
            viewportMargin: 12,
            decorateSurface: false,
            anchorBuilder: (context, actions) => const SizedBox(
              width: 40,
              height: 40,
              child: Text('Edge anchor'),
            ),
            overlayBuilder: (context, actions) => const SizedBox(
              key: ValueKey<String>('edge-overlay'),
              height: 80,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Edge anchor'));
    await tester.pumpAndSettle();

    final rect = tester.getRect(
      find.byKey(const ValueKey<String>('edge-overlay')),
    );
    expect(rect.left, greaterThanOrEqualTo(12));
    expect(rect.right, lessThanOrEqualTo(388));
  });
}
