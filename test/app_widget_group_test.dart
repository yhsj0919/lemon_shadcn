import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('plain group preserves children and inserts spacing', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: AppWidgetGroup.horizontal(
            mode: AppWidgetGroupMode.plain,
            spacing: 12,
            children: [
              SizedBox(key: Key('first'), width: 20, height: 20),
              SizedBox(key: Key('second'), width: 20, height: 20),
            ],
          ),
        ),
      ),
    );

    final first = tester.getRect(find.byKey(const Key('first')));
    final second = tester.getRect(find.byKey(const Key('second')));
    expect(second.left - first.right, 12);
  });

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
