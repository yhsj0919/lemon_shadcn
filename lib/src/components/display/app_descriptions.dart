import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_theme_config.dart';

enum AppDescriptionLayout { vertical, horizontal }

enum AppDescriptionsType { standard, table }

/// Controls the whitespace used by [AppDescriptions].
enum AppDescriptionsDensity { standard, compact }

/// Component-level visual overrides for [AppDescriptions].
///
/// Apply it to a subtree with `ComponentTheme<AppDescriptionsTheme>`.
class AppDescriptionsTheme extends shad.ComponentThemeData {
  const AppDescriptionsTheme({
    this.density,
    this.labelStyle,
    this.valueStyle,
    this.titleStyle,
    this.labelIconTheme,
    this.labelAlignment,
    this.padding,
    this.tableCellPadding,
    this.spacing,
    this.runSpacing,
    this.labelGap,
    this.contentGap,
    this.headerPadding,
    this.controlMetrics,
  });

  const AppDescriptionsTheme.compact({
    this.labelStyle,
    this.valueStyle,
    this.titleStyle,
    this.labelIconTheme,
    this.labelAlignment,
  }) : density = AppDescriptionsDensity.compact,
       padding = null,
       tableCellPadding = null,
       spacing = null,
       runSpacing = null,
       labelGap = null,
       contentGap = null,
       headerPadding = null,
       controlMetrics = null;

  final AppDescriptionsDensity? density;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? titleStyle;
  final IconThemeData? labelIconTheme;
  final AlignmentGeometry? labelAlignment;
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
    this.labelAlignment,
    this.valueWidth,
    this.valueAlignment = AlignmentDirectional.topStart,
  }) : assert(span > 0),
       assert(valueWidth == null || valueWidth > 0);

  final Widget label;
  final Widget value;
  final Widget? icon;
  final int span;

  /// Alignment of this item's complete label, including its optional icon.
  final AlignmentGeometry? labelAlignment;

  /// Optional width for controls such as fields that would otherwise fill a cell.
  final double? valueWidth;
  final AlignmentGeometry valueAlignment;
}

/// Responsive key-value details for entity and record pages.
class AppDescriptions extends StatelessWidget {
  const AppDescriptions({
    super.key,
    required this.items,
    this.title,
    this.actions,
    this.columns = 3,
    this.minColumnWidth = 220,
    this.layout = AppDescriptionLayout.vertical,
    this.labelWidth = 80,
    this.density,
    this.labelStyle,
    this.valueStyle,
    this.titleStyle,
    this.labelIconTheme,
    this.labelAlignment,
    this.spacing,
    this.runSpacing,
    this.labelGap,
    this.contentGap,
    this.bordered = false,
    this.type = AppDescriptionsType.standard,
    this.padding,
    this.tableCellPadding,
    this.headerPadding,
    this.controlMetrics,
    this.margin = EdgeInsets.zero,
  }) : customChild = null,
       assert(columns > 0),
       assert(minColumnWidth > 0);

  /// A descriptions surface with a fully custom body.
  ///
  /// [title] and [actions] keep the standard header layout, while [child]
  /// replaces the responsive label/value grid completely.
  const AppDescriptions.custom({
    super.key,
    required Widget child,
    this.title,
    this.actions,
    this.density,
    this.valueStyle,
    this.titleStyle,
    this.padding,
    this.headerPadding,
    this.controlMetrics,
    this.bordered = false,
    this.margin = EdgeInsets.zero,
  }) : items = const [],
       customChild = child,
       columns = 1,
       minColumnWidth = 1,
       layout = AppDescriptionLayout.vertical,
       labelWidth = 80,
       labelStyle = null,
       labelIconTheme = null,
       labelAlignment = null,
       spacing = null,
       runSpacing = null,
       labelGap = null,
       contentGap = null,
       type = AppDescriptionsType.standard,
       tableCellPadding = null;

  final List<AppDescriptionItem> items;
  final Widget? customChild;
  final Widget? title;
  final Widget? actions;
  final int columns;
  final double minColumnWidth;
  final AppDescriptionLayout layout;
  final double labelWidth;
  final AppDescriptionsDensity? density;
  final TextStyle? labelStyle;
  final TextStyle? valueStyle;
  final TextStyle? titleStyle;
  final IconThemeData? labelIconTheme;
  final AlignmentGeometry? labelAlignment;
  final double? spacing;
  final double? runSpacing;
  final double? labelGap;
  final double? contentGap;
  final bool bordered;
  final AppDescriptionsType type;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? tableCellPadding;
  final EdgeInsetsGeometry? headerPadding;
  final AppControlMetrics? controlMetrics;
  final EdgeInsetsGeometry margin;

