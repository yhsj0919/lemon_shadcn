import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('candlestick chart accepts hidden x and y axes', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppCandlestickChart(
          xAxis: AppChartAxis(show: false),
          yAxis: AppChartAxis(show: false),
          data: <AppCandlestickData>[
            AppCandlestickData(open: 10, high: 16, low: 8, close: 14),
          ],
        ),
      ),
    );
    await tester.pump();

    final chart = tester.widget<AppCandlestickChart>(
      find.byType(AppCandlestickChart),
    );
    expect(chart.xAxis.show, isFalse);
    expect(chart.yAxis.show, isFalse);
    expect(tester.takeException(), isNull);
  });

  testWidgets('candlestick chart paints business data', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppCandlestickChart(
          data: <AppCandlestickData>[
            AppCandlestickData(
              label: 'Mon',
              open: 10,
              high: 16,
              low: 8,
              close: 14,
            ),
            AppCandlestickData(
              label: 'Tue',
              open: 14,
              high: 15,
              low: 9,
              close: 11,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CustomPaint), findsWidgets);
    expect(find.byType(AppCandlestickChart), findsOneWidget);
  });

  testWidgets('candlestick keyboard activation returns current candle', (
    tester,
  ) async {
    AppCandlestickChartHit? hit;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppCandlestickChart(
          autofocus: true,
          data: const <AppCandlestickData>[
            AppCandlestickData(open: 10, high: 16, low: 8, close: 14),
            AppCandlestickData(open: 14, high: 18, low: 12, close: 17),
          ],
          onCandleTap: (value) => hit = value,
        ),
      ),
    );
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);

    expect(hit?.index, 0);
    expect(hit?.data.close, 14);
  });
}
