import 'dart:async';
import 'dart:math' as math;

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
    expect(AppButtonConfig.interactive.hoverLift, isFalse);
    expect(AppButtonConfig.interactive.pressEffect, AppButtonPressEffect.sink);
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

    expect(resolved.hoverLift, isFalse);
    expect(resolved.pressEffect, AppButtonPressEffect.sink);
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
                  config: const AppButtonConfig(
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text('Nav'),
                ),
              ],
            );
          },
        ),
      ),
    );

    expect(fromTheme.hoverLift, isFalse);
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

    expect(outside.hoverLift, isFalse);
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

    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 1));
    await tester.tap(find.byType(CircularProgressIndicator));
    await tester.pump();

    expect(presses, 1);
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

  testWidgets('AppToggle switches between primary and outline', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) => Row(
            children: [
              AppToggle(
                value: true,
                onChanged: (_) {},
                child: const Text('Selected'),
              ),
              AppToggle(
                value: false,
                onChanged: (_) {},
                child: const Text('Unselected'),
              ),
            ],
          ),
        ),
      ),
    );

    shad.Button buttonFor(String label) => tester.widget<shad.Button>(
      find.ancestor(of: find.text(label), matching: find.byType(shad.Button)),
    );
    BuildContext contextFor(String label) => tester.element(
      find.ancestor(of: find.text(label), matching: find.byType(shad.Button)),
    );

    final selectedDecoration = buttonFor(
      'Selected',
    ).style.decoration(contextFor('Selected'), const {});
    final unselectedDecoration = buttonFor(
      'Unselected',
    ).style.decoration(contextFor('Unselected'), const {});

    final selectedBox = selectedDecoration as BoxDecoration;
    final unselectedBox = unselectedDecoration as BoxDecoration;
    expect(selectedBox.color, isNot(unselectedBox.color));
    expect(unselectedBox.border, isNotNull);
  });

  testWidgets('AppToggleGroup supports plain spaced layout', (tester) async {
    const selectedColor = Color(0xff7c3aed);
    const unselectedColor = Color(0xff475569);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppToggleGroup<String>.single(
            value: 'all',
            onChanged: (_) {},
            mode: AppWidgetGroupMode.plain,
            spacing: 10,
            selectedColor: selectedColor,
            unselectedColor: unselectedColor,
            items: const [
              AppToggleGroupItem(value: 'all', child: Text('All')),
              AppToggleGroupItem(value: 'year', child: Text('Year')),
            ],
          ),
        ),
      ),
    );

    final first = tester.getRect(find.text('All'));
    final second = tester.getRect(find.text('Year'));
    expect(second.left - first.right, greaterThanOrEqualTo(10));

    final selectedButton = tester.widget<shad.Button>(
      find.ancestor(of: find.text('All'), matching: find.byType(shad.Button)),
    );
    final selectedContext = tester.element(
      find.ancestor(of: find.text('All'), matching: find.byType(shad.Button)),
    );
    final selectedDecoration = selectedButton.style.decoration(
      selectedContext,
      const {},
    );
    expect((selectedDecoration as BoxDecoration).color, selectedColor);
    expect(
      selectedButton.style.textStyle(selectedContext, const {}).color,
      Colors.white,
    );

    final unselectedButton = tester.widget<shad.Button>(
      find.ancestor(of: find.text('Year'), matching: find.byType(shad.Button)),
    );
    final unselectedContext = tester.element(
      find.ancestor(of: find.text('Year'), matching: find.byType(shad.Button)),
    );
    final unselectedDecoration = unselectedButton.style.decoration(
      unselectedContext,
      const {},
    );
    expect(
      (unselectedDecoration as BoxDecoration).border,
      Border.all(color: unselectedColor),
    );
  });

  testWidgets('default AppButton stays on hover and sinks on press', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Center(
          child: AppButton.primary(onPressed: () {}, child: const Text('Sink')),
        ),
      ),
    );

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();

    final center = tester.getCenter(find.text('Sink'));
    await gesture.moveTo(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    for (final transform in tester.widgetList<Transform>(
      find.byType(Transform),
    )) {
      expect(transform.transform.getTranslation().y, 0);
    }

    await gesture.down(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(
      tester
          .widgetList<Transform>(find.byType(Transform))
          .any((transform) => transform.transform.getTranslation().y > 0.5),
      isTrue,
    );

    await gesture.up();
    await tester.pump();
  });

  testWidgets('shadow button removes its shadow while pressed', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Center(
          child: AppButton.primary(
            shadow: true,
            onPressed: () {},
            child: const Text('Shadow'),
          ),
        ),
      ),
    );

    Iterable<BoxDecoration> decorations() => tester
        .widgetList<DecoratedBox>(
          find.ancestor(
            of: find.text('Shadow'),
            matching: find.byType(DecoratedBox),
          ),
        )
        .map((widget) => widget.decoration)
        .whereType<BoxDecoration>();

    double defaultButtonShadowAlpha() => decorations()
        .expand((decoration) => decoration.boxShadow ?? const <BoxShadow>[])
        .where(
          (shadow) =>
              shadow.blurRadius == 10 && shadow.offset == const Offset(0, 3),
        )
        .fold(0.0, (value, shadow) => math.max(value, shadow.color.a));

    final restingAlpha = defaultButtonShadowAlpha();
    expect(restingAlpha, greaterThan(0));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    final center = tester.getCenter(find.text('Shadow'));
    await gesture.moveTo(center);
    await tester.pumpAndSettle();
    await gesture.down(center);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(defaultButtonShadowAlpha(), lessThan(restingAlpha));

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

    for (final transform in tester.widgetList<Transform>(
      find.byType(Transform),
    )) {
      expect(transform.transform.getTranslation().y, 0);
    }
  });

  testWidgets('AppIconButton supports custom color and icon size', (
    tester,
  ) async {
    const customColor = Color(0xff7c3aed);
    const customBackground = Color(0xffede9fe);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Center(
          child: AppIconButton(
            tooltip: 'Custom',
            onPressed: _noop,
            foregroundColor: customColor,
            backgroundColor: customBackground,
            iconSize: 28,
            icon: Icon(Icons.palette),
          ),
        ),
      ),
    );

    final iconContext = tester.element(find.byIcon(Icons.palette));
    expect(IconTheme.of(iconContext).color, customColor);
    expect(IconTheme.of(iconContext).size, 28);
    final button = tester.widget<shad.Button>(find.byType(shad.Button));
    final decoration = button.style.decoration(
      tester.element(find.byType(shad.Button)),
      const {},
    );
    expect((decoration as BoxDecoration).color, customBackground);
  });

  testWidgets('AppIconButton uses component theme defaults', (tester) async {
    const themeColor = Color(0xff0f766e);
    const themeBackground = Color(0xffccfbf1);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const ComponentTheme<AppIconButtonTheme>(
          data: AppIconButtonTheme(
            foregroundColor: themeColor,
            backgroundColor: themeBackground,
            iconSize: 24,
          ),
          child: Center(
            child: AppIconButton(
              tooltip: 'Themed',
              onPressed: _noop,
              icon: Icon(Icons.search),
            ),
          ),
        ),
      ),
    );

    final iconContext = tester.element(find.byIcon(Icons.search));
    expect(IconTheme.of(iconContext).color, themeColor);
    expect(IconTheme.of(iconContext).size, 24);
    final button = tester.widget<shad.Button>(find.byType(shad.Button));
    final decoration = button.style.decoration(
      tester.element(find.byType(shad.Button)),
      const {},
    );
    expect((decoration as BoxDecoration).color, themeBackground);
  });
}

void _noop() {}
