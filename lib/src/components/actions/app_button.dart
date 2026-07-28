import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_async_action.dart';
import '../../foundation/app_control_box.dart';
import '../../foundation/app_interactive_style.dart';
import '../../foundation/app_shadcn_scope.dart';

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
    this.pressDuration = const Duration(milliseconds: 90),
    this.hoverLift = false,
    this.hoverDuration = const Duration(milliseconds: 180),
  });

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
  final Duration pressDuration;
  final bool hoverLift;
  final Duration hoverDuration;
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
    AppButtonConfig config = const AppButtonConfig(),
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.primary,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
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
    AppButtonConfig config = const AppButtonConfig(),
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.secondary,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
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
    AppButtonConfig config = const AppButtonConfig(),
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.outline,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
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
    AppButtonConfig config = const AppButtonConfig(),
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.ghost,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
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
    AppButtonConfig config = const AppButtonConfig(),
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.destructive,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
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
    AppButtonConfig config = const AppButtonConfig(),
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.link,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
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
    AppButtonConfig config = const AppButtonConfig(),
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.text,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    config: config,
    child: child,
  );
}

/// A low-template icon-only button with a guaranteed square hit target.
///
/// The default constructor uses the rectangular shape. Use [AppIconButton.circle]
/// for the circular shape; both follow the globally configured control height.
class AppIconButton extends StatelessWidget {
  const AppIconButton({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.action,
    this.loading,
    this.variant = AppButtonVariant.outline,
    this.config = const AppButtonConfig(),
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
    this.config = const AppButtonConfig(),
  }) : _circle = true,
       assert(action == null || onPressed == null);

  final Widget icon;
  final String tooltip;
  final AppButtonCallback? onPressed;
  final AppAsyncAction<void>? action;
  final bool? loading;
  final AppButtonVariant variant;
  final AppButtonConfig config;
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
    this.config = const AppButtonConfig(),
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
  final AppButtonConfig config;
  final bool iconOnly;
  final shad.ButtonShape? shapeOverride;

  @override
  State<_AppAsyncButton> createState() => _AppAsyncButtonState();
}

class _AppAsyncButtonState extends State<_AppAsyncButton> {
  bool _loading = false;
  bool _running = false;
  bool _pressed = false;
  bool _hovered = false;

