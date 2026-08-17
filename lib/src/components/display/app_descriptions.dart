import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_density.dart';
import '../../foundation/app_theme_config.dart';
import '../forms/app_inline_edit.dart';

// Public constructor names intentionally differ from the nullable internal
// override slots so the legacy non-null getters remain source-compatible.
// ignore_for_file: prefer_initializing_formals

enum AppDescriptionLayout { vertical, horizontal }

enum AppDescriptionsType { standard, table }

/// Controls the whitespace used by [AppDescriptions].
/// Sentinel for an omitted [valueHeight] so explicit `null` can mean
/// content-sized (no minimum height).
const Object _valueHeightUnset = Object();

bool _isValueHeightSet(Object? value) => !identical(value, _valueHeightUnset);

double? _readValueHeight(Object? value) {
  if (!_isValueHeightSet(value) || value == null) return null;
  return (value as num).toDouble();
}

/// Component-level visual overrides for [AppDescriptions].
///
/// Apply it to a subtree with `ComponentTheme<AppDescriptionsTheme>`.
class AppDescriptionsTheme extends shad.ComponentThemeData {
  const AppDescriptionsTheme({
    this.density,
    this.labelStyle,
    this.valueStyle,
    this.titleStyle,
    this.titleIconTheme,
    this.titleGap,
    this.labelIconTheme,
    this.labelAlignment,
    this.valueAlignment,
    Object? valueHeight = _valueHeightUnset,
    this.padding,
    this.tableCellPadding,
    this.spacing,
    this.runSpacing,
    this.labelGap,
    this.contentGap,
    this.headerPadding,
    this.controlMetrics,
  }) : _valueHeight = valueHeight,
       assert(
         identical(valueHeight, _valueHeightUnset) ||
             valueHeight == null ||
             (valueHeight is num && valueHeight > 0),
       );

  const AppDescriptionsTheme.compact({
    this.labelStyle,
    this.valueStyle,
    this.titleStyle,
    this.titleIconTheme,
    this.titleGap,
    this.labelIconTheme,
    this.labelAlignment,
    this.valueAlignment,
    Object? valueHeight = _valueHeightUnset,
  }) : density = AppDensity.compact,
       _valueHeight = valueHeight,
       padding = null,
       tableCellPadding = null,
       spacing = null,
       runSpacing = null,
       labelGap = null,
       contentGap = null,
       headerPadding = null,
       controlMetrics = null,
       assert(
         identical(valueHeight, _valueHeightUnset) ||
             valueHeight == null ||
             (valueHeight is num && valueHeight > 0),
       );

  final AppDensity? density;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? titleStyle;
  final IconThemeData? titleIconTheme;
  final double? titleGap;
  final IconThemeData? labelIconTheme;
  final AlignmentGeometry? labelAlignment;
  final AlignmentGeometry? valueAlignment;
  final Object? _valueHeight;

  /// Minimum height of each item's value slot.
  ///
  /// - Omitted: when the surface contains [AppInlineEdit], fall back to the
  ///   active control height so plain text lines up with editors; otherwise
  ///   keep the value content-sized.
  /// - `null`: always content-sized, no minimum height.
  /// - `double`: use that minimum height.
  double? get valueHeight => _readValueHeight(_valueHeight);

  bool get _hasValueHeight => _isValueHeightSet(_valueHeight);
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? tableCellPadding;
  final double? spacing;
  final double? runSpacing;
  final double? labelGap;
  final double? contentGap;
  final EdgeInsetsGeometry? headerPadding;
  final AppControlMetrics? controlMetrics;
}

class AppDescriptionItem {
  const AppDescriptionItem({
    required this.label,
    required this.value,
    this.icon,
    this.span = 1,
    this.width,
    this.minWidth,
    this.maxWidth,
    this.labelAlignment,
    this.valueWidth,
    Object? valueHeight = _valueHeightUnset,
    this.expandValue = false,
    AlignmentGeometry? valueAlignment,
  }) : _isDivider = false,
       _isCustom = false,
       _valueAlignment = valueAlignment,
       _valueHeight = valueHeight,
       assert(span > 0),
       assert(width == null || width > 0),
       assert(minWidth == null || minWidth > 0),
       assert(maxWidth == null || maxWidth > 0),
       assert(minWidth == null || maxWidth == null || minWidth <= maxWidth),
       assert(valueWidth == null || valueWidth > 0),
       assert(
         identical(valueHeight, _valueHeightUnset) ||
             valueHeight == null ||
             (valueHeight is num && valueHeight > 0),
       );

