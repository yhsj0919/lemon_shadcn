import 'dart:ui' show PointerDeviceKind;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('scatter chart maps business points, colors and touch callback', (
    tester,
  ) async {
    AppScatterChartHit? hit;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppScatterChart(
            showLegend: false,
            series: const <AppScatterSeries>[
              AppScatterSeries(
                name: '客户',
                color: Color(0xff2563eb),
                points: <AppScatterPoint>[
                  AppScatterPoint(x: 2, y: 8, label: '企业 A'),
                  AppScatterPoint(x: 4, y: 5, color: Color(0xffef4444)),
                ],
              ),
            ],
            onPointTap: (value) => hit = value,
          ),
        ),
      ),
    );
    await tester.pump();

    final data = tester.widget<ScatterChart>(find.byType(ScatterChart)).data;
    expect(data.scatterSpots, hasLength(2));
    expect(
      (data.scatterSpots[1].dotPainter as FlDotCirclePainter).color,
      const Color(0xffef4444),
    );
    expect(data.scatterTouchData.handleBuiltInTouches, isFalse);
    expect(data.titlesData.leftTitles.sideTitles.minIncluded, isFalse);
    expect(data.titlesData.leftTitles.sideTitles.maxIncluded, isFalse);
    expect(data.titlesData.bottomTitles.sideTitles.minIncluded, isFalse);
    expect(data.titlesData.bottomTitles.sideTitles.maxIncluded, isFalse);

    data.scatterTouchData.touchCallback!(
      FlTapUpEvent(
        TapUpDetails(
          localPosition: const Offset(40, 40),
          kind: PointerDeviceKind.mouse,
        ),
      ),
      ScatterTouchResponse(
        touchLocation: const Offset(40, 40),
        touchChartCoordinate: const Offset(2, 8),
        touchedSpot: ScatterTouchedSpot(data.scatterSpots.first, 0),
      ),
    );
    await tester.pump();

    expect(hit?.point.label, '企业 A');
    expect(find.byType(AppPointerTooltip), findsOneWidget);
  });

  testWidgets('scatter keyboard activation reuses the point callback', (
    tester,
  ) async {
    AppScatterChartHit? hit;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppScatterChart(
            autofocus: true,
            showLegend: false,
            series: const <AppScatterSeries>[
              AppScatterSeries(
                name: '客户',
                points: <AppScatterPoint>[
                  AppScatterPoint(x: 2, y: 8, label: '企业 A'),
                  AppScatterPoint(x: 4, y: 5, label: '企业 B'),
                ],
              ),
            ],
            onPointTap: (value) => hit = value,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(hit?.point.label, '企业 A');
  });
}
