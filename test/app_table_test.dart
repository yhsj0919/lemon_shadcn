import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('AppTable shares DataGrid metrics and can hide dividers', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            dataGrid: const AppDataGridMetrics(
              rowHeight: 38,
              columnHeight: 42,
              horizontalPadding: 15,
            ),
          ),
        ),
        home: const AppTable(
          showInternalDividers: false,
          rows: [
            AppTableHeader(cells: [AppTableCell(child: Text('Header'))]),
            AppTableRow(cells: [AppTableCell(child: Text('Cell'))]),
          ],
        ),
      ),
    );

    final table = tester.widget<Table>(find.byType(Table));
    expect(table.border, isNull);
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 42,
      ),
      findsOneWidget,
    );
    expect(
      find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 38,
      ),
      findsOneWidget,
    );
  });

  testWidgets('AppTable builder supports custom header, rows, and cells', (
    tester,
  ) async {
    var builds = 0;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppTable.builder(
          rowCount: 2,
          striped: true,
          headerBuilder: (_) => const AppTableHeader(
            backgroundColor: Color(0xFF112233),
            cells: [AppTableCell(child: Text('Name'))],
          ),
          rowBuilder: (_, index) {
            builds++;
            return AppTableRow(
              cells: [
                AppTableCell(
                  foregroundColor: const Color(0xFF00AA00),
                  child: Text('Row $index'),
                ),
              ],
            );
          },
        ),
      ),
    );

    expect(builds, 2);
    expect(find.text('Name'), findsOneWidget);
    expect(find.text('Row 0'), findsOneWidget);
    expect(find.text('Row 1'), findsOneWidget);
  });

  testWidgets('AppTable paints its outer border above cell backgrounds', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppTable(
          rows: [
            AppTableRow(
              backgroundColor: Color(0xFFFF0000),
              cells: [AppTableCell(child: Text('Cell'))],
            ),
          ],
        ),
      ),
    );

    final container = tester.widget<Container>(
      find
          .descendant(
            of: find.byType(AppTable),
            matching: find.byType(Container),
          )
          .first,
    );
    final foreground = container.foregroundDecoration! as BoxDecoration;
    expect(foreground.border, isNotNull);
  });
}
