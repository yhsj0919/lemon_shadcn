import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_overlay_style.dart';

/// Shared frame for prompt controls backed by a popover or dialog.
class AppPromptControlFrame extends StatefulWidget {
  const AppPromptControlFrame({
    super.key,
    required this.child,
    this.enabled = true,
  });

  final Widget child;
  final bool enabled;

  @override
  State<AppPromptControlFrame> createState() => _AppPromptControlFrameState();
}

class _AppPromptControlFrameState extends State<AppPromptControlFrame> {
  bool _active = false;

  void _setActive(bool value) {
    if (!mounted || _active == value) return;
    setState(() => _active = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return TapRegion(
      onTapOutside: (_) => _setActive(false),
      child: Listener(
        onPointerDown: widget.enabled ? (_) => _setActive(true) : null,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            shad.ComponentTheme(
              data: shad.CardTheme(
                boxShadow: AppOverlayStyle.floatingShadows(context),
              ),
              child: shad.ComponentTheme(
                data: const shad.FocusOutlineTheme(
                  border: Border.fromBorderSide(BorderSide.none),
                ),
                child: widget.child,
              ),
            ),
            if (_active && widget.enabled)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(
                        color: theme.colorScheme.ring,
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
    );
  }
}
