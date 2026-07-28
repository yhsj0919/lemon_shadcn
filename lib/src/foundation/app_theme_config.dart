import 'dart:ui' show Color, Offset;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart' show TextStyle, Widget;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_visual_style.dart';

TextStyle _windowsUiStyle(TextStyle source) => TextStyle(
  inherit: source.inherit,
  fontFamily: 'Microsoft YaHei UI',
  fontFamilyFallback: const ['Microsoft YaHei', 'Segoe UI'],
  fontSize: source.fontSize,
  fontWeight: source.fontWeight,
  fontStyle: source.fontStyle,
  letterSpacing: source.letterSpacing,
  wordSpacing: source.wordSpacing,
  height: source.height,
  decoration: source.decoration,
);

shad.Typography _resolveTypography() {
  const source = shad.Typography.geist();
  if (defaultTargetPlatform != TargetPlatform.windows) return source;
  TextStyle ui(TextStyle style) => _windowsUiStyle(style);
  return source.copyWith(
    sans: () => ui(source.sans),
    mono: () => ui(source.mono),
    xSmall: () => ui(source.xSmall),
    small: () => ui(source.small).copyWith(height: 1.25),
    base: () => ui(source.base),
    large: () => ui(source.large),
    xLarge: () => ui(source.xLarge),
    x2Large: () => ui(source.x2Large),
    x3Large: () => ui(source.x3Large),
    x4Large: () => ui(source.x4Large),
    x5Large: () => ui(source.x5Large),
    x6Large: () => ui(source.x6Large),
    x7Large: () => ui(source.x7Large),
    x8Large: () => ui(source.x8Large),
    x9Large: () => ui(source.x9Large),
    thin: () => ui(source.thin),
    extraLight: () => ui(source.extraLight),
    light: () => ui(source.light),
    normal: () => ui(source.normal),
    medium: () => ui(source.medium),
    semiBold: () => ui(source.semiBold),
    bold: () => ui(source.bold),
    extraBold: () => ui(source.extraBold),
    black: () => ui(source.black),
    italic: () => ui(source.italic),
    h1: () => ui(source.h1),
    h2: () => ui(source.h2),
    h3: () => ui(source.h3),
    h4: () => ui(source.h4),
    p: () => ui(source.p),
    blockQuote: () => ui(source.blockQuote),
    inlineCode: () => ui(source.inlineCode),
    lead: () => ui(source.lead),
    textLarge: () => ui(source.textLarge),
    textSmall: () => ui(source.textSmall),
    textMuted: () => ui(source.textMuted),
  );
}

final _appTypography = _resolveTypography();

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
    shad.ThemeData? lightTheme,
    shad.ThemeData? darkTheme,
    this.themeMode = shad.ThemeMode.system,
    this.motion = const AppMotionTheme(),
    this.shadows = const AppShadowTheme(),
    this.controls = const AppControlMetrics(),
    this.controlPalette,
    this.errorPresenter,
    this.enableScrollInterception = false,
    this.componentThemeWrapper,
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
        typography: _appTypography,
      ),
      darkTheme: shad.ThemeData.dark(
        colorScheme: shad.ColorSchemes.zinc(shad.ThemeMode.dark),
        radius: radius,
        typography: _appTypography,
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
          typography: _appTypography,
        ),
        darkTheme: shad.ThemeData.dark(
          colorScheme: _accentScheme(
            shad.ThemeMode.dark,
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
        lightTheme: shad.ThemeData(
          colorScheme: shad.ColorSchemes.slate(shad.ThemeMode.light),
          radius: 0.25,
          typography: _appTypography,
        ),
        darkTheme: shad.ThemeData.dark(
          colorScheme: shad.ColorSchemes.slate(shad.ThemeMode.dark),
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
        lightTheme: shad.ThemeData(
          colorScheme: _accentScheme(
            shad.ThemeMode.light,
            const Color(0xff6750a4),
          ),
          radius: 0.75,
          typography: _appTypography,
        ),
        darkTheme: shad.ThemeData.dark(
          colorScheme: _accentScheme(
            shad.ThemeMode.dark,
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

  final shad.ThemeData lightTheme;
  final shad.ThemeData darkTheme;
  final shad.ThemeMode themeMode;
  final AppMotionTheme motion;
  final AppShadowTheme shadows;
  final AppControlMetrics controls;
  final AppVisualPalette? controlPalette;
  final AppErrorPresenter? errorPresenter;
  final bool enableScrollInterception;
  final AppThemeWrapper? componentThemeWrapper;

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
      errorPresenter: errorPresenter ?? this.errorPresenter,
      enableScrollInterception:
          enableScrollInterception ?? this.enableScrollInterception,
      componentThemeWrapper: clearComponentThemeWrapper
          ? null
          : (componentThemeWrapper ?? this.componentThemeWrapper),
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
    typography: _appTypography,
  );

  static final shad.ThemeData dark = shad.ThemeData.dark(
    colorScheme: shad.ColorSchemes.zinc(shad.ThemeMode.dark),
    radius: 0.5,
    typography: _appTypography,
  );
}
