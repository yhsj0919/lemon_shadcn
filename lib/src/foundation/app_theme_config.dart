import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/painting.dart'
    show BoxShadow, Color, EdgeInsets, HSLColor, Offset;
import 'package:flutter/widgets.dart' show Brightness, BuildContext, Widget;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../components/display/app_text.dart';
import '../motion/app_page_transition.dart';
import 'app_shadow_types.dart';
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
    this.fontSize = 14,
    this.iconSize = 16,
    this.contentGap = 8,
    this.textAreaHeight = 100,
  }) : assert(height > 0),
       assert(buttonHeight > 0),
       assert(horizontalPadding >= 0),
       assert(fontSize > 0),
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
  final double fontSize;
  final double iconSize;
  final double contentGap;
  final double textAreaHeight;

  /// Content box used by bordered controls that sit inside the shared slot.
  double get borderedContentHeight => height - 1;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppControlMetrics &&
          height == other.height &&
          buttonHeight == other.buttonHeight &&
          horizontalPadding == other.horizontalPadding &&
          fontSize == other.fontSize &&
          iconSize == other.iconSize &&
          contentGap == other.contentGap &&
          textAreaHeight == other.textAreaHeight;

  @override
  int get hashCode => Object.hash(
    height,
    buttonHeight,
    horizontalPadding,
    fontSize,
    iconSize,
    contentGap,
    textAreaHeight,
  );
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

/// Shared motion timings for application tooltips, including chart tooltips.
@immutable
class AppTooltipTheme {
  const AppTooltipTheme({
    this.fadeDuration = const Duration(milliseconds: 140),
    this.moveDuration = const Duration(milliseconds: 120),
    this.waitDuration = const Duration(milliseconds: 400),
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.margin = 7,
    this.radius = 6,
    this.fontSize = 12,
    this.maxWidth = 240,
  });

  final Duration fadeDuration;
  final Duration moveDuration;
  final Duration waitDuration;
  final EdgeInsets padding;
  final double margin;
  final double radius;
  final double fontSize;
  final double maxWidth;

  AppTooltipTheme copyWith({
    Duration? fadeDuration,
    Duration? moveDuration,
    Duration? waitDuration,
    EdgeInsets? padding,
    double? margin,
    double? radius,
    double? fontSize,
    double? maxWidth,
  }) => AppTooltipTheme(
    fadeDuration: fadeDuration ?? this.fadeDuration,
    moveDuration: moveDuration ?? this.moveDuration,
    waitDuration: waitDuration ?? this.waitDuration,
    padding: padding ?? this.padding,
    margin: margin ?? this.margin,
    radius: radius ?? this.radius,
    fontSize: fontSize ?? this.fontSize,
    maxWidth: maxWidth ?? this.maxWidth,
  );
}

/// Shared chart appearance tokens. An empty [palette] derives a harmonious
/// palette from the active shadcn color scheme instead of using fl_chart's
/// native colors.
@immutable
class AppChartTheme {
  const AppChartTheme({
    this.palette = const <Color>[],
    this.height = 280,
    this.barWidth = 16,
    this.groupSpacing = 20,
    this.axisMinReservedSize = 40,
    this.axisMaxReservedSize = 96,
    this.labelFontSize = 12,
    this.gridOpacity = 0.55,
    this.inactiveOpacity = 0.32,
    this.hoverScale = 1.12,
    this.radius = 5,
    this.lineWidth = 2.5,
    this.pieRadius = 76,
    this.donutHoleRadius = 48,
    this.pointRadius = 3,
    this.pieSectionSpacing = 3,
    this.legendSpacing = 12,
    this.dataLabelMinSpacing = 44,
    this.pieLabelMinPercent = 6,
    this.keyboardFocusWidth = 2,
    this.animationDuration = const Duration(milliseconds: 320),
    this.pieAnimationDuration = const Duration(milliseconds: 240),
  }) : assert(height > 0),
       assert(barWidth > 0),
       assert(groupSpacing >= 0),
       assert(axisMinReservedSize >= 0),
       assert(axisMaxReservedSize >= axisMinReservedSize),
       assert(labelFontSize > 0),
       assert(gridOpacity >= 0 && gridOpacity <= 1),
       assert(inactiveOpacity >= 0 && inactiveOpacity <= 1),
       assert(hoverScale >= 1),
       assert(radius >= 0),
       assert(lineWidth > 0),
       assert(pieRadius > 0),
       assert(donutHoleRadius >= 0),
       assert(pointRadius > 0),
       assert(pieSectionSpacing >= 0),
       assert(legendSpacing >= 0),
       assert(dataLabelMinSpacing > 0),
       assert(pieLabelMinPercent >= 0 && pieLabelMinPercent <= 100),
       assert(keyboardFocusWidth > 0);

