import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../../foundation/app_control_box.dart';
import '../../foundation/app_outline_style.dart';
import '../../foundation/app_overlay_style.dart';

typedef AppSelectControlBuilder =
    Widget Function(
      BuildContext context,
      Widget Function(Widget) popup,
      FocusNode focusNode,
    );

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
  final FocusNode _focusNode = FocusNode();
  bool _open = false;

  void _setOpen(bool value) {
    if (!mounted || _open == value) return;
    setState(() => _open = value);
  }

  void _handlePopupDisposed() {
    _setOpen(false);
    if (_focusNode.hasFocus) _focusNode.unfocus();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final grouped = AppWidgetGroup.isItemContext(context);
    final ancestor = shad.ComponentTheme.maybeOf<shad.OutlineButtonTheme>(
      context,
    );

    Decoration decoration(
      BuildContext context,
      Set<WidgetState> states,
      Decoration current,
    ) {
      final resolved = AppOutlineStyle.resolve(
        context,
        states,
        current,
        borderColor: _open ? theme.colorScheme.ring : theme.colorScheme.border,
      );
      if (!grouped || resolved is! BoxDecoration) {
        return resolved;
      }
      return resolved.copyWith(
        border: AppWidgetGroup.clearItemBorder,
        borderRadius: BorderRadius.zero,
      );
    }

    Widget popup(Widget child) => _AppSelectPopupSurface(
      onDisposed: _handlePopupDisposed,
      child: shad.ComponentTheme(
        data: AppOverlayStyle.cardTheme(
          context,
          borderRadius: theme.borderRadiusMd,
        ),
        child: child,
      ),
    );

    return AppControlBox(
      showFocusOutline: !grouped,
      child: shad.ComponentTheme(
        data: (ancestor ?? const shad.OutlineButtonTheme()).copyWith(
          decoration: () => decoration,
        ),
        child: Listener(
          onPointerDown: widget.enabled ? (_) => _setOpen(true) : null,
          child: widget.builder(context, popup, _focusNode),
        ),
      ),
    );
  }
}

class _AppSelectPopupSurface extends StatefulWidget {
  const _AppSelectPopupSurface({required this.child, required this.onDisposed});

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
