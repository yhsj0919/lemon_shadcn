import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('text area uses configured height and native Form reset', (
    tester,
  ) async {
    final controller = AppFormController();
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controls: const AppControlMetrics(textAreaHeight: 120),
          ),
        ),
        home: AppForm(
          controller: controller,
          child: AppTextAreaFormField(
            name: 'notes',
            initialValue: 'Initial notes',
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppTextArea)).height, 120);
    await tester.enterText(find.byType(AppTextArea), 'Updated notes');
    await tester.pump();
    expect(controller.value<String>('notes'), 'Updated notes');

    controller.reset();
    await tester.pump();
    expect(controller.value<String>('notes'), 'Initial notes');
    expect(find.text('Initial notes'), findsOneWidget);
  });

  testWidgets(
    'OTP accepts paste, validates, and resets without template code',
    (tester) async {
      final controller = AppFormController();
      await tester.pumpWidget(
        MaterialApp(
          builder: AppShadcnScope.builder(),
          home: AppForm(
            controller: controller,
            child: AppInputOtpFormField(
              name: 'otp',
              length: 6,
              initialValue: '12',
              validator: AppValidators.exactLength(6),
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(EditableText).first, '123456');
      await tester.pump();
      expect(controller.value<String>('otp'), '123456');
      expect(await controller.validate(), isTrue);

      controller.reset();
      await tester.pump();
      expect(controller.value<String>('otp'), '12');
    },
  );

  testWidgets('phone input emits formatted values and resets', (tester) async {
    final controller = AppFormController();
    final initial = shad.PhoneNumber(shad.Country.unitedStates, '2025550100');
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppPhoneInputFormField(name: 'phone', initialValue: initial),
        ),
      ),
    );

    await tester.enterText(find.byType(shad.TextField).last, '+12025550199');
    await tester.pump();
    expect(controller.value<shad.PhoneNumber>('phone')?.number, '2025550199');

    controller.reset();
    await tester.pump();
    expect(controller.value<shad.PhoneNumber>('phone'), initial);
  });
}
