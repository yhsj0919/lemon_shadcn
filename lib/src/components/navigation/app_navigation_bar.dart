import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_visual_style.dart';

typedef AppNavigationBar = shad.NavigationBar;
typedef AppNavigationButton = shad.NavigationButton;
typedef AppNavigationBarAlignment = shad.NavigationBarAlignment;
typedef AppNavigationRailAlignment = shad.NavigationRailAlignment;
typedef AppNavigationContainerType = shad.NavigationContainerType;
typedef AppNavigationLabelType = shad.NavigationLabelType;
typedef AppNavigationLabelPosition = shad.NavigationLabelPosition;
typedef AppNavigationLabelSize = shad.NavigationLabelSize;

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
    this.overflow = shad.NavigationOverflow.clip,
    this.marginAlignment,
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

  @override
  Widget build(BuildContext context) {
    return shad.NavigationItem(
      key: key,
      label: label,
      selected: selected,
      onChanged: onChanged,
      style: _withControlPalette(
        style ?? const shad.ButtonStyle.ghost(),
        selected: false,
      ),
      selectedStyle: _withControlPalette(
        selectedStyle ?? const shad.ButtonStyle.secondary(),
        selected: true,
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
}) {
  Set<WidgetState> effectiveStates(Set<WidgetState> states) => {
    ...states,
    if (selected) WidgetState.selected,
  };

  return base.copyWith(
    decoration: (context, states, decoration) {
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
      final colors = resolveAppControlVisuals(context, effectiveStates(states));
      return textStyle.copyWith(color: colors?.foreground);
    },
    iconTheme: (context, states, iconTheme) {
      final colors = resolveAppControlVisuals(context, effectiveStates(states));
      return iconTheme.copyWith(color: colors?.foreground);
    },
  );
}
