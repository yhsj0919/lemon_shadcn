import 'package:flutter/widgets.dart';

import 'app_shadcn_scope.dart';

/// Applies the globally configured default interactive-control height.
class AppControlBox extends StatelessWidget {
  const AppControlBox({
    super.key,
    required this.child,
    this.height,
    this.square = false,
  });

  final Widget child;
  final double? height;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final resolvedHeight =
        height ?? AppTheme.maybeOf(context)?.controls.height ?? 36;
    return SizedBox(
      height: resolvedHeight,
      width: square ? resolvedHeight : null,
      child: child,
    );
  }
}
