import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/app_overlay_style.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';

enum AppExpandDirection { auto, up, down, left, right }

enum AppExpandAxis { both, horizontal, vertical }

enum AppAnchoredOverlayViewMode { expand, cover }

typedef AppExpandableOverlayBuilder =
    Widget Function(BuildContext context, VoidCallback toggle);

/// Expands an item into the root overlay while its original layout slot keeps
/// the same size. This is intended for cards inside grids and dense dashboards.
class AppExpandableOverlay extends StatefulWidget {
  const AppExpandableOverlay({
    super.key,
    required this.collapsedBuilder,
    required this.expandedBuilder,
    required this.expandedSize,
    this.expanded,
    this.onExpandedChanged,
    this.direction = AppExpandDirection.auto,
    this.axis,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.viewportMargin = 12,
    this.dismissOnTapOutside = true,
    this.closeOnEscape = true,
    this.decorateSurface = true,
    this.contentRevealStart = 0.48,
  }) : overlayMainBuilder = null,
       viewMode = AppAnchoredOverlayViewMode.cover;

  const AppExpandableOverlay.cover({
    super.key,
    required this.collapsedBuilder,
    required this.expandedBuilder,
    required this.expandedSize,
    this.expanded,
    this.onExpandedChanged,
    this.direction = AppExpandDirection.auto,
    this.axis,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.viewportMargin = 12,
    this.dismissOnTapOutside = true,
    this.closeOnEscape = true,
    this.decorateSurface = true,
    this.contentRevealStart = 0.48,
  }) : overlayMainBuilder = null,
       viewMode = AppAnchoredOverlayViewMode.cover;

  /// Keeps [mainBuilder] visible after opening and adds [contentBuilder] in
  /// the resolved expansion direction, similar to a regular collapsible.
  const AppExpandableOverlay.sections({
    super.key,
    required AppExpandableOverlayBuilder mainBuilder,
    required AppExpandableOverlayBuilder contentBuilder,
    this.overlayMainBuilder,
    required this.expandedSize,
    this.expanded,
    this.onExpandedChanged,
    this.direction = AppExpandDirection.auto,
    this.axis,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.viewportMargin = 12,
    this.dismissOnTapOutside = true,
    this.closeOnEscape = true,
    this.decorateSurface = true,
    this.contentRevealStart = 0.48,
  }) : collapsedBuilder = mainBuilder,
       expandedBuilder = contentBuilder,
       viewMode = AppAnchoredOverlayViewMode.expand;

  const AppExpandableOverlay.expand({
    super.key,
    required AppExpandableOverlayBuilder mainBuilder,
    required AppExpandableOverlayBuilder contentBuilder,
    this.overlayMainBuilder,
    required this.expandedSize,
    this.expanded,
    this.onExpandedChanged,
    this.direction = AppExpandDirection.auto,
    this.axis,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.viewportMargin = 12,
    this.dismissOnTapOutside = true,
    this.closeOnEscape = true,
    this.decorateSurface = true,
    this.contentRevealStart = 0.48,
  }) : collapsedBuilder = mainBuilder,
       expandedBuilder = contentBuilder,
       viewMode = AppAnchoredOverlayViewMode.expand;

  AppExpandableOverlay.horizontal({
    super.key,
    required this.collapsedBuilder,
    required this.expandedBuilder,
    required double expandedWidth,
    this.expanded,
    this.onExpandedChanged,
    this.direction = AppExpandDirection.auto,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.viewportMargin = 12,
    this.dismissOnTapOutside = true,
    this.closeOnEscape = true,
    this.decorateSurface = true,
    this.contentRevealStart = 0.48,
  }) : expandedSize = Size(expandedWidth, double.infinity),
       axis = AppExpandAxis.horizontal,
       overlayMainBuilder = null,
       viewMode = AppAnchoredOverlayViewMode.cover;

  final AppExpandableOverlayBuilder collapsedBuilder;
  final AppExpandableOverlayBuilder expandedBuilder;

  /// Optional borderless version of the main view used inside a sections
  /// overlay. This avoids nesting the collapsed card surface inside the
  /// overlay surface. Falls back to [collapsedBuilder] when omitted.
  final AppExpandableOverlayBuilder? overlayMainBuilder;
  final Size expandedSize;
  final bool? expanded;
  final ValueChanged<bool>? onExpandedChanged;
  final AppExpandDirection direction;

  /// The dimensions that may grow.
  ///
  /// When omitted, the resolved [direction] determines the axis: left/right
  /// only change width and up/down only change height. Use
  /// [AppExpandAxis.both] to explicitly allow growth in both dimensions.
  final AppExpandAxis? axis;
  final Duration duration;
  final Curve curve;
  final double viewportMargin;
  final bool dismissOnTapOutside;
  final bool closeOnEscape;
  final bool decorateSurface;

