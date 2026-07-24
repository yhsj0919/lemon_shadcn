import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

@immutable
class AppMotionTheme {
  const AppMotionTheme({
    this.enabled = true,
    this.duration = const Duration(milliseconds: 150),
    this.loadingDelay = const Duration(milliseconds: 120),
    this.minimumLoadingDuration = const Duration(milliseconds: 250),
  });

  final bool enabled;
  final Duration duration;
  final Duration loadingDelay;
  final Duration minimumLoadingDuration;
}

@immutable
class AppThemeConfig {
  AppThemeConfig({
    shad.ThemeData? lightTheme,
    shad.ThemeData? darkTheme,
    this.themeMode = shad.ThemeMode.system,
    this.motion = const AppMotionTheme(),
    this.enableScrollInterception = false,
  }) : lightTheme = lightTheme ?? LemonThemes.light,
       darkTheme = darkTheme ?? LemonThemes.dark;

  factory AppThemeConfig.standard({
    double radius = 0.5,
    shad.ThemeMode themeMode = shad.ThemeMode.system,
    AppMotionTheme motion = const AppMotionTheme(),
  }) {
    return AppThemeConfig(
      lightTheme: shad.ThemeData(
        colorScheme: shad.ColorSchemes.zinc(shad.ThemeMode.light),
        radius: radius,
      ),
      darkTheme: shad.ThemeData.dark(
        colorScheme: shad.ColorSchemes.zinc(shad.ThemeMode.dark),
        radius: radius,
      ),
      themeMode: themeMode,
      motion: motion,
    );
  }

  final shad.ThemeData lightTheme;
  final shad.ThemeData darkTheme;
  final shad.ThemeMode themeMode;
  final AppMotionTheme motion;
  final bool enableScrollInterception;
}

abstract final class LemonThemes {
  static final shad.ThemeData light = shad.ThemeData(
    colorScheme: shad.ColorSchemes.zinc(shad.ThemeMode.light),
    radius: 0.5,
  );

  static final shad.ThemeData dark = shad.ThemeData.dark(
    colorScheme: shad.ColorSchemes.zinc(shad.ThemeMode.dark),
    radius: 0.5,
  );
}
