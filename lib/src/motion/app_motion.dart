import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../foundation/app_shadcn_scope.dart';
import '../foundation/app_theme_config.dart';
import '../foundation/app_visual_style.dart';

enum AppMotionEffect { none, tint, lift, scale, glow, depth }

class AppMotion extends StatefulWidget {
  const AppMotion({
    super.key,
    required this.child,
    this.effect = AppMotionEffect.lift,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.borderRadius,
    this.cursor,
  });

  const AppMotion.lift({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.lift;

  const AppMotion.scale({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.scale;

  const AppMotion.tint({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.tint;

  const AppMotion.glow({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.glow;

  const AppMotion.depth({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.depth;

  final Widget child;
  final AppMotionEffect effect;
  final bool enabled;
  final AppShadowColorMode? shadowColorMode;
  final Color? shadowColor;
  final BorderRadiusGeometry? borderRadius;
  final MouseCursor? cursor;

  @override
  State<AppMotion> createState() => _AppMotionState();
}

class _AppMotionState extends State<AppMotion> {
  bool _hovered = false;
  bool _pressed = false;
  double _depthX = 0;
  double _depthY = 0;

  void _setHovered(bool value) {
    if (!widget.enabled || _hovered == value) return;
    setState(() => _hovered = value);
  }

  void _setPressed(bool value) {
    if (!widget.enabled || _pressed == value) return;
    setState(() => _pressed = value);
  }

  void _updateDepth(PointerHoverEvent event) {
    if (!widget.enabled || widget.effect != AppMotionEffect.depth) return;
    final size = context.size;
    if (size == null || size.isEmpty) return;
    final x = ((event.localPosition.dx / size.width) * 2 - 1)
        .clamp(-1, 1)
        .toDouble();
    final y = ((event.localPosition.dy / size.height) * 2 - 1)
        .clamp(-1, 1)
        .toDouble();
    if ((_depthX - x).abs() < 0.01 && (_depthY - y).abs() < 0.01) return;
    setState(() {
      _depthX = x;
      _depthY = y;
    });
  }

  @override
  void didUpdateWidget(AppMotion oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.enabled && (_hovered || _pressed)) {
      _hovered = false;
      _pressed = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppTheme.maybeOf(context) ?? AppThemeConfig.standard();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final animate = widget.enabled && config.motion.enabled && !reduceMotion;
    final activeHover = animate && _hovered && !_pressed;
    final activePress = animate && _pressed;
    final scale = activePress
        ? config.motion.pressedScale
        : activeHover &&
              (widget.effect == AppMotionEffect.scale ||
                  widget.effect == AppMotionEffect.lift)
        ? config.motion.hoverScale
        : 1.0;
    final offset = activeHover && widget.effect == AppMotionEffect.lift
        ? config.motion.hoverOffset
        : Offset.zero;
    final showShadow =
        activeHover &&
        (widget.effect == AppMotionEffect.lift ||
            widget.effect == AppMotionEffect.glow ||
            widget.effect == AppMotionEffect.depth);
    final tint = activeHover && widget.effect == AppMotionEffect.tint
        ? _resolveShadowColor(context, config).withValues(alpha: 0.08)
        : null;

    final transform = Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setTranslationRaw(offset.dx, offset.dy, 0);

    final surface = widget.effect == AppMotionEffect.depth
        ? TweenAnimationBuilder<_DepthTilt>(
            tween: _DepthTiltTween(
              end: _DepthTilt(
                x: animate && _hovered ? _depthX : 0,
                y: animate && _hovered ? _depthY : 0,
              ),
            ),
            duration: animate ? config.motion.depthTiltDuration : Duration.zero,
            curve: Curves.easeOutCubic,
            builder: (context, tilt, child) {
              final elevationTarget = !animate || !_hovered
                  ? 0.0
                  : _pressed
                  ? 1 - config.motion.depthPressAmount
                  : 1.0;
              final elevationDuration = !animate
                  ? Duration.zero
                  : _pressed
                  ? config.motion.depthPressDuration
                  : config.motion.depthDuration;
              final elevationCurve = _hovered && !_pressed
                  ? Curves.easeOutBack
                  : Curves.easeOutCubic;
              return TweenAnimationBuilder<double>(
                tween: Tween<double>(end: elevationTarget),
                duration: elevationDuration,
                curve: elevationCurve,
                builder: (context, elevation, child) {
                  final lift = config.motion.depthOffsetY * elevation;
                  final z = config.motion.depthTranslateZ * elevation;
                  final matrix = Matrix4.identity()
                    ..setEntry(3, 2, config.motion.depthPerspective)
                    ..setTranslationRaw(0, lift, z)
                    ..rotateX(tilt.y * config.motion.depthRotateY * 0.72)
                    ..rotateY(-tilt.x * config.motion.depthRotateY);
                  return Transform(
                    transform: matrix,
                    alignment: Alignment.center,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: widget.borderRadius,
                        boxShadow: _resolveShadows(
                          context,
                          config,
                          intensity: elevation.clamp(0, 1).toDouble(),
                        ),
                      ),
                      child: child,
                    ),
                  );
                },
                child: child,
              );
            },
            child: widget.child,
          )
        : AnimatedContainer(
            duration: animate ? config.motion.duration : Duration.zero,
            curve: Curves.easeOutCubic,
            transform: transform,
            transformAlignment: Alignment.center,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: widget.borderRadius,
              boxShadow: showShadow
                  ? _resolveShadows(context, config)
                  : const [],
            ),
            child: widget.child,
          );

    return MouseRegion(
      cursor: widget.cursor ?? MouseCursor.defer,
      onEnter: (_) => _setHovered(true),
      onHover: _updateDepth,
      onExit: (_) {
        _setHovered(false);
        if (_depthX != 0 || _depthY != 0) {
          setState(() {
            _depthX = 0;
            _depthY = 0;
          });
        }
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _setPressed(true),
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: surface,
      ),
    );
  }

  Color _resolveShadowColor(BuildContext context, AppThemeConfig config) {
    final visual = AppVisualStyle.maybeOf(context);
    final colors = shad.Theme.of(context).colorScheme;
    final mode = widget.shadowColorMode ?? config.shadows.colorMode;
    final source = switch (mode) {
      AppShadowColorMode.custom => widget.shadowColor,
      AppShadowColorMode.background => visual?.background,
      AppShadowColorMode.border => visual?.border,
      AppShadowColorMode.accent => visual?.accent,
      AppShadowColorMode.primary => colors.primary,
      AppShadowColorMode.auto =>
        widget.shadowColor ??
            visual?.shadow ??
            visual?.border ??
            visual?.accent ??
            visual?.background ??
            colors.primary,
    };
    return _soften(source ?? colors.primary);
  }

  List<BoxShadow> _resolveShadows(
    BuildContext context,
    AppThemeConfig config, {
    double intensity = 1,
  }) {
    final theme = config.shadows;
    if (!theme.enabled) return const [];
    final color = _resolveShadowColor(context, config);
    final dark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final colorOpacity = dark ? theme.darkColorOpacity : theme.colorOpacity;
    return [
      BoxShadow(
        color: color.withValues(alpha: theme.ambientOpacity * intensity),
        blurRadius: theme.blurRadius * 0.45,
        offset: theme.offset * 0.35,
      ),
      BoxShadow(
        color: color.withValues(alpha: colorOpacity * intensity),
        blurRadius: theme.blurRadius,
        spreadRadius: theme.spreadRadius,
        offset: theme.offset,
      ),
    ];
  }

  Color _soften(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withSaturation((hsl.saturation * 0.72).clamp(0, 1)).toColor();
  }
}

@immutable
class _DepthTilt {
  const _DepthTilt({this.x = 0, this.y = 0});

  final double x;
  final double y;

  static _DepthTilt lerp(_DepthTilt left, _DepthTilt right, double t) {
    return _DepthTilt(
      x: left.x + (right.x - left.x) * t,
      y: left.y + (right.y - left.y) * t,
    );
  }
}

class _DepthTiltTween extends Tween<_DepthTilt> {
  _DepthTiltTween({required _DepthTilt end}) : super(end: end);

  @override
  _DepthTilt lerp(double t) => _DepthTilt.lerp(begin ?? end!, end!, t);
}
