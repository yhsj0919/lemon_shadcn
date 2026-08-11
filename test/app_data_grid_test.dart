import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;
import 'package:trina_grid/trina_grid.dart';

void main() {
  testWidgets('data grid derives shared dimensions and typography from theme', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            dataGrid: const AppDataGridMetrics(
              rowHeight: 38,
              columnHeight: 38,
              horizontalPadding: 15,
            ),
          ),
        ),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: AppDataGrid<_Row>.local(
              height: 180,
              columns: const [
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: const [_Row(1, 'Ada')],
              rowKey: (row) => row.id,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final grid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
    final style = grid.configuration.style;
    expect(style.rowHeight, 38);
    expect(style.columnHeight, 38);
    expect(
      style.defaultCellPadding,
      const EdgeInsets.symmetric(horizontal: 15),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('sortable feedback uses the active popover surface', (
    tester,
  ) async {
    late Color expected;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(themeMode: AppThemeMode.dark),
        ),
        home: AppSortableDragFeedback(
          child: Builder(
            builder: (context) {
              expected = shad.Theme.of(context).colorScheme.popover;
              return const Text('Dragging');
            },
          ),
        ),
      ),
    );

    final feedback = find.byType(AppSortableDragFeedback);
    final surface = tester.widget<material.Material>(
      find.descendant(of: feedback, matching: find.byType(material.Material)),
    );
    expect(surface.color, expected);
  });

  testWidgets('data grid falls back to dark theme foreground colors', (
    tester,
  ) async {
    late Color expectedForeground;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(themeMode: AppThemeMode.dark),
        ),
        home: Builder(
          builder: (context) {
            expectedForeground = shad.Theme.of(context).colorScheme.foreground;
            return const SizedBox(
              width: 420,
              child: AppDataGrid<_Row>.local(
                height: 180,
                columns: [
                  AppDataGridColumn(id: 'name', title: 'Name', value: _name),
                ],
                rows: [_Row(1, 'Ada')],
                rowKey: _rowId,
              ),
            );
          },
        ),
      ),
    );
    await tester.pump();

    final style = tester
        .widget<TrinaGrid>(find.byType(TrinaGrid))
        .configuration
        .style;
    expect(style.columnTextStyle.color, expectedForeground);
    expect(style.cellTextStyle.color, expectedForeground);
  });

  testWidgets('data grid supports fully borderless style and typography', (
    tester,
  ) async {
    const headerBackground = Color(0xff312e81);
    const headerForeground = Color(0xffeef2ff);
    const cellBackground = Color(0xfffffbeb);
    const cellForeground = Color(0xff451a03);
    const firstRowBackground = Color(0xffecfccb);
    final resolvedRows = <int>[];

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: AppDataGrid<_Row>.local(
              height: 180,
              showBorder: false,
              showInternalDividers: false,
              textStyle: const TextStyle(fontSize: 13, letterSpacing: .2),
              headerTextStyle: const TextStyle(fontWeight: FontWeight.w700),
              cellTextStyle: const TextStyle(fontWeight: FontWeight.w500),
              headerBackgroundColor: headerBackground,
              headerForegroundColor: headerForeground,
              cellBackgroundColor: cellBackground,
              cellForegroundColor: cellForeground,
              rowBackgroundColor: (row) {
                resolvedRows.add(row.id);
                return row.id == 1 ? firstRowBackground : null;
              },
              columns: const [
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: const [_Row(1, 'Ada')],
              rowKey: (row) => row.id,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final grid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
    final style = grid.configuration.style;
    expect(style.enableColumnBorderVertical, isFalse);
    expect(style.enableColumnBorderHorizontal, isFalse);
    expect(style.enableCellBorderVertical, isFalse);
    expect(style.enableCellBorderHorizontal, isFalse);
    expect(style.cellVerticalBorderWidth, 0);
    expect(style.cellHorizontalBorderWidth, 0);
    expect(style.gridBorderWidth, 0);
    expect(style.gridBorderColor, material.Colors.transparent);
    expect(style.rowColor, cellBackground);
    expect(style.gridBackgroundColor, cellBackground);
    expect(style.columnTextStyle.color, headerForeground);
    expect(style.cellTextStyle.color, cellForeground);
    expect(style.columnTextStyle.fontSize, 13);
    expect(style.columnTextStyle.letterSpacing, .2);
    expect(style.columnTextStyle.fontWeight, FontWeight.w700);
    expect(style.cellTextStyle.fontSize, 13);
    expect(style.cellTextStyle.letterSpacing, .2);
    expect(style.cellTextStyle.fontWeight, FontWeight.w500);
    expect(grid.rowColorCallback, isNotNull);
    expect(resolvedRows, contains(1));
    expect(
      tester
          .widgetList<DecoratedBox>(
            find.ancestor(
              of: find.text('Name'),
              matching: find.byType(DecoratedBox),
            ),
          )
          .map((widget) => widget.decoration)
          .whereType<BoxDecoration>()
          .any((decoration) => decoration.color == headerBackground),
      isTrue,
    );
  });

  testWidgets('data grid supports configurable zebra stripes', (tester) async {
    const baseColor = Color(0xffffffff);
    const stripeColor = Color(0xfff1f5f9);
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: AppDataGrid<_Row>.local(
              height: 180,
              striped: true,
              stripeColor: stripeColor,
              cellBackgroundColor: baseColor,
              columns: [
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: [_Row(1, 'Ada'), _Row(2, 'Linus')],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final style = tester
        .widget<TrinaGrid>(find.byType(TrinaGrid))
        .configuration
        .style;
    expect(style.oddRowColor, baseColor);
    expect(style.evenRowColor, stripeColor);
  });
}

String _name(_Row row) => row.name;

int _rowId(_Row row) => row.id;

class _Row {
  const _Row(this.id, this.name);

  final int id;
  final String name;
}
