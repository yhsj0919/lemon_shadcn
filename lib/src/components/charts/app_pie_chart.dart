import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../../foundation/app_theme_config.dart';
import '../overlay/app_pointer_tooltip.dart';
import 'app_chart_common.dart';

typedef AppPieChartTapCallback = void Function(AppPieChartHit hit);
typedef AppPieChartTooltipBuilder =
    Widget Function(BuildContext context, AppPieChartHit hit);
typedef AppPieChartDataBuilder = PieChartData Function(PieChartData data);

@immutable
class AppPieSection {
  const AppPieSection({required this.label, required this.value, this.color})
    : assert(value >= 0);

  final String label;
  final double value;
  final Color? color;
}

@immutable
class AppPieChartHit {
  const AppPieChartHit({required this.index, required this.section});

  final int index;
  final AppPieSection section;
}

class AppPieChart extends StatefulWidget {
  const AppPieChart({
    super.key,
    required this.sections,
    this.height,
    this.palette,
    this.showLegend = true,
    this.showValues = true,
    this.showTooltip = true,
    this.tooltipStyle,
    this.tooltipWidgetBuilder,
    this.interactive = true,
    this.selectionEnabled = false,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.semanticLabel = '饼图，使用方向键浏览数据',
    this.valueFormatter,
    this.selectedIndex,
    this.onSelectionChanged,
    this.onSectionTap,
    this.dataBuilder,
  }) : _donut = false;

  const AppPieChart.donut({
    super.key,
    required this.sections,
    this.height,
    this.palette,
    this.showLegend = true,
    this.showValues = true,
    this.showTooltip = true,
    this.tooltipStyle,
    this.tooltipWidgetBuilder,
    this.interactive = true,
    this.selectionEnabled = false,
    this.keyboardNavigation = true,
    this.autofocus = false,
    this.semanticLabel = '环形图，使用方向键浏览数据',
    this.valueFormatter,
    this.selectedIndex,
    this.onSelectionChanged,
    this.onSectionTap,
    this.dataBuilder,
  }) : _donut = true;

  final List<AppPieSection> sections;
  final double? height;
  final List<Color>? palette;
  final bool showLegend;
  final bool showValues;
  final bool showTooltip;
  final AppPointerTooltipStyle? tooltipStyle;
  final AppPieChartTooltipBuilder? tooltipWidgetBuilder;
  final bool interactive;
  final bool selectionEnabled;
  final bool keyboardNavigation;
  final bool autofocus;
  final String semanticLabel;
  final AppChartValueFormatter? valueFormatter;
  final int? selectedIndex;
  final ValueChanged<int?>? onSelectionChanged;
  final AppPieChartTapCallback? onSectionTap;
  final AppPieChartDataBuilder? dataBuilder;
  final bool _donut;

  @override
  State<AppPieChart> createState() => _AppPieChartState();
}

class _AppPieChartState extends State<AppPieChart> {
  final Set<int> _hidden = <int>{};
  int? _internalSelected;
  int? _hovered;
  Offset? _tooltipPosition;
  String? _tooltipMessage;

  bool get _controlled => widget.onSelectionChanged != null;
  int? get _selected => widget.selectionEnabled
      ? (_controlled ? widget.selectedIndex : _internalSelected)
      : null;

  @override
  void initState() {
    super.initState();
    _internalSelected = widget.selectedIndex;
  }