  AppDescriptionsTheme _resolvedTheme(BuildContext context) {
    final shadTheme = shad.Theme.of(context);
    final local = shad.ComponentTheme.maybeOf<AppDescriptionsTheme>(context);
    final effectiveDensity =
        density ?? local?.density ?? AppDescriptionsDensity.standard;
    final compact = effectiveDensity == AppDescriptionsDensity.compact;
    return AppDescriptionsTheme(
      density: effectiveDensity,
      labelStyle: TextStyle(
        fontSize: compact ? 12 : 13,
        color: shadTheme.colorScheme.mutedForeground,
      ).merge(local?.labelStyle).merge(labelStyle),
      valueStyle: TextStyle(
        fontSize: compact ? 13 : 14,
      ).merge(local?.valueStyle).merge(valueStyle),
      titleStyle: TextStyle(
        fontSize: compact ? 14 : 16,
        fontWeight: FontWeight.w600,
      ).merge(local?.titleStyle).merge(titleStyle),
      labelIconTheme: IconThemeData(
        size: compact ? 14 : 16,
        color: shadTheme.colorScheme.mutedForeground,
      ).merge(local?.labelIconTheme).merge(labelIconTheme),
      labelAlignment:
          labelAlignment ??
          local?.labelAlignment ??
          AlignmentDirectional.centerStart,
      padding: padding ?? local?.padding ?? EdgeInsets.all(compact ? 8 : 12),
      tableCellPadding:
          tableCellPadding ??
          local?.tableCellPadding ??
          EdgeInsets.symmetric(
            horizontal: compact ? 8 : 12,
            vertical: compact ? 0 : 8,
          ),
      spacing: spacing ?? local?.spacing ?? 12,
      runSpacing: runSpacing ?? local?.runSpacing ?? 8,
      labelGap: labelGap ?? local?.labelGap ?? (compact ? 4 : 8),
      contentGap: contentGap ?? local?.contentGap ?? (compact ? 2 : 4),
      headerPadding:
          headerPadding ??
          local?.headerPadding ??
          EdgeInsets.fromLTRB(
            compact ? 10 : 16,
            compact ? 9 : 14,
            compact ? 10 : 16,
            0,
          ),
      controlMetrics:
          controlMetrics ??
          local?.controlMetrics ??
          (compact
              ? const AppControlMetrics(
                  height: 26,
                  buttonHeight: 26,
                  horizontalPadding: 8,
                  fontSize: 13,
                  iconSize: 14,
                  contentGap: 6,
                )
              : null),
    );
  }

  Widget _buildItem(
    BuildContext context,
    AppDescriptionItem item,
    AppDescriptionsTheme style,
  ) {
    final resolvedLabelAlignment =
        (item.labelAlignment ?? style.labelAlignment!).resolve(
          Directionality.of(context),
        );
    final label = Align(
      alignment: resolvedLabelAlignment,
      child: IconTheme.merge(
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
      ),
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
    }
    // Align supplies loose constraints to intrinsic controls (notably buttons),
    // while the outer item can still occupy its responsive grid cell.
    value = Align(
      alignment: item.valueAlignment,
      widthFactor: layout == AppDescriptionLayout.vertical ? 1 : null,
      child: value,
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

  int _resolveColumnCount(double available, double gap) =>
      ((available + gap) / (minColumnWidth + gap)).floor().clamp(1, columns);

  Widget _buildPlainContent(
    BuildContext context,
    double available,
    int count,
    AppDescriptionsTheme style,
  ) {
    final gap = style.spacing!;
    final columnWidth = (available - gap * (count - 1)) / count;
    return Wrap(
      spacing: gap,
      runSpacing: style.runSpacing!,
      children: [
        for (final item in items)
          SizedBox(
            width:
                columnWidth * item.span.clamp(1, count) +
                gap * (item.span.clamp(1, count) - 1),
            child: _buildItem(context, item, style),
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
    final rows = <TableRow>[];
    for (var offset = 0; offset < items.length; offset += count) {
      rows.add(
        TableRow(
          children: [
            for (var column = 0; column < count; column++)
              offset + column < items.length
                  ? Padding(
                      padding: style.tableCellPadding!,
                      child: _buildItem(context, items[offset + column], style),
                    )
                  : const SizedBox.shrink(),
          ],
        ),
      );
    }
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.colorScheme.border),
        verticalInside: BorderSide(color: theme.colorScheme.border),
      ),
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
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
                      child: title!,
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
              height: style.density == AppDescriptionsDensity.compact ? 8 : 14,
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
