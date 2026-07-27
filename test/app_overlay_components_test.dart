import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('dialog, drawer, sheet and popover work in a Material host', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
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

  testWidgets('scope supplies toast and hover surface infrastructure', (
    tester,
  ) async {
    AppToastOverlay? toast;
    await tester.pumpWidget(
      material.MaterialApp(
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
