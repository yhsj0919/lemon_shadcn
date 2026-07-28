import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

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
      material.MaterialApp(
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

    tester.widget<Pagination>(find.byType(Pagination)).onPageChanged(2);
    tester.widget<AppTabs>(find.byType(AppTabs)).onChanged(1);
    expect(page, 2);
    expect(tab, 1);
    expect(find.byType(Breadcrumb), findsOneWidget);
    expect(find.byType(AppTabs), findsOneWidget);
    expect(find.byType(AppTabList), findsOneWidget);
  });

  testWidgets('steps and timeline aliases render categorized layout data', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
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
    expect(find.byType(Steps), findsOneWidget);
    expect(find.byType(Timeline), findsOneWidget);
  });
}
