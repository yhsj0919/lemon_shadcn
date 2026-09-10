import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_overlay_style.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';
import '../actions/app_button.dart';

typedef AppOverlayController = shad.OverlayController;
typedef AppOverlayCompleter<T> = shad.OverlayCompleter<T>;
typedef AppDialogConfiguration = shad.DialogConfiguration;
typedef AppDrawerConfiguration = shad.DrawerConfiguration;
typedef AppSheetConfiguration = shad.SheetConfiguration;
typedef AppPopoverConfiguration = shad.PopoverConfiguration;
typedef AppMenuConfiguration = shad.MenuConfiguration;
typedef AppToastOverlay = shad.ToastOverlay;
typedef AppToastLocation = shad.ToastLocation;

class AppTooltip extends StatelessWidget {
  const AppTooltip({
    super.key,
    required this.child,
    required this.tooltip,
    this.alignment = Alignment.topCenter,
    this.anchorAlignment = Alignment.bottomCenter,
    this.waitDuration,
    this.showDuration,
    this.minDuration = Duration.zero,
  });

  final Widget child;
  final WidgetBuilder tooltip;
  final AlignmentGeometry alignment;
  final AlignmentGeometry anchorAlignment;
  final Duration? waitDuration;
  final Duration? showDuration;
  final Duration minDuration;

  @override
  Widget build(BuildContext context) {
    final config = AppTheme.maybeOf(context);
    final animationsDisabled =
        config?.motion.enabled == false ||
        MediaQuery.maybeOf(context)?.disableAnimations == true;
    final duration = animationsDisabled
        ? Duration.zero
        : (showDuration ??
              config?.tooltip.fadeDuration ??
              const AppTooltipTheme().fadeDuration);
    final tooltipTheme = config?.tooltip ?? const AppTooltipTheme();
    return shad.Tooltip(
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      waitDuration: waitDuration ?? tooltipTheme.waitDuration,
      showDuration: duration,
      minDuration: minDuration,
      tooltip: (context) => AppTooltipSurface(child: tooltip(context)),
      child: child,
    );
  }
}