  /// Creates an item whose content completely replaces the label/value layout.
  ///
  /// [span] follows the same responsive-column rules as a regular item.
  const AppDescriptionItem.custom({
    required Widget child,
    this.span = 1,
    this.width,
    this.minWidth,
    this.maxWidth,
  }) : label = const SizedBox.shrink(),
       value = child,
       icon = null,
       labelAlignment = null,
       valueWidth = null,
       _valueHeight = _valueHeightUnset,
       expandValue = false,
       _valueAlignment = null,
       _isDivider = false,
       _isCustom = true,
       assert(span > 0),
       assert(width == null || width > 0),
       assert(minWidth == null || minWidth > 0),
       assert(maxWidth == null || maxWidth > 0),
       assert(minWidth == null || maxWidth == null || minWidth <= maxWidth);

  /// Creates a full-row divider that participates in the item order.
  const AppDescriptionItem.divider({required Widget divider})
    : label = const SizedBox.shrink(),
      value = divider,
      icon = null,
      span = 1,
      width = null,
      minWidth = null,
      maxWidth = null,
      labelAlignment = null,
      valueWidth = null,
      _valueHeight = _valueHeightUnset,
      expandValue = false,
      _valueAlignment = null,
      _isDivider = true,
      _isCustom = false;

  final Widget label;
  final Widget value;
  final Widget? icon;

  /// Number of responsive columns occupied in standard mode.
  /// Table mode requires every item to keep the default span of one.
  final int span;

  /// Optional exact width for this complete item in standard Wrap layout.
  /// This overrides the width calculated from [span].
  final double? width;

  /// Minimum width applied to the calculated item width.
  final double? minWidth;

  /// Maximum width applied to the calculated item width.
  final double? maxWidth;

  /// Alignment of this item's complete label, including its optional icon.
  final AlignmentGeometry? labelAlignment;

  /// Optional width for controls such as fields that would otherwise fill a cell.
  final double? valueWidth;

  final Object? _valueHeight;

  /// Minimum height for this item's value slot.
  ///
  /// - Omitted: inherit from [AppDescriptions.valueHeight] / theme, or sync to
  ///   the control height only when the surface mixes in [AppInlineEdit].
  /// - `null`: content-sized, no minimum height.
  /// - `double`: use that minimum height.
  double? get valueHeight => _readValueHeight(_valueHeight);

  bool get _hasValueHeight => _isValueHeightSet(_valueHeight);

  /// Whether the value should consume the full value-area width.
  /// Buttons, badges, and other controls remain content-sized by default.
  final bool expandValue;
  final AlignmentGeometry? _valueAlignment;
  AlignmentGeometry get valueAlignment =>
      _valueAlignment ?? AlignmentDirectional.centerStart;
  final bool _isDivider;
  final bool _isCustom;
}

/// Responsive key-value details for entity and record pages.
///
/// When any item embeds [AppInlineEdit], omitted [valueHeight] syncs every
/// value slot to the control height so plain text aligns with editors without
/// per-row wrappers. Surfaces without inline edit stay content-sized.
class AppDescriptions extends StatelessWidget {
  const AppDescriptions({
    super.key,
    required this.items,
    this.title,
    this.titleIcon,
    this.actions,
    this.columns = 3,
    this.minColumnWidth = 220,
    this.columnWidth,
    this.maxColumnWidth,
    this.layout = AppDescriptionLayout.vertical,
    this.labelWidth = 80,
    this.density,
    this.labelStyle,
    this.valueStyle,
    this.titleStyle,
    this.titleIconTheme,
    this.titleGap,
    this.labelIconTheme,
    this.labelAlignment,
    this.valueAlignment,
    Object? valueHeight = _valueHeightUnset,
    double? spacing,
    double? runSpacing,
    this.labelGap,
    this.contentGap,
    this.bordered = false,
    this.type = AppDescriptionsType.standard,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? tableCellPadding,
    this.headerPadding,
    this.controlMetrics,
    this.margin = EdgeInsets.zero,
  }) : _spacing = spacing,
       _runSpacing = runSpacing,
       _padding = padding,
       _tableCellPadding = tableCellPadding,
       _valueHeight = valueHeight,
       customChild = null,
       assert(columns > 0),
       assert(minColumnWidth > 0),
       assert(columnWidth == null || columnWidth > 0),
       assert(maxColumnWidth == null || maxColumnWidth > 0),
       assert(
         identical(valueHeight, _valueHeightUnset) ||
             valueHeight == null ||
             (valueHeight is num && valueHeight > 0),
       ),
       assert(
         maxColumnWidth == null || minColumnWidth <= maxColumnWidth,
         'minColumnWidth must not exceed maxColumnWidth.',
       );

