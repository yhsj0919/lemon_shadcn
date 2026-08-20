import 'dart:math' as math;
import 'package:flutter/material.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../../foundation/app_theme_config.dart';
import 'app_chart_common.dart';

@immutable
class AppRankBarSegment {
  const AppRankBarSegment({required this.value, this.color});

  final double value;
  final Color? color;
}

@immutable
class AppRankBarItem {
  const AppRankBarItem({
    required this.label,
    required this.value,
    this.segments = const <AppRankBarSegment>[],
  });

  final String label;
  final double value;
  final List<AppRankBarSegment> segments;
}

@immutable
class AppRankBarHeader {
  const AppRankBarHeader({
    this.rank = '序号',
    this.label = '名称',
    this.value = '数值',
    this.rankWidget,
    this.labelWidget,
    this.valueWidget,
    this.height = 44,
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
    this.margin = EdgeInsets.zero,
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.backgroundColor,
  });

  final String rank;
  final String label;
  final String value;
  final Widget? rankWidget;
  final Widget? labelWidget;
  final Widget? valueWidget;
  final double height;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry borderRadius;
  final Color? backgroundColor;
}

/// A table-like ranking chart whose value labels live in a dedicated,
/// right-aligned column and therefore cannot overflow the bar plot.
class AppRankBarChart extends StatelessWidget {
  const AppRankBarChart({
    super.key,
    required this.items,
    this.header,
    this.max,
    this.height,
    this.rowHeight = 44,
    this.rowSpacing = 0,
    this.headerSpacing = 8,
    this.rankWidth = 40,
    this.labelWidth = 120,
    this.valueWidth,
    this.gap = 8,
    this.barHeight = 12,
    this.radius = 999,
    this.color,
    this.palette,
    this.trackColor,
    this.valueFormatter,
    this.rankBuilder,
    this.labelBuilder,
    this.valueBuilder,
    this.onItemTap,
  }) : assert(rowHeight > 0),
       assert(rowSpacing >= 0),
       assert(headerSpacing >= 0),
       assert(rankWidth >= 0),
       assert(labelWidth >= 0),
       assert(valueWidth == null || valueWidth >= 0),
       assert(gap >= 0),
       assert(barHeight > 0),
       assert(radius >= 0);

  final List<AppRankBarItem> items;
  final AppRankBarHeader? header;
  final double? max;
  final double? height;
  final double rowHeight;
  final double rowSpacing;
  final double headerSpacing;
  final double rankWidth;
  final double labelWidth;
  final double? valueWidth;
  final double gap;
  final double barHeight;
  final double radius;

  /// When set, every bar and segment uses this color (monochrome mode).
  final Color? color;

  /// Used for multi-color segments when [color] is null.
  final List<Color>? palette;
  final Color? trackColor;
  final String Function(double value)? valueFormatter;
  final Widget Function(BuildContext context, int rank)? rankBuilder;
  final Widget Function(BuildContext context, AppRankBarItem item)?
  labelBuilder;
  final Widget Function(
    BuildContext context,
    AppRankBarItem item,
    String formattedValue,
  )?
  valueBuilder;
  final ValueChanged<AppRankBarItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    final config = AppTheme.maybeOf(context);
    final chartTheme = config?.chart ?? const AppChartTheme();
    final theme = ShadcnTheme.of(context);
    final colors = appChartPalette(chartTheme, theme.colorScheme, palette);
    final effectiveMax = math.max(
      max ??
          items.fold<double>(0, (value, item) => math.max(value, item.value)),
      1.0,
    );
    final valueStyle = theme.typography.small.copyWith(
      color: theme.colorScheme.foreground,
      fontFeatures: const <FontFeature>[FontFeature.tabularFigures()],
    );
    final measuredValueWidth =
        valueWidth ?? _measureValueWidth(valueStyle, chartTheme);
    final contentHeight =
        rowHeight * math.max(items.length, 1) +
        rowSpacing * math.max(0, items.length - 1);
    final headerMargin = header?.margin.resolve(Directionality.of(context));
    final headerPadding = header?.padding.resolve(Directionality.of(context));
    final rowInsets = header == null
        ? EdgeInsets.zero
        : EdgeInsets.only(
            left: headerMargin!.left + headerPadding!.left,
            right: headerMargin.right + headerPadding.right,
          );
    final headerHeight = header == null
        ? 0.0
        : header!.height + headerMargin!.vertical + headerSpacing;