class AppTooltipSurface extends StatelessWidget {
  const AppTooltipSurface({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final tooltip =
        AppTheme.maybeOf(context)?.tooltip ?? const AppTooltipTheme();
    return Padding(
      padding: EdgeInsets.all(tooltip.margin),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: tooltip.maxWidth),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.foreground,
            borderRadius: BorderRadius.circular(tooltip.radius),
          ),
          child: Padding(
            padding: tooltip.padding,
            child: DefaultTextStyle.merge(
              style: TextStyle(
                color: theme.colorScheme.background,
                fontSize: tooltip.fontSize,
                height: 1.25,
              ),
              child: IconTheme.merge(
                data: IconThemeData(
                  color: theme.colorScheme.background,
                  size: tooltip.fontSize + 2,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppInstantTooltip extends StatelessWidget {
  const AppInstantTooltip({
    super.key,
    required this.child,
    required this.tooltipBuilder,
    this.behavior = HitTestBehavior.translucent,
    this.tooltipAlignment = Alignment.bottomCenter,
    this.tooltipAnchorAlignment,
  });

  final Widget child;
  final HitTestBehavior behavior;
  final WidgetBuilder tooltipBuilder;
  final AlignmentGeometry tooltipAlignment;
  final AlignmentGeometry? tooltipAnchorAlignment;

  @override
  Widget build(BuildContext context) {
    return shad.InstantTooltip(
      behavior: behavior,
      tooltipAlignment: tooltipAlignment,
      tooltipAnchorAlignment: tooltipAnchorAlignment,
      tooltipBuilder: (context) =>
          AppTooltipSurface(child: tooltipBuilder(context)),
      child: child,
    );
  }
}

class AppHoverCard extends StatelessWidget {
  const AppHoverCard({
    super.key,
    required this.child,
    required this.hoverBuilder,
    this.debounce,
    this.wait,
    this.popoverAlignment,
    this.anchorAlignment,
    this.popoverOffset,
    this.behavior,
    this.controller,
    this.adaptiveOverlay = false,
  });

  final Widget child;
  final WidgetBuilder hoverBuilder;
  final Duration? debounce;
  final Duration? wait;
  final AlignmentGeometry? popoverAlignment;
  final AlignmentGeometry? anchorAlignment;
  final Offset? popoverOffset;
  final HitTestBehavior? behavior;
  final shad.OverlayController? controller;
  final bool adaptiveOverlay;

  @override
  Widget build(BuildContext context) {
    return shad.HoverCard(
      debounce: debounce,
      wait: wait,
      popoverAlignment: popoverAlignment,
      anchorAlignment: anchorAlignment,
      popoverOffset: popoverOffset,
      behavior: behavior,
      controller: controller,
      adaptiveOverlay: adaptiveOverlay,
      hoverBuilder: (context) =>
          AppOverlaySurfaceTheme(child: hoverBuilder(context)),
      child: child,
    );
  }
}

abstract final class AppOverlay {
  static Future<void> close<T>(BuildContext context, [T? value]) =>
      shad.closeOverlay<T>(context, value);
}

abstract final class AppDialog {
  static const BoxConstraints defaultResizeConstraints = BoxConstraints(
    minWidth: 280,
    minHeight: 200,
  );

  /// Shows a dialog. Pass [movable] / [resizable] to opt into drag and resize;
  /// [builder] stays the same as a normal dialog (e.g. [AppAlertDialog]).
  ///
  /// For form / add dialogs that should only drag: `movable: true`,
  /// `resizable: false`, `maximizable: false`. Do not use [showMovable]
  /// (it enables resize). Content keeps its intrinsic size;
  /// [AppFormDialog] defaults to `maxWidth: 480`.
  ///
  /// Window chrome buttons (maximize / close) can be replaced via [controls]
  /// or [controlsBuilder]. Maximize is button-driven (no top-edge snap).
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useRootNavigator = true,
    bool fullScreen = false,
    AlignmentGeometry? alignment,
    bool movable = false,
    bool resizable = false,
    bool maximizable = true,
    bool closable = true,
    Size? initialSize,
    Offset? initialOffset,
    BoxConstraints resizeConstraints = defaultResizeConstraints,
    Widget? controls,
    AppDialogControlsBuilder? controlsBuilder,
  }) {
    final interactive = movable || resizable;
    return shad.DialogConfiguration(
      barrierDismissible: barrierDismissible,
      barrierColor: interactive
          ? (barrierColor ?? AppOverlayStyle.modalBarrier(context))
          : barrierColor,
      useRootNavigator: useRootNavigator,
      fullScreen: interactive ? true : fullScreen,
      alignment: alignment,
    ).show<T>(
      context,
      (dialogContext) => AppButtonMotionScope.disable(
        child: interactive
            ? AppMovableDialog(
                movable: movable,
                resizable: resizable,
                maximizable: maximizable,
                closable: closable,
                initialSize: initialSize,
                initialOffset: initialOffset,
                constraints: resizeConstraints,
                controls: controls,
                controlsBuilder: controlsBuilder,
                builder: builder,
              )
            : builder(dialogContext),
      ),
    );
  }

  /// Alias for [show] with [movable] and [resizable] enabled.
  static shad.OverlayCompleter<T?> showMovable<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useRootNavigator = true,
    bool movable = true,
    bool resizable = true,
    bool maximizable = true,
    bool closable = true,
    Size? initialSize,
    Offset? initialOffset,
    BoxConstraints resizeConstraints = defaultResizeConstraints,
    Widget? controls,
    AppDialogControlsBuilder? controlsBuilder,
  }) {
    return show<T>(
      context: context,
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      movable: movable,
      resizable: resizable,
      maximizable: maximizable,
      closable: closable,
      initialSize: initialSize,
      initialOffset: initialOffset,
      resizeConstraints: resizeConstraints,
      controls: controls,
      controlsBuilder: controlsBuilder,
    );
  }
}

/// Builds replacement window controls for a movable / resizable dialog.
typedef AppDialogControlsBuilder =
    Widget Function(BuildContext context, AppDialogInteraction interaction);

/// Host state for dialogs shown with [AppDialog.show] movable / resizable.
class AppDialogInteraction extends InheritedWidget {
  const AppDialogInteraction({
    super.key,
    required this.movable,
    required this.resizable,
    required this.maximizable,
    required this.closable,
    required this.maximized,
    required this.fillsBounds,
    required this.toggleMaximize,
    required this.close,
    required this.controls,
    required this.controlsBuilder,
    required super.child,
  });

  final bool movable;
  final bool resizable;
  final bool maximizable;
  final bool closable;
  final bool maximized;
  final bool fillsBounds;
  final VoidCallback toggleMaximize;
  final VoidCallback close;
  final Widget? controls;
  final AppDialogControlsBuilder? controlsBuilder;

  static AppDialogInteraction? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppDialogInteraction>();

  bool get showsWindowActions =>
      controls != null ||
      controlsBuilder != null ||
      maximizable ||
      closable;

  Widget buildWindowActions(BuildContext context) {
    if (controls != null) return controls!;
    if (controlsBuilder != null) return controlsBuilder!(context, this);
    return AppDialogWindowActions(interaction: this);
  }

  Widget? mergeTrailing(BuildContext context, Widget? trailing) {
    if (!showsWindowActions) return trailing;
    final actions = buildWindowActions(context);
    if (trailing == null) return actions;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        trailing,
        const SizedBox(width: 8),
        actions,
      ],
    );
  }

