import 'dart:ui' show PointerDeviceKind;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('integrates with native Form validation and reset', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Form(
          key: formKey,
          child: AppTextFormField.email(
            label: 'Email',
            required: true,
            initialValue: 'initial@example.com',
          ),
        ),
      ),
    );

    expect(find.text('initial@example.com'), findsOneWidget);
    final widthBefore = tester.getSize(find.byType(AppField)).width;
    final heightBefore = tester.getSize(find.byType(AppField)).height;

    await tester.enterText(find.byType(TextField), 'invalid');
    await tester.pump();
    final widthWithError = tester.getSize(find.byType(AppField)).width;
    final heightWithError = tester.getSize(find.byType(AppField)).height;
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(widthWithError, widthBefore);
    expect(heightWithError, heightBefore);
    expect(formKey.currentState!.validate(), isFalse);

    await tester.enterText(find.byType(TextField), 'valid@example.com');
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);

    formKey.currentState!.reset();
    await tester.pump();
    expect(find.text('initial@example.com'), findsOneWidget);
  });

  testWidgets('shows hintText as visible placeholder when empty', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppTextFormField(hintText: '输入内容'),
      ),
    );

    expect(find.text('输入内容'), findsOneWidget);
  });

  testWidgets('supports an explicit field width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppTextFormField(label: 'Name', width: 320),
        ),
      ),
    );

    expect(tester.getSize(find.byType(AppField)).width, 320);
  });

  testWidgets('shows label-less errors in a stable trailing tooltip', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Form(
          key: formKey,
          child: AppTextFormField.email(label: null, initialValue: 'invalid'),
        ),
      ),
    );

    final sizeBefore = tester.getSize(find.byType(AppField));
    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();

    expect(tester.getSize(find.byType(AppField)), sizeBefore);
    final warning = find.byIcon(AppLucideIcons.triangleAlert);
    expect(warning, findsOneWidget);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await mouse.addPointer();
    await mouse.moveTo(tester.getCenter(warning));
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Enter a valid email address.'), findsOneWidget);
  });

  testWidgets('password variant configures autofill and toggles visibility', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppTextFormField.password(required: true, initialValue: 'secret'),
      ),
    );

    var input = tester.widget<TextField>(find.byType(TextField));
    expect(input.obscureText, isTrue);
    expect(input.autocorrect, isFalse);
    expect(input.enableSuggestions, isFalse);
    expect(input.autofillHints, contains(AutofillHints.password));
    final size = tester.getSize(find.byType(AppControlBox));

    await tester.tap(find.byIcon(AppLucideIcons.eye));
    await tester.pump();
    input = tester.widget<TextField>(find.byType(TextField));
    expect(input.obscureText, isFalse);
    expect(find.byIcon(AppLucideIcons.eyeOff), findsOneWidget);
    expect(tester.getSize(find.byType(AppControlBox)), size);
  });
}
