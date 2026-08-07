import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('badge facade maps semantic variants to upstream widgets', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Wrap(
          children: [
            AppBadge.primary(child: const Text('Primary')),
            AppBadge.secondary(child: const Text('Secondary')),
            AppBadge.outline(child: const Text('Outline')),
            AppBadge.destructive(child: const Text('Destructive')),
            AppBadge.info(child: const Text('Info')),
            AppBadge.success(child: const Text('Success')),
            AppBadge.success(
              size: AppBadgeSize.small,
              child: const Text('SuccessSmall'),
            ),
            AppBadge.success(
              size: AppBadgeSize.large,
              child: const Text('SuccessLarge'),
            ),
            AppBadge.success(
              appearance: AppBadgeStyle.plain,
              child: const Text('SuccessPlain'),
            ),
            AppBadge.success(
              appearance: AppBadgeStyle.outline,
              child: const Text('SuccessOutline'),
            ),
            AppBadge.success(
              appearance: AppBadgeStyle.solid,
              child: const Text('SuccessSolid'),
            ),
            AppBadge.success(
              fontWeight: FontWeight.bold,
              child: const Text('SuccessBold'),
            ),
            AppBadge.warning(child: const Text('Warning')),
            AppBadge.destructive(
              appearance: AppBadgeStyle.soft,
              child: const Text('SoftDestructive'),
            ),
          ],
        ),
      ),
    );

    expect(find.byType(shad.PrimaryBadge), findsOneWidget);
    expect(find.byType(shad.OutlineBadge), findsOneWidget);
    expect(find.byType(shad.DestructiveBadge), findsOneWidget);
    expect(find.byType(shad.SecondaryBadge), findsNWidgets(11));

    for (final label in [
      'Primary',
      'Secondary',
      'Outline',
      'Destructive',
      'Info',
      'Success',
      'SuccessSmall',
      'SuccessLarge',
      'SuccessPlain',
      'SuccessOutline',
      'SuccessSolid',
      'SuccessBold',
      'Warning',
      'SoftDestructive',
    ]) {
      expect(find.text(label), findsOneWidget);
    }

    final smallContext = tester.element(find.text('SuccessSmall'));
    final largeContext = tester.element(find.text('SuccessLarge'));
    final boldContext = tester.element(find.text('SuccessBold'));
    final warningContext = tester.element(find.text('Warning'));
    final destructiveContext = tester.element(find.text('SoftDestructive'));
    expect(DefaultTextStyle.of(smallContext).style.fontSize, 10);
    expect(DefaultTextStyle.of(largeContext).style.fontSize, 14);
    expect(DefaultTextStyle.of(boldContext).style.fontWeight, FontWeight.bold);
    expect(
      DefaultTextStyle.of(warningContext).style.color,
      const Color(0xffd97706),
    );
    expect(
      DefaultTextStyle.of(destructiveContext).style.color,
      const Color(0xffef4444),
    );
    expect(
      AppBadgeSize.normal.padding,
      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    );
    expect(AppBadgeSize.small.contentGap, 2);
    expect(AppBadgeSize.normal.contentGap, 4);
    expect(AppBadgeSize.large.contentGap, 6);
  });
}
