import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  test('exposes package metadata', () {
    expect(LemonShadcn.packageName, 'lemon_shadcn');
    expect(LemonShadcn.version, '0.0.1');
  });

  test('provides light and dark theme tokens', () {
    expect(LemonThemes.light.colorScheme, shad.ColorSchemes.zinc(shad.ThemeMode.light));
    expect(LemonThemes.dark.colorScheme, shad.ColorSchemes.zinc(shad.ThemeMode.dark));
  });

  test('theme presets expose distinct overridable baselines', () {
    final standard = AppThemeConfig.preset(AppThemePreset.standard);
    final apple = AppThemeConfig.preset(AppThemePreset.apple);
    final fluent = AppThemeConfig.preset(AppThemePreset.fluent);
    final material = AppThemeConfig.preset(AppThemePreset.material);

    expect(standard.controls.height, 36);
    expect(apple.lightTheme.colorScheme.primary, const Color(0xff007aff));
    expect(fluent.controls.height, 36);
    expect(material.controls.height, 40);

    final customized = apple.copyWith(
      controls: const AppControlMetrics(height: 44),
      shadows: const AppShadowTheme.none(),
    );
    expect(customized.controls.height, 44);
    expect(customized.shadows.enabled, isFalse);
    expect(customized.lightTheme, same(apple.lightTheme));
  });
}
