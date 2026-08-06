import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../motion/app_page_transition.dart';
import 'app_shadcn_scope.dart';
import 'app_theme_config.dart';

/// Shared visual and layout tokens for application overlays.
abstract final class AppOverlayStyle {
  static const EdgeInsets compactPadding = EdgeInsets.symmetric(
    horizontal: 12,
    vertical: 10,
  );
  static const EdgeInsets toastPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const BorderRadiusGeometry surfaceBorderRadius = BorderRadius.all(
    Radius.circular(8),
  );

  static const AlignmentGeometry popoverAlignment = Alignment.topCenter;
  static const AlignmentGeometry popoverAnchorAlignment =
      Alignment.bottomCenter;
  static const Offset popoverOffset = Offset(0, 8);

  static bool isDark(BuildContext context) =>
      shad.Theme.of(context).brightness == Brightness.dark;

  static Color modalBarrier(BuildContext context) =>
      Color.fromRGBO(0, 0, 0, isDark(context) ? 0.38 : 0.20);

  static List<BoxShadow> floatingShadows(BuildContext context) {
    final config = AppTheme.maybeOf(context);
    if (config != null) {
      return config.shadows.resolve(
        context,
        level: AppShadowLevel.floating,
        quality: AppPageTransitionScope.shadowQualityOf(context),
      );
    }
    final dark = isDark(context);
    return [
      BoxShadow(
        color: dark ? const Color(0x52000000) : const Color(0x1f000000),
        blurRadius: 16,
        spreadRadius: -2,
        offset: const Offset(0, 3),
      ),
    ];
  }

  static shad.CardTheme cardTheme(
    BuildContext context, {
    EdgeInsetsGeometry? padding,
    BorderRadiusGeometry? borderRadius,
  }) {
    return shad.CardTheme(
      padding: padding,
      borderRadius: borderRadius,
      boxShadow: floatingShadows(context),
    );
  }
}

/// Applies the shared card styling used by floating overlay surfaces.
class AppOverlaySurfaceTheme extends StatelessWidget {
  const AppOverlaySurfaceTheme({
    super.key,
    required this.child,
    this.padding = AppOverlayStyle.compactPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return shad.ComponentTheme<shad.CardTheme>(
      data: AppOverlayStyle.cardTheme(
        context,
        padding: padding,
        borderRadius: AppOverlayStyle.surfaceBorderRadius,
      ),
      child: child,
    );
  }
}

/// Adds the shared floating shadow without changing the child's own surface,
/// border, padding, or overlay behavior.
class AppOverlayShadow extends StatelessWidget {
  const AppOverlayShadow({super.key, required this.child, this.borderRadius});

  final Widget child;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: borderRadius ?? AppOverlayStyle.surfaceBorderRadius,
        boxShadow: AppOverlayStyle.floatingShadows(context),
      ),
      child: child,
    );
  }
}

/// Keeps anchored overlays in sync with window metrics and responsive anchor
/// layout changes. Custom App overlays should wrap their anchor with this
/// widget instead of maintaining component-specific resize listeners.
class AppOverlayAnchorTracker extends StatefulWidget {
  const AppOverlayAnchorTracker({
    super.key,
    required this.onGeometryChanged,
    required this.child,
    this.enabled = true,
  });

  final VoidCallback onGeometryChanged;
  final Widget child;
  final bool enabled;

  @override
  State<AppOverlayAnchorTracker> createState() =>
      _AppOverlayAnchorTrackerState();
}

class _AppOverlayAnchorTrackerState extends State<AppOverlayAnchorTracker>
    with WidgetsBindingObserver {
  bool _refreshScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didUpdateWidget(AppOverlayAnchorTracker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !oldWidget.enabled) _scheduleRefresh();
  }

  @override
  void didChangeMetrics() => _scheduleRefresh();

  void _scheduleRefresh() {
    if (!widget.enabled || _refreshScheduled) return;
    _refreshScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshScheduled = false;
      if (mounted && widget.enabled) widget.onGeometryChanged();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        _scheduleRefresh();
        return false;
      },
      child: SizeChangedLayoutNotifier(child: widget.child),
    );
  }
}
