import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test('LTTB keeps endpoints and a significant spike', () {
    final values = <double>[
      for (var index = 0; index < 100; index++) index == 50 ? 1000 : index / 10,
    ];
    final indices = appChartSampleIndices<double>(
      values,
      maxPoints: 12,
      x: (value) => values.indexOf(value).toDouble(),
      y: (value) => value,
    );

    expect(indices, hasLength(12));
    expect(indices.first, 0);
    expect(indices.last, 99);
    expect(indices, contains(50));
  });

  test('sampling can be disabled without copying data values', () {
    final values = List<double>.generate(20, (index) => index.toDouble());
    final indices = appChartSampleIndices<double>(
      values,
      maxPoints: 5,
      x: (value) => value,
      y: (value) => value,
      strategy: AppChartSamplingStrategy.none,
    );
    expect(indices, List<int>.generate(20, (index) => index));
  });

  test('chart keyboard index wraps in both directions', () {
    expect(appChartLoopIndex(0, -1, 5), 4);
    expect(appChartLoopIndex(4, 1, 5), 0);
  });

  testWidgets('line chart shows an empty state when every value is null', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppLineChart(
          series: <AppLineSeries>[
            AppLineSeries(
              name: 'Empty',
              points: <AppLinePoint>[
                AppLinePoint(x: 0, y: null),
                AppLinePoint(x: 1, y: null),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    expect(find.text('暂无数据'), findsOneWidget);
    expect(find.byType(LineChart), findsNothing);
  });

  testWidgets('line chart limits rendered points but retains endpoints', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppLineChart(
          showLegend: false,
          maxRenderedPoints: 100,
          series: <AppLineSeries>[
            AppLineSeries(
              name: 'Large',
              points: <AppLinePoint>[
                for (var index = 0; index < 1200; index++)
                  AppLinePoint(x: index.toDouble(), y: (index % 47).toDouble()),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    final spots = tester
        .widget<LineChart>(find.byType(LineChart))
        .data
        .lineBarsData
        .single
        .spots;
    expect(spots, hasLength(100));
    expect(spots.first.x, 0);
    expect(spots.last.x, 1199);
  });

  testWidgets('scatter chart limits rendered points per series', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppScatterChart(
          showLegend: false,
          maxRenderedPointsPerSeries: 80,
          samplingStrategy:
              AppChartSamplingStrategy.largestTriangleThreeBuckets,
          series: <AppScatterSeries>[
            AppScatterSeries(
              name: 'Large',
              points: <AppScatterPoint>[
                for (var index = 0; index < 1200; index++)
                  AppScatterPoint(
                    x: index.toDouble(),
                    y: (index % 31).toDouble(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    final spots = tester
        .widget<ScatterChart>(find.byType(ScatterChart))
        .data
        .scatterSpots;
    expect(spots, hasLength(80));
    expect(spots.first.x, 0);
    expect(spots.last.x, 1199);
  });

  testWidgets('scatter chart does not silently sample unordered data', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppScatterChart(
          showLegend: false,
          maxRenderedPointsPerSeries: 20,
          series: <AppScatterSeries>[
            AppScatterSeries(
              name: 'Cloud',
              points: <AppScatterPoint>[
                for (var index = 0; index < 120; index++)
                  AppScatterPoint(
                    x: index.toDouble(),
                    y: (index % 17).toDouble(),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    final spots = tester
        .widget<ScatterChart>(find.byType(ScatterChart))
        .data
        .scatterSpots;
    expect(spots, hasLength(120));
  });
}
