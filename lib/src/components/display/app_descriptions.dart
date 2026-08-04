import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

enum AppDescriptionLayout { vertical, horizontal }

enum AppDescriptionsType { standard, table }

class AppDescriptionItem {
  const AppDescriptionItem({
    required this.label,
    required this.value,
    this.icon,
    this.span = 1,
  }) : assert(span > 0);

  final Widget label;
  final Widget value;
  final Widget? icon;
  final int span;
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
    this.labelWidth = 96,
    this.spacing = 16,
    this.runSpacing = 16,
    this.bordered = false,
    this.type = AppDescriptionsType.standard,
    this.padding = const EdgeInsets.all(16),
  }) : assert(columns > 0),
       assert(minColumnWidth > 0);

  final List<AppDescriptionItem> items;
  final Widget? title;
  final Widget? actions;
  final int columns;
  final double minColumnWidth;
  final AppDescriptionLayout layout;
  final double labelWidth;
  final double spacing;
  final double runSpacing;
  final bool bordered;
  final AppDescriptionsType type;
  final EdgeInsetsGeometry padding;

  Widget _buildItem(BuildContext context, AppDescriptionItem item) {
    final theme = shad.Theme.of(context);
    final label = IconTheme.merge(
      data: IconThemeData(size: 16, color: theme.colorScheme.mutedForeground),
      child: DefaultTextStyle.merge(
        style: TextStyle(
          fontSize: 13,
          color: theme.colorScheme.mutedForeground,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (item.icon != null) ...[item.icon!, const SizedBox(width: 6)],
            Flexible(child: item.label),
          ],
        ),
      ),
    );
    final value = DefaultTextStyle.merge(
      style: const TextStyle(fontSize: 14),
      child: item.value,
    );
    if (layout == AppDescriptionLayout.horizontal) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: labelWidth, child: label),
          const SizedBox(width: 8),
          Expanded(child: value),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [label, const SizedBox(height: 4), value],
    );
  }

  int _resolveColumnCount(double available) {
    final responsiveColumns =
        ((available + spacing) / (minColumnWidth + spacing)).floor();
    return responsiveColumns.clamp(1, columns);
  }

  Widget _buildPlainContent(BuildContext context, double available, int count) {
    final columnWidth = (available - spacing * (count - 1)) / count;
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: [
        for (final item in items)
          SizedBox(
            width:
                columnWidth * item.span.clamp(1, count) +
                spacing * (item.span.clamp(1, count) - 1),
            child: _buildItem(context, item),
          ),
      ],
    );
  }

  Widget _buildDividedContent(
    BuildContext context,
    int count,
    shad.ThemeData theme,
  ) {
    final rows = <TableRow>[];
    for (var offset = 0; offset < items.length; offset += count) {
      final cells = <Widget>[];
      for (var column = 0; column < count; column++) {
        final index = offset + column;
        cells.add(
          index < items.length
              ? Padding(
                  padding: padding,
                  child: _buildItem(context, items[index]),
                )
              : const SizedBox.shrink(),
        );
      }
      rows.add(TableRow(children: cells));
    }
    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
      border: TableBorder(
        horizontalInside: BorderSide(color: theme.colorScheme.border, width: 1),
        verticalInside: BorderSide(color: theme.colorScheme.border, width: 1),
      ),
      children: rows,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final available = constraints.hasBoundedWidth
            ? constraints.maxWidth
            : minColumnWidth * columns;
        if (type == AppDescriptionsType.table) {
          final count = _resolveColumnCount(available);
          return _buildDividedContent(context, count, theme);
        }
        final resolvedPadding = padding.resolve(Directionality.of(context));
        final contentWidth = (available - resolvedPadding.horizontal).clamp(
          0.0,
          available,
        );
        final count = _resolveColumnCount(contentWidth);
        return Padding(
          padding: padding,
          child: _buildPlainContent(context, contentWidth, count),
        );
      },
    );
    if (title != null || actions != null) {
      content = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                if (title != null)
                  Expanded(
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
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
            const SizedBox(height: 14),
            SizedBox(
              height: 1,
              child: ColoredBox(color: theme.colorScheme.border),
            ),
          ],
          content,
        ],
      );
    }
    if (!bordered && type != AppDescriptionsType.table) return content;
    return DecoratedBox(
      decoration: BoxDecoration(
        border: Border.all(color: theme.colorScheme.border, width: 1),
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: content,
    );
  }
}