  /// Progress after which section content starts fading in. Keeping content
  /// hidden during the first part of the size animation prevents it from
  /// looking squeezed into a space that has not opened yet.
  final double contentRevealStart;
  final AppAnchoredOverlayViewMode viewMode;

  @override
  State<AppExpandableOverlay> createState() => _AppExpandableOverlayState();
}

class _AppExpandableOverlayState extends State<AppExpandableOverlay>
    with SingleTickerProviderStateMixin {
  final OverlayPortalController _portal = OverlayPortalController();
  final LayerLink _link = LayerLink();
  final GlobalKey _anchorKey = GlobalKey();
  late final AnimationController _animation;
  bool _internalExpanded = false;
  bool _overlayVisible = false;
  Size _anchorSize = Size.zero;
  Offset _anchorGlobal = Offset.zero;

  bool get _controlled => widget.onExpandedChanged != null;
  bool get _expanded =>
      _controlled ? (widget.expanded ?? false) : _internalExpanded;

  @override
  void initState() {
    super.initState();
    _internalExpanded = widget.expanded ?? false;
    _animation = AnimationController(vsync: this, duration: widget.duration);
    if (_expanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openOverlay());
    }
  }

  @override
  void didUpdateWidget(covariant AppExpandableOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncDuration();
    if (_controlled && oldWidget.expanded != widget.expanded) {
      _scheduleOverlaySync();
    } else if (!_controlled && oldWidget.expanded != widget.expanded) {
      _internalExpanded = widget.expanded ?? _internalExpanded;
      _scheduleOverlaySync();
    }
  }

  void _scheduleOverlaySync() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _expanded ? _openOverlay() : _closeOverlay();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncDuration();
  }

  void _syncDuration() {
    final disabled =
        AppTheme.maybeOf(context)?.motion.enabled == false ||
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    _animation.duration = disabled ? Duration.zero : widget.duration;
  }

  @override
  void dispose() {
    _animation.dispose();
    super.dispose();
  }

  void _refreshGeometry() {
    if (!_overlayVisible) return;
    final previousSize = _anchorSize;
    final previousOffset = _anchorGlobal;
    _measureAnchor();
    if (previousSize != _anchorSize || previousOffset != _anchorGlobal) {
      setState(() {});
    }
  }

  void _toggle() => _requestExpanded(!_expanded);

  void _requestExpanded(bool value) {
    if (value == _expanded) return;
    if (_controlled) {
      widget.onExpandedChanged?.call(value);
      return;
    }
    setState(() => _internalExpanded = value);
    value ? _openOverlay() : _closeOverlay();
  }

  void _measureAnchor() {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _anchorSize = box.size;
    _anchorGlobal = box.localToGlobal(Offset.zero);
  }

  void _openOverlay() {
    if (!mounted) return;
    _measureAnchor();
    if (_anchorSize.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _openOverlay());
      return;
    }
    if (!_overlayVisible) {
      setState(() => _overlayVisible = true);
      _portal.show();
    }
    _animation.forward();
  }

  Future<void> _closeOverlay() async {
    if (!_overlayVisible) return;
    await _animation.reverse();
    if (!mounted || _expanded) return;
    _portal.hide();
    setState(() => _overlayVisible = false);
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _link,
      child: OverlayPortal(
        controller: _portal,
        overlayChildBuilder: _buildOverlay,
        child: AppOverlayAnchorTracker(
          enabled: _overlayVisible,
          onGeometryChanged: _refreshGeometry,
          child: KeyedSubtree(
            key: _anchorKey,
            child: IgnorePointer(
              ignoring: _overlayVisible,
              child: Opacity(
                opacity: _overlayVisible ? 0 : 1,
                child: widget.collapsedBuilder(context, _toggle),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final media = MediaQuery.of(context);
    final viewport = media.size;
    final direction = _resolveDirection(viewport);
    final targetSize = _targetSize(viewport, direction);
    final targetOffset = _targetOffset(viewport, targetSize, direction);
    Widget content = widget.viewMode == AppAnchoredOverlayViewMode.expand
        ? _buildSectionContent(context, direction)
        : widget.expandedBuilder(context, _toggle);
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
    if (widget.dismissOnTapOutside) {
      content = TapRegion(
        onTapOutside: (_) => _requestExpanded(false),
        child: content,
      );
    }
    if (widget.closeOnEscape) {
      content = CallbackShortcuts(
        bindings: <ShortcutActivator, VoidCallback>{
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              _requestExpanded(false),
        },
        child: Focus(autofocus: true, child: content),
      );
    }
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final value = widget.curve.transform(_animation.value);
        final size = Size.lerp(_anchorSize, targetSize, value)!;
        return CompositedTransformFollower(
          link: _link,
          showWhenUnlinked: false,
          offset: Offset.lerp(Offset.zero, targetOffset, value)!,
          child: Align(
            alignment: Alignment.topLeft,
            child: SizedBox.fromSize(size: size, child: child),
          ),
        );
      },
      child: content,
    );
  }

  Widget _buildSectionContent(
    BuildContext context,
    AppExpandDirection direction,
  ) {
    final main = SizedBox.fromSize(
      size: _anchorSize,
      child: (widget.overlayMainBuilder ?? widget.collapsedBuilder)(
        context,
        _toggle,
      ),
    );
    final revealStart = widget.contentRevealStart.clamp(0.0, 0.95);
    final details = Expanded(
      child: FadeTransition(
        opacity: CurvedAnimation(
          parent: _animation,
          curve: Interval(revealStart, 1, curve: Curves.easeOut),
          reverseCurve: const Interval(0, 0.5, curve: Curves.easeIn),
        ),
        child: widget.expandedBuilder(context, _toggle),
      ),
    );
    return switch (direction) {
      AppExpandDirection.left => Row(children: <Widget>[details, main]),
      AppExpandDirection.right => Row(children: <Widget>[main, details]),
      AppExpandDirection.up => Column(children: <Widget>[details, main]),
      AppExpandDirection.down => Column(children: <Widget>[main, details]),
      AppExpandDirection.auto => Column(children: <Widget>[main, details]),
    };
  }

  Size _targetSize(Size viewport, AppExpandDirection direction) {
    final axis =
        widget.axis ??
        switch (direction) {
          AppExpandDirection.left ||
          AppExpandDirection.right => AppExpandAxis.horizontal,
          AppExpandDirection.up ||
          AppExpandDirection.down => AppExpandAxis.vertical,
          AppExpandDirection.auto => AppExpandAxis.both,
        };
    final maxWidth = math.max(
      _anchorSize.width,
      viewport.width - widget.viewportMargin * 2,
    );
    final maxHeight = math.max(
      _anchorSize.height,
      viewport.height - widget.viewportMargin * 2,
    );
    final requestedWidth = widget.expandedSize.width.isFinite
        ? widget.expandedSize.width
        : _anchorSize.width;
    final requestedHeight = widget.expandedSize.height.isFinite
        ? widget.expandedSize.height
        : _anchorSize.height;
    return Size(
      axis == AppExpandAxis.vertical
          ? _anchorSize.width
          : requestedWidth.clamp(_anchorSize.width, maxWidth),
      axis == AppExpandAxis.horizontal
          ? _anchorSize.height
          : requestedHeight.clamp(_anchorSize.height, maxHeight),
    );
  }

  Offset _targetOffset(
    Size viewport,
    Size target,
    AppExpandDirection direction,
  ) {
    var offset = switch (direction) {
      AppExpandDirection.left => Offset(_anchorSize.width - target.width, 0),
      AppExpandDirection.up => Offset(0, _anchorSize.height - target.height),
      _ => Offset.zero,
    };
    final viewportMinX = widget.viewportMargin - _anchorGlobal.dx;
    final viewportMaxX =
        viewport.width -
        widget.viewportMargin -
        target.width -
        _anchorGlobal.dx;
    final viewportMinY = widget.viewportMargin - _anchorGlobal.dy;
    final viewportMaxY =
        viewport.height -
        widget.viewportMargin -
        target.height -
        _anchorGlobal.dy;
    offset = Offset(
      _clampOffset(
        offset.dx,
        containMin: math.min(0, _anchorSize.width - target.width),
        containMax: 0,
        viewportMin: viewportMinX,
        viewportMax: viewportMaxX,
      ),
      _clampOffset(
        offset.dy,
        containMin: math.min(0, _anchorSize.height - target.height),
        containMax: 0,
        viewportMin: viewportMinY,
        viewportMax: viewportMaxY,
      ),
    );
    return offset;
  }

  double _clampOffset(
    double value, {
    required double containMin,
    required double containMax,
    required double viewportMin,
    required double viewportMax,
  }) {
    final lower = math.max(containMin, viewportMin);
    final upper = math.min(containMax, viewportMax);
    // Covering the original item has priority when an item already touches or
    // exceeds the configured viewport margin.
    return lower <= upper
        ? value.clamp(lower, upper)
        : value.clamp(containMin, containMax);
  }

  AppExpandDirection _resolveDirection(Size viewport) {
    if (widget.direction != AppExpandDirection.auto) return widget.direction;
    final spaces = <AppExpandDirection, double>{
      if (widget.axis != AppExpandAxis.vertical)
        AppExpandDirection.right:
            viewport.width - _anchorGlobal.dx - _anchorSize.width,
      if (widget.axis != AppExpandAxis.vertical)
        AppExpandDirection.left: _anchorGlobal.dx,
      if (widget.axis != AppExpandAxis.horizontal)
        AppExpandDirection.down:
            viewport.height - _anchorGlobal.dy - _anchorSize.height,
      if (widget.axis != AppExpandAxis.horizontal)
        AppExpandDirection.up: _anchorGlobal.dy,
    };
    return spaces.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
  }
}
