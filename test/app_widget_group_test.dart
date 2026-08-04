import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('vertical expanded group honors per-child flex factors', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 120,
            height: 120,
            child: AppWidgetGroup.vertical(
              expands: true,
              flexes: const [1, 2],
              children: const [
                ColoredBox(key: Key('first'), color: Colors.red),
                ColoredBox(key: Key('second'), color: Colors.blue),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(const Key('first'))).height, 40);
    expect(tester.getSize(find.byKey(const Key('second'))).height, 80);
  });
}