  @override
  bool updateShouldNotify(AppDialogInteraction oldWidget) =>
      movable != oldWidget.movable ||
      resizable != oldWidget.resizable ||
      maximizable != oldWidget.maximizable ||
      closable != oldWidget.closable ||
      maximized != oldWidget.maximized ||
      fillsBounds != oldWidget.fillsBounds ||
      controls != oldWidget.controls ||
      controlsBuilder != oldWidget.controlsBuilder;
}

/// Default maximize / close controls for movable dialogs. Replace via
/// [AppDialog.show] `controls` / `controlsBuilder`.
class AppDialogWindowActions extends StatelessWidget {
  const AppDialogWindowActions({super.key, required this.interaction});

  final AppDialogInteraction interaction;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (interaction.maximizable)
          AppIconButton(
            icon: Icon(
              interaction.maximized
                  ? shad.LucideIcons.minimize2
                  : shad.LucideIcons.maximize2,
            ),
            tooltip: interaction.maximized ? '还原' : '最大化',
            variant: AppButtonVariant.ghost,
            onPressed: interaction.toggleMaximize,
          ),
        if (interaction.closable)
          AppIconButton(
            icon: const Icon(shad.LucideIcons.x),
            tooltip: '关闭',
            variant: AppButtonVariant.ghost,
            onPressed: interaction.close,
          ),
      ],
    );
  }
}

/// Lightweight drag / resize shell that hosts the same dialog builder used by
/// a normal [AppDialog.show]. Maximize is available via window actions (no
/// top-edge snap).
class AppMovableDialog extends StatefulWidget {
  const AppMovableDialog({
    super.key,
    required this.builder,
    this.movable = true,
    this.resizable = true,
    this.maximizable = true,
    this.closable = true,
    this.initialSize,
    this.initialOffset,
    this.constraints = AppDialog.defaultResizeConstraints,
    this.controls,
    this.controlsBuilder,
  });

  final WidgetBuilder builder;
  final bool movable;
  final bool resizable;
  final bool maximizable;
  final bool closable;
  final Size? initialSize;
  final Offset? initialOffset;
  final BoxConstraints constraints;
  final Widget? controls;
  final AppDialogControlsBuilder? controlsBuilder;

  @override
  State<AppMovableDialog> createState() => _AppMovableDialogState();
}

class _AppMovableDialogState extends State<AppMovableDialog> {
  static const double _handleExtent = 8;
  static const double _maximizeInset = 24;

  final GlobalKey _dialogKey = GlobalKey();
  Offset? _offset;
  Size? _size;
  Size? _viewport;
  Offset? _restoreOffset;
  Size? _restoreSize;
  bool _maximized = false;
  bool _measureScheduled = false;

  /// Fixed bounds only when the window must fill a box (maximize / resize /
  /// explicit [initialSize]). Movable-only keeps intrinsic content size —
  /// measured [_size] is for positioning, not a forced layout size.
  bool get _forcesSize =>
      _maximized ||
      widget.initialSize != null ||
      (widget.resizable && _size != null);

  Size get _effectiveSize {
    if (_maximized && _viewport != null) return _maximizedRect(_viewport!).size;
    if (_size != null) return _size!;
    if (widget.initialSize != null) return widget.initialSize!;
    final box = _dialogKey.currentContext?.findRenderObject() as RenderBox?;
    if (box != null && box.hasSize) return box.size;
    return const Size(480, 360);
  }

