import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_async_action.dart';
import '../../foundation/app_control_box.dart';
import '../../foundation/app_interactive_style.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';
import '../../motion/app_hover_press_ticker.dart';

typedef AppButtonCallback = FutureOr<void> Function();

enum AppButtonVariant {
  primary,
  secondary,
  outline,
  ghost,
  destructive,
  link,
  text,
}

enum AppButtonPressEffect { none, returnToBase, lift }

/// Disables default [AppButton] hover-lift inside chrome subtrees (menus,
/// sidebar, toolbars). Standalone AppButtons outside this scope keep motion.
class AppButtonMotionScope extends InheritedWidget {
  const AppButtonMotionScope({
    super.key,
    required this.enabled,
    required super.child,
  });

  /// Prefer this around menus / nav chrome.
  const AppButtonMotionScope.disable({super.key, required super.child})
    : enabled = false;

  final bool enabled;

  /// Whether null-config AppButtons may use interactive motion here.
  static bool allowsMotion(BuildContext context) {
    final scope = context
        .dependOnInheritedWidgetOfExactType<AppButtonMotionScope>();
    return scope?.enabled ?? true;
  }

  @override
  bool updateShouldNotify(AppButtonMotionScope oldWidget) =>
      enabled != oldWidget.enabled;
}

@immutable
class AppButtonConfig {
  const AppButtonConfig({
    this.height,
    this.enabled = true,
    this.alignment,
    this.size = shad.ButtonSize.normal,
    this.density = shad.ButtonDensity.normal,
    this.shape = shad.ButtonShape.rectangle,
    this.focusNode,
    this.disableTransition = false,
    this.onHover,
    this.onFocus,
    this.enableFeedback,
    this.pressEffect = AppButtonPressEffect.none,
    this.pressDuration,
    this.hoverLift = false,
    this.hoverDuration,
  });

  /// Hover lift + press returns to rest. Magnitudes come from
  /// [AppMotionTheme.tokens] (shared by text and icon buttons).
  static const interactive = AppButtonConfig(
    hoverLift: true,
    pressEffect: AppButtonPressEffect.returnToBase,
  );

  /// Hover lift + press lifts slightly further.
  static const interactiveLift = AppButtonConfig(
    hoverLift: true,
    pressEffect: AppButtonPressEffect.lift,
  );

  /// Explicit no-motion config. Pass this from chrome (nav, toolbars) when a
  /// global interactive default must stay still for this embed.
  static const plain = AppButtonConfig();

  final double? height;
  final bool enabled;
  final AlignmentGeometry? alignment;
  final shad.ButtonSize size;
  final shad.ButtonDensity density;
  final shad.ButtonShape shape;
  final FocusNode? focusNode;
  final bool disableTransition;
  final ValueChanged<bool>? onHover;
  final ValueChanged<bool>? onFocus;
  final bool? enableFeedback;
  final AppButtonPressEffect pressEffect;

  /// Null → [AppMotionTokens.pressDuration] from theme.
  final Duration? pressDuration;
  final bool hoverLift;

  /// Null → [AppMotionTokens.hoverDuration] from theme.
  final Duration? hoverDuration;

  AppButtonConfig copyWith({
    double? height,
    bool? enabled,
    AlignmentGeometry? alignment,
    shad.ButtonSize? size,
    shad.ButtonDensity? density,
    shad.ButtonShape? shape,
    FocusNode? focusNode,
    bool? disableTransition,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocus,
    bool? enableFeedback,
    AppButtonPressEffect? pressEffect,
    Duration? pressDuration,
    bool? hoverLift,
    Duration? hoverDuration,
  }) {
    return AppButtonConfig(
      height: height ?? this.height,
      enabled: enabled ?? this.enabled,
      alignment: alignment ?? this.alignment,
      size: size ?? this.size,
      density: density ?? this.density,
      shape: shape ?? this.shape,
      focusNode: focusNode ?? this.focusNode,
      disableTransition: disableTransition ?? this.disableTransition,
      onHover: onHover ?? this.onHover,
      onFocus: onFocus ?? this.onFocus,
      enableFeedback: enableFeedback ?? this.enableFeedback,
      pressEffect: pressEffect ?? this.pressEffect,
      pressDuration: pressDuration ?? this.pressDuration,
      hoverLift: hoverLift ?? this.hoverLift,
      hoverDuration: hoverDuration ?? this.hoverDuration,
    );
  }

