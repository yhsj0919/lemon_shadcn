import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_overlay_style.dart';

typedef AppWindowWidget = shad.WindowWidget;
typedef AppWindowState = shad.WindowState;
typedef AppWindowSnapStrategy = shad.WindowSnapStrategy;
typedef AppWindowActions = shad.WindowActions;
typedef AppWindowViewport = shad.WindowViewport;

/// A window controller that keeps the complete title bar inside its viewport.
class AppWindowController extends shad.WindowController {
  AppWindowController({
    required super.bounds,
    super.maximized,
    super.minimized,
    super.focused,
    super.closable,
    super.resizable,
    super.draggable,
    super.maximizable,
    super.minimizable,
    super.enableSnapping,
    super.constraints,
  });

  Size? _viewportSize;
  double titleBarHeight = 32;

  void updateViewport(Size size) {
    if (_viewportSize == size) return;
    _viewportSize = size;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_viewportSize == size) value = value;
    });
  }

  @override
  set value(shad.WindowState next) {
    final viewport = _viewportSize;
    if (viewport != null && next.maximized == null) {
      final bounds = next.bounds;
      final maxLeft = math.max(0.0, viewport.width - bounds.width);
      final maxTop = math.max(0.0, viewport.height - titleBarHeight);
      final clamped = Rect.fromLTWH(
        bounds.left.clamp(0.0, maxLeft),
        bounds.top.clamp(0.0, maxTop),
        bounds.width,
        bounds.height,
      );
      if (clamped != bounds) {
        next = next.copyWith(bounds: () => clamped);
      }
    }
    super.value = next;
  }
}

/// Lemon window configuration backed by a constrained upstream controller.
class AppWindow extends shad.Window {
  factory AppWindow({
    Widget? title,
    Widget? actions = const shad.WindowActions(),
    Widget? content,
    bool resizable = true,
    bool draggable = true,
    bool closable = true,
    bool maximizable = true,
    bool minimizable = true,
    bool enableSnapping = true,
    required Rect bounds,
    Rect? maximized,
    bool minimized = false,
    bool alwaysOnTop = false,
    BoxConstraints constraints = shad.kDefaultWindowConstraints,
  }) {
    final controller = AppWindowController(
      bounds: bounds,
      maximized: maximized,
      minimized: minimized,
      focused: alwaysOnTop,
      closable: closable,
      resizable: resizable,
      draggable: draggable,
      maximizable: maximizable,
      minimizable: minimizable,
      enableSnapping: enableSnapping,
      constraints: constraints,
    );
    return AppWindow.controlled(
      title: title,
      actions: actions,
      content: content,
      controller: controller,
    );
  }

  AppWindow.controlled({
    super.title,
    super.actions = const shad.WindowActions(),
    super.content,
    required AppWindowController super.controller,
  }) : super.controlled();

  // WindowNavigator reads this configuration getter directly while moving a
  // window between its normal and dragging layers. Upstream controlled
  // windows store the value only in the controller, leaving the field null.
  @override
  bool get alwaysOnTop => controller!.value.alwaysOnTop;
}

/// Upstream window navigator with Lemon's shadow and safe drag bounds defaults.
class AppWindowNavigator extends StatelessWidget {
  const AppWindowNavigator({
    super.key,
    required this.initialWindows,
    this.child,
    this.showTopSnapBar = true,
  });

  final List<shad.Window> initialWindows;
  final Widget? child;
  final bool showTopSnapBar;

  @override
  Widget build(BuildContext context) {
    final inheritedCardTheme = shad.ComponentTheme.maybeOf<shad.CardTheme>(
      context,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = constraints.biggest;
        for (final window in initialWindows) {
          final controller = window.controller;
          if (controller is AppWindowController) {
            controller.updateViewport(viewport);
          }
        }
        return shad.ComponentTheme<shad.CardTheme>(
          data: (inheritedCardTheme ?? const shad.CardTheme()).copyWith(
            boxShadow: () => AppOverlayStyle.floatingShadows(context),
          ),
          child: shad.WindowNavigator(
            initialWindows: initialWindows,
            showTopSnapBar: showTopSnapBar,
            child: child,
          ),
        );
      },
    );
  }
}
