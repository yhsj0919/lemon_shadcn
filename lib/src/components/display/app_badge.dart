import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_compact_label_style.dart';
import '../../foundation/app_interactive_style.dart';

/// Visual treatment for semantic [AppBadge] variants.
enum AppBadgeStyle {
  /// Saturated fill with contrasting foreground.
  solid,

  /// Light tinted background with accent foreground.
  soft,

  /// No background — colored label and icons only.
  plain,

  /// Accent border with transparent fill.
  outline,
}

/// Preset badge sizes, similar to [AppButtonSize].
@immutable
class AppBadgeSize {
  const AppBadgeSize({
    required this.fontSize,
    required this.height,
    required this.padding,
    required this.iconSize,
  });

  static const small = AppBadgeSize(
    fontSize: 10,
    height: 16,
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    iconSize: 10,
  );

  /// Default compact badge size.
  static const normal = AppBadgeSize(
    fontSize: AppCompactLabelStyle.badgeFontSize,
    height: AppCompactLabelStyle.badgeHeight,
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    iconSize: 12,
  );

  static const large = AppBadgeSize(
    fontSize: 14,
    height: 24,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    iconSize: 14,
  );

  final double fontSize;

  /// Content line height inside the badge (excluding [padding]).
  final double height;
  final EdgeInsetsGeometry padding;
  final double iconSize;

  AppBadgeSize copyWith({
    double? fontSize,
    double? height,
    EdgeInsetsGeometry? padding,
    double? iconSize,
  }) {
    return AppBadgeSize(
      fontSize: fontSize ?? this.fontSize,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
    );
  }
}

/// Semantic badge variants exposed through one App-prefixed facade.
abstract final class AppBadge {
  static Widget _content(Widget child, AppBadgeSize size) => SizedBox(
    height: size.height,
    child: Center(widthFactor: 1, child: child),
  );

  static shad.AbstractButtonStyle _style(
    shad.AbstractButtonStyle base, {
    required bool interactive,
    required AppBadgeSize size,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
    bool zeroPadding = false,
  }) {
    final resolvedPadding = padding ??
        (zeroPadding ? EdgeInsets.zero : size.padding);
    final compact = base.copyWith(
      decoration: (context, states, current) {
        if (current is BoxDecoration) {
          return current.copyWith(borderRadius: BorderRadius.circular(999));
        }
        return current;
      },
      padding: (context, states, current) => resolvedPadding,
      textStyle: (context, states, current) => current.copyWith(
        fontSize: size.fontSize,
        fontWeight: fontWeight ?? FontWeight.w500,
      ),
      iconTheme: (context, states, current) =>
          current.copyWith(size: size.iconSize),
    );
    return interactive ? AppInteractiveStyle.hover(compact) : compact;
  }

