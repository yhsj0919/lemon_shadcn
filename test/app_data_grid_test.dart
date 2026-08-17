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
    expect(style.cellColorInReadOnlyState, Colors.transparent);
    expect(style.cellColorInEditState, baseColor);
  });

  testWidgets('data grid shows zebra stripes by default', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: AppDataGrid<_Row>.local(
              height: 180,
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

    final grid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
    final style = grid.configuration.style;
    expect(style.oddRowColor, isNotNull);
    expect(style.evenRowColor, isNotNull);
    expect(style.evenRowColor, isNot(style.oddRowColor));
    expect(style.cellColorInReadOnlyState, Colors.transparent);
  });

  testWidgets('selected row color stays independent from zebra stripes', (
    tester,
  ) async {
    const stripeColor = Color(0xfff1f5f9);
    const selectedColor = Color(0xffdbeafe);
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
              selectedRowColor: selectedColor,
              selectionMode: AppDataGridSelectionMode.multiple,
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
    expect(style.evenRowColor, stripeColor);
    expect(style.activatedColor, selectedColor);
    expect(style.rowCheckedColor, selectedColor);
    expect(style.activatedColor, isNot(style.evenRowColor));
  });

  testWidgets('neutral themes still get a distinct default selection color', (
    tester,
  ) async {
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
              selectionMode: AppDataGridSelectionMode.single,
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
    expect(style.activatedColor, const Color(0xffdbeafe));
    expect(style.activatedColor, isNot(style.evenRowColor));
    expect(style.activatedColor, isNot(style.rowHoveredColor));
  });

  testWidgets('row context menu builder opens at the row click position', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: AppDataGrid<_Row>.local(
              height: 180,
              rowContextMenuBuilder: _rowMenu,
              columns: [
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: [_Row(1, 'Ada')],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final grid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
    final row = grid.rows.first;
    final cell = row.cells.values.first;
    grid.onRowSecondaryTap!(
      TrinaGridOnRowSecondaryTapEvent(
        row: row,
        rowIdx: 0,
        cell: cell,
        offset: const Offset(40, 40),
      ),
    );
    await tester.pump();

    expect(find.text('编辑行 Ada'), findsOneWidget);
  });

  testWidgets('row double tap exposes the business row', (tester) async {
    _Row? doubleTappedRow;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: AppDataGrid<_Row>.local(
              height: 180,
              onRowDoubleTap: (row) => doubleTappedRow = row,
              columns: const [
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: const [_Row(1, 'Ada')],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final grid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
    final row = grid.rows.first;
    final cell = row.cells.values.first;
    grid.onRowDoubleTap!(
      TrinaGridOnRowDoubleTapEvent(
        row: row,
        rowIdx: 0,
        cell: cell,
      ),
    );

    expect(doubleTappedRow?.name, 'Ada');
  });

  testWidgets('reorderable rows use Trina drag-compatible runtime types', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            child: AppDataGrid<_Row>.local(
              height: 180,
              reorderableRows: true,
              onRowsReordered: (_, _) {},
              columns: const [
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: const [_Row(1, 'Ada'), _Row(2, 'Linus')],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final rows = tester.widget<TrinaGrid>(find.byType(TrinaGrid)).rows;
    expect(rows, isA<List<TrinaRow<dynamic>>>());
    expect(rows, everyElement(isA<TrinaRow<dynamic>>()));
  });

  testWidgets('grid-wide fill mode applies to every default column', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 500,
            child: AppDataGrid<_Row>.local(
              height: 180,
              columnWidthMode: AppDataGridColumnWidthMode.fill,
              columns: [
                AppDataGridColumn(id: 'id', title: 'ID', value: _rowId),
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: [_Row(1, 'Ada')],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final grid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
    expect(grid.configuration.columnSize.autoSizeMode, TrinaAutoSizeMode.scale);
    expect(grid.configuration.scrollbar.showHorizontal, isFalse);
    expect(grid.configuration.scrollbar.showVertical, isFalse);
    expect(grid.configuration.scrollbar.columnShowScrollWidth, isFalse);
    expect(
      grid.columns.map((column) => column.suppressedAutoSize),
      everyElement(isFalse),
    );
    expect(
      grid.columns.fold<double>(0, (width, column) => width + column.width),
      greaterThan(490),
    );
  });

  testWidgets('individual column width modes override the grid default', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 600,
            child: AppDataGrid<_Row>.local(
              height: 180,
              columnWidthMode: AppDataGridColumnWidthMode.fixed,
              columns: [
                AppDataGridColumn(
                  id: 'id',
                  title: 'ID',
                  value: _rowId,
                  width: 100,
                ),
                AppDataGridColumn(
                  id: 'name',
                  title: 'Name',
                  value: _name,
                  widthMode: AppDataGridColumnWidthMode.content,
                ),
                AppDataGridColumn(
                  id: 'notes',
                  title: 'Notes',
                  value: _name,
                  widthMode: AppDataGridColumnWidthMode.fill,
                  flex: 2,
                ),
              ],
              rows: [_Row(1, 'A considerably longer cell value')],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final columns = {
      for (final column
          in tester.widget<TrinaGrid>(find.byType(TrinaGrid)).columns)
        column.field: column,
    };
    expect(columns['id']!.suppressedAutoSize, isTrue);
    expect(columns['id']!.width, 100);
    expect(columns['name']!.suppressedAutoSize, isTrue);
    expect(
      tester.getSize(find.text('A considerably longer cell value')).width,
      greaterThan(160),
    );
    expect(columns['notes']!.suppressedAutoSize, isFalse);
  });

  testWidgets('null height fills bounded parent constraints', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 420,
            height: 260,
            child: AppDataGrid<_Row>.local(
              height: null,
              columns: [
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: [_Row(1, 'Ada')],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(TrinaGrid)).height, 260);
  });

  testWidgets('horizontal and vertical scrollbars are overlay layers', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 180,
            height: 140,
            child: AppDataGrid<_Row>.local(
              height: null,
              columns: [
                AppDataGridColumn(id: 'id', title: 'ID', value: _rowId),
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rows: [
                _Row(1, 'One'),
                _Row(2, 'Two'),
                _Row(3, 'Three'),
                _Row(4, 'Four'),
              ],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final grid = tester.widget<TrinaGrid>(find.byType(TrinaGrid));
    expect(grid.configuration.scrollbar.showHorizontal, isFalse);
    expect(grid.configuration.scrollbar.showVertical, isFalse);
    expect(find.byType(RawScrollbar), findsNWidgets(2));
    expect(tester.getSize(find.byType(TrinaGrid)), const Size(180, 140));
  });

  testWidgets('shrinkWrap derives height from rendered header and rows', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            dataGrid: const AppDataGridMetrics(
              rowHeight: 38,
              columnHeight: 42,
              filterHeight: 46,
            ),
          ),
        ),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 120,
            child: AppDataGrid<_Row>.local(
              height: 999,
              shrinkWrap: true,
              showFilters: true,
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

    expect(tester.getSize(find.byType(TrinaGrid)).height, 173);
    expect(
      tester.getBottomLeft(find.text('Linus')).dy,
      lessThan(tester.getBottomLeft(find.byType(TrinaGrid)).dy),
    );
  });

  testWidgets('paginated shrinkWrap follows the loaded page row count', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 800,
            child: AppDataGrid<_Row>.paginated(
              shrinkWrap: true,
              loader: (_) async => const AppDataGridPage(
                items: [_Row(1, 'Ada'), _Row(2, 'Linus')],
                total: 2,
              ),
              columns: const [
                AppDataGridColumn(id: 'name', title: 'Name', value: _name),
              ],
              rowKey: _rowId,
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.getSize(find.byType(TrinaGrid)).height, greaterThan(150));
  });
}

String _name(_Row row) => row.name;

List<shad.MenuItem> _rowMenu(BuildContext context, _Row row, int rowIndex) => [
  AppMenuButton(onPressed: (_) {}, child: Text('编辑行 ${row.name}')),
  const AppMenuDivider(),
];

int _rowId(_Row row) => row.id;

class _Row {
  const _Row(this.id, this.name);

  final int id;
  final String name;
}
