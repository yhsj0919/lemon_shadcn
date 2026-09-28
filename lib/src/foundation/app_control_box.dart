import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_shadcn_scope.dart';
import 'app_theme_config.dart';

/// Locally overrides control dimensions without replacing the application
/// theme. Useful when standard controls are embedded in dense surfaces.
class AppControlMetricsScope extends InheritedWidget {
  const AppControlMetricsScope({
    super.key,
    required this.metrics,
    this.enforceSafeHeight = false,
    required super.child,
  });

  final AppControlMetrics metrics;
  final bool enforceSafeHeight;

  static AppControlMetrics resolve(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AppControlMetricsScope>()
          ?.metrics ??
      AppTheme.maybeOf(context)?.controls ??
      const AppControlMetrics();

  static bool shouldEnforceSafeHeight(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AppControlMetricsScope>()
          ?.enforceSafeHeight ??
      true;

  @override
  bool updateShouldNotify(AppControlMetricsScope oldWidget) =>
      metrics != oldWidget.metrics ||
      enforceSafeHeight != oldWidget.enforceSafeHeight;
}

/// Overrides the height of every form control in this subtree.
///
/// This is the per-control counterpart to [AppThemeConfig.controls]. Controls
/// treat the requested height as a minimum so text, icons, validation content,
/// and platform text scaling are not clipped when they need more room.
class AppControlHeight extends StatelessWidget {
  const AppControlHeight({
    super.key,
    required this.height,
    this.textAreaHeight,
    required this.child,
  }) : assert(height > 0),
       assert(textAreaHeight == null || textAreaHeight > 0);

  final double height;

  /// Optional independent minimum for multiline controls. When omitted,
  /// [height] is used for both single-line and multiline form controls.
  final double? textAreaHeight;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inherited = AppControlMetricsScope.resolve(context);
    return AppControlMetricsScope(
      metrics: inherited.copyWith(
        height: height,
        textAreaHeight: textAreaHeight ?? height,
      ),
      enforceSafeHeight: true,
      child: child,
    );
  }
}

/// Applies the globally configured default interactive-control height.
class AppControlBox extends StatelessWidget {
  const AppControlBox({
    super.key,
    required this.child,
    this.height,
    this.contentHeight,
    this.square = false,
    this.alignment = Alignment.center,
    this.showFocusOutline = true,
  });

  final Widget child;
  final double? height;
  final double? contentHeight;
  final bool square;
  final AlignmentGeometry alignment;
  final bool showFocusOutline;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final metrics = AppControlMetricsScope.resolve(context);
    final scaledTextHeight =
        MediaQuery.textScalerOf(context).scale(metrics.fontSize) * 1.2 + 12;
    final iconHeight = metrics.iconSize + 12;
    final safeContentHeight = scaledTextHeight > iconHeight
        ? scaledTextHeight
        : iconHeight;
    final themedHeight = AppControlMetricsScope.shouldEnforceSafeHeight(context)
        ? (metrics.height > safeContentHeight
              ? metrics.height
              : safeContentHeight)
        : metrics.height;
    // A component's explicit height (for example compact density) is
    // intentional. Theme/subtree heights are guarded by the content floor.
    final resolvedHeight = height ?? themedHeight;
    final content = contentHeight == null
        ? child
        : Align(
            alignment: alignment,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: contentHeight!),
              child: child,
            ),
          );
    final control = SizedBox(
      height: resolvedHeight,
      width: square ? resolvedHeight : null,
      child: content,
    );
    if (!showFocusOutline) return control;
    return shad.ComponentTheme(
      data: shad.FocusOutlineTheme(
        align: 0,
        border: Border.all(
          color: theme.colorScheme.ring,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: control,
    );
  }
}
