import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_overlay_style.dart';

/// Shared frame for prompt controls backed by a popover or dialog.
class AppPromptControlFrame extends StatefulWidget {
  const AppPromptControlFrame({
    super.key,
    required this.child,
    this.enabled = true,
    this.maintainBorder = false,
    this.activateOnPointerDown = true,
  }) : builder = null;

  const AppPromptControlFrame.builder({
    super.key,
    required this.builder,
    this.enabled = true,
    this.maintainBorder = false,
    this.activateOnPointerDown = true,
  }) : child = null;

  final Widget? child;
  final Widget Function(
    BuildContext context,
    Widget Function(Widget child) popup,
  )?
  builder;
  final bool enabled;
  final bool maintainBorder;
  final bool activateOnPointerDown;

  @override
  State<AppPromptControlFrame> createState() => _AppPromptControlFrameState();
}

class _AppPromptControlFrameState extends State<AppPromptControlFrame> {
  bool _pointerActive = false;
  bool _focused = false;
  FocusNode? _focusNode;

  void _setPointerActive(bool value) {
    if (!mounted || _pointerActive == value) return;
    setState(() => _pointerActive = value);
  }

  void _handlePopupDisposed() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _setPointerActive(false);
      if (_focused) setState(() => _focused = false);
      WidgetsBinding.instance.endOfFrame.then((_) {
        if (!mounted) return;
        if (_focusNode?.hasFocus == true) _focusNode!.unfocus();
        if (_focused) setState(() => _focused = false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final active = widget.enabled && (_pointerActive || _focused);
    Widget popup(Widget child) =>
        _AppPromptPopupSurface(onDisposed: _handlePopupDisposed, child: child);
    final child = widget.builder?.call(context, popup) ?? widget.child!;
    return Focus(
      onFocusChange: (value) {
        if (_focused != value) setState(() => _focused = value);
      },
      child: Builder(
        builder: (focusContext) {
          _focusNode = Focus.of(focusContext);
          return TapRegion(
            onTapOutside: (_) {
              _setPointerActive(false);
              final focusNode = Focus.of(focusContext);
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted && focusNode.hasFocus) focusNode.unfocus();
              });
            },
            child: Listener(
              onPointerDown: widget.enabled && widget.activateOnPointerDown
                  ? (_) => _setPointerActive(true)
                  : null,
              child: shad.FocusOutline(
                focused: active,
                align: 0,
                borderRadius: BorderRadius.circular(theme.radiusMd),
                border: Border.all(
                  color: theme.colorScheme.ring,
                  width: 1,
                  strokeAlign: BorderSide.strokeAlignInside,
                ),
                child: Stack(
                  fit: StackFit.passthrough,
                  children: [
                    shad.ComponentTheme(
                      data: AppOverlayStyle.cardTheme(context),
                      child: shad.ComponentTheme(
                        data: const shad.FocusOutlineTheme(
                          border: Border.fromBorderSide(BorderSide.none),
                        ),
                        child: child,
                      ),
                    ),
                    if (widget.maintainBorder)
                      Positioned.fill(
                        child: IgnorePointer(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                theme.radiusMd,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.border,
                                width: 1,
                                strokeAlign: BorderSide.strokeAlignInside,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _AppPromptPopupSurface extends StatefulWidget {
  const _AppPromptPopupSurface({required this.onDisposed, required this.child});

  final VoidCallback onDisposed;
  final Widget child;

  @override
  State<_AppPromptPopupSurface> createState() => _AppPromptPopupSurfaceState();
}

class _AppPromptPopupSurfaceState extends State<_AppPromptPopupSurface> {
  @override
  void dispose() {
    widget.onDisposed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