  Size _resolvedViewport(BoxConstraints constraints) {
    final biggest = constraints.biggest;
    if (biggest.width.isFinite && biggest.height.isFinite) return biggest;
    final mq = MediaQuery.sizeOf(context);
    return Size(
      biggest.width.isFinite ? biggest.width : mq.width,
      biggest.height.isFinite ? biggest.height : mq.height,
    );
  }

  Rect _maximizedRect(Size viewport) {
    final width = (viewport.width - _maximizeInset * 2).clamp(
      widget.constraints.minWidth,
      double.infinity,
    );
    final height = (viewport.height - _maximizeInset * 2).clamp(
      widget.constraints.minHeight,
      double.infinity,
    );
    return Rect.fromCenter(
      center: Offset(viewport.width / 2, viewport.height / 2),
      width: width,
      height: height,
    );
  }

  Offset _centeredOffset(Size size, Size viewport) => Offset(
    ((viewport.width - size.width) / 2).clamp(0.0, double.infinity),
    ((viewport.height - size.height) / 2).clamp(0.0, double.infinity),
  );

  void _ensureGeometry(Size viewport) {
    _viewport = viewport;
    if (_maximized) {
      final rect = _maximizedRect(viewport);
      _offset = rect.topLeft;
      _size = rect.size;
      return;
    }
    if (_size == null && widget.initialSize != null) {
      _size = _clampSize(widget.initialSize!, viewport);
    }
    if (_size != null && _offset == null) {
      _offset = widget.initialOffset ?? _centeredOffset(_size!, viewport);
      _offset = _clampOffset(_offset!, _size!, viewport);
    }
    if (_size == null && (widget.resizable || widget.movable)) {
      _scheduleMeasure();
    }
  }

