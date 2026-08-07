import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';

typedef AppTableRowBuilder =
    AppTableRow Function(BuildContext context, int index);

typedef AppTableHeaderBuilder = AppTableHeader Function(BuildContext context);

typedef AppTableRowColor = Color? Function(int index, AppTableRow row);

@immutable
class AppTableCell {
  const AppTableCell({
    required this.child,
    this.alignment = Alignment.centerLeft,
    this.padding,
    this.backgroundColor,
    this.foregroundColor,
  });

  final Widget child;
  final AlignmentGeometry alignment;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

@immutable
class AppTableRow {
  const AppTableRow({
    required this.cells,
    this.height,
    this.backgroundColor,
    this.foregroundColor,
  });

  final List<AppTableCell> cells;
  final double? height;
  final Color? backgroundColor;
  final Color? foregroundColor;
}

class AppTableHeader extends AppTableRow {
  const AppTableHeader({
    required super.cells,
    super.height,
    super.backgroundColor,
    super.foregroundColor,
  });
}

class AppTableFooter extends AppTableRow {
  const AppTableFooter({
    required super.cells,
    super.height,
    super.backgroundColor,
    super.foregroundColor,
  });
}

/// A lightweight table that shares sizing and color rules with [AppDataGrid].
class AppTable extends StatelessWidget {
  const AppTable({
    super.key,
    required this.rows,
    this.columnWidths,
    this.defaultColumnWidth = const FlexColumnWidth(),
    this.defaultVerticalAlignment = TableCellVerticalAlignment.middle,
    this.rowHeight,
    this.headerHeight,
    this.cellPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.borderColor,
    this.borderRadius,
    this.showOuterBorder = true,
    this.showInternalDividers = true,
    this.striped = false,
    this.oddRowColor,
    this.evenRowColor,
    this.rowBackgroundColor,
    this.clipBehavior = Clip.antiAlias,
  }) : rowCount = null,
       rowBuilder = null,
       headerBuilder = null;

  const AppTable.builder({
    super.key,
    required int rowCount,
    required this.rowBuilder,
    this.headerBuilder,
    this.columnWidths,
    this.defaultColumnWidth = const FlexColumnWidth(),
    this.defaultVerticalAlignment = TableCellVerticalAlignment.middle,
    this.rowHeight,
    this.headerHeight,
    this.cellPadding,
    this.backgroundColor,
    this.foregroundColor,
    this.headerBackgroundColor,
    this.headerForegroundColor,
    this.borderColor,
    this.borderRadius,
    this.showOuterBorder = true,
    this.showInternalDividers = true,
    this.striped = false,
    this.oddRowColor,
    this.evenRowColor,
    this.rowBackgroundColor,
    this.clipBehavior = Clip.antiAlias,
  }) : assert(rowCount >= 0),
       rows = null,
       rowCount = rowCount,
       assert(rowBuilder != null);

  final List<AppTableRow>? rows;
  final int? rowCount;
  final AppTableRowBuilder? rowBuilder;
  final AppTableHeaderBuilder? headerBuilder;
  final Map<int, TableColumnWidth>? columnWidths;
  final TableColumnWidth defaultColumnWidth;
  final TableCellVerticalAlignment defaultVerticalAlignment;
  final double? rowHeight;
  final double? headerHeight;
  final EdgeInsetsGeometry? cellPadding;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? headerBackgroundColor;
  final Color? headerForegroundColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final bool showOuterBorder;
  final bool showInternalDividers;
  final bool striped;
  final Color? oddRowColor;
  final Color? evenRowColor;
  final AppTableRowColor? rowBackgroundColor;
  final Clip clipBehavior;

  List<AppTableRow> _resolveRows(BuildContext context) {
    if (rows != null) return rows!;
    return <AppTableRow>[
      if (headerBuilder case final builder?) builder(context),
      for (var index = 0; index < rowCount!; index++)
        rowBuilder!(context, index),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final colors = theme.colorScheme;
    final metrics =
        AppTheme.maybeOf(context)?.dataGrid ?? const AppDataGridMetrics();
    final resolvedRows = _resolveRows(context);
    final radius = borderRadius ?? BorderRadius.circular(theme.radiusMd);
    final side = BorderSide(color: borderColor ?? colors.border, width: 1);
    final padding =
        cellPadding ??
        EdgeInsets.symmetric(horizontal: metrics.horizontalPadding);
    final baseTextStyle = DefaultTextStyle.of(context).style.copyWith(
      fontSize: metrics.fontSize,
      color: foregroundColor ?? colors.foreground,
    );
    final maxCells = resolvedRows.fold<int>(
      0,
      (count, row) => row.cells.length > count ? row.cells.length : count,
    );
    var bodyIndex = 0;

    final tableRows = <TableRow>[];
    for (final row in resolvedRows) {
      final isHeader = row is AppTableHeader;
      final isFooter = row is AppTableFooter;
      final index = isHeader || isFooter ? -1 : bodyIndex++;
      final zebraColor = !striped || index < 0
          ? null
          : index.isEven
          ? (oddRowColor ?? colors.muted.withValues(alpha: .45))
          : (evenRowColor ?? backgroundColor ?? colors.background);
      final resolvedRowColor =
          row.backgroundColor ??
          (index >= 0 ? rowBackgroundColor?.call(index, row) : null) ??
          zebraColor ??
          (isHeader
              ? headerBackgroundColor
              : isFooter
              ? colors.muted.withValues(alpha: .45)
              : backgroundColor) ??
          colors.background;
      final resolvedRowForeground =
          row.foregroundColor ??
          (isHeader ? headerForegroundColor : foregroundColor) ??
          colors.foreground;
      final height =
          row.height ??
          (isHeader
              ? headerHeight ?? metrics.columnHeight
              : rowHeight ?? metrics.rowHeight);

      tableRows.add(
        TableRow(
          children: List<Widget>.generate(maxCells, (column) {
            final cell = column < row.cells.length ? row.cells[column] : null;
            final cellForeground =
                cell?.foregroundColor ?? resolvedRowForeground;
            return ColoredBox(
              color: cell?.backgroundColor ?? resolvedRowColor,
              child: SizedBox(
                height: height,
                child: Padding(
                  padding: cell?.padding ?? padding,
                  child: Align(
                    alignment: cell?.alignment ?? Alignment.centerLeft,
                    child: DefaultTextStyle.merge(
                      style: baseTextStyle.copyWith(
                        color: cellForeground,
                        fontWeight: isHeader ? FontWeight.w600 : null,
                      ),
                      child: IconTheme.merge(
                        data: IconThemeData(color: cellForeground),
                        child: cell?.child ?? const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      );
    }

    final content = Table(
      columnWidths: columnWidths,
      defaultColumnWidth: defaultColumnWidth,
      defaultVerticalAlignment: defaultVerticalAlignment,
      border: showInternalDividers
          ? TableBorder(horizontalInside: side, verticalInside: side)
          : null,
      children: tableRows,
    );

    return ClipRRect(
      borderRadius: radius,
      clipBehavior: clipBehavior,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor ?? colors.background,
          borderRadius: radius,
        ),
        // Paint the outline above cell backgrounds. A decoration behind the
        // table is covered by edge cells, which makes parts of the outline
        // disappear (most noticeably along the left and right edges).
        foregroundDecoration: BoxDecoration(
          border: showOuterBorder ? Border.fromBorderSide(side) : null,
          borderRadius: radius,
        ),
        child: content,
      ),
    );
  }
}
