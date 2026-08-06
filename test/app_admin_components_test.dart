import 'package:flutter/gestures.dart';
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
    expect(text.style?.fontSize, 24);
    expect(tester.takeException(), isNull);
  });

  testWidgets('AppText compact roles use admin sizes', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            AppText.h3('Page'),
            AppText.body('Body'),
            AppText.caption('Meta'),
            AppText.error('Bad'),
          ],
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('Page')).style?.fontSize, 18);
    expect(tester.widget<Text>(find.text('Body')).style?.fontSize, 14);
    expect(tester.widget<Text>(find.text('Meta')).style?.fontSize, 12);
    expect(tester.widget<Text>(find.text('Bad')).style?.fontSize, 12);
  });

  testWidgets('AppText list roles use admin sizes', (tester) async {
    await tester.pumpWidget(
      _host(
        const Column(
          children: [AppText.listItem('Row'), AppText.listSecondary('Meta')],
        ),
      ),
    );

    expect(tester.widget<Text>(find.text('Row')).style?.fontSize, 14);
    expect(tester.widget<Text>(find.text('Meta')).style?.fontSize, 12);
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

  testWidgets('AppText accessories inherit role style and adaptive gaps', (
    tester,
  ) async {
    const iconData = IconData(0xe000);
    await tester.pumpWidget(
      _host(
        const AppText.caption(
          'Caption',
          leading: Icon(iconData, key: Key('leading')),
          trailing: Icon(iconData, key: Key('trailing')),
        ),
      ),
    );

    final leadingContext = tester.element(find.byKey(const Key('leading')));
    final iconTheme = IconTheme.of(leadingContext);
    final text = tester.widget<Text>(find.text('Caption'));
    final gaps = tester.widgetList<SizedBox>(find.byType(SizedBox)).toList();

    expect(iconTheme.color, text.style?.color);
    expect(iconTheme.size, 12);
    expect(gaps.where((gap) => gap.width == 4), hasLength(2));
  });

  testWidgets('AppText keeps explicit accessory color and size', (
    tester,
  ) async {
    const iconData = IconData(0xe000);
    await tester.pumpWidget(
      _host(
        const AppText.body(
          'Status',
          leading: Icon(
            iconData,
            key: Key('custom-icon'),
            color: Color(0xffff0000),
            size: 20,
          ),
          leadingGap: 2,
        ),
      ),
    );

    final icon = tester.widget<Icon>(find.byKey(const Key('custom-icon')));
    expect(icon.color, const Color(0xffff0000));
    expect(icon.size, 20);
    expect(
      tester
          .widgetList<SizedBox>(find.byType(SizedBox))
          .any((gap) => gap.width == 2),
      isTrue,
    );
  });

  testWidgets('AppText supports automatic and hover scrolling modes', (
    tester,
  ) async {
    const hoverKey = Key('hover-text');
    await tester.pumpWidget(
      _host(
        const Column(
          children: [
            SizedBox(
              width: 100,
              child: AppText.body(
                'Automatic scrolling text',
                scrollMode: AppTextScrollMode.automatic,
              ),
            ),
            SizedBox(
              width: 100,
              child: AppText.body(
                'Hover scrolling text',
                key: hoverKey,
                scrollMode: AppTextScrollMode.hover,
              ),
            ),
          ],
        ),
      ),
    );

    expect(find.byType(shad.OverflowMarquee), findsOneWidget);
    expect(
      tester
          .widget<shad.OverflowMarquee>(find.byType(shad.OverflowMarquee))
          .duration,
      const Duration(milliseconds: 2500),
    );

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: Offset.zero);
    await mouse.moveTo(tester.getCenter(find.byKey(hoverKey)));
    await tester.pump();

    expect(find.byType(shad.OverflowMarquee), findsNWidgets(2));
  });

  testWidgets('AppText.rich scrolls mixed text styles', (tester) async {
    await tester.pumpWidget(
      _host(
        const SizedBox(
          width: 120,
          child: AppText.rich(
            TextSpan(
              children: [
                TextSpan(text: 'Normal '),
                TextSpan(text: 'Large', style: TextStyle(fontSize: 24)),
              ],
            ),
            scrollMode: AppTextScrollMode.automatic,
          ),
        ),
      ),
    );

    final text = tester.widget<Text>(find.byType(Text));
    final children = (text.textSpan as TextSpan).children!;
    expect((children.last as TextSpan).style?.fontSize, 24);
    expect(find.byType(shad.OverflowMarquee), findsOneWidget);
  });

  testWidgets('AppThemeConfig.textTheme applies globally', (tester) async {
    await tester.pumpWidget(
      Localizations(
        locale: const Locale('en'),
        delegates: const [DefaultWidgetsLocalizations.delegate],
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: AppShadcnScope(
            config: AppThemeConfig.standard(
              textTheme: AppTextTheme.comfortable(),
            ),
            child: const AppText.body('Comfortable body'),
          ),
        ),
      ),
    );

    expect(
      tester.widget<Text>(find.text('Comfortable body')).style?.fontSize,
      16,
    );
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
    // Default surface (~800) is compact; force expanded so child labels are visible.
    await tester.binding.setSurfaceSize(const Size(1200, 800));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      _host(
        AppShell(
          sidebarContent: const AppSidebarContent(
            items: [
              AppSidebarMenuItem(
                id: 'components',
                label: 'Components',
                icon: AppLucideIcons.component,
                children: [
                  AppSidebarMenuItem(
                    id: 'actions',
                    label: 'Actions',
                    icon: AppLucideIcons.mousePointerClick,
                  ),
                  AppSidebarMenuItem(
                    id: 'forms',
                    label: 'Forms',
                    icon: AppLucideIcons.textCursorInput,
                  ),
                ],
              ),
            ],
          ),
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
          sidebarContent: const AppSidebarContent(
            items: [
              AppSidebarMenuItem(
                id: 'actions',
                label: 'Actions',
                icon: AppLucideIcons.mousePointerClick,
              ),
              AppSidebarMenuItem(
                id: 'forms',
                label: 'Forms',
                icon: AppLucideIcons.textCursorInput,
              ),
            ],
          ),
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
