import 'dart:ui' show PointerDeviceKind;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

void main() {
  test('axis width is measured and bounded by chart theme tokens', () {
    const chart = AppChartTheme(
      axisMinReservedSize: 40,
      axisMaxReservedSize: 80,
    );
    const style = TextStyle(fontSize: 12);

    expect(appChartAxisReservedWidth(const <String>['1'], style, chart), 40);
    expect(
      appChartAxisReservedWidth(
        const <String>['12345678901234567890'],
        style,
        chart,
      ),
      80,
    );
  });

  testWidgets('bar chart derives geometry and colors from App chart theme', (
    tester,
  ) async {
    late Color primary;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            chart: const AppChartTheme(height: 240, barWidth: 21, radius: 7),
          ),
        ),
        home: Align(
          alignment: Alignment.topLeft,
          child: Builder(
            builder: (context) {
              primary = shad.Theme.of(context).colorScheme.primary;
              return AppBarChart.simple(
                labels: const <String>['A', 'B'],
                values: const <AppBarValue>[
                  AppBarValue(value: 10),
                  AppBarValue(value: 20, color: Color(0xff10b981)),
                ],
              );
            },
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(AppBarChart)).height, 240);
    final data = tester.widget<BarChart>(find.byType(BarChart)).data;
    expect(data.barGroups.first.barRods.first.width, 21);
    expect(data.barGroups.first.barRods.first.color, primary);
    expect(data.barGroups[1].barRods.first.color, const Color(0xff10b981));
    expect(data.barGroups.first.barRods.first.borderRadius?.topLeft.x, 7);
    expect(tester.takeException(), isNull);
  });

  testWidgets('series style, controlled selection and resolver compose', (
    tester,
  ) async {
    const selectedColor = Color(0xffef4444);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppBarChart(
          groups: const <AppBarGroup>[
            AppBarGroup(
              label: 'Q1',
              values: <AppBarValue>[AppBarValue(value: 42)],
            ),
          ],
          series: const <AppBarSeries>[
            AppBarSeries(name: '收入', color: Color(0xff10b981)),
          ],
          selectionEnabled: true,
          selected: <AppChartSelection>{const AppChartSelection(0, 0)},
          onSelectionChanged: (_) {},
          colorResolver: (data) =>
              data.isSelected ? selectedColor : data.baseColor,
        ),
      ),
    );
    await tester.pump();

    final data = tester.widget<BarChart>(find.byType(BarChart)).data;
    expect(data.barGroups.single.barRods.single.color, selectedColor);

    await tester.tap(find.text('收入'));
    await tester.pump();
    final hidden = tester.widget<BarChart>(find.byType(BarChart)).data;
    expect(hidden.barGroups.single.barRods.single.toY, 0);
    expect(hidden.barGroups.single.barRods.single.color?.a, 0);
  });

  testWidgets('empty chart preserves configured height', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: AppBarChart(groups: <AppBarGroup>[], height: 180),
        ),
      ),
    );

    expect(find.text('暂无数据'), findsOneWidget);
    expect(tester.getSize(find.byType(AppBarChart)).height, 180);
  });

  testWidgets('bar touch maps to the simple business callback', (tester) async {
    AppBarChartHit? tapped;
    Set<AppChartSelection>? selected;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppBarChart(
            groups: const <AppBarGroup>[
              AppBarGroup(
                label: '一月',
                values: <AppBarValue>[AppBarValue(value: 28)],
              ),
            ],
            onBarTap: (value) => tapped = value,
            selectionEnabled: true,
            onSelectionChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.pump();

    final data = tester.widget<BarChart>(find.byType(BarChart)).data;
    final group = data.barGroups.single;
    final rod = group.barRods.single;
    data.barTouchData.touchCallback!(
      FlTapUpEvent(
        TapUpDetails(
          localPosition: const Offset(10, 10),
          kind: PointerDeviceKind.mouse,
        ),
      ),
      BarTouchResponse(
        touchLocation: const Offset(10, 10),
        touchChartCoordinate: const Offset(10, 10),
        spot: BarTouchedSpot(
          group,
          0,
          rod,
          0,
          null,
          -1,
          const FlSpot(0, 28),
          const Offset(10, 10),
        ),
      ),
    );
    await tester.pump();

    expect(tapped?.group.label, '一月');
    expect(tapped?.value.value, 28);
    expect(selected, <AppChartSelection>{const AppChartSelection(0, 0)});
  });

  testWidgets('stacked bars keep segment styles and callback identity', (
    tester,
  ) async {
    AppBarChartHit? tapped;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppBarChart.stacked(
            series: const <AppBarSeries>[
              AppBarSeries(name: '收入'),
              AppBarSeries(name: '支出', color: Color(0xfff59e0b)),
            ],
            groups: const <AppBarGroup>[
              AppBarGroup(
                label: '一月',
                values: <AppBarValue>[
                  AppBarValue(value: 30),
                  AppBarValue(value: 12),
                ],
              ),
            ],
            onBarTap: (hit) => tapped = hit,
          ),
        ),
      ),
    );
    await tester.pump();

    final data = tester.widget<BarChart>(find.byType(BarChart)).data;
    final group = data.barGroups.single;
    final rod = group.barRods.single;
    expect(rod.toY, 42);
    expect(rod.rodStackItems, hasLength(2));
    expect(rod.rodStackItems[0].fromY, 0);
    expect(rod.rodStackItems[0].toY, 30);
    expect(rod.rodStackItems[1].fromY, 30);
    expect(rod.rodStackItems[1].toY, 42);
    expect(rod.rodStackItems[1].color, const Color(0xfff59e0b));

    data.barTouchData.touchCallback!(
      FlTapUpEvent(
        TapUpDetails(
          localPosition: const Offset(10, 10),
          kind: PointerDeviceKind.mouse,
        ),
      ),
      BarTouchResponse(
        touchLocation: const Offset(10, 10),
        touchChartCoordinate: const Offset(10, 10),
        spot: BarTouchedSpot(
          group,
          0,
          rod,
          0,
          rod.rodStackItems[1],
          1,
          const FlSpot(0, 35),
          const Offset(10, 10),
        ),
      ),
    );
    await tester.pump();

    expect(tapped?.series?.name, '支出');
    expect(tapped?.value.value, 12);
    expect(find.byType(AppPointerTooltip), findsOneWidget);
    expect(data.barTouchData.handleBuiltInTouches, isFalse);
  });

  testWidgets('horizontal bars use numeric x axis and upright labels', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: AppBarChart.horizontal(
            groups: <AppBarGroup>[
              AppBarGroup(
                label: '华东',
                values: <AppBarValue>[AppBarValue(value: 42)],
              ),
              AppBarGroup(
                label: '华南',
                values: <AppBarValue>[AppBarValue(value: 31)],
              ),
            ],
            xAxis: AppChartAxis(min: 0, max: 50, interval: 10),
            yAxis: AppChartAxis(title: '区域'),
          ),
        ),
      ),
    );
    await tester.pump();

    final data = tester.widget<BarChart>(find.byType(BarChart)).data;
    expect(data.rotationQuarterTurns, 1);
    expect(data.minY, 0);
    expect(data.maxY, 50);
    expect(data.titlesData.leftTitles.sideTitles.showTitles, isFalse);
    expect(data.titlesData.rightTitles.sideTitles.showTitles, isTrue);
    expect(data.barGroups.first.barRods.first.label.angle, 0);
    expect(
      find.ancestor(
        of: find.text('华东'),
        matching: find.byWidgetPredicate(
          (widget) => widget is RotatedBox && widget.quarterTurns == 3,
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('dense bar labels are sampled instead of overlapping', (
    tester,
  ) async {
    Future<BarChartData> pump(double width) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: AppShadcnScope.builder(),
          home: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: const AppBarChart(
                showValues: true,
                groups: <AppBarGroup>[
                  AppBarGroup(
                    label: 'A',
                    values: <AppBarValue>[AppBarValue(value: 10)],
                  ),
                  AppBarGroup(
                    label: 'B',
                    values: <AppBarValue>[AppBarValue(value: 20)],
                  ),
                  AppBarGroup(
                    label: 'C',
                    values: <AppBarValue>[AppBarValue(value: 30)],
                  ),
                  AppBarGroup(
                    label: 'D',
                    values: <AppBarValue>[AppBarValue(value: 40)],
                  ),
                ],
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      return tester.widget<BarChart>(find.byType(BarChart)).data;
    }

    var data = await pump(500);
    expect(
      data.barGroups
          .expand((group) => group.barRods)
          .where((rod) => rod.label.show),
      hasLength(4),
    );

    data = await pump(80);
    expect(
      data.barGroups
          .expand((group) => group.barRods)
          .where((rod) => rod.label.show)
          .length,
      lessThan(4),
    );
  });

  testWidgets('keyboard navigation triggers the same bar callback', (
    tester,
  ) async {
    AppBarChartHit? tapped;
    Set<AppChartSelection>? selected;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppBarChart.simple(
            labels: const <String>['A', 'B'],
            values: const <AppBarValue>[
              AppBarValue(value: 10),
              AppBarValue(value: 20),
            ],
            onBarTap: (hit) => tapped = hit,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(AppChartKeyboardRegion));
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(tapped?.group.label, 'A');
    expect(tapped?.value.value, 10);

    // A controlled chart uses the identical keyboard activation path.
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppBarChart(
            autofocus: true,
            groups: const <AppBarGroup>[
              AppBarGroup(
                label: 'A',
                values: <AppBarValue>[AppBarValue(value: 10)],
              ),
            ],
            selectionEnabled: true,
            onSelectionChanged: (value) => selected = value,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(selected, <AppChartSelection>{const AppChartSelection(0, 0)});
    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    expect(selected, isEmpty);
  });

  testWidgets('stacked bar down arrow follows the visual downward order', (
    tester,
  ) async {
    AppBarChartHit? tapped;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppBarChart.stacked(
            autofocus: true,
            series: const <AppBarSeries>[
              AppBarSeries(name: '底部'),
              AppBarSeries(name: '中部'),
              AppBarSeries(name: '顶部'),
            ],
            groups: const <AppBarGroup>[
              AppBarGroup(
                label: '一月',
                values: <AppBarValue>[
                  AppBarValue(value: 10),
                  AppBarValue(value: 20),
                  AppBarValue(value: 30),
                ],
              ),
            ],
            onBarTap: (hit) => tapped = hit,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(tapped?.series?.name, '中部');
  });

  testWidgets('selection is opt-in while click callbacks remain enabled', (
    tester,
  ) async {
    var selectionCalls = 0;
    AppBarChartHit? tapped;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppBarChart(
            autofocus: true,
            groups: const <AppBarGroup>[
              AppBarGroup(
                label: '默认',
                values: <AppBarValue>[AppBarValue(value: 8)],
              ),
            ],
            onBarTap: (hit) => tapped = hit,
            onSelectionChanged: (_) => selectionCalls++,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(tapped?.group.label, '默认');
    expect(selectionCalls, 0);
  });
}
