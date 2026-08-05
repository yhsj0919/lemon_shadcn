import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('chart export boundary returns PNG bytes', (tester) async {
    final controller = AppChartExportController();
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Center(
          child: SizedBox(
            width: 200,
            height: 120,
            child: AppChartExportBoundary(
              controller: controller,
              child: const ColoredBox(color: Colors.blue),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(controller.attached, isTrue);
    final bytes = await tester.runAsync(
      () => controller.capturePng(pixelRatio: 1),
    );
    expect(bytes, isNotEmpty);
    expect(bytes!.take(8), <int>[137, 80, 78, 71, 13, 10, 26, 10]);
  });

  testWidgets('chart export controller detaches with its boundary', (
    tester,
  ) async {
    final controller = AppChartExportController();
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppChartExportBoundary(
          controller: controller,
          child: const SizedBox(width: 20, height: 20),
        ),
      ),
    );
    expect(controller.attached, isTrue);

    await tester.pumpWidget(const SizedBox());
    expect(controller.attached, isFalse);
    expect(controller.capturePng(), throwsStateError);
  });
}
