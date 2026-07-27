import 'dart:ui' show Color, Offset;

import 'package:flutter/foundation.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_visual_style.dart';

typedef AppErrorPresenter =
    String Function(Object error, StackTrace? stackTrace);

/// Built-in visual baselines. Presets only compose public theme tokens, so
/// applications can safely refine the result with [AppThemeConfig.copyWith].
enum AppThemePreset { standard, apple, fluent, material }

@immutable
class AppControlMetrics {
  const AppControlMetrics({
    this.height = 36,
    this.horizontalPadding = 12,
    this.iconSize = 16,
    this.contentGap = 8,
    this.textAreaHeight = 100,
  }) : assert(height > 0),
       assert(horizontalPadding >= 0),
       assert(iconSize > 0),
       assert(contentGap >= 0),
       assert(textAreaHeight > 0);

  final double height;
  final double horizontalPadding;
  final double iconSize;
  final double contentGap;
  final double textAreaHeight;
}

@immutable
class AppMotionTheme {
  const AppMotionTheme({
    this.enabled = true,
    this.duration = const Duration(milliseconds: 150),
    this.loadingDelay = const Duration(milliseconds: 120),
    this.minimumLoadingDuration = const Duration(milliseconds: 250),
    this.hoverScale = 1.015,
    this.pressedScale = 0.985,
    this.hoverOffset = const Offset(0, -2),
    this.depthPerspective = 0.0012,
    this.depthDuration = const Duration(milliseconds: 320),
    this.depthTiltDuration = const Duration(milliseconds: 100),
    this.depthPressDuration = const Duration(milliseconds: 150),
    this.depthRotateY = 0.14,
    this.depthOffsetY = -10,
    this.depthTranslateZ = 18,
    this.depthPressAmount = 0.42,
  });

  final bool enabled;
  final Duration duration;
  final Duration loadingDelay;
  final Duration minimumLoadingDuration;
  final double hoverScale;
  final double pressedScale;
  final Offset hoverOffset;
  final double depthPerspective;
  final Duration depthDuration;
  final Duration depthTiltDuration;
  final Duration depthPressDuration;
  final double depthRotateY;
  final double depthOffsetY;
  final double depthTranslateZ;
  final double depthPressAmount;
}

enum AppShadowColorMode { auto, background, border, accent, primary, custom }

@immutable
class AppShadowTheme {
  const AppShadowTheme({
    this.enabled = true,
    this.colorMode = AppShadowColorMode.auto,
    this.ambientOpacity = 0.06,
    this.colorOpacity = 0.18,
    this.darkColorOpacity = 0.24,
    this.blurRadius = 18,
    this.spreadRadius = -4,
    this.offset = const Offset(0, 6),
  });

  const AppShadowTheme.none()
    : enabled = false,
      colorMode = AppShadowColorMode.auto,
      ambientOpacity = 0,
      colorOpacity = 0,
      darkColorOpacity = 0,
      blurRadius = 0,
      spreadRadius = 0,
      offset = Offset.zero;

  final bool enabled;
  final AppShadowColorMode colorMode;
  final double ambientOpacity;
  final double colorOpacity;
  final double darkColorOpacity;
  final double blurRadius;
  final double spreadRadius;
  final Offset offset;
}

@immutable
class AppThemeConfig {
  AppThemeConfig({
    shad.ThemeData? lightTheme,
    shad.ThemeData? darkTheme,
    this.themeMode = shad.ThemeMode.system,
    this.motion = const AppMotionTheme(),
    this.shadows = const AppShadowTheme(),
    this.controls = const AppControlMetrics(),
    this.controlPalette,
    this.errorPresenter,
    this.enableScrollInterception = false,
  }) : lightTheme = lightTheme ?? LemonThemes.light,
       darkTheme = darkTheme ?? LemonThemes.dark;

  factory AppThemeConfig.standard({
    double radius = 0.5,
    shad.ThemeMode themeMode = shad.ThemeMode.system,
    AppMotionTheme motion = const AppMotionTheme(),
    AppShadowTheme shadows = const AppShadowTheme(),
    AppControlMetrics controls = const AppControlMetrics(),
    AppVisualPalette? controlPalette,
    AppErrorPresenter? errorPresenter,
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
      shadows: shadows,
      controls: controls,
      controlPalette: controlPalette,
      errorPresenter: errorPresenter,
    );
  }

