import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// A themed divider that supports horizontal, vertical, and labeled variants.
class AppDivider extends StatelessWidget implements PreferredSizeWidget {
  const AppDivider.horizontal({
    super.key,
    this.color,
    this.width,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.child,
    this.label,
    this.textStyle,
    this.padding,
    this.childAlignment,
  }) : axis = Axis.horizontal,
       assert(child == null || label == null);

  const AppDivider.vertical({
    super.key,
    this.color,
    this.width,
    this.height,
    this.thickness,
    this.indent,
    this.endIndent,
    this.child,
    this.label,
    this.textStyle,
    this.padding,
    this.childAlignment,
  }) : axis = Axis.vertical,
       assert(child == null || label == null);

  const AppDivider.text(
    String text, {
    super.key,
    this.axis = Axis.horizontal,
    this.color,
    this.height,
    this.width,
    this.thickness,
    this.indent,
    this.endIndent,
    this.padding,
    this.childAlignment,
    TextStyle? textStyle,
  }) : child = null,
       label = text,
       textStyle = textStyle ?? const TextStyle(fontSize: 12);

  final Axis axis;
  final Color? color;

  /// Total cross-axis extent for a horizontal divider.
  final double? height;

  /// Total cross-axis extent for a vertical divider.
  final double? width;
  final double? thickness;
  final double? indent;
  final double? endIndent;
  final Widget? child;
  final String? label;
  final TextStyle? textStyle;
  final EdgeInsetsGeometry? padding;
  final shad.AxisAlignmentGeometry? childAlignment;

  @override
  Size get preferredSize => axis == Axis.horizontal
      ? Size(0, height ?? thickness ?? 1)
      : Size(width ?? thickness ?? 1, 0);

  @override
  Widget build(BuildContext context) {
    final resolvedChild =
        child ?? (label == null ? null : Text(label!, style: textStyle));
    if (axis == Axis.horizontal) {
      final divider = shad.Divider(
        color: color,
        height: height,
        thickness: thickness,
        indent: indent,
        endIndent: endIndent,
        padding: padding,
        childAlignment: childAlignment,
        child: resolvedChild,
      );
      return width == null ? divider : SizedBox(width: width, child: divider);
    }

    final theme = shad.Theme.of(context);
    final resolvedColor = color ?? theme.colorScheme.border;
    final resolvedThickness = thickness ?? 1;
    final resolvedWidth =
        width ?? (resolvedChild == null ? resolvedThickness : 24);
    final resolvedPadding =
        padding ??
        EdgeInsets.symmetric(vertical: theme.density.baseGap * theme.scaling);

    Widget line({double top = 0, double bottom = 0}) => Expanded(
      child: Padding(
        padding: EdgeInsets.only(top: top, bottom: bottom),
        child: Center(
          child: SizedBox(
            width: resolvedThickness,
            height: double.infinity,
            child: ColoredBox(color: resolvedColor),
          ),
        ),
      ),
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedHeight =
            height ??
            (constraints.hasBoundedHeight ? constraints.maxHeight : 16);
        if (resolvedChild == null) {
          return SizedBox(
            width: resolvedWidth,
            height: resolvedHeight,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [line(top: indent ?? 0, bottom: endIndent ?? 0)],
            ),
          );
        }

        final renderedLabel = DefaultTextStyle.merge(
          style: TextStyle(
            color: theme.colorScheme.mutedForeground,
            fontSize: 12 * theme.scaling,
          ),
          child: Padding(padding: resolvedPadding, child: resolvedChild),
        );
        return SizedBox(
          width: resolvedWidth,
          height: resolvedHeight,
          child: Column(
            children: [
              line(top: indent ?? 0),
              renderedLabel,
              line(bottom: endIndent ?? 0),
            ],
          ),
        );
      },
    );
  }
}
