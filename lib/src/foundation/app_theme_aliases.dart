import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Upstream shadcn [Theme] (design tokens, color scheme, radius, …).
///
/// Named [ShadcnTheme] because [AppTheme] already exposes [AppThemeConfig]
/// from [AppShadcnScope].
///
/// ```dart
/// final colors = ShadcnTheme.of(context).colorScheme;
/// ```
typedef ShadcnTheme = shad.Theme;

/// Upstream shadcn theme data used by [AppThemeConfig] and [LemonThemes].
typedef AppThemeData = shad.ThemeData;

/// Tween for animating between [AppThemeData] values.
typedef AppThemeDataTween = shad.ThemeDataTween;

/// Upstream color roles (`primary`, `muted`, `destructive`, …).
typedef AppColorScheme = shad.ColorScheme;

/// Built-in color scheme presets (`zinc`, `slate`, …).
typedef AppColorSchemes = shad.ColorSchemes;

/// Upstream light / dark / system mode for shadcn themes.
///
/// Distinct from Material's `ThemeMode` — use this when configuring
/// [AppThemeConfig] or [AppColorSchemes].
typedef AppThemeMode = shad.ThemeMode;

/// Scoped override for a single component theme.
typedef AppComponentTheme = shad.ComponentTheme;

/// Base type for component theme payloads.
typedef AppComponentThemeData = shad.ComponentThemeData;

/// Typography factories for Lemon apps.
///
/// Prefer [system] so pages pick up platform UI fonts instead of the bundled
/// Geist package. Size tokens still follow the upstream shadcn scale.
///
/// ```dart
/// AppThemeData(typography: AppTypography.system());
/// ```
///
/// TODO(upstream): drop this shim once `shadcn_flutter` defaults to platform
/// UI fonts (or exposes an equivalent factory).
abstract final class AppTypography {
  /// Upstream Geist fonts shipped with `shadcn_flutter`.
  static shad.Typography geist() => const shad.Typography.geist();

  /// Platform UI fonts with the same size/weight tokens as [geist].
  ///
  /// - Windows: Microsoft YaHei UI
  /// - Apple: system UI + PingFang SC fallbacks
  /// - Android / Linux: platform default + Noto CJK fallbacks
  ///
  /// TODO(upstream): temporary until Geist is no longer the package default.
  static shad.Typography system({TargetPlatform? platform}) {
    final target = platform ?? defaultTargetPlatform;
    final fonts = _SystemFonts.forPlatform(target);
    final source = geist();
    TextStyle ui(TextStyle style, {bool mono = false}) {
      final stack = mono ? fonts.mono : fonts.sans;
      return TextStyle(
        inherit: style.inherit,
        fontFamily: stack.family,
        fontFamilyFallback: stack.fallback,
        fontSize: style.fontSize,
        fontWeight: style.fontWeight,
        fontStyle: style.fontStyle,
        letterSpacing: style.letterSpacing,
        wordSpacing: style.wordSpacing,
        height: style.height,
        decoration: style.decoration,
      );
    }

    return source.copyWith(
      sans: () => ui(source.sans),
      mono: () => ui(source.mono, mono: true),
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
      inlineCode: () => ui(source.inlineCode, mono: true),
      lead: () => ui(source.lead),
      textLarge: () => ui(source.textLarge),
      textSmall: () => ui(source.textSmall),
      textMuted: () => ui(source.textMuted),
    );
  }
}

class _FontStack {
  const _FontStack(this.family, this.fallback);
  final String? family;
  final List<String>? fallback;
}

class _SystemFonts {
  const _SystemFonts({required this.sans, required this.mono});

  final _FontStack sans;
  final _FontStack mono;

  static _SystemFonts forPlatform(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.windows => const _SystemFonts(
        sans: _FontStack('Microsoft YaHei UI', [
          'Microsoft YaHei',
          'Segoe UI',
          'Arial',
        ]),
        mono: _FontStack('Consolas', ['Cascadia Mono', 'Courier New']),
      ),
      TargetPlatform.macOS || TargetPlatform.iOS => const _SystemFonts(
        sans: _FontStack(null, [
          'PingFang SC',
          'Hiragino Sans GB',
          '.AppleSystemUIFont',
        ]),
        mono: _FontStack(null, ['Menlo', 'SF Mono', 'Courier']),
      ),
      TargetPlatform.android || TargetPlatform.fuchsia => const _SystemFonts(
        sans: _FontStack(null, ['Noto Sans SC', 'Roboto', 'sans-serif']),
        mono: _FontStack(null, ['Droid Sans Mono', 'monospace']),
      ),
      TargetPlatform.linux => const _SystemFonts(
        sans: _FontStack(null, [
          'Noto Sans CJK SC',
          'WenQuanYi Micro Hei',
          'DejaVu Sans',
        ]),
        mono: _FontStack(null, ['DejaVu Sans Mono', 'monospace']),
      ),
    };
  }
}
