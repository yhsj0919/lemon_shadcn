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

  testWidgets('compact theme changes typography and spacing', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: ComponentTheme<AppDescriptionsTheme>(
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

  testWidgets('compact embedded controls and inline edit use local height', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.SizedBox(
          width: 600,
          child: AppDescriptions(
            density: AppDescriptionsDensity.compact,
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
}
