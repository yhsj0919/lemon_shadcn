import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_async_action.dart';
import '../../foundation/app_control_box.dart';
import '../../foundation/app_shadcn_scope.dart';

typedef AppButtonCallback = FutureOr<void> Function();

enum AppButtonVariant { primary, secondary, outline, ghost, destructive }

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
        onHover: widget.config.onHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.secondary => shad.SecondaryButton(
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
        onHover: widget.config.onHover,
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
        onHover: widget.config.onHover,
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
        onHover: widget.config.onHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.destructive => shad.DestructiveButton(
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
        onHover: widget.config.onHover,
        onFocus: widget.config.onFocus,
        enableFeedback: widget.config.enableFeedback,
        child: child,
      ),
    };
    return AppControlBox(
      height: widget.config.height,
      square: widget.iconOnly,
      child: button,
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
    return Stack(
      alignment: Alignment.center,
      children: [
        Opacity(opacity: loading ? 0 : 1, child: child),
        if (loading)
          Positioned.fill(
            child: Center(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox.square(
                      dimension: 16,
                      child: shad.CircularProgressIndicator(),
                    ),
                    if (loadingLabel != null) ...[
                      const shad.Gap(8),
                      Text(loadingLabel!),
                    ],
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
