import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  const tree = [
    AppCascadeOption(
      value: 1,
      label: 'Drinks',
      children: [
        AppCascadeOption(
          value: 11,
          label: 'Liquor',
          children: [AppCascadeOption(value: 111, label: 'Baijiu')],
        ),
        AppCascadeOption(value: 12, label: 'Tea'),
      ],
    ),
    AppCascadeOption(value: 2, label: 'Food'),
  ];

  Widget host(List<int> value, ValueChanged<List<int>> onChanged) =>
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Center(
          child: SizedBox(
            width: 240,
            child: AppCascadeSelect<int>(
              options: tree,
              value: value,
              hintText: 'Industry',
              onChanged: onChanged,
            ),
          ),
        ),
      );

  testWidgets('drills through levels and commits the leaf path', (
    tester,
  ) async {
    var value = <int>[];
    await tester.pumpWidget(host(value, (v) => value = v));

    await tester.tap(find.text('Industry'));
    await tester.pumpAndSettle();
    expect(find.text('Liquor'), findsNothing);

    await tester.tap(find.text('Drinks'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Liquor'));
    await tester.pumpAndSettle();
    expect(value, isEmpty);

    await tester.tap(find.text('Baijiu'));
    await tester.pumpAndSettle();
    expect(value, [1, 11, 111]);
    expect(find.text('Baijiu'), findsNothing);
  });

  testWidgets('trigger shows the full path', (tester) async {
    await tester.pumpWidget(host(const [1, 12], (_) {}));
    expect(find.text('Drinks / Tea'), findsOneWidget);
  });
}
