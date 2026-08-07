import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_overlay_style.dart';
import '../overlay/app_popup_switch_coordinator.dart';
import 'app_inline_edit_overlay_scope.dart';

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
  final GlobalKey _anchorKey = GlobalKey();
  late final AppPopupSwitchHandle _popupSwitch;
  bool _pointerActive = false;
  bool _focused = false;
  FocusNode? _focusNode;

  @override
  void initState() {
    super.initState();
    _popupSwitch = AppPopupSwitchHandle(
      anchorKey: _anchorKey,
      isOpen: () => _pointerActive,
      open: _openPrompt,
    );
  }

  void _openPrompt() {
    if (!mounted || !widget.enabled) return;
    shad.ObjectFormFieldState<dynamic>? promptState;
    void findPrompt(Element element) {
      if (promptState != null) return;
      if (element is StatefulElement &&
          element.state is shad.ObjectFormFieldState<dynamic>) {
        promptState = element.state as shad.ObjectFormFieldState<dynamic>;
        return;
      }
      element.visitChildElements(findPrompt);
    }

    final context = _anchorKey.currentContext;
    if (context is Element) context.visitChildElements(findPrompt);
    _focusNode?.requestFocus();
    if (promptState != null) {
      promptState!.prompt();
    } else {
      invokeFirstPopupButton(_anchorKey);
    }
  }

  void _setPointerActive(bool value) {
    if (!mounted || _pointerActive == value) return;
    setState(() => _pointerActive = value);
  }

  void _handlePopupDisposed() {
    if (!mounted) return;
    _setPointerActive(false);
    if (_focused) setState(() => _focused = false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (_focusNode?.hasFocus == true) _focusNode!.unfocus();
      if (_focused) setState(() => _focused = false);
    });
  }

  @override
  void dispose() {
    _popupSwitch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final active = widget.enabled && (_pointerActive || _focused);
    final inlineOverlay = AppInlineEditOverlayScope.maybeOf(context);
    Widget popup(Widget child) => AppPopupSwitchSurface(
      handle: _popupSwitch,
      onMounted: () {
        inlineOverlay?.opened();
        _setPointerActive(true);
      },
      onDisposed: () {
        _handlePopupDisposed();
        inlineOverlay?.closed();
      },
      child: child,
    );
    final child = widget.builder?.call(context, popup) ?? widget.child!;
    return KeyedSubtree(
      key: _anchorKey,
      child: Focus(
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
            );
          },
        ),
      ),
    );
  }
}
