import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  test('joins duplicate execution and exposes result state', () async {
    final completer = Completer<int>();
    var calls = 0;
    final action = AppAsyncAction<int>(
      operation: () {
        calls++;
        return completer.future;
      },
    );

    final first = action.execute();
    final second = action.execute();
    expect(identical(first, second), isTrue);
    expect(action.isRunning, isTrue);
    expect(action.status, AppAsyncStatus.loading);
    expect(calls, 1);

    completer.complete(42);
    expect(await first, 42);
    expect(action.value, 42);
    expect(action.status, AppAsyncStatus.success);
    expect(action.isRunning, isFalse);
    action.dispose();
  });

  testWidgets('multiple buttons share one action and disable immediately', (
    tester,
  ) async {
    final completer = Completer<void>();
    var calls = 0;
    final action = AppAsyncAction<void>(
      operation: () {
        calls++;
        return completer.future;
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Row(
          children: [
            AppButton.primary(
              action: action,
              loadingLabel: 'Saving',
              child: const Text('Save'),
            ),
            AppButton.outline(action: action, child: const Text('Save copy')),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Save'));
    await tester.pump();
    expect(calls, 1);
    expect(find.byType(AppCircularProgressIndicator), findsNWidgets(2));
    expect(
      tester
          .widgetList<shad.Button>(find.byType(shad.Button))
          .every((button) => button.onPressed == null),
      isTrue,
    );

    completer.complete();
    await tester.pump();
    expect(find.text('Save'), findsOneWidget);
    expect(find.text('Save copy'), findsOneWidget);
    action.dispose();
  });

  testWidgets('automatic async button blocks repeat during loading delay', (
    tester,
  ) async {
    final completer = Completer<void>();
    var calls = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            motion: const AppMotionTheme(loadingDelay: Duration(seconds: 1)),
          ),
        ),
        home: AppButton.primary(
          onPressed: () {
            calls++;
            return completer.future;
          },
          child: const Text('Submit'),
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(calls, 1);
    expect(
      tester.widget<shad.Button>(find.byType(shad.Button)).onPressed,
      isNull,
    );
    completer.complete();
    await tester.pump();
  });

  testWidgets('button config forwards advanced behavior with explicit size', (
    tester,
  ) async {
    final focusNode = FocusNode();
    addTearDown(focusNode.dispose);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppButton.secondary(
            onPressed: () {},
            config: AppButtonConfig(
              height: 44,
              alignment: Alignment.centerLeft,
              size: AppButtonSize.small,
              density: shad.ButtonDensity.dense,
              shape: shad.ButtonShape.circle,
              focusNode: focusNode,
              enableFeedback: false,
            ),
            child: const Text('Configured'),
          ),
        ),
      ),
    );

    final button = tester.widget<shad.Button>(find.byType(shad.Button));
    expect(button.alignment, Alignment.centerLeft);
    expect(button.focusNode, same(focusNode));
    expect(button.enableFeedback, isFalse);
    expect(tester.getSize(find.byType(AppControlBox)).height, 44);
  });

  testWidgets('icon button shortcuts keep square dimensions', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controls: const AppControlMetrics(height: 40, buttonHeight: 40),
          ),
        ),
        home: Row(
          children: [
            AppIconButton(
              tooltip: 'Square action',
              onPressed: () {},
              icon: const SizedBox.square(dimension: 16),
            ),
            AppIconButton.circle(
              tooltip: 'Circular action',
              onPressed: () {},
              icon: const SizedBox.square(dimension: 16),
            ),
          ],
        ),
      ),
    );

    final boxes = find.byType(AppControlBox);
    expect(boxes, findsNWidgets(2));
    for (final element in boxes.evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)), const Size(40, 40));
    }
  });
}