  void _scheduleMeasure() {
    if (_measureScheduled || _size != null) return;
    _measureScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _measureScheduled = false;
      if (!mounted || _size != null || _viewport == null || _maximized) return;
      final box = _dialogKey.currentContext?.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      setState(() {
        // Content-sized (non-resizable) dialogs: clamp to viewport max only —
        // resize minWidth/minHeight must not inflate the measured size used
        // for centering / drag bounds.
        _size = widget.resizable
            ? _clampSize(box.size, _viewport!)
            : _clampMeasuredSize(box.size, _viewport!);
        _offset = widget.initialOffset == null
            ? _centeredOffset(_size!, _viewport!)
            : _clampOffset(widget.initialOffset!, _size!, _viewport!);
      });
    });
  }

  Size _clampSize(Size size, Size viewport) {
    final limits = widget.constraints.enforce(BoxConstraints.loose(viewport));
    return Size(
      size.width.clamp(
        limits.minWidth,
        limits.maxWidth.isFinite ? limits.maxWidth : viewport.width,
      ),
      size.height.clamp(
        limits.minHeight,
        limits.maxHeight.isFinite ? limits.maxHeight : viewport.height,
      ),
    );
  }

  Size _clampMeasuredSize(Size size, Size viewport) {
    final maxW = widget.constraints.maxWidth.isFinite
        ? widget.constraints.maxWidth.clamp(0.0, viewport.width)
        : viewport.width;
    final maxH = widget.constraints.maxHeight.isFinite
        ? widget.constraints.maxHeight.clamp(0.0, viewport.height)
        : viewport.height;
    return Size(
      size.width.clamp(0.0, maxW),
      size.height.clamp(0.0, maxH),
    );
  }

  Offset _clampOffset(Offset offset, Size size, Size viewport) {
    final maxDx = (viewport.width - size.width).clamp(0.0, double.infinity);
    final maxDy = (viewport.height - size.height).clamp(0.0, double.infinity);
    return Offset(offset.dx.clamp(0.0, maxDx), offset.dy.clamp(0.0, maxDy));
  }

  void _toggleMaximize() {
    if (!widget.maximizable || _viewport == null) return;
    setState(() {
      if (_maximized) {
        _maximized = false;
        _size = _restoreSize ?? _size ?? const Size(480, 360);
        _offset =
            _restoreOffset ?? _centeredOffset(_size!, _viewport!);
        _restoreSize = null;
        _restoreOffset = null;
      } else {
        _restoreSize = _effectiveSize;
        _restoreOffset = _offset ?? _centeredOffset(_effectiveSize, _viewport!);
        _maximized = true;
        final rect = _maximizedRect(_viewport!);
        _size = rect.size;
        _offset = rect.topLeft;
      }
    });
  }

  void _close() => AppOverlay.close(context);

  void _onDrag(DragUpdateDetails details) {
    if (!widget.movable || _viewport == null) return;
    if (_maximized) {
      // Dragging a maximized dialog restores it first (no top-edge snap).
      final restored = _restoreSize ?? const Size(480, 360);
      final local = details.globalPosition;
      setState(() {
        _maximized = false;
        _size = restored;
        _offset = _clampOffset(
          Offset(local.dx - restored.width / 2, local.dy - 16),
          restored,
          _viewport!,
        );
        _restoreSize = null;
        _restoreOffset = null;
      });
      return;
    }
    if (_offset == null) return;
    setState(() {
      _offset = _clampOffset(
        _offset! + details.delta,
        _effectiveSize,
        _viewport!,
      );
    });
  }

  void _onResize(Offset delta, {_ResizeEdge edge = _ResizeEdge.bottomRight}) {
    if (!widget.resizable || _maximized || _offset == null || _viewport == null) {
      return;
    }
    final current = _effectiveSize;
    var left = _offset!.dx;
    var top = _offset!.dy;
    var right = left + current.width;
    var bottom = top + current.height;

    if (edge.adjustsLeft) left += delta.dx;
    if (edge.adjustsTop) top += delta.dy;
    if (edge.adjustsRight) right += delta.dx;
    if (edge.adjustsBottom) bottom += delta.dy;

    var next = _clampSize(Size(right - left, bottom - top), _viewport!);
    if (edge.adjustsLeft && !edge.adjustsRight) {
      left = right - next.width;
    } else {
      right = left + next.width;
    }
    if (edge.adjustsTop && !edge.adjustsBottom) {
      top = bottom - next.height;
    } else {
      bottom = top + next.height;
    }
    next = Size(right - left, bottom - top);
    final nextOffset = _clampOffset(Offset(left, top), next, _viewport!);

    setState(() {
      _size = next;
      _offset = nextOffset;
    });
  }

  Widget _resizeHandle({
    required _ResizeEdge edge,
    required double? left,
    required double? top,
    required double? right,
    required double? bottom,
    required double? width,
    required double? height,
    required SystemMouseCursor cursor,
  }) {
    return Positioned(
      left: left,
      top: top,
      right: right,
      bottom: bottom,
      width: width,
      height: height,
      child: MouseRegion(
        cursor: cursor,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onPanUpdate: (details) => _onResize(details.delta, edge: edge),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = _resolvedViewport(constraints);
        _ensureGeometry(viewport);
        final offset = _offset;
        final size = _effectiveSize;
        final canResize = widget.resizable && !_maximized;
        final measureConstraints = BoxConstraints(
          maxWidth: viewport.width,
          maxHeight: viewport.height,
        );

        Widget dialog = KeyedSubtree(
          key: _dialogKey,
          child: Builder(builder: widget.builder),
        );
        if (_forcesSize) {
          dialog = SizedBox(
            width: size.width,
            height: size.height,
            child: dialog,
          );
        } else {
          // Intrinsic / first-measure path: keep cross-axis finite so forms,
          // fields, and scrollables can lay out (Center alone can pass
          // 0..Infinity when the overlay reports unbounded constraints).
          dialog = ConstrainedBox(
            constraints: measureConstraints,
            child: dialog,
          );
        }
        if (widget.movable) {
          dialog = MouseRegion(
            cursor: SystemMouseCursors.move,
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: _onDrag,
              child: dialog,
            ),
          );
        }

        // DialogConfiguration(fullScreen: true) sets ModalContainer fullscreen
        // mode which zeroes corner radius — clear it so dialog chrome keeps
        // rounded corners like a normal AppAlertDialog.
        dialog = shad.MultiModel(
          data: const [
            shad.Model(shad.ModalContainer.kFullScreenMode, false),
          ],
          child: shad.ComponentTheme<shad.ModalBackdropTheme>(
            data: const shad.ModalBackdropTheme(modal: false),
            child: AppDialogInteraction(
              movable: widget.movable,
              resizable: widget.resizable,
              maximizable: widget.maximizable,
              closable: widget.closable,
              maximized: _maximized,
              fillsBounds: _forcesSize,
              toggleMaximize: _toggleMaximize,
              close: _close,
              controls: widget.controls,
              controlsBuilder: widget.controlsBuilder,
              child: dialog,
            ),
          ),
        );

        // Before the first measure, center intrinsically so the panel does not
        // jump from a guessed size origin.
        if (offset == null) {
          return Stack(
            clipBehavior: Clip.none,
            children: [Center(child: dialog)],
          );
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: offset.dx,
              top: offset.dy,
              width: _forcesSize ? size.width : null,
              height: _forcesSize ? size.height : null,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  dialog,
                  if (canResize) ...[
                    _resizeHandle(
                      edge: _ResizeEdge.topLeft,
                      left: -_handleExtent / 2,
                      top: -_handleExtent / 2,
                      right: null,
                      bottom: null,
                      width: _handleExtent,
                      height: _handleExtent,
                      cursor: SystemMouseCursors.resizeUpLeft,
                    ),
                    _resizeHandle(
                      edge: _ResizeEdge.topRight,
                      left: null,
                      top: -_handleExtent / 2,
                      right: -_handleExtent / 2,
                      bottom: null,
                      width: _handleExtent,
                      height: _handleExtent,
                      cursor: SystemMouseCursors.resizeUpRight,
                    ),
                    _resizeHandle(
                      edge: _ResizeEdge.bottomLeft,
                      left: -_handleExtent / 2,
                      top: null,
                      right: null,
                      bottom: -_handleExtent / 2,
                      width: _handleExtent,
                      height: _handleExtent,
                      cursor: SystemMouseCursors.resizeDownLeft,
                    ),
                    _resizeHandle(
                      edge: _ResizeEdge.bottomRight,
                      left: null,
                      top: null,
                      right: -_handleExtent / 2,
                      bottom: -_handleExtent / 2,
                      width: _handleExtent,
                      height: _handleExtent,
                      cursor: SystemMouseCursors.resizeDownRight,
                    ),
                    _resizeHandle(
                      edge: _ResizeEdge.top,
                      left: _handleExtent,
                      top: -_handleExtent / 2,
                      right: _handleExtent,
                      bottom: null,
                      width: null,
                      height: _handleExtent,
                      cursor: SystemMouseCursors.resizeUpDown,
                    ),
                    _resizeHandle(
                      edge: _ResizeEdge.bottom,
                      left: _handleExtent,
                      top: null,
                      right: _handleExtent,
                      bottom: -_handleExtent / 2,
                      width: null,
                      height: _handleExtent,
                      cursor: SystemMouseCursors.resizeUpDown,
                    ),
                    _resizeHandle(
                      edge: _ResizeEdge.left,
                      left: -_handleExtent / 2,
                      top: _handleExtent,
                      right: null,
                      bottom: _handleExtent,
                      width: _handleExtent,
                      height: null,
                      cursor: SystemMouseCursors.resizeLeftRight,
                    ),
                    _resizeHandle(
                      edge: _ResizeEdge.right,
                      left: null,
                      top: _handleExtent,
                      right: -_handleExtent / 2,
                      bottom: _handleExtent,
                      width: _handleExtent,
                      height: null,
                      cursor: SystemMouseCursors.resizeLeftRight,
                    ),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

enum _ResizeEdge {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight,
  top,
  bottom,
  left,
  right;

  bool get adjustsLeft =>
      this == topLeft || this == bottomLeft || this == left;
  bool get adjustsTop => this == topLeft || this == topRight || this == top;
  bool get adjustsRight =>
      this == topRight || this == bottomRight || this == right;
  bool get adjustsBottom =>
      this == bottomLeft || this == bottomRight || this == bottom;
}

/// A shadcn alert dialog with a softer application-level modal backdrop.
///
/// Upstream [shad.AlertDialog] may hardcode a heavy barrier when no color is
/// supplied, so the ambient backdrop theme cannot override it.
///
/// When hosted by a movable / resizable [AppDialog.show], window actions are
/// merged into [trailing] and the surface fills the dialog bounds.
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    this.leading,
    this.title,
    this.content,
    this.actions,
    this.trailing,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.barrierColor,
    this.padding,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? trailing;
  final double? surfaceBlur;
  final double? surfaceOpacity;
  final Color? barrierColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return _AppDialogChrome(
      leading: leading,
      title: title,
      content: content == null ? null : content!.small().muted(),
      actions: actions,
      trailing: trailing,
      surfaceBlur: surfaceBlur,
      surfaceOpacity: surfaceOpacity,
      barrierColor: barrierColor,
      padding: padding,
    );
  }
}

/// Form-oriented dialog shell aligned with [AppAlertDialog].
///
/// Upstream [shad.AlertDialog] forces `content` through `.small().muted()`
/// (confirmation copy). This shell keeps the same chrome and title treatment
/// but leaves [content] at normal body typography for forms and denser copy.
///
/// Omit [actions] (or pass an empty list) for a button-less dialog; dismiss via
/// barrier tap when shown with [AppDialog.show].
class AppFormDialog extends StatelessWidget {
  const AppFormDialog({
    super.key,
    this.leading,
    this.title,
    this.content,
    this.actions,
    this.trailing,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.barrierColor,
    this.backgroundColor,
    this.padding,
    this.constraints = const BoxConstraints(maxWidth: 480),
  });

  final Widget? leading;
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? trailing;
  final double? surfaceBlur;
  final double? surfaceOpacity;
  final Color? barrierColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  /// Width / height caps for the form shell. Defaults to `maxWidth: 480` so
  /// stretch content (fields, columns) can lay out under movable dialogs.
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    return _AppDialogChrome(
      leading: leading,
      title: title,
      content: content,
      actions: actions,
      trailing: trailing,
      surfaceBlur: surfaceBlur,
      surfaceOpacity: surfaceOpacity,
      barrierColor: barrierColor,
      backgroundColor: backgroundColor,
      padding: padding,
      constraints: constraints,
    );
  }
}

class _AppDialogChrome extends StatelessWidget {
  const _AppDialogChrome({
    this.leading,
    this.title,
    this.content,
    this.actions,
    this.trailing,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.barrierColor,
    this.backgroundColor,
    this.padding,
    this.constraints,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? trailing;
  final double? surfaceBlur;
  final double? surfaceOpacity;
  final Color? barrierColor;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final BoxConstraints? constraints;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final densityGap = theme.density.baseGap * scaling;
    final densityContainerPadding =
        theme.density.baseContainerPadding * scaling;
    final interaction = AppDialogInteraction.maybeOf(context);
    final fillsBounds = interaction?.fillsBounds ?? false;
    // Form shells pass maxWidth; under that, header must use Flexible —
    // Row(mainAxisSize: min) lays out non-flex children with infinite
    // max width, which breaks CrossAxisAlignment.stretch form content.
    final boundedHeader =
        fillsBounds || (constraints?.maxWidth.isFinite ?? false);
    // Keep rounded corners always — maximize only insets, it does not go
    // edge-to-edge over the page.
    final borderRadius = theme.borderRadiusXxl;
    final styledTrailing = trailing == null
        ? null
        : trailing!.iconXLarge().iconMutedForeground();
    final resolvedTrailing =
        interaction?.mergeTrailing(context, styledTrailing) ?? styledTrailing;

    final titleColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ?title?.large().semiBold(),
        if (title != null && content != null) SizedBox(height: densityGap),
        ?content,
      ],
    );

    final headerChildren = <Widget>[
      ?leading?.iconXLarge().iconMutedForeground(),
      if (title != null || content != null)
        boundedHeader ? Flexible(child: titleColumn) : titleColumn,
      ?resolvedTrailing,
    ];

    final bodyChildren = <Widget>[
      fillsBounds
          ? Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < headerChildren.length; i++) ...[
                    if (i > 0) SizedBox(width: densityGap * 2),
                    headerChildren[i],
                  ],
                ],
              ),
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: boundedHeader ? MainAxisSize.max : MainAxisSize.min,
              children: [
                for (var i = 0; i < headerChildren.length; i++) ...[
                  if (i > 0) SizedBox(width: densityGap * 2),
                  headerChildren[i],
                ],
              ],
            ),
      if (actions != null && actions!.isNotEmpty) ...[
        SizedBox(height: densityGap * 2),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: fillsBounds || boundedHeader
              ? MainAxisSize.max
              : MainAxisSize.min,
          children: shad.join(actions!, SizedBox(width: densityGap)).toList(),
        ),
      ],
    ];

    Widget surface = shad.ModalContainer(
      fillColor: backgroundColor ?? theme.colorScheme.popover,
      filled: true,
      borderRadius: borderRadius,
      borderWidth: 1 * scaling,
      borderColor: theme.colorScheme.muted,
      padding: padding ?? EdgeInsets.all(densityContainerPadding * 1.5),
      surfaceBlur: surfaceBlur ?? theme.surfaceBlur,
      surfaceOpacity: surfaceOpacity ?? theme.surfaceOpacity,
      child: Column(
        mainAxisSize: fillsBounds ? MainAxisSize.max : MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: bodyChildren,
      ),
    );

    if (fillsBounds) {
      surface = SizedBox.expand(child: surface);
    }

    if (constraints != null) {
      surface = ConstrainedBox(constraints: constraints!, child: surface);
    }

    return shad.ModalBackdrop(
      borderRadius: borderRadius,
      barrierColor: barrierColor ?? AppOverlayStyle.modalBarrier(context),
      surfaceClip: shad.ModalBackdrop.shouldClipSurface(
        surfaceOpacity ?? theme.surfaceOpacity,
      ),
      child: surface,
    );
  }
}

