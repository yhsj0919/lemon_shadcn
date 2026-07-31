import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('works inside MaterialApp without ShadcnApp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) =>
              AppButton.primary(onPressed: () {}, child: const Text('Save')),
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    expect(
      AppTheme.of(tester.element(find.text('Save'))),
      isA<AppThemeConfig>(),
    );
  });

  test('AppButtonConfig.resolve honors interactive and theme flag', () {
    expect(AppButtonConfig.interactive.hoverLift, isTrue);
    expect(
      AppButtonConfig.interactive.pressEffect,
      AppButtonPressEffect.returnToBase,
    );
  });

  testWidgets('AppButton defaults to interactive motion', (tester) async {
    late AppButtonConfig resolved;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) {
            resolved = AppButtonConfig.resolve(context, null);
            return AppButton.primary(
              onPressed: () {},
              child: const Text('Lift'),
            );
          },
        ),
      ),
    );

    expect(resolved.hoverLift, isTrue);
    expect(resolved.pressEffect, AppButtonPressEffect.returnToBase);
    expect(find.text('Lift'), findsOneWidget);
  });

  testWidgets('explicit config keeps chrome buttons still', (tester) async {
    late AppButtonConfig fromTheme;
    late AppButtonConfig fromChrome;

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) {
            fromTheme = AppButtonConfig.resolve(context, null);
            fromChrome = AppButtonConfig.resolve(
              context,
              const AppButtonConfig(alignment: Alignment.centerLeft),
            );
            return Column(
              children: [
                AppButton.primary(onPressed: () {}, child: const Text('CTA')),
                AppButton.ghost(
                  onPressed: () {},
                  config: const AppButtonConfig(alignment: Alignment.centerLeft),
                  child: const Text('Nav'),
                ),
              ],
            );
          },
        ),
      ),
    );

    expect(fromTheme.hoverLift, isTrue);
    expect(fromChrome.hoverLift, isFalse);
  });

  testWidgets('AppButtonMotionScope.disable keeps null-config buttons plain', (
    tester,
  ) async {
    late AppButtonConfig inside;
    late AppButtonConfig outside;

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) {
            outside = AppButtonConfig.resolve(context, null);
            return AppButtonMotionScope.disable(
              child: Builder(
                builder: (context) {
                  inside = AppButtonConfig.resolve(context, null);
                  return AppButton.primary(
                    onPressed: () {},
                    child: const Text('Menu'),
                  );
                },
              ),
            );
          },
        ),
      ),
    );

    expect(outside.hoverLift, isTrue);
    expect(inside.hoverLift, isFalse);
  });

  testWidgets('disables repeated presses while an async action runs', (
    tester,
  ) async {
    final completer = Completer<void>();
    var presses = 0;

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            motion: const AppMotionTheme(
              loadingDelay: Duration.zero,
              minimumLoadingDuration: Duration.zero,
            ),
          ),
        ),
        home: Builder(
          builder: (context) => AppButton.primary(
            onPressed: () {
              presses++;
              return completer.future;
            },
            child: const Text('Save'),
          ),
        ),
      ),
    );

    final widthBefore = tester.getSize(find.byType(shad.PrimaryButton)).width;
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 1));
    final widthDuring = tester.getSize(find.byType(shad.PrimaryButton)).width;
    await tester.tap(find.byType(CircularProgressIndicator));
    await tester.pump();

    expect(presses, 1);
    expect(widthDuring, widthBefore);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pump();

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('renders link and text variants', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) => Row(
            children: [
              AppButton.link(onPressed: () {}, child: const Text('Link')),
              AppButton.text(onPressed: () {}, child: const Text('Text')),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Link'), findsOneWidget);
    expect(find.text('Text'), findsOneWidget);
  });

  testWidgets('default AppButton hover lifts and press scales', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Center(
          child: AppButton.primary(
            onPressed: () {},
            child: const Text('Lift'),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    final center = tester.getCenter(find.text('Lift'));
    await gesture.moveTo(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.widgetList<Transform>(find.byType(Transform)).any(
        (t) => t.transform.getTranslation().y < -1.0,
      ),
      isTrue,
    );

    await gesture.down(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      tester.widgetList<Transform>(find.byType(Transform)).any((t) {
        final sx = t.transform.storage[0];
        return sx > 0.9 && sx < 0.99;
      }),
      isTrue,
    );

    await gesture.up();
    await tester.pump();
  });

  testWidgets('plain config skips motion lift', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Center(
          child: AppButton.primary(
            onPressed: () {},
            config: AppButtonConfig.plain,
            child: const Text('Still'),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.text('Still')));
    await tester.pump(const Duration(milliseconds: 300));

    for (final t in tester.widgetList<Transform>(find.byType(Transform))) {
      expect(t.transform.getTranslation().y, 0);
    }
  });

  testWidgets('AppIconButton defaults to interactive motion', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: AppIconButton(
            tooltip: 'Add',
            variant: AppButtonVariant.primary,
            onPressed: _noop,
            icon: Icon(Icons.add),
          ),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byIcon(Icons.add)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      tester.widgetList<Transform>(find.byType(Transform)).any(
        (t) => t.transform.getTranslation().y < -1.0,
      ),
      isTrue,
    );
  });
}

void _noop() {}
