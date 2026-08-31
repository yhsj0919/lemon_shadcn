import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

void main() {
  test('AppDescriptions accepts independently configurable spacing', () {
    const descriptions = AppDescriptions(
      items: [],
      padding: material.EdgeInsets.all(12),
      tableCellPadding: material.EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 8,
      ),
      margin: material.EdgeInsets.all(20),
    );

    expect(descriptions.padding, const material.EdgeInsets.all(12));
    expect(
      descriptions.tableCellPadding,
      const material.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
    expect(descriptions.margin, const material.EdgeInsets.all(20));
  });

  test('AppDescriptions uses the standard label width by default', () {
    const descriptions = AppDescriptions(items: []);
    expect(descriptions.labelWidth, 80);
  });

  test('AppDescriptions exposes fixed and maximum column widths', () {
    const fixed = AppDescriptions(items: [], columnWidth: 240);
    const limited = AppDescriptions(
      items: [],
      minColumnWidth: 180,
      maxColumnWidth: 280,
    );
    expect(fixed.columnWidth, 240);
    expect(limited.maxColumnWidth, 280);
  });

  testWidgets('compact theme changes typography and spacing', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: AppComponentTheme<AppDescriptionsTheme>(
            data: AppDescriptionsTheme.compact(
              labelStyle: material.TextStyle(color: material.Colors.purple),
            ),
            child: AppDescriptions(
              type: AppDescriptionsType.table,
              columns: 1,
              items: [
                AppDescriptionItem(
                  label: material.Text('Label'),
                  value: material.Text('Value'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final labelStyle = tester
        .widget<material.RichText>(
          find.descendant(
            of: find.text('Label'),
            matching: find.byType(material.RichText),
          ),
        )
        .text
        .style;
    expect(labelStyle?.fontSize, 12);
    expect(labelStyle?.color, material.Colors.purple);
    expect(
      tester
          .widgetList<material.Padding>(find.byType(material.Padding))
          .any(
            (widget) =>
                widget.padding ==
                const material.EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
      isTrue,
    );
  });

  testWidgets('button value keeps its intrinsic width', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.SizedBox(
          width: 500,
          child: AppDescriptions(
            columns: 1,
            layout: AppDescriptionLayout.horizontal,
            items: [
              AppDescriptionItem(
                label: const material.Text('Action'),
                value: material.TextButton(
                  onPressed: () {},
                  child: const material.Text('Edit'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(material.TextButton)).width,
      lessThan(200),
    );
  });

  testWidgets('standard layout defaults to 8 item run spacing', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.SizedBox(
          width: 300,
          child: AppDescriptions(
            columns: 1,
            items: [
              AppDescriptionItem(
                label: material.Text('First'),
                value: material.Text('One'),
              ),
              AppDescriptionItem(
                label: material.Text('Second'),
                value: material.Text('Two'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.widget<material.Wrap>(find.byType(material.Wrap)).runSpacing,
      8,
    );
  });

  testWidgets('divider item occupies a complete responsive row', (
    tester,
  ) async {
    const dividerKey = material.ValueKey('standard-divider');
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: material.SizedBox(
            width: 500,
            child: AppDescriptions(
              columns: 2,
              minColumnWidth: 100,
              items: [
                AppDescriptionItem(
                  label: material.Text('First'),
                  value: material.Text('One'),
                ),
                AppDescriptionItem.divider(
                  divider: material.SizedBox(
                    key: dividerKey,
                    height: 1,
                    child: material.ColoredBox(color: material.Colors.red),
                  ),
                ),
                AppDescriptionItem(
                  label: material.Text('Second'),
                  value: material.Text('Two'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(dividerKey)).width, 476);
    expect(
      tester.getTopLeft(find.byKey(dividerKey)).dy,
      greaterThan(tester.getBottomLeft(find.text('One')).dy),
    );
    expect(
      tester.getBottomLeft(find.byKey(dividerKey)).dy,
      lessThan(tester.getTopLeft(find.text('Second')).dy),
    );
  });

  testWidgets('divider item spans the full table width', (tester) async {
    const dividerKey = material.ValueKey('table-divider');
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: material.SizedBox(
            width: 500,
            child: AppDescriptions(
              type: AppDescriptionsType.table,
              columns: 2,
              items: [
                AppDescriptionItem(
                  label: material.Text('First'),
                  value: material.Text('One'),
                ),
                AppDescriptionItem.divider(
                  divider: material.SizedBox(
                    key: dividerKey,
                    height: 1,
                    child: material.ColoredBox(color: material.Colors.red),
                  ),
                ),
                AppDescriptionItem(
                  label: material.Text('Second'),
                  value: material.Text('Two'),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(dividerKey)).width, 500);
    expect(find.byType(material.Table), findsNWidgets(2));
  });

  testWidgets('custom item replaces item layout and honors span', (
    tester,
  ) async {
    const customKey = material.ValueKey('custom-item');
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: material.SizedBox(
            width: 500,
            child: AppDescriptions(
              columns: 2,
              minColumnWidth: 100,
              items: [
                AppDescriptionItem.custom(
                  span: 2,
                  child: material.SizedBox(
                    key: customKey,
                    width: double.infinity,
                    child: material.Text('自定义操作区'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byKey(customKey)).width, 476);
    expect(find.text('自定义操作区'), findsOneWidget);
    expect(find.byType(material.Column), findsNothing);
  });

  testWidgets('layout defaults to 12 horizontal item spacing', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.SizedBox(
          width: 500,
          child: AppDescriptions(
            columns: 2,
            minColumnWidth: 100,
            items: [
              AppDescriptionItem(
                label: material.Text('First'),
                value: material.Text('One'),
              ),
              AppDescriptionItem(
                label: material.Text('Second'),
                value: material.Text('Two'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.widget<material.Wrap>(find.byType(material.Wrap)).spacing,
      12,
    );
  });

  testWidgets('custom variant renders arbitrary body and header actions', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppDescriptions.custom(
          title: const material.Text('Device'),
          actions: material.IconButton(
            onPressed: () {},
            icon: const material.Icon(material.Icons.more_horiz),
          ),
          padding: const material.EdgeInsets.all(18),
          child: const material.Column(
            children: [
              material.Text('Custom body'),
              material.Text('Menu body'),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Device'), findsOneWidget);
    expect(find.byIcon(material.Icons.more_horiz), findsOneWidget);
    expect(find.text('Custom body'), findsOneWidget);
    expect(find.text('Menu body'), findsOneWidget);
    expect(find.byType(material.Wrap), findsNothing);
  });

  testWidgets('title icon renders before title with density-aware size', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppDescriptions(
          titleIcon: material.Icon(material.Icons.monitor),
          title: material.Text('Device'),
          items: [],
        ),
      ),
    );

    expect(find.byIcon(material.Icons.monitor), findsOneWidget);
    expect(find.text('Device'), findsOneWidget);
    expect(
      tester.widget<material.Icon>(find.byIcon(material.Icons.monitor)).size,
      isNull,
    );
    expect(
      material.IconTheme.of(
        tester.element(find.byIcon(material.Icons.monitor)),
      ).size,
      20,
    );
    expect(
      tester.getTopLeft(find.text('Device')).dx -
          tester.getTopRight(find.byIcon(material.Icons.monitor)).dx,
      closeTo(8, 0.01),
    );
  });

  testWidgets('item label alignment can be overridden directly', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.SizedBox(
          width: 300,
          child: AppDescriptions(
            columns: 1,
            layout: AppDescriptionLayout.horizontal,
            labelWidth: 100,
            padding: material.EdgeInsets.zero,
            items: [
              AppDescriptionItem(
                labelAlignment: material.Alignment.centerRight,
                label: material.Text('City'),
                value: material.Text('Jinan'),
              ),
            ],
          ),
        ),
      ),
    );

    final labelRight = tester.getTopRight(find.text('City')).dx;
    final valueLeft = tester.getTopLeft(find.text('Jinan')).dx;
    expect(valueLeft - labelRight, closeTo(8, 0.01));
  });

  testWidgets('descriptions applies one label alignment to all items', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.SizedBox(
          width: 300,
          child: AppDescriptions(
            columns: 1,
            layout: AppDescriptionLayout.horizontal,
            labelWidth: 100,
            labelAlignment: material.Alignment.centerRight,
            padding: material.EdgeInsets.zero,
            items: [
              AppDescriptionItem(
                label: material.Text('City'),
                value: material.Text('Jinan'),
              ),
              AppDescriptionItem(
                label: material.Text('Owner'),
                value: material.Text('Zhang'),
              ),
            ],
          ),
        ),
      ),
    );

    for (final pair in [('City', 'Jinan'), ('Owner', 'Zhang')]) {
      final labelRight = tester.getTopRight(find.text(pair.$1)).dx;
      final valueLeft = tester.getTopLeft(find.text(pair.$2)).dx;
      expect(valueLeft - labelRight, closeTo(8, 0.01));
    }
  });

  testWidgets('topStart aligns label to top of a multiline value', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.SizedBox(
          width: 300,
          child: AppDescriptions(
            columns: 1,
            layout: AppDescriptionLayout.horizontal,
            labelAlignment: material.AlignmentDirectional.topStart,
            padding: material.EdgeInsets.zero,
            items: [
              AppDescriptionItem(
                label: material.Text('Boot time'),
                value: material.Text('09:00-12:00\n09:00-12:00'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('Boot time')).dy,
      closeTo(
        tester.getTopLeft(find.text('09:00-12:00\n09:00-12:00')).dy,
        0.01,
      ),
    );
  });

  testWidgets('compact embedded controls and inline edit use local height', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.SizedBox(
          width: 600,
          child: AppDescriptions(
            density: AppDensity.compact,
            type: AppDescriptionsType.table,
            columns: 2,
            layout: AppDescriptionLayout.horizontal,
            items: [
              AppDescriptionItem(
                label: const material.Text('Name'),
                value: AppTextFormField(
                  name: 'compact-name',
                  initialValue: 'Lemon',
                ),
              ),
              AppDescriptionItem(
                label: const material.Text('Action'),
                value: AppButton.outline(
                  key: const material.ValueKey('compact-button'),
                  onPressed: () {},
                  child: const material.Text('Edit'),
                ),
              ),
              AppDescriptionItem(
                label: const material.Text('Owner'),
                value: AppInlineEdit.text(value: 'Zhang', onSaved: (_) {}),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppTextFormField)).height, 26);
    expect(
      tester
          .getSize(find.byKey(const material.ValueKey('compact-button')))
          .height,
      26,
    );
    expect(tester.getSize(find.byType(AppInlineEdit<String>)).height, 26);
    final editableStyles = tester
        .widgetList<material.EditableText>(find.byType(material.EditableText))
        .map((widget) => widget.style.fontSize);
    expect(editableStyles, everyElement(13));
    final buttonText = tester.widget<material.RichText>(
      find.descendant(
        of: find.byKey(const material.ValueKey('compact-button')),
        matching: find.byType(material.RichText),
      ),
    );
    expect(buttonText.text.style?.fontSize, 13);
    final labelCenter = tester.getCenter(find.text('Action')).dy;
    final controlCenter = tester
        .getCenter(find.byKey(const material.ValueKey('compact-button')))
        .dy;
    expect(labelCenter, closeTo(controlCenter, 0.01));
  });

  testWidgets('plain text stays content-sized without AppInlineEdit', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: AppDescriptions(
            columns: 1,
            padding: material.EdgeInsets.zero,
            items: [
              AppDescriptionItem(
                label: material.Text('名称'),
                value: material.Text('柠檬管理后台'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.ancestor(
        of: find.text('柠檬管理后台'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is material.ConstrainedBox &&
              widget.constraints.minHeight == 32,
        ),
      ),
      findsNothing,
    );
    expect(tester.getSize(find.text('柠檬管理后台')).height, lessThan(32));
  });

  testWidgets('mixed AppInlineEdit syncs plain text to control height', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.Align(
          alignment: material.Alignment.topLeft,
          child: AppDescriptions(
            columns: 1,
            padding: material.EdgeInsets.zero,
            items: [
              const AppDescriptionItem(
                label: material.Text('名称'),
                value: material.Text('柠檬管理后台'),
              ),
              AppDescriptionItem(
                label: const material.Text('负责人'),
                value: AppInlineEdit.text(value: '张明', onSaved: (_) {}),
              ),
            ],
          ),
        ),
      ),
    );

    final valueArea = find.ancestor(
      of: find.text('柠檬管理后台'),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is material.ConstrainedBox &&
            widget.constraints.minHeight == 32,
      ),
    );
    expect(tester.getSize(valueArea).height, 32);
    expect(tester.getSize(find.byType(AppInlineEdit<String>)).height, 32);
  });

  testWidgets('valueHeight can be overridden on the surface and item', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: AppDescriptions(
            columns: 1,
            padding: material.EdgeInsets.zero,
            valueHeight: 40,
            items: [
              AppDescriptionItem(
                label: material.Text('默认'),
                value: material.Text('表面高度'),
              ),
              AppDescriptionItem(
                label: material.Text('单项'),
                value: material.Text('单项高度'),
                valueHeight: 48,
              ),
            ],
          ),
        ),
      ),
    );

    Finder valueSlot(String text, double height) => find.ancestor(
      of: find.text(text),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is material.ConstrainedBox &&
            widget.constraints.minHeight == height,
      ),
    );

    expect(tester.getSize(valueSlot('表面高度', 40)).height, 40);
    expect(tester.getSize(valueSlot('单项高度', 48)).height, 48);
  });

  testWidgets('valueHeight null keeps the value content-sized', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: AppDescriptions(
            columns: 1,
            padding: material.EdgeInsets.zero,
            valueHeight: null,
            items: [
              AppDescriptionItem(
                label: material.Text('名称'),
                value: material.Text('内容高度'),
              ),
              AppDescriptionItem(
                label: material.Text('单项'),
                value: material.Text('单项内容'),
                valueHeight: null,
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      find.ancestor(
        of: find.text('内容高度'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is material.ConstrainedBox &&
              widget.constraints.minHeight == 32,
        ),
      ),
      findsNothing,
    );
    expect(
      tester.getSize(find.text('内容高度')).height,
      lessThan(32),
    );
    expect(
      find.ancestor(
        of: find.text('单项内容'),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is material.ConstrainedBox &&
              widget.constraints.minHeight > 0,
        ),
      ),
      findsNothing,
    );
  });

  testWidgets('table row stays compact with a form-height value', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: AppDescriptions(
            type: AppDescriptionsType.table,
            columns: 1,
            layout: AppDescriptionLayout.horizontal,
            items: [
              AppDescriptionItem(
                label: material.Text('名称'),
                value: material.SizedBox(height: 32, child: material.Text('值')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(material.Table)).height, 48);
  });

  testWidgets('table mode rejects unsupported item spans', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppDescriptions(
          type: AppDescriptionsType.table,
          items: [
            AppDescriptionItem(
              span: 2,
              label: material.Text('Wide'),
              value: material.Text('Value'),
            ),
          ],
        ),
      ),
    );
    expect(tester.takeException(), isAssertionError);
  });

  testWidgets('vertical multi-column items honor individual alignments', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: material.SizedBox(
            width: 600,
            child: AppDescriptions(
              columns: 3,
              minColumnWidth: 150,
              padding: material.EdgeInsets.zero,
              items: [
                AppDescriptionItem(
                  label: material.Text('Left label'),
                  value: material.Text('Left value'),
                ),
                AppDescriptionItem(
                  label: material.Text('Center label'),
                  value: material.Text('Center value'),
                  labelAlignment: material.Alignment.center,
                  valueAlignment: material.Alignment.center,
                ),
                AppDescriptionItem(
                  label: material.Text('Right label'),
                  value: material.Text('Right value'),
                  labelAlignment: material.Alignment.centerRight,
                  valueAlignment: material.Alignment.centerRight,
                ),
              ],
            ),
          ),
        ),
      ),
    );

    final centerLabel = tester.getCenter(find.text('Center label')).dx;
    final centerValue = tester.getCenter(find.text('Center value')).dx;
    expect(centerLabel, closeTo(300, 0.01));
    expect(centerValue, closeTo(300, 0.01));

    final rightLabel = tester.getTopRight(find.text('Right label')).dx;
    final rightValue = tester.getTopRight(find.text('Right value')).dx;
    expect(rightLabel, closeTo(600, 0.01));
    expect(rightValue, closeTo(600, 0.01));
  });

  testWidgets('header aligns with body and value controls stay intrinsic', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.SizedBox(
          width: 500,
          child: AppDescriptions(
            title: const material.Text('Device information'),
            columns: 1,
            items: [
              AppDescriptionItem(
                label: const material.Text('Status'),
                value: AppBadge.success(child: const material.Text('Online')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(
      tester.getTopLeft(find.text('Device information')).dx,
      closeTo(tester.getTopLeft(find.text('Status')).dx, 0.01),
    );
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: find.text('Online'),
                  matching: find.byType(material.IgnorePointer),
                )
                .first,
          )
          .width,
      lessThan(500),
    );
  });

  testWidgets('an item can enforce a minimum column width', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.SizedBox(
          width: 600,
          child: AppDescriptions(
            columns: 3,
            padding: material.EdgeInsets.zero,
            items: [
              AppDescriptionItem(
                minWidth: 280,
                label: material.Text('Custom width label'),
                value: material.Text('Custom width value'),
              ),
            ],
          ),
        ),
      ),
    );

    final item = find.ancestor(
      of: find.text('Custom width label'),
      matching: find.byType(material.SizedBox),
    );
    expect(
      tester.widgetList<material.SizedBox>(item).any((box) => box.width == 280),
      isTrue,
    );
  });

  testWidgets('descriptions follows globally scaled typography', (
    tester,
  ) async {
    final base = AppThemeConfig.standard();
    const scale = 12 / 14;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: base.copyWith(
            lightTheme: base.lightTheme.copyWith(
              typography: () => base.lightTheme.typography.scale(scale),
            ),
            darkTheme: base.darkTheme.copyWith(
              typography: () => base.darkTheme.typography.scale(scale),
            ),
          ),
        ),
        home: const AppDescriptions(
          items: [
            AppDescriptionItem(
              label: material.Text('Global label'),
              value: material.Text('Global value'),
            ),
          ],
        ),
      ),
    );

    final style = material.DefaultTextStyle.of(
      tester.element(find.text('Global value')),
    ).style;
    expect(style.fontSize, closeTo(12, 0.01));
  });
}
