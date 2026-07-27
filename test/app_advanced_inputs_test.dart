import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('formatted and color fields collect typed values and reset', (
    tester,
  ) async {
    final initialFormatted = AppFormattedValue([
      AppFormattedParts.fixed('ID-'),
      AppFormattedParts.editable('', length: 3),
    ]);
    final nextFormatted = AppFormattedValue([
      AppFormattedParts.fixed('ID-'),
      AppFormattedParts.editable('123', length: 3),
    ]);
    final initialColor = AppColorDerivative.fromColor(
      const material.Color(0xff336699),
    );
    final nextColor = AppColorDerivative.fromColor(
      const material.Color(0xffcc5500),
    );
    final controller = AppFormController();
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppFormattedInputFormField(
                name: 'reference',
                initialValue: initialFormatted,
              ),
              AppColorInputFormField(name: 'color', initialValue: initialColor),
            ],
          ),
        ),
      ),
    );

    tester
            .widget<FormattedInput>(find.byType(FormattedInput))
            .controller!
            .value =
        nextFormatted;
    tester.widget<ColorInput>(find.byType(ColorInput)).onChanged!(nextColor);
    await tester.pump();
    expect(controller.value<AppFormattedValue>('reference'), nextFormatted);
    expect(controller.value<AppColorDerivative>('color'), nextColor);

    controller.reset();
    await tester.pump();
    expect(controller.value<AppFormattedValue>('reference'), initialFormatted);
    expect(controller.value<AppColorDerivative>('color'), initialColor);
    expect(
      tester
          .widget<FormattedInput>(find.byType(FormattedInput))
          .controller!
          .value,
      initialFormatted,
    );
  });

  testWidgets('formatted options remove choice and picker item boilerplate', (
    tester,
  ) async {
    final controller = AppFormController();
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppMultipleChoiceFormField<String>(
                name: 'plan',
                options: const [
                  AppOption(value: 'personal', label: 'Personal'),
                  AppOption(value: 'team', label: 'Team'),
                ],
              ),
              AppItemPickerFormField<String>(
                name: 'icon',
                options: const [
                  AppOption(value: 'folder', label: 'Folder'),
                  AppOption(value: 'star', label: 'Star'),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Team'));
    await tester.pump();
    expect(controller.value<String>('plan'), 'team');
    tester
        .widget<ItemPicker<String>>(find.byType(ItemPicker<String>))
        .onChanged!('star');
    await tester.pump();
    expect(controller.value<String>('icon'), 'star');
  });

  testWidgets('AppInput remains the raw upstream input primitive', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppControlBox(child: AppInput(initialValue: 'Raw input')),
      ),
    );
    expect(find.byType(TextField), findsOneWidget);
  });

  testWidgets('formatted input stays centered and keeps focus while typing', (
    tester,
  ) async {
    final controller = AppFormController();
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controls: const AppControlMetrics(height: 40),
          ),
        ),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 320,
            child: AppForm(
              controller: controller,
              child: AppFormattedInputFormField(
                name: 'reference',
                initialValue: AppFormattedValue([
                  AppFormattedParts.fixed('APP-'),
                  AppFormattedParts.editable('', length: 4),
                  AppFormattedParts.fixed('-'),
                  AppFormattedParts.editable('', length: 2),
                ]),
              ),
            ),
          ),
        ),
      ),
    );

    final formatted = find.byType(FormattedInput);
    final control = find.byType(AppControlBox);
    expect(tester.getSize(formatted).height, 40);
    expect(tester.getCenter(formatted).dy, tester.getCenter(control).dy);

    final firstPart = find.byType(TextField).first;
    final originalElement = firstPart.evaluate().single;
    final textController = tester.widget<TextField>(firstPart).controller!;
    expect(
      textController
          .buildTextSpan(
            context: tester.element(firstPart),
            withComposing: false,
          )
          .toPlainText(),
      '____',
    );
    await tester.tap(firstPart);
    await tester.showKeyboard(firstPart);
    tester.testTextInput.enterText('1');
    await tester.pump();

    expect(firstPart.evaluate().single, same(originalElement));
    expect(tester.widget<TextField>(firstPart).focusNode!.hasFocus, isTrue);
    expect(
      tester.getCenter(find.byType(EditableText).first).dy,
      closeTo(tester.getCenter(formatted).dy, 0.5),
    );

    tester.testTextInput.enterText('12');
    await tester.pump();
    expect(firstPart.evaluate().single, same(originalElement));
    expect(
      textController
          .buildTextSpan(
            context: tester.element(firstPart),
            withComposing: false,
          )
          .toPlainText(),
      '12__',
    );
    expect(
      controller.value<AppFormattedValue>('reference')!.values.first.value,
      '12',
    );
  });
}
