import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Shared sizing for compact labels such as chips and badges.
abstract final class AppCompactLabelStyle {
  static const double fontSize = 14;
  static const double lineHeight = 1.2;
  static const EdgeInsetsGeometry padding =
      EdgeInsets.symmetric(horizontal: 10, vertical: 6);

  static shad.AbstractButtonStyle apply(shad.AbstractButtonStyle base) {
    return base.copyWith(
      padding: (context, states, current) => padding,
      textStyle: (context, states, current) => current.copyWith(
        fontSize: fontSize,
        height: lineHeight,
      ),
    );
  }
}
