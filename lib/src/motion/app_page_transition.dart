import 'package:flutter/widgets.dart';

import '../foundation/app_shadow_types.dart';

/// Runtime phase exposed to expensive visual effects during a page change.
enum AppPageTransitionPhase { idle, entering, exiting }

/// Makes transition state available to shadows, motion, and opt-in heavy
/// subtrees without coupling those widgets to a navigator implementation.
class AppPageTransitionScope extends InheritedWidget {
  const AppPageTransitionScope({
    super.key,
    required this.phase,
    this.shadowQuality = AppShadowQuality.reduced,
    required super.child,
  });

  final AppPageTransitionPhase phase;
  final AppShadowQuality shadowQuality;

  bool get isTransitioning => phase != AppPageTransitionPhase.idle;

  static AppPageTransitionScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppPageTransitionScope>();

  static bool isAnimating(BuildContext context) =>
      maybeOf(context)?.isTransitioning ?? false;

  static AppShadowQuality shadowQualityOf(BuildContext context) {
    final scope = maybeOf(context);
    return scope?.isTransitioning == true
        ? scope!.shadowQuality
        : AppShadowQuality.normal;
  }

  @override
  bool updateShouldNotify(AppPageTransitionScope oldWidget) =>
      phase != oldWidget.phase || shadowQuality != oldWidget.shadowQuality;
}

/// Transition-friendly page switcher that isolates incoming and outgoing
/// pages and temporarily exposes reduced visual quality to their descendants.
class AppPageTransition extends StatelessWidget {
  const AppPageTransition({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 180),
    this.reverseDuration,
    this.curve = Curves.easeOutCubic,
    this.shadowQuality = AppShadowQuality.reduced,
    this.transitionBuilder,
    this.layoutBuilder = AnimatedSwitcher.defaultLayoutBuilder,
  });

  final Widget child;
  final Duration duration;
  final Duration? reverseDuration;
  final Curve curve;
  final AppShadowQuality shadowQuality;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final AnimatedSwitcherLayoutBuilder layoutBuilder;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final effectiveDuration = reduceMotion ? Duration.zero : duration;
    return AnimatedSwitcher(
      duration: effectiveDuration,
      reverseDuration: reduceMotion
          ? Duration.zero
          : (reverseDuration ?? duration),
      layoutBuilder: layoutBuilder,
      transitionBuilder: (child, animation) => _TransitionBoundary(
        animation: animation,
        curve: curve,
        shadowQuality: shadowQuality,
        transitionBuilder: transitionBuilder,
        child: child,
      ),
      child: child,
    );
  }
}

class _TransitionBoundary extends StatelessWidget {
  const _TransitionBoundary({
    required this.animation,
    required this.curve,
    required this.shadowQuality,
    required this.transitionBuilder,
    required this.child,
  });

  final Animation<double> animation;
  final Curve curve;
  final AppShadowQuality shadowQuality;
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(parent: animation, curve: curve);
    return AnimatedBuilder(
      animation: animation,
      child: RepaintBoundary(
        child:
            transitionBuilder?.call(child, curved) ??
            FadeTransition(opacity: curved, child: child),
      ),
      builder: (context, child) {
        final status = animation.status;
        final phase = switch (status) {
          AnimationStatus.forward => AppPageTransitionPhase.entering,
          AnimationStatus.reverse => AppPageTransitionPhase.exiting,
          AnimationStatus.completed ||
          AnimationStatus.dismissed => AppPageTransitionPhase.idle,
        };
        return AppPageTransitionScope(
          phase: phase,
          shadowQuality: shadowQuality,
          child: child!,
        );
      },
    );
  }
}

/// Explicitly postpones a non-essential expensive subtree while its enclosing
/// page is transitioning. Essential form content should not use this widget.
class AppDeferredDuringTransition extends StatelessWidget {
  const AppDeferredDuringTransition({
    super.key,
    required this.child,
    this.placeholder = const SizedBox.shrink(),
  });

  final Widget child;
  final Widget placeholder;

  @override
  Widget build(BuildContext context) =>
      AppPageTransitionScope.isAnimating(context) ? placeholder : child;
}
