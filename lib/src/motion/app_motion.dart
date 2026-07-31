import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../foundation/app_shadcn_scope.dart';
import '../foundation/app_theme_config.dart';
import '../foundation/app_visual_style.dart';
import 'app_hover_press_ticker.dart';

enum AppMotionEffect { none, tint, lift, scale, glow, depth }

enum AppEntranceEffect { fade, slideUp, scale }

/// Ready-to-use one-shot entrance animations.
class AppEntranceAnimation extends StatelessWidget {
  const AppEntranceAnimation.fade({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 240),
    this.curve = Curves.easeOutCubic,
  }) : effect = AppEntranceEffect.fade;

  const AppEntranceAnimation.slideUp({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 280),
    this.curve = Curves.easeOutCubic,
  }) : effect = AppEntranceEffect.slideUp;

  const AppEntranceAnimation.scale({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutBack,
  }) : effect = AppEntranceEffect.scale;

  final Widget child;
  final AppEntranceEffect effect;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return shad.AnimatedValueBuilder<double>(
      initialValue: 0,
      value: 1,
      duration: reduceMotion ? Duration.zero : duration,
      curve: curve,
      child: child,
      builder: (context, value, child) => switch (effect) {
        AppEntranceEffect.fade => Opacity(opacity: value, child: child),
        AppEntranceEffect.slideUp => Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - value)),
            child: child,
          ),
        ),
        AppEntranceEffect.scale => Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.scale(scale: 0.92 + 0.08 * value, child: child),
        ),
      },
    );
  }
}

enum AppLoopEffect { pulse, float }

/// Ready-to-use continuous animations with seamless ping-pong playback.
class AppLoopAnimation extends StatelessWidget {
  const AppLoopAnimation.pulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 900),
    this.curve = Curves.easeInOut,
    this.play = true,
  }) : effect = AppLoopEffect.pulse;

  const AppLoopAnimation.float({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1200),
    this.curve = Curves.easeInOut,
    this.play = true,
  }) : effect = AppLoopEffect.float;

  final Widget child;
  final AppLoopEffect effect;
  final Duration duration;
  final Curve curve;
  final bool play;

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return shad.RepeatedAnimationBuilder<double>(
      start: 0,
      end: 1,
      duration: duration,
      curve: curve,
      mode: shad.LoopingMode.pingPong,
      play: play && !reduceMotion,
      child: child,
      builder: (context, value, child) => switch (effect) {
        AppLoopEffect.pulse => Transform.scale(
          scale: 0.82 + value * 0.18,
          child: child,
        ),
        AppLoopEffect.float => Transform.translate(
          offset: Offset(0, -6 * value),
          child: child,
        ),
      },
    );
  }
}

class AppMotion extends StatefulWidget {
  const AppMotion({
    super.key,
    required this.child,
    this.effect = AppMotionEffect.lift,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.hoverLift = false,
    this.borderRadius,
    this.cursor,
  });

