import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_semantic_style.dart';
import 'app_text.dart';

enum AppAvatarShape { circle, square }

enum AppAvatarAppearance { solid, soft }

/// An avatar with explicit circular and square shape variants.
class AppAvatar extends StatelessWidget implements shad.AvatarWidget {
  static const double _softLightOpacity = 0.24;
  static const double _softDarkOpacity = 0.20;

  const AppAvatar.circle({
    super.key,
    this.initials,
    this.name,
    this.icon,
    this.iconSize,
    this.initialsCount = 1,
    this.appearance = AppAvatarAppearance.solid,
    this.color,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.size,
    this.badge,
    this.badgeAlignment,
    this.badgeGap,
    this.provider,
  }) : assert(initials != null || name != null || icon != null),
       assert(initialsCount > 0),
       shape = AppAvatarShape.circle,
       borderRadius = 999;

  const AppAvatar.square({
    super.key,
    this.initials,
    this.name,
    this.icon,
    this.iconSize,
    this.initialsCount = 1,
    this.appearance = AppAvatarAppearance.solid,
    this.color,
    this.backgroundColor,
    this.foregroundColor,
    this.textStyle,
    this.size,
    this.borderRadius = 12,
    this.badge,
    this.badgeAlignment,
    this.badgeGap,
    this.provider,
  }) : assert(initials != null || name != null || icon != null),
       assert(initialsCount > 0),
       shape = AppAvatarShape.square;

  /// Extracts up to [count] grapheme-safe initials from a name.
  ///
  /// Names containing spaces use the first character of each word. Unspaced
  /// names, including Chinese names, use their first [count] characters.
  static String getInitials(String name, {int count = 1}) {
    if (count <= 0) {
      throw ArgumentError.value(count, 'count', 'Must be greater than zero.');
    }
    final trimmed = name.trim();
    if (trimmed.isEmpty) return '';
    final words = trimmed.split(RegExp(r'\s+'));
    final extracted = words.length > 1
        ? words.take(count).map((word) => word.characters.first).join()
        : trimmed.characters.take(count).toString();
    return extracted.toUpperCase();
  }

  final AppAvatarShape shape;
  final AppAvatarAppearance appearance;
  final String? initials;
  final String? name;
  final int initialsCount;
  final Widget? icon;
  final double? iconSize;
  final Color? color;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final TextStyle? textStyle;

  @override
  final double? size;

  @override
  final double? borderRadius;

  final shad.AvatarWidget? badge;
  final AlignmentGeometry? badgeAlignment;
  final double? badgeGap;
  final ImageProvider? provider;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final avatarTheme = shad.ComponentTheme.maybeOf<shad.AvatarTheme>(context);
    final resolvedSize = size ?? avatarTheme?.size ?? theme.scaling * 40;
    final resolvedBorderRadius =
        borderRadius ??
        avatarTheme?.borderRadius ??
        theme.radius * resolvedSize;
    final accent = color ?? theme.colorScheme.primary;
    final soft = appearance == AppAvatarAppearance.soft || icon != null;
    final resolvedBackground =
        backgroundColor ??
        (soft
            ? _softBackground(theme, accent)
            : avatarTheme?.backgroundColor ?? theme.colorScheme.muted);
    final resolvedForeground =
        foregroundColor ??
        textStyle?.color ??
        (soft
            ? _softForeground(theme, accent)
            : avatarTheme?.textStyle?.color ??
                  _contrastingForeground(resolvedBackground));
    final resolvedTextStyle =
        AppTextTheme.resolve(context, AppTextRole.bodyStrong, null)
            .copyWith(fontWeight: FontWeight.bold)
            .merge(avatarTheme?.textStyle)
            .merge(textStyle)
            .copyWith(color: resolvedForeground);
    final resolvedInitials =
        initials ??
        (name == null ? '' : getInitials(name!, count: initialsCount));
    final fallback = icon == null
        ? _initials(
            value: resolvedInitials,
            background: resolvedBackground,
            textStyle: resolvedTextStyle,
            size: resolvedSize,
          )
        : _icon(
            icon: icon!,
            background: resolvedBackground,
            foreground: resolvedForeground,
            iconSize: iconSize ?? resolvedSize * 0.48,
          );

    final surface = _AppAvatarSurface(
      size: resolvedSize,
      borderRadius: resolvedBorderRadius,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(resolvedBorderRadius),
        child: provider == null
            ? fallback
            : Image(
                image: provider!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => fallback,
              ),
      ),
    );

    final badge = this.badge;
    if (badge == null) return surface;

    final badgeSize = badge.size ?? theme.scaling * 12;
    var offset = resolvedSize / 2 - badgeSize / 2;
    offset /= resolvedSize;
    final alignment =
        badgeAlignment ??
        avatarTheme?.badgeAlignment ??
        AlignmentDirectional(offset, offset);
    final gap = badgeGap ?? avatarTheme?.badgeGap ?? theme.scaling * 4;
    return shad.AvatarGroup(
      alignment: alignment,
      gap: gap,
      children: [badge, surface],
    );
  }

  Widget _initials({
    required String value,
    required Color background,
    required TextStyle textStyle,
    required double size,
  }) {
    return ColoredBox(
      color: background,
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(size * 0.16),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, maxLines: 1, softWrap: false, style: textStyle),
          ),
        ),
      ),
    );
  }

  Widget _icon({
    required Widget icon,
    required Color background,
    required Color foreground,
    required double iconSize,
  }) {
    return ColoredBox(
      color: background,
      child: Center(
        child: IconTheme(
          data: IconThemeData(color: foreground, size: iconSize),
          child: icon,
        ),
      ),
    );
  }

  static Color _contrastingForeground(Color background) {
    return background.computeLuminance() > 0.179
        ? const Color(0xff000000)
        : const Color(0xffffffff);
  }

  static Color _softForeground(shad.ThemeData theme, Color accent) {
    if (theme.brightness == Brightness.dark) return accent;
    final hsl = HSLColor.fromColor(accent);
    return hsl.withLightness((hsl.lightness * 0.82).clamp(0.0, 1.0)).toColor();
  }

  static Color _softBackground(shad.ThemeData theme, Color accent) {
    final background = AppSoftColor.background(
      theme,
      accent,
      lightOpacity: _softLightOpacity,
      darkOpacity: _softDarkOpacity,
    );
    if (theme.brightness == Brightness.dark) return background;
    final hsl = HSLColor.fromColor(background);
    final clarified = hsl
        .withSaturation((hsl.saturation * 1.2).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + 0.025).clamp(0.0, 1.0));
    final hue = clarified.hue;
    return (hue >= 20 && hue <= 50
            ? clarified.withHue((hue + 10).clamp(0.0, 360.0))
            : clarified)
        .toColor();
  }
}

class _AppAvatarSurface extends StatelessWidget implements shad.AvatarWidget {
  const _AppAvatarSurface({
    required this.size,
    required this.borderRadius,
    required this.child,
  });

  @override
  final double size;

  @override
  final double borderRadius;

  final Widget child;

  @override
  Widget build(BuildContext context) =>
      SizedBox.square(dimension: size, child: child);
}
