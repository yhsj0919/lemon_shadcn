import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

typedef AppAnimatedValueBuilder<T> = shad.AnimatedValueBuilder<T>;
typedef AppRepeatedAnimationBuilder = shad.RepeatedAnimationBuilder;
typedef AppDotIndicator = shad.DotIndicator;
typedef AppSelectableText = shad.SelectableText;
typedef AppRefreshTrigger = shad.RefreshTrigger;
typedef AppSwiper = shad.Swiper;
typedef AppBackdropTransform = shad.BackdropTransform;
typedef AppScaleBackdropTransform = shad.ScaleBackdropTransform;
typedef AppNoBackdropTransform = shad.NoBackdropTransform;

/// Scrolls overflowing content automatically or only while it is hovered.
class AppOverflowMarquee extends StatefulWidget {
  const AppOverflowMarquee({
    super.key,
    required this.child,
    this.direction,
    this.duration,
    this.delayDuration,
    this.step,
    this.fadePortion,
    this.curve,
  }) : startOnHover = false;

  /// Keeps content still until the pointer enters, and resets it when the
  /// pointer leaves.
  const AppOverflowMarquee.hover({
    super.key,
    required this.child,
    this.direction,
    this.duration,
    this.delayDuration,
    this.step,
    this.fadePortion,
    this.curve,
  }) : startOnHover = true;

  final Widget child;
  final Axis? direction;
  final Duration? duration;
  final Duration? delayDuration;
  final double? step;
  final double? fadePortion;
  final Curve? curve;
  final bool startOnHover;

  @override
  State<AppOverflowMarquee> createState() => _AppOverflowMarqueeState();
}

class _AppOverflowMarqueeState extends State<AppOverflowMarquee> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final shouldAnimate = !reduceMotion && (!widget.startOnHover || _hovered);
    final content = shouldAnimate
        ? shad.OverflowMarquee(
            direction: widget.direction,
            duration: widget.duration,
            delayDuration: widget.delayDuration,
            step: widget.step,
            fadePortion: widget.fadePortion,
            curve: widget.curve,
            child: widget.child,
          )
        : ClipRect(child: widget.child);

    if (!widget.startOnHover) return content;
    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: content,
    );
  }
}

/// Low-level scrollbar that requires the same controller as its ScrollView.
class AppScrollbar extends StatelessWidget {
  const AppScrollbar({
    super.key,
    required this.controller,
    required this.child,
    this.thumbVisibility,
    this.trackVisibility,
    this.thickness,
    this.radius,
    this.color,
    this.notificationPredicate,
    this.interactive,
    this.scrollbarOrientation,
  });

  final ScrollController controller;
  final Widget child;
  final bool? thumbVisibility;
  final bool? trackVisibility;
  final double? thickness;
  final Radius? radius;
  final Color? color;
  final ScrollNotificationPredicate? notificationPredicate;
  final bool? interactive;
  final ScrollbarOrientation? scrollbarOrientation;

  @override
  Widget build(BuildContext context) {
    return shad.Scrollbar(
      controller: controller,
      thumbVisibility: thumbVisibility,
      trackVisibility: trackVisibility,
      thickness: thickness,
      radius: radius,
      color: color,
      notificationPredicate: notificationPredicate,
      interactive: interactive,
      scrollbarOrientation: scrollbarOrientation,
      child: child,
    );
  }
}

/// Ready-to-use scrollbar and [SingleChildScrollView] pair.
///
/// When [controller] is omitted, this widget owns and disposes one. This is
/// the preferred entry point for ordinary content because the scrollbar and
/// scroll view cannot accidentally use different controllers.
class AppScrollbarView extends StatefulWidget {
  const AppScrollbarView({
    super.key,
    required this.child,
    this.controller,
    this.scrollDirection = Axis.vertical,
    this.reverse = false,
    this.padding,
    this.physics,
    this.thumbVisibility,
    this.trackVisibility,
    this.thickness,
    this.radius,
    this.color,
    this.interactive,
    this.scrollbarOrientation,
  });

  final Widget child;
  final ScrollController? controller;
  final Axis scrollDirection;
  final bool reverse;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;
  final bool? thumbVisibility;
  final bool? trackVisibility;
  final double? thickness;
  final Radius? radius;
  final Color? color;
  final bool? interactive;
  final ScrollbarOrientation? scrollbarOrientation;

  @override
  State<AppScrollbarView> createState() => _AppScrollbarViewState();
}

class _AppScrollbarViewState extends State<AppScrollbarView> {
  ScrollController? _ownedController;

  ScrollController get _controller =>
      widget.controller ?? (_ownedController ??= ScrollController());

  @override
  void didUpdateWidget(covariant AppScrollbarView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller == null && widget.controller != null) {
      _ownedController?.dispose();
      _ownedController = null;
    }
  }

  @override
  void dispose() {
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return AppScrollbar(
      controller: controller,
      thumbVisibility: widget.thumbVisibility,
      trackVisibility: widget.trackVisibility,
      thickness: widget.thickness,
      radius: widget.radius,
      color: widget.color,
      interactive: widget.interactive,
      scrollbarOrientation: widget.scrollbarOrientation,
      child: SingleChildScrollView(
        controller: controller,
        primary: false,
        scrollDirection: widget.scrollDirection,
        reverse: widget.reverse,
        padding: widget.padding,
        physics: widget.physics,
        child: widget.child,
      ),
    );
  }
}

/// Product-facing skeleton entry point over shadcn's theme-aware extension.
class AppSkeleton extends StatelessWidget {
  const AppSkeleton({
    super.key,
    required this.child,
    this.enabled = true,
    this.leaf = false,
    this.unite = false,
    this.replacement,
  });

  final Widget child;
  final bool enabled;
  final bool leaf;
  final bool unite;
  final Widget? replacement;

  @override
  Widget build(BuildContext context) => child.asSkeleton(
    enabled: enabled,
    leaf: leaf,
    unite: unite,
    replacement: replacement,
  );
}
