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
  });

  final Widget child;
  final bool enabled;
  final bool maintainBorder;
  final bool activateOnPointerDown;

  @override
  State<AppPromptControlFrame> createState() => _AppPromptControlFrameState();
}

class _AppPromptControlFrameState extends State<AppPromptControlFrame> {
  bool _pointerActive = false;
  bool _focused = false;

  void _setPointerActive(bool value) {
    if (!mounted || _pointerActive == value) return;
    setState(() => _pointerActive = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final active = widget.enabled && (_pointerActive || _focused);
    return TapRegion(
      onTapOutside: (_) => _setPointerActive(false),
      child: Focus(
        onFocusChange: (value) {
          if (_focused != value) setState(() => _focused = value);
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
                    child: widget.child,
                  ),
                ),
                if (widget.maintainBorder)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(theme.radiusMd),
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
      ),
    );
  }
}