  final List<Color> palette;
  final double height;
  final double barWidth;
  final double groupSpacing;
  final double axisMinReservedSize;
  final double axisMaxReservedSize;
  final double labelFontSize;
  final double gridOpacity;
  final double inactiveOpacity;
  final double hoverScale;
  final double radius;
  final double lineWidth;
  final double pieRadius;
  final double donutHoleRadius;
  final double pointRadius;
  final double pieSectionSpacing;
  final double legendSpacing;
  final double dataLabelMinSpacing;
  final double pieLabelMinPercent;
  final double keyboardFocusWidth;
  final Duration animationDuration;
  final Duration pieAnimationDuration;

  AppChartTheme copyWith({
    List<Color>? palette,
    double? height,
    double? barWidth,
    double? groupSpacing,
    double? axisMinReservedSize,
    double? axisMaxReservedSize,
    double? labelFontSize,
    double? gridOpacity,
    double? inactiveOpacity,
    double? hoverScale,
    double? radius,
    double? lineWidth,
    double? pieRadius,
    double? donutHoleRadius,
    double? pointRadius,
    double? pieSectionSpacing,
    double? legendSpacing,
    double? dataLabelMinSpacing,
    double? pieLabelMinPercent,
    double? keyboardFocusWidth,
    Duration? animationDuration,
    Duration? pieAnimationDuration,
  }) => AppChartTheme(
    palette: palette ?? this.palette,
    height: height ?? this.height,
    barWidth: barWidth ?? this.barWidth,
    groupSpacing: groupSpacing ?? this.groupSpacing,
    axisMinReservedSize: axisMinReservedSize ?? this.axisMinReservedSize,
    axisMaxReservedSize: axisMaxReservedSize ?? this.axisMaxReservedSize,
    labelFontSize: labelFontSize ?? this.labelFontSize,
    gridOpacity: gridOpacity ?? this.gridOpacity,
    inactiveOpacity: inactiveOpacity ?? this.inactiveOpacity,
    hoverScale: hoverScale ?? this.hoverScale,
    radius: radius ?? this.radius,
    lineWidth: lineWidth ?? this.lineWidth,
    pieRadius: pieRadius ?? this.pieRadius,
    donutHoleRadius: donutHoleRadius ?? this.donutHoleRadius,
    pointRadius: pointRadius ?? this.pointRadius,
    pieSectionSpacing: pieSectionSpacing ?? this.pieSectionSpacing,
    legendSpacing: legendSpacing ?? this.legendSpacing,
    dataLabelMinSpacing: dataLabelMinSpacing ?? this.dataLabelMinSpacing,
    pieLabelMinPercent: pieLabelMinPercent ?? this.pieLabelMinPercent,
    keyboardFocusWidth: keyboardFocusWidth ?? this.keyboardFocusWidth,
    animationDuration: animationDuration ?? this.animationDuration,
    pieAnimationDuration: pieAnimationDuration ?? this.pieAnimationDuration,
  );
}

/// Shared interactive motion tokens for [AppButton], [AppIconButton], and
/// [AppMotion].
///
/// Configure once via [AppMotionTheme.tokens].
@immutable
class AppMotionTokens {
  const AppMotionTokens({
    this.hoverOffset = const Offset(0, -2),
    this.hoverScale = 1.008,
    this.pressedScale = 0.985,
    this.hoverDuration = const Duration(milliseconds: 240),
    this.pressDuration = const Duration(milliseconds: 140),
  });

