import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../../foundation/app_theme_config.dart';
import '../overlay/app_pointer_tooltip.dart';
import 'app_chart_common.dart';

enum _AppLineChartVariant { line, area, step }

typedef AppLineChartTapCallback = void Function(AppLineChartHit hit);
typedef AppLineChartTooltipBuilder =
    Widget Function(BuildContext context, AppLineChartTooltipData data);
typedef AppLineChartDataBuilder = LineChartData Function(LineChartData data);

@immutable
class AppLinePoint {
  const AppLinePoint({required this.x, required this.y, this.label});

  final double x;
  final double? y;
  final String? label;
}

@immutable
class AppLineSeries {
  const AppLineSeries({
    required this.name,
    required this.points,
    this.color,
    this.width,
    this.showPoints = true,
  });

  final String name;
  final List<AppLinePoint> points;
  final Color? color;
  final double? width;
  final bool showPoints;
}

@immutable
class AppLineChartHit {
  const AppLineChartHit({
    required this.selection,
    required this.series,
    required this.point,
  });

  final AppChartSelection selection;
  final AppLineSeries series;
  final AppLinePoint point;
}

@immutable
class AppLineChartTooltipItem {
  const AppLineChartTooltipItem({
    required this.hit,
    required this.color,
    required this.formattedValue,
  });

  final AppLineChartHit hit;
  final Color color;
  final String formattedValue;
}

@immutable
class AppLineChartTooltipData {
  const AppLineChartTooltipData({
    required this.x,
    required this.xLabel,
    required this.items,
  });

  final double x;
  final String xLabel;
  final List<AppLineChartTooltipItem> items;
}

class AppLineChart extends StatefulWidget {
  const AppLineChart({
    super.key,
    required this.series,
    this.xAxis = const AppChartAxis(),
    this.yAxis = const AppChartAxis(),
    this.referenceLines = const <AppChartReferenceLine>[],
    this.nullPolicy = AppChartNullPolicy.gap,
    this.height,
    this.palette,
    this.showGrid = true,
    this.showTooltip = true,
    this.tooltipStyle,
    this.tooltipWidgetBuilder,
    this.showLegend = true,
    this.interactive = true,
    this.selectionEnabled = false,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.maxRenderedPoints = 1000,
    this.samplingStrategy =
        AppChartSamplingStrategy.largestTriangleThreeBuckets,
    this.semanticLabel = '折线图，使用方向键浏览数据',
    this.selected = const <AppChartSelection>{},
    this.onSelectionChanged,
    this.onPointTap,
    this.dataBuilder,
  }) : _variant = _AppLineChartVariant.line;

  const AppLineChart.area({
    super.key,
    required this.series,
    this.xAxis = const AppChartAxis(),
    this.yAxis = const AppChartAxis(),
    this.referenceLines = const <AppChartReferenceLine>[],
    this.nullPolicy = AppChartNullPolicy.gap,
    this.height,
    this.palette,
    this.showGrid = true,
    this.showTooltip = true,
    this.tooltipStyle,
    this.tooltipWidgetBuilder,
    this.showLegend = true,
    this.interactive = true,
    this.selectionEnabled = false,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.maxRenderedPoints = 1000,
    this.samplingStrategy =
        AppChartSamplingStrategy.largestTriangleThreeBuckets,
    this.semanticLabel = '面积图，使用方向键浏览数据',
    this.selected = const <AppChartSelection>{},
    this.onSelectionChanged,
    this.onPointTap,
    this.dataBuilder,
  }) : _variant = _AppLineChartVariant.area;

  const AppLineChart.step({
    super.key,
    required this.series,
    this.xAxis = const AppChartAxis(),
    this.yAxis = const AppChartAxis(),
    this.referenceLines = const <AppChartReferenceLine>[],
    this.nullPolicy = AppChartNullPolicy.gap,
    this.height,
    this.palette,
    this.showGrid = true,
    this.showTooltip = true,
    this.tooltipStyle,
    this.tooltipWidgetBuilder,
    this.showLegend = true,
    this.interactive = true,
    this.selectionEnabled = false,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.maxRenderedPoints = 1000,
    this.samplingStrategy =
        AppChartSamplingStrategy.largestTriangleThreeBuckets,
    this.semanticLabel = '阶梯图，使用方向键浏览数据',
    this.selected = const <AppChartSelection>{},
    this.onSelectionChanged,
    this.onPointTap,
    this.dataBuilder,
  }) : _variant = _AppLineChartVariant.step;

