import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../../foundation/app_control_box.dart';
import '../../foundation/app_outline_style.dart';
import '../../foundation/app_overlay_style.dart';
import '../overlay/app_popup_switch_coordinator.dart';
import 'app_inline_edit_overlay_scope.dart';

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
  final GlobalKey _controlKey = GlobalKey();
  late final AppPopupSwitchHandle _popupSwitch;
  bool _open = false;

  @override
  void initState() {
    super.initState();
    _popupSwitch = AppPopupSwitchHandle(
      anchorKey: _controlKey,
      isOpen: () => _open,
      open: _openControl,
    );
  }

  void _setOpen(bool value) {
    if (!mounted || _open == value) return;
    setState(() => _open = value);
  }

  void _handlePopupMounted() {
    _setOpen(true);
  }

  void _handlePopupDisposed() {
    _setOpen(false);
    if (_focusNode.hasFocus) _focusNode.unfocus();
  }

  void _openControl() {
    if (!mounted || _open || !widget.enabled) return;
    invokeFirstPopupButton(_controlKey);
  }

  @override
  void dispose() {
    _popupSwitch.dispose();
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
    final inlineOverlay = AppInlineEditOverlayScope.maybeOf(context);

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

    Widget popup(Widget child) => AppPopupSwitchSurface(
      handle: _popupSwitch,
      onMounted: () {
        inlineOverlay?.opened();
        _handlePopupMounted();
      },
      onDisposed: () {
        _handlePopupDisposed();
        inlineOverlay?.closed();
      },
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
        child: KeyedSubtree(
          key: _controlKey,
          child: widget.builder(context, popup, _focusNode),
        ),
      ),
    );
  }
}
