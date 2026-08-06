import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('sidebar selection defaults to primary tinted highlight', (
    tester,
  ) async {
    const primary = Color(0xff7c3aed);
    final config = AppThemeConfig.standard(primary: primary);
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(config: config),
        home: SizedBox(
          width: 260,
          height: 300,
          child: AppSidebar(
            content: const AppSidebarContent(
              items: [
                AppSidebarMenuItem(
                  id: 'selected',
                  label: 'Selected menu',
                  icon: AppLucideIcons.house,
                ),
              ],
            ),
            selectedId: 'selected',
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final buttonFinder = find.ancestor(
      of: find.text('Selected menu'),
      matching: find.byType(shad.Button),
    );
    final button = tester.widget<shad.Button>(buttonFinder);
    final context = tester.element(buttonFinder);
    final decoration = button.style.decoration(context, const {});
    final textStyle = button.style.textStyle(context, const {});

    expect(
      (decoration as BoxDecoration).color,
      Color.alphaBlend(
        primary.withValues(alpha: 0.08),
        config.lightTheme.colorScheme.background,
      ),
    );
    expect(textStyle.color, primary);
  });

  testWidgets('sidebar selectedColor overrides the theme primary', (
    tester,
  ) async {
    const custom = Color(0xff059669);
    final config = AppThemeConfig.standard(primary: const Color(0xff7c3aed));
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(config: config),
        home: SizedBox(
          width: 260,
          height: 300,
          child: AppSidebar(
            selectedColor: custom,
            content: const AppSidebarContent(
              items: [
                AppSidebarMenuItem(
                  id: 'selected',
                  label: 'Custom menu',
                  icon: AppLucideIcons.house,
                ),
              ],
            ),
            selectedId: 'selected',
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );

    final buttonFinder = find.ancestor(
      of: find.text('Custom menu'),
      matching: find.byType(shad.Button),
    );
    final button = tester.widget<shad.Button>(buttonFinder);
    final context = tester.element(buttonFinder);
    final decoration = button.style.decoration(context, const {});
    final textStyle = button.style.textStyle(context, const {});

    expect(
      (decoration as BoxDecoration).color,
      Color.alphaBlend(
        custom.withValues(alpha: 0.08),
        config.lightTheme.colorScheme.background,
      ),
    );
    expect(textStyle.color, custom);
  });

  testWidgets('navigation item selectedColor overrides the theme primary', (
    tester,
  ) async {
    const custom = Color(0xff0f9f6e);
    final config = AppThemeConfig.standard(primary: const Color(0xff7c3aed));
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(config: config),
        home: const AppNavigationItem(
          selected: true,
          selectedColor: custom,
          label: Text('Custom item'),
          child: Icon(Icons.person),
        ),
      ),
    );

    final itemFinder = find.byType(shad.NavigationItem);
    final item = tester.widget<shad.NavigationItem>(itemFinder);
    final context = tester.element(itemFinder);
    final decoration = item.selectedStyle!.decoration(context, const {});
    final textStyle = item.selectedStyle!.textStyle(context, const {});
    final iconTheme = item.selectedStyle!.iconTheme(context, const {});

    expect(
      (decoration as BoxDecoration).color,
      Color.alphaBlend(
        custom.withValues(alpha: 0.08),
        config.lightTheme.colorScheme.background,
      ),
    );
    expect(textStyle.color, custom);
    expect(iconTheme.color, custom);
  });
}
