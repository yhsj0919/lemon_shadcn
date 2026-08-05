import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../../foundation/app_theme_config.dart';
import '../overlay/app_pointer_tooltip.dart';
import 'app_chart_common.dart';

typedef AppBarChartTapCallback = void Function(AppBarChartHit hit);
typedef AppBarChartColorResolver = Color Function(AppBarChartStyleContext data);
typedef AppBarChartDataBuilder = BarChartData Function(BarChartData data);

enum _AppBarChartVariant { grouped, stacked, horizontal }

@immutable
class AppBarValue {
  const AppBarValue({required this.value, this.color, this.gradient})
    : assert(color == null || gradient == null);

  final double? value;
  final Color? color;
  final Gradient? gradient;
}

@immutable
class AppBarGroup {
  const AppBarGroup({required this.label, required this.values});

  final String label;
  final List<AppBarValue> values;
}

@immutable
class AppBarSeries {
  const AppBarSeries({required this.name, this.color});

  final String name;
  final Color? color;
}

@immutable
class AppBarChartHit {
  const AppBarChartHit({
    required this.selection,
    required this.group,
    required this.value,
    this.series,
  });

  final AppChartSelection selection;
  final AppBarGroup group;
  final AppBarSeries? series;
  final AppBarValue value;
}

@immutable
class AppBarChartStyleContext {
  const AppBarChartStyleContext({
    required this.hit,
    required this.baseColor,
    required this.isHovered,
    required this.isSelected,
  });

  final AppBarChartHit hit;
  final Color baseColor;
  final bool isHovered;
  final bool isSelected;
}

/// A business-first bar chart whose defaults are derived from Lemon's shadcn
/// theme. fl_chart remains the renderer, never the source of visual defaults.
class AppBarChart extends StatefulWidget {
  const AppBarChart({
    super.key,
    required this.groups,
    this.series = const <AppBarSeries>[],
    this.xAxis = const AppChartAxis(),
    this.yAxis = const AppChartAxis(),
    this.referenceLines = const <AppChartReferenceLine>[],
    this.nullPolicy = AppChartNullPolicy.gap,
    this.height,
    this.palette,
    this.showGrid = true,
    this.showTooltip = true,
    this.showLegend = true,
    this.showValues = false,
    this.interactive = true,
    this.selectionEnabled = false,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.semanticLabel = '柱状图，使用方向键浏览数据',
    this.selected = const <AppChartSelection>{},
    this.onSelectionChanged,
    this.onBarTap,
    this.colorResolver,
    this.dataBuilder,
  }) : _variant = _AppBarChartVariant.grouped;

  const AppBarChart.stacked({
    super.key,
    required this.groups,
    this.series = const <AppBarSeries>[],
    this.xAxis = const AppChartAxis(),
    this.yAxis = const AppChartAxis(),
    this.referenceLines = const <AppChartReferenceLine>[],
    this.nullPolicy = AppChartNullPolicy.gap,
    this.height,
    this.palette,
    this.showGrid = true,
    this.showTooltip = true,
    this.showLegend = true,
    this.showValues = false,
    this.interactive = true,
    this.selectionEnabled = false,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.semanticLabel = '堆叠柱状图，使用方向键浏览数据',
    this.selected = const <AppChartSelection>{},
    this.onSelectionChanged,
    this.onBarTap,
    this.colorResolver,
    this.dataBuilder,
  }) : _variant = _AppBarChartVariant.stacked;

  /// Horizontal business chart. [xAxis] configures numeric values while
  /// [yAxis] configures category labels and the category axis title.
  const AppBarChart.horizontal({
    super.key,
    required this.groups,
    this.series = const <AppBarSeries>[],
    this.xAxis = const AppChartAxis(),
    this.yAxis = const AppChartAxis(),
    this.referenceLines = const <AppChartReferenceLine>[],
    this.nullPolicy = AppChartNullPolicy.gap,
    this.height,
    this.palette,
    this.showGrid = true,
    this.showTooltip = true,
    this.showLegend = true,
    this.showValues = false,
    this.interactive = true,
    this.selectionEnabled = false,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.semanticLabel = '横向柱状图，使用方向键浏览数据',
    this.selected = const <AppChartSelection>{},
    this.onSelectionChanged,
    this.onBarTap,
    this.colorResolver,
    this.dataBuilder,
  }) : _variant = _AppBarChartVariant.horizontal;

