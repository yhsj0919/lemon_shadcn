import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart' show BoxShadow, Color, Offset;
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
    this.height = 32,
    this.buttonHeight = 31,
    this.horizontalPadding = 12,
    this.iconSize = 16,
    this.contentGap = 8,
    this.textAreaHeight = 100,
  }) : assert(height > 0),
       assert(buttonHeight > 0),
       assert(horizontalPadding >= 0),
       assert(iconSize > 0),
       assert(contentGap >= 0),
       assert(textAreaHeight > 0);

  final double height;

  /// Default (`normal`) button height in logical pixels. At the standard
  /// desktop scale, 31 logical pixels keeps the 60px content height separate
  /// from the surrounding border.
  /// Other button sizes preserve the 44 / 52 / 60 / 68 ratio.
  final double buttonHeight;
  final double horizontalPadding;
  final double iconSize;
  final double contentGap;
  final double textAreaHeight;

  /// Content box used by bordered controls that sit inside the shared slot.
  double get borderedContentHeight => height - 1;
}

/// Shared DataGrid dimensions. Defaults preserve the standard grid appearance
/// while keeping every grid surface on one configurable token set.
@immutable
class AppDataGridMetrics {
  const AppDataGridMetrics({
    this.rowHeight = 40,
    this.columnHeight = 40,
    this.filterHeight = 48,
    this.footerHeight = 40,
    this.horizontalPadding = 12,
    this.fontSize = 14,
  }) : assert(rowHeight > 0),
       assert(columnHeight > 0),
       assert(filterHeight > 0),
       assert(footerHeight > 0),
       assert(horizontalPadding >= 0),
       assert(fontSize > 0);

  final double rowHeight;
  final double columnHeight;
  final double filterHeight;
  final double footerHeight;
  final double horizontalPadding;
  final double fontSize;
}

/// Shared interactive motion tokens for [AppButton], [AppIconButton], and
/// [AppMotion].
///
/// Configure once via [AppMotionTheme.tokens].
@immutable
class AppMotionTokens {
  const AppMotionTokens({
    this.hoverOffset = const Offset(0, -3),
    this.hoverScale = 1.015,
    this.pressedScale = 0.96,
    this.pressExtraLift = 1.5,
    this.unhoveredPressNudge = 1.0,
    this.hoverDuration = const Duration(milliseconds: 240),
    this.pressDuration = const Duration(milliseconds: 140),
    this.hoverShadowOpacity = 0.14,
  });

  static const standard = AppMotionTokens();

  final Offset hoverOffset;
  final double hoverScale;
  final double pressedScale;
  final double pressExtraLift;
  final double unhoveredPressNudge;
  final Duration hoverDuration;
  final Duration pressDuration;
  final double hoverShadowOpacity;

  /// Hover elevation shadow; [strength] 0..1 keeps list shape stable for lerps.
  List<BoxShadow> hoverShadow(Color color, double strength) {
    final t = strength.clamp(0.0, 1.0);
    return [
      BoxShadow(
        color: color.withValues(alpha: hoverShadowOpacity * t),
        blurRadius: 10 + 6 * t,
        spreadRadius: -4,
        offset: Offset(0, 3 + 3 * t),
      ),
    ];
  }

  AppMotionTokens copyWith({
    Offset? hoverOffset,
    double? hoverScale,
    double? pressedScale,
    double? pressExtraLift,
    double? unhoveredPressNudge,
    Duration? hoverDuration,
    Duration? pressDuration,
    double? hoverShadowOpacity,
  }) {
    return AppMotionTokens(
      hoverOffset: hoverOffset ?? this.hoverOffset,
      hoverScale: hoverScale ?? this.hoverScale,
      pressedScale: pressedScale ?? this.pressedScale,
      pressExtraLift: pressExtraLift ?? this.pressExtraLift,
      unhoveredPressNudge: unhoveredPressNudge ?? this.unhoveredPressNudge,
      hoverDuration: hoverDuration ?? this.hoverDuration,
      pressDuration: pressDuration ?? this.pressDuration,
      hoverShadowOpacity: hoverShadowOpacity ?? this.hoverShadowOpacity,
    );
  }
}

@immutable
class AppMotionTheme {
  const AppMotionTheme({
    this.enabled = true,
    this.loadingDelay = const Duration(milliseconds: 120),
    this.minimumLoadingDuration = const Duration(milliseconds: 250),
    this.depthPerspective = 0.0012,
    this.depthDuration = const Duration(milliseconds: 320),
    this.depthTiltDuration = const Duration(milliseconds: 100),
    this.depthPressDuration = const Duration(milliseconds: 150),
    this.depthRotateY = 0.14,
    this.depthOffsetY = -10,
    this.depthTranslateZ = 18,
    this.depthPressAmount = 0.42,
    this.tokens = const AppMotionTokens(),
    this.interactive = true,
  });