abstract final class AppDrawer {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    shad.OverlayPosition position = shad.OverlayPosition.bottom,
    bool draggable = true,
    bool expands = false,
    bool barrierDismissible = true,
    Color? barrierColor,
    BoxConstraints? constraints,
  }) {
    return shad.DrawerConfiguration(
      position: position,
      draggable: draggable,
      expands: expands,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? AppOverlayStyle.modalBarrier(context),
      constraints: constraints,
    ).show<T>(context, builder);
  }
}

abstract final class AppSheet {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    shad.OverlayPosition position = shad.OverlayPosition.bottom,
    bool draggable = false,
    bool barrierDismissible = true,
    Color? barrierColor,
    BoxConstraints? constraints,
  }) {
    return shad.SheetConfiguration(
      position: position,
      draggable: draggable,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? AppOverlayStyle.modalBarrier(context),
      constraints: constraints,
    ).show<T>(context, builder);
  }
}

abstract final class AppPopover {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    AlignmentGeometry alignment = AppOverlayStyle.popoverAlignment,
    AlignmentGeometry anchorAlignment = AppOverlayStyle.popoverAnchorAlignment,
    Offset offset = AppOverlayStyle.popoverOffset,
    bool modal = true,
    bool barrierDismissible = true,
    bool follow = false,
  }) {
    return shad.PopoverConfiguration(
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      offset: offset,
      modal: modal,
      barrierDismissable: barrierDismissible,
      follow: follow,
    ).show<T>(
      context,
      (context) => AppOverlaySurfaceTheme(child: builder(context)),
    );
  }
}

