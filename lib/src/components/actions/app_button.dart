import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_async_action.dart';
import '../../foundation/app_control_box.dart';
import '../../foundation/app_interactive_style.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';
import '../../motion/app_hover_press_ticker.dart';
import '../display/app_semantic_style.dart';
import '../overlay/app_overlay_components.dart';

typedef AppButtonCallback = FutureOr<void> Function();
typedef AppWidgetGroupItem = shad.ButtonGroupItem;
typedef AppWidgetGroupFlexible = shad.ButtonGroupFlexible;

enum AppWidgetGroupMode { compact, plain }

class AppWidgetGroup extends StatelessWidget {
  const AppWidgetGroup({
    super.key,
    this.direction = Axis.horizontal,
    this.mode = AppWidgetGroupMode.compact,
    this.spacing = 8,
    this.expands = false,
    this.flexes,
    this.widths,
    required this.children,
  }) : assert(spacing >= 0),
       assert(
         flexes == null || flexes.length == children.length,
         'flexes length must match children length',
       ),
       assert(
         widths == null ||
             (direction == Axis.horizontal && widths.length == children.length),
         'widths must match children length and is only valid horizontally',
       );

  const AppWidgetGroup.horizontal({
    super.key,
    this.mode = AppWidgetGroupMode.compact,
    this.spacing = 8,
    this.expands = false,
    this.flexes,
    this.widths,
    required this.children,
  }) : direction = Axis.horizontal,
       assert(spacing >= 0),
       assert(
         flexes == null || flexes.length == children.length,
         'flexes length must match children length',
       ),
       assert(
         widths == null || widths.length == children.length,
         'widths length must match children length',
       );

  const AppWidgetGroup.vertical({
    super.key,
    this.mode = AppWidgetGroupMode.compact,
    this.spacing = 8,
    this.expands = false,
    this.flexes,
    required this.children,
  }) : direction = Axis.vertical,
       widths = null,
       assert(spacing >= 0),
       assert(
         flexes == null || flexes.length == children.length,
         'flexes length must match children length',
       );

  final Axis direction;
  final AppWidgetGroupMode mode;

  /// Gap between untouched children in [AppWidgetGroupMode.plain].
  final double spacing;
  final bool expands;

  /// Per-child flex factors used when [expands] is true. Defaults to `1`.
  final List<int>? flexes;

  /// Fixed widths for horizontal children. A null entry uses its intrinsic
  /// width, or fills remaining space when [expands] is true.
  final List<double?>? widths;
  final List<Widget> children;

  /// Whether [context] belongs to a child currently managed by a widget group.
  static bool isItemContext(BuildContext context) =>
      _AppWidgetGroupItemScope.maybeOf(context) != null;

  /// Transparent border for nested controls; the group frame owns the outline.
  static Border get clearItemBorder =>
      Border.all(color: const Color(0x00000000), width: 0);

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final side = BorderSide(color: theme.colorScheme.border, width: 1);
    final lastIndex = children.length - 1;
    Widget sizeItem(int index, Widget item) {
      final width = widths?[index];
      if (width != null) {
        assert(width > 0, 'group child widths must be greater than zero');
        return SizedBox(width: width, child: item);
      }
      return expands
          ? Expanded(flex: flexes?[index] ?? 1, child: item)
          : item;
    }

    Widget buildItem(int index) {
      if (mode == AppWidgetGroupMode.plain) {
        return sizeItem(index, children[index]);
      }
      final item = Builder(
        builder: (context) {
          final first = index == 0;
          final last = index == lastIndex;
          final radius = switch (direction) {
            Axis.horizontal => BorderRadius.horizontal(
              left: first ? Radius.circular(theme.radiusMd) : Radius.zero,
              right: last ? Radius.circular(theme.radiusMd) : Radius.zero,
            ),
            Axis.vertical => BorderRadius.vertical(
              top: first ? Radius.circular(theme.radiusMd) : Radius.zero,
              bottom: last ? Radius.circular(theme.radiusMd) : Radius.zero,
            ),
          };
          final border = switch (direction) {
            Axis.horizontal => Border(
              left: first ? side : BorderSide.none,
              top: side,
              right: side,
              bottom: side,
            ),
            Axis.vertical => Border(
              left: side,
              top: first ? side : BorderSide.none,
              right: side,
              bottom: side,
            ),
          };
          return ClipRRect(
            borderRadius: radius,
            child: DecoratedBox(
              position: DecorationPosition.foreground,
              decoration: BoxDecoration(border: border, borderRadius: radius),
              child: _AppWidgetGroupItemScope(
                direction: direction,
                index: index,
                child: children[index],
              ),
            ),
          );
        },
      );
      return sizeItem(index, item);
    }