  /// Resolves call-site config against theme + [AppButtonMotionScope].
  ///
  /// - `config == null` → [interactive] by default (standalone CTAs)
  /// - inside [AppButtonMotionScope.disable] → [plain] when config omitted
  /// - `config != null` → call site wins fully
  /// - `interactive: true` → forces hover lift + return-to-base on top
  static AppButtonConfig resolve(
    BuildContext context,
    AppButtonConfig? config, {
    bool interactive = false,
  }) {
    final themeInteractive =
        AppTheme.maybeOf(context)?.motion.interactive ?? true;
    final motionInteractive =
        themeInteractive && AppButtonMotionScope.allowsMotion(context);
    var resolved = config ??
        (motionInteractive ? AppButtonConfig.interactive : plain);
    if (!interactive) return resolved;
    return resolved.copyWith(
      hoverLift: true,
      pressEffect: resolved.pressEffect == AppButtonPressEffect.none
          ? AppButtonPressEffect.returnToBase
          : resolved.pressEffect,
    );
  }
}

abstract final class AppButton {
  static Widget primary({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    AppAsyncAction<void>? action,
    bool? loading,
    Widget? leading,
    Widget? trailing,
    String? loadingLabel,
    bool interactive = false,
    AppButtonConfig? config,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.primary,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    interactive: interactive,
    config: config,
    child: child,
  );

  static Widget secondary({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    AppAsyncAction<void>? action,
    bool? loading,
    Widget? leading,
    Widget? trailing,
    String? loadingLabel,
    bool interactive = false,
    AppButtonConfig? config,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.secondary,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    interactive: interactive,
    config: config,
    child: child,
  );

  static Widget outline({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    AppAsyncAction<void>? action,
    bool? loading,
    Widget? leading,
    Widget? trailing,
    String? loadingLabel,
    bool interactive = false,
    AppButtonConfig? config,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.outline,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    interactive: interactive,
    config: config,
    child: child,
  );

  static Widget ghost({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    AppAsyncAction<void>? action,
    bool? loading,
    Widget? leading,
    Widget? trailing,
    String? loadingLabel,
    bool interactive = false,
    AppButtonConfig? config,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.ghost,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    interactive: interactive,
    config: config,
    child: child,
  );

  static Widget destructive({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    AppAsyncAction<void>? action,
    bool? loading,
    Widget? leading,
    Widget? trailing,
    String? loadingLabel,
    bool interactive = false,
    AppButtonConfig? config,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.destructive,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    interactive: interactive,
    config: config,
    child: child,
  );

  static Widget link({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    AppAsyncAction<void>? action,
    bool? loading,
    Widget? leading,
    Widget? trailing,
    String? loadingLabel,
    bool interactive = false,
    AppButtonConfig? config,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.link,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    interactive: interactive,
    config: config,
    child: child,
  );

  static Widget text({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    AppAsyncAction<void>? action,
    bool? loading,
    Widget? leading,
    Widget? trailing,
    String? loadingLabel,
    bool interactive = false,
    AppButtonConfig? config,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.text,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    interactive: interactive,
    config: config,
    child: child,
  );
}

/// A low-template icon-only button with a guaranteed square hit target.
///
/// The default constructor uses the rectangular shape. Use [AppIconButton.circle]
/// for the circular shape; both follow the globally configured control height.
///
/// Motion follows [AppButtonConfig.resolve]: interactive by default, plain
/// inside [AppButtonMotionScope.disable], or pass [config] / [interactive].
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.action,
    this.loading,
    this.variant = AppButtonVariant.outline,
    this.config,
    this.interactive = false,
  }) : _circle = false,
       assert(action == null || onPressed == null);

  const AppIconButton.circle({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.action,
    this.loading,
    this.variant = AppButtonVariant.outline,
    this.config,
    this.interactive = false,
  }) : _circle = true,
       assert(action == null || onPressed == null);

  final Widget icon;
  final String tooltip;
  final AppButtonCallback? onPressed;
  final AppAsyncAction<void>? action;
  final bool? loading;
  final AppButtonVariant variant;
  final AppButtonConfig? config;
  final bool interactive;
  final bool _circle;

  @override
  Widget build(BuildContext context) {
    return shad.Tooltip(
      tooltip: (context) => Text(tooltip),
      child: Semantics(
        label: tooltip,
        button: true,
        child: _AppAsyncButton(
          variant: variant,
          onPressed: onPressed,
          action: action,
          loading: loading,
          config: config,
          interactive: interactive,
          iconOnly: true,
          shapeOverride: _circle
              ? shad.ButtonShape.circle
              : shad.ButtonShape.rectangle,
          child: icon,
        ),
      ),
    );
  }
}

class _AppAsyncButton extends StatefulWidget {
  const _AppAsyncButton({
    super.key,
    required this.variant,
    required this.child,
    this.onPressed,
    this.action,
    this.loading,
    this.leading,
    this.trailing,
    this.loadingLabel,
    this.config,
    this.interactive = false,
    this.iconOnly = false,
    this.shapeOverride,
  }) : assert(action == null || onPressed == null);

  final AppButtonVariant variant;
  final Widget child;
  final AppButtonCallback? onPressed;
  final AppAsyncAction<void>? action;
  final bool? loading;
  final Widget? leading;
  final Widget? trailing;
  final String? loadingLabel;
  final AppButtonConfig? config;
  final bool interactive;
  final bool iconOnly;
  final shad.ButtonShape? shapeOverride;

  @override
  State<_AppAsyncButton> createState() => _AppAsyncButtonState();
}

class _AppAsyncButtonState extends State<_AppAsyncButton>
    with TickerProviderStateMixin {
  bool _loading = false;
  bool _running = false;
  bool _pressed = false;
  bool _hovered = false;

  late final AppHoverPressTicker _ticker = AppHoverPressTicker(this);

  /// Resolved during [build] so pointer handlers never call
  /// `dependOnInheritedWidgetOfExactType` outside the build phase.
  AppButtonConfig _config = AppButtonConfig.plain;
  AppMotionTokens _motion = AppMotionTokens.standard;

  bool get _effectiveLoading =>
      widget.loading ?? widget.action?.isLoading ?? _loading;
  bool get _effectiveRunning =>
      !_config.enabled ||
      widget.loading == true ||
      widget.action?.isRunning == true ||
      _running;

  bool get _animate {
    final reduce = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return !reduce;
  }

  @override
  void initState() {
    super.initState();
    widget.action?.addListener(_actionChanged);
  }

  @override
  void didUpdateWidget(covariant _AppAsyncButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.action != widget.action) {
      oldWidget.action?.removeListener(_actionChanged);
      widget.action?.addListener(_actionChanged);
    }
  }

  void _actionChanged() {
    if (mounted) setState(() {});
  }

  void _handleHover(bool value) {
    if (!mounted || _hovered == value) {
      if (mounted) _config.onHover?.call(value);
      return;
    }
    _hovered = value;
    if (!_config.hoverLift) {
      _ticker.hover.value = 0;
    } else {
      _ticker.setHover(value, animate: _animate, tokens: _motion);
    }
    _config.onHover?.call(value);
  }

  void _setPressed(bool value) {
    if (!mounted || _pressed == value) return;
    _pressed = value;
    if (_config.pressEffect == AppButtonPressEffect.none) {
      _ticker.press.value = 0;
    } else {
      _ticker.setPress(value, animate: _animate, tokens: _motion);
    }
  }

  @override
  void dispose() {
    widget.action?.removeListener(_actionChanged);
    _ticker.dispose();
    super.dispose();
  }

  Future<void> _press() async {
    if (_effectiveRunning) return;
    final action = widget.action;
    if (action != null) {
      await action.execute();
      return;
    }
    if (widget.onPressed == null) return;
    final result = widget.onPressed!();
    if (result is! Future<void>) return;

    setState(() => _running = true);
    final motion = AppTheme.maybeOf(context)?.motion;
    DateTime? loadingStarted;
    final delay = motion?.loadingDelay ?? Duration.zero;
    final timer = Timer(delay, () {
      if (mounted && widget.loading == null) {
        loadingStarted = DateTime.now();
        setState(() => _loading = true);
      }
    });

    try {
      await result;
      if (loadingStarted case final started?) {
        final minimum = motion?.minimumLoadingDuration ?? Duration.zero;
        final remaining = minimum - DateTime.now().difference(started);
        if (remaining > Duration.zero) await Future<void>.delayed(remaining);
      }
    } finally {
      timer.cancel();
      if (mounted && widget.loading == null) {
        setState(() {
          _loading = false;
          _running = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _config = AppButtonConfig.resolve(
      context,
      widget.config,
      interactive: widget.interactive,
    );
    _motion =
        AppTheme.maybeOf(context)?.motion.tokens ?? AppMotionTokens.standard;
    _ticker.sync(_motion);

    final loading = _effectiveLoading;
    final child = _AppButtonContent(
      loading: loading,
      loadingLabel: widget.loadingLabel,
      child: widget.child,
    );
    final enabled = widget.action != null || widget.onPressed != null;
    final onPressed = !enabled || _effectiveRunning ? null : _press;
    final destructiveStyle = shad.ButtonStyle.destructive(
      size: _config.size,
      density: widget.iconOnly
          ? shad.ButtonDensity.icon
          : _config.density,
      shape: widget.shapeOverride ?? _config.shape,
    );
    final secondaryStyle = shad.ButtonStyle.secondary(
      size: _config.size,
      density: widget.iconOnly
          ? shad.ButtonDensity.icon
          : _config.density,
      shape: widget.shapeOverride ?? _config.shape,
    );
    final linkStyle = shad.ButtonStyle.link(
      size: _config.size,
      density: widget.iconOnly
          ? shad.ButtonDensity.icon
          : _config.density,
      shape: widget.shapeOverride ?? _config.shape,
    );
    final textStyle = shad.ButtonStyle.text(
      size: _config.size,
      density: widget.iconOnly
          ? shad.ButtonDensity.icon
          : _config.density,
      shape: widget.shapeOverride ?? _config.shape,
    );

    // Motion hover is owned by the outer MouseRegion. Keep Button.onHover only
    // for style state; avoid wiring _handleHover twice.
    final button = switch (widget.variant) {
      AppButtonVariant.primary => shad.PrimaryButton(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        size: _config.size,
        density: widget.iconOnly
            ? shad.ButtonDensity.icon
            : _config.density,
        shape: widget.shapeOverride ?? _config.shape,
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.secondary => shad.Button(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        style: AppInteractiveStyle.hover(secondaryStyle),
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.outline => shad.OutlineButton(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        size: _config.size,
        density: widget.iconOnly
            ? shad.ButtonDensity.icon
            : _config.density,
        shape: widget.shapeOverride ?? _config.shape,
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.ghost => shad.GhostButton(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        size: _config.size,
        density: widget.iconOnly
            ? shad.ButtonDensity.icon
            : _config.density,
        shape: widget.shapeOverride ?? _config.shape,
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.destructive => shad.Button(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        style: destructiveStyle.copyWith(
          decoration: (context, states, value) {
            if (states.contains(WidgetState.hovered) &&
                !states.contains(WidgetState.pressed)) {
              final normalStates = Set<WidgetState>.of(states)
                ..remove(WidgetState.hovered);
              return destructiveStyle.decoration(context, normalStates);
            }
            return value;
          },
        ),
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.link => shad.Button(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        style: AppInteractiveStyle.hover(
          linkStyle,
          tone: AppInteractiveHoverTone.accent,
        ),
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.text => shad.Button(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        style: AppInteractiveStyle.hover(
          textStyle,
          tone: AppInteractiveHoverTone.accent,
        ),
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
    };
    final control = AppControlBox(
      height: _config.height,
      square: widget.iconOnly,
      child: button,
    );
    final config = _config;
    final wantsMotion =
        config.hoverLift || config.pressEffect != AppButtonPressEffect.none;
    // Chrome / plain buttons: no transform wrapper, no hover jump.
    if (!wantsMotion) return control;

    final enabledForPress =
        enabled && config.enabled && !_effectiveRunning;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final theme = shad.Theme.of(context);
    final backgroundless =
        widget.variant == AppButtonVariant.outline ||
        widget.variant == AppButtonVariant.ghost ||
        widget.variant == AppButtonVariant.link ||
        widget.variant == AppButtonVariant.text;
    final shadowColor = switch (widget.variant) {
      AppButtonVariant.primary => theme.colorScheme.primary,
      AppButtonVariant.secondary => theme.colorScheme.secondaryForeground,
      AppButtonVariant.destructive => theme.colorScheme.destructive,
      AppButtonVariant.outline ||
      AppButtonVariant.ghost ||
      AppButtonVariant.link ||
      AppButtonVariant.text => theme.colorScheme.foreground,
    };
    final circular =
        widget.iconOnly ||
        widget.shapeOverride == shad.ButtonShape.circle ||
        config.shape == shad.ButtonShape.circle;

    return MouseRegion(
      onEnter: enabledForPress ? (_) => _handleHover(true) : null,
      onExit: (_) {
        _handleHover(false);
        _setPressed(false);
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown:
            enabledForPress &&
                config.pressEffect != AppButtonPressEffect.none
            ? (_) => _setPressed(true)
            : null,
        onPointerUp: (_) => _setPressed(false),
        onPointerCancel: (_) => _setPressed(false),
        child: AnimatedBuilder(
          animation: _ticker.listenable,
          builder: (context, child) {
            final hoverT = !config.hoverLift || !enabledForPress
                ? 0.0
                : reduceMotion
                ? (_hovered ? 1.0 : 0.0)
                : _ticker.hover.value;
            final pressT =
                config.pressEffect == AppButtonPressEffect.none ||
                    !enabledForPress
                ? 0.0
                : reduceMotion
                ? (_pressed ? 1.0 : 0.0)
                : _ticker.press.value;

            final hoverY = _motion.hoverOffset.dy * hoverT;
            final settle = -_motion.hoverOffset.dy;
            final (pressY, scale) = switch (config.pressEffect) {
              AppButtonPressEffect.none => (0.0, 1.0),
              AppButtonPressEffect.returnToBase => (
                settle * pressT * hoverT +
                    _motion.unhoveredPressNudge * pressT * (1.0 - hoverT),
                1.0 + (_motion.pressedScale - 1.0) * pressT,
              ),
              AppButtonPressEffect.lift => (
                -_motion.pressExtraLift * pressT,
                1.0 + (1.0 - _motion.pressedScale) * 0.4 * pressT,
              ),
            };
            final shadowT = (hoverT * (1.0 - pressT * 0.85)).clamp(0.0, 1.0);

            return Transform.translate(
              offset: Offset(0, hoverY + pressY),
              child: Transform.scale(
                scale: scale,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: circular
                        ? BorderRadius.circular(999)
                        : theme.borderRadiusMd,
                    boxShadow: backgroundless
                        ? const []
                        : _motion.hoverShadow(shadowColor, shadowT),
                  ),
                  child: child,
                ),
              ),
            );
          },
          child: control,
        ),
      ),
    );

  }
}

class _AppButtonContent extends StatelessWidget {
  const _AppButtonContent({
    required this.loading,
    required this.child,
    this.loadingLabel,
  });

  final bool loading;
  final Widget child;
  final String? loadingLabel;

  @override
  Widget build(BuildContext context) {
    final foreground =
        DefaultTextStyle.of(context).style.color ?? IconTheme.of(context).color;
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: loading ? 0 : 1, child: child),
        if (loading)
          Positioned.fill(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final showLabel =
                    loadingLabel != null && constraints.maxWidth >= 72;
                return Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox.square(
                        dimension: 16,
                        child: shad.CircularProgressIndicator(
                          color: foreground,
                          backgroundColor: foreground?.withValues(alpha: 0.24),
                        ),
                      ),
                      if (showLabel) ...[
                        const shad.Gap(8),
                        Flexible(child: Text(loadingLabel!)),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}
