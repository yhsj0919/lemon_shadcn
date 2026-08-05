import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../foundation/app_theme_aliases.dart';

/// Controls an [AppChartExportBoundary].
///
/// The controller deliberately returns bytes instead of writing a file so the
/// package remains platform independent. Applications can download, share, or
/// upload the PNG using their existing platform service.
class AppChartExportController {
  _AppChartExportBoundaryState? _state;

  bool get attached => _state != null;

  Future<ui.Image> captureImage({double pixelRatio = 2}) {
    assert(pixelRatio > 0);
    final state = _state;
    if (state == null) {
      throw StateError(
        'AppChartExportController is not attached to an '
        'AppChartExportBoundary.',
      );
    }
    return state.captureImage(pixelRatio: pixelRatio);
  }

  Future<Uint8List> capturePng({double pixelRatio = 2}) async {
    final image = await captureImage(pixelRatio: pixelRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) {
        throw StateError('Unable to encode the chart as PNG.');
      }
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    } finally {
      image.dispose();
    }
  }
}

/// A platform-neutral export boundary shared by every App chart.
class AppChartExportBoundary extends StatefulWidget {
  const AppChartExportBoundary({
    super.key,
    required this.controller,
    required this.child,
    this.backgroundColor,
    this.padding = EdgeInsets.zero,
  });

  final AppChartExportController controller;
  final Widget child;

  /// Defaults to the active shadcn background color. Set transparent to export
  /// only the chart pixels.
  final Color? backgroundColor;
  final EdgeInsetsGeometry padding;

  @override
  State<AppChartExportBoundary> createState() => _AppChartExportBoundaryState();
}

class _AppChartExportBoundaryState extends State<AppChartExportBoundary> {
  final GlobalKey _boundaryKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _attach(widget.controller);
  }

  @override
  void didUpdateWidget(covariant AppChartExportBoundary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _detach(oldWidget.controller);
      _attach(widget.controller);
    }
  }

  @override
  void dispose() {
    _detach(widget.controller);
    super.dispose();
  }

  void _attach(AppChartExportController controller) {
    final owner = controller._state;
    if (owner != null && owner != this) {
      throw FlutterError(
        'An AppChartExportController cannot be attached to multiple '
        'AppChartExportBoundary widgets.',
      );
    }
    controller._state = this;
  }

  void _detach(AppChartExportController controller) {
    if (controller._state == this) controller._state = null;
  }

  Future<ui.Image> captureImage({required double pixelRatio}) async {
    final context = _boundaryKey.currentContext;
    var boundary = context?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) {
      throw StateError('The chart export boundary is not ready to capture.');
    }
    if (boundary.debugNeedsPaint) {
      WidgetsBinding.instance.scheduleFrame();
      await WidgetsBinding.instance.endOfFrame;
      boundary =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
    }
    if (boundary == null || boundary.debugNeedsPaint) {
      throw StateError('The chart export boundary is not ready to capture.');
    }
    return boundary.toImage(pixelRatio: pixelRatio);
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadcnTheme.of(context);
    return RepaintBoundary(
      key: _boundaryKey,
      child: ColoredBox(
        color: widget.backgroundColor ?? theme.colorScheme.background,
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );
  }
}
