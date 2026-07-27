import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('image field accepts formatted values and removes them', (
    tester,
  ) async {
    final controller = AppFormController();
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppImageInputFormField<String>(
            name: 'image',
            pick: () => 'asset://avatar',
            previewBuilder: (context, value) => Text(value),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Choose image'));
    await tester.pump();
    expect(controller.values['image'], 'asset://avatar');
    expect(find.text('asset://avatar'), findsOneWidget);

    await tester.tap(find.text('Remove'));
    await tester.pump();
    expect(controller.values['image'], isNull);
  });

  testWidgets('sortable field stores reordered domain values', (tester) async {
    List<String>? changed;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppSortableInputFormField<String>(
          initialValue: const ['A', 'B', 'C'],
          itemBuilder: (context, index, item) =>
              SizedBox(height: 40, child: Text(item)),
          onChanged: (value) => changed = value,
        ),
      ),
    );

    final input = tester.widget<AppSortableInput<String>>(
      find.byType(AppSortableInput<String>),
    );
    final list = tester.widget<material.ReorderableListView>(
      find.byType(material.ReorderableListView),
    );
    expect(input.items, ['A', 'B', 'C']);
    list.onReorderItem!(0, 2);
    await tester.pump();
    expect(changed, ['B', 'C', 'A']);
  });

  testWidgets('object field exposes upstream formatted object input', (
    tester,
  ) async {
    final formController = AppFormController();
    final converter = AppObjectConverter<String?, List<String?>>(
      (value) => [value],
      (parts) => parts.first,
    );
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 240,
            child: AppForm(
              controller: formController,
              child: AppObjectInputFormField<String>(
                name: 'shortCode',
                initialValue: 'AB',
                converter: converter,
                parts: const [AppEditablePart(length: 2, width: 48)],
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(AppObjectInput<String>), findsOneWidget);
    final editable = find.byType(TextField).first;
    final originalElement = editable.evaluate().single;
    await tester.tap(editable);
    await tester.showKeyboard(editable);
    tester.testTextInput.enterText('A');
    await tester.pump();
    tester.testTextInput.enterText('AX');
    await tester.pump();

    expect(editable.evaluate().single, same(originalElement));
    expect(tester.widget<TextField>(editable).focusNode!.hasFocus, isTrue);
    expect(
      tester.getCenter(find.byType(EditableText).first).dy,
      closeTo(tester.getCenter(find.byType(AppObjectInput<String>)).dy, 0.5),
    );
    expect(formController.value<String>('shortCode'), 'AX');
    expect(tester.takeException(), isNull);
  });
}