  static shad.AbstractButtonStyle _semanticStyle(
    _BadgePalette Function(shad.ThemeData theme, bool dark) paletteOf, {
    required AppBadgeStyle style,
    required bool interactive,
    required AppBadgeSize size,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) {
    final base = switch (style) {
      AppBadgeStyle.solid => const shad.ButtonStyle.primary(
        size: shad.ButtonSize.small,
        density: shad.ButtonDensity.dense,
      ),
      AppBadgeStyle.soft ||
      AppBadgeStyle.plain ||
      AppBadgeStyle.outline => const shad.ButtonStyle.secondary(
        size: shad.ButtonSize.small,
        density: shad.ButtonDensity.dense,
      ),
    };

    return _style(
      base.copyWith(
        decoration: (context, states, value) {
          if (value is! BoxDecoration) return value;
          final theme = shad.Theme.of(context);
          final dark = theme.brightness == Brightness.dark;
          final palette = paletteOf(theme, dark);
          return switch (style) {
            AppBadgeStyle.solid => value.copyWith(
              color: palette.solid,
              border: Border.all(color: const Color(0x00000000)),
            ),
            AppBadgeStyle.soft => value.copyWith(
              color: palette.softBackground,
              border: Border.all(color: const Color(0x00000000)),
            ),
            AppBadgeStyle.plain => value.copyWith(
              color: const Color(0x00000000),
              border: Border.all(color: const Color(0x00000000)),
            ),
            AppBadgeStyle.outline => value.copyWith(
              color: const Color(0x00000000),
              border: Border.all(color: palette.foreground, width: 1),
            ),
          };
        },
        textStyle: (context, states, value) {
          final theme = shad.Theme.of(context);
          final dark = theme.brightness == Brightness.dark;
          final palette = paletteOf(theme, dark);
          return value.copyWith(
            color: style == AppBadgeStyle.solid
                ? palette.onSolid
                : palette.foreground,
          );
        },
        iconTheme: (context, states, value) {
          final theme = shad.Theme.of(context);
          final dark = theme.brightness == Brightness.dark;
          final palette = paletteOf(theme, dark);
          return value.copyWith(
            color: style == AppBadgeStyle.solid
                ? palette.onSolid
                : palette.foreground,
          );
        },
      ),
      interactive: interactive,
      size: size,
      padding: padding,
      fontWeight: fontWeight,
      zeroPadding: padding == null && style == AppBadgeStyle.plain,
    );
  }

  static _BadgePalette _infoPalette(shad.ThemeData theme, bool dark) => dark
      ? const _BadgePalette(
          solid: Color(0xff2563eb),
          onSolid: Color(0xffffffff),
          softBackground: Color(0xff172554),
          foreground: Color(0xffbfdbfe),
        )
      : const _BadgePalette(
          solid: Color(0xff2563eb),
          onSolid: Color(0xffffffff),
          softBackground: Color(0xffeff6ff),
          foreground: Color(0xff1e40af),
        );

  static _BadgePalette _successPalette(shad.ThemeData theme, bool dark) => dark
      ? const _BadgePalette(
          solid: Color(0xff16a34a),
          onSolid: Color(0xffffffff),
          softBackground: Color(0xff052e16),
          foreground: Color(0xffbbf7d0),
        )
      : const _BadgePalette(
          solid: Color(0xff16a34a),
          onSolid: Color(0xffffffff),
          softBackground: Color(0xfff0fdf4),
          foreground: Color(0xff166534),
        );

  static _BadgePalette _warningPalette(shad.ThemeData theme, bool dark) => dark
      ? const _BadgePalette(
          solid: Color(0xffd97706),
          onSolid: Color(0xffffffff),
          softBackground: Color(0xff451a03),
          foreground: Color(0xfffde68a),
        )
      : const _BadgePalette(
          solid: Color(0xffd97706),
          onSolid: Color(0xffffffff),
          softBackground: Color(0xfffffbeb),
          foreground: Color(0xff92400e),
        );

  static _BadgePalette _destructivePalette(shad.ThemeData theme, bool dark) =>
      dark
      ? _BadgePalette(
          solid: theme.colorScheme.destructive,
          onSolid: const Color(0xffffffff),
          softBackground: const Color(0xff450a0a),
          foreground: const Color(0xfffecaca),
        )
      : _BadgePalette(
          solid: theme.colorScheme.destructive,
          onSolid: const Color(0xffffffff),
          softBackground: const Color(0xfffef2f2),
          foreground: const Color(0xff991b1b),
        );

  static _BadgePalette _mutedPalette(shad.ThemeData theme, bool dark) =>
      _BadgePalette(
        solid: theme.colorScheme.secondary,
        onSolid: theme.colorScheme.secondaryForeground,
        softBackground: theme.colorScheme.muted,
        foreground: theme.colorScheme.mutedForeground,
      );

  static Widget primary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    shad.AbstractButtonStyle? style,
    AppBadgeSize size = AppBadgeSize.normal,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => shad.PrimaryBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: _style(
      style ?? shad.ButtonVariance.primary,
      interactive: onPressed != null,
      size: size,
      padding: padding,
      fontWeight: fontWeight,
    ),
    child: _content(child, size),
  );

