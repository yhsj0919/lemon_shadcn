import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('works inside MaterialApp without ShadcnApp', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) =>
              AppButton.primary(onPressed: () {}, child: const Text('Save')),
        ),
      ),
    );

    expect(find.text('Save'), findsOneWidget);
    expect(
      AppTheme.of(tester.element(find.text('Save'))),
      isA<AppThemeConfig>(),
    );
  });

  testWidgets('disables repeated presses while an async action runs', (
    tester,
  ) async {
    final completer = Completer<void>();
    var presses = 0;

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            motion: const AppMotionTheme(
              loadingDelay: Duration.zero,
              minimumLoadingDuration: Duration.zero,
            ),
          ),
        ),
        home: Builder(
          builder: (context) => AppButton.primary(
            onPressed: () {
              presses++;
              return completer.future;
            },
            child: const Text('Save'),
          ),
        ),
      ),
    );

    final widthBefore = tester.getSize(find.byType(shad.PrimaryButton)).width;
    await tester.tap(find.text('Save'));
    await tester.pump(const Duration(milliseconds: 1));
    final widthDuring = tester.getSize(find.byType(shad.PrimaryButton)).width;
    await tester.tap(find.byType(CircularProgressIndicator));
    await tester.pump();

    expect(presses, 1);
    expect(widthDuring, widthBefore);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    completer.complete();
    await tester.pump();

    expect(find.text('Save'), findsOneWidget);
  });

  testWidgets('renders link and text variants', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) => Row(
            children: [
              AppButton.link(onPressed: () {}, child: const Text('Link')),
              AppButton.text(onPressed: () {}, child: const Text('Text')),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(shad.LinkButton), findsOneWidget);
    expect(find.byType(shad.TextButton), findsOneWidget);
  });
}
