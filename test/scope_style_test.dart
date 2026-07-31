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
    final typography = AppTypography.system(
      platform: foundation.TargetPlatform.windows,
    );
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
      'Consolas',
    });
  });

  test('LemonThemes default typography uses AppTypography.system', () {
    if (foundation.defaultTargetPlatform != foundation.TargetPlatform.windows) {
      return;
    }
    expect(
      AppThemeConfig.standard().lightTheme.typography.sans.fontFamily,
      'Microsoft YaHei UI',
    );
  });

  test('AppThemeConfig.standard(primary) overrides zinc accent', () {
    const brand = Color(0xFF2563EB);
    final config = AppThemeConfig.standard(primary: brand);
    expect(config.lightTheme.colorScheme.primary, brand);
    expect(config.darkTheme.colorScheme.primary, brand);
    expect(config.lightTheme.colorScheme.ring, brand);
    expect(config.controls.height, 34);
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

  testWidgets('scope syncs Material primary and fontFamily', (tester) async {
    const brand = Color(0xFF0EA5E9);
    late ThemeData materialTheme;
    late shad.ThemeData shadTheme;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(primary: brand),
        ),
        home: Builder(
          builder: (context) {
            materialTheme = Theme.of(context);
            shadTheme = ShadcnTheme.of(context);
            return const Text('Synced');
          },
        ),
      ),
    );

    expect(materialTheme.colorScheme.primary, brand);
    expect(materialTheme.colorScheme.onPrimary, shadTheme.colorScheme.primaryForeground);
    final expectedFamily =
        shadTheme.typography.sans.fontFamily ??
        shadTheme.typography.sans.fontFamilyFallback?.first;
    expect(materialTheme.textTheme.bodyMedium?.fontFamily, expectedFamily);
  });

  testWidgets('syncMaterialTheme: false leaves Material primary alone', (
    tester,
  ) async {
    const brand = Color(0xFF0EA5E9);
    late Color materialPrimary;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.purple),
          useMaterial3: true,
        ),
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(primary: brand),
          syncMaterialTheme: false,
        ),
        home: Builder(
          builder: (context) {
            materialPrimary = Theme.of(context).colorScheme.primary;
            return const Text('Unsynced');
          },
        ),
      ),
    );

    expect(materialPrimary, isNot(brand));
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