  final List<AppLineSeries> series;
  final AppChartAxis xAxis;
  final AppChartAxis yAxis;
  final List<AppChartReferenceLine> referenceLines;
  final AppChartNullPolicy nullPolicy;
  final double? height;
  final List<Color>? palette;
  final bool showGrid;
  final bool showTooltip;
  final AppPointerTooltipStyle? tooltipStyle;
  final AppLineChartTooltipBuilder? tooltipWidgetBuilder;
  final bool showLegend;
  final bool interactive;
  final bool selectionEnabled;
  final bool keyboardNavigation;
  final bool autofocus;
  final int? maxRenderedPoints;
  final AppChartSamplingStrategy samplingStrategy;
  final String semanticLabel;
  final Set<AppChartSelection> selected;
  final ValueChanged<Set<AppChartSelection>>? onSelectionChanged;
  final AppLineChartTapCallback? onPointTap;
  final AppLineChartDataBuilder? dataBuilder;
  final _AppLineChartVariant _variant;

  @override
  State<AppLineChart> createState() => _AppLineChartState();
}

class _AppLineChartState extends State<AppLineChart> {
  final Set<int> _hiddenSeries = <int>{};
  Set<AppChartSelection> _internalSelected = <AppChartSelection>{};
  AppChartSelection? _hovered;
  Offset? _tooltipPosition;
  String? _tooltipMessage;
  AppLineChartTooltipData? _tooltipData;

  bool get _controlled => widget.onSelectionChanged != null;
  Set<AppChartSelection> get _selected => widget.selectionEnabled
      ? (_controlled ? widget.selected : _internalSelected)
      : const <AppChartSelection>{};

  @override
  void initState() {
    super.initState();
    _internalSelected = Set<AppChartSelection>.of(widget.selected);
  }

