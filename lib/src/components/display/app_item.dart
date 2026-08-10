import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_interactive_style.dart';

class AppItemGroup extends StatelessWidget {
  const AppItemGroup({
    super.key,
    required this.children,
    this.bordered = true,
    this.divided = true,
  });

  final List<Widget> children;
  final bool bordered;
  final bool divided;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final radius = BorderRadius.circular(theme.radiusMd);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < children.length; index++) ...[
          if (index > 0 && divided)
            SizedBox(
              height: 1,
              child: ColoredBox(color: theme.colorScheme.border),
            ),
          children[index],
        ],
      ],
    );
    if (!bordered) return content;
    return ClipRRect(
      borderRadius: radius,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(
            color: theme.colorScheme.border,
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
        ),
        child: content,
      ),
    );
  }
}

class AppItem extends StatelessWidget {
  const AppItem({
    super.key,
    required this.title,
    this.leading,
    this.description,
    this.trailing,
    this.onPressed,
    this.selected = false,
    this.enabled = true,
    this.padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  });

  final Widget title;
  final Widget? leading;
  final Widget? description;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final bool selected;
  final bool enabled;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final content = Padding(
      padding: padding,
      child: Row(
        children: [
          if (leading != null) ...[
            IconTheme.merge(
              data: const IconThemeData(size: 18),
              child: leading!,
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                DefaultTextStyle.merge(
                  style: const TextStyle(fontSize: 14),
                  child: title,
                ),
                if (description != null) ...[
                  const SizedBox(height: 2),
                  DefaultTextStyle.merge(
                    style: TextStyle(
                      fontSize: 12,
                      color: theme.colorScheme.mutedForeground,
                    ),
                    child: description!,
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) ...[const SizedBox(width: 10), trailing!],
        ],
      ),
    );
    if (onPressed == null) return content;
    final style = shad.ButtonStyle.ghost().copyWith(
      mouseCursor: (context, states) =>
          enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      decoration: (context, states, value) {
        if (value is! BoxDecoration) return value;
        return value.copyWith(
          color: selected ? theme.colorScheme.accent : value.color,
          borderRadius: BorderRadius.circular(theme.radiusMd),
        );
      },
      padding: (context, states, value) => EdgeInsets.zero,
    );
    return shad.Button(
      enabled: enabled,
      onPressed: enabled ? onPressed : null,
      style: AppInteractiveStyle.hover(style),
      child: content,
    );
  }
}
