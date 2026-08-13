import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Shared soft-background calculation. Components keep their own color APIs
/// and presets, but derive tinted backgrounds with the same rule.
abstract final class AppSoftColor {
  static const double softLightOpacity = 0.14;
  static const double softDarkOpacity = 0.20;
  static const double selectionLightOpacity = 0.08;
  static const double selectionDarkOpacity = 0.12;
  static const double borderLightOpacity = 0.18;
  static const double borderDarkOpacity = 0.28;

  static Color background(
    shad.ThemeData theme,
    Color color, {
    double lightOpacity = softLightOpacity,
    double darkOpacity = softDarkOpacity,
  }) {
    final dark = theme.brightness == Brightness.dark;
    return Color.alphaBlend(
      color.withValues(alpha: dark ? darkOpacity : lightOpacity),
      theme.colorScheme.background,
    );
  }

  static Color selectionBackground(shad.ThemeData theme, Color color) =>
      background(
        theme,
        color,
        lightOpacity: selectionLightOpacity,
        darkOpacity: selectionDarkOpacity,
      );

  static Color border(shad.ThemeData theme, Color color) => background(
    theme,
    color,
    lightOpacity: borderLightOpacity,
    darkOpacity: borderDarkOpacity,
  );
}

enum AppSemanticTone { primary, secondary, info, success, warning, destructive }

@immutable
class AppSemanticPalette {
  const AppSemanticPalette({
    required this.solid,
    required this.onSolid,
    required this.softBackground,
    required this.foreground,
  });

  final Color solid;
  final Color onSolid;
  final Color softBackground;
  final Color foreground;

  static AppSemanticPalette resolve(
    shad.ThemeData theme,
    AppSemanticTone tone,
  ) {
    final dark = theme.brightness == Brightness.dark;
    return switch (tone) {
      AppSemanticTone.primary => custom(theme, theme.colorScheme.primary),
      AppSemanticTone.secondary => AppSemanticPalette(
        solid: theme.colorScheme.secondary,
        onSolid: theme.colorScheme.secondaryForeground,
        softBackground: theme.colorScheme.muted,
        foreground: theme.colorScheme.mutedForeground,
      ),
      AppSemanticTone.info =>
        dark
            ? const AppSemanticPalette(
                solid: Color(0xff2563eb),
                onSolid: Color(0xffffffff),
                softBackground: Color(0xff172554),
                foreground: Color(0xffbfdbfe),
              )
            : const AppSemanticPalette(
                solid: Color(0xff2563eb),
                onSolid: Color(0xffffffff),
                softBackground: Color(0xffeff6ff),
                foreground: Color(0xff1e40af),
              ),
      AppSemanticTone.success =>
        dark
            ? const AppSemanticPalette(
                solid: Color(0xff16a34a),
                onSolid: Color(0xffffffff),
                softBackground: Color(0xff052e16),
                foreground: Color(0xffbbf7d0),
              )
            : const AppSemanticPalette(
                solid: Color(0xff16a34a),
                onSolid: Color(0xffffffff),
                softBackground: Color(0xfff0fdf4),
                foreground: Color(0xff16a34a),
              ),
      AppSemanticTone.warning =>
        dark
            ? const AppSemanticPalette(
                solid: Color(0xfffbbf24),
                onSolid: Color(0xff1c1917),
                softBackground: Color(0xff451a03),
                foreground: Color(0xfffbbf24),
              )
            : const AppSemanticPalette(
                solid: Color(0xfff59e0b),
                onSolid: Color(0xff451a03),
                softBackground: Color(0xfffffbeb),
                foreground: Color(0xffd97706),
              ),
      AppSemanticTone.destructive =>
        dark
            ? AppSemanticPalette(
                solid: theme.colorScheme.destructive,
                onSolid: const Color(0xffffffff),
                softBackground: const Color(0xff450a0a),
                foreground: theme.colorScheme.destructive,
              )
            : AppSemanticPalette(
                solid: theme.colorScheme.destructive,
                onSolid: const Color(0xffffffff),
                softBackground: const Color(0xfffef2f2),
                foreground: theme.colorScheme.destructive,
              ),
    };
  }

  static AppSemanticPalette custom(shad.ThemeData theme, Color color) {
    return AppSemanticPalette(
      solid: color,
      onSolid: color.computeLuminance() > 0.48
          ? const Color(0xff000000)
          : const Color(0xffffffff),
      softBackground: AppSoftColor.background(theme, color),
      foreground: color,
    );
  }
}
