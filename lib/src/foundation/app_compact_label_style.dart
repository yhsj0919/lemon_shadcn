import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Shared sizing for compact labels such as chips and badges.
abstract final class AppCompactLabelStyle {
  static const double fontSize = 14;
  static const double lineHeight = 1.2;
  static const EdgeInsetsGeometry padding = EdgeInsets.symmetric(
    horizontal: 10,
    vertical: 6,
  );
  static const double badgeFontSize = 12;
  static const double badgeHeight = 19;
  static const EdgeInsetsGeometry badgePadding = EdgeInsets.symmetric(
    horizontal: 8,
  );

  static shad.AbstractButtonStyle apply(shad.AbstractButtonStyle base) {
    return base.copyWith(
      padding: (context, states, current) => padding,
      textStyle: (context, states, current) =>
          current.copyWith(fontSize: fontSize, height: lineHeight),
    );
  }

  static shad.AbstractButtonStyle applyBadge(shad.AbstractButtonStyle base) {
    return base.copyWith(
      decoration: (context, states, current) {
        if (current is BoxDecoration) {
          return current.copyWith(borderRadius: BorderRadius.circular(999));
        }
        return current;
      },
      padding: (context, states, current) => badgePadding,
      textStyle: (context, states, current) =>
          current.copyWith(fontSize: badgeFontSize),
    );
  }
}
