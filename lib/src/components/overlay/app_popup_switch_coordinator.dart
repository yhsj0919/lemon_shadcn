import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Coordinates switching between anchored popup controls whose modal barrier
/// consumes the pointer event used to dismiss the previously open popup.
class AppPopupSwitchHandle {
  AppPopupSwitchHandle({
    required this.anchorKey,
    required this.isOpen,
    required this.open,
  }) {
    _handles.add(this);
    if (_handles.length == 1) {
      GestureBinding.instance.pointerRouter.addGlobalRoute(_routePointer);
    }
  }

  static final Set<AppPopupSwitchHandle> _handles = {};
  static AppPopupSwitchHandle? _active;
  static AppPopupSwitchHandle? _pending;

  final GlobalKey anchorKey;
  final bool Function() isOpen;
  final VoidCallback open;
  bool _disposed = false;

  static void _routePointer(PointerEvent event) {
    if (event is! PointerDownEvent || _active == null) return;
    for (final handle in _handles) {
      if (identical(handle, _active) || handle._disposed) continue;
      if (handle._contains(event.position)) {
        _pending = handle;
        return;
      }
    }
  }

  bool _contains(Offset position) {
    final renderObject = anchorKey.currentContext?.findRenderObject();
    if (renderObject is! RenderBox || !renderObject.hasSize) return false;
    return (renderObject.localToGlobal(Offset.zero) & renderObject.size)
        .contains(position);
  }

  void markOpened() {
    if (_disposed) return;
    _active = this;
    if (identical(_pending, this)) _pending = null;
  }

  void markClosed() {
    if (_disposed) return;
    if (identical(_active, this)) _active = null;
    final pending = _pending;
    if (pending == null || pending._disposed || pending.isOpen()) return;
    _pending = null;
    _openAfterFrames(pending, 4);
  }

  static void _openAfterFrames(AppPopupSwitchHandle pending, int frames) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (pending._disposed || pending.isOpen()) return;
      if (frames > 1) {
        _openAfterFrames(pending, frames - 1);
      } else {
        pending.open();
      }
    });
    WidgetsBinding.instance.scheduleFrame();
  }

  void dispose() {
    _disposed = true;
    _handles.remove(this);
    if (identical(_active, this)) _active = null;
    if (identical(_pending, this)) _pending = null;
    if (_handles.isEmpty) {
      GestureBinding.instance.pointerRouter.removeGlobalRoute(_routePointer);
    }
  }
}

void invokeFirstPopupButton(GlobalKey anchorKey) {
  shad.Button? button;
  void findButton(Element element) {
    if (button != null) return;
    if (element.widget case final shad.Button candidate) {
      button = candidate;
      return;
    }
    element.visitChildElements(findButton);
  }

  final context = anchorKey.currentContext;
  if (context is! Element) return;
  context.visitChildElements(findButton);
  button?.onPressed?.call();
}

class AppPopupSwitchSurface extends StatefulWidget {
  const AppPopupSwitchSurface({
    super.key,
    required this.handle,
    required this.child,
    this.onMounted,
    this.onDisposed,
  });

  final AppPopupSwitchHandle handle;
  final Widget child;
  final VoidCallback? onMounted;
  final VoidCallback? onDisposed;

  @override
  State<AppPopupSwitchSurface> createState() => _AppPopupSwitchSurfaceState();
}

class _AppPopupSwitchSurfaceState extends State<AppPopupSwitchSurface> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.handle.markOpened();
        widget.onMounted?.call();
      }
    });
  }

  @override
  void dispose() {
    final handle = widget.handle;
    final onDisposed = widget.onDisposed;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      handle.markClosed();
      onDisposed?.call();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
