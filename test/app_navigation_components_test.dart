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

  testWidgets('icon-only AppTabs stay square and honor padding', (tester) async {
    const padding = EdgeInsets.all(12);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            height: 64,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppTabs(
                  index: 0,
                  iconOnly: true,
                  padding: padding,
                  onChanged: (_) {},
                  children: const [
                    AppTabItem(child: Icon(Icons.grid_view, size: 16)),
                    AppTabItem(child: Icon(Icons.list, size: 16)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    Rect tabRectFor(IconData icon) {
      return tester.getRect(
        find
            .ancestor(
              of: find.byIcon(icon),
              matching: find.byType(GestureDetector),
            )
            .first,
      );
    }

    final first = tabRectFor(Icons.grid_view);
    final second = tabRectFor(Icons.list);
    expect(first.width, closeTo(first.height, 0.5));
    expect(second.width, closeTo(second.height, 0.5));
    expect(first.width, closeTo(16 + padding.horizontal, 0.5));
    expect(second.left, greaterThan(first.right - 0.5));
  });

  testWidgets('icon-only AppTabs default height matches control metrics', (
    tester,
  ) async {
    late double controlHeight;
    late double iconSize;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) {
            final metrics = AppControlMetricsScope.resolve(context);
            controlHeight = metrics.height;
            iconSize = metrics.iconSize;
            return Align(
              alignment: Alignment.topLeft,
              child: AppTabs(
                index: 0,
                iconOnly: true,
                onChanged: (_) {},
                children: const [
                  AppTabItem(child: Icon(Icons.grid_view)),
                  AppTabItem(child: Icon(Icons.list)),
                ],
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final track = tester.getRect(
      find
          .descendant(
            of: find.byType(AppTabs),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Container && widget.decoration is BoxDecoration,
            ),
          )
          .first,
    );
    expect(track.height, closeTo(controlHeight, 1));

    final tab = tester.getRect(
      find
          .ancestor(
            of: find.byIcon(Icons.grid_view),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(tab.width, closeTo(tab.height, 0.5));
    expect(tab.height, closeTo(iconSize + (controlHeight - iconSize) / 2, 1));
  });

  testWidgets('AppTabsTheme.tabPadding applies when padding is omitted', (
    tester,
  ) async {
    const themePadding = EdgeInsets.all(10);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppComponentTheme<AppTabsTheme>(
          data: const AppTabsTheme(tabPadding: themePadding),
          child: Align(
            alignment: Alignment.topLeft,
            child: AppTabs(
              index: 0,
              iconOnly: true,
              onChanged: (_) {},
              children: const [
                AppTabItem(child: Icon(Icons.star, size: 16)),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final tab = tester.getRect(
      find
          .ancestor(
            of: find.byIcon(Icons.star),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    expect(tab.width, closeTo(16 + themePadding.horizontal, 0.5));
    expect(tab.height, closeTo(16 + themePadding.vertical, 0.5));
  });

  testWidgets('first selected tab indicator covers the full first tab', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppTabs(
            index: 0,
            selectedColor: const Color(0xffffffff),
            unselectedColor: const Color(0xffe2e8f0),
            onChanged: (_) {},
            children: const [
              AppTabItem(child: Text('全部 172')),
              AppTabItem(child: Text('在线 1')),
              AppTabItem(child: Text('离线 171')),
            ],
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final firstTab = tester.getRect(
      find
          .ancestor(
            of: find.text('全部 172'),
            matching: find.byType(GestureDetector),
          )
          .first,
    );
    final indicator = tester.getRect(
      find.descendant(
        of: find.byType(AppTabs),
        matching: find.byType(AnimatedPositioned),
      ),
    );

    expect(indicator.left, closeTo(firstTab.left, 1));
    expect(indicator.top, closeTo(firstTab.top, 1));
    expect(indicator.width, closeTo(firstTab.width, 1));
    expect(indicator.height, closeTo(firstTab.height, 1));
  });
}