  final bool enabled;
  final Duration loadingDelay;
  final Duration minimumLoadingDuration;
  final double depthPerspective;
  final Duration depthDuration;
  final Duration depthTiltDuration;
  final Duration depthPressDuration;
  final double depthRotateY;
  final double depthOffsetY;
  final double depthTranslateZ;
  final double depthPressAmount;
  final AppMotionTokens tokens;

  /// When true (default), [AppButton]s that omit config use interactive motion.
  final bool interactive;
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
    this.dataGrid = const AppDataGridMetrics(),
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
  /// Default [controls] height is 32 — override only when the product needs a
  /// different control size, not as a required setup step.
  factory AppThemeConfig.standard({
    Color? primary,
    Color primaryForeground = const Color(0xffffffff),
    double radius = 0.5,
    AppThemeMode themeMode = AppThemeMode.system,
    AppMotionTheme motion = const AppMotionTheme(),
    AppShadowTheme shadows = const AppShadowTheme(),
    AppControlMetrics controls = const AppControlMetrics(),
    AppDataGridMetrics dataGrid = const AppDataGridMetrics(),
    AppVisualPalette? controlPalette,
    AppTextTheme? textTheme,
    AppErrorPresenter? errorPresenter,
  }) {
    AppColorScheme scheme(AppThemeMode mode) {
      final base = AppColorSchemes.zinc(mode);
      final branded = primary == null
          ? base
          : base.copyWith(
              primary: () => primary,
              primaryForeground: () => primaryForeground,
              ring: () => primary,
            );
      return _flatInputScheme(branded);
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
      dataGrid: dataGrid,
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
          height: 32,
          horizontalPadding: 14,
          iconSize: 16,
          contentGap: 8,
        ),
        motion: const AppMotionTheme(
          tokens: AppMotionTokens(
            hoverOffset: Offset(0, -1),
            hoverScale: 1.01,
            pressedScale: 0.98,
            hoverDuration: Duration(milliseconds: 220),
          ),
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
          colorScheme: _flatInputScheme(
            AppColorSchemes.slate(AppThemeMode.light),
          ),
          radius: 0.25,
          typography: _appTypography,
        ),
        darkTheme: AppThemeData.dark(
          colorScheme: _flatInputScheme(
            AppColorSchemes.slate(AppThemeMode.dark),
          ),
          radius: 0.25,
          typography: _appTypography,
        ),
        themeMode: themeMode,
        controls: const AppControlMetrics(
          height: 32,
          horizontalPadding: 10,
          iconSize: 16,
          contentGap: 6,
        ),
        motion: const AppMotionTheme(
          tokens: AppMotionTokens(
            hoverOffset: Offset.zero,
            hoverScale: 1,
            pressedScale: 0.99,
            hoverDuration: Duration(milliseconds: 120),
            pressDuration: Duration(milliseconds: 100),
          ),
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
          height: 32,
          horizontalPadding: 16,
          iconSize: 18,
          contentGap: 8,
        ),
        motion: const AppMotionTheme(
          tokens: AppMotionTokens(
            hoverOffset: Offset(0, -1),
            hoverScale: 1.01,
            pressedScale: 0.97,
            hoverDuration: Duration(milliseconds: 200),
          ),
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
  final AppDataGridMetrics dataGrid;
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
    AppDataGridMetrics? dataGrid,
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
      dataGrid: dataGrid ?? this.dataGrid,
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
  return _flatInputScheme(
    AppColorSchemes.slate(mode).copyWith(
      primary: () => primary,
      primaryForeground: () => foreground,
      ring: () => primary,
    ),
  );
}

AppColorScheme _flatInputScheme(AppColorScheme scheme) =>
    scheme.copyWith(input: () => scheme.background);

abstract final class LemonThemes {
  static final AppThemeData light = AppThemeData(
    colorScheme: _flatInputScheme(AppColorSchemes.zinc(AppThemeMode.light)),
    radius: 0.5,
    typography: _appTypography,
  );

  static final AppThemeData dark = AppThemeData.dark(
    colorScheme: _flatInputScheme(AppColorSchemes.zinc(AppThemeMode.dark)),
    radius: 0.5,
    typography: _appTypography,
  );
}