  const AppMotion.lift({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.hoverLift = false,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.lift;

  const AppMotion.scale({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.hoverLift = false,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.scale;

  const AppMotion.tint({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.hoverLift = false,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.tint;

  const AppMotion.glow({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.hoverLift = false,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.glow;

  const AppMotion.depth({
    super.key,
    required this.child,
    this.enabled = true,
    this.shadowColorMode,
    this.shadowColor,
    this.hoverLift = false,
    this.borderRadius,
    this.cursor,
  }) : effect = AppMotionEffect.depth;

  final Widget child;
  final AppMotionEffect effect;
  final bool enabled;
  final AppShadowColorMode? shadowColorMode;
  final Color? shadowColor;
  final bool hoverLift;
  final BorderRadiusGeometry? borderRadius;
  final MouseCursor? cursor;

  @override
  State<AppMotion> createState() => _AppMotionState();
}

class _AppMotionState extends State<AppMotion> with TickerProviderStateMixin {
  late final AppHoverPressTicker _ticker = AppHoverPressTicker(this);
  double _depthX = 0;
  double _depthY = 0;
  bool _hovered = false;
  bool _pressed = false;

  AppMotionTokens _tokens(AppThemeConfig config) => config.motion.tokens;

  bool _canAnimate(AppThemeConfig config) {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return widget.enabled && config.motion.enabled && !reduce;
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _setHovered(bool value, AppThemeConfig config) {
    if (!widget.enabled || _hovered == value) return;
    _hovered = value;
    _ticker.setHover(
      value,
      animate: _canAnimate(config),
      tokens: _tokens(config),
    );
  }

  void _setPressed(bool value, AppThemeConfig config) {
    if (!widget.enabled || _pressed == value) return;
    _pressed = value;
    _ticker.setPress(
      value,
      animate: _canAnimate(config),
      tokens: _tokens(config),
    );
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
      _ticker.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppTheme.maybeOf(context) ?? AppThemeConfig.standard();
    final tokens = _tokens(config);
    final animate = _canAnimate(config);
    _ticker.sync(tokens);

    final borderRadius =
        widget.borderRadius ?? shad.Theme.of(context).borderRadiusLg;

    final surface = widget.effect == AppMotionEffect.depth
        ? _buildDepth(config, borderRadius, animate, tokens)
        : AnimatedBuilder(
            animation: _ticker.listenable,
            builder: (context, child) {
              final hoverT = animate ? _ticker.hover.value : (_hovered ? 1.0 : 0.0);
              final pressT = animate ? _ticker.press.value : (_pressed ? 1.0 : 0.0);
              final settled = hoverT * (1.0 - pressT * 0.72);
              final hoverScaleEffect =
                  widget.effect == AppMotionEffect.scale ||
                  widget.effect == AppMotionEffect.lift;
              final scale =
                  1.0 +
                  (tokens.hoverScale - 1.0) *
                      hoverT *
                      (1.0 - pressT) *
                      (hoverScaleEffect ? 1.0 : 0.0) +
                  (tokens.pressedScale - 1.0) * pressT;
              final liftFactor = widget.effect == AppMotionEffect.lift
                  ? 1.0
                  : widget.hoverLift
                  ? 0.5
                  : 0.0;
              final offset = tokens.hoverOffset * settled * liftFactor;
              final shadowCapable =
                  widget.effect == AppMotionEffect.lift ||
                  widget.effect == AppMotionEffect.glow;
              final shadowIntensity =
                  (shadowCapable ? settled : 0.0) *
                  (widget.shadowColorMode == AppShadowColorMode.background
                      ? 2.4
                      : 1.0);
              final tint = widget.effect == AppMotionEffect.tint
                  ? _resolveShadowColor(context, config).withValues(
                      alpha: 0.08 * settled.clamp(0.0, 1.0),
                    )
                  : null;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(0, 0, scale)
                  ..setEntry(1, 1, scale)
                  ..setTranslationRaw(offset.dx, offset.dy, 0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: borderRadius,
                    boxShadow: _resolveShadows(
                      context,
                      config,
                      intensity: shadowIntensity,
                    ),
                  ),
                  foregroundDecoration: tint == null
                      ? null
                      : BoxDecoration(color: tint, borderRadius: borderRadius),
                  child: child,
                ),
              );
            },
            child: widget.child,
          );

    return MouseRegion(
      cursor: widget.cursor ?? MouseCursor.defer,
      onEnter: (_) => _setHovered(true, config),
      onHover: _updateDepth,
      onExit: (_) {
        _setHovered(false, config);
        _setPressed(false, config);
        if (_depthX != 0 || _depthY != 0) {
          setState(() {
            _depthX = 0;
            _depthY = 0;
          });
        }
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) => _setPressed(true, config),
        onPointerUp: (_) => _setPressed(false, config),
        onPointerCancel: (_) => _setPressed(false, config),
        child: surface,
      ),
    );
  }

  Widget _buildDepth(
    AppThemeConfig config,
    BorderRadiusGeometry borderRadius,
    bool animate,
    AppMotionTokens tokens,
  ) {
    final hovered = animate && _hovered;
    final pressed = animate && _pressed;
    return TweenAnimationBuilder<_DepthTilt>(
      tween: _DepthTiltTween(
        end: _DepthTilt(x: hovered ? _depthX : 0, y: hovered ? _depthY : 0),
      ),
      duration: animate ? config.motion.depthTiltDuration : Duration.zero,
      curve: Curves.easeInOutCubic,
      builder: (context, tilt, child) {
        final elevationTarget = !hovered
            ? 0.0
            : pressed
            ? 1 - config.motion.depthPressAmount
            : 1.0;
        return TweenAnimationBuilder<double>(
          tween: Tween<double>(end: elevationTarget),
          duration: !animate
              ? Duration.zero
              : pressed
              ? tokens.pressDuration
              : config.motion.depthDuration,
          curve: hovered && !pressed
              ? Curves.easeOutCubic
              : Curves.easeInOutCubic,
          builder: (context, elevation, child) {
            final matrix = Matrix4.identity()
              ..setEntry(3, 2, config.motion.depthPerspective)
              ..setTranslationRaw(
                0,
                config.motion.depthOffsetY * elevation,
                config.motion.depthTranslateZ * elevation,
              )
              ..rotateX(tilt.y * config.motion.depthRotateY * 0.72)
              ..rotateY(-tilt.x * config.motion.depthRotateY);
            return Transform(
              transform: matrix,
              alignment: Alignment.center,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: borderRadius,
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
    final resolved = source ?? colors.primary;
    if (mode == AppShadowColorMode.background) {
      final hsl = HSLColor.fromColor(resolved);
      return hsl
          .withSaturation((hsl.saturation * 0.9).clamp(0, 1))
          .withLightness(hsl.lightness.clamp(0.26, 0.34))
          .toColor();
    }
    final hsl = HSLColor.fromColor(resolved);
    return hsl.withSaturation((hsl.saturation * 0.72).clamp(0, 1)).toColor();
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
    final mode = widget.shadowColorMode ?? theme.colorMode;
    if (mode == AppShadowColorMode.background) {
      return [
        BoxShadow(
          color: color.withValues(alpha: (dark ? 0.18 : 0.12) * intensity),
          blurRadius: 7,
          offset: const Offset(0, 2),
        ),
        BoxShadow(
          color: color.withValues(alpha: (dark ? 0.34 : 0.28) * intensity),
          blurRadius: 12,
          spreadRadius: -2,
          offset: const Offset(0, 4),
        ),
      ];
    }
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
