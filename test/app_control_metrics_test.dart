import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('default interactive controls share one configured height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
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
              initialValue: AppColorDerivative.fromColor(Colors.indigo),
            ),
          ],
        ),
      ),
    );

    final boxes = tester.widgetList<AppControlBox>(find.byType(AppControlBox));
    expect(boxes, hasLength(6));
    for (var index = 0; index < boxes.length; index++) {
      final element = find.byType(AppControlBox).evaluate().elementAt(index);
      final height = tester.getSize(find.byWidget(element.widget)).height;
      if (index == 0) {
        expect(height, 31);
      } else {
        expect(height, greaterThanOrEqualTo(40));
      }
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('fluent preset keeps button text centered without clipping', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
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
    expect(tester.getSize(control).height, 31);
    expect(
      tester.getCenter(label).dy,
      closeTo(tester.getCenter(control).dy, 0.01),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('one height override applies across form control families', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppControlHeight(
          height: 44,
          child: Column(
            children: [
              AppTextFormField(),
              const AppSelectFormField<String>(
                options: [AppOption(value: 'one', label: 'One')],
              ),
              AppNumberInput(value: 1, onChanged: (_) {}),
              AppDatePicker(value: null, onChanged: (_) {}),
            ],
          ),
        ),
      ),
    );

    final boxes = find.byType(AppControlBox);
    expect(boxes, findsNWidgets(4));
    for (final element in boxes.evaluate()) {
      expect(
        tester.getSize(find.byWidget(element.widget)).height,
        greaterThanOrEqualTo(44),
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('small requested height is clamped to a safe content floor', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: AppControlHeight(
            height: 12,
            child: AppControlBox(child: Center(child: Text('Safe content'))),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppControlBox)).height, greaterThan(12));
    expect(tester.takeException(), isNull);
  });
}