  bool get _effectiveLoading =>
      widget.loading ?? widget.action?.isLoading ?? _loading;
  bool get _effectiveRunning =>
      !widget.config.enabled ||
      widget.loading == true ||
      widget.action?.isRunning == true ||
      _running;

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
    if (_hovered != value) setState(() => _hovered = value);
    widget.config.onHover?.call(value);
  }

  @override
  void dispose() {
    widget.action?.removeListener(_actionChanged);
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
    final loading = _effectiveLoading;
    final child = _AppButtonContent(
      loading: loading,
      loadingLabel: widget.loadingLabel,
      child: widget.child,
    );
    final enabled = widget.action != null || widget.onPressed != null;
    final onPressed = !enabled || _effectiveRunning ? null : _press;
    final destructiveStyle = shad.ButtonStyle.destructive(
      size: widget.config.size,
      density: widget.iconOnly
          ? shad.ButtonDensity.icon
          : widget.config.density,
      shape: widget.shapeOverride ?? widget.config.shape,
    );
    final secondaryStyle = shad.ButtonStyle.secondary(
      size: widget.config.size,
      density: widget.iconOnly
          ? shad.ButtonDensity.icon
          : widget.config.density,
      shape: widget.shapeOverride ?? widget.config.shape,
    );
    final linkStyle = shad.ButtonStyle.link(
      size: widget.config.size,
      density: widget.iconOnly
          ? shad.ButtonDensity.icon
          : widget.config.density,
      shape: widget.shapeOverride ?? widget.config.shape,
    );
    final textStyle = shad.ButtonStyle.text(
      size: widget.config.size,
      density: widget.iconOnly
          ? shad.ButtonDensity.icon
          : widget.config.density,
      shape: widget.shapeOverride ?? widget.config.shape,
    );

    final button = switch (widget.variant) {
      AppButtonVariant.primary => shad.PrimaryButton(
        onPressed: onPressed,
        enabled: widget.config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: widget.config.alignment,
        size: widget.config.size,
        density: widget.iconOnly
            ? shad.ButtonDensity.icon
            : widget.config.density,
        shape: widget.shapeOverride ?? widget.config.shape,
        focusNode: widget.config.focusNode,
        disableTransition: widget.config.disableTransition,
        onHover: _handleHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.secondary => shad.Button(
        onPressed: onPressed,
        enabled: widget.config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: widget.config.alignment,
        style: AppInteractiveStyle.hover(secondaryStyle),
        focusNode: widget.config.focusNode,
        disableTransition: widget.config.disableTransition,
        onHover: _handleHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.outline => shad.OutlineButton(
        onPressed: onPressed,
        enabled: widget.config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: widget.config.alignment,
        size: widget.config.size,
        density: widget.iconOnly
            ? shad.ButtonDensity.icon
            : widget.config.density,
        shape: widget.shapeOverride ?? widget.config.shape,
        focusNode: widget.config.focusNode,
        disableTransition: widget.config.disableTransition,
        onHover: _handleHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.ghost => shad.GhostButton(
        onPressed: onPressed,
        enabled: widget.config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: widget.config.alignment,
        size: widget.config.size,
        density: widget.iconOnly
            ? shad.ButtonDensity.icon
            : widget.config.density,
        shape: widget.shapeOverride ?? widget.config.shape,
        focusNode: widget.config.focusNode,
        disableTransition: widget.config.disableTransition,
        onHover: _handleHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.destructive => shad.Button(
        onPressed: onPressed,
        enabled: widget.config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: widget.config.alignment,
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
        focusNode: widget.config.focusNode,
        disableTransition: widget.config.disableTransition,
        onHover: _handleHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.link => shad.Button(
        onPressed: onPressed,
        enabled: widget.config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: widget.config.alignment,
        style: AppInteractiveStyle.hover(
          linkStyle,
          tone: AppInteractiveHoverTone.accent,
        ),
        focusNode: widget.config.focusNode,
        disableTransition: widget.config.disableTransition,
        onHover: _handleHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.text => shad.Button(
        onPressed: onPressed,
        enabled: widget.config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: widget.config.alignment,
        style: AppInteractiveStyle.hover(
          textStyle,
          tone: AppInteractiveHoverTone.accent,
        ),
        focusNode: widget.config.focusNode,
        disableTransition: widget.config.disableTransition,
        onHover: _handleHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
    };
    final control = AppControlBox(
      height: widget.config.height,
      square: widget.iconOnly,
      child: button,
    );
    final enabledForPress =
        enabled && widget.config.enabled && !_effectiveRunning;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final hoverActive =
        _hovered && enabledForPress && widget.config.hoverLift && !reduceMotion;
    final (offset, scale) = _pressed && enabledForPress
        ? switch (widget.config.pressEffect) {
            AppButtonPressEffect.none => (Offset.zero, 1.0),
            AppButtonPressEffect.returnToBase => (Offset.zero, 1.0),
            AppButtonPressEffect.lift => (const Offset(0, -1), 1.01),
          }
        : hoverActive
        ? (const Offset(0, -1), 1.0)
        : (Offset.zero, 1.0);
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
        widget.config.shape == shad.ButtonShape.circle;
    return Listener(
      onPointerDown:
          enabledForPress &&
              widget.config.pressEffect != AppButtonPressEffect.none
          ? (_) => setState(() => _pressed = true)
          : null,
      onPointerUp: _pressed ? (_) => setState(() => _pressed = false) : null,
      onPointerCancel: _pressed
          ? (_) => setState(() => _pressed = false)
          : null,
      child: AnimatedContainer(
        duration: reduceMotion
            ? Duration.zero
            : _pressed
            ? widget.config.pressDuration
            : widget.config.hoverDuration,
        curve: Curves.easeOutCubic,
        transform: Matrix4.diagonal3Values(scale, scale, 1)
          ..setTranslationRaw(offset.dx, offset.dy, 0),
        transformAlignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: circular
              ? BorderRadius.circular(999)
              : theme.borderRadiusMd,
          boxShadow: hoverActive && !_pressed && !backgroundless
              ? [
                  BoxShadow(
                    color: shadowColor.withValues(alpha: 0.16),
                    blurRadius: 10,
                    spreadRadius: -4,
                    offset: const Offset(0, 4),
                  ),
                ]
              : const [],
        ),
        child: control,
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
