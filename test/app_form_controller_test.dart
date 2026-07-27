import 'dart:async';

import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('collects named values and keeps native Form lifecycle', (
    tester,
  ) async {
    final controller = AppFormController();
    String? saved;

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppTextFormField(
            name: 'displayName',
            initialValue: 'Initial',
            onSaved: (value) => saved = value,
          ),
        ),
      ),
    );

    expect(controller.value<String>('displayName'), 'Initial');
    await tester.enterText(find.byType(TextField), 'Updated');
    await tester.pump();
    expect(controller.values, {'displayName': 'Updated'});

    controller.save();
    expect(saved, 'Updated');
    controller.reset();
    await tester.pump();
    expect(controller.value<String>('displayName'), 'Initial');
  });

  testWidgets('runs sync and async validation through one controller', (
    tester,
  ) async {
    final controller = AppFormController();

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppTextFormField(
            name: 'username',
            label: 'Username',
            initialValue: 'taken',
            validator: AppValidators.required(),
            asyncValidator: (value) async {
              return value == 'taken' ? 'Username is already in use.' : null;
            },
          ),
        ),
      ),
    );

    expect(await controller.validate(), isFalse);
    await tester.pump();
    expect(find.text('Username is already in use.'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'available');
    await tester.pump();
    expect(find.text('Username is already in use.'), findsNothing);
    expect(await controller.validate(), isTrue);
  });

  testWidgets('ignores obsolete async validation results', (tester) async {
    final controller = AppFormController();
    final requests = <String, Completer<String?>>{};

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppTextFormField(
            name: 'code',
            initialValue: 'old',
            asyncValidator: (value) {
              final request = Completer<String?>();
              requests[value!] = request;
              return request.future;
            },
          ),
        ),
      ),
    );

    final oldValidation = controller.validate();
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'new');
    await tester.pump();
    final newValidation = controller.validate();
    requests['new']!.complete(null);
    expect(await newValidation, isTrue);
    requests['old']!.complete('Obsolete error');
    await oldValidation;
    await tester.pump();
    expect(find.text('Obsolete error'), findsNothing);
  });

  testWidgets('routes cross-field errors and clears stale results on edit', (
    tester,
  ) async {
    final pending = Completer<Map<String, String>>();
    final controller = AppFormController(
      crossValidators: [(_) => pending.future],
    );
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppTextFormField(
                name: 'password',
                label: 'Password',
                initialValue: 'secret',
              ),
              AppTextFormField(
                name: 'confirmation',
                label: 'Confirmation',
                initialValue: 'different',
              ),
            ],
          ),
        ),
      ),
    );

    final validation = controller.validate();
    await tester.pump();
    expect(controller.isValidating, isTrue);
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.pump();
    pending.complete({'confirmation': 'Passwords do not match.'});
    expect(await validation, isFalse);
    await tester.pump();
    expect(find.text('Passwords do not match.'), findsNothing);
    expect(controller.isValidating, isFalse);
  });

  testWidgets('shows a current cross-field error in the target field slot', (
    tester,
  ) async {
    final controller = AppFormController(
      crossValidators: [
        (values) => values['password'] == values['confirmation']
            ? const {}
            : const {'confirmation': 'Passwords do not match.'},
      ],
    );
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppTextFormField(
                name: 'password',
                label: 'Password',
                initialValue: 'secret',
              ),
              AppTextFormField(
                name: 'confirmation',
                label: 'Confirmation',
                initialValue: 'different',
              ),
            ],
          ),
        ),
      ),
    );

    expect(await controller.validate(), isFalse);
    await tester.pump();
    expect(find.text('Passwords do not match.'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, 'secret');
    await tester.pump();
    expect(find.text('Passwords do not match.'), findsNothing);
    expect(await controller.validate(), isTrue);
  });

  testWidgets('submit validates then passes an immutable value snapshot', (
    tester,
  ) async {
    final controller = AppFormController();
    Map<String, Object?>? submitted;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppTextFormField(
            name: 'title',
            initialValue: '',
            validator: AppValidators.required(),
          ),
        ),
      ),
    );

    expect(await controller.submit((values) => submitted = values), isFalse);
    expect(submitted, isNull);
    await tester.enterText(find.byType(TextField), 'Ready');
    await tester.pump();
    expect(await controller.submit((values) => submitted = values), isTrue);
    expect(submitted, {'title': 'Ready'});
    expect(() => submitted!['title'] = 'Changed', throwsUnsupportedError);
  });

  testWidgets('submit action shares validation and request state with button', (
    tester,
  ) async {
    final controller = AppFormController();
    final request = Completer<void>();
    final action = controller.createSubmitAction((values) => request.future);
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppTextFormField(name: 'title', initialValue: 'Ready'),
              AppButton.primary(action: action, child: const Text('Submit')),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Submit'));
    await tester.pump();
    expect(action.isRunning, isTrue);
    request.complete();
    await tester.pump();
    expect(action.status, AppAsyncStatus.success);
    action.dispose();
  });

  testWidgets('tracks dirty values and supports a new clean baseline', (
    tester,
  ) async {
    final controller = AppFormController();
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppTextFormField(name: 'title', initialValue: 'Initial'),
        ),
      ),
    );

    expect(controller.isDirty, isFalse);
    await tester.enterText(find.byType(TextField), 'Changed');
    await tester.pump();
    expect(controller.dirtyFields, {'title'});
    controller.markClean();
    expect(controller.isDirty, isFalse);
    await tester.enterText(find.byType(TextField), 'Changed again');
    await tester.pump();
    expect(controller.isDirty, isTrue);
  });

  testWidgets('unmounted fields leave values and disabled fields stay', (
    tester,
  ) async {
    final controller = AppFormController();
    late StateSetter update;
    var showDynamic = true;
    var disabledValidated = false;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: StatefulBuilder(
          builder: (context, setState) {
            update = setState;
            return AppForm(
              controller: controller,
              child: Column(
                children: [
                  if (showDynamic)
                    AppTextFormField(
                      key: const ValueKey('dynamic-field'),
                      name: 'dynamic',
                      initialValue: 'value',
                    ),
                  AppTextFormField(
                    key: const ValueKey('disabled-field'),
                    name: 'disabled',
                    initialValue: 'kept',
                    enabled: false,
                    validator: (_) {
                      disabledValidated = true;
                      return 'Must not run';
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );

    expect(controller.values, {'dynamic': 'value', 'disabled': 'kept'});
    expect(await controller.validate(), isFalse);
    expect(disabledValidated, isTrue);
    update(() => showDynamic = false);
    await tester.pump();
    expect(controller.values, {'disabled': 'kept'});
  });

  testWidgets('submit errors propagate and render in a fixed summary slot', (
    tester,
  ) async {
    final controller = AppFormController();
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            errorPresenter: (error, stackTrace) => 'Unable to save form',
          ),
        ),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppTextFormField(name: 'title', initialValue: 'Ready'),
              AppFormErrorSummary(controller: controller),
            ],
          ),
        ),
      ),
    );

    final summary = find.byType(AppFormErrorSummary);
    final sizeBefore = tester.getSize(summary);
    await expectLater(
      controller.submit((values) => throw StateError('database details')),
      throwsStateError,
    );
    await tester.pump();
    expect(find.text('Unable to save form'), findsOneWidget);
    expect(tester.getSize(summary), sizeBefore);
    expect(controller.submitError, isA<StateError>());

    await tester.enterText(find.byType(TextField), 'Edited');
    await tester.pump();
    expect(find.text('Unable to save form'), findsNothing);
    expect(tester.getSize(summary), sizeBefore);
  });
}
