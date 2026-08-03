import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_compact_label_style.dart';
import '../../foundation/app_interactive_style.dart';

/// Semantic badge variants exposed through one App-prefixed facade.
abstract final class AppBadge {
  static Widget _content(Widget child) => SizedBox(
    height: AppCompactLabelStyle.badgeHeight,
    child: Center(widthFactor: 1, child: child),
  );

  static shad.AbstractButtonStyle _style(
    shad.AbstractButtonStyle base,
    bool interactive,
  ) {
    final compact = AppCompactLabelStyle.applyBadge(base);
    return interactive ? AppInteractiveStyle.hover(compact) : compact;
  }

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
    style: _style(style ?? shad.ButtonVariance.primary, onPressed != null),
    child: _content(child),
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
    style: _style(style ?? shad.ButtonVariance.secondary, onPressed != null),
    child: _content(child),
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
    style: _style(style ?? shad.ButtonVariance.outline, onPressed != null),
    child: _content(child),
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
    style: _style(style ?? shad.ButtonVariance.destructive, onPressed != null),
    child: _content(child),
  );
}
