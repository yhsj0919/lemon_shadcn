import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('dialog, drawer, sheet and popover work in a Material host', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) => Wrap(
            children: [
              AppButton.outline(
                onPressed: () => AppDialog.show<void>(
                  context: context,
                  builder: (overlayContext) => AppAlertDialog(
                    title: const Text('Dialog content'),
                    actions: [
                      AppButton.outline(
                        onPressed: () => AppOverlay.close(overlayContext),
                        child: const Text('Close dialog'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Open dialog'),
              ),
              AppButton.outline(
                onPressed: () => AppDrawer.show<void>(
                  context: context,
                  builder: (overlayContext) => AppButton.outline(
                    onPressed: () => AppOverlay.close(overlayContext),
                    child: const Text('Close drawer'),
                  ),
                ),
                child: const Text('Open drawer'),
              ),
              AppButton.outline(
                onPressed: () => AppSheet.show<void>(
                  context: context,
                  builder: (overlayContext) => AppButton.outline(
                    onPressed: () => AppOverlay.close(overlayContext),
                    child: const Text('Close sheet'),
                  ),
                ),
                child: const Text('Open sheet'),
              ),
              Builder(
                builder: (anchorContext) => AppButton.outline(
                  onPressed: () => AppPopover.show<void>(
                    context: anchorContext,
                    builder: (_) => const Text('Popover content'),
                  ),
                  child: const Text('Open popover'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open dialog'));
    await tester.pumpAndSettle();
    expect(find.text('Dialog content'), findsOneWidget);
    await tester.tap(find.text('Close dialog'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open drawer'));
    await tester.pumpAndSettle();
    expect(find.text('Close drawer'), findsOneWidget);
    await tester.tap(find.text('Close drawer'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();
    expect(find.text('Close sheet'), findsOneWidget);
    await tester.tap(find.text('Close sheet'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open popover'));
    await tester.pumpAndSettle();
    expect(find.text('Popover content'), findsOneWidget);
  });

  testWidgets('dialog buttons default to plain motion', (tester) async {
    late AppButtonConfig resolved;

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) => AppButton.outline(
            onPressed: () => AppDialog.show<void>(
              context: context,
              builder: (dialogContext) => AppAlertDialog(
                title: const Text('Confirm'),
                actions: [
                  Builder(
                    builder: (inner) {
                      resolved = AppButtonConfig.resolve(inner, null);
                      return AppButton.primary(
                        onPressed: () => AppOverlay.close(dialogContext),
                        child: const Text('OK'),
                      );
                    },
                  ),
                ],
              ),
            ),
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(resolved.hoverLift, isFalse);
    expect(resolved.pressEffect, AppButtonPressEffect.none);
  });

  testWidgets('form dialog keeps content body color and constraints', (
    tester,
  ) async {
    Color? formContentColor;
    Color? alertContentColor;
    late Color mutedForeground;

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) {
            mutedForeground =
                ShadcnTheme.of(context).colorScheme.mutedForeground;
            return Column(
              children: [
                AppButton.outline(
                  onPressed: () => AppDialog.show<void>(
                    context: context,
                    builder: (dialogContext) => AppFormDialog(
                      title: const Text('Edit'),
                      constraints: const BoxConstraints(maxWidth: 360),
                      content: Builder(
                        builder: (inner) {
                          formContentColor =
                              DefaultTextStyle.of(inner).style.color;
                          return const Text('Form body copy');
                        },
                      ),
                      actions: [
                        AppButton.outline(
                          onPressed: () {
                            AppOverlay.close(dialogContext);
                          },
                          child: const Text('Close form'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Open form'),
                ),
                AppButton.outline(
                  onPressed: () => AppDialog.show<void>(
                    context: context,
                    builder: (dialogContext) => AppAlertDialog(
                      title: const Text('Confirm'),
                      content: Builder(
                        builder: (inner) {
                          alertContentColor =
                              DefaultTextStyle.of(inner).style.color;
                          return const Text('Alert body copy');
                        },
                      ),
                      actions: [
                        AppButton.outline(
                          onPressed: () {
                            AppOverlay.close(dialogContext);
                          },
                          child: const Text('Close alert'),
                        ),
                      ],
                    ),
                  ),
                  child: const Text('Open alert'),
                ),
              ],
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open form'));
    await tester.pumpAndSettle();
    expect(find.text('Form body copy'), findsOneWidget);
    expect(formContentColor, isNot(equals(mutedForeground)));
    final constrained = tester.widget<ConstrainedBox>(
      find.descendant(
        of: find.byType(AppFormDialog),
        matching: find.byType(ConstrainedBox),
      ),
    );
    expect(constrained.constraints.maxWidth, 360);
    await tester.tap(find.text('Close form'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Open alert'));
    await tester.pumpAndSettle();
    expect(alertContentColor, equals(mutedForeground));
    await tester.tap(find.text('Close alert'));
    await tester.pumpAndSettle();
  });

  testWidgets('scope supplies toast and hover surface infrastructure', (
    tester,
  ) async {
    AppToastOverlay? toast;
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Builder(
          builder: (context) => Column(
            children: [
              AppButton.primary(
                onPressed: () => toast = AppToast.show(
                  context: context,
                  title: 'Saved',
                  showDuration: const Duration(seconds: 1),
                ),
                child: const Text('Toast'),
              ),
              const AppHoverCard(hoverBuilder: _hover, child: Text('Hover')),
              AppTooltip(
                tooltip: (context) => const Text('Tip'),
                child: const Text('Help'),
              ),
            ],
          ),
        ),
      ),
    );
    await tester.tap(find.text('Toast'));
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('Saved'), findsOneWidget);
    expect(toast?.isShowing, isTrue);
    toast!.close();
    await tester.pump(const Duration(seconds: 2));
    expect(toast!.isShowing, isFalse);
  });
}

Widget _hover(BuildContext context) => const Text('Hover content');