  factory AppBarChart.simple({
    Key? key,
    required List<AppBarValue> values,
    required List<String> labels,
    AppChartAxis yAxis = const AppChartAxis(),
    AppBarChartTapCallback? onBarTap,
    double? height,
  }) {
    assert(values.length == labels.length);
    return AppBarChart(
      key: key,
      groups: <AppBarGroup>[
        for (var i = 0; i < values.length; i++)
          AppBarGroup(label: labels[i], values: <AppBarValue>[values[i]]),
      ],
      yAxis: yAxis,
      onBarTap: onBarTap,
      height: height,
    );
  }

  final List<AppBarGroup> groups;
  final List<AppBarSeries> series;
  final AppChartAxis xAxis;
  final AppChartAxis yAxis;
  final List<AppChartReferenceLine> referenceLines;
  final AppChartNullPolicy nullPolicy;
  final double? height;
  final List<Color>? palette;
  final bool showGrid;
  final bool showTooltip;
  final bool showLegend;
  final bool showValues;
  final bool interactive;
  final bool selectionEnabled;
  final bool keyboardNavigation;
  final bool autofocus;
  final String semanticLabel;
  final Set<AppChartSelection> selected;
  final ValueChanged<Set<AppChartSelection>>? onSelectionChanged;
  final AppBarChartTapCallback? onBarTap;
  final AppBarChartColorResolver? colorResolver;
  final AppBarChartDataBuilder? dataBuilder;
  final _AppBarChartVariant _variant;

  @override
  State<AppBarChart> createState() => _AppBarChartState();
}

class _AppBarChartState extends State<AppBarChart> {
  final GlobalKey _chartAreaKey = GlobalKey();
  AppChartSelection? _hovered;
  Offset? _tooltipPosition;
  String? _tooltipMessage;
  Set<AppChartSelection> _internalSelected = <AppChartSelection>{};
  final Set<int> _hiddenSeries = <int>{};

  bool get _selectionIsControlled => widget.onSelectionChanged != null;
  Set<AppChartSelection> get _selected => widget.selectionEnabled
      ? (_selectionIsControlled ? widget.selected : _internalSelected)
      : const <AppChartSelection>{};
  bool get _horizontal => widget._variant == _AppBarChartVariant.horizontal;
  AppChartAxis get _categoryAxis => _horizontal ? widget.yAxis : widget.xAxis;
  AppChartAxis get _valueAxis => _horizontal ? widget.xAxis : widget.yAxis;

  @override
  void initState() {
    super.initState();
    _internalSelected = Set<AppChartSelection>.of(widget.selected);
  }

