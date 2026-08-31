import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

void main() {
  testWidgets('navigation aliases render and retain upstream callbacks', (
    tester,
  ) async {
    var page = 1;
    var tab = 0;
    const tabs = [
      AppTabItem(child: Text('First')),
      AppTabItem(child: Text('Second')),
    ];
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Column(
          children: [
            const AppBreadcrumb(children: [Text('Home'), Text('Current')]),
            AppPagination(
              page: page,
              totalPages: 3,
              onPageChanged: (value) => page = value,
            ),
            AppTabs(
              index: tab,
              onChanged: (value) => tab = value,
              children: tabs,
            ),
            AppTabList(
              index: tab,
              onChanged: (value) => tab = value,
              children: tabs,
            ),
          ],
        ),
      ),
    );

    tester.widget<AppPagination>(find.byType(AppPagination)).onPageChanged(2);
    tester.widget<AppTabs>(find.byType(AppTabs)).onChanged(1);
    expect(page, 2);
    expect(tab, 1);
    expect(find.byType(AppBreadcrumb), findsOneWidget);
    expect(find.byType(AppTabs), findsOneWidget);
    expect(find.byType(AppTabList), findsOneWidget);
  });

  testWidgets('pagination supports icon-only navigation and custom items', (
    tester,
  ) async {
    var builtItems = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppPagination(
          page: 2,
          totalPages: 3,
          variant: AppPaginationVariant.iconOnly,
          itemBuilder: (context, page, selected, onPressed) {
            builtItems++;
            return GestureDetector(
              key: ValueKey('custom-page-$page'),
              onTap: onPressed,
              child: Text(selected ? '[$page]' : '$page'),
            );
          },
          onPageChanged: (_) {},
        ),
      ),
    );

    expect(builtItems, 3);
    expect(find.byKey(const ValueKey('custom-page-2')), findsOneWidget);
    expect(find.text('Previous'), findsNothing);
    expect(find.text('Next'), findsNothing);
  });

  testWidgets('unselected pagination items keep a transparent background', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppPagination(
          page: 2,
          totalPages: 2,
          variant: AppPaginationVariant.iconOnly,
          onPageChanged: (_) {},
        ),
      ),
    );

    final override = tester.widget<shad.ButtonStyleOverride>(
      find.ancestor(
        of: find.text('1'),
        matching: find.byType(shad.ButtonStyleOverride),
      ),
    );
    final decoration = override.decoration!(
      tester.element(find.text('1')),
      {WidgetState.hovered},
      const BoxDecoration(color: Colors.grey),
    );
    expect((decoration as BoxDecoration).color, Colors.transparent);
  });

  testWidgets('steps and timeline aliases render categorized layout data', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Column(
          children: [
            const AppSteps(children: [Text('One'), Text('Two')]),
            AppTimeline(
              data: [
                AppTimelineData(
                  time: const Text('Now'),
                  title: const Text('Done'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
    expect(find.byType(AppSteps), findsOneWidget);
    expect(find.byType(AppTimeline), findsOneWidget);
  });

  testWidgets('timeline can place time and actions in the title row', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppTimeline.vertical(
          timePosition: AppTimelineTimePosition.inline,
          data: [
            AppTimelineData(
              time: const Text('2026-08-27'),
              title: const Text('更换滤芯'),
              trailing: const Icon(Icons.more_horiz),
            ),
          ],
        ),
      ),
    );

    final headerRow = find.ancestor(
      of: find.text('更换滤芯'),
      matching: find.byType(Row),
    );
    expect(headerRow, findsOneWidget);
    expect(
      find.descendant(of: headerRow, matching: find.text('2026-08-27')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: headerRow, matching: find.byIcon(Icons.more_horiz)),
      findsOneWidget,
    );

    final table = tester.widget<Table>(find.byType(Table));
    expect((table.columnWidths![0]! as FixedColumnWidth).value, 0);
    expect((table.columnWidths![1]! as FixedColumnWidth).value, 0);
  });

  testWidgets('tabs use component foreground defaults without mutating scheme', (
    tester,
  ) async {
    const selected = Color(0xff2563eb);
    const unselected = Color(0xff64748b);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppComponentTheme<AppTabsTheme>(
          data: const AppTabsTheme(
            selectedForegroundColor: selected,
            unselectedForegroundColor: unselected,
          ),
          child: Column(
            children: [
              AppTabs(
                index: 0,
                onChanged: (_) {},
                children: const [
                  AppTabItem(
                    child: Row(
                      children: [Icon(Icons.home), Text('Selected tab')],
                    ),
                  ),
                  AppTabItem(
                    child: Row(
                      children: [Icon(Icons.settings), Text('Muted tab')],
                    ),
                  ),
                ],
              ),
              AppTabList(
                index: 0,
                onChanged: (_) {},
                children: const [
                  AppTabItem(child: Text('Selected list tab')),
                  AppTabItem(
                    child: Row(
                      children: [Icon(Icons.info), Text('Muted list tab')],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      IconTheme.of(tester.element(find.byIcon(Icons.home))).color,
      selected,
    );
    expect(
      IconTheme.of(tester.element(find.byIcon(Icons.settings))).color,
      unselected,
    );
    expect(
      IconTheme.of(tester.element(find.byIcon(Icons.info))).color,
      unselected,
    );
    expect(
      DefaultTextStyle.of(tester.element(find.text('Muted tab'))).style.color,
      unselected,
    );
    expect(
      find.descendant(
        of: find.byType(AppTabs),
        matching: find.byType(ColorFiltered),
      ),
      findsNothing,
    );
  });
}
