import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

enum AppAvatarShape { circle, square }

/// An avatar with explicit circular and square shape variants.
class AppAvatar extends StatelessWidget implements shad.AvatarWidget {
  const AppAvatar.circle({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
    this.badge,
    this.badgeAlignment,
    this.badgeGap,
    this.provider,
  }) : shape = AppAvatarShape.circle,
       borderRadius = 999;

  const AppAvatar.square({
    super.key,
    required this.initials,
    this.backgroundColor,
    this.foregroundColor,
    this.size,
    this.borderRadius = 12,
    this.badge,
    this.badgeAlignment,
    this.badgeGap,
    this.provider,
  }) : shape = AppAvatarShape.square;

  static String getInitials(String name) => shad.Avatar.getInitials(name);

  final AppAvatarShape shape;
  final String initials;
  final Color? backgroundColor;
  final Color? foregroundColor;

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
    final resolvedBackground =
        backgroundColor ??
        avatarTheme?.backgroundColor ??
        theme.colorScheme.muted;
    final resolvedForeground =
        foregroundColor ?? _contrastingForeground(resolvedBackground);
    final textStyle =
        (avatarTheme?.textStyle ?? const TextStyle(fontWeight: FontWeight.bold))
            .copyWith(color: resolvedForeground);

    return shad.ComponentTheme<shad.AvatarTheme>(
      data: (avatarTheme ?? const shad.AvatarTheme()).copyWith(
        textStyle: () => textStyle,
      ),
      child: shad.Avatar(
        initials: initials,
        backgroundColor: resolvedBackground,
        size: size,
        borderRadius: borderRadius,
        badge: badge,
        badgeAlignment: badgeAlignment,
        badgeGap: badgeGap,
        provider: provider,
      ),
    );
  }

  static Color _contrastingForeground(Color background) {
    return background.computeLuminance() > 0.179
        ? const Color(0xff000000)
        : const Color(0xffffffff);
  }
}
