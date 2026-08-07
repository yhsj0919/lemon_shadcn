import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_visual_style.dart';
import '../display/app_semantic_style.dart';

typedef AppNavigationButton = shad.NavigationButton;
typedef AppNavigationBarAlignment = shad.NavigationBarAlignment;
typedef AppNavigationRailAlignment = shad.NavigationRailAlignment;
typedef AppNavigationContainerType = shad.NavigationContainerType;
typedef AppNavigationLabelType = shad.NavigationLabelType;
typedef AppNavigationLabelPosition = shad.NavigationLabelPosition;
typedef AppNavigationLabelSize = shad.NavigationLabelSize;

/// Horizontal/vertical navigation bar with equal-width items by default.
class AppNavigationBar extends StatelessWidget {
  const AppNavigationBar({
    super.key,
    required this.children,
    this.alignment = AppNavigationBarAlignment.start,
    this.direction,
    this.labelType = AppNavigationLabelType.all,
    this.labelPosition = AppNavigationLabelPosition.bottom,
    this.labelSize = AppNavigationLabelSize.small,
    this.backgroundColor,
    this.padding,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.selectedKey,
    this.onSelected,
    this.expanded = false,
    this.keepCrossAxisSize,
    this.keepMainAxisSize,
    this.expandedSize,
    this.collapsedSize,
    this.spacing,
    this.equalWidth = true,
  });

  final List<Widget> children;
  final AppNavigationBarAlignment alignment;
  final Axis? direction;
  final AppNavigationLabelType labelType;
  final AppNavigationLabelPosition labelPosition;
  final AppNavigationLabelSize labelSize;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final Key? selectedKey;
  final ValueChanged<Key?>? onSelected;
  final bool expanded;
  final bool? keepCrossAxisSize;
  final bool? keepMainAxisSize;
  final double? expandedSize;
  final double? collapsedSize;
  final double? spacing;

  /// When true (default) and [direction] is horizontal, navigation items share
  /// equal width like a typical bottom navigation bar.
  final bool equalWidth;

  static bool _isNavigationItem(Widget child) {
    return child is AppNavigationItem ||
        child is shad.NavigationItem ||
        child is shad.NavigationButton;
  }

  @override
  Widget build(BuildContext context) {
    final axis = direction ?? Axis.horizontal;
    final useEqualWidth = equalWidth && axis == Axis.horizontal;
    final resolvedChildren = useEqualWidth
        ? [
            for (final child in children)
              if (_isNavigationItem(child))
                Expanded(child: Center(child: child))
              else
                child,
          ]
        : children;

    final bar = shad.NavigationBar(
      alignment: alignment,
      direction: direction,
      labelType: labelType,
      labelPosition: labelPosition,
      labelSize: labelSize,
      backgroundColor: backgroundColor,
      padding: padding,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
      selectedKey: selectedKey,
      onSelected: onSelected,
      expanded: expanded,
      keepCrossAxisSize: keepCrossAxisSize,
      keepMainAxisSize: keepMainAxisSize,
      expandedSize: expandedSize,
      collapsedSize: collapsedSize,
      spacing: spacing,
      children: resolvedChildren,
    );

    // Ensure equal-width items get a bounded main-axis extent.
    if (useEqualWidth) {
      return SizedBox(width: double.infinity, child: bar);
    }
    return bar;
  }
}

class AppNavigationItem extends StatelessWidget {
  const AppNavigationItem({
    super.key,
    required this.child,
    this.label,
    this.selected,
    this.onChanged,
    this.style,
    this.selectedStyle,
    this.spacing,
    this.alignment,
    this.enabled,
    this.overflow = shad.NavigationOverflow.ellipsis,
    this.marginAlignment,
    this.selectedColor,
  });

  final Widget child;
  final Widget? label;
  final bool? selected;
  final ValueChanged<bool>? onChanged;
  final shad.AbstractButtonStyle? style;
  final shad.AbstractButtonStyle? selectedStyle;
  final double? spacing;
  final AlignmentGeometry? alignment;
  final bool? enabled;
  final shad.NavigationOverflow overflow;
  final AlignmentGeometry? marginAlignment;
  final Color? selectedColor;

  @override
  Widget build(BuildContext context) {
    final data = shad.Data.maybeOf<shad.NavigationControlData>(context);
    final isSidebar =
        data?.containerType == shad.NavigationContainerType.sidebar;
    // Match upstream defaults: icon density for bar/rail, normal for sidebar.
    final defaultStyle = isSidebar
        ? const shad.ButtonStyle.ghost()
        : const shad.ButtonStyle.ghost(density: shad.ButtonDensity.icon);
    final defaultSelectedStyle = isSidebar
        ? const shad.ButtonStyle.secondary()
        : const shad.ButtonStyle.secondary(density: shad.ButtonDensity.icon);

    final resolvedLabel = label == null
        ? null
        : DefaultTextStyle.merge(
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            child: label!,
          );

    return shad.NavigationItem(
      key: key,
      label: resolvedLabel,
      selected: selected,
      onChanged: onChanged,
      style: _withControlPalette(style ?? defaultStyle, selected: false),
      selectedStyle:
          selectedStyle ??
          _withControlPalette(
            defaultSelectedStyle,
            selected: true,
            selectedColor: selectedColor,
          ),
      spacing: spacing,
      alignment: alignment,
      enabled: enabled,
      overflow: overflow,
      marginAlignment: marginAlignment,
      child: child,
    );
  }
}

shad.AbstractButtonStyle _withControlPalette(
  shad.AbstractButtonStyle base, {
  required bool selected,
  Color? selectedColor,
}) {
  Set<WidgetState> effectiveStates(Set<WidgetState> states) => {
    ...states,
    if (selected) WidgetState.selected,
  };

  return base.copyWith(
    decoration: (context, states, decoration) {
      if (selected) {
        final theme = shad.Theme.of(context);
        final color = selectedColor ?? theme.colorScheme.primary;
        if (decoration is BoxDecoration) {
          return decoration.copyWith(
            color: AppSoftColor.selectionBackground(theme, color),
          );
        }
      }
      final colors = resolveAppControlVisuals(context, effectiveStates(states));
      if (colors == null) return decoration;
      if (decoration is BoxDecoration) {
        return decoration.copyWith(
          color: colors.background ?? decoration.color,
          border: colors.border == null
              ? decoration.border
              : Border.all(color: colors.border!),
        );
      }
      if (decoration is ShapeDecoration && colors.background != null) {
        return ShapeDecoration(
          color: colors.background,
          image: decoration.image,
          gradient: decoration.gradient,
          shadows: decoration.shadows,
          shape: decoration.shape,
        );
      }
      return decoration;
    },
    textStyle: (context, states, textStyle) {
      if (selected) {
        return textStyle.copyWith(
          color: selectedColor ?? shad.Theme.of(context).colorScheme.primary,
        );
      }
      final colors = resolveAppControlVisuals(context, effectiveStates(states));
      return textStyle.copyWith(color: colors?.foreground);
    },
    iconTheme: (context, states, iconTheme) {
      if (selected) {
        return iconTheme.copyWith(
          color: selectedColor ?? shad.Theme.of(context).colorScheme.primary,
        );
      }
      final colors = resolveAppControlVisuals(context, effectiveStates(states));
      return iconTheme.copyWith(color: colors?.foreground);
    },
  );
}
