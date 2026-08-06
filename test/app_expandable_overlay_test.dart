import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('overlay expansion keeps the original grid geometry', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SizedBox(
          width: 600,
          height: 400,
          child: GridView.count(
            crossAxisCount: 2,
            childAspectRatio: 2,
            children: <Widget>[
              AppExpandableOverlay.cover(
                expandedSize: const Size(420, 240),
                direction: AppExpandDirection.right,
                collapsedBuilder: (context, toggle) => GestureDetector(
                  onTap: toggle,
                  child: const ColoredBox(
                    key: ValueKey<String>('collapsed'),
                    color: Colors.blue,
                    child: Text('Open'),
                  ),
                ),
                expandedBuilder: (context, toggle) => GestureDetector(
                  key: const ValueKey<String>('expanded'),
                  onTap: toggle,
                  child: const Text('Close'),
                ),
              ),
              const ColoredBox(
                key: ValueKey<String>('neighbor'),
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    final before = tester.getRect(
      find.byKey(const ValueKey<String>('neighbor')),
    );
    final collapsedSize = tester.getSize(
      find.byKey(const ValueKey<String>('collapsed')),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('expanded')), findsOneWidget);
    expect(
      tester.getRect(find.byKey(const ValueKey<String>('neighbor'))),
      before,
    );
    final expandedSize = tester.getSize(
      find.byKey(const ValueKey<String>('expanded')),
    );
    expect(expandedSize.width, 420);
    expect(expandedSize.height, collapsedSize.height);

    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('collapsed')), findsOneWidget);
  });

  testWidgets('vertical direction preserves width unless both axes allowed', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 140,
            height: 80,
            child: AppExpandableOverlay(
              expandedSize: const Size(360, 240),
              direction: AppExpandDirection.down,
              collapsedBuilder: (context, toggle) => GestureDetector(
                onTap: toggle,
                child: const Text('Open vertical'),
              ),
              expandedBuilder: (context, toggle) =>
                  const SizedBox(key: ValueKey<String>('vertical-expanded')),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open vertical'));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey<String>('vertical-expanded'))),
      const Size(140, 240),
    );
  });

  testWidgets('horizontal overlay preserves the anchor height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 140,
            height: 80,
            child: AppExpandableOverlay.horizontal(
              expandedWidth: 360,
              collapsedBuilder: (context, toggle) => GestureDetector(
                onTap: toggle,
                child: const Text('Open horizontal'),
              ),
              expandedBuilder: (context, toggle) =>
                  const SizedBox(key: ValueKey<String>('horizontal-expanded')),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open horizontal'));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byKey(const ValueKey<String>('horizontal-expanded'))),
      const Size(360, 80),
    );
  });

  testWidgets('sections mode retains main view and adds expanded content', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 140,
            height: 80,
            child: AppExpandableOverlay.expand(
              expandedSize: const Size(360, 80),
              direction: AppExpandDirection.right,
              mainBuilder: (context, toggle) => GestureDetector(
                onTap: toggle,
                child: const Text('Main view'),
              ),
              contentBuilder: (context, toggle) => const Text('Extra view'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Main view'));
    await tester.pumpAndSettle();

    final visibleMain = find.text('Main view').hitTestable();
    expect(visibleMain, findsOneWidget);
    expect(find.text('Extra view'), findsOneWidget);
    expect(tester.getSize(visibleMain).width, lessThanOrEqualTo(140));
  });

  testWidgets('collapsible supports horizontal content animation', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppCollapsible.horizontal(
            triggerExtent: 140,
            children: const <Widget>[
              AppCollapsibleTrigger(child: Text('Details')),
              AppCollapsibleContent.horizontal(
                child: SizedBox(width: 180, child: Text('Horizontal content')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Horizontal content'), findsOneWidget);
    await tester.tap(find.text('Details'));
    await tester.pumpAndSettle();
    expect(
      tester.getSize(find.text('Horizontal content')).width,
      greaterThan(0),
    );
  });

  testWidgets('open overlay follows anchor width after window resize', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: FractionallySizedBox(
            widthFactor: 0.5,
            child: SizedBox(
              height: 80,
              child: AppExpandableOverlay(
                expandedSize: const Size(700, 240),
                direction: AppExpandDirection.down,
                collapsedBuilder: (context, toggle) => GestureDetector(
                  onTap: toggle,
                  child: const Text('Resize open'),
                ),
                expandedBuilder: (context, toggle) =>
                    const SizedBox(key: ValueKey<String>('resize-expanded')),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Resize open'));
    await tester.pumpAndSettle();
    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('resize-expanded')))
          .width,
      400,
    );

    tester.view.physicalSize = const Size(480, 600);
    await tester.pumpAndSettle();

    expect(
      tester
          .getSize(find.byKey(const ValueKey<String>('resize-expanded')))
          .width,
      240,
    );
  });

  testWidgets('updated expanded value synchronizes an uncontrolled overlay', (
    tester,
  ) async {
    final expanded = ValueNotifier<bool>(false);
    addTearDown(expanded.dispose);

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 140,
            height: 80,
            child: ValueListenableBuilder<bool>(
              valueListenable: expanded,
              builder: (context, value, child) => AppExpandableOverlay(
                expanded: value,
                expandedSize: const Size(140, 200),
                direction: AppExpandDirection.down,
                collapsedBuilder: (context, toggle) => const Text('Collapsed'),
                expandedBuilder: (context, toggle) => const SizedBox(
                  key: ValueKey<String>('externally-expanded'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    expanded.value = true;
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('externally-expanded')),
      findsOneWidget,
    );

    expanded.value = false;
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey<String>('externally-expanded')),
      findsNothing,
    );
  });
}
