import 'dart:async';
import 'dart:ui' show PointerDeviceKind;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  const series = <AppLineSeries>[
    AppLineSeries(
      name: '访问量',
      points: <AppLinePoint>[
        AppLinePoint(x: 0, y: 12, label: '周一'),
        AppLinePoint(x: 1, y: 24, label: '周二'),
        AppLinePoint(x: 2, y: 18, label: '周三'),
      ],
    ),
  ];

  testWidgets('line variants share App theme geometry', (tester) async {
    Future<LineChartData> pump(Widget chart) async {
      await tester.pumpWidget(
        MaterialApp(
          builder: AppShadcnScope.builder(
            config: AppThemeConfig.standard(
              chart: const AppChartTheme(lineWidth: 4, height: 230),
            ),
          ),
          home: Align(alignment: Alignment.topLeft, child: chart),
        ),
      );
      await tester.pump();
      return tester.widget<LineChart>(find.byType(LineChart)).data;
    }

    var data = await pump(const AppLineChart(series: series));
    expect(data.lineBarsData.single.barWidth, 4);
    expect(data.lineBarsData.single.belowBarData.show, isFalse);
    expect(data.titlesData.leftTitles.sideTitles.minIncluded, isFalse);
    expect(data.titlesData.bottomTitles.sideTitles.minIncluded, isTrue);
    expect(data.titlesData.bottomTitles.sideTitles.interval, 1);
    expect(find.text('0.1'), findsNothing);
    expect(tester.getSize(find.byType(AppLineChart)).height, 230);

    data = await pump(const AppLineChart.area(series: series));
    expect(data.lineBarsData.single.belowBarData.show, isTrue);

    data = await pump(const AppLineChart.step(series: series));
    expect(data.lineBarsData.single.isStepLineChart, isTrue);
  });

  testWidgets('line touch maps to point and series callback', (tester) async {
    AppLineChartHit? tapped;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppLineChart(
            series: series,
            onPointTap: (hit) => tapped = hit,
          ),
        ),
      ),
    );
    await tester.pump();
    final data = tester.widget<LineChart>(find.byType(LineChart)).data;
    final bar = data.lineBarsData.single;
    final spot = bar.spots[1];
    data.lineTouchData.touchCallback!(
      FlTapUpEvent(
        TapUpDetails(
          localPosition: const Offset(10, 10),
          kind: PointerDeviceKind.mouse,
        ),
      ),
      LineTouchResponse(
        touchLocation: const Offset(10, 10),
        touchChartCoordinate: const Offset(10, 10),
        lineBarSpots: <TouchLineBarSpot>[TouchLineBarSpot(bar, 0, spot, 0)],
      ),
    );
    await tester.pump();

    expect(tapped?.series.name, '访问量');
    expect(tapped?.point.label, '周二');
    expect(tapped?.point.y, 24);
  });

  testWidgets('donut uses App theme and maps section touch', (tester) async {
    AppPieChartHit? tapped;
    int? selected;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            chart: const AppChartTheme(
              pieRadius: 68,
              donutHoleRadius: 44,
              pieLabelMinPercent: 40,
            ),
          ),
        ),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppPieChart.donut(
            sections: const <AppPieSection>[
              AppPieSection(label: '桌面端', value: 62),
              AppPieSection(label: '移动端', value: 38, color: Color(0xff10b981)),
            ],
            selectionEnabled: true,
            onSelectionChanged: (value) => selected = value,
            onSectionTap: (hit) => tapped = hit,
          ),
        ),
      ),
    );
    await tester.pump();
    final data = tester.widget<PieChart>(find.byType(PieChart)).data;
    expect(data.centerSpaceRadius, 44);
    expect(data.sections.first.radius, 68);
    expect(data.sections.first.showTitle, isTrue);
    expect(data.sections[1].showTitle, isFalse);
    expect(data.sections[1].color, const Color(0xff10b981));

    data.pieTouchData.touchCallback!(
      FlTapUpEvent(
        TapUpDetails(
          localPosition: const Offset(10, 10),
          kind: PointerDeviceKind.mouse,
        ),
      ),
      PieTouchResponse(
        touchLocation: const Offset(10, 10),
        touchedSection: PieTouchedSection(data.sections[1], 1, 0, 20),
      ),
    );
    await tester.pump();

    expect(selected, 1);
    expect(tapped?.section.label, '移动端');
    expect(find.text('移动端'), findsWidgets);
  });

  testWidgets('async chart keeps one stable themed slot', (tester) async {
    final completer = Completer<List<AppBarValue>>();
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppAsyncChart<List<AppBarValue>>(
            height: 190,
            load: () => completer.future,
            builder: (_, values) =>
                AppBarChart.simple(labels: const <String>['A'], values: values),
          ),
        ),
      ),
    );
    expect(
      tester.getSize(find.byType(AppAsyncChart<List<AppBarValue>>)).height,
      190,
    );
    expect(find.byType(AppBarChart), findsNothing);

    completer.complete(const <AppBarValue>[AppBarValue(value: 12)]);
    await tester.pumpAndSettle();
    expect(find.byType(AppBarChart), findsOneWidget);
    expect(
      tester.getSize(find.byType(AppAsyncChart<List<AppBarValue>>)).height,
      190,
    );
  });

  testWidgets('line and pie charts expose keyboard business callbacks', (
    tester,
  ) async {
    AppLineChartHit? lineHit;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppLineChart(
            autofocus: true,
            series: series,
            onPointTap: (hit) => lineHit = hit,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(lineHit?.point.label, '周二');

    AppPieChartHit? pieHit;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppPieChart.donut(
            autofocus: true,
            sections: const <AppPieSection>[
              AppPieSection(label: '桌面端', value: 60),
              AppPieSection(label: '移动端', value: 40),
            ],
            onSectionTap: (hit) => pieHit = hit,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    expect(pieHit?.section.label, '移动端');
  });

  testWidgets('pointer tooltip follows the pointer and avoids chart edges', (
    tester,
  ) async {
    const chartKey = ValueKey<String>('chart-box');
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            key: chartKey,
            width: 200,
            height: 120,
            child: Stack(
              children: <Widget>[
                AppPointerTooltip(
                  position: Offset(194, 114),
                  message: '顶部系列\n128 次',
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final chartRect = tester.getRect(find.byKey(chartKey));
    final tooltipRect = tester.getRect(
      find.byKey(const ValueKey<String>('app-pointer-tooltip-surface')),
    );
    expect(chartRect.contains(tooltipRect.topLeft), isTrue);
    expect(chartRect.contains(tooltipRect.bottomRight), isTrue);
    expect(tooltipRect.right, lessThan(194));
    expect(tooltipRect.bottom, lessThan(114));
  });

  testWidgets('pointer tooltip fades out when the mouse leaves the chart', (
    tester,
  ) async {
    Offset? position = const Offset(50, 50);
    String? message = '42';
    late StateSetter rebuild;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            height: 120,
            child: StatefulBuilder(
              builder: (context, setState) {
                rebuild = setState;
                return AppPointerTooltipArea(
                  position: position,
                  message: message,
                  onExit: () => rebuild(() {
                    position = null;
                    message = null;
                  }),
                  child: const ColoredBox(color: Colors.transparent),
                );
              },
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    expect(
      tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity,
      1,
    );
    await tester.pump(const Duration(milliseconds: 140));

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer(location: const Offset(20, 20));
    await mouse.moveTo(const Offset(300, 200));
    await tester.pump();

    final opacity = tester.widget<AnimatedOpacity>(
      find.byType(AnimatedOpacity),
    );
    expect(opacity.opacity, 0);
    expect(
      find.byKey(const ValueKey<String>('app-pointer-tooltip-surface')),
      findsOneWidget,
    );
    await tester.pump(const Duration(milliseconds: 140));
    await mouse.removePointer();
  });

  testWidgets('pointer tooltip follows same-side movement without lag', (
    tester,
  ) async {
    Widget subject(Offset position) => MaterialApp(
      builder: AppShadcnScope.builder(),
      home: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: 300,
          height: 160,
          child: Stack(
            children: <Widget>[
              AppPointerTooltip(position: position, message: '42'),
            ],
          ),
        ),
      ),
    );

    await tester.pumpWidget(subject(const Offset(30, 50)));
    await tester.pumpAndSettle();
    final surface = find.byKey(
      const ValueKey<String>('app-pointer-tooltip-surface'),
    );
    final before = tester.getTopLeft(surface);

    await tester.pumpWidget(subject(const Offset(90, 50)));
    await tester.pump();
    final after = tester.getTopLeft(surface);

    expect(after.dx - before.dx, closeTo(60, 0.01));
  });
}
