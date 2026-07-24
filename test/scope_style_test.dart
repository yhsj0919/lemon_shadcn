import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('scope supplies a non-fallback default text style', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Text('Hosted text'),
      ),
    );

    final context = tester.element(find.text('Hosted text'));
    final style = material.DefaultTextStyle.of(context).style;

    expect(material.Material.of(context), isNotNull);
    expect(
      style.decoration,
      isNot(
        material.TextDecoration.combine([
          material.TextDecoration.underline,
          material.TextDecoration.overline,
        ]),
      ),
    );
    expect(style.color, isNotNull);
  });
}
