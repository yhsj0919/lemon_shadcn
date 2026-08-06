import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

Widget _host(Widget child) => MaterialApp(
  builder: AppShadcnScope.builder(),
  home: Center(child: child),
);

void main() {
  testWidgets('shadow resolver reduces layers during a transition', (
    tester,
  ) async {
    late List<BoxShadow> normal;
    late List<BoxShadow> reduced;
    late List<BoxShadow> disabled;

    await tester.pumpWidget(
      _host(
        Column(
          children: [
            Builder(
              builder: (context) {
                final shadows = AppTheme.of(context).shadows;
                normal = shadows.resolve(context);
                disabled = shadows.resolve(
                  context,
                  quality: AppShadowQuality.disabled,
                );
                return const SizedBox.shrink();
              },
            ),
            AppPageTransitionScope(
              phase: AppPageTransitionPhase.entering,
              child: Builder(
                builder: (context) {
                  reduced = AppTheme.of(context).shadows.resolve(context);
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );

    expect(normal, hasLength(1));
    expect(reduced, hasLength(1));
    expect(reduced.single.blurRadius, lessThanOrEqualTo(6));
    expect(disabled, isEmpty);
  });

  testWidgets('page transition exposes phase and defers opt-in heavy content', (
    tester,
  ) async {
    final page = ValueNotifier(0);
    addTearDown(page.dispose);

    await tester.pumpWidget(
      _host(
        ValueListenableBuilder<int>(
          valueListenable: page,
          builder: (context, value, child) => SizedBox(
            width: 300,
            height: 120,
            child: AppPageTransition(
              duration: const Duration(milliseconds: 200),
              child: ColoredBox(
                key: ValueKey(value),
                color: Colors.white,
                child: AppDeferredDuringTransition(
                  placeholder: const Text('Deferred'),
                  child: Text('Heavy $value'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Heavy 0'), findsOneWidget);

    page.value = 1;
    await tester.pump();

    expect(find.text('Deferred'), findsWidgets);
    expect(
      find.descendant(
        of: find.byType(AppPageTransition),
        matching: find.byType(RepaintBoundary),
      ),
      findsWidgets,
    );

    await tester.pumpAndSettle();
    expect(find.text('Heavy 1'), findsOneWidget);
    expect(find.text('Deferred'), findsNothing);
  });

  testWidgets('elevated card uses transition-aware theme shadows', (
    tester,
  ) async {
    const normalKey = Key('normal-card');
    const reducedKey = Key('reduced-card');
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            AppCard.elevated(key: normalKey, child: Text('Normal')),
            AppPageTransitionScope(
              phase: AppPageTransitionPhase.entering,
              child: AppCard.elevated(key: reducedKey, child: Text('Reduced')),
            ),
          ],
        ),
      ),
    );

    shad.Card innerCard(Key wrapperKey) => tester.widget<shad.Card>(
      find.descendant(
        of: find.byKey(wrapperKey),
        matching: find.byType(shad.Card),
      ),
    );

    expect(innerCard(normalKey).boxShadow, hasLength(1));
    expect(innerCard(reducedKey).boxShadow, hasLength(1));
  });

  testWidgets('soft card derives fill, border, and shadow from one color', (
    tester,
  ) async {
    const accent = Color(0xffd97706);
    final config = AppThemeConfig.standard();
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(config: config),
        home: const Center(
          child: AppCard.soft(color: accent, child: Text('Tinted card')),
        ),
      ),
    );

    final card = tester.widget<shad.Card>(find.byType(shad.Card));
    expect(card.filled, isTrue);
    expect(card.borderColor, accent);
    expect(
      card.fillColor,
      Color.alphaBlend(
        accent.withValues(alpha: 0.06),
        config.lightTheme.colorScheme.background,
      ),
    );
    expect(card.boxShadow, hasLength(1));
    expect(card.boxShadow!.single.color, accent.withValues(alpha: 0.12));
  });
}
