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

  testWidgets('AppTable supports fixed, fill, and content heights', (
    tester,
  ) async {
    const rows = [
      AppTableRow(cells: [AppTableCell(child: Text('Cell'))]),
    ];

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: AppTable(height: 180, rows: rows),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AppTable)).height, 180);

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 300,
            height: 220,
            child: AppTable(fillHeight: true, rows: rows),
          ),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AppTable)).height, 220);

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: AppTable(rows: rows),
        ),
      ),
    );
    expect(tester.getSize(find.byType(AppTable)).height, 40);
  });

  testWidgets('AppTable stripeColor matches DataGrid row ordering', (
    tester,
  ) async {
    const base = Color(0xffffffff);
    const stripe = Color(0xffeef2ff);
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppTable(
          striped: true,
          stripeColor: stripe,
          backgroundColor: base,
          rows: [
            AppTableRow(cells: [AppTableCell(child: Text('First'))]),
            AppTableRow(cells: [AppTableCell(child: Text('Second'))]),
          ],
        ),
      ),
    );

    Color cellColor(String text) => tester
        .widget<ColoredBox>(
          find
              .ancestor(of: find.text(text), matching: find.byType(ColoredBox))
              .first,
        )
        .color;

    expect(cellColor('First'), base);
    expect(cellColor('Second'), stripe);
  });
}