  @override
  void didUpdateWidget(covariant AppBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_selectionIsControlled && oldWidget.selected != widget.selected) {
      _internalSelected = Set<AppChartSelection>.of(widget.selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appConfig = AppTheme.maybeOf(context);
    final chartTheme = appConfig?.chart ?? const AppChartTheme();
    final theme = ShadcnTheme.of(context);
    final colors = theme.colorScheme;
    final palette = appChartPalette(chartTheme, colors, widget.palette);
    return AppChartKeyboardRegion(
      enabled: widget.keyboardNavigation && widget.groups.isNotEmpty,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      onPrevious: () => _moveKeyboard(-1),
      onNext: () => _moveKeyboard(1),
      onUp: widget._variant == _AppBarChartVariant.stacked
          ? () => _moveKeyboard(1)
          : null,
      onDown: widget._variant == _AppBarChartVariant.stacked
          ? () => _moveKeyboard(-1)
          : null,
      onActivate: _activateCurrent,
      onClear: _clearKeyboard,
      child: SizedBox(
        height: widget.height ?? chartTheme.height,
        child: widget.groups.isEmpty
            ? Center(
                child: Text(
                  '暂无数据',
                  style: theme.typography.small.copyWith(
                    color: colors.mutedForeground,
                  ),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  final labelLayout = _labelLayout(constraints, chartTheme);
                  final data = _buildData(
                    theme,
                    chartTheme,
                    palette,
                    labelLayout,
                  );
                  final chart = BarChart(
                    widget.dataBuilder?.call(data) ?? data,
                    duration:
                        appConfig?.motion.enabled == false ||
                            MediaQuery.maybeOf(context)?.disableAnimations ==
                                true
                        ? Duration.zero
                        : chartTheme.animationDuration,
                  );
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      if (widget.showLegend &&
                          widget.series.isNotEmpty) ...<Widget>[
                        _legend(palette),
                        SizedBox(height: chartTheme.legendSpacing),
                      ],
                      Expanded(
                        child: AppPointerTooltipArea(
                          key: _chartAreaKey,
                          position: _tooltipPosition,
                          message: _tooltipMessage,
                          onExit: _clearPointerHover,
                          child: chart,
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }

  Widget _legend(List<Color> palette) => AppChartLegend(
    items: <AppChartLegendData>[
      for (var index = 0; index < widget.series.length; index++)
        AppChartLegendData(
          label: widget.series[index].name,
          color: widget.series[index].color ?? palette[index % palette.length],
        ),
    ],
    hidden: _hiddenSeries,
    onToggle: (index) => setState(() {
      _hiddenSeries.contains(index)
          ? _hiddenSeries.remove(index)
          : _hiddenSeries.add(index);
    }),
  );

  _AppBarLabelLayout _labelLayout(
    BoxConstraints constraints,
    AppChartTheme chart,
  ) {
    if (!widget.showValues || widget.groups.isEmpty) {
      return const _AppBarLabelLayout.hidden();
    }
    var extent = _horizontal ? constraints.maxHeight : constraints.maxWidth;
    if (!extent.isFinite) {
      return const _AppBarLabelLayout(stride: 1, singlePerGroup: false);
    }
    if (widget.showLegend && widget.series.isNotEmpty) {
      extent = math.max(0, extent - chart.legendSpacing - 28);
    }
    final groupSlot = extent / widget.groups.length;
    if (groupSlot <= 0) return const _AppBarLabelLayout.hidden();
    final stride = math.max(1, (chart.dataLabelMinSpacing / groupSlot).ceil());
    final maxSeries = widget._variant == _AppBarChartVariant.stacked
        ? 1
        : widget.groups.fold<int>(
            1,
            (count, group) => math.max(count, group.values.length),
          );
    return _AppBarLabelLayout(
      stride: stride,
      singlePerGroup:
          widget._variant != _AppBarChartVariant.stacked &&
          groupSlot / maxSeries < chart.dataLabelMinSpacing,
    );
  }

  bool _showLabel(_AppBarLabelLayout layout, int groupIndex, int seriesIndex) {
    if (!layout.visible || groupIndex % layout.stride != 0) return false;
    if (!layout.singlePerGroup) return true;
    final values = widget.groups[groupIndex].values;
    var largestIndex = 0;
    var largest = -1.0;
    for (var index = 0; index < values.length; index++) {
      final magnitude = (values[index].value ?? 0).abs();
      if (magnitude > largest) {
        largest = magnitude;
        largestIndex = index;
      }
    }
    return seriesIndex == largestIndex;
  }

  BarChartData _buildData(
    AppThemeData theme,
    AppChartTheme chart,
    List<Color> palette,
    _AppBarLabelLayout labelLayout,
  ) {
    final values = widget._variant == _AppBarChartVariant.stacked
        ? <double>[
            for (final group in widget.groups) ...<double>[
              group.values
                  .map((bar) => bar.value ?? 0)
                  .where((value) => value < 0)
                  .fold<double>(0, (sum, value) => sum + value),
              group.values
                  .map((bar) => bar.value ?? 0)
                  .where((value) => value > 0)
                  .fold<double>(0, (sum, value) => sum + value),
            ],
          ]
        : widget.groups
              .expand((group) => group.values)
              .map((bar) => bar.value)
              .whereType<double>()
              .toList();
    final minValue = values.isEmpty ? 0.0 : values.reduce(math.min);
    final maxValue = values.isEmpty ? 1.0 : values.reduce(math.max);
    final minY = _valueAxis.min ?? math.min(0, minValue * 1.12);
    final maxY =
        _valueAxis.max ??
        (maxValue == minY ? minY + 1 : math.max(0, maxValue * 1.12));
    final axisStyle = theme.typography.xSmall.copyWith(
      fontSize: chart.labelFontSize,
      color: theme.colorScheme.mutedForeground,
    );

    final groups = <BarChartGroupData>[];
    for (var groupIndex = 0; groupIndex < widget.groups.length; groupIndex++) {
      final group = widget.groups[groupIndex];
      final rods = <BarChartRodData>[];
      if (widget._variant == _AppBarChartVariant.stacked) {
        rods.add(
          _stackedRod(
            groupIndex,
            theme,
            chart,
            palette,
            axisStyle,
            labelLayout,
          ),
        );
      } else {
        for (
          var seriesIndex = 0;
          seriesIndex < group.values.length;
          seriesIndex++
        ) {
          final value = group.values[seriesIndex];
          final hidden = _hiddenSeries.contains(seriesIndex);
          final suppressNull =
              value.value == null &&
              widget.nullPolicy != AppChartNullPolicy.zero;
          final numeric = hidden ? 0.0 : (value.value ?? 0);
          final selection = AppChartSelection(groupIndex, seriesIndex);
          final hit = _hit(selection);
          final baseColor =
              value.color ??
              (seriesIndex < widget.series.length
                  ? widget.series[seriesIndex].color
                  : null) ??
              palette[seriesIndex % palette.length];
          final isHovered = selection == _hovered;
          final isSelected = _selected.contains(selection);
          final resolved =
              widget.colorResolver?.call(
                AppBarChartStyleContext(
                  hit: hit,
                  baseColor: baseColor,
                  isHovered: isHovered,
                  isSelected: isSelected,
                ),
              ) ??
              baseColor;
          final hasActive = _hovered != null || _selected.isNotEmpty;
          final active = isHovered || isSelected;
          rods.add(
            BarChartRodData(
              toY: numeric,
              color: value.gradient == null
                  ? resolved.withValues(
                      alpha: hidden || suppressNull
                          ? 0
                          : (hasActive && !active ? chart.inactiveOpacity : 1),
                    )
                  : null,
              gradient: hidden || suppressNull ? null : value.gradient,
              width: chart.barWidth * (isHovered ? chart.hoverScale : 1),
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(numeric >= 0 ? chart.radius : 0),
                bottom: Radius.circular(numeric < 0 ? chart.radius : 0),
              ),
              label: BarChartRodLabel(
                show:
                    _showLabel(labelLayout, groupIndex, seriesIndex) &&
                    !hidden &&
                    value.value != null,
                text:
                    _valueAxis.formatter?.call(numeric) ??
                    appChartNumber(numeric),
                style: axisStyle.copyWith(color: theme.colorScheme.foreground),
              ),
            ),
          );
        }
      }
      groups.add(
        BarChartGroupData(
          x: groupIndex,
          barRods: rods,
          barsSpace: math.max(2, chart.groupSpacing / 4),
        ),
      );
    }

    return BarChartData(
      barGroups: groups,
      groupsSpace: chart.groupSpacing,
      minY: minY,
      maxY: maxY,
      alignment: BarChartAlignment.spaceAround,
      borderData: FlBorderData(show: false),
      gridData: FlGridData(
        show: widget.showGrid,
        drawVerticalLine: false,
        horizontalInterval: _valueAxis.interval,
        getDrawingHorizontalLine: (_) => FlLine(
          color: theme.colorScheme.border.withValues(alpha: chart.gridOpacity),
          strokeWidth: 1,
        ),
      ),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: _horizontal
            ? _leftTitles(axisStyle, chart, minY, maxY)
            : const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: _bottomTitles(axisStyle, chart),
        leftTitles: _horizontal
            ? const AxisTitles(sideTitles: SideTitles(showTitles: false))
            : _leftTitles(axisStyle, chart, minY, maxY),
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
                direction: _horizontal
                    ? LabelDirection.verticalMirrored
                    : LabelDirection.horizontal,
              ),
            ),
        ],
      ),
      rotationQuarterTurns: _horizontal ? 1 : 0,
      barTouchData: BarTouchData(
        enabled: widget.interactive,
        handleBuiltInTouches: false,
        mouseCursorResolver: (_, response) => response?.spot == null
            ? SystemMouseCursors.basic
            : SystemMouseCursors.click,
        touchCallback: _handleTouch,
      ),
    );
  }

  BarChartRodData _stackedRod(
    int groupIndex,
    AppThemeData theme,
    AppChartTheme chart,
    List<Color> palette,
    TextStyle axisStyle,
    _AppBarLabelLayout labelLayout,
  ) {
    final group = widget.groups[groupIndex];
    final items = <BarChartRodStackItem>[];
    var positive = 0.0;
    var negative = 0.0;
    var anyHovered = false;
    for (
      var seriesIndex = 0;
      seriesIndex < group.values.length;
      seriesIndex++
    ) {
      final value = group.values[seriesIndex];
      final hidden = _hiddenSeries.contains(seriesIndex);
      final suppressNull =
          value.value == null && widget.nullPolicy != AppChartNullPolicy.zero;
      final numeric = hidden || suppressNull ? 0.0 : (value.value ?? 0);
      final from = numeric >= 0 ? positive : negative;
      final to = from + numeric;
      if (numeric >= 0) {
        positive = to;
      } else {
        negative = to;
      }
      final selection = AppChartSelection(groupIndex, seriesIndex);
      final isHovered = selection == _hovered;
      final isSelected = _selected.contains(selection);
      anyHovered = anyHovered || isHovered;
      final baseColor =
          value.color ??
          (seriesIndex < widget.series.length
              ? widget.series[seriesIndex].color
              : null) ??
          palette[seriesIndex % palette.length];
      final resolved =
          widget.colorResolver?.call(
            AppBarChartStyleContext(
              hit: _hit(selection),
              baseColor: baseColor,
              isHovered: isHovered,
              isSelected: isSelected,
            ),
          ) ??
          baseColor;
      final hasActive = _hovered != null || _selected.isNotEmpty;
      final active = isHovered || isSelected;
      final color = resolved.withValues(
        alpha: hidden || suppressNull
            ? 0
            : (hasActive && !active ? chart.inactiveOpacity : 1),
      );
      items.add(
        BarChartRodStackItem(
          from,
          to,
          hidden || suppressNull
              ? Colors.transparent
              : (value.gradient == null ? color : null),
          gradient: hidden || suppressNull ? null : value.gradient,
        ),
      );
    }
    final total = positive + negative;
    return BarChartRodData(
      fromY: negative,
      toY: positive,
      color: Colors.transparent,
      width: chart.barWidth * (anyHovered ? chart.hoverScale : 1),
      borderRadius: BorderRadius.circular(chart.radius),
      rodStackItems: items,
      label: BarChartRodLabel(
        show: _showLabel(labelLayout, groupIndex, 0),
        text: _valueAxis.formatter?.call(total) ?? appChartNumber(total),
        style: axisStyle.copyWith(color: theme.colorScheme.foreground),
      ),
    );
  }

  AxisTitles _bottomTitles(TextStyle style, AppChartTheme chart) => AxisTitles(
    axisNameWidget: _categoryAxis.title == null
        ? null
        : Text(
            _categoryAxis.title!,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
    axisNameSize: _categoryAxis.title == null ? 0 : 22,
    sideTitles: SideTitles(
      showTitles: _categoryAxis.show,
      reservedSize:
          _categoryAxis.reservedSize ??
          (_horizontal
              ? appChartAxisReservedWidth(
                  widget.groups.map((group) => group.label),
                  style,
                  chart,
                )
              : 30),
      interval: _categoryAxis.interval,
      getTitlesWidget: (value, meta) {
        final index = value.round();
        if (index < 0 || index >= widget.groups.length || value != index) {
          return const SizedBox.shrink();
        }
        return SideTitleWidget(
          meta: meta,
          space: 8,
          fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
          child: Text(
            widget.groups[index].label,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
        );
      },
    ),
  );

  AxisTitles _leftTitles(
    TextStyle style,
    AppChartTheme chart,
    double min,
    double max,
  ) => AxisTitles(
    axisNameWidget: _valueAxis.title == null
        ? null
        : Text(
            _valueAxis.title!,
            style: style,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.ellipsis,
          ),
    axisNameSize: _valueAxis.title == null ? 0 : 22,
    sideTitles: SideTitles(
      showTitles: _valueAxis.show,
      reservedSize:
          _valueAxis.reservedSize ??
          (_horizontal
              ? 30
              : appChartAxisReservedWidth(
                  appChartValueAxisLabels(min, max, _valueAxis.formatter),
                  style,
                  chart,
                )),
      interval: _valueAxis.interval,
      getTitlesWidget: (value, meta) => SideTitleWidget(
        meta: meta,
        space: 8,
        fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
        child: Text(
          _valueAxis.formatter?.call(value) ?? appChartNumber(value),
          style: style,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ),
  );

  void _handleTouch(FlTouchEvent event, BarTouchResponse? response) {
    final spot = response?.spot;
    final seriesIndex = spot == null
        ? -1
        : widget._variant == _AppBarChartVariant.stacked
        ? spot.touchedStackItemIndex
        : spot.touchedRodDataIndex;
    final next = spot == null || seriesIndex < 0
        ? null
        : AppChartSelection(spot.touchedBarGroupIndex, seriesIndex);
    final tooltipMessage = next == null || !widget.showTooltip
        ? null
        : _tooltipFor(next);
    final tooltipPosition = tooltipMessage == null
        ? null
        : _pointerPosition(response?.touchLocation);
    if (_hovered != next ||
        _tooltipPosition != tooltipPosition ||
        _tooltipMessage != tooltipMessage) {
      setState(() {
        _hovered = next;
        _tooltipPosition = tooltipPosition;
        _tooltipMessage = tooltipMessage;
      });
    }
    if (event is! FlTapUpEvent || next == null) return;
    _activate(next);
  }

  Offset? _pointerPosition(Offset? position) {
    if (position == null || !_horizontal) return position;
    final size = _chartAreaKey.currentContext?.size;
    if (size == null) return position;
    return Offset(size.width - position.dy, position.dx);
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
    });
  }

  void _activate(AppChartSelection next) {
    if (widget.selectionEnabled) {
      final changed = Set<AppChartSelection>.of(_selected);
      changed.contains(next) ? changed.remove(next) : changed.add(next);
      if (!_selectionIsControlled) setState(() => _internalSelected = changed);
      widget.onSelectionChanged?.call(
        Set<AppChartSelection>.unmodifiable(changed),
      );
    }
    widget.onBarTap?.call(_hit(next));
  }

  List<AppChartSelection> get _keyboardItems => <AppChartSelection>[
    for (var groupIndex = 0; groupIndex < widget.groups.length; groupIndex++)
      for (
        var seriesIndex = 0;
        seriesIndex < widget.groups[groupIndex].values.length;
        seriesIndex++
      )
        if (!_hiddenSeries.contains(seriesIndex) &&
            (widget.groups[groupIndex].values[seriesIndex].value != null ||
                widget.nullPolicy == AppChartNullPolicy.zero))
          AppChartSelection(groupIndex, seriesIndex),
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
      });
      return;
    }
    if (!_selectionIsControlled) {
      setState(() {
        _hovered = null;
        _tooltipPosition = null;
        _tooltipMessage = null;
        _internalSelected = <AppChartSelection>{};
      });
    } else {
      setState(() {
        _hovered = null;
        _tooltipPosition = null;
        _tooltipMessage = null;
      });
    }
    widget.onSelectionChanged?.call(const <AppChartSelection>{});
  }

  String _tooltipFor(AppChartSelection selection) {
    final hit = _hit(selection);
    if (widget._variant == _AppBarChartVariant.stacked) {
      final lines = <String>[hit.group.label];
      for (var index = 0; index < hit.group.values.length; index++) {
        if (_hiddenSeries.contains(index)) continue;
        final name = index < widget.series.length
            ? widget.series[index].name
            : '系列 ${index + 1}';
        final value = hit.group.values[index].value ?? 0;
        lines.add(
          '$name ${_valueAxis.formatter?.call(value) ?? appChartNumber(value)}',
        );
      }
      return lines.join('\n');
    }
    final seriesName = hit.series?.name;
    final value = hit.value.value ?? 0;
    return '${hit.group.label}${seriesName == null ? '' : ' · $seriesName'}\n${_valueAxis.formatter?.call(value) ?? appChartNumber(value)}';
  }

  AppBarChartHit _hit(AppChartSelection selection) {
    final group = widget.groups[selection.groupIndex];
    return AppBarChartHit(
      selection: selection,
      group: group,
      series: selection.seriesIndex < widget.series.length
          ? widget.series[selection.seriesIndex]
          : null,
      value: group.values[selection.seriesIndex],
    );
  }
}

@immutable
class _AppBarLabelLayout {
  const _AppBarLabelLayout({required this.stride, required this.singlePerGroup})
    : visible = true;

  const _AppBarLabelLayout.hidden()
    : stride = 1,
      singlePerGroup = false,
      visible = false;

  final int stride;
  final bool singlePerGroup;
  final bool visible;
}
