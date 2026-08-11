import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';

/// Shared frame for compound inputs with leading/trailing addons.
class AppInputGroup extends StatelessWidget {
  const AppInputGroup({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.height,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 10),
    this.backgroundColor,
    this.borderColor,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final double? height;
  final bool enabled;
  final EdgeInsetsGeometry padding;
  final Color? backgroundColor;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final metrics = AppControlMetricsScope.resolve(context);
    final radius = BorderRadius.circular(theme.radiusMd);
    return SizedBox(
      height: height ?? metrics.height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color:
              backgroundColor ??
              (enabled
                  ? theme.colorScheme.input
                  : theme.colorScheme.muted.withValues(alpha: 0.55)),
          borderRadius: radius,
          border: Border.all(
            color: borderColor ?? theme.colorScheme.border,
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: Padding(
          padding: padding,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (leading != null) ...[
                AppInputGroupAddon(child: leading!),
                SizedBox(width: metrics.contentGap),
              ],
              Expanded(child: child),
              if (trailing != null) ...[
                SizedBox(width: metrics.contentGap),
                AppInputGroupAddon(child: trailing!),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class AppInputGroupAddon extends StatelessWidget {
  const AppInputGroupAddon({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => DefaultTextStyle.merge(
    style: TextStyle(
      fontSize: 14,
      color: shad.Theme.of(context).colorScheme.mutedForeground,
    ),
    child: IconTheme.merge(
      data: IconThemeData(
        size: AppControlMetricsScope.resolve(context).iconSize,
        color: shad.Theme.of(context).colorScheme.mutedForeground,
      ),
      child: child,
    ),
  );
}
