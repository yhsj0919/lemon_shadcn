import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test('exposes package metadata', () {
    expect(LemonShadcn.packageName, 'lemon_shadcn');
    expect(LemonShadcn.version, '0.0.1');
  });

  test('provides light and dark theme tokens', () {
    expect(LemonThemes.light.colorScheme, ColorSchemes.zinc(ThemeMode.light));
    expect(LemonThemes.dark.colorScheme, ColorSchemes.zinc(ThemeMode.dark));
  });
}