  factory AppThemeConfig.preset(
    AppThemePreset preset, {
    shad.ThemeMode themeMode = shad.ThemeMode.system,
    AppErrorPresenter? errorPresenter,
    bool enableScrollInterception = false,
  }) {
    final config = switch (preset) {
      AppThemePreset.standard => AppThemeConfig.standard(themeMode: themeMode),
      AppThemePreset.apple => AppThemeConfig(
        lightTheme: shad.ThemeData(
          colorScheme: _accentScheme(
            shad.ThemeMode.light,
            const Color(0xff007aff),
          ),
          radius: 0.75,
        ),
        darkTheme: shad.ThemeData.dark(
          colorScheme: _accentScheme(
            shad.ThemeMode.dark,
            const Color(0xff0a84ff),
          ),
          radius: 0.75,
        ),
        themeMode: themeMode,
        controls: const AppControlMetrics(
          height: 36,
          horizontalPadding: 14,
          iconSize: 16,
          contentGap: 8,
        ),
        motion: const AppMotionTheme(
          duration: Duration(milliseconds: 220),
          hoverScale: 1.01,
          pressedScale: 0.98,
          hoverOffset: Offset(0, -1),
        ),
        shadows: const AppShadowTheme(
          ambientOpacity: 0.05,
          colorOpacity: 0.12,
          darkColorOpacity: 0.2,
          blurRadius: 22,
          spreadRadius: -6,
          offset: Offset(0, 8),
        ),
      ),
      AppThemePreset.fluent => AppThemeConfig(
        lightTheme: shad.ThemeData(
          colorScheme: shad.ColorSchemes.slate(shad.ThemeMode.light),
          radius: 0.25,
        ),
        darkTheme: shad.ThemeData.dark(
          colorScheme: shad.ColorSchemes.slate(shad.ThemeMode.dark),
          radius: 0.25,
        ),
        themeMode: themeMode,
        controls: const AppControlMetrics(
          height: 36,
          horizontalPadding: 10,
          iconSize: 16,
          contentGap: 6,
        ),
        motion: const AppMotionTheme(
          duration: Duration(milliseconds: 120),
          hoverScale: 1,
          pressedScale: 0.99,
          hoverOffset: Offset.zero,
        ),
        shadows: const AppShadowTheme(
          ambientOpacity: 0.04,
          colorOpacity: 0.08,
          darkColorOpacity: 0.16,
          blurRadius: 10,
          spreadRadius: -3,
          offset: Offset(0, 3),
        ),
      ),
      AppThemePreset.material => AppThemeConfig(
        lightTheme: shad.ThemeData(
          colorScheme: _accentScheme(
            shad.ThemeMode.light,
            const Color(0xff6750a4),
          ),
          radius: 0.75,
        ),
        darkTheme: shad.ThemeData.dark(
          colorScheme: _accentScheme(
            shad.ThemeMode.dark,
            const Color(0xffd0bcff),
            foreground: const Color(0xff381e72),
          ),
          radius: 0.75,
        ),
        themeMode: themeMode,
        controls: const AppControlMetrics(
          height: 40,
          horizontalPadding: 16,
          iconSize: 18,
          contentGap: 8,
        ),
        motion: const AppMotionTheme(
          duration: Duration(milliseconds: 200),
          hoverScale: 1.01,
          pressedScale: 0.97,
          hoverOffset: Offset(0, -1),
        ),
        shadows: const AppShadowTheme(
          ambientOpacity: 0.08,
          colorOpacity: 0.16,
          darkColorOpacity: 0.24,
          blurRadius: 14,
          spreadRadius: -3,
          offset: Offset(0, 5),
        ),
      ),
    };
    return config.copyWith(
      errorPresenter: errorPresenter,
      enableScrollInterception: enableScrollInterception,
    );
  }

  final shad.ThemeData lightTheme;
  final shad.ThemeData darkTheme;
  final shad.ThemeMode themeMode;
  final AppMotionTheme motion;
  final AppShadowTheme shadows;
  final AppControlMetrics controls;
  final AppVisualPalette? controlPalette;
  final AppErrorPresenter? errorPresenter;
  final bool enableScrollInterception;

  AppThemeConfig copyWith({
    shad.ThemeData? lightTheme,
    shad.ThemeData? darkTheme,
    shad.ThemeMode? themeMode,
    AppMotionTheme? motion,
    AppShadowTheme? shadows,
    AppControlMetrics? controls,
    AppVisualPalette? controlPalette,
    AppErrorPresenter? errorPresenter,
    bool? enableScrollInterception,
  }) {
    return AppThemeConfig(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeMode: themeMode ?? this.themeMode,
      motion: motion ?? this.motion,
      shadows: shadows ?? this.shadows,
      controls: controls ?? this.controls,
      controlPalette: controlPalette ?? this.controlPalette,
      errorPresenter: errorPresenter ?? this.errorPresenter,
      enableScrollInterception:
          enableScrollInterception ?? this.enableScrollInterception,
    );
  }
}

shad.ColorScheme _accentScheme(
  shad.ThemeMode mode,
  Color primary, {
  Color foreground = const Color(0xffffffff),
}) {
  return shad.ColorSchemes.slate(mode).copyWith(
    primary: () => primary,
    primaryForeground: () => foreground,
    ring: () => primary,
  );
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
