import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('tooltip surface uses global spacing and size tokens', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: AppTooltipSurface(
            key: material.Key('tooltip-surface'),
            child: material.Text('重启'),
          ),
        ),
      ),
    );

    final surface = find.byKey(const material.Key('tooltip-surface'));
    final margin = tester.widget<material.Padding>(
      find.descendant(
        of: surface,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is material.Padding &&
              widget.padding == const material.EdgeInsets.all(7),
        ),
      ),
    );
    final width = tester.widget<material.ConstrainedBox>(
      find.descendant(
        of: surface,
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is material.ConstrainedBox &&
              widget.constraints.maxWidth == 240,
        ),
      ),
    );
    expect(margin.padding, const material.EdgeInsets.all(7));
    expect(width.constraints.maxWidth, 240);
    expect(find.text('重启'), findsOneWidget);
  });
}
