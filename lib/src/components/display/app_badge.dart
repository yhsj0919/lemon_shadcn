import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_compact_label_style.dart';
import '../../foundation/app_interactive_style.dart';
import 'app_semantic_style.dart';

/// Visual treatment for semantic [AppBadge] variants.
enum AppBadgeStyle { solid, soft, plain, outline }

/// Badge outline shape. [square] is a rounded rectangle and is the default.
enum AppBadgeShape { pill, square }

/// Preset badge sizes, similar to [AppButtonSize].
@immutable
class AppBadgeSize {
  const AppBadgeSize({
    required this.fontSize,
    required this.height,
    required this.padding,
    required this.iconSize,
    required this.contentGap,
  });

  static const small = AppBadgeSize(
    fontSize: 10,
    height: 16,
    padding: EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    iconSize: 10,
    contentGap: 2,
  );

  /// Default compact badge size.
  static const normal = AppBadgeSize(
    fontSize: AppCompactLabelStyle.badgeFontSize,
    height: AppCompactLabelStyle.badgeHeight,
    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    iconSize: 12,
    contentGap: 4,
  );

  static const large = AppBadgeSize(
    fontSize: 14,
    height: 24,
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    iconSize: 14,
    contentGap: 6,
  );

  final double fontSize;

  /// Content line height inside the badge (excluding [padding]).
  final double height;
  final EdgeInsetsGeometry padding;
  final double iconSize;
  final double contentGap;

  AppBadgeSize copyWith({
    double? fontSize,
    double? height,
    EdgeInsetsGeometry? padding,
    double? iconSize,
    double? contentGap,
  }) {
    return AppBadgeSize(
      fontSize: fontSize ?? this.fontSize,
      height: height ?? this.height,
      padding: padding ?? this.padding,
      iconSize: iconSize ?? this.iconSize,
      contentGap: contentGap ?? this.contentGap,
    );
  }
}