  @override
  void didUpdateWidget(covariant AppLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controlled && oldWidget.selected != widget.selected) {
      _internalSelected = Set<AppChartSelection>.of(widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppTheme.maybeOf(context);
    final chart = config?.chart ?? const AppChartTheme();
    final theme = ShadcnTheme.of(context);
    final palette = appChartPalette(chart, theme.colorScheme, widget.palette);
    final empty = widget.series.every(
      (series) => series.points.every((point) => point.y == null),
    );
    return AppChartKeyboardRegion(
      enabled: widget.keyboardNavigation && !empty,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      onPrevious: () => _moveKeyboard(-1),
      onNext: () => _moveKeyboard(1),
      onActivate: _activateCurrent,
      onClear: _clearKeyboard,
      child: SizedBox(
        height: widget.height ?? chart.height,
        child: empty
            ? Center(
                child: Text(
                  '暂无数据',
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.mutedForeground,
                  ),
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  if (widget.showLegend &&
                      widget.series.isNotEmpty) ...<Widget>[
                    AppChartLegend(
                      items: <AppChartLegendData>[
                        for (var i = 0; i < widget.series.length; i++)
                          AppChartLegendData(
                            label: widget.series[i].name,
                            color:
                                widget.series[i].color ??
                                palette[i % palette.length],
                          ),
                      ],
                      hidden: _hiddenSeries,
                      onToggle: (index) => setState(() {
                        _hiddenSeries.contains(index)
                            ? _hiddenSeries.remove(index)
                            : _hiddenSeries.add(index);
                      }),
                    ),
                    SizedBox(height: chart.legendSpacing),
                  ],
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final data = _data(
                          theme,
                          chart,
                          palette,
                          constraints.maxWidth,
                        );
                        return AppPointerTooltipArea(
                          position: _tooltipPosition,
                          message: _tooltipMessage,
                          style: widget.tooltipStyle,
                          builder:
                              widget.tooltipWidgetBuilder == null ||
                                  _tooltipData == null
                              ? null
                              : (context, _) => widget.tooltipWidgetBuilder!(
                                  context,
                                  _tooltipData!,
                                ),
                          onExit: _clearPointerHover,
                          child: LineChart(
                            widget.dataBuilder?.call(data) ?? data,
                            duration:
                                config?.motion.enabled == false ||
                                    MediaQuery.maybeOf(
                                          context,
                                        )?.disableAnimations ==
                                        true
                                ? Duration.zero
                                : chart.animationDuration,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  LineChartData _data(
    AppThemeData theme,
    AppChartTheme chart,
    List<Color> palette,
    double availableWidth,
  ) {
    final points = widget.series.expand((series) => series.points);
    final valid = points.where((point) => point.y != null).toList();
    final minX = widget.xAxis.min ?? valid.map((e) => e.x).reduce(math.min);
    final maxX = widget.xAxis.max ?? valid.map((e) => e.x).reduce(math.max);
    final rawMinY = valid.map((e) => e.y!).reduce(math.min);
    final rawMaxY = valid.map((e) => e.y!).reduce(math.max);
    final minY = widget.yAxis.min ?? math.min(0, rawMinY * 1.08);
    final automaticMinY = math.min(0.0, rawMinY);
    final maxY =
        widget.yAxis.max ??
        appChartNiceMaximum(
          widget.yAxis.min ?? automaticMinY,
          math.max(0.0, rawMaxY),
          interval: widget.yAxis.interval,
        );
    final axisStyle = appChartAxisStyle(theme, chart);
    final xLabelExtent = math.max(
      0.0,
      availableWidth -
          (widget.yAxis.show
              ? widget.yAxis.reservedSize ??
                    appChartAxisReservedWidth(
                      appChartValueAxisLabels(
                        minY,
                        maxY,
                        widget.yAxis.formatter,
                      ),
                      axisStyle,
                      chart,
                    )
              : 0) -
          16,
    );

    return LineChartData(
      minX: minX,
      maxX: maxX == minX ? minX + 1 : maxX,
      minY: minY,
      maxY: maxY == minY ? minY + 1 : maxY,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: widget.showGrid,
        drawVerticalLine: false,
        horizontalInterval: widget.yAxis.interval,
        getDrawingHorizontalLine: (_) => FlLine(
          color: theme.colorScheme.border.withValues(alpha: chart.gridOpacity),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: _axisTitles(
          widget.xAxis,
          axisStyle,
          false,
          chart,
          minX,
          maxX,
          availableExtent: xLabelExtent,
        ),
        leftTitles: _axisTitles(
          widget.yAxis,
          axisStyle,
          true,
          chart,
          minY,
          maxY,
        ),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: <HorizontalLine>[
          for (final line in widget.referenceLines)
            HorizontalLine(
              y: line.value,
              color: line.color ?? theme.colorScheme.primary,
              strokeWidth: line.width,
              dashArray: line.dash,
              label: HorizontalLineLabel(
                show: line.label != null,
                labelResolver: (_) => line.label ?? '',
                style: axisStyle.copyWith(
                  color: line.color ?? theme.colorScheme.primary,
                ),
              ),
            ),
        ],
      ),
      lineBarsData: <LineChartBarData>[
        for (
          var seriesIndex = 0;
          seriesIndex < widget.series.length;
          seriesIndex++
        )
          _seriesData(seriesIndex, theme, chart, palette),
      ],
      lineTouchData: LineTouchData(
        enabled: widget.interactive,
        handleBuiltInTouches: false,
        touchCallback: _handleTouch,
        mouseCursorResolver: (_, response) =>
            response?.lineBarSpots?.isNotEmpty == true
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
      ),
    );
  }

  LineChartBarData _seriesData(
    int seriesIndex,
    AppThemeData theme,
    AppChartTheme chart,
    List<Color> palette,
  ) {
    final series = widget.series[seriesIndex];
    final base = series.color ?? palette[seriesIndex % palette.length];
    final hidden = _hiddenSeries.contains(seriesIndex);
    final activeSeries =
        _hovered?.seriesIndex == seriesIndex ||
        _selected.any((selection) => selection.seriesIndex == seriesIndex);
    final hasActive = _hovered != null || _selected.isNotEmpty;
    final color = base.withValues(
      alpha: hidden
          ? 0
          : (hasActive && !activeSeries ? chart.inactiveOpacity : 1),
    );
    return LineChartBarData(
      show: !hidden,
      spots: <FlSpot>[
        for (final point in _renderPoints(series))
          if (point.y == null && widget.nullPolicy == AppChartNullPolicy.gap)
            FlSpot.nullSpot
          else if (point.y != null ||
              widget.nullPolicy == AppChartNullPolicy.zero)
            FlSpot(point.x, point.y ?? 0),
      ],
      color: color,
      barWidth: series.width ?? chart.lineWidth,
      isCurved: widget._variant != _AppLineChartVariant.step,
      preventCurveOverShooting: true,
      isStrokeCapRound: true,
      isStrokeJoinRound: true,
      isStepLineChart: widget._variant == _AppLineChartVariant.step,
      belowBarData: BarAreaData(
        show: widget._variant == _AppLineChartVariant.area,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[
            color.withValues(alpha: 0.24),
            color.withValues(alpha: 0.02),
          ],
        ),
      ),
      dotData: FlDotData(
        show: series.showPoints,
        getDotPainter: (spot, _, _, _) {
          final selection = AppChartSelection(
            _pointIndexForX(seriesIndex, spot.x),
            seriesIndex,
          );
          final active = _hovered == selection || _selected.contains(selection);
          return FlDotCirclePainter(
            radius: active
                ? chart.pointRadius * chart.hoverScale
                : chart.pointRadius,
            color: color,
            strokeWidth: active ? 2 : 1.5,
            strokeColor: theme.colorScheme.background,
          );
        },
      ),
    );
  }

  AxisTitles _axisTitles(
    AppChartAxis axis,
    TextStyle style,
    bool vertical,
    AppChartTheme chart,
    double min,
    double max, {
    double? availableExtent,
  }) => AxisTitles(
    axisNameWidget: !axis.show || axis.title == null
        ? null
        : Text(
            axis.title!,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
    axisNameSize: !axis.show || axis.title == null ? 0 : 20,
    sideTitles: SideTitles(
      showTitles: axis.show,
      minIncluded: vertical ? axis.min != null : true,
      maxIncluded: true,
      reservedSize:
          axis.reservedSize ??
          (vertical
              ? appChartAxisReservedWidth(
                  appChartValueAxisLabels(min, max, axis.formatter),
                  style,
                  chart,
                )
              : 26),
      interval: axis.interval ?? (vertical ? null : _xPointInterval()),
      getTitlesWidget: (value, meta) {
        final pointLabel = vertical ? null : _pointLabel(value);
        if (!vertical &&
            axis.formatter == null &&
            _hasPointLabels &&
            pointLabel == null) {
          return const SizedBox.shrink();
        }
        if (!vertical &&
            axis.interval == null &&
            axis.autoLabelInterval &&
            pointLabel != null &&
            !_showAutomaticXLabel(
              value,
              availableExtent ?? double.infinity,
              style,
              axis,
            )) {
          return const SizedBox.shrink();
        }
        return SideTitleWidget(
          meta: meta,
          space: 6,
          child: Text(
            axis.formatter?.call(value) ?? pointLabel ?? appChartNumber(value),
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    ),
  );

  bool get _hasPointLabels => widget.series.any(
    (series) => series.points.any((point) => point.label != null),
  );

  bool _showAutomaticXLabel(
    double value,
    double availableWidth,
    TextStyle style,
    AppChartAxis axis,
  ) {
    final values = _xLabelValues();
    final index = values.indexWhere((entry) => entry.$1 == value);
    if (index < 0) return false;
    final stride = appChartLabelStride(
      values.map((entry) => entry.$2),
      availableWidth,
      style,
      minSpacing: axis.minLabelSpacing,
    );
    return appChartShowSampledLabel(index, values.length, stride);
  }

  List<(double, String)> _xLabelValues() {
    final labels = <double, String>{};
    for (final series in widget.series) {
      for (final point in series.points) {
        if (point.label != null) {
          labels.putIfAbsent(point.x, () => point.label!);
        }
      }
    }
    return labels.entries.map((entry) => (entry.key, entry.value)).toList()
      ..sort((left, right) => left.$1.compareTo(right.$1));
  }

  double? _xPointInterval() {
    final values =
        widget.series
            .expand((series) => series.points)
            .map((point) => point.x)
            .toSet()
            .toList()
          ..sort();
    if (values.length < 2) return null;
    var interval = double.infinity;
    for (var index = 1; index < values.length; index++) {
      final distance = values[index] - values[index - 1];
      if (distance > 0) interval = math.min(interval, distance);
    }
    return interval.isFinite ? interval : null;
  }

  String? _pointLabel(double x) {
    for (final series in widget.series) {
      for (final point in series.points) {
        if (point.x == x && point.label != null) return point.label;
      }
    }
    return null;
  }

  void _handleTouch(FlTouchEvent event, LineTouchResponse? response) {
    final spots = response?.lineBarSpots;
    final spot = spots?.firstOrNull;
    final next = spot == null
        ? null
        : AppChartSelection(
            _pointIndexForX(spot.barIndex, spot.x),
            spot.barIndex,
          );
    final tooltipMessage = spot == null || !widget.showTooltip || spots == null
        ? null
        : _tooltipFor(spots);
    final tooltipData = tooltipMessage == null || spots == null
        ? null
        : _tooltipDataFor(spots);
    final tooltipPosition = tooltipMessage == null
        ? null
        : response?.touchLocation;
    if (_hovered != next ||
        _tooltipPosition != tooltipPosition ||
        _tooltipMessage != tooltipMessage) {
      setState(() {
        _hovered = next;
        _tooltipPosition = tooltipPosition;
        _tooltipMessage = tooltipMessage;
        _tooltipData = tooltipData;
      });
    }
    if (event is! FlTapUpEvent || next == null) return;
    _activate(next);
  }

  void _clearPointerHover() {
    if (_hovered == null &&
        _tooltipPosition == null &&
        _tooltipMessage == null) {
      return;
    }
    setState(() {
      _hovered = null;
      _tooltipPosition = null;
      _tooltipMessage = null;
      _tooltipData = null;
    });
  }

  void _activate(AppChartSelection next) {
    if (widget.selectionEnabled) {
      final changed = Set<AppChartSelection>.of(_selected);
      changed.contains(next) ? changed.remove(next) : changed.add(next);
      if (!_controlled) setState(() => _internalSelected = changed);
      widget.onSelectionChanged?.call(
        Set<AppChartSelection>.unmodifiable(changed),
      );
    }
    widget.onPointTap?.call(_hit(next));
  }

  List<AppChartSelection> get _keyboardItems => <AppChartSelection>[
    for (var seriesIndex = 0; seriesIndex < widget.series.length; seriesIndex++)
      if (!_hiddenSeries.contains(seriesIndex))
        for (final point in _renderPoints(widget.series[seriesIndex]))
          if (point.y != null || widget.nullPolicy == AppChartNullPolicy.zero)
            AppChartSelection(
              _pointIndexForX(seriesIndex, point.x),
              seriesIndex,
            ),
  ];

  void _moveKeyboard(int delta) {
    final items = _keyboardItems;
    if (items.isEmpty) return;
    final current = _hovered == null ? -1 : items.indexOf(_hovered!);
    final next = current < 0
        ? (delta > 0 ? 0 : items.length - 1)
        : appChartLoopIndex(current, delta, items.length);
    setState(() {
      _hovered = items[next];
      _tooltipPosition = null;
      _tooltipMessage = null;
      _tooltipData = null;
    });
  }

  void _activateCurrent() {
    final items = _keyboardItems;
    if (items.isEmpty) return;
    final current = _hovered ?? items.first;
    if (_hovered == null) setState(() => _hovered = current);
    _activate(current);
  }

  void _clearKeyboard() {
    if (!widget.selectionEnabled) {
      setState(() {
        _hovered = null;
        _tooltipPosition = null;
        _tooltipMessage = null;
        _tooltipData = null;
      });
      return;
    }
    if (!_controlled) {
      setState(() {
        _hovered = null;
        _tooltipPosition = null;
        _tooltipMessage = null;
        _tooltipData = null;
        _internalSelected = <AppChartSelection>{};
      });
    } else {
      setState(() {
        _hovered = null;
        _tooltipPosition = null;
        _tooltipMessage = null;
        _tooltipData = null;
      });
    }
    widget.onSelectionChanged?.call(const <AppChartSelection>{});
  }

  AppLineChartHit _hit(AppChartSelection selection) => AppLineChartHit(
    selection: selection,
    series: widget.series[selection.seriesIndex],
    point: widget.series[selection.seriesIndex].points[selection.groupIndex],
  );

  String _tooltipFor(List<TouchLineBarSpot> spots) {
    final first = spots.first;
    final xLabel =
        _pointLabel(first.x) ??
        widget.xAxis.formatter?.call(first.x) ??
        appChartNumber(first.x);
    final lines = <String>[xLabel];
    for (final spot in spots) {
      lines.add(
        '${widget.series[spot.barIndex].name} ${widget.yAxis.formatter?.call(spot.y) ?? appChartNumber(spot.y)}',
      );
    }
    return lines.join('\n');
  }

  AppLineChartTooltipData _tooltipDataFor(List<TouchLineBarSpot> spots) {
    final first = spots.first;
    final config = AppTheme.maybeOf(context);
    final chart = config?.chart ?? const AppChartTheme();
    final theme = ShadcnTheme.of(context);
    final palette = appChartPalette(chart, theme.colorScheme, widget.palette);
    final xLabel =
        _pointLabel(first.x) ??
        widget.xAxis.formatter?.call(first.x) ??
        appChartNumber(first.x);
    return AppLineChartTooltipData(
      x: first.x,
      xLabel: xLabel,
      items: <AppLineChartTooltipItem>[
        for (final spot in spots)
          AppLineChartTooltipItem(
            hit: _hit(
              AppChartSelection(
                _pointIndexForX(spot.barIndex, spot.x),
                spot.barIndex,
              ),
            ),
            color:
                widget.series[spot.barIndex].color ??
                palette[spot.barIndex % palette.length],
            formattedValue:
                widget.yAxis.formatter?.call(spot.y) ?? appChartNumber(spot.y),
          ),
      ],
    );
  }

  int _pointIndexForX(int seriesIndex, double x) =>
      widget.series[seriesIndex].points.indexWhere((point) => point.x == x);

  List<AppLinePoint> _renderPoints(AppLineSeries series) {
    final limit = widget.maxRenderedPoints;
    if (limit == null ||
        limit < 3 ||
        series.points.length <= limit ||
        widget.samplingStrategy == AppChartSamplingStrategy.none) {
      return series.points;
    }
    final valid = <AppLinePoint>[
      for (final point in series.points)
        if (point.y != null || widget.nullPolicy == AppChartNullPolicy.zero)
          point,
    ];
    if (valid.length <= limit) return series.points;
    final sampled = appChartSampleIndices<AppLinePoint>(
      valid,
      maxPoints: limit,
      x: (point) => point.x,
      y: (point) => point.y ?? 0,
      strategy: widget.samplingStrategy,
    );
    final retained = <AppLinePoint>{for (final index in sampled) valid[index]};
    if (widget.nullPolicy != AppChartNullPolicy.gap) {
      return <AppLinePoint>[
        for (final point in series.points)
          if (retained.contains(point)) point,
      ];
    }
    return <AppLinePoint>[
      for (var index = 0; index < series.points.length; index++)
        if (retained.contains(series.points[index]) ||
            (series.points[index].y == null &&
                (index == 0 || series.points[index - 1].y != null)))
          series.points[index],
    ];
  }
}
