import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/app_overlay_style.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';

enum AppAnchoredOverlayTrigger { click, hover, focus, manual }

enum AppAnchoredOverlayPlacement { auto, top, bottom, left, right }

enum AppAnchoredOverlayWidth { content, matchAnchor, fixed }

typedef AppAnchoredOverlayBuilder =
    Widget Function(BuildContext context, AppAnchoredOverlayActions actions);

class AppAnchoredOverlayActions {
  const AppAnchoredOverlayActions({
    required this.isOpen,
    required this.open,
    required this.close,
    required this.toggle,
  });

  final bool isOpen;
  final VoidCallback open;
  final VoidCallback close;
  final VoidCallback toggle;
}

/// General-purpose overlay anchored to any widget.
///
/// Use [anchorBuilder] for the wrapped widget and [overlayBuilder] for the
/// floating content. Placement can be directional or expressed as custom
/// target/follower alignment points.
class AppAnchoredOverlay extends StatefulWidget {
  const AppAnchoredOverlay({
    super.key,
    required this.anchorBuilder,
    required this.overlayBuilder,
    this.triggers = const <AppAnchoredOverlayTrigger>{
      AppAnchoredOverlayTrigger.click,
    },
    this.placement = AppAnchoredOverlayPlacement.auto,
    this.targetAnchor,
    this.followerAnchor,
    this.offset = Offset.zero,
    this.gap = 8,
    this.width = AppAnchoredOverlayWidth.content,
    this.fixedWidth,
    this.maxWidth = 480,
    this.maxHeight = 420,
    this.viewportMargin = 12,
    this.open,
    this.onOpenChanged,
    this.dismissOnTapOutside = true,
    this.closeOnEscape = true,
    this.decorateSurface = true,
    this.hoverOpenDelay = const Duration(milliseconds: 120),
    this.hoverCloseDelay = const Duration(milliseconds: 120),
    this.duration = const Duration(milliseconds: 160),
    this.curve = Curves.easeOutCubic,
  }) : assert(
         width != AppAnchoredOverlayWidth.fixed || fixedWidth != null,
         'fixedWidth is required when width is fixed.',
       );

  final AppAnchoredOverlayBuilder anchorBuilder;
  final AppAnchoredOverlayBuilder overlayBuilder;
  final Set<AppAnchoredOverlayTrigger> triggers;
  final AppAnchoredOverlayPlacement placement;
  final Alignment? targetAnchor;
  final Alignment? followerAnchor;
  final Offset offset;
  final double gap;
  final AppAnchoredOverlayWidth width;
  final double? fixedWidth;
  final double maxWidth;
  final double maxHeight;
  final double viewportMargin;
  final bool? open;
  final ValueChanged<bool>? onOpenChanged;
  final bool dismissOnTapOutside;
  final bool closeOnEscape;
  final bool decorateSurface;
  final Duration hoverOpenDelay;
  final Duration hoverCloseDelay;
  final Duration duration;
  final Curve curve;

  @override
  State<AppAnchoredOverlay> createState() => _AppAnchoredOverlayState();
}

