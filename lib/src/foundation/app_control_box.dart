import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_shadcn_scope.dart';

/// Applies the globally configured default interactive-control height.
class AppControlBox extends StatelessWidget {
  const AppControlBox({
    super.key,
    required this.child,
    this.height,
    this.contentHeight,
    this.square = false,
  });

  final Widget child;
  final double? height;
  final double? contentHeight;
  final bool square;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final resolvedHeight =
        height ?? AppTheme.maybeOf(context)?.controls.height ?? 32;
    return shad.ComponentTheme(
      data: shad.FocusOutlineTheme(
        align: 0,
        border: Border.all(
          color: theme.colorScheme.ring,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: SizedBox(
        height: resolvedHeight,
        width: square ? resolvedHeight : null,
        child: contentHeight == null
            ? child
            : Center(
                child: SizedBox(height: contentHeight, child: child),
              ),
      ),
    );
  }
}
