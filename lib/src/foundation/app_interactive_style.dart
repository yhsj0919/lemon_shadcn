import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_shadcn_scope.dart';
import 'app_theme_config.dart';

enum AppInteractiveHoverTone { accent, deepen }

/// Shared state styling for controls implemented with shadcn button styles.
abstract final class AppInteractiveStyle {
  static shad.AbstractButtonStyle hover(
    shad.AbstractButtonStyle base, {
    AppInteractiveHoverTone tone = AppInteractiveHoverTone.deepen,
    double overlayOpacity = 0.08,
  }) {
    return base.copyWith(
      decoration: (context, states, current) {
        if (!states.contains(WidgetState.hovered)) {
          return current;
        }
        final normalStates = Set<WidgetState>.of(states)
          ..remove(WidgetState.hovered);
        final normal = base.decoration(context, normalStates);
        if (normal is! BoxDecoration) return normal;
        final colors = shad.Theme.of(context).colorScheme;
        return normal.copyWith(
          color: switch (tone) {
            AppInteractiveHoverTone.accent => colors.accent,
            AppInteractiveHoverTone.deepen => Color.alphaBlend(
              colors.foreground.withValues(alpha: overlayOpacity),
              normal.color ?? colors.accent,
            ),
          },
        );
      },
    );
  }
}

/// Adds button-like pointer, keyboard and focus feedback to any widget.
/// This intentionally does not translate, scale or add shadows.
class AppInkWell extends StatefulWidget {
  const AppInkWell({
    super.key,
    required this.child,
    required this.onPressed,
    this.enabled = true,
    this.borderRadius,
    this.hoverOpacity = 0.06,
    this.pressedOpacity = 0.10,
  });

  final Widget child;
  final VoidCallback onPressed;
  final bool enabled;
  final BorderRadiusGeometry? borderRadius;
  final double hoverOpacity;
  final double pressedOpacity;

  @override
  State<AppInkWell> createState() => _AppInkWellState();
}

class _AppInkWellState extends State<AppInkWell> {
  bool _hovered = false;
  bool _pressed = false;
  bool _focused = false;

  void _activate() {
    if (widget.enabled) widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final motion =
        AppTheme.maybeOf(context)?.motion.tokens ?? AppMotionTokens.standard;
    final radius = widget.borderRadius ?? theme.borderRadiusMd;
    final overlayOpacity = !widget.enabled
        ? 0.0
        : _pressed
        ? widget.pressedOpacity
        : _hovered
        ? widget.hoverOpacity
        : 0.0;
    return Semantics(
      button: true,
      enabled: widget.enabled,
      child: FocusableActionDetector(
        enabled: widget.enabled,
        mouseCursor: widget.enabled
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onShowHoverHighlight: (value) => setState(() => _hovered = value),
        onShowFocusHighlight: (value) => setState(() => _focused = value),
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.enter): ActivateIntent(),
          SingleActivator(LogicalKeyboardKey.space): ActivateIntent(),
        },
        actions: {
          ActivateIntent: CallbackAction<ActivateIntent>(
            onInvoke: (_) {
              _activate();
              return null;
            },
          ),
        },
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.enabled ? _activate : null,
          onTapDown: widget.enabled
              ? (_) => setState(() => _pressed = true)
              : null,
          onTapUp: _pressed ? (_) => setState(() => _pressed = false) : null,
          onTapCancel: _pressed ? () => setState(() => _pressed = false) : null,
          child: AnimatedContainer(
            duration: motion.pressDuration,
            foregroundDecoration: BoxDecoration(
              color: theme.colorScheme.foreground.withValues(
                alpha: overlayOpacity,
              ),
              borderRadius: radius,
              border: _focused
                  ? Border.all(color: theme.colorScheme.ring, width: 1)
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}
