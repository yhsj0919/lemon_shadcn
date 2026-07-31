import 'package:flutter/foundation.dart' as foundation;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  test('Windows typography uses one Chinese UI font for every token', () {
    if (foundation.defaultTargetPlatform != foundation.TargetPlatform.windows) {
      return;
    }
    final typography = AppThemeConfig.standard().lightTheme.typography;
    final styles = [
      typography.sans,
      typography.mono,
      typography.xSmall,
      typography.small,
      typography.base,
      typography.large,
      typography.xLarge,
      typography.h1,
      typography.h2,
      typography.h3,
      typography.h4,
      typography.p,
      typography.inlineCode,
      typography.textLarge,
      typography.textSmall,
      typography.textMuted,
    ];

    expect(styles.map((style) => style.fontFamily).toSet(), {
      'Microsoft YaHei UI',
    });
  });

  testWidgets('scope supplies a non-fallback default text style', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Text('Hosted text'),
      ),
    );

    final context = tester.element(find.text('Hosted text'));
    final style = DefaultTextStyle.of(context).style;

    expect(Material.of(context), isNotNull);
    expect(
      style.decoration,
      isNot(
        TextDecoration.combine([
          TextDecoration.underline,
          TextDecoration.overline,
        ]),
      ),
    );
    expect(style.color, isNotNull);
  });

  testWidgets('control metrics feed upstream button component themes', (
    tester,
  ) async {
    shad.PrimaryButtonTheme? buttonTheme;
    BuildContext? themedContext;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controls: const AppControlMetrics(
              horizontalPadding: 21,
              iconSize: 19,
            ),
          ),
        ),
        home: Builder(
          builder: (context) {
            themedContext = context;
            buttonTheme = shad.ComponentTheme.maybeOf<shad.PrimaryButtonTheme>(context);
            return AppButton.primary(
              onPressed: () {},
              child: const Text('Metrics'),
            );
          },
        ),
      ),
    );

    final padding = buttonTheme!
        .padding!(
          themedContext!,
          const <WidgetState>{},
          const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        )
        .resolve(TextDirection.ltr);
    final iconTheme = buttonTheme!.iconTheme!(
      themedContext!,
      const <WidgetState>{},
      const IconThemeData(size: 12),
    );
    expect(padding, const EdgeInsets.fromLTRB(21, 3, 21, 3));
    expect(iconTheme.size, 19);
  });
}