/// Semantic badge variants exposed through one App-prefixed facade.
abstract final class AppBadge {
  static Widget _badge({required Widget child, VoidCallback? onPressed}) {
    final badge = UnconstrainedBox(
      constrainedAxis: Axis.vertical,
      alignment: Alignment.centerLeft,
      child: child,
    );
    if (onPressed != null) return badge;
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      child: IgnorePointer(child: badge),
    );
  }

  static Widget _content(
    Widget child,
    AppBadgeSize size, {
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
  }) => SizedBox(
    height: size.height,
    child: Center(
      widthFactor: 1,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ?leading,
          if (leading != null && (leadingGap ?? size.contentGap) > 0)
            SizedBox(width: leadingGap ?? size.contentGap),
          child,
          if (trailing != null && (trailingGap ?? size.contentGap) > 0)
            SizedBox(width: trailingGap ?? size.contentGap),
          ?trailing,
        ],
      ),
    ),
  );

  static shad.AbstractButtonStyle _style(
    shad.AbstractButtonStyle base, {
    required bool interactive,
    required AppBadgeSize size,
    required AppBadgeShape shape,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
    bool zeroPadding = false,
  }) {
    final resolvedPadding =
        padding ?? (zeroPadding ? EdgeInsets.zero : size.padding);
    final compact = base.copyWith(
      decoration: (context, states, current) {
        if (current is BoxDecoration) {
          return current.copyWith(
            borderRadius:
                borderRadius ??
                BorderRadius.circular(shape == AppBadgeShape.pill ? 999 : 6),
          );
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
      mouseCursor: (context, states, current) =>
          interactive ? SystemMouseCursors.click : SystemMouseCursors.basic,
    );
    return interactive ? AppInteractiveStyle.hover(compact) : compact;
  }

  static shad.AbstractButtonStyle _semanticStyle(
    _BadgePalette Function(shad.ThemeData theme, bool dark) paletteOf, {
    required AppBadgeStyle style,
    required bool interactive,
    required AppBadgeSize size,
    required AppBadgeShape shape,
    BorderRadiusGeometry? borderRadius,
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
              color: AppSoftColor.background(theme, palette.solid),
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
      shape: shape,
      borderRadius: borderRadius,
      padding: padding,
      fontWeight: fontWeight,
      zeroPadding: padding == null && style == AppBadgeStyle.plain,
    );
  }

  static _BadgePalette _infoPalette(shad.ThemeData theme, bool dark) =>
      AppSemanticPalette.resolve(theme, AppSemanticTone.info);

  static _BadgePalette _successPalette(shad.ThemeData theme, bool dark) =>
      AppSemanticPalette.resolve(theme, AppSemanticTone.success);

  static _BadgePalette _warningPalette(shad.ThemeData theme, bool dark) =>
      AppSemanticPalette.resolve(theme, AppSemanticTone.warning);

  static _BadgePalette _destructivePalette(shad.ThemeData theme, bool dark) =>
      AppSemanticPalette.resolve(theme, AppSemanticTone.destructive);

  static _BadgePalette _mutedPalette(shad.ThemeData theme, bool dark) =>
      AppSemanticPalette.resolve(theme, AppSemanticTone.secondary);

  /// A badge derived from an arbitrary business color.
  static Widget custom({
    Key? key,
    required Color color,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
    AppBadgeStyle appearance = AppBadgeStyle.soft,
    AppBadgeSize size = AppBadgeSize.normal,
    AppBadgeShape shape = AppBadgeShape.square,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => _badge(
    onPressed: onPressed,
    child: shad.SecondaryBadge(
      key: key,
      onPressed: onPressed,
      style: _semanticStyle(
        (theme, dark) => AppSemanticPalette.custom(theme, color),
        style: appearance,
        interactive: onPressed != null,
        size: size,
        shape: shape,
        borderRadius: borderRadius,
        padding: padding,
        fontWeight: fontWeight,
      ),
      child: _content(
        child,
        size,
        leading: leading,
        trailing: trailing,
        leadingGap: leadingGap,
        trailingGap: trailingGap,
      ),
    ),
  );

  static Widget primary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
    shad.AbstractButtonStyle? style,
    AppBadgeSize size = AppBadgeSize.normal,
    AppBadgeShape shape = AppBadgeShape.square,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => _badge(
    onPressed: onPressed,
    child: shad.PrimaryBadge(
      key: key,
      onPressed: onPressed,
      style: _style(
        style ?? shad.ButtonVariance.primary,
        interactive: onPressed != null,
        size: size,
        shape: shape,
        borderRadius: borderRadius,
        padding: padding,
        fontWeight: fontWeight,
      ),
      child: _content(
        child,
        size,
        leading: leading,
        trailing: trailing,
        leadingGap: leadingGap,
        trailingGap: trailingGap,
      ),
    ),
  );

  static Widget secondary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
    shad.AbstractButtonStyle? style,
    AppBadgeStyle appearance = AppBadgeStyle.solid,
    AppBadgeSize size = AppBadgeSize.normal,
    AppBadgeShape shape = AppBadgeShape.square,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) {
    if (style != null || appearance == AppBadgeStyle.solid) {
      return _badge(
        onPressed: onPressed,
        child: shad.SecondaryBadge(
          key: key,
          onPressed: onPressed,
          style: _style(
            style ?? shad.ButtonVariance.secondary,
            interactive: onPressed != null,
            size: size,
            shape: shape,
            borderRadius: borderRadius,
            padding: padding,
            fontWeight: fontWeight,
          ),
          child: _content(
            child,
            size,
            leading: leading,
            trailing: trailing,
            leadingGap: leadingGap,
            trailingGap: trailingGap,
          ),
        ),
      );
    }
    return _badge(
      onPressed: onPressed,
      child: shad.SecondaryBadge(
        key: key,
        onPressed: onPressed,
        style: _semanticStyle(
          _mutedPalette,
          style: appearance,
          interactive: onPressed != null,
          size: size,
          shape: shape,
          borderRadius: borderRadius,
          padding: padding,
          fontWeight: fontWeight,
        ),
        child: _content(
          child,
          size,
          leading: leading,
          trailing: trailing,
          leadingGap: leadingGap,
          trailingGap: trailingGap,
        ),
      ),
    );
  }

  static Widget outline({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
    shad.AbstractButtonStyle? style,
    AppBadgeSize size = AppBadgeSize.normal,
    AppBadgeShape shape = AppBadgeShape.square,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => _badge(
    onPressed: onPressed,
    child: shad.OutlineBadge(
      key: key,
      onPressed: onPressed,
      style: _style(
        style ?? shad.ButtonVariance.outline,
        interactive: onPressed != null,
        size: size,
        shape: shape,
        borderRadius: borderRadius,
        padding: padding,
        fontWeight: fontWeight,
      ),
      child: _content(
        child,
        size,
        leading: leading,
        trailing: trailing,
        leadingGap: leadingGap,
        trailingGap: trailingGap,
      ),
    ),
  );

  static Widget destructive({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
    shad.AbstractButtonStyle? style,
    AppBadgeStyle appearance = AppBadgeStyle.solid,
    AppBadgeSize size = AppBadgeSize.normal,
    AppBadgeShape shape = AppBadgeShape.square,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) {
    if (style != null || appearance == AppBadgeStyle.solid) {
      return _badge(
        onPressed: onPressed,
        child: shad.DestructiveBadge(
          key: key,
          onPressed: onPressed,
          style: _style(
            style ?? shad.ButtonVariance.destructive,
            interactive: onPressed != null,
            size: size,
            shape: shape,
            borderRadius: borderRadius,
            padding: padding,
            fontWeight: fontWeight,
          ),
          child: _content(
            child,
            size,
            leading: leading,
            trailing: trailing,
            leadingGap: leadingGap,
            trailingGap: trailingGap,
          ),
        ),
      );
    }
    return _badge(
      onPressed: onPressed,
      child: shad.SecondaryBadge(
        key: key,
        onPressed: onPressed,
        style: _semanticStyle(
          _destructivePalette,
          style: appearance,
          interactive: onPressed != null,
          size: size,
          shape: shape,
          borderRadius: borderRadius,
          padding: padding,
          fontWeight: fontWeight,
        ),
        child: _content(
          child,
          size,
          leading: leading,
          trailing: trailing,
          leadingGap: leadingGap,
          trailingGap: trailingGap,
        ),
      ),
    );
  }

  /// Blue status badge. Default [appearance] is [AppBadgeStyle.soft].
  static Widget info({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
    AppBadgeStyle appearance = AppBadgeStyle.soft,
    AppBadgeSize size = AppBadgeSize.normal,
    AppBadgeShape shape = AppBadgeShape.square,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => _badge(
    onPressed: onPressed,
    child: shad.SecondaryBadge(
      key: key,
      onPressed: onPressed,
      style: _semanticStyle(
        _infoPalette,
        style: appearance,
        interactive: onPressed != null,
        size: size,
        shape: shape,
        borderRadius: borderRadius,
        padding: padding,
        fontWeight: fontWeight,
      ),
      child: _content(
        child,
        size,
        leading: leading,
        trailing: trailing,
        leadingGap: leadingGap,
        trailingGap: trailingGap,
      ),
    ),
  );

  /// Green status badge. Default [appearance] is [AppBadgeStyle.soft].
  static Widget success({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
    AppBadgeStyle appearance = AppBadgeStyle.soft,
    AppBadgeSize size = AppBadgeSize.normal,
    AppBadgeShape shape = AppBadgeShape.square,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => _badge(
    onPressed: onPressed,
    child: shad.SecondaryBadge(
      key: key,
      onPressed: onPressed,
      style: _semanticStyle(
        _successPalette,
        style: appearance,
        interactive: onPressed != null,
        size: size,
        shape: shape,
        borderRadius: borderRadius,
        padding: padding,
        fontWeight: fontWeight,
      ),
      child: _content(
        child,
        size,
        leading: leading,
        trailing: trailing,
        leadingGap: leadingGap,
        trailingGap: trailingGap,
      ),
    ),
  );

  /// Amber status badge. Default [appearance] is [AppBadgeStyle.soft].
  static Widget warning({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    double? leadingGap,
    double? trailingGap,
    AppBadgeStyle appearance = AppBadgeStyle.soft,
    AppBadgeSize size = AppBadgeSize.normal,
    AppBadgeShape shape = AppBadgeShape.square,
    BorderRadiusGeometry? borderRadius,
    EdgeInsetsGeometry? padding,
    FontWeight? fontWeight,
  }) => _badge(
    onPressed: onPressed,
    child: shad.SecondaryBadge(
      key: key,
      onPressed: onPressed,
      style: _semanticStyle(
        _warningPalette,
        style: appearance,
        interactive: onPressed != null,
        size: size,
        shape: shape,
        borderRadius: borderRadius,
        padding: padding,
        fontWeight: fontWeight,
      ),
      child: _content(
        child,
        size,
        leading: leading,
        trailing: trailing,
        leadingGap: leadingGap,
        trailingGap: trailingGap,
      ),
    ),
  );
}

typedef _BadgePalette = AppSemanticPalette;
