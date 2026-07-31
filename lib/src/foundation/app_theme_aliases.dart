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

/// Upstream typography scale.
typedef AppTypography = shad.Typography;

/// Scoped override for a single component theme.
typedef AppComponentTheme = shad.ComponentTheme;

/// Base type for component theme payloads.
typedef AppComponentThemeData = shad.ComponentThemeData;