abstract final class AppToast {
  static shad.ToastOverlay show({
    required BuildContext context,
    required String title,
    String? message,
    shad.ToastLocation location = shad.ToastLocation.bottomRight,
    Duration showDuration = const Duration(seconds: 5),
  }) {
    return custom(
      context: context,
      location: location,
      showDuration: showDuration,
      builder: (context, overlay) => shad.Card(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title).semiBold(),
                  if (message != null) ...[
                    const shad.Gap(4),
                    Text(message).small().muted(),
                  ],
                ],
              ),
            ),
            const shad.Gap(12),
            shad.Button.ghost(
              onPressed: overlay.close,
              child: const Icon(shad.LucideIcons.x),
            ),
          ],
        ),
      ),
    );
  }

  static shad.ToastOverlay custom({
    required BuildContext context,
    required shad.ToastBuilder builder,
    shad.ToastLocation location = shad.ToastLocation.bottomRight,
    bool dismissible = true,
    Duration showDuration = const Duration(seconds: 5),
  }) {
    return shad.showToast(
      context: context,
      builder: (context, overlay) => AppOverlaySurfaceTheme(
        padding: AppOverlayStyle.toastPadding,
        child: builder(context, overlay),
      ),
      location: location,
      dismissible: dismissible,
      showDuration: showDuration,
    );
  }
}
