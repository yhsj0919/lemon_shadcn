import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../../foundation/app_theme_config.dart';
import '../overlay/app_pointer_tooltip.dart';
import 'app_chart_common.dart';

@immutable
class AppCandlestickData {
  const AppCandlestickData({
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    this.label,
    this.color,
  }) : assert(high >= open && high >= close && high >= low),
       assert(low <= open && low <= close);

  final double open;
  final double high;
  final double low;
  final double close;
  final String? label;
  final Color? color;

  bool get isRising => close >= open;
}

@immutable
class AppCandlestickChartHit {
  const AppCandlestickChartHit({required this.index, required this.data});

  final int index;
  final AppCandlestickData data;
}

class AppCandlestickChart extends StatefulWidget {
  const AppCandlestickChart({
    super.key,
    required this.data,
    this.xAxis = const AppChartAxis(),
    this.yAxis = const AppChartAxis(),
    this.height,
    this.risingColor,
    this.fallingColor,
    this.showGrid = true,
    this.showTooltip = true,
    this.showValues = false,
    this.interactive = true,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.semanticLabel = 'K 线图，使用左右方向键浏览数据',
    this.labelFormatter,
    this.valueFormatter,
    this.tooltipBuilder,
    this.onCandleTap,
  });

  final List<AppCandlestickData> data;
  final AppChartAxis xAxis;
  final AppChartAxis yAxis;
  final double? height;
  final Color? risingColor;
  final Color? fallingColor;
  final bool showGrid;
  final bool showTooltip;
  final bool showValues;
  final bool interactive;
  final bool keyboardNavigation;
  final bool autofocus;
  final String semanticLabel;
  final String Function(int index, AppCandlestickData data)? labelFormatter;
  final String Function(double value)? valueFormatter;
  final String Function(int index, AppCandlestickData data)? tooltipBuilder;
  final ValueChanged<AppCandlestickChartHit>? onCandleTap;

  @override
  State<AppCandlestickChart> createState() => _AppCandlestickChartState();
}

class _AppCandlestickChartState extends State<AppCandlestickChart> {
  int? _hoveredIndex;
  Offset? _tooltipPosition;
  String? _tooltipMessage;

