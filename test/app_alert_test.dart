import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('custom alert derives its whole palette from one color', (
    tester,
  ) async {
    const color = Color(0xff7e22ce);
    final config = AppThemeConfig.standard(primary: const Color(0xff2563eb));
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(config: config),
        home: const AppAlert.custom(
          color: color,
          leading: Icon(Icons.info),
          title: Text('Custom alert'),
        ),
      ),
    );

    final componentThemeFinder = find.byWidgetPredicate(
      (widget) => widget is shad.ComponentTheme<shad.AlertTheme>,
    );
    final componentTheme = tester.widget<shad.ComponentTheme<shad.AlertTheme>>(
      componentThemeFinder,
    );
    expect(
      componentTheme.data.backgroundColor,
      Color.alphaBlend(
        color.withValues(alpha: 0.14),
        config.lightTheme.colorScheme.background,
      ),
    );
    expect(componentTheme.data.borderColor, color);

    final textContext = tester.element(find.text('Custom alert'));
    final iconContext = tester.element(find.byIcon(Icons.info));
    expect(DefaultTextStyle.of(textContext).style.color, color);
    expect(IconTheme.of(iconContext).color, color);
  });

  testWidgets('semantic alert color overrides its preset', (tester) async {
    const color = Color(0xff0891b2);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppAlert.warning(
          color: color,
          title: Text('Override warning'),
        ),
      ),
    );

    final componentTheme = tester.widget<shad.ComponentTheme<shad.AlertTheme>>(
      find.byWidgetPredicate(
        (widget) => widget is shad.ComponentTheme<shad.AlertTheme>,
      ),
    );
    expect(componentTheme.data.borderColor, color);
    expect(
      DefaultTextStyle.of(
        tester.element(find.text('Override warning')),
      ).style.color,
      color,
    );
  });
}