    return SizedBox(
      height: height ?? contentHeight + headerHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final effectiveLabelWidth = math.min(
            labelWidth,
            math.max(56.0, constraints.maxWidth * .28),
          );
          return Column(
            children: <Widget>[
              if (header != null)
                SizedBox(
                  height: header!.height + headerMargin!.vertical,
                  child: Padding(
                    padding: header!.margin,
                    child: _headerRow(
                      context,
                      header!,
                      effectiveLabelWidth,
                      measuredValueWidth,
                      theme,
                    ),
                  ),
                ),
              if (header != null && headerSpacing > 0)
                SizedBox(height: headerSpacing),
              Expanded(
                child: items.isEmpty
                    ? Center(
                        child: Text(
                          '暂无数据',
                          style: theme.typography.small.copyWith(
                            color: theme.colorScheme.mutedForeground,
                          ),
                        ),
                      )
                    : Column(
                        children: <Widget>[
                          for (
                            var index = 0;
                            index < items.length;
                            index++
                          ) ...<Widget>[
                            Expanded(
                              child: Padding(
                                padding: rowInsets,
                                child: _itemRow(
                                  context,
                                  index,
                                  items[index],
                                  effectiveMax,
                                  effectiveLabelWidth,
                                  measuredValueWidth,
                                  valueStyle,
                                  colors,
                                  theme,
                                ),
                              ),
                            ),
                            if (index < items.length - 1 && rowSpacing > 0)
                              SizedBox(height: rowSpacing),
                          ],
                        ],
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _headerRow(
    BuildContext context,
    AppRankBarHeader data,
    double effectiveLabelWidth,
    double effectiveValueWidth,
    AppThemeData theme,
  ) {
    final style = theme.typography.small.copyWith(
      color: theme.colorScheme.mutedForeground,
      fontWeight: FontWeight.w600,
    );
    return DecoratedBox(
      decoration: BoxDecoration(
        color: data.backgroundColor ?? theme.colorScheme.muted,
        borderRadius: data.borderRadius,
      ),
      child: Padding(
        padding: data.padding,
        child: Row(
          children: <Widget>[
            SizedBox(
              width: rankWidth,
              child:
                  data.rankWidget ??
                  Text(data.rank, textAlign: TextAlign.center, style: style),
            ),
            SizedBox(width: gap),
            SizedBox(
              width: effectiveLabelWidth,
              child:
                  data.labelWidget ??
                  Text(data.label, maxLines: 1, style: style),
            ),
            SizedBox(width: gap),
            const Expanded(child: SizedBox()),
            SizedBox(width: gap),
            SizedBox(
              width: effectiveValueWidth,
              child:
                  data.valueWidget ??
                  Text(
                    data.value,
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    style: style,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemRow(
    BuildContext context,
    int index,
    AppRankBarItem item,
    double effectiveMax,
    double effectiveLabelWidth,
    double effectiveValueWidth,
    TextStyle valueStyle,
    List<Color> colors,
    AppThemeData theme,
  ) {
    return Semantics(
      button: onItemTap != null,
      label: '${index + 1} ${item.label} ${_format(item.value)}',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onItemTap == null ? null : () => onItemTap!(item),
        child: Row(
          children: <Widget>[
            SizedBox(
              width: rankWidth,
              child:
                  rankBuilder?.call(context, index + 1) ??
                  Text(
                    '${index + 1}',
                    textAlign: TextAlign.center,
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.mutedForeground,
                    ),
                  ),
            ),
            SizedBox(width: gap),
            SizedBox(
              width: effectiveLabelWidth,
              child:
                  labelBuilder?.call(context, item) ??
                  Text(
                    item.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.typography.small.copyWith(
                      color: theme.colorScheme.foreground,
                    ),
                  ),
            ),
            SizedBox(width: gap),
            Expanded(
              child: SizedBox(
                height: barHeight,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(radius),
                  child: ColoredBox(
                    color: trackColor ?? theme.colorScheme.muted,
                    child: LayoutBuilder(
                      builder: (_, constraints) => Stack(
                        children: _segments(
                          index,
                          item,
                          effectiveMax,
                          constraints.maxWidth,
                          colors,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(width: gap),
            SizedBox(
              key: ValueKey<String>('app-rank-bar-value-$index'),
              width: effectiveValueWidth,
              child:
                  valueBuilder?.call(context, item, _format(item.value)) ??
                  Text(
                    _format(item.value),
                    textAlign: TextAlign.right,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: valueStyle,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _segments(
    int rowIndex,
    AppRankBarItem item,
    double effectiveMax,
    double width,
    List<Color> colors,
  ) {
    final source = item.segments.isEmpty
        ? <AppRankBarSegment>[AppRankBarSegment(value: item.value)]
        : item.segments;
    final visible = <(int, AppRankBarSegment)>[
      for (var index = 0; index < source.length; index++)
        if (source[index].value > 0) (index, source[index]),
    ];
    final result = <Widget>[];
    var left = 0.0;
    for (var visibleIndex = 0; visibleIndex < visible.length; visibleIndex++) {
      final (index, segment) = visible[visibleIndex];
      final segmentWidth = (math.max(0.0, segment.value) / effectiveMax * width)
          .clamp(0.0, math.max(0.0, width - left))
          .toDouble();
      if (segmentWidth <= 0) continue;
      result.add(
        Positioned(
          left: left,
          top: 0,
          bottom: 0,
          width: segmentWidth,
          child: ClipRRect(
            borderRadius: BorderRadius.horizontal(
              left: visibleIndex == 0 ? Radius.circular(radius) : Radius.zero,
              right: visibleIndex == visible.length - 1
                  ? Radius.circular(radius)
                  : Radius.zero,
            ),
            child: ColoredBox(
              key: ValueKey<String>('app-rank-bar-segment-$rowIndex-$index'),
              color: color ?? segment.color ?? colors[index % colors.length],
            ),
          ),
        ),
      );
      left += segmentWidth;
    }
    return result;
  }

  double _measureValueWidth(TextStyle style, AppChartTheme chart) {
    final painter = TextPainter(maxLines: 1, textDirection: TextDirection.ltr);
    var width = 0.0;
    for (final item in items) {
      painter.text = TextSpan(text: _format(item.value), style: style);
      painter.layout();
      width = math.max(width, painter.width);
    }
    if (header != null) {
      painter.text = TextSpan(text: header!.value, style: style);
      painter.layout();
      width = math.max(width, painter.width);
    }
    painter.dispose();
    return (width + 2).clamp(32.0, chart.axisMaxReservedSize + 32).toDouble();
  }

  String _format(double value) =>
      valueFormatter?.call(value) ?? appChartNumber(value);
}
