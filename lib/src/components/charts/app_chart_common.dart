import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_aliases.dart';
import '../../foundation/app_theme_config.dart';

enum AppChartNullPolicy { gap, zero, skip }

enum AppChartSamplingStrategy { none, largestTriangleThreeBuckets }

int appChartLoopIndex(int current, int delta, int length) {
  assert(length > 0);
  return (current + delta + length) % length;
}

/// Returns source indices selected with Largest-Triangle-Three-Buckets (LTTB).
/// The first and last values are always retained, and callbacks continue to
/// address the original data because no replacement points are synthesized.
List<int> appChartSampleIndices<T>(
  List<T> values, {
  required int maxPoints,
  required double Function(T value) x,
  required double Function(T value) y,
  AppChartSamplingStrategy strategy =
      AppChartSamplingStrategy.largestTriangleThreeBuckets,
}) {
  assert(maxPoints >= 3);
  if (strategy == AppChartSamplingStrategy.none || values.length <= maxPoints) {
    return List<int>.generate(values.length, (index) => index);
  }

  final sampled = <int>[0];
  final every = (values.length - 2) / (maxPoints - 2);
  var selected = 0;
  for (var bucket = 0; bucket < maxPoints - 2; bucket++) {
    final averageStart = ((bucket + 1) * every).floor() + 1;
    final averageEnd = math.min(
      ((bucket + 2) * every).floor() + 1,
      values.length,
    );
    var averageX = 0.0;
    var averageY = 0.0;
    final averageLength = math.max(averageEnd - averageStart, 1);
    for (var index = averageStart; index < averageEnd; index++) {
      averageX += x(values[index]);
      averageY += y(values[index]);
    }
    if (averageStart >= values.length) {
      averageX = x(values.last);
      averageY = y(values.last);
    } else {
      averageX /= averageLength;
      averageY /= averageLength;
    }

    final rangeStart = (bucket * every).floor() + 1;
    final rangeEnd = math.min(
      ((bucket + 1) * every).floor() + 1,
      values.length - 1,
    );
    final selectedX = x(values[selected]);
    final selectedY = y(values[selected]);
    var largestArea = -1.0;
    var next = rangeStart;
    for (var index = rangeStart; index < rangeEnd; index++) {
      final area =
          ((selectedX - averageX) * (y(values[index]) - selectedY) -
                  (selectedX - x(values[index])) * (averageY - selectedY))
              .abs();
      if (area > largestArea) {
        largestArea = area;
        next = index;
      }
    }
    sampled.add(next);
    selected = next;
  }
  sampled.add(values.length - 1);
  return sampled;
}

typedef AppChartValueFormatter = String Function(double value);

@immutable
class AppChartAxis {
  const AppChartAxis({
    this.show = true,
    this.title,
    this.min,
    this.max,
    this.interval,
    this.reservedSize,
    this.formatter,
  });

  final bool show;
  final String? title;
  final double? min;
  final double? max;
  final double? interval;
  final double? reservedSize;
  final AppChartValueFormatter? formatter;
}

@immutable
class AppChartReferenceLine {
  const AppChartReferenceLine({
    required this.value,
    this.label,
    this.color,
    this.width = 1,
    this.dash = const <int>[5, 4],
  });

  final double value;
  final String? label;
  final Color? color;
  final double width;
  final List<int>? dash;
}

@immutable
class AppChartSelection {
  const AppChartSelection(this.groupIndex, this.seriesIndex);

  final int groupIndex;
  final int seriesIndex;

  @override
  bool operator ==(Object other) =>
      other is AppChartSelection &&
      other.groupIndex == groupIndex &&
      other.seriesIndex == seriesIndex;

  @override
  int get hashCode => Object.hash(groupIndex, seriesIndex);
}

List<Color> appChartPalette(
  AppChartTheme chart,
  AppColorScheme colors, [
  List<Color>? local,
]) {
  if (local != null && local.isNotEmpty) return local;
  if (chart.palette.isNotEmpty) return chart.palette;
  return <Color>[
    colors.primary,
    const Color(0xff10b981),
    const Color(0xfff59e0b),
    const Color(0xff8b5cf6),
    const Color(0xffef4444),
    const Color(0xff06b6d4),
  ];
}

String appChartNumber(double value) => value == value.roundToDouble()
    ? value.toInt().toString()
    : value.toStringAsFixed(1);

TextStyle appChartAxisStyle(AppThemeData theme, AppChartTheme chart) =>
    theme.typography.xSmall.copyWith(
      fontSize: chart.labelFontSize,
      color: theme.colorScheme.mutedForeground,
    );

double appChartAxisReservedWidth(
  Iterable<String> labels,
  TextStyle style,
  AppChartTheme chart,
) {
  var widest = 0.0;
  final painter = TextPainter(maxLines: 1, textDirection: TextDirection.ltr);
  for (final label in labels) {
    painter.text = TextSpan(text: label, style: style);
    painter.layout(maxWidth: chart.axisMaxReservedSize);
    widest = math.max(widest, painter.width);
  }
  painter.dispose();
  return (widest + 16).clamp(
    chart.axisMinReservedSize,
    chart.axisMaxReservedSize,
  );
}