  static Widget secondary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    shad.AbstractButtonStyle? style,
    AppBadgeStyle appearance = AppBadgeStyle.solid,
    AppBadgeSize size = AppBadgeSize.normal,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) {
    if (style != null || appearance == AppBadgeStyle.solid) {
      return shad.SecondaryBadge(
        key: key,
        onPressed: onPressed,
        leading: leading,
        trailing: trailing,
        style: _style(
          style ?? shad.ButtonVariance.secondary,
          interactive: onPressed != null,
          size: size,
          padding: padding,
          fontWeight: fontWeight,
        ),
        child: _content(child, size),
      );
    }
    return shad.SecondaryBadge(
      key: key,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      style: _semanticStyle(
        _mutedPalette,
        style: appearance,
        interactive: onPressed != null,
        size: size,
        padding: padding,
        fontWeight: fontWeight,
      ),
      child: _content(child, size),
    );
  }

  static Widget outline({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    shad.AbstractButtonStyle? style,
    AppBadgeSize size = AppBadgeSize.normal,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => shad.OutlineBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: _style(
      style ?? shad.ButtonVariance.outline,
      interactive: onPressed != null,
      size: size,
      padding: padding,
      fontWeight: fontWeight,
    ),
    child: _content(child, size),
  );

  static Widget destructive({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    shad.AbstractButtonStyle? style,
    AppBadgeStyle appearance = AppBadgeStyle.solid,
    AppBadgeSize size = AppBadgeSize.normal,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) {
    if (style != null || appearance == AppBadgeStyle.solid) {
      return shad.DestructiveBadge(
        key: key,
        onPressed: onPressed,
        leading: leading,
        trailing: trailing,
        style: _style(
          style ?? shad.ButtonVariance.destructive,
          interactive: onPressed != null,
          size: size,
          padding: padding,
          fontWeight: fontWeight,
        ),
        child: _content(child, size),
      );
    }
    return shad.SecondaryBadge(
      key: key,
      onPressed: onPressed,
      leading: leading,
      trailing: trailing,
      style: _semanticStyle(
        _destructivePalette,
        style: appearance,
        interactive: onPressed != null,
        size: size,
        padding: padding,
        fontWeight: fontWeight,
      ),
      child: _content(child, size),
    );
  }

  /// Blue status badge. Default [appearance] is [AppBadgeStyle.soft].
  static Widget info({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    AppBadgeStyle appearance = AppBadgeStyle.soft,
    AppBadgeSize size = AppBadgeSize.normal,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => shad.SecondaryBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: _semanticStyle(
      _infoPalette,
      style: appearance,
      interactive: onPressed != null,
      size: size,
      padding: padding,
      fontWeight: fontWeight,
    ),
    child: _content(child, size),
  );

  /// Green status badge. Default [appearance] is [AppBadgeStyle.soft].
  static Widget success({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    AppBadgeStyle appearance = AppBadgeStyle.soft,
    AppBadgeSize size = AppBadgeSize.normal,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => shad.SecondaryBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: _semanticStyle(
      _successPalette,
      style: appearance,
      interactive: onPressed != null,
      size: size,
      padding: padding,
      fontWeight: fontWeight,
    ),
    child: _content(child, size),
  );

  /// Amber status badge. Default [appearance] is [AppBadgeStyle.soft].
  static Widget warning({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    AppBadgeStyle appearance = AppBadgeStyle.soft,
    AppBadgeSize size = AppBadgeSize.normal,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => shad.SecondaryBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: _semanticStyle(
      _warningPalette,
      style: appearance,
      interactive: onPressed != null,
      size: size,
      padding: padding,
      fontWeight: fontWeight,
    ),
    child: _content(child, size),
  );
}

@immutable
class _BadgePalette {
  const _BadgePalette({
    required this.solid,
    required this.onSolid,
    required this.softBackground,
    required this.foreground,
  });

  final Color solid;
  final Color onSolid;
  final Color softBackground;
  final Color foreground;
}
