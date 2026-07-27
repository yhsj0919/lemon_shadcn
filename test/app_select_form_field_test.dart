import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  const options = [
    AppOption(value: 'admin', label: 'Administrator'),
    AppOption(value: 'user', label: 'User'),
  ];

  testWidgets('selects and saves a formatted option in native Form', (
    tester,
  ) async {
    final formKey = material.GlobalKey<material.FormState>();
    String? saved;

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.Form(
          key: formKey,
          child: AppSelectFormField<String>(
            label: 'Role',
            options: options,
            onSaved: (value) => saved = value,
            validator: (value) => value == null ? 'Select a role.' : null,
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Select a role.'), findsOneWidget);

    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Administrator').last);
    await tester.pumpAndSettle();

    expect(formKey.currentState!.validate(), isTrue);
    formKey.currentState!.save();
    expect(saved, 'admin');
  });

  testWidgets('async select loads formatted options only once on rebuild', (
    tester,
  ) async {
    var loads = 0;

    Future<List<AppOption<String>>> loadOptions() async {
      loads++;
      return options;
    }

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppSelectFormField<String>.async(loadOptions: loadOptions),
      ),
    );
    await tester.pumpAndSettle();

    expect(loads, 1);
    expect(find.text('Select an option'), findsOneWidget);

    await tester.pump();
    expect(loads, 1);
  });

  testWidgets('async select exposes local error and retry builders', (
    tester,
  ) async {
    var loads = 0;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppSelectFormField<String>.async(
          loadOptions: () async {
            loads++;
            throw StateError('offline');
          },
          loadErrorBuilder: (context, error, retry) => AppButton.outline(
            onPressed: retry,
            child: const Text('Try roles again'),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Try roles again'), findsOneWidget);
    await tester.tap(find.text('Try roles again'));
    await tester.pumpAndSettle();
    expect(loads, 2);
  });

  testWidgets('select rejects duplicate option identity', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppSelect<String>(
          options: [
            AppOption(value: 'same', label: 'First'),
            AppOption(value: 'same', label: 'Second'),
          ],
        ),
      ),
    );

    expect(tester.takeException(), isA<FlutterError>());
  });
}