    final items = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (mode == AppWidgetGroupMode.plain && index > 0 && spacing > 0) {
        items.add(
          SizedBox(
            width: direction == Axis.horizontal ? spacing : 0,
            height: direction == Axis.vertical ? spacing : 0,
          ),
        );
      }
      items.add(buildItem(index));
    }
    Widget group = Flex(
      direction: direction,
      mainAxisSize: expands && direction == Axis.horizontal
          ? MainAxisSize.max
          : MainAxisSize.min,
      crossAxisAlignment: direction == Axis.horizontal
          ? CrossAxisAlignment.center
          : CrossAxisAlignment.stretch,
      children: items,
    );
    return direction == Axis.horizontal ? group : IntrinsicWidth(child: group);
  }
}

class _AppWidgetGroupItemScope extends InheritedWidget {
  const _AppWidgetGroupItemScope({
    required this.direction,
    required this.index,
    required super.child,
  });

  final Axis direction;
  final int index;

  static _AppWidgetGroupItemScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_AppWidgetGroupItemScope>();

  @override
  bool updateShouldNotify(_AppWidgetGroupItemScope oldWidget) =>
      direction != oldWidget.direction || index != oldWidget.index;
}

/// Application button size presets.
///
/// A size scales the button's height, horizontal/vertical padding, label text
/// and icons together. The presets use the official 44 / 52 / 60 / 68 ratio,
/// with the globally configured control height representing the 60px default.
/// A custom proportional size remains available through the constructor.
class AppButtonSize extends shad.ButtonSize {
  const AppButtonSize(super.scale);

  static const xSmall = AppButtonSize(44 / 60);
  static const small = AppButtonSize(52 / 60);
  static const normal = AppButtonSize(1);
  static const large = AppButtonSize(68 / 60);
}

enum AppButtonVariant {
  primary,
  secondary,
  selected,
  outline,
  ghost,
  destructive,
  link,
  text,
}

enum AppButtonPressEffect { none, sink }

/// Disables default [AppButton] press motion inside chrome subtrees (menus,
/// sidebar, toolbars, dialogs).
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

  /// Whether null-config AppButtons may use press motion here.
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
    this.size = AppButtonSize.normal,
    this.density = shad.ButtonDensity.normal,
    this.shape = shad.ButtonShape.rectangle,
    this.focusNode,
    this.disableTransition = false,
    this.onHover,
    this.onFocus,
    this.enableFeedback,
    this.pressEffect = AppButtonPressEffect.sink,
    this.pressDuration,
    this.hoverLift = false,
    this.hoverDuration,
  });

  /// Standard button feedback: hover stays in place and press sinks by 1 px.
  static const interactive = AppButtonConfig(
    pressEffect: AppButtonPressEffect.sink,
  );

  /// Explicit no-motion config. Pass this from chrome (nav, toolbars) when a
  /// global interactive default must stay still for this embed.
  static const plain = AppButtonConfig(pressEffect: AppButtonPressEffect.none);

  final double? height;
  final bool enabled;
  final AlignmentGeometry? alignment;
  final AppButtonSize size;
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
    AppButtonSize? size,
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
  /// - `interactive: true` → forces the standard press-sink feedback
  static AppButtonConfig resolve(
    BuildContext context,
    AppButtonConfig? config, {
    bool interactive = false,
  }) {
    final themeInteractive =
        AppTheme.maybeOf(context)?.motion.interactive ?? true;
    final motionInteractive =
        themeInteractive && AppButtonMotionScope.allowsMotion(context);
    var resolved =
        config ?? (motionInteractive ? AppButtonConfig.interactive : plain);
    if (!interactive) return resolved;
    return resolved.copyWith(
      pressEffect: resolved.pressEffect == AppButtonPressEffect.none
          ? AppButtonPressEffect.sink
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
    AppButtonSize? size,
    bool shadow = false,
    bool interactive = false,
    AppButtonConfig? config,
    Color? color,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.primary,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    size: size,
    shadow: shadow,
    interactive: interactive,
    config: config,
    color: color,
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
    AppButtonSize? size,
    bool shadow = false,
    bool interactive = false,
    AppButtonConfig? config,
    Color? color,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.secondary,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    size: size,
    shadow: shadow,
    interactive: interactive,
    config: config,
    color: color,
    child: child,
  );

  /// A quiet but explicit selected state for toggles and segmented controls.
  static Widget selected({
    Key? key,
    required Widget child,
    AppButtonCallback? onPressed,
    AppButtonSize? size,
    AppButtonConfig? config,
    Color? color,
    bool shadow = false,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.selected,
    onPressed: onPressed,
    size: size,
    shadow: shadow,
    config: config,
    selectedColor: color,
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
    AppButtonSize? size,
    bool shadow = false,
    bool interactive = false,
    AppButtonConfig? config,
    Color? color,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.outline,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    size: size,
    shadow: shadow,
    interactive: interactive,
    config: config,
    color: color,
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
    AppButtonSize? size,
    bool interactive = false,
    AppButtonConfig? config,
    Color? color,
  }) => _AppAsyncButton(
    key: key,
    variant: AppButtonVariant.ghost,
    onPressed: onPressed,
    action: action,
    loading: loading,
    leading: leading,
    trailing: trailing,
    loadingLabel: loadingLabel,
    size: size,
    interactive: interactive,
    config: config,
    color: color,
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
    AppButtonSize? size,
    bool shadow = false,
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
    size: size,
    shadow: shadow,
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
    AppButtonSize? size,
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
    size: size,
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
    AppButtonSize? size,
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
    size: size,
    interactive: interactive,
    config: config,
    child: child,
  );
}

