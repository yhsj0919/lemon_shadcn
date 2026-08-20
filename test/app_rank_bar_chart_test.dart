import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test('rank chart uses compact default row geometry', () {
    const chart = AppRankBarChart(items: <AppRankBarItem>[]);
    expect(chart.rowHeight, 44);
    expect(chart.labelWidth, 120);
    expect(chart.gap, 8);
  });

  testWidgets('rank values share a fixed column and stay inside the chart', (
    tester,
  ) async {
    const chartKey = Key('rank-chart');
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 360,
            child: AppRankBarChart(
              key: chartKey,
              header: AppRankBarHeader(value: '设备数量'),
              items: <AppRankBarItem>[
                AppRankBarItem(label: '历下区', value: 1562),
                AppRankBarItem(label: '市中区', value: 8),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final first = tester.getRect(
      find.byKey(const ValueKey<String>('app-rank-bar-value-0')),
    );
    final second = tester.getRect(
      find.byKey(const ValueKey<String>('app-rank-bar-value-1')),
    );
    final headerValueRight = tester.getRect(find.text('设备数量')).right;
    expect(first.right, headerValueRight);
    expect(second.right, headerValueRight);
    expect(first.right, lessThan(tester.getRect(find.byKey(chartKey)).right));
    expect(tester.takeException(), isNull);
  });

  testWidgets('rank chart supports monochrome segments', (tester) async {
    const blue = Color(0xff2563eb);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppRankBarChart(
          color: blue,
          items: <AppRankBarItem>[
            AppRankBarItem(
              label: '历下区',
              value: 100,
              segments: <AppRankBarSegment>[
                AppRankBarSegment(value: 40, color: Colors.red),
                AppRankBarSegment(value: 60, color: Colors.green),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    for (var index = 0; index < 2; index++) {
      final box = tester.widget<ColoredBox>(
        find.byKey(ValueKey<String>('app-rank-bar-segment-0-$index')),
      );
      expect(box.color, blue);
    }
    final lastSegment = find.byKey(
      const ValueKey<String>('app-rank-bar-segment-0-1'),
    );
    final clips = tester.widgetList<ClipRRect>(
      find.ancestor(of: lastSegment, matching: find.byType(ClipRRect)),
    );
    expect(
      clips.any(
        (clip) => clip.borderRadius.resolve(TextDirection.ltr).topRight.x > 0,
      ),
      isTrue,
    );
  });

  testWidgets('rank chart supports spacing and custom cell widgets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppRankBarChart(
          rowSpacing: 14,
          headerSpacing: 10,
          header: const AppRankBarHeader(
            padding: EdgeInsets.all(6),
            margin: EdgeInsets.symmetric(horizontal: 4),
            rankWidget: Icon(Icons.tag, key: Key('header-rank')),
            labelWidget: Text('自定义名称', key: Key('header-label')),
            valueWidget: Icon(Icons.numbers, key: Key('header-value')),
          ),
          rankBuilder: (_, rank) =>
              Icon(Icons.star, key: ValueKey<String>('rank-$rank')),
          labelBuilder: (_, item) => Chip(label: Text(item.label)),
          valueBuilder: (_, item, formatted) => Text(
            '$formatted 台',
            key: ValueKey<String>('custom-value-${item.label}'),
            textAlign: TextAlign.right,
          ),
          items: const <AppRankBarItem>[
            AppRankBarItem(label: 'A', value: 10),
            AppRankBarItem(label: 'B', value: 8),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('header-rank')), findsOneWidget);
    expect(find.byKey(const Key('header-label')), findsOneWidget);
    expect(find.byKey(const Key('header-value')), findsOneWidget);
    expect(find.byKey(const ValueKey<String>('rank-1')), findsOneWidget);
    expect(find.byType(Chip), findsNWidgets(2));
    expect(
      find.byKey(const ValueKey<String>('custom-value-A')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
