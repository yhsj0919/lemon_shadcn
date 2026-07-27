import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Semantic badge variants exposed through one App-prefixed facade.
abstract final class AppBadge {
  static Widget primary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    shad.AbstractButtonStyle? style,
  }) => shad.PrimaryBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: style,
    child: child,
  );

  static Widget secondary({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    shad.AbstractButtonStyle? style,
  }) => shad.SecondaryBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: style,
    child: child,
  );

  static Widget outline({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    shad.AbstractButtonStyle? style,
  }) => shad.OutlineBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: style,
    child: child,
  );

  static Widget destructive({
    Key? key,
    required Widget child,
    VoidCallback? onPressed,
    Widget? leading,
    Widget? trailing,
    shad.AbstractButtonStyle? style,
  }) => shad.DestructiveBadge(
    key: key,
    onPressed: onPressed,
    leading: leading,
    trailing: trailing,
    style: style,
    child: child,
  );
}
