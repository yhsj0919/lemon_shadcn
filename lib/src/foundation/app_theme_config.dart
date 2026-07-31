import 'dart:ui' show Color, Offset;

import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/widgets.dart' show Widget;

import '../components/display/app_text.dart';
import 'app_theme_aliases.dart';
import 'app_visual_style.dart';

final _appTypography = AppTypography.system();

typedef AppErrorPresenter =
    String Function(Object error, StackTrace? stackTrace);

/// Wraps the application content with optional component-specific themes.
typedef AppThemeWrapper = Widget Function(Widget child);

/// Built-in visual baselines. Presets only compose public theme tokens, so
/// applications can safely refine the result with [AppThemeConfig.copyWith].
enum AppThemePreset { standard, apple, fluent, material }

@immutable
class AppControlMetrics {
  const AppControlMetrics({
    this.height = 34,
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
    this.ambientOpacity = 0.03,
    this.colorOpacity = 0.10,
    this.darkColorOpacity = 0.16,
    this.blurRadius = 14,
    this.spreadRadius = -5,
    this.offset = const Offset(0, 4),
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
    AppThemeData? lightTheme,
    AppThemeData? darkTheme,
    this.themeMode = AppThemeMode.system,
    this.motion = const AppMotionTheme(),
    this.shadows = const AppShadowTheme(),
    this.controls = const AppControlMetrics(),
    this.controlPalette,
    this.textTheme,
    this.errorPresenter,
    this.enableScrollInterception = false,
    this.componentThemeWrapper,
  }) : lightTheme = lightTheme ?? LemonThemes.light,
       darkTheme = darkTheme ?? LemonThemes.dark;

  /// Zinc baseline with optional brand [primary] (and matching ring).
  ///
  /// Prefer this over rebuilding both [lightTheme]/[darkTheme] via
  /// [copyWith] when only the product accent changes:
  ///
  /// ```dart
  /// AppThemeConfig.standard(primary: Color(0xFF2563EB));
  /// ```
  ///
  /// Default [controls] height is 34 — override only when the product needs a
  /// different control size, not as a required setup step.
  factory AppThemeConfig.standard({
    Color? primary,
    Color primaryForeground = const Color(0xffffffff),
    double radius = 0.5,
    AppThemeMode themeMode = AppThemeMode.system,
    AppMotionTheme motion = const AppMotionTheme(),
    AppShadowTheme shadows = const AppShadowTheme(),
    AppControlMetrics controls = const AppControlMetrics(),
    AppVisualPalette? controlPalette,
    AppTextTheme? textTheme,
    AppErrorPresenter? errorPresenter,
  }) {
    AppColorScheme scheme(AppThemeMode mode) {
      final base = AppColorSchemes.zinc(mode);
      if (primary == null) return base;
      return base.copyWith(
        primary: () => primary,
        primaryForeground: () => primaryForeground,
        ring: () => primary,
      );
    }

    return AppThemeConfig(
      lightTheme: AppThemeData(
        colorScheme: scheme(AppThemeMode.light),
        radius: radius,
        typography: _appTypography,
      ),
      darkTheme: AppThemeData.dark(
        colorScheme: scheme(AppThemeMode.dark),
        radius: radius,
        typography: _appTypography,
      ),
      themeMode: themeMode,
      motion: motion,
      shadows: shadows,
      controls: controls,
      controlPalette: controlPalette,
      textTheme: textTheme,
      errorPresenter: errorPresenter,
    );
  }

