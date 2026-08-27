import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../../foundation/app_theme_config.dart';
import '../overlay/app_pointer_tooltip.dart';
import 'app_chart_common.dart';

@immutable
class AppRadarSeries {
  const AppRadarSeries({required this.name, required this.values, this.color});

  final String name;
  final List<double> values;
  final Color? color;
}

@immutable
class AppRadarChartHit {
  const AppRadarChartHit({
    required this.seriesIndex,
    required this.indicatorIndex,
    required this.series,
    required this.indicator,
    required this.value,
  });

  final int seriesIndex;
  final int indicatorIndex;
  final AppRadarSeries series;
  final String indicator;
  final double value;
}

typedef AppRadarChartDataBuilder = RadarChartData Function(RadarChartData data);
typedef AppRadarChartTooltipBuilder =
    Widget Function(BuildContext context, AppRadarChartHit hit);

class AppRadarChart extends StatefulWidget {
  const AppRadarChart({
    super.key,
    required this.indicators,
    required this.series,
    this.height,
    this.palette,
    this.tickCount = 4,
    this.showTickLabels = false,
    this.titlePositionPercentageOffset = 0.12,
    this.shape = RadarShape.polygon,
    this.showLegend = true,
    this.showTooltip = true,
    this.tooltipStyle,
    this.tooltipWidgetBuilder,
    this.interactive = true,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.semanticLabel = '雷达图，使用方向键浏览数据',
    this.onPointTap,
    this.dataBuilder,
  }) : assert(tickCount >= 1);

  final List<String> indicators;
  final List<AppRadarSeries> series;
  final double? height;
  final List<Color>? palette;
  final int tickCount;
  final bool showTickLabels;
  final double titlePositionPercentageOffset;
  final RadarShape shape;
  final bool showLegend;
  final bool showTooltip;
  final AppPointerTooltipStyle? tooltipStyle;
  final AppRadarChartTooltipBuilder? tooltipWidgetBuilder;
  final bool interactive;
  final bool keyboardNavigation;
  final bool autofocus;
  final String semanticLabel;
  final ValueChanged<AppRadarChartHit>? onPointTap;
  final AppRadarChartDataBuilder? dataBuilder;

  @override
  State<AppRadarChart> createState() => _AppRadarChartState();
}

class _AppRadarChartState extends State<AppRadarChart> {
  final Set<int> _hidden = <int>{};
  Offset? _tooltipPosition;
  String? _tooltipMessage;
  AppChartSelection? _hovered;