  @override
  void didUpdateWidget(covariant AppPieChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_controlled && oldWidget.selectedIndex != widget.selectedIndex) {
      _internalSelected = widget.selectedIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = AppTheme.maybeOf(context);
    final chart = config?.chart ?? const AppChartTheme();
    final theme = ShadcnTheme.of(context);
    final palette = appChartPalette(chart, theme.colorScheme, widget.palette);
    var total = 0.0;
    for (var index = 0; index < widget.sections.length; index++) {
      if (!_hidden.contains(index)) total += widget.sections[index].value;
    }
    final empty = widget.sections.isEmpty || total == 0;
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
                  if (widget.showLegend) ...<Widget>[
                    AppChartLegend(
                      items: <AppChartLegendData>[
                        for (
                          var index = 0;
                          index < widget.sections.length;
                          index++
                        )
                          AppChartLegendData(
                            label: widget.sections[index].label,
                            color:
                                widget.sections[index].color ??
                                palette[index % palette.length],
                          ),
                      ],
                      hidden: _hidden,
                      onToggle: _toggleSection,
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
                              AppPieChartHit(
                                index: _hovered!,
                                section: widget.sections[_hovered!],
                              ),
                            ),
                      onExit: _clearPointerHover,
                      child: Stack(
                        alignment: Alignment.center,
                        children: <Widget>[
                          PieChart(
                            widget.dataBuilder?.call(
                                  _data(theme, chart, palette, total),
                                ) ??
                                _data(theme, chart, palette, total),
                            duration:
                                config?.motion.enabled == false ||
                                    MediaQuery.maybeOf(
                                          context,
                                        )?.disableAnimations ==
                                        true
                                ? Duration.zero
                                : chart.pieAnimationDuration,
                          ),
                          if (widget._donut)
                            IgnorePointer(child: _centerLabel(theme, total)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  PieChartData _data(
    AppThemeData theme,
    AppChartTheme chart,
    List<Color> palette,
    double total,
  ) => PieChartData(
    centerSpaceRadius: widget._donut ? chart.donutHoleRadius : 0,
    centerSpaceColor: theme.colorScheme.background,
    sectionsSpace: chart.pieSectionSpacing,
    startDegreeOffset: -90,
    sections: <PieChartSectionData>[
      for (var index = 0; index < widget.sections.length; index++)
        _section(index, theme, chart, palette, total),
    ],
    pieTouchData: PieTouchData(
      enabled: widget.interactive,
      mouseCursorResolver: (_, response) =>
          response?.touchedSection?.touchedSectionIndex != null
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      touchCallback: _handleTouch,
    ),
  );

  PieChartSectionData _section(
    int index,
    AppThemeData theme,
    AppChartTheme chart,
    List<Color> palette,
    double total,
  ) {
    final item = widget.sections[index];
    final hidden = _hidden.contains(index);
    final active = _hovered == index || _selected == index;
    final hasActive = _hovered != null || _selected != null;
    final base = item.color ?? palette[index % palette.length];
    final color = base.withValues(
      alpha: hidden ? 0 : (hasActive && !active ? chart.inactiveOpacity : 1),
    );
    final percent = total == 0 ? 0 : item.value / total * 100;
    return PieChartSectionData(
      value: hidden ? 0 : item.value,
      color: color,
      radius: chart.pieRadius * (active ? chart.hoverScale : 1),
      cornerRadius: chart.radius,
      showTitle:
          widget.showValues && !hidden && percent >= chart.pieLabelMinPercent,
      title: '${percent.round()}%',
      titleStyle: theme.typography.xSmall.copyWith(
        color: _foregroundFor(base),
        fontWeight: FontWeight.w600,
      ),
      titlePositionPercentageOffset: widget._donut ? 0.55 : 0.62,
    );
  }

  Widget _centerLabel(AppThemeData theme, double total) {
    final index = _hovered ?? _selected;
    final label = index == null ? '总计' : widget.sections[index].label;
    final value = index == null ? total : widget.sections[index].value;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          widget.valueFormatter?.call(value) ?? appChartNumber(value),
          style: theme.typography.large.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: theme.typography.xSmall.copyWith(
            color: theme.colorScheme.mutedForeground,
          ),
        ),
      ],
    );
  }

  void _toggleSection(int index) {
    if (!_hidden.contains(index) &&
        _hidden.length == widget.sections.length - 1) {
      return;
    }
    setState(() {
      _hidden.contains(index) ? _hidden.remove(index) : _hidden.add(index);
    });
  }

  void _handleTouch(FlTouchEvent event, PieTouchResponse? response) {
    final touched = response?.touchedSection?.touchedSectionIndex;
    final next = touched == null || touched < 0 ? null : touched;
    final tooltipMessage = next == null || !widget.showTooltip
        ? null
        : _tooltipFor(next);
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
    });
  }

  void _activate(int next) {
    if (widget.selectionEnabled) {
      final changed = _selected == next ? null : next;
      if (!_controlled) setState(() => _internalSelected = changed);
      widget.onSelectionChanged?.call(changed);
    }
    widget.onSectionTap?.call(
      AppPieChartHit(index: next, section: widget.sections[next]),
    );
  }

  List<int> get _keyboardItems => <int>[
    for (var index = 0; index < widget.sections.length; index++)
      if (!_hidden.contains(index) && widget.sections[index].value > 0) index,
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
    if (!_controlled) {
      setState(() {
        _hovered = null;
        _tooltipPosition = null;
        _tooltipMessage = null;
        _internalSelected = null;
      });
    } else {
      setState(() {
        _hovered = null;
        _tooltipPosition = null;
        _tooltipMessage = null;
      });
    }
    widget.onSelectionChanged?.call(null);
  }

  String _tooltipFor(int index) {
    final visibleTotal = widget.sections
        .asMap()
        .entries
        .where((entry) => !_hidden.contains(entry.key))
        .fold<double>(0, (sum, entry) => sum + entry.value.value);
    final section = widget.sections[index];
    final percent = visibleTotal == 0 ? 0 : section.value / visibleTotal * 100;
    return '${section.label}\n${widget.valueFormatter?.call(section.value) ?? appChartNumber(section.value)} · ${percent.round()}%';
  }
}

Color _foregroundFor(Color color) =>
    color.computeLuminance() > 0.48 ? const Color(0xff111827) : Colors.white;
