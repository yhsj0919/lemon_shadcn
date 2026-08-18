import 'package:flutter/widgets.dart';

/// A lazily-built responsive grid.
class AppGrid extends StatelessWidget {
  const AppGrid.builder({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
    this.minItemWidth = 160,
    this.maxColumns,
    this.itemHeight,
    this.aspectRatio = 1,
    this.spacing = 0,
    this.runSpacing = 0,
    this.padding,
    this.controller,
    this.shrinkWrap = false,
    this.physics,
  }) : assert(minItemWidth > 0),
       assert(maxColumns == null || maxColumns > 0),
       assert(itemHeight == null || itemHeight > 0),
       assert(aspectRatio > 0);

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double minItemWidth;
  final int? maxColumns;
  final double? itemHeight;
  final double aspectRatio;
  final double spacing;
  final double runSpacing;
  final EdgeInsetsGeometry? padding;
  final ScrollController? controller;
  final bool shrinkWrap;
  final ScrollPhysics? physics;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : minItemWidth;
        final columns = (availableWidth / (minItemWidth + spacing))
            .floor()
            .clamp(1, maxColumns ?? 0x7fffffff);
        final itemWidth =
            (availableWidth - spacing * (columns - 1)) / columns;

        return GridView.builder(
          padding: padding,
          controller: controller,
          shrinkWrap: shrinkWrap,
          physics: physics,
          itemCount: itemCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            mainAxisExtent: itemHeight,
            childAspectRatio: itemHeight == null
                ? itemWidth / (itemWidth / aspectRatio)
                : 1,
          ),
          itemBuilder: itemBuilder,
        );
      },
    );
  }
}
