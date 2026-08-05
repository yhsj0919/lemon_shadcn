import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('radar chart maps indicators and themed series', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: AppRadarChart(
            showLegend: false,
            indicators: <String>['速度', '质量', '成本'],
            series: <AppRadarSeries>[
              AppRadarSeries(
                name: '方案 A',
                color: Color(0xff2563eb),
                values: <double>[80, 72, 64],
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(RadarChart)).width, greaterThan(300));
    expect(tester.getSize(find.byType(RadarChart)).height, greaterThan(150));

    final data = tester.widget<RadarChart>(find.byType(RadarChart)).data;
    expect(data.dataSets.single.dataEntries, hasLength(3));
    expect(data.dataSets.single.borderColor, const Color(0xff2563eb));
    expect(data.getTitle!(0, 0).text, '速度');
    expect(data.getTitle!(1, 72).angle, 0);
    expect(data.ticksTextStyle?.fontSize, 0);
    expect(data.radarShape, RadarShape.polygon);
  });

  testWidgets('radar chart keyboard navigation activates a point', (
    tester,
  ) async {
    AppRadarChartHit? hit;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppRadarChart(
          autofocus: true,
          showLegend: false,
          indicators: const <String>['Speed', 'Quality', 'Cost'],
          series: const <AppRadarSeries>[
            AppRadarSeries(name: 'Plan A', values: <double>[80, 72, 64]),
          ],
          onPointTap: (value) => hit = value,
        ),
      ),
    );
    await tester.pump();

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(hit?.indicatorIndex, 0);
    expect(hit?.seriesIndex, 0);
    expect(hit?.value, 80);
  });
}
