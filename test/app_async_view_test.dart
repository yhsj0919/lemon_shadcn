import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('renders formatted async data with no page state template', (
    tester,
  ) async {
    final completer = Completer<List<String>>();
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppAsyncView<List<String>>(
          load: () => completer.future,
          builder: (context, data) => Text(data.join(', ')),
        ),
      ),
    );

    expect(find.byType(AppCircularProgressIndicator), findsOneWidget);
    completer.complete(['ready', 'formatted']);
    await tester.pump();
    expect(find.text('ready, formatted'), findsOneWidget);
  });

  testWidgets('default error state retries the loader', (tester) async {
    var attempts = 0;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppAsyncView<String>(
          load: () {
            attempts++;
            if (attempts == 1) throw StateError('offline');
            return 'recovered';
          },
          builder: (context, data) => Text(data),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Retry'), findsOneWidget);
    await tester.tap(find.text('Retry'));
    await tester.pump();
    expect(find.text('recovered'), findsOneWidget);
    expect(attempts, 2);
  });

  testWidgets('global error presenter converts technical failures', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            errorPresenter: (error, stackTrace) => 'Unable to load data',
          ),
        ),
        home: AppAsyncView<String>(
          load: () => throw StateError('database details'),
          builder: (context, data) => Text(data),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Unable to load data'), findsOneWidget);
    expect(find.textContaining('database details'), findsNothing);
  });
}
