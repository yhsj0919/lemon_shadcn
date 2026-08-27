import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../../foundation/app_theme_config.dart';

typedef AppPointerTooltipBuilder =
    Widget Function(BuildContext context, String message);

@immutable
class AppPointerTooltipStyle {
  const AppPointerTooltipStyle({
    this.decoration,
    this.padding,
    this.textStyle,
    this.margin,
  });

  final Decoration? decoration;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;
  final double? margin;
}

class AppPointerTooltipArea extends StatelessWidget {
  const AppPointerTooltipArea({
    super.key,
    required this.child,
    required this.position,
    required this.message,
    required this.onExit,
    this.style,
    this.builder,
  });

  final Widget child;
  final Offset? position;
  final String? message;
  final VoidCallback onExit;
  final AppPointerTooltipStyle? style;
  final AppPointerTooltipBuilder? builder;

  @override
  Widget build(BuildContext context) => MouseRegion(
    onExit: (_) => onExit(),
    child: Stack(
      children: <Widget>[
        Positioned.fill(child: child),
        AppPointerTooltip(
          position: position,
          message: message,
          style: style,
          builder: builder,
        ),
      ],
    ),
  );
}

class AppPointerTooltip extends StatefulWidget {
  const AppPointerTooltip({
    super.key,
    required this.position,
    required this.message,
    this.style,
    this.builder,
  });

  final Offset? position;
  final String? message;
  final AppPointerTooltipStyle? style;
  final AppPointerTooltipBuilder? builder;

  @override
  State<AppPointerTooltip> createState() => _AppPointerTooltipState();
}

class _AppPointerTooltipState extends State<AppPointerTooltip>
    with SingleTickerProviderStateMixin {
  Offset? _position;
  Offset? _previousPosition;
  String? _message;
  bool _shown = false;
  late final AnimationController _moveController;
  late final Animation<double> _moveAnimation;

  bool get _visible => widget.position != null && widget.message != null;

  @override
  void initState() {
    super.initState();
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      value: 1,
    );
    _moveAnimation = CurvedAnimation(
      parent: _moveController,
      curve: Curves.easeOutCubic,
    );
    _retainContent();
    _previousPosition = _position;
    if (_visible) _showAfterLayout();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final config = AppTheme.maybeOf(context);
    final animationsDisabled =
        config?.motion.enabled == false ||
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    _moveController.duration = animationsDisabled
        ? Duration.zero
        : (config?.tooltip.moveDuration ??
              const AppTooltipTheme().moveDuration);
  }

  @override
  void didUpdateWidget(covariant AppPointerTooltip oldWidget) {
    super.didUpdateWidget(oldWidget);
    final oldPosition = _position;
    _retainContent();
    if (_visible && oldPosition != null && oldPosition != _position) {
      if (_moveController.duration == Duration.zero) {
        _previousPosition = _position;
        _moveController.value = 1;
      } else if (_moveController.isCompleted) {
        _previousPosition = oldPosition;
        _moveController.forward(from: 0);
      }
    }
    if (!_visible) {
      _shown = false;
    } else if (oldWidget.position == null || oldWidget.message == null) {
      _shown = false;
      _showAfterLayout();
    }
  }

  void _retainContent() {
    if (_visible) {
      _position = widget.position;
      _message = widget.message;
    }
  }

  void _showAfterLayout() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _visible && !_shown) setState(() => _shown = true);
    });
  }

  @override
  void dispose() {
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_position == null || _message == null) return const SizedBox.shrink();
    final theme = ShadcnTheme.of(context);
    final config = AppTheme.maybeOf(context);
    final tooltip = config?.tooltip ?? const AppTooltipTheme();
    final style = widget.style;
    final duration =
        config?.motion.enabled == false ||
            MediaQuery.maybeOf(context)?.disableAnimations == true
        ? Duration.zero
        : tooltip.fadeDuration;
    return Positioned.fill(
      child: IgnorePointer(
        child: AnimatedOpacity(
          opacity: _shown ? 1 : 0,
          duration: duration,
          curve: Curves.easeOut,
          child: CustomSingleChildLayout(
            delegate: _AppPointerTooltipLayoutDelegate(
              _position!,
              previousPointer: _previousPosition ?? _position!,
              movement: _moveAnimation,
              gap: style?.margin ?? tooltip.margin,
            ),
            child: DecoratedBox(
              key: const ValueKey<String>('app-pointer-tooltip-surface'),
              decoration:
                  style?.decoration ??
                  BoxDecoration(
                    color: theme.colorScheme.popover,
                    border: Border.all(color: theme.colorScheme.border),
                    borderRadius: BorderRadius.circular(tooltip.radius),
                    boxShadow: AppTheme.of(context).shadows.resolve(
                      context,
                      level: AppShadowLevel.floating,
                      colorMode: AppShadowColorMode.custom,
                      color: theme.colorScheme.foreground,
                      blurRadius: 8,
                      spreadRadius: 0,
                      offset: const Offset(0, 2),
                    ),
                  ),
              child: Padding(
                padding: style?.padding ?? tooltip.padding,
                child:
                    widget.builder?.call(context, _message!) ??
                    Text(
                      _message!,
                      style: theme.typography.xSmall
                          .copyWith(
                            color: theme.colorScheme.popoverForeground,
                            fontWeight: FontWeight.w600,
                          )
                          .merge(style?.textStyle),
                    ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppPointerTooltipLayoutDelegate extends SingleChildLayoutDelegate {
  _AppPointerTooltipLayoutDelegate(
    this.pointer, {
    required this.previousPointer,
    required this.movement,
    required this.gap,
  }) : super(relayout: movement);

  final Offset pointer;
  final Offset previousPointer;
  final Animation<double> movement;
  final double gap;
  static const double edge = 6;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) =>
      BoxConstraints(
        maxWidth: math.max(0, constraints.maxWidth - edge * 2),
        maxHeight: math.max(0, constraints.maxHeight - edge * 2),
      );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final previous = _positionForPointer(previousPointer, size, childSize);
    final target = _positionForPointer(pointer, size, childSize);
    if (previous.placeLeft == target.placeLeft &&
        previous.placeAbove == target.placeAbove) {
      return target.offset;
    }
    return Offset.lerp(previous.offset, target.offset, movement.value)!;
  }

  _AppPointerTooltipPlacement _positionForPointer(
    Offset pointer,
    Size size,
    Size childSize,
  ) {
    var x = pointer.dx + gap;
    var y = pointer.dy + gap;
    final placeLeft = x + childSize.width > size.width - edge;
    final placeAbove = y + childSize.height > size.height - edge;
    if (placeLeft) x = pointer.dx - childSize.width - gap;
    if (placeAbove) y = pointer.dy - childSize.height - gap;
    return _AppPointerTooltipPlacement(
      Offset(
        x.clamp(edge, math.max(edge, size.width - childSize.width - edge)),
        y.clamp(edge, math.max(edge, size.height - childSize.height - edge)),
      ),
      placeLeft: placeLeft,
      placeAbove: placeAbove,
    );
  }

  @override
  bool shouldRelayout(covariant _AppPointerTooltipLayoutDelegate oldDelegate) =>
      oldDelegate.pointer != pointer ||
      oldDelegate.previousPointer != previousPointer ||
      oldDelegate.gap != gap;
}

class _AppPointerTooltipPlacement {
  const _AppPointerTooltipPlacement(
    this.offset, {
    required this.placeLeft,
    required this.placeAbove,
  });

  final Offset offset;
  final bool placeLeft;
  final bool placeAbove;
}
