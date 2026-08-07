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

  testWidgets('data grid supports borderless internals and split colors', (
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
              showInternalDividers: false,
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
    expect(style.rowColor, cellBackground);
    expect(style.gridBackgroundColor, cellBackground);
    expect(style.columnTextStyle.color, headerForeground);
    expect(style.cellTextStyle.color, cellForeground);
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
}

String _name(_Row row) => row.name;

class _Row {
  const _Row(this.id, this.name);

  final int id;
  final String name;
}
