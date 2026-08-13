import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  const options = [
    AppOption(value: 'admin', label: 'Administrator'),
    AppOption(value: 'user', label: 'User'),
  ];

  testWidgets('selects and saves a formatted option in native Form', (
    tester,
  ) async {
    final formKey = GlobalKey<FormState>();
    String? saved;

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Form(
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
    expect(find.text('Administrator'), findsOneWidget);
  });

  testWidgets('selected option is rendered back into the form field', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppSelectFormField<String>(
          hintText: '时间类型',
          width: 140,
          options: const [
            AppOption(value: 'today', label: '今天'),
            AppOption(value: 'month', label: '本月'),
          ],
        ),
      ),
    );

    await tester.tap(find.text('时间类型'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('本月').last);
    await tester.pumpAndSettle();

    expect(find.text('时间类型'), findsNothing);
    expect(find.text('本月'), findsOneWidget);
  });

  testWidgets('expand icon follows available content width', (tester) async {
    Future<void> pumpSelect(String label) => tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 119,
            child: AppSelect<String>(
              value: label,
              onChanged: _ignoreSelection,
              minWidth: 0,
              options: [AppOption(value: label, label: label)],
            ),
          ),
        ),
      ),
    );

    await pumpSelect('TOP10');
    expect(
      tester
          .widget<shad.Select<String>>(find.byType(shad.Select<String>))
          .expandIcon,
      isNotNull,
    );

    await pumpSelect('A very long selected option');
    expect(
      tester
          .widget<shad.Select<String>>(find.byType(shad.Select<String>))
          .expandIcon,
      isNull,
    );
  });

  testWidgets('select ellipsizes content after hiding the expand icon', (
    tester,
  ) async {
    const value = 'A very long value outside the option list';
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 70,
            child: AppSelect<String>(value: value, minWidth: 0, options: []),
          ),
        ),
      ),
    );

    final select = tester.widget<shad.Select<String>>(
      find.byType(shad.Select<String>),
    );
    final text = tester.widget<Text>(find.text(value));
    expect(select.expandIcon, isNull);
    expect(text.maxLines, 1);
    expect(text.overflow, TextOverflow.ellipsis);
    expect(tester.takeException(), isNull);
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
      MaterialApp(
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
      MaterialApp(
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
      MaterialApp(
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

  testWidgets('select releases focus when its popup is dismissed outside', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Column(
          children: [
            const AppSelect<String>(
              options: options,
              onChanged: _ignoreSelection,
            ),
            const SizedBox(
              key: ValueKey<String>('outside-select'),
              width: 200,
              height: 100,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('Select an option'));
    await tester.pumpAndSettle();
    expect(find.text('Administrator'), findsOneWidget);

    await tester.tapAt(const Offset(790, 590));
    await tester.pumpAndSettle();
    expect(find.text('Administrator'), findsNothing);
    expect(
      tester
          .widget<shad.Select<String>>(find.byType(shad.Select<String>))
          .focusNode!
          .hasFocus,
      isFalse,
    );
  });

  testWidgets('clicking another select transfers the open popup and focus', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Column(
          children: [
            AppSelect<String>(
              hintText: 'First select',
              options: [AppOption(value: 'first', label: 'First option')],
              onChanged: _ignoreSelection,
            ),
            AppSelect<String>(
              hintText: 'Second select',
              options: [AppOption(value: 'second', label: 'Second option')],
              onChanged: _ignoreSelection,
            ),
            AppSelect<String>(
              hintText: 'Third select',
              options: [AppOption(value: 'third', label: 'Third option')],
              onChanged: _ignoreSelection,
            ),
          ],
        ),
      ),
    );

    await tester.tap(find.text('First select'));
    await tester.pumpAndSettle();
    expect(find.text('First option'), findsOneWidget);

    await tester.tap(find.text('Second select'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('First option'), findsNothing);
    expect(find.text('Second option'), findsOneWidget);

    await tester.tap(find.text('Third select'), warnIfMissed: false);
    await tester.pumpAndSettle();
    expect(find.text('Second option'), findsNothing);
    expect(find.text('Third option'), findsOneWidget);

    final selects = tester
        .widgetList<shad.Select<String>>(find.byType(shad.Select<String>))
        .toList();
    expect(
      selects.take(2).every((select) => !select.focusNode!.hasFocus),
      isTrue,
    );

    await tester.tapAt(const Offset(790, 590));
    await tester.pumpAndSettle();
    expect(find.text('Third option'), findsNothing);
    expect(selects.every((select) => !select.focusNode!.hasFocus), isTrue);
  });
}

void _ignoreSelection(String? value) {}
