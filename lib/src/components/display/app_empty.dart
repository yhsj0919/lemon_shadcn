import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class AppEmpty extends StatelessWidget {
  const AppEmpty({
    super.key,
    required this.title,
    this.icon,
    this.description,
    this.action,
    this.padding = const EdgeInsets.all(24),
    this.iconColor,
    this.iconSize = 32,
  });

  final Widget title;
  final Widget? icon;
  final Widget? description;
  final Widget? action;
  final EdgeInsetsGeometry padding;
  final Color? iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return Semantics(
      container: true,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              IconTheme.merge(
                data: IconThemeData(
                  size: iconSize,
                  color: iconColor ?? theme.colorScheme.mutedForeground,
                ),
                child: icon!,
              ),
              const SizedBox(height: 12),
            ],
            DefaultTextStyle.merge(
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.w600,
              ),
              child: title,
            ),
            if (description != null) ...[
              const SizedBox(height: 6),
              DefaultTextStyle.merge(
                style: TextStyle(
                  fontSize: theme.typography.small.fontSize,
                  color: theme.colorScheme.mutedForeground,
                ),
                textAlign: TextAlign.center,
                child: description!,
              ),
            ],
            if (action != null) ...[const SizedBox(height: 16), action!],
          ],
        ),
      ),
    );
  }
}