  /// A descriptions surface with a fully custom body.
  ///
  /// [title] and [actions] keep the standard header layout, while [child]
  /// replaces the responsive label/value grid completely.
  const AppDescriptions.custom({
    super.key,
    required Widget child,
    this.title,
    this.titleIcon,
    this.actions,
    this.columnWidth,
    this.maxColumnWidth,
    this.density,
    this.valueStyle,
    this.titleStyle,
    this.titleIconTheme,
    this.titleGap,
    EdgeInsetsGeometry? padding,
    this.headerPadding,
    this.controlMetrics,
    this.bordered = false,
    this.margin = EdgeInsets.zero,
  }) : _padding = padding,
       _spacing = null,
       _runSpacing = null,
       _tableCellPadding = null,
       _valueHeight = _valueHeightUnset,
       items = const [],
       customChild = child,
       columns = 1,
       minColumnWidth = 1,
       layout = AppDescriptionLayout.vertical,
       labelWidth = 80,
       labelStyle = null,
       labelIconTheme = null,
       labelAlignment = null,
       valueAlignment = null,
       labelGap = null,
       contentGap = null,
       type = AppDescriptionsType.standard;

  final List<AppDescriptionItem> items;
  final Widget? customChild;
  final Widget? title;
  final Widget? titleIcon;
  final Widget? actions;
  final int columns;
  final double minColumnWidth;

  /// Exact width of each responsive column. When set, it overrides the
  /// calculated width and [minColumnWidth]/[maxColumnWidth] clamping.
  final double? columnWidth;

  /// Maximum width of a calculated responsive column.
  final double? maxColumnWidth;
  final AppDescriptionLayout layout;
  final double labelWidth;
  final AppDensity? density;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? titleStyle;
  final IconThemeData? titleIconTheme;
  final double? titleGap;
  final IconThemeData? labelIconTheme;
  final AlignmentGeometry? labelAlignment;
  final AlignmentGeometry? valueAlignment;
  final Object? _valueHeight;

  /// Minimum height of each item's value slot.
  ///
  /// - Omitted: sync to the control height only when items include
  ///   [AppInlineEdit]; otherwise content-sized.
  /// - `null`: always content-sized, no minimum height.
  /// - `double`: use that minimum height.
  double? get valueHeight => _readValueHeight(_valueHeight);

  final double? _spacing;
  final double? _runSpacing;

  /// Requested horizontal item spacing, or the stable standard default.
  double get spacing => _spacing ?? 12;

  /// Requested vertical item spacing, or the stable standard default.
  double get runSpacing => _runSpacing ?? 8;
  final double? labelGap;
  final double? contentGap;
  final bool bordered;
  final AppDescriptionsType type;

  final EdgeInsetsGeometry? _padding;
  final EdgeInsetsGeometry? _tableCellPadding;

  /// Requested content padding, or the stable standard default.
  EdgeInsetsGeometry get padding => _padding ?? const EdgeInsets.all(12);

  /// Requested table-cell padding, or the stable standard default.
  EdgeInsetsGeometry get tableCellPadding =>
      _tableCellPadding ??
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  final EdgeInsetsGeometry? headerPadding;
  final AppControlMetrics? controlMetrics;
  final EdgeInsetsGeometry margin;

