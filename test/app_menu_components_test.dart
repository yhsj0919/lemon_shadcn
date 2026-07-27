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
}

void _noop() {}
