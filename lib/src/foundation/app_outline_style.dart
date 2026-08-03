import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Shared decoration states for outline controls.
abstract final class AppOutlineStyle {
  static Decoration resolve(
    BuildContext context,
    Set<WidgetState> states,
    Decoration current, {
    Color? borderColor,
  }) {
    if (current is! BoxDecoration) return current;
    final colors = shad.Theme.of(context).colorScheme;
    final disabled = states.contains(WidgetState.disabled);
    final hovered = states.contains(WidgetState.hovered);
    final resolvedBorder = borderColor ?? colors.border;
    return current.copyWith(
      color: !disabled && hovered ? colors.accent : current.color,
      border: Border.all(
        color: disabled
            ? resolvedBorder.withValues(alpha: 0.5)
            : resolvedBorder,
        width: 1,
        strokeAlign: BorderSide.strokeAlignInside,
      ),
    );
  }
}
