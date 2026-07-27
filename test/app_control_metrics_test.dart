import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('default interactive controls share one configured height', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controls: const AppControlMetrics(height: 40),
          ),
        ),
        home: Column(
          children: [
            AppButton.primary(onPressed: () {}, child: const Text('Action')),
            AppTextFormField(),
            const AppSelectFormField<String>(
              options: [AppOption(value: 'one', label: 'One')],
            ),
            AppAutoCompleteFormField<String>.async(
              searchOptions: (_) async => const [],
            ),
            AppFormattedInputFormField(
              initialValue: AppFormattedValue([
                AppFormattedParts.editable('', length: 4),
              ]),
            ),
            AppColorInputFormField(
              initialValue: AppColorDerivative.fromColor(
                material.Colors.indigo,
              ),
            ),
          ],
        ),
      ),
    );

    final boxes = tester.widgetList<AppControlBox>(find.byType(AppControlBox));
    expect(boxes, hasLength(6));
    for (final element in find.byType(AppControlBox).evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height, 40);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('fluent preset keeps button text centered without clipping', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.preset(AppThemePreset.fluent),
        ),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppButton.primary(
            onPressed: () {},
            child: const Text('Fluent action'),
          ),
        ),
      ),
    );

    final control = find.byType(AppControlBox);
    final label = find.text('Fluent action');
    expect(tester.getSize(control).height, 36);
    expect(
      tester.getCenter(label).dy,
      closeTo(tester.getCenter(control).dy, 0.01),
    );
    expect(tester.takeException(), isNull);
  });
}