class AppIconButtonTheme extends shad.ComponentThemeData {
  static const quietVariants = <AppButtonVariant>{
    AppButtonVariant.outline,
    AppButtonVariant.ghost,
    AppButtonVariant.text,
  };

  const AppIconButtonTheme({
    this.color,
    this.foregroundColor,
    this.backgroundColor,
    this.iconSize,
    this.variants = quietVariants,
  })
    : assert(iconSize == null || iconSize > 0);

  /// Shorthand default for [foregroundColor].
  final Color? color;

  /// Default icon foreground color.
  final Color? foregroundColor;

  /// Default button background color.
  final Color? backgroundColor;

  /// Default icon size. The button hit target is unaffected.
  final double? iconSize;

  /// Variants that receive this theme's foreground and background colors.
  /// Defaults to the quiet outline, ghost, and text variants so solid buttons
  /// retain their own automatic contrast colors.
  final Set<AppButtonVariant> variants;
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
    this.size,
    this.color,
    this.foregroundColor,
    this.backgroundColor,
    this.iconSize,
    this.config,
    this.interactive = false,
    this.shadow = false,
  }) : _circle = false,
       assert(action == null || onPressed == null),
       assert(iconSize == null || iconSize > 0);

  const AppIconButton.circle({
    super.key,
    required this.icon,
    required this.tooltip,
    this.onPressed,
    this.action,
    this.loading,
    this.variant = AppButtonVariant.outline,
    this.size,
    this.color,
    this.foregroundColor,
    this.backgroundColor,
    this.iconSize,
    this.config,
    this.interactive = false,
    this.shadow = false,
  }) : _circle = true,
       assert(action == null || onPressed == null),
       assert(iconSize == null || iconSize > 0);

  final Widget icon;
  final String tooltip;
  final AppButtonCallback? onPressed;
  final AppAsyncAction<void>? action;
  final bool? loading;
  final AppButtonVariant variant;
  final AppButtonSize? size;

  /// Shorthand for [foregroundColor].
  final Color? color;

  /// Icon foreground color. Falls back to [AppIconButtonTheme], then to the
  /// selected [variant]'s theme-aware default.
  final Color? foregroundColor;

  /// Button background color. Falls back to [AppIconButtonTheme.backgroundColor].
  final Color? backgroundColor;

  /// Overrides [AppIconButtonTheme.iconSize] without changing the hit target.
  final double? iconSize;
  final AppButtonConfig? config;
  final bool interactive;
  final bool shadow;
  final bool _circle;

  @override
  Widget build(BuildContext context) {
    final iconButtonTheme =
        shad.ComponentTheme.maybeOf<AppIconButtonTheme>(context);
    final appliesThemeColor =
        iconButtonTheme?.variants.contains(variant) ?? false;
    final themedForeground = appliesThemeColor
        ? iconButtonTheme?.foregroundColor ?? iconButtonTheme?.color
        : null;
    final resolvedColor =
        foregroundColor ??
        color ??
        themedForeground;
    final resolvedBackground =
        backgroundColor ??
        (appliesThemeColor ? iconButtonTheme?.backgroundColor : null);
    final resolvedIconSize = iconSize ?? iconButtonTheme?.iconSize;
    final resolvedIcon = resolvedColor == null && resolvedIconSize == null
        ? icon
        : IconTheme.merge(
            data: IconThemeData(
              color: resolvedColor,
              size: resolvedIconSize,
            ),
            child: icon,
          );
    return AppTooltip(
      tooltip: (context) => Text(tooltip),
      child: Semantics(
        label: tooltip,
        button: true,
        child: _AppAsyncButton(
          variant: variant,
          onPressed: onPressed,
          action: action,
          loading: loading,
          size: size,
          backgroundColor: resolvedBackground,
          config: config,
          interactive: interactive,
          shadow: shadow,
          iconOnly: true,
          shapeOverride: _circle
              ? shad.ButtonShape.circle
              : shad.ButtonShape.rectangle,
          child: resolvedIcon,
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
    this.size,
    this.config,
    this.interactive = false,
    this.iconOnly = false,
    this.shapeOverride,
    this.selectedColor,
    this.color,
    this.backgroundColor,
    this.shadow = false,
  }) : assert(action == null || onPressed == null);

  final AppButtonVariant variant;
  final Widget child;
  final AppButtonCallback? onPressed;
  final AppAsyncAction<void>? action;
  final bool? loading;
  final Widget? leading;
  final Widget? trailing;
  final String? loadingLabel;
  final AppButtonSize? size;
  final AppButtonConfig? config;
  final bool interactive;
  final bool iconOnly;
  final shad.ButtonShape? shapeOverride;
  final Color? selectedColor;
  final Color? color;
  final Color? backgroundColor;
  final bool shadow;

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
    if (widget.size case final size?) {
      _config = _config.copyWith(size: size);
    }
    _motion =
        AppTheme.maybeOf(context)?.motion.tokens ?? AppMotionTokens.standard;
    _ticker.sync(_motion);
    final theme = shad.Theme.of(context);

    final loading = _effectiveLoading;
    final child = _AppButtonContent(
      loading: loading,
      loadingLabel: widget.loadingLabel,
      child: widget.child,
    );
    final enabled = widget.action != null || widget.onPressed != null;
    final onPressed = !enabled || _effectiveRunning ? null : _press;
    final metrics = AppControlMetricsScope.resolve(context);
    final baseHeight = metrics.buttonHeight;
    final sizeScale = _config.size.scale;
    final groupItem = _AppWidgetGroupItemScope.maybeOf(context);

    shad.AbstractButtonStyle sized(shad.ButtonStyle style) => style.copyWith(
      decoration: groupItem == null && widget.backgroundColor == null
          ? null
          : (context, states, value) {
              if (value is! BoxDecoration) return value;
              return value.copyWith(
                color: widget.backgroundColor ?? value.color,
                border: groupItem == null
                    ? value.border
                    : AppWidgetGroup.clearItemBorder,
                borderRadius: groupItem == null
                    ? value.borderRadius
                    : BorderRadius.zero,
              );
            },
      padding: (context, states, value) => widget.iconOnly
          ? EdgeInsets.zero
          : EdgeInsets.symmetric(
              horizontal:
                  (metrics.horizontalPadding + (groupItem == null ? 0 : -2)) *
                  sizeScale,
              vertical: 2 * sizeScale,
            ),
      textStyle: (context, states, value) =>
          value.copyWith(fontSize: metrics.fontSize * sizeScale, height: 1.2),
      iconTheme: (context, states, value) =>
          value.copyWith(size: metrics.iconSize * sizeScale),
    );

    shad.AbstractButtonStyle colorize(
      shad.AbstractButtonStyle style, {
      required bool solid,
    }) {
      final color = widget.color;
      if (color == null) return style;
      final palette = AppSemanticPalette.custom(theme, color);
      return style.copyWith(
        decoration: (context, states, value) {
          if (value is! BoxDecoration) return value;
          return value.copyWith(
            color: solid ? palette.solid : const Color(0x00000000),
            border: solid
                ? value.border
                : Border.all(color: palette.foreground),
          );
        },
        textStyle: (context, states, value) =>
            value.copyWith(color: solid ? palette.onSolid : palette.foreground),
        iconTheme: (context, states, value) =>
            value.copyWith(color: solid ? palette.onSolid : palette.foreground),
      );
    }

    final primaryStyle = colorize(
      sized(
        shad.ButtonStyle.primary(
          size: _config.size,
          density: widget.iconOnly ? shad.ButtonDensity.icon : _config.density,
          shape: widget.shapeOverride ?? _config.shape,
        ),
      ),
      solid: true,
    );
    final destructiveStyle = sized(
      shad.ButtonStyle.destructive(
        size: _config.size,
        density: widget.iconOnly ? shad.ButtonDensity.icon : _config.density,
        shape: widget.shapeOverride ?? _config.shape,
      ),
    );
    final softDestructiveStyle = destructiveStyle.copyWith(
      decoration: (context, states, value) {
        if (value is! BoxDecoration) return value;
        final opacity = states.contains(WidgetState.disabled)
            ? 0.06
            : states.contains(WidgetState.pressed)
            ? 0.20
            : states.contains(WidgetState.hovered)
            ? 0.16
            : 0.12;
        return value.copyWith(
          color: theme.colorScheme.destructive.withValues(alpha: opacity),
        );
      },
      textStyle: (context, states, value) => value.copyWith(
        color: theme.colorScheme.destructive.withValues(
          alpha: states.contains(WidgetState.disabled) ? 0.45 : 1,
        ),
      ),
      iconTheme: (context, states, value) => value.copyWith(
        color: theme.colorScheme.destructive.withValues(
          alpha: states.contains(WidgetState.disabled) ? 0.45 : 1,
        ),
      ),
    );
    final secondaryStyle = colorize(
      sized(
        shad.ButtonStyle.secondary(
          size: _config.size,
          density: widget.iconOnly ? shad.ButtonDensity.icon : _config.density,
          shape: widget.shapeOverride ?? _config.shape,
        ),
      ),
      solid: true,
    );
    final selectedStyle = secondaryStyle.copyWith(
      decoration: (context, states, value) {
        if (value is! BoxDecoration) return value;
        final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;
        final disabled = states.contains(WidgetState.disabled);
        final pressed = states.contains(WidgetState.pressed);
        final hovered = states.contains(WidgetState.hovered);
        final lightOpacity = disabled
            ? 0.04
            : pressed
            ? 0.14
            : hovered
            ? 0.11
            : AppSoftColor.selectionLightOpacity;
        final darkOpacity = disabled
            ? 0.06
            : pressed
            ? 0.18
            : hovered
            ? 0.15
            : AppSoftColor.selectionDarkOpacity;
        return value.copyWith(
          color: AppSoftColor.background(
            theme,
            selectedColor,
            lightOpacity: lightOpacity,
            darkOpacity: darkOpacity,
          ),
        );
      },
      textStyle: (context, states, value) {
        final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;
        return value.copyWith(
          color: selectedColor.withValues(
            alpha: states.contains(WidgetState.disabled) ? 0.45 : 1,
          ),
        );
      },
      iconTheme: (context, states, value) {
        final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;
        return value.copyWith(
          color: selectedColor.withValues(
            alpha: states.contains(WidgetState.disabled) ? 0.45 : 1,
          ),
        );
      },
    );
    final outlineStyle = colorize(
      sized(
        shad.ButtonStyle.outline(
          size: _config.size,
          density: widget.iconOnly ? shad.ButtonDensity.icon : _config.density,
          shape: widget.shapeOverride ?? _config.shape,
        ),
      ),
      solid: false,
    );
    final ghostStyle = colorize(
      sized(
        shad.ButtonStyle.ghost(
          size: _config.size,
          density: widget.iconOnly ? shad.ButtonDensity.icon : _config.density,
          shape: widget.shapeOverride ?? _config.shape,
        ),
      ),
      solid: false,
    );
    final linkStyle = sized(
      shad.ButtonStyle.link(
        size: _config.size,
        density: widget.iconOnly ? shad.ButtonDensity.icon : _config.density,
        shape: widget.shapeOverride ?? _config.shape,
      ),
    );
    final textStyle = sized(
      shad.ButtonStyle.text(
        size: _config.size,
        density: widget.iconOnly ? shad.ButtonDensity.icon : _config.density,
        shape: widget.shapeOverride ?? _config.shape,
      ),
    );

    // Motion hover is owned by the outer MouseRegion. Keep Button.onHover only
    // for style state; avoid wiring _handleHover twice.
    final button = switch (widget.variant) {
      AppButtonVariant.primary => shad.Button(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        style: primaryStyle,
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
      AppButtonVariant.selected => shad.Button(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        style: selectedStyle,
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.outline => shad.Button(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        style: outlineStyle,
        focusNode: _config.focusNode,
        disableTransition: _config.disableTransition,
        onFocus: _config.onFocus,
        enableFeedback: _config.enableFeedback,
        child: child,
      ),
      AppButtonVariant.ghost => shad.Button(
        onPressed: onPressed,
        enabled: _config.enabled,
        leading: widget.leading,
        trailing: widget.trailing,
        alignment: _config.alignment,
        style: ghostStyle,
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
        style: softDestructiveStyle,
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
    // ButtonSize also scales the upstream padding, text and icon theme. Keep
    // the outer control box on the same scale so content is never clipped.
    final sizeHeight = baseHeight * sizeScale;
    final control = AppControlBox(
      height: _config.height ?? sizeHeight,
      square: widget.iconOnly,
      child: button,
    );
    final config = _config;
    final wantsMotion =
        config.hoverLift || config.pressEffect != AppButtonPressEffect.none;
    final supportsShadow =
        widget.variant == AppButtonVariant.primary ||
        widget.variant == AppButtonVariant.secondary ||
        widget.variant == AppButtonVariant.selected ||
        widget.variant == AppButtonVariant.outline ||
        widget.variant == AppButtonVariant.destructive;
    final showDefaultShadow = widget.shadow && supportsShadow;
    // Chrome / plain buttons: no transform wrapper, no hover jump.
    if (!wantsMotion && !showDefaultShadow) return control;

    final enabledForPress = enabled && config.enabled && !_effectiveRunning;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final backgroundless =
        widget.variant == AppButtonVariant.ghost ||
        widget.variant == AppButtonVariant.link ||
        widget.variant == AppButtonVariant.text;
    final rawShadowColor = switch (widget.variant) {
      AppButtonVariant.primary => theme.colorScheme.primary,
      // Pale secondary fills disappear when reused as a translucent shadow.
      AppButtonVariant.secondary => theme.colorScheme.secondaryForeground,
      AppButtonVariant.selected =>
        widget.selectedColor ?? theme.colorScheme.primary,
      AppButtonVariant.destructive => theme.colorScheme.destructive,
      // The flattened border token is intentionally very light; use its
      // foreground semantic so the outline shadow remains visible on white.
      AppButtonVariant.outline => theme.colorScheme.mutedForeground,
      AppButtonVariant.ghost ||
      AppButtonVariant.link ||
      AppButtonVariant.text => theme.colorScheme.foreground,
    };
    final solidColorShadow = widget.variant == AppButtonVariant.primary;
    final shadowColor = solidColorShadow
        ? AppTheme.of(
            context,
          ).shadows.resolveSolidShadowColor(context, rawShadowColor)
        : rawShadowColor;
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
            enabledForPress && config.pressEffect != AppButtonPressEffect.none
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
            final (pressY, scale) = switch (config.pressEffect) {
              AppButtonPressEffect.none => (0.0, 1.0),
              AppButtonPressEffect.sink => (1.0 * pressT, 1.0),
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
                    boxShadow: showDefaultShadow
                        ? AppTheme.of(context).shadows.resolve(
                            context,
                            level: AppShadowLevel.interactive,
                            colorMode: AppShadowColorMode.custom,
                            color: shadowColor,
                            blurRadius: 10,
                            spreadRadius: 0,
                            offset: const Offset(0, 3),
                            intensity: (1.6 + hoverT * 0.25) * (1.0 - pressT),
                          )
                        : backgroundless
                        ? const []
                        : AppTheme.of(context).shadows.resolve(
                            context,
                            level: AppShadowLevel.interactive,
                            colorMode: AppShadowColorMode.custom,
                            color: shadowColor,
                            intensity: shadowT,
                          ),
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
