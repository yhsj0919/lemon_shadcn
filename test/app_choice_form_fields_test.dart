import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('choice fields register values and share control height', (
    tester,
  ) async {
    final controller = AppFormController();

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controls: const AppControlMetrics(height: 40),
          ),
        ),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppCheckboxFormField(
                name: 'terms',
                controlLabel: const Text('Accept terms'),
              ),
              AppCheckboxGroupFormField<String>(
                name: 'times',
                label: 'Time options',
                layout: AppFieldLayout.horizontal,
                options: const [
                  AppOption(value: 'day', label: 'Day'),
                  AppOption(value: 'night', label: 'Night'),
                ],
              ),
              AppSwitchFormField(
                name: 'notifications',
                controlLabel: const Text('Notifications'),
              ),
              AppRadioGroupFormField<String>(
                name: 'density',
                direction: Axis.horizontal,
                options: const [
                  AppOption(value: 'compact', label: 'Compact'),
                  AppOption(value: 'standard', label: 'Standard'),
                ],
              ),
              AppSliderFormField(
                name: 'volume',
                initialValue: const shad.SliderValue.single(0.4),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Accept terms'));
    await tester.tap(find.text('Day'));
    await tester.tap(find.text('Night'));
    await tester.tap(find.text('Notifications'));
    await tester.tap(find.text('Standard'));
    await tester.pump();

    expect(controller.value<bool>('terms'), isTrue);
    expect(controller.value<List<String>>('times'), ['day', 'night']);
    expect(controller.value<bool>('notifications'), isTrue);
    expect(controller.value<String>('density'), 'standard');
    expect(controller.value<shad.SliderValue>('volume')!.value, 0.4);

    for (final element in find.byType(AppControlBox).evaluate()) {
      expect(tester.getSize(find.byWidget(element.widget)).height, 40);
    }
  });

  testWidgets('checkbox validation uses native Form semantics', (tester) async {
    final controller = AppFormController();
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppCheckboxFormField(
            name: 'terms',
            controlLabel: const Text('Accept terms'),
            validator: (value) => value == true ? null : 'Accept to continue.',
          ),
        ),
      ),
    );

    expect(await controller.validate(), isFalse);
    await tester.pump();
    expect(find.byIcon(AppLucideIcons.triangleAlert), findsOneWidget);

    await tester.tap(find.text('Accept terms'));
    await tester.pump();
    expect(await controller.validate(), isTrue);
  });

  testWidgets('global control palette updates selected internal colors', (
    tester,
  ) async {
    const selected = Color(0xff336699);
    const foreground = Color(0xffffffff);
    const border = Color(0xff224466);
    const explicit = Color(0xffcc5500);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controlPalette: const AppVisualPalette(
              normal: AppVisualColors(),
              selected: AppVisualColors(
                background: selected,
                foreground: foreground,
                border: border,
              ),
            ),
          ),
        ),
        home: Column(
          children: [
            AppCheckbox(
              state: shad.CheckboxState.checked,
              activeColor: explicit,
              onChanged: (_) {},
            ),
            AppSwitch(value: true, onChanged: (_) {}),
            AppRadioGroup<String>(
              value: 'selected',
              onChanged: (_) {},
              options: const [AppOption(value: 'selected', label: 'Selected')],
            ),
            AppSlider(
              value: const shad.SliderValue.single(0.5),
              onChanged: (_) {},
            ),
          ],
        ),
      ),
    );

    expect(
      tester.widget<Checkbox>(find.byType(Checkbox)).activeColor,
      explicit,
    );
    final appSwitch = tester.widget<Switch>(find.byType(Switch));
    expect(appSwitch.activeTrackColor, selected);
    expect(appSwitch.activeThumbColor, foreground);

    final radioTheme = tester
        .widgetList<shad.ComponentTheme<shad.RadioTheme>>(
          find.byWidgetPredicate(
            (widget) => widget is shad.ComponentTheme<shad.RadioTheme>,
          ),
        )
        .single
        .data;
    expect(radioTheme.activeColor, foreground);
    expect(radioTheme.borderColor, border);

    final sliderTheme = tester
        .widgetList<shad.ComponentTheme<shad.SliderTheme>>(
          find.byWidgetPredicate(
            (widget) => widget is shad.ComponentTheme<shad.SliderTheme>,
          ),
        )
        .single
        .data;
    expect(sliderTheme.valueColor, foreground);
    expect(sliderTheme.thumbBorderColor, border);
  });

  testWidgets('slider stays vertically centered in the control height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controls: const AppControlMetrics(height: 40),
          ),
        ),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 240,
            child: AppSlider(
              value: const shad.SliderValue.single(0.6),
              onChanged: (_) {},
            ),
          ),
        ),
      ),
    );

    final control = find.byType(AppControlBox);
    final slider = find.byType(Slider);
    expect(tester.getSize(control).height, 40);
    expect(tester.getSize(slider).height, lessThan(40));
    expect(
      tester.getCenter(slider).dy,
      closeTo(tester.getCenter(control).dy, 0.01),
    );
  });
}
