import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('debounces formatted option searches and selects a value', (
    tester,
  ) async {
    final queries = <String>[];
    String? selected;

    Future<List<AppOption<String>>> search(String query) async {
      queries.add(query);
      return const [
        AppOption(value: 'admin', label: 'Administrator'),
        AppOption(value: 'user', label: 'User'),
      ];
    }

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppAutoCompleteFormField<String>.async(
          searchOptions: search,
          debounce: const Duration(milliseconds: 300),
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.text('Search and select'));
    await tester.pumpAndSettle();
    expect(queries, ['']);

    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'ad');
    await tester.pump(const Duration(milliseconds: 299));
    expect(queries, ['']);

    await tester.pump(const Duration(milliseconds: 1));
    await tester.pumpAndSettle();
    expect(queries, ['', 'ad']);

    await tester.tap(find.text('Administrator'));
    await tester.pumpAndSettle();
    expect(selected, 'admin');
    expect(find.text('Administrator'), findsOneWidget);
  });

  testWidgets('paged autocomplete loads more formatted options in place', (
    tester,
  ) async {
    final source = AppAsyncPagedOptionSource<String>(
      loader: (query, cursor) async => cursor == null
          ? const AppOptionPage(
              options: [AppOption(value: 'one', label: 'One')],
              nextCursor: 2,
            )
          : const AppOptionPage(
              options: [AppOption(value: 'two', label: 'Two')],
            ),
    );
    String? selected;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppAutoCompleteFormField<String>.paged(
          pagedOptionSource: source,
          debounce: Duration.zero,
          onChanged: (value) => selected = value,
        ),
      ),
    );

    await tester.tap(find.text('Search and select'));
    await tester.pumpAndSettle();
    expect(find.text('One'), findsOneWidget);
    await tester.tap(find.text('Load more'));
    await tester.pumpAndSettle();
    expect(find.text('Two'), findsOneWidget);
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
    expect(selected, 'two');
  });

  testWidgets('autocomplete exposes an initial-load retry action', (
    tester,
  ) async {
    var attempts = 0;
    final source = AppAsyncOptionSource<String>(
      loader: (_) async {
        attempts++;
        if (attempts == 1) throw StateError('temporary');
        return const [AppOption(value: 'ok', label: 'Recovered')];
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppAutoCompleteFormField<String>.source(
          optionSource: source,
          debounce: Duration.zero,
        ),
      ),
    );

    await tester.tap(find.text('Search and select'));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    expect(find.text('Recovered'), findsOneWidget);
    expect(attempts, 2);
  });
}
