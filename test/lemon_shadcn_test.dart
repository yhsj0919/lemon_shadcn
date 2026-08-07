import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test('exposes package metadata', () {
    expect(LemonShadcn.packageName, 'lemon_shadcn');
    expect(LemonShadcn.version, '0.0.1');
  });

  test('provides light and dark theme tokens', () {
    expect(LemonThemes.light.colorScheme.brightness, Brightness.light);
    expect(LemonThemes.dark.colorScheme.brightness, Brightness.dark);
    expect(
      LemonThemes.light.colorScheme.input,
      LemonThemes.light.colorScheme.background,
    );
    expect(
      LemonThemes.dark.colorScheme.input,
      LemonThemes.dark.colorScheme.background,
    );
  });

  test('dark theme uses a bright readable destructive color', () {
    expect(LemonThemes.dark.colorScheme.destructive, const Color(0xffff5c5c));
  });

  test('theme presets expose distinct overridable baselines', () {
    final standard = AppThemeConfig.preset(AppThemePreset.standard);
    final apple = AppThemeConfig.preset(AppThemePreset.apple);
    final fluent = AppThemeConfig.preset(AppThemePreset.fluent);
    final material = AppThemeConfig.preset(AppThemePreset.material);

    expect(standard.controls.height, 32);
    expect(apple.lightTheme.colorScheme.primary, const Color(0xff007aff));
    expect(fluent.controls.height, 32);
    expect(material.controls.height, 32);

    final customized = apple.copyWith(
      controls: const AppControlMetrics(height: 44),
      shadows: const AppShadowTheme.none(),
    );
    expect(customized.controls.height, 44);
    expect(customized.shadows.enabled, isFalse);
    expect(customized.lightTheme, same(apple.lightTheme));
  });
}