List<String> appChartValueAxisLabels(
  double min,
  double max,
  AppChartValueFormatter? formatter,
) {
  final values = <double>{min, max, 0, (min + max) / 2};
  String label(double value) => formatter?.call(value) ?? appChartNumber(value);
  return <String>[for (final value in values) label(value)];
}

class AppChartLegend extends StatelessWidget {
  const AppChartLegend({
    super.key,
    required this.items,
    required this.hidden,
    required this.onToggle,
  });

  final List<AppChartLegendData> items;
  final Set<int> hidden;
  final ValueChanged<int> onToggle;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: 14,
    runSpacing: 8,
    children: <Widget>[
      for (var index = 0; index < items.length; index++)
        _AppChartLegendItem(
          data: items[index],
          hidden: hidden.contains(index),
          onTap: () => onToggle(index),
        ),
    ],
  );
}

class AppChartKeyboardRegion extends StatefulWidget {
  const AppChartKeyboardRegion({
    super.key,
    required this.child,
    required this.semanticLabel,
    required this.onPrevious,
    required this.onNext,
    required this.onActivate,
    required this.onClear,
    this.onLeft,
    this.onRight,
    this.onUp,
    this.onDown,
    this.enabled = true,
    this.autofocus = false,
  });

  final Widget child;
  final String semanticLabel;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onActivate;
  final VoidCallback onClear;
  final VoidCallback? onLeft;
  final VoidCallback? onRight;
  final VoidCallback? onUp;
  final VoidCallback? onDown;
  final bool enabled;
  final bool autofocus;

  @override
  State<AppChartKeyboardRegion> createState() => _AppChartKeyboardRegionState();
}

class _AppChartKeyboardRegionState extends State<AppChartKeyboardRegion> {
  bool _focused = false;
  bool _showFocusRing = false;
  final FocusNode _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadcnTheme.of(context);
    final chart = AppTheme.maybeOf(context)?.chart ?? const AppChartTheme();
    return Semantics(
      label: widget.semanticLabel,
      focusable: widget.enabled,
      focused: _focused,
      onTap: widget.enabled ? widget.onActivate : null,
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          if (widget.enabled) {
            if (_showFocusRing) setState(() => _showFocusRing = false);
            _focusNode.requestFocus();
          }
        },
        child: Focus(
          focusNode: _focusNode,
          autofocus: widget.autofocus,
          canRequestFocus: widget.enabled,
          onFocusChange: (value) => setState(() {
            _focused = value;
            if (!value) _showFocusRing = false;
          }),
          onKeyEvent: _onKeyEvent,
          child: Stack(
            clipBehavior: Clip.none,
            children: <Widget>[
              widget.child,
              if (_focused && _showFocusRing)
                Positioned.fill(
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        border: Border.fromBorderSide(
                          BorderSide(
                            color: theme.colorScheme.ring.withValues(
                              alpha: 0.65,
                            ),
                            width: chart.keyboardFocusWidth,
                            strokeAlign: BorderSide.strokeAlignOutside,
                          ),
                        ),
                        borderRadius: BorderRadius.circular(theme.radius * 8),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (!widget.enabled || event is! KeyDownEvent) {
      return KeyEventResult.ignored;
    }
    if (!_showFocusRing) setState(() => _showFocusRing = true);
    final key = event.logicalKey;
    if (key == LogicalKeyboardKey.arrowLeft) {
      (widget.onLeft ?? widget.onPrevious)();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowUp) {
      (widget.onUp ?? widget.onPrevious)();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowRight) {
      (widget.onRight ?? widget.onNext)();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.arrowDown) {
      (widget.onDown ?? widget.onNext)();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.enter || key == LogicalKeyboardKey.space) {
      widget.onActivate();
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.escape) {
      widget.onClear();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }
}

@immutable
class AppChartLegendData {
  const AppChartLegendData({required this.label, required this.color});

  final String label;
  final Color color;
}

class _AppChartLegendItem extends StatefulWidget {
  const _AppChartLegendItem({
    required this.data,
    required this.hidden,
    required this.onTap,
  });

  final AppChartLegendData data;
  final bool hidden;
  final VoidCallback onTap;

  @override
  State<_AppChartLegendItem> createState() => _AppChartLegendItemState();
}

class _AppChartLegendItemState extends State<_AppChartLegendItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = ShadcnTheme.of(context);
    final chart = AppTheme.maybeOf(context)?.chart ?? const AppChartTheme();
    final config = AppTheme.maybeOf(context);
    final duration =
        config?.motion.enabled == false ||
            MediaQuery.maybeOf(context)?.disableAnimations == true
        ? Duration.zero
        : chart.animationDuration;
    final colors = theme.colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: duration,
          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
          decoration: BoxDecoration(
            color: _hovered ? colors.accent : Colors.transparent,
            borderRadius: BorderRadius.circular(theme.radius * 6),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              AnimatedContainer(
                duration: duration,
                width: 9,
                height: 9,
                decoration: BoxDecoration(
                  color: widget.hidden ? Colors.transparent : widget.data.color,
                  border: Border.all(color: widget.data.color),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                widget.data.label,
                style: theme.typography.xSmall.copyWith(
                  color: widget.hidden
                      ? colors.mutedForeground
                      : colors.foreground,
                  decoration: widget.hidden ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