class _AppAnchoredOverlayState extends State<AppAnchoredOverlay>
    with SingleTickerProviderStateMixin {
  final LayerLink _link = LayerLink();
  final OverlayPortalController _portal = OverlayPortalController();
  final GlobalKey _anchorKey = GlobalKey();
  late final AnimationController _animation;
  bool _internalOpen = false;
  bool _overlayVisible = false;
  bool _hoveringOverlay = false;
  Size _anchorSize = Size.zero;
  Offset _anchorGlobal = Offset.zero;
  Timer? _hoverTimer;

  bool get _controlled => widget.onOpenChanged != null;
  bool get _open => _controlled ? (widget.open ?? false) : _internalOpen;

  AppAnchoredOverlayActions get _actions => AppAnchoredOverlayActions(
    isOpen: _open,
    open: () => _requestOpen(true),
    close: () => _requestOpen(false),
    toggle: () => _requestOpen(!_open),
  );

  @override
  void initState() {
    super.initState();
    _internalOpen = widget.open ?? false;
    _animation = AnimationController(vsync: this, duration: widget.duration);
    if (_open) WidgetsBinding.instance.addPostFrameCallback((_) => _show());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDuration();
  }

  @override
  void didUpdateWidget(AppAnchoredOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDuration();
    if (_controlled && oldWidget.open != widget.open) {
      _open ? _show() : _hide();
    }
  }

  void _syncDuration() {
    final disabled =
        AppTheme.maybeOf(context)?.motion.enabled == false ||
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    _animation.duration = disabled ? Duration.zero : widget.duration;
  }

  void _measureAnchor() {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _anchorSize = box.size;
    _anchorGlobal = box.localToGlobal(Offset.zero);
  }

  void _refreshGeometry() {
    if (!_overlayVisible) return;
    final oldSize = _anchorSize;
    final oldOffset = _anchorGlobal;
    _measureAnchor();
    if (oldSize != _anchorSize || oldOffset != _anchorGlobal) setState(() {});
  }

  void _requestOpen(bool value) {
    _hoverTimer?.cancel();
    if (value == _open) return;
    if (_controlled) {
      widget.onOpenChanged?.call(value);
      return;
    }
    setState(() => _internalOpen = value);
    value ? _show() : _hide();
  }

  void _show() {
    if (!mounted) return;
    _measureAnchor();
    if (_anchorSize.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _show());
      return;
    }
    if (!_overlayVisible) {
      setState(() => _overlayVisible = true);
      _portal.show();
    }
    _animation.forward();
  }

  Future<void> _hide() async {
    if (!_overlayVisible) return;
    await _animation.reverse();
    if (!mounted || _open) return;
    _portal.hide();
    setState(() => _overlayVisible = false);
  }

  void _scheduleHover(bool value) {
    _hoverTimer?.cancel();
    final delay = value ? widget.hoverOpenDelay : widget.hoverCloseDelay;
    _hoverTimer = Timer(delay, () {
      if (!mounted || (!value && _hoveringOverlay)) return;
      _requestOpen(value);
    });
  }

  @override
  void dispose() {
    _hoverTimer?.cancel();
    _animation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget anchor = widget.anchorBuilder(context, _actions);
    if (widget.triggers.contains(AppAnchoredOverlayTrigger.click)) {
      anchor = GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: _actions.toggle,
        child: anchor,
      );
    }
    if (widget.triggers.contains(AppAnchoredOverlayTrigger.focus)) {
      anchor = Focus(onFocusChange: _requestOpen, child: anchor);
    }
    if (widget.triggers.contains(AppAnchoredOverlayTrigger.hover)) {
      anchor = MouseRegion(
        onEnter: (_) => _scheduleHover(true),
        onExit: (_) => _scheduleHover(false),
        child: anchor,
      );
    }
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: TapRegion(
          groupId: this,
          child: AppOverlayAnchorTracker(
            enabled: _overlayVisible,
            onGeometryChanged: _refreshGeometry,
            child: KeyedSubtree(key: _anchorKey, child: anchor),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final viewport = MediaQuery.sizeOf(context);
    final placement = _resolvePlacement(viewport);
    final anchors = _anchorsFor(placement);
    final availableWidth = math.max(
      0.0,
      viewport.width - widget.viewportMargin * 2,
    );
    final availableHeight = math.max(
      0.0,
      viewport.height - widget.viewportMargin * 2,
    );
    final width = switch (widget.width) {
      AppAnchoredOverlayWidth.content => null,
      AppAnchoredOverlayWidth.matchAnchor => _anchorSize.width,
      AppAnchoredOverlayWidth.fixed => widget.fixedWidth,
    };
    final placementWidth = switch (placement) {
      AppAnchoredOverlayPlacement.left =>
        _anchorGlobal.dx - widget.gap - widget.viewportMargin,
      AppAnchoredOverlayPlacement.right =>
        viewport.width -
            widget.viewportMargin -
            _anchorGlobal.dx -
            _anchorSize.width -
            widget.gap,
      _ => availableWidth,
    };
    final placementHeight = switch (placement) {
      AppAnchoredOverlayPlacement.top =>
        _anchorGlobal.dy - widget.gap - widget.viewportMargin,
      AppAnchoredOverlayPlacement.bottom || AppAnchoredOverlayPlacement.auto =>
        viewport.height -
            widget.viewportMargin -
            _anchorGlobal.dy -
            _anchorSize.height -
            widget.gap,
      _ => availableHeight,
    };
    final constrainedMaxWidth = math.max(
      0.0,
      math.min(widget.maxWidth, placementWidth),
    );
    final constrainedMaxHeight = math.max(
      0.0,
      math.min(widget.maxHeight, placementHeight),
    );
    final collisionOffset = _collisionOffset(
      viewport: viewport,
      placement: placement,
      maxWidth: constrainedMaxWidth,
      maxHeight: constrainedMaxHeight,
    );
    Widget overlayContent = widget.overlayBuilder(context, _actions);
    if (width != null) {
      overlayContent = SizedBox(width: width, child: overlayContent);
    }
    Widget content = ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: constrainedMaxWidth,
        maxHeight: constrainedMaxHeight,
      ),
      child: overlayContent,
    );
    if (widget.decorateSurface) {
      final theme = ShadcnTheme.of(context);
      content = AppOverlayShadow(
        child: ClipRRect(
          borderRadius: AppOverlayStyle.surfaceBorderRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: theme.colorScheme.card,
              border: Border.all(color: theme.colorScheme.border),
              borderRadius: AppOverlayStyle.surfaceBorderRadius,
            ),
            child: content,
          ),
        ),
      );
    }
    if (widget.closeOnEscape) {
      content = CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): _actions.close,
        },
        child: Focus(autofocus: true, child: content),
      );
    }
    content = MouseRegion(
      onEnter: (_) {
        _hoveringOverlay = true;
        _hoverTimer?.cancel();
      },
      onExit: (_) {
        _hoveringOverlay = false;
        if (widget.triggers.contains(AppAnchoredOverlayTrigger.hover)) {
          _scheduleHover(false);
        }
      },
      child: TapRegion(
        groupId: this,
        onTapOutside: widget.dismissOnTapOutside
            ? (_) => _actions.close()
            : null,
        child: content,
      ),
    );
    return UnconstrainedBox(
      alignment: Alignment.topLeft,
      child: CompositedTransformFollower(
        link: _link,
        showWhenUnlinked: false,
        targetAnchor: widget.targetAnchor ?? anchors.$1,
        followerAnchor: widget.followerAnchor ?? anchors.$2,
        offset: widget.offset + anchors.$3 + collisionOffset,
        child: FadeTransition(
          opacity: CurvedAnimation(parent: _animation, curve: widget.curve),
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.98,
              end: 1,
            ).animate(CurvedAnimation(parent: _animation, curve: widget.curve)),
            child: content,
          ),
        ),
      ),
    );
  }

  Offset _collisionOffset({
    required Size viewport,
    required AppAnchoredOverlayPlacement placement,
    required double maxWidth,
    required double maxHeight,
  }) {
    if (placement == AppAnchoredOverlayPlacement.top ||
        placement == AppAnchoredOverlayPlacement.bottom ||
        placement == AppAnchoredOverlayPlacement.auto) {
      final desiredLeft = _anchorGlobal.dx + (_anchorSize.width - maxWidth) / 2;
      final minLeft = widget.viewportMargin;
      final maxLeft = math.max(
        minLeft,
        viewport.width - widget.viewportMargin - maxWidth,
      );
      return Offset(desiredLeft.clamp(minLeft, maxLeft) - desiredLeft, 0);
    }

    final desiredTop = _anchorGlobal.dy + (_anchorSize.height - maxHeight) / 2;
    final minTop = widget.viewportMargin;
    final maxTop = math.max(
      minTop,
      viewport.height - widget.viewportMargin - maxHeight,
    );
    return Offset(0, desiredTop.clamp(minTop, maxTop) - desiredTop);
  }

  AppAnchoredOverlayPlacement _resolvePlacement(Size viewport) {
    if (widget.placement != AppAnchoredOverlayPlacement.auto) {
      return widget.placement;
    }
    final spaces = <AppAnchoredOverlayPlacement, double>{
      AppAnchoredOverlayPlacement.bottom:
          viewport.height - _anchorGlobal.dy - _anchorSize.height,
      AppAnchoredOverlayPlacement.top: _anchorGlobal.dy,
      AppAnchoredOverlayPlacement.right:
          viewport.width - _anchorGlobal.dx - _anchorSize.width,
      AppAnchoredOverlayPlacement.left: _anchorGlobal.dx,
    };
    return spaces.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }

  (Alignment, Alignment, Offset) _anchorsFor(
    AppAnchoredOverlayPlacement placement,
  ) => switch (placement) {
    AppAnchoredOverlayPlacement.top => (
      Alignment.topCenter,
      Alignment.bottomCenter,
      Offset(0, -widget.gap),
    ),
    AppAnchoredOverlayPlacement.bottom || AppAnchoredOverlayPlacement.auto => (
      Alignment.bottomCenter,
      Alignment.topCenter,
      Offset(0, widget.gap),
    ),
    AppAnchoredOverlayPlacement.left => (
      Alignment.centerLeft,
      Alignment.centerRight,
      Offset(-widget.gap, 0),
    ),
    AppAnchoredOverlayPlacement.right => (
      Alignment.centerRight,
      Alignment.centerLeft,
      Offset(widget.gap, 0),
    ),
  };
}
