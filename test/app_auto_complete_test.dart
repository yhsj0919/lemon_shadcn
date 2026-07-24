import 'package:flutter/material.dart' as material;
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
      material.MaterialApp(
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
}