  factory AppThemeConfig.preset(
    AppThemePreset preset, {
    AppThemeMode themeMode = AppThemeMode.system,
    AppErrorPresenter? errorPresenter,
    bool enableScrollInterception = false,
  }) {
    final config = switch (preset) {
      AppThemePreset.standard => AppThemeConfig.standard(themeMode: themeMode),
      AppThemePreset.apple => AppThemeConfig(
        lightTheme: AppThemeData(
          colorScheme: _accentScheme(
            AppThemeMode.light,
            const Color(0xff007aff),
          ),
          radius: 0.75,
          typography: _appTypography,
        ),
        darkTheme: AppThemeData.dark(
          colorScheme: _accentScheme(
            AppThemeMode.dark,
            const Color(0xff0a84ff),
          ),
          radius: 0.75,
          typography: _appTypography,
        ),
        themeMode: themeMode,
        controls: const AppControlMetrics(
          height: 34,
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
        lightTheme: AppThemeData(
          colorScheme: AppColorSchemes.slate(AppThemeMode.light),
          radius: 0.25,
          typography: _appTypography,
        ),
        darkTheme: AppThemeData.dark(
          colorScheme: AppColorSchemes.slate(AppThemeMode.dark),
          radius: 0.25,
          typography: _appTypography,
        ),
        themeMode: themeMode,
        controls: const AppControlMetrics(
          height: 34,
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
        lightTheme: AppThemeData(
          colorScheme: _accentScheme(
            AppThemeMode.light,
            const Color(0xff6750a4),
          ),
          radius: 0.75,
          typography: _appTypography,
        ),
        darkTheme: AppThemeData.dark(
          colorScheme: _accentScheme(
            AppThemeMode.dark,
            const Color(0xffd0bcff),
            foreground: const Color(0xff381e72),
          ),
          radius: 0.75,
          typography: _appTypography,
        ),
        themeMode: themeMode,
        controls: const AppControlMetrics(
          height: 36,
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

  final AppThemeData lightTheme;
  final AppThemeData darkTheme;
  final AppThemeMode themeMode;
  final AppMotionTheme motion;
  final AppShadowTheme shadows;
  final AppControlMetrics controls;
  final AppVisualPalette? controlPalette;
  final AppTextTheme? textTheme;
  final AppErrorPresenter? errorPresenter;
  final bool enableScrollInterception;
  final AppThemeWrapper? componentThemeWrapper;

  AppThemeConfig copyWith({
    AppThemeData? lightTheme,
    AppThemeData? darkTheme,
    AppThemeMode? themeMode,
    AppMotionTheme? motion,
    AppShadowTheme? shadows,
    AppControlMetrics? controls,
    AppVisualPalette? controlPalette,
    AppTextTheme? textTheme,
    bool clearTextTheme = false,
    AppErrorPresenter? errorPresenter,
    bool? enableScrollInterception,
    AppThemeWrapper? componentThemeWrapper,
    bool clearComponentThemeWrapper = false,
  }) {
    return AppThemeConfig(
      lightTheme: lightTheme ?? this.lightTheme,
      darkTheme: darkTheme ?? this.darkTheme,
      themeMode: themeMode ?? this.themeMode,
      motion: motion ?? this.motion,
      shadows: shadows ?? this.shadows,
      controls: controls ?? this.controls,
      controlPalette: controlPalette ?? this.controlPalette,
      textTheme: clearTextTheme ? null : (textTheme ?? this.textTheme),
      errorPresenter: errorPresenter ?? this.errorPresenter,
      enableScrollInterception:
          enableScrollInterception ?? this.enableScrollInterception,
      componentThemeWrapper: clearComponentThemeWrapper
          ? null
          : (componentThemeWrapper ?? this.componentThemeWrapper),
    );
  }
}

AppColorScheme _accentScheme(
  AppThemeMode mode,
  Color primary, {
  Color foreground = const Color(0xffffffff),
}) {
  return AppColorSchemes.slate(mode).copyWith(
    primary: () => primary,
    primaryForeground: () => foreground,
    ring: () => primary,
  );
}

abstract final class LemonThemes {
  static final AppThemeData light = AppThemeData(
    colorScheme: AppColorSchemes.zinc(AppThemeMode.light),
    radius: 0.5,
    typography: _appTypography,
  );

  static final AppThemeData dark = AppThemeData.dark(
    colorScheme: AppColorSchemes.zinc(AppThemeMode.dark),
    radius: 0.5,
    typography: _appTypography,
  );
}
