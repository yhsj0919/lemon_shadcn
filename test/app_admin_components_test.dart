import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

Widget _host(Widget child, {Locale locale = const Locale('en')}) {
  return Localizations(
    locale: locale,
    delegates: const [DefaultWidgetsLocalizations.delegate],
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: AppShadcnScope(child: child),
    ),
  );
}

void main() {
  testWidgets('AppText resolves semantic typography', (tester) async {
    await tester.pumpWidget(_host(const AppText.h1('Admin heading')));

    final text = tester.widget<Text>(find.text('Admin heading'));
    expect(text.style?.fontSize, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppTextTheme overrides a semantic role', (tester) async {
    await tester.pumpWidget(
      _host(
        const shad.ComponentTheme<AppTextTheme>(
          data: AppTextTheme(h1: TextStyle(fontSize: 42)),
          child: AppText.h1('Custom heading'),
        ),
      ),
    );

    final text = tester.widget<Text>(find.text('Custom heading'));
    expect(text.style?.fontSize, 42);
  });

  testWidgets('scope provides Chinese shadcn localizations', (tester) async {
    late String saveLabel;
    await tester.pumpWidget(
      _host(
        Builder(
          builder: (context) {
            saveLabel = shad.ShadcnLocalizations.of(context).buttonSave;
            return const SizedBox.shrink();
          },
        ),
        locale: const Locale('zh', 'CN'),
      ),
    );

    expect(saveLabel, '保存');
  });

  testWidgets('AppShell selects a destination', (tester) async {
    var selected = 'actions';
    await tester.pumpWidget(
      _host(
        AppShell(
          destinations: const [
            AppNavDestination(
              id: 'components',
              label: 'Components',
              icon: AppLucideIcons.component,
              children: [
                AppNavDestination(
                  id: 'actions',
                  label: 'Actions',
                  icon: AppLucideIcons.mousePointerClick,
                ),
                AppNavDestination(
                  id: 'forms',
                  label: 'Forms',
                  icon: AppLucideIcons.textCursorInput,
                ),
              ],
            ),
          ],
          selectedId: selected,
          onDestinationSelected: (value) => selected = value,
          pageTitle: 'Actions',
          child: const Text('Page body'),
        ),
      ),
    );

    await tester.tap(find.text('Forms'));
    await tester.pump();
    expect(selected, 'forms');
    expect(find.text('Page body'), findsOneWidget);
  });

  testWidgets('AppShell uses compact navigation on narrow screens', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(600, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        AppShell(
          destinations: const [
            AppNavDestination(
              id: 'actions',
              label: 'Actions',
              icon: AppLucideIcons.mousePointerClick,
            ),
            AppNavDestination(
              id: 'forms',
              label: 'Forms',
              icon: AppLucideIcons.textCursorInput,
            ),
          ],
          selectedId: 'actions',
          onDestinationSelected: (_) {},
          pageTitle: 'Actions',
          child: const Text('Compact body'),
        ),
      ),
    );

    expect(find.text('Compact body'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
