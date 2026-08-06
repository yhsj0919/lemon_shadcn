import 'package:flutter/material.dart';

/// Covers [child] with a fully custom [overlay] while the pointer is inside.
///
/// The overlay is constrained to exactly the same bounds as [child]. This
/// widget does not add a scrim, background, padding, or alignment: callers own
/// the complete visual treatment of the overlay.
class AppHoverOverlay extends StatefulWidget {
  const AppHoverOverlay({
    super.key,
    required this.child,
    required this.overlay,
    this.enabled = true,
    this.duration = const Duration(milliseconds: 160),
    this.curve = Curves.easeOutCubic,
    this.borderRadius,
    this.clipBehavior = Clip.antiAlias,
    this.cursor = MouseCursor.defer,
    this.onHoverChanged,
  });

  /// The layout whose size defines the hover and cover area.
  final Widget child;

  /// Fully custom content stretched over [child].
  final Widget overlay;

  final bool enabled;
  final Duration duration;
  final Curve curve;
  final BorderRadiusGeometry? borderRadius;
  final Clip clipBehavior;
  final MouseCursor cursor;
  final ValueChanged<bool>? onHoverChanged;

  @override
  State<AppHoverOverlay> createState() => _AppHoverOverlayState();
}

class _AppHoverOverlayState extends State<AppHoverOverlay> {
  bool _hovered = false;

  void _setHovered(bool value) {
    if (_hovered == value) return;
    setState(() => _hovered = value);
    widget.onHoverChanged?.call(value);
  }

  @override
  void didUpdateWidget(AppHoverOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled && !widget.enabled && _hovered) {
      _hovered = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.onHoverChanged?.call(false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = widget.enabled && _hovered;
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = reduceMotion ? Duration.zero : widget.duration;

    Widget content = Stack(
      fit: StackFit.passthrough,
      children: [
        widget.child,
        Positioned.fill(
          child: ExcludeSemantics(
            excluding: !visible,
            child: IgnorePointer(
              ignoring: !visible,
              child: AnimatedOpacity(
                opacity: visible ? 1 : 0,
                duration: duration,
                curve: widget.curve,
                child: widget.overlay,
              ),
            ),
          ),
        ),
      ],
    );

    final borderRadius = widget.borderRadius;
    if (borderRadius != null) {
      content = ClipRRect(
        borderRadius: borderRadius.resolve(Directionality.of(context)),
        clipBehavior: widget.clipBehavior,
        child: content,
      );
    }

    return MouseRegion(
      cursor: widget.cursor,
      onEnter: widget.enabled ? (_) => _setHovered(true) : null,
      onExit: widget.enabled ? (_) => _setHovered(false) : null,
      child: content,
    );
  }
}