  AppDescriptionsTheme _resolvedTheme(BuildContext context) {
    final shadTheme = shad.Theme.of(context);
    final local = shad.ComponentTheme.maybeOf<AppDescriptionsTheme>(context);
    final effectiveDensity =
        density ?? local?.density ?? AppDensity.standard;
    final compact = effectiveDensity == AppDensity.compact;
    final inlineEdit = _syncValueHeightWithInlineEdit;
    final typography = shadTheme.typography;
    final xSmallSize = typography.xSmall.fontSize ?? 12;
    final smallSize = typography.small.fontSize ?? 14;
    final baseSize = typography.base.fontSize ?? 16;
    final intermediateSize = (xSmallSize + smallSize) / 2;
    final resolvedTitleStyle = TextStyle(
      fontSize: compact ? smallSize : baseSize,
      fontWeight: FontWeight.w600,
    ).merge(local?.titleStyle).merge(titleStyle);
    return AppDescriptionsTheme(
      density: effectiveDensity,
      labelStyle: TextStyle(
        fontSize: compact ? xSmallSize : intermediateSize,
        color: shadTheme.colorScheme.mutedForeground,
      ).merge(local?.labelStyle).merge(labelStyle),
      valueStyle: TextStyle(
        fontSize: compact ? intermediateSize : smallSize,
      ).merge(local?.valueStyle).merge(valueStyle),
      titleStyle: resolvedTitleStyle,
      titleIconTheme: IconThemeData(
        size: compact ? 18 : 20,
        color: resolvedTitleStyle.color,
      ).merge(local?.titleIconTheme).merge(titleIconTheme),
      titleGap: titleGap ?? local?.titleGap ?? 8,
      labelIconTheme: IconThemeData(
        size: compact ? 14 : 16,
        color: shadTheme.colorScheme.mutedForeground,
      ).merge(local?.labelIconTheme).merge(labelIconTheme),
      labelAlignment:
          labelAlignment ??
          local?.labelAlignment ??
          AlignmentDirectional.centerStart,
      valueAlignment:
          valueAlignment ??
          local?.valueAlignment ??
          AlignmentDirectional.centerStart,
      valueHeight: _isValueHeightSet(_valueHeight)
          ? _valueHeight
          : local != null && local._hasValueHeight
          ? local._valueHeight
          : _valueHeightUnset,
      padding:
          _padding ??
          local?.padding ??
          (compact
              ? const EdgeInsets.all(8)
              : inlineEdit
              ? const EdgeInsets.symmetric(horizontal: 12, vertical: 6)
              : const EdgeInsets.all(12)),
      tableCellPadding:
          _tableCellPadding ??
          local?.tableCellPadding ??
          EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 0 : 8,
          ),
      spacing: _spacing ?? local?.spacing ?? 12,
      runSpacing:
          _runSpacing ?? local?.runSpacing ?? (inlineEdit ? 0 : 8),
      labelGap: labelGap ?? local?.labelGap ?? (compact ? 4 : 8),
      contentGap:
          contentGap ?? local?.contentGap ?? (compact ? 2 : inlineEdit ? 0 : 4),
      headerPadding:
          headerPadding ??
          local?.headerPadding ??
          EdgeInsets.fromLTRB(
            compact ? 8 : 12,
            compact ? 7 : 10,
            compact ? 8 : 12,
            0,
          ),
      controlMetrics:
          controlMetrics ??
          local?.controlMetrics ??
          (compact
              ? AppControlMetrics(
                  height: 26,
                  buttonHeight: 26,
                  horizontalPadding: 8,
                  fontSize: intermediateSize,
                  iconSize: 14,
                  contentGap: 6,
                )
              : null),
    );
  }

  Widget _buildItem(
    BuildContext context,
    AppDescriptionItem item,
    AppDescriptionsTheme style, {
    required bool syncValueHeightWithInlineEdit,
  }) {
    if (item._isCustom) {
      Widget custom = DefaultTextStyle.merge(
        style: style.valueStyle!,
        child: item.value,
      );
      if (style.controlMetrics case final metrics?) {
        custom = AppControlMetricsScope(metrics: metrics, child: custom);
      }
      return custom;
    }
    final resolvedLabelAlignment =
        (item.labelAlignment ?? style.labelAlignment!).resolve(
          Directionality.of(context),
        );
    final labelContent = IconTheme.merge(
      data: style.labelIconTheme!,
      child: DefaultTextStyle.merge(
        style: style.labelStyle!,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[
              item.icon!,
              SizedBox(width: style.contentGap),
            ],
            Flexible(child: item.label),
          ],
        ),
      ),
    );
    final label = SizedBox(
      width: double.infinity,
      child: Align(alignment: resolvedLabelAlignment, child: labelContent),
    );
    Widget value = DefaultTextStyle.merge(
      style: style.valueStyle!,
      child: item.value,
    );
    if (style.controlMetrics case final metrics?) {
      value = AppControlMetricsScope(metrics: metrics, child: value);
    }
    if (item.valueWidth != null) {
      value = SizedBox(width: item.valueWidth, child: value);
    } else if (item.expandValue) {
      value = SizedBox(width: double.infinity, child: value);
    }
    // Sync plain text to the control slot only when this surface mixes in
    // AppInlineEdit. Explicit valueHeight / null still win.
    final double? valueHeight;
    if (item._hasValueHeight) {
      valueHeight = item.valueHeight;
    } else if (style._hasValueHeight) {
      valueHeight = style.valueHeight;
    } else if (syncValueHeightWithInlineEdit) {
      valueHeight =
          style.controlMetrics?.height ??
          AppControlMetricsScope.resolve(context).height;
    } else {
      valueHeight = null;
    }
    // Align supplies loose constraints to intrinsic controls (notably buttons),
    // while the outer item can still occupy its responsive grid cell.
    final aligned = Align(
      alignment: item._valueAlignment ?? style.valueAlignment!,
      child: value,
    );
    value = valueHeight == null
        ? aligned
        : SizedBox(
            width: double.infinity,
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: valueHeight),
              child: aligned,
            ),
          );
    if (layout == AppDescriptionLayout.horizontal) {
      return Row(
        crossAxisAlignment: resolvedLabelAlignment.y <= -0.5
            ? CrossAxisAlignment.start
            : resolvedLabelAlignment.y >= 0.5
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.center,
        children: [
          SizedBox(width: labelWidth, child: label),
          SizedBox(width: style.labelGap),
          Expanded(child: value),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        label,
        SizedBox(height: style.contentGap),
        value,
      ],
    );
  }

  bool get _syncValueHeightWithInlineEdit =>
      items.any((item) => !item._isDivider && _containsInlineEdit(item.value));

  static bool _containsInlineEdit(Widget widget) {
    if (widget is AppInlineEdit) return true;
    if (widget is ProxyWidget) return _containsInlineEdit(widget.child);
    if (widget is SingleChildRenderObjectWidget) {
      final child = widget.child;
      return child != null && _containsInlineEdit(child);
    }
    if (widget is MultiChildRenderObjectWidget) {
      for (final child in widget.children) {
        if (_containsInlineEdit(child)) return true;
      }
    }
    return false;
  }

  double get _minimumResponsiveColumnWidth => columnWidth ?? minColumnWidth;

  int _resolveColumnCount(double available, double gap) =>
      ((available + gap) / (_minimumResponsiveColumnWidth + gap)).floor().clamp(
        1,
        columns,
      );

  double _resolveColumnWidth(double available, double gap, int count) {
    if (columnWidth case final width?) return width;
    final calculated = (available - gap * (count - 1)) / count;
    return calculated.clamp(minColumnWidth, maxColumnWidth ?? double.infinity);
  }

  double _resolveItemWidth(AppDescriptionItem item, double calculatedWidth) {
    if (item.width case final width?) return width;
    return calculatedWidth.clamp(
      item.minWidth ?? 0,
      item.maxWidth ?? double.infinity,
    );
  }

  Widget _buildPlainContent(
    BuildContext context,
    double available,
    int count,
    AppDescriptionsTheme style,
  ) {
    final gap = style.spacing!;
    final columnWidth = _resolveColumnWidth(available, gap, count);
    final syncValueHeight = _syncValueHeightWithInlineEdit;
    return Wrap(
      spacing: gap,
      runSpacing: style.runSpacing!,
      children: [
        for (final item in items)
          SizedBox(
            width: item._isDivider
                ? available
                : _resolveItemWidth(
                    item,
                    columnWidth * item.span.clamp(1, count) +
                        gap * (item.span.clamp(1, count) - 1),
                  ),
            child: item._isDivider
                ? item.value
                : _buildItem(
                    context,
                    item,
                    style,
                    syncValueHeightWithInlineEdit: syncValueHeight,
                  ),
          ),
      ],
    );
  }

  Widget _buildDividedContent(
    BuildContext context,
    int count,
    shad.ThemeData theme,
    AppDescriptionsTheme style,
  ) {
    final sections = <Widget>[];
    final regularItems = <AppDescriptionItem>[];
    final syncValueHeight = _syncValueHeightWithInlineEdit;

    void flushRegularItems() {
      if (regularItems.isEmpty) return;
      final rows = <TableRow>[];
      for (var offset = 0; offset < regularItems.length; offset += count) {
        rows.add(
          TableRow(
            children: [
              for (var column = 0; column < count; column++)
                offset + column < regularItems.length
                    ? Padding(
                        padding: style.tableCellPadding!,
                        child: _buildItem(
                          context,
                          regularItems[offset + column],
                          style,
                          syncValueHeightWithInlineEdit: syncValueHeight,
                        ),
                      )
                    : const SizedBox.shrink(),
            ],
          ),
        );
      }
      sections.add(
        Table(
          defaultVerticalAlignment: TableCellVerticalAlignment.middle,
          border: TableBorder(
            horizontalInside: BorderSide(color: theme.colorScheme.border),
            verticalInside: BorderSide(color: theme.colorScheme.border),
          ),
          children: rows,
        ),
      );
      regularItems.clear();
    }

    for (final item in items) {
      if (item._isDivider) {
        flushRegularItems();
        sections.add(item.value);
      } else {
        regularItems.add(item);
      }
    }
    flushRegularItems();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: sections,
    );
  }

  @override
  Widget build(BuildContext context) {
    assert(
      type != AppDescriptionsType.table ||
          items.every(
            (item) =>
                item._isDivider ||
                (item.span == 1 &&
                    item.width == null &&
                    item.minWidth == null &&
                    item.maxWidth == null),
          ),
      'AppDescriptions table mode does not support item spans or width '
      'constraints. Use span: 1 with null width constraints, or switch to '
      'standard mode.',
    );
    final theme = shad.Theme.of(context);
    final style = _resolvedTheme(context);
    Widget content;
    if (customChild case final child?) {
      Widget customContent = DefaultTextStyle.merge(
        style: style.valueStyle!,
        child: child,
      );
      if (style.controlMetrics case final metrics?) {
        customContent = AppControlMetricsScope(
          metrics: metrics,
          child: customContent,
        );
      }
      content = Padding(padding: style.padding!, child: customContent);
    } else {
      content = LayoutBuilder(
        builder: (context, constraints) {
          final available = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : minColumnWidth * columns;
          if (type == AppDescriptionsType.table) {
            return _buildDividedContent(
              context,
              _resolveColumnCount(available, style.spacing!),
              theme,
              style,
            );
          }
          final resolvedPadding = style.padding!.resolve(
            Directionality.of(context),
          );
          final contentWidth = (available - resolvedPadding.horizontal).clamp(
            0.0,
            available,
          );
          return Padding(
            padding: style.padding!,
            child: _buildPlainContent(
              context,
              contentWidth,
              _resolveColumnCount(contentWidth, style.spacing!),
              style,
            ),
          );
        },
      );
    }
    if (title != null || actions != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: style.headerPadding!,
            child: Row(
              children: [
                if (title != null)
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: style.titleStyle!,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (titleIcon != null) ...[
                            IconTheme.merge(
                              data: style.titleIconTheme!,
                              child: titleIcon!,
                            ),
                            SizedBox(width: style.titleGap),
                          ],
                          Flexible(child: title!),
                        ],
                      ),
                    ),
                  )
                else
                  const Spacer(),
                ?actions,
              ],
            ),
          ),
          if (type == AppDescriptionsType.table) ...[
            SizedBox(
              height: style.density == AppDensity.compact ? 8 : 14,
            ),
            SizedBox(
              height: 1,
              child: ColoredBox(color: theme.colorScheme.border),
            ),
          ],
          content,
        ],
      );
    }
    Widget result = content;
    if (bordered || type == AppDescriptionsType.table) {
      result = DecoratedBox(
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.border),
          borderRadius: BorderRadius.circular(theme.radiusMd),
        ),
        child: content,
      );
    }
    return Padding(padding: margin, child: result);
  }
}
