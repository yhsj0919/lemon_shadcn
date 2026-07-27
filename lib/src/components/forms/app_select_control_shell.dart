import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_overlay_style.dart';

typedef AppSelectControlBuilder =
    Widget Function(BuildContext context, Widget Function(Widget) popup);

/// Shared visual and lifecycle shell for select-like controls.
class AppSelectControlShell extends StatefulWidget {
  const AppSelectControlShell({
    super.key,
    required this.builder,
    this.enabled = true,
  });

  final AppSelectControlBuilder builder;
  final bool enabled;

  @override
  State<AppSelectControlShell> createState() => _AppSelectControlShellState();
}

class _AppSelectControlShellState extends State<AppSelectControlShell> {
  bool _open = false;

  void _setOpen(bool value) {
    if (!mounted || _open == value) return;
    setState(() => _open = value);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final ancestor = shad.ComponentTheme.maybeOf<shad.OutlineButtonTheme>(
      context,
    );

    Decoration decoration(
      BuildContext context,
      Set<WidgetState> states,
      Decoration current,
    ) {
      if (current is! BoxDecoration) return current;
      return current.copyWith(
        border: Border.all(
          color: _open ? theme.colorScheme.ring : theme.colorScheme.border,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      );
    }

    Widget popup(Widget child) => _AppSelectPopupSurface(
      onDisposed: () => _setOpen(false),
      child: shad.ComponentTheme(
        data: shad.CardTheme(
          boxShadow: AppOverlayStyle.floatingShadows(context),
        ),
        child: child,
      ),
    );

    return AppControlBox(
      child: shad.ComponentTheme(
        data: (ancestor ?? const shad.OutlineButtonTheme()).copyWith(
          decoration: () => decoration,
        ),
        child: Listener(
          onPointerDown: widget.enabled ? (_) => _setOpen(true) : null,
          child: widget.builder(context, popup),
        ),
      ),
    );
  }
}

class _AppSelectPopupSurface extends StatefulWidget {
  const _AppSelectPopupSurface({
    required this.child,
    required this.onDisposed,
  });

  final Widget child;
  final VoidCallback onDisposed;

  @override
  State<_AppSelectPopupSurface> createState() => _AppSelectPopupSurfaceState();
}

class _AppSelectPopupSurfaceState extends State<_AppSelectPopupSurface> {
  @override
  void dispose() {
    final onDisposed = widget.onDisposed;
    WidgetsBinding.instance.addPostFrameCallback((_) => onDisposed());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
