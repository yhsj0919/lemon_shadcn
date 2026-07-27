import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('menu aliases render in a Material host', (tester) async {
    final items = <AppMenuItem>[
      AppMenuButton(onPressed: (_) {}, child: const Text('Open')),
    ];

    await tester.pumpWidget(
      material.MaterialApp(
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
      material.MaterialApp(
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
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.Align(
          alignment: material.Alignment.topLeft,
          child: material.SizedBox(
            width: 360,
            height: 300,
            child: material.Column(
              crossAxisAlignment: material.CrossAxisAlignment.start,
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
    expect(
      tester.getSize(find.byType(AppCommand)),
      const material.Size(360, 280),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppDropdownButton opens an anchored menu', (tester) async {
    var selected = false;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.Scaffold(
          body: material.Align(
            alignment: material.Alignment.topLeft,
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
}

void _noop() {}
