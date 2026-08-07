import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('menu aliases render in a Material host', (tester) async {
    final items = <AppMenuItem>[
      AppMenuButton(onPressed: (_) {}, child: const Text('Open')),
    ];

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Column(
          children: [
            AppMenubar(
              children: [
                AppMenuButton(subMenu: items, child: const Text('File')),
              ],
            ),
            const AppNavigationMenu(
              children: [
                AppNavigationMenuItem(
                  onPressed: _noop,
                  child: Text('Overview'),
                ),
              ],
            ),
            AppContextMenu(items: items, child: const Text('Context target')),
          ],
        ),
      ),
    );

    expect(find.text('File'), findsOneWidget);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Context target'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('command alias consumes a stream builder', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppCommand(
          autofocus: false,
          debounceDuration: Duration.zero,
          builder: (context, query) async* {
            yield const [AppCommandItem(title: Text('Create component'))];
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();

    expect(find.text('Create component'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppCommand fills a loose-width parent', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 360,
            height: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppCommand(
                  autofocus: false,
                  debounceDuration: Duration.zero,
                  builder: (context, query) async* {
                    yield const [AppCommandItem(title: Text('Open'))];
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 1));
    await tester.pump();
    expect(tester.getSize(find.byType(AppCommand)), const Size(360, 280));
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppDropdownButton opens an anchored menu', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: AppDropdownButton(
              items: [
                AppMenuButton(
                  onPressed: (_) => selected = true,
                  child: const Text('Open item'),
                ),
              ],
              child: const Text('Actions'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Actions'));
    await tester.pumpAndSettle();
    expect(find.text('Open item'), findsOneWidget);

    await tester.tap(find.text('Open item'));
    await tester.pumpAndSettle();
    expect(selected, isTrue);
    expect(tester.takeException(), isNull);
  });

  testWidgets('clicking another dropdown transfers the open menu', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Scaffold(
          body: Column(
            children: [
              AppDropdownButton(
                items: [
                  AppMenuButton(
                    onPressed: (_) {},
                    child: const Text('First item'),
                  ),
                ],
                child: const Text('First dropdown'),
              ),
              AppDropdownButton(
                items: [
                  AppMenuButton(
                    onPressed: (_) {},
                    child: const Text('Second item'),
                  ),
                ],
                child: const Text('Second dropdown'),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('First dropdown'));
    await tester.pumpAndSettle();
    expect(find.text('First item'), findsOneWidget);

    await tester.tap(find.text('Second dropdown'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('First item'), findsNothing);
    expect(find.text('Second item'), findsOneWidget);
  });
}

void _noop() {}