  @override
  Widget build(BuildContext context) {
    final config = AppTheme.maybeOf(context);
    final chart = config?.chart ?? const AppChartTheme();
    final theme = ShadcnTheme.of(context);
    final palette = appChartPalette(chart, theme.colorScheme, widget.palette);
    final valid = widget.series.where(
      (series) => series.values.length == widget.indicators.length,
    );
    final hasData = widget.indicators.length >= 3 && valid.isNotEmpty;
    return AppChartKeyboardRegion(
      enabled: widget.keyboardNavigation && hasData,
      autofocus: widget.autofocus,
      semanticLabel: widget.semanticLabel,
      onPrevious: () => _moveKeyboard(-1),
      onNext: () => _moveKeyboard(1),
      onActivate: _activateCurrent,
      onClear: _clear,
      child: SizedBox(
        height: widget.height ?? chart.height,
        child: !hasData
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
                  if (widget.showLegend) ...<Widget>[
                    AppChartLegend(
                      items: <AppChartLegendData>[
                        for (
                          var index = 0;
                          index < widget.series.length;
                          index++
                        )
                          AppChartLegendData(
                            label: widget.series[index].name,
                            color:
                                widget.series[index].color ??
                                palette[index % palette.length],
                          ),
                      ],
                      hidden: _hidden,
                      onToggle: _toggle,
                    ),
                    SizedBox(height: chart.legendSpacing),
                  ],
                  Expanded(
                    child: AppPointerTooltipArea(
                      position: _tooltipPosition,
                      message: _tooltipMessage,
                      style: widget.tooltipStyle,
                      builder: widget.tooltipWidgetBuilder == null
                          ? null
                          : (context, _) => widget.tooltipWidgetBuilder!(
                              context,
                              _hit(_hovered!),
                            ),
                      onExit: _clear,
                      child: RadarChart(
                        widget.dataBuilder?.call(
                              _data(theme, chart, palette),
                            ) ??
                            _data(theme, chart, palette),
                        duration:
                            config?.motion.enabled == false ||
                                MediaQuery.maybeOf(
                                      context,
                                    )?.disableAnimations ==
                                    true
                            ? Duration.zero
                            : chart.animationDuration,
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  RadarChartData _data(
    AppThemeData theme,
    AppChartTheme chart,
    List<Color> palette,
  ) => RadarChartData(
    dataSets: <RadarDataSet>[
      for (var index = 0; index < widget.series.length; index++)
        if (!_hidden.contains(index) &&
            widget.series[index].values.length == widget.indicators.length)
          RadarDataSet(
            dataEntries: <RadarEntry>[
              for (final value in widget.series[index].values)
                RadarEntry(value: value),
            ],
            borderColor:
                widget.series[index].color ?? palette[index % palette.length],
            fillColor:
                (widget.series[index].color ?? palette[index % palette.length])
                    .withValues(alpha: 0.16),
            borderWidth:
                chart.lineWidth * (_hovered?.seriesIndex == index ? 1.4 : 1),
            entryRadius:
                chart.pointRadius *
                (_hovered?.seriesIndex == index ? chart.hoverScale : 1),
          ),
    ],
    radarShape: widget.shape,
    radarBackgroundColor: Colors.transparent,
    radarBorderData: BorderSide(color: theme.colorScheme.border),
    gridBorderData: BorderSide(
      color: theme.colorScheme.border.withValues(alpha: chart.gridOpacity),
    ),
    tickBorderData: BorderSide(
      color: theme.colorScheme.border.withValues(alpha: chart.gridOpacity),
    ),
    tickCount: widget.tickCount,
    ticksTextStyle: widget.showTickLabels
        ? appChartAxisStyle(theme, chart)
        : const TextStyle(color: Colors.transparent, fontSize: 0),
    titleTextStyle: appChartAxisStyle(
      theme,
      chart,
    ).copyWith(color: theme.colorScheme.foreground),
    titlePositionPercentageOffset: widget.titlePositionPercentageOffset,
    getTitle: (index, _) => RadarChartTitle(text: widget.indicators[index]),
    radarTouchData: RadarTouchData(
      enabled: widget.interactive,
      touchCallback: _handleTouch,
      mouseCursorResolver: (_, response) => response?.touchedSpot == null
          ? SystemMouseCursors.basic
          : SystemMouseCursors.click,
    ),
  );

  void _handleTouch(FlTouchEvent event, RadarTouchResponse? response) {
    final spot = response?.touchedSpot;
    if (spot == null) {
      _clear();
      return;
    }
    final visible = <int>[
      for (var index = 0; index < widget.series.length; index++)
        if (!_hidden.contains(index) &&
            widget.series[index].values.length == widget.indicators.length)
          index,
    ];
    final seriesIndex = visible[spot.touchedDataSetIndex];
    final hit = AppRadarChartHit(
      seriesIndex: seriesIndex,
      indicatorIndex: spot.touchedRadarEntryIndex,
      series: widget.series[seriesIndex],
      indicator: widget.indicators[spot.touchedRadarEntryIndex],
      value: spot.touchedRadarEntry.value,
    );
    setState(() {
      _hovered = AppChartSelection(hit.indicatorIndex, hit.seriesIndex);
      _tooltipPosition = response?.touchLocation;
      _tooltipMessage = widget.showTooltip
          ? '${hit.indicator}\n${hit.series.name}: ${appChartNumber(hit.value)}'
          : null;
    });
    if (event is FlTapUpEvent) widget.onPointTap?.call(hit);
  }

  List<AppChartSelection> get _keyboardItems => <AppChartSelection>[
    for (var seriesIndex = 0; seriesIndex < widget.series.length; seriesIndex++)
      if (!_hidden.contains(seriesIndex) &&
          widget.series[seriesIndex].values.length == widget.indicators.length)
        for (
          var indicatorIndex = 0;
          indicatorIndex < widget.indicators.length;
          indicatorIndex++
        )
          AppChartSelection(indicatorIndex, seriesIndex),
  ];

  AppRadarChartHit _hit(AppChartSelection selection) {
    final series = widget.series[selection.seriesIndex];
    return AppRadarChartHit(
      seriesIndex: selection.seriesIndex,
      indicatorIndex: selection.groupIndex,
      series: series,
      indicator: widget.indicators[selection.groupIndex],
      value: series.values[selection.groupIndex],
    );
  }

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
    final selection = _hovered ?? items.first;
    if (_hovered == null) {
      setState(() => _hovered = selection);
    }
    final series = widget.series[selection.seriesIndex];
    widget.onPointTap?.call(
      AppRadarChartHit(
        seriesIndex: selection.seriesIndex,
        indicatorIndex: selection.groupIndex,
        series: series,
        indicator: widget.indicators[selection.groupIndex],
        value: series.values[selection.groupIndex],
      ),
    );
  }

  void _toggle(int index) {
    if (!_hidden.contains(index) &&
        _hidden.length >= widget.series.length - 1) {
      return;
    }
    setState(() {
      _hidden.contains(index) ? _hidden.remove(index) : _hidden.add(index);
      _hovered = null;
      _tooltipPosition = null;
      _tooltipMessage = null;
    });
  }

  void _clear() {
    if (_tooltipPosition == null &&
        _tooltipMessage == null &&
        _hovered == null) {
      return;
    }
    setState(() {
      _hovered = null;
      _tooltipPosition = null;
      _tooltipMessage = null;
    });
  }
}