  @override
  Widget build(BuildContext context) {
    final config = AppTheme.maybeOf(context);
    final chart = config?.chart ?? const AppChartTheme();
    final theme = ShadcnTheme.of(context);
    final palette = appChartPalette(chart, theme.colorScheme, null);
    final rising = widget.risingColor ?? palette[1 % palette.length];
    final falling = widget.fallingColor ?? palette.first;

    return AppChartKeyboardRegion(
      enabled: widget.keyboardNavigation && widget.data.isNotEmpty,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      onPrevious: () => _move(-1),
      onNext: () => _move(1),
      onActivate: _activateCurrent,
      onClear: _clear,
      child: SizedBox(
        height: widget.height ?? chart.height,
        child: widget.data.isEmpty
            ? Center(
                child: Text(
                  '暂无数据',
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final geometry = _geometry(constraints.biggest, chart, theme);
                  return AppPointerTooltipArea(
                    position: _tooltipPosition,
                    message: _tooltipMessage,
                    onExit: _clear,
                    child: MouseRegion(
                      cursor: widget.interactive
                          ? SystemMouseCursors.click
                          : SystemMouseCursors.basic,
                      onHover: widget.interactive
                          ? (event) =>
                                _updatePointer(event.localPosition, geometry)
                          : null,
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTapUp: widget.interactive
                            ? (details) {
                                final index = geometry.indexAt(
                                  details.localPosition,
                                );
                                if (index != null) _activate(index);
                              }
                            : null,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween<double>(begin: 0, end: 1),
                          duration:
                              config?.motion.enabled == false ||
                                  MediaQuery.maybeOf(
                                        context,
                                      )?.disableAnimations ==
                                      true
                              ? Duration.zero
                              : chart.animationDuration,
                          builder: (context, progress, _) => CustomPaint(
                            size: constraints.biggest,
                            painter: _CandlestickPainter(
                              data: widget.data,
                              geometry: geometry,
                              theme: theme,
                              chart: chart,
                              risingColor: rising,
                              fallingColor: falling,
                              hoveredIndex: _hoveredIndex,
                              showGrid: widget.showGrid,
                              showXAxis: widget.xAxis.show,
                              showYAxis: widget.yAxis.show,
                              showValues: widget.showValues,
                              valueFormatter: _formatValue,
                              labelFormatter: _formatLabel,
                              progress: progress,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  _CandlestickGeometry _geometry(
    Size size,
    AppChartTheme chart,
    AppThemeData theme,
  ) {
    final low =
        widget.yAxis.min ?? widget.data.map((e) => e.low).reduce(math.min);
    final high =
        widget.yAxis.max ?? widget.data.map((e) => e.high).reduce(math.max);
    final span = math.max(high - low, 1);
    final min = widget.yAxis.min ?? low - span * .06;
    final max = widget.yAxis.max ?? high + span * .06;
    final style = appChartAxisStyle(theme, chart);
    final reserved =
        widget.yAxis.reservedSize ??
        appChartAxisReservedWidth(
          appChartValueAxisLabels(
            min,
            max,
            widget.yAxis.formatter ?? widget.valueFormatter,
          ),
          style,
          chart,
        );
    return _CandlestickGeometry(
      size: size,
      count: widget.data.length,
      min: min,
      max: max == min ? min + 1 : max,
      left: widget.yAxis.show ? reserved : 10,
      bottom: widget.xAxis.show ? 26 : 8,
    );
  }

  String _formatValue(double value) =>
      widget.valueFormatter?.call(value) ??
      widget.yAxis.formatter?.call(value) ??
      appChartNumber(value);

  String _formatLabel(int index, AppCandlestickData data) =>
      widget.labelFormatter?.call(index, data) ?? data.label ?? '${index + 1}';

  void _updatePointer(Offset position, _CandlestickGeometry geometry) {
    final index = geometry.indexAt(position);
    if (index == null) {
      _clear();
      return;
    }
    setState(() {
      _hoveredIndex = index;
      _tooltipPosition = position;
      _tooltipMessage = widget.showTooltip ? _tooltip(index) : null;
    });
  }

  String _tooltip(int index) {
    final data = widget.data[index];
    return widget.tooltipBuilder?.call(index, data) ??
        '${_formatLabel(index, data)}\n开 ${_formatValue(data.open)}  高 ${_formatValue(data.high)}\n低 ${_formatValue(data.low)}  收 ${_formatValue(data.close)}';
  }

  void _move(int delta) {
    if (widget.data.isEmpty) return;
    final current = _hoveredIndex;
    final next = current == null
        ? (delta > 0 ? 0 : widget.data.length - 1)
        : appChartLoopIndex(current, delta, widget.data.length);
    setState(() {
      _hoveredIndex = next;
      _tooltipPosition = null;
      _tooltipMessage = null;
    });
  }

  void _activateCurrent() {
    if (widget.data.isEmpty) return;
    final index = _hoveredIndex ?? 0;
    if (_hoveredIndex == null) setState(() => _hoveredIndex = index);
    _activate(index);
  }

  void _activate(int index) => widget.onCandleTap?.call(
    AppCandlestickChartHit(index: index, data: widget.data[index]),
  );

  void _clear() {
    if (_hoveredIndex == null &&
        _tooltipPosition == null &&
        _tooltipMessage == null) {
      return;
    }
    setState(() {
      _hoveredIndex = null;
      _tooltipPosition = null;
      _tooltipMessage = null;
    });
  }
}

class _CandlestickGeometry {
  const _CandlestickGeometry({
    required this.size,
    required this.count,
    required this.min,
    required this.max,
    required this.left,
    required this.bottom,
  });

  final Size size;
  final int count;
  final double min;
  final double max;
  final double left;
  final double bottom;

  Rect get plot => Rect.fromLTRB(left, 8, size.width - 8, size.height - bottom);
  double get slot => plot.width / count;
  double x(int index) => plot.left + slot * (index + .5);
  double y(double value) =>
      plot.bottom - (value - min) / (max - min) * plot.height;

  int? indexAt(Offset position) {
    if (!plot.inflate(6).contains(position)) return null;
    return ((position.dx - plot.left) / slot).floor().clamp(0, count - 1);
  }
}

class _CandlestickPainter extends CustomPainter {
  const _CandlestickPainter({
    required this.data,
    required this.geometry,
    required this.theme,
    required this.chart,
    required this.risingColor,
    required this.fallingColor,
    required this.hoveredIndex,
    required this.showGrid,
    required this.showXAxis,
    required this.showYAxis,
    required this.showValues,
    required this.valueFormatter,
    required this.labelFormatter,
    required this.progress,
  });

  final List<AppCandlestickData> data;
  final _CandlestickGeometry geometry;
  final AppThemeData theme;
  final AppChartTheme chart;
  final Color risingColor;
  final Color fallingColor;
  final int? hoveredIndex;
  final bool showGrid;
  final bool showXAxis;
  final bool showYAxis;
  final bool showValues;
  final String Function(double) valueFormatter;
  final String Function(int, AppCandlestickData) labelFormatter;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final axisStyle = appChartAxisStyle(theme, chart);
    final gridPaint = Paint()
      ..color = theme.colorScheme.border.withValues(alpha: chart.gridOpacity)
      ..strokeWidth = 1;
    for (var tick = 0; tick <= 4; tick++) {
      final value = geometry.min + (geometry.max - geometry.min) * tick / 4;
      final y = geometry.y(value);
      if (showGrid) {
        canvas.drawLine(
          Offset(geometry.plot.left, y),
          Offset(geometry.plot.right, y),
          gridPaint,
        );
      }
      if (showYAxis && theme.colorScheme.mutedForeground.a > 0) {
        _text(
          canvas,
          valueFormatter(value),
          axisStyle,
          Offset(geometry.plot.left - 6, y),
          right: true,
        );
      }
    }

    final maxLabels = math.max(1, (geometry.plot.width / 56).floor());
    final labelStep = math.max(1, (data.length / maxLabels).ceil());
    final bodyWidth = math
        .min(chart.barWidth, geometry.slot * .62)
        .clamp(2.0, 24.0);
    for (var index = 0; index < data.length; index++) {
      final candle = data[index];
      final x = geometry.x(index);
      final color =
          candle.color ?? (candle.isRising ? risingColor : fallingColor);
      final active = hoveredIndex == index;
      final hasActive = hoveredIndex != null;
      final paint = Paint()
        ..color = color.withValues(
          alpha: hasActive && !active ? chart.inactiveOpacity : 1,
        )
        ..strokeWidth = active ? 2.2 : 1.4;
      final baseY = geometry.y(candle.open);
      double animatedY(double value) =>
          baseY + (geometry.y(value) - baseY) * progress;
      canvas.drawLine(
        Offset(x, animatedY(candle.high)),
        Offset(x, animatedY(candle.low)),
        paint,
      );
      final openY = animatedY(candle.open);
      final closeY = animatedY(candle.close);
      final top = math.min(openY, closeY);
      final height = math.max((openY - closeY).abs(), 1.5);
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x - bodyWidth / 2, top, bodyWidth, height),
        Radius.circular(math.min(chart.radius, bodyWidth / 3)),
      );
      canvas.drawRRect(rect, paint);
      if (active) {
        canvas.drawRRect(
          rect.inflate(3),
          Paint()
            ..color = color.withValues(alpha: .22)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      }
      if (showXAxis && (index % labelStep == 0 || index == data.length - 1)) {
        _text(
          canvas,
          labelFormatter(index, candle),
          axisStyle,
          Offset(x, geometry.plot.bottom + 8),
          center: true,
        );
      }
      if (showValues && geometry.slot >= chart.dataLabelMinSpacing) {
        _text(
          canvas,
          valueFormatter(candle.close),
          axisStyle,
          Offset(x, math.max(0, top - 6)),
          center: true,
          above: true,
        );
      }
    }
  }

  void _text(
    Canvas canvas,
    String value,
    TextStyle style,
    Offset anchor, {
    bool right = false,
    bool center = false,
    bool above = false,
  }) {
    final painter =
        TextPainter(
          text: TextSpan(text: value, style: style),
          maxLines: 1,
          ellipsis: '…',
          textDirection: TextDirection.ltr,
        )..layout(
          maxWidth: center ? math.max(geometry.slot, 20) : geometry.left - 8,
        );
    final dx = right
        ? anchor.dx - painter.width
        : center
        ? anchor.dx - painter.width / 2
        : anchor.dx;
    final dy = above
        ? anchor.dy - painter.height
        : anchor.dy - painter.height / 2;
    painter.paint(canvas, Offset(dx, dy));
  }

  @override
  bool shouldRepaint(covariant _CandlestickPainter oldDelegate) =>
      oldDelegate.data != data ||
      oldDelegate.geometry != geometry ||
      oldDelegate.hoveredIndex != hoveredIndex ||
      oldDelegate.progress != progress ||
      oldDelegate.theme != theme;
}