  static const standard = AppMotionTokens();

  final Offset hoverOffset;
  final double hoverScale;
  final double pressedScale;
  final Duration hoverDuration;
  final Duration pressDuration;
  AppMotionTokens copyWith({
    Offset? hoverOffset,
    double? hoverScale,
    double? pressedScale,
    Duration? hoverDuration,
    Duration? pressDuration,
  }) {
    return AppMotionTokens(
      hoverOffset: hoverOffset ?? this.hoverOffset,
      hoverScale: hoverScale ?? this.hoverScale,
      pressedScale: pressedScale ?? this.pressedScale,
      hoverDuration: hoverDuration ?? this.hoverDuration,
      pressDuration: pressDuration ?? this.pressDuration,
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
    this.depthRotateY = 0.08,
    this.depthOffsetY = -4,
    this.depthTranslateZ = 8,
    this.depthPressAmount = 0.25,
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

enum AppShadowLevel { card, raised, floating, interactive }

@immutable
class AppShadowTheme {
  const AppShadowTheme({
    this.enabled = true,
    this.colorMode = AppShadowColorMode.auto,
    this.colorOpacity = 0.09,
    this.darkColorOpacity = 0.13,
    this.blurRadius = 8,
    this.spreadRadius = 0,
    this.offset = const Offset(0, 2),
  });

  const AppShadowTheme.none()
    : enabled = false,
      colorMode = AppShadowColorMode.auto,
      colorOpacity = 0,
      darkColorOpacity = 0,
      blurRadius = 0,
      spreadRadius = 0,
      offset = Offset.zero;

  final bool enabled;
  final AppShadowColorMode colorMode;
  final double colorOpacity;
  final double darkColorOpacity;
  final double blurRadius;
  final double spreadRadius;
  final Offset offset;

  /// Resolves the theme's complete shadow treatment for a surface.
  ///
  /// Callers should use this instead of composing additional business-side
  /// blur layers. During page transitions quality is reduced automatically.
  List<BoxShadow> resolve(
    BuildContext context, {
    AppShadowLevel level = AppShadowLevel.card,
    AppShadowQuality? quality,
    AppShadowColorMode? colorMode,
    Color? color,
    double intensity = 1,
    double? blurRadius,
    double? spreadRadius,
    Offset? offset,
  }) {
    final effectiveQuality =
        quality ?? AppPageTransitionScope.shadowQualityOf(context);
    if (!enabled ||
        effectiveQuality == AppShadowQuality.disabled ||
        intensity <= 0) {
      return const [];
    }

    final resolvedColor = resolveColor(
      context,
      colorMode: colorMode,
      color: color,
    );
    final dark = shad.Theme.of(context).brightness == shad.Brightness.dark;
    final levelFactor = switch (level) {
      AppShadowLevel.card => 1.0,
      AppShadowLevel.raised => 1.0,
      AppShadowLevel.floating => 1.35,
      AppShadowLevel.interactive => 1.0,
    };
    final effectiveIntensity = intensity.clamp(0.0, 3.0) * levelFactor;
    final opacity =
        (dark ? darkColorOpacity : colorOpacity) * effectiveIntensity;
    final resolvedBlurRadius = blurRadius ?? this.blurRadius;
    final resolvedSpreadRadius = spreadRadius ?? this.spreadRadius;
    final resolvedOffset = offset ?? this.offset;

    if (effectiveQuality == AppShadowQuality.reduced) {
      return [
        BoxShadow(
          color: resolvedColor.withValues(alpha: opacity * 0.65),
          blurRadius: resolvedBlurRadius.clamp(0, 6),
          spreadRadius: resolvedSpreadRadius.clamp(0, 2) * 0.5,
          offset: resolvedOffset * 0.55,
        ),
      ];
    }

    return [
      BoxShadow(
        color: resolvedColor.withValues(alpha: opacity),
        blurRadius: resolvedBlurRadius,
        spreadRadius: resolvedSpreadRadius,
        offset: resolvedOffset,
      ),
    ];
  }

  Color resolveColor(
    BuildContext context, {
    AppShadowColorMode? colorMode,
    Color? color,
  }) {
    final visual = AppVisualStyle.maybeOf(context);
    final colors = shad.Theme.of(context).colorScheme;
    final mode = colorMode ?? this.colorMode;
    final source = switch (mode) {
      AppShadowColorMode.custom => color,
      AppShadowColorMode.background => visual?.background,
      AppShadowColorMode.border => visual?.border,
      AppShadowColorMode.accent => visual?.accent,
      AppShadowColorMode.primary => colors.primary,
      AppShadowColorMode.auto =>
        color ??
            visual?.shadow ??
            visual?.border ??
            visual?.accent ??
            visual?.background ??
            colors.primary,
    };
    // Color modes only select the source. Normalize chromatic colors to a
    // shadow-safe luminance so bright surface colors do not disappear after
    // blending with the page background. Hue and saturation stay unchanged.
    final resolved = source ?? colors.primary;
    final hsl = HSLColor.fromColor(resolved);
    if (hsl.saturation < 0.08) return resolved;
    final dark = shad.Theme.of(context).brightness == shad.Brightness.dark;
    final lightness = dark
        ? hsl.lightness.clamp(0.58, 1.0)
        : hsl.lightness.clamp(0.0, 0.32);
    return hsl.withLightness(lightness).toColor();
  }

  /// Creates sufficient tonal separation between a solid-colored surface and
  /// its same-hue shadow. Soft surfaces should continue using [resolveColor].
  Color resolveSolidShadowColor(BuildContext context, Color color) {
    final hsl = HSLColor.fromColor(color);
    if (hsl.saturation < 0.08) return color;
    final dark = shad.Theme.of(context).brightness == shad.Brightness.dark;
    final lightness = dark
        ? hsl.lightness.clamp(0.66, 1.0)
        : hsl.lightness.clamp(0.0, 0.25);
    return hsl.withLightness(lightness).toColor();
  }
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
    this.tooltip = const AppTooltipTheme(),
    this.chart = const AppChartTheme(),
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
    AppTooltipTheme tooltip = const AppTooltipTheme(),
    AppChartTheme chart = const AppChartTheme(),
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
      tooltip: tooltip,
      chart: chart,
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
            hoverScale: 1.006,
            pressedScale: 0.99,
            hoverDuration: Duration(milliseconds: 220),
          ),
        ),
        shadows: const AppShadowTheme(
          colorOpacity: 0.09,
          darkColorOpacity: 0.14,
          blurRadius: 10,
          spreadRadius: 0,
          offset: Offset(0, 3),
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
            pressedScale: 0.995,
            hoverDuration: Duration(milliseconds: 120),
            pressDuration: Duration(milliseconds: 100),
          ),
        ),
        shadows: const AppShadowTheme(
          colorOpacity: 0.07,
          darkColorOpacity: 0.12,
          blurRadius: 8,
          spreadRadius: 0,
          offset: Offset(0, 2),
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
            hoverScale: 1.006,
            pressedScale: 0.985,
            hoverDuration: Duration(milliseconds: 200),
          ),
        ),
        shadows: const AppShadowTheme(
          colorOpacity: 0.11,
          darkColorOpacity: 0.16,
          blurRadius: 10,
          spreadRadius: 0,
          offset: Offset(0, 2),
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
  final AppTooltipTheme tooltip;
  final AppChartTheme chart;
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
    AppTooltipTheme? tooltip,
    AppChartTheme? chart,
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
      tooltip: tooltip ?? this.tooltip,
      chart: chart ?? this.chart,
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

AppColorScheme _flatInputScheme(AppColorScheme scheme) {
  final dark = scheme.brightness == Brightness.dark;
  const darkDestructive = Color(0xffff5c5c);
  Color soften(Color color, double opacity) =>
      Color.alphaBlend(color.withValues(alpha: opacity), scheme.background);

  return scheme.copyWith(
    input: () => scheme.background,
    border: () => soften(scheme.border, dark ? 0.78 : 0.72),
    ring: () => soften(scheme.ring, dark ? 0.72 : 0.55),
    destructive: dark ? () => darkDestructive : null,
  );
}

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
