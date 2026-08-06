import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

enum AppAvatarShape { circle, square }

/// An avatar with explicit circular and square shape variants.
class AppAvatar extends StatelessWidget implements shad.AvatarWidget {
  const AppAvatar.circle({
    super.key,
    required this.initials,
    this.backgroundColor,
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
    return shad.Avatar(
      initials: initials,
      backgroundColor: backgroundColor,
      size: size,
      borderRadius: borderRadius,
      badge: badge,
      badgeAlignment: badgeAlignment,
      badgeGap: badgeGap,
      provider: provider,
    );
  }
}
