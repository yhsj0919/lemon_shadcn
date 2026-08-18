import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
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

  testWidgets('sidebar text selection style tints the item and colors text', (
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
            selectionStyle: AppSidebarSelectionStyle.text,
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

  testWidgets('sidebar fill selection style uses a solid accent background', (
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
            selectionStyle: AppSidebarSelectionStyle.fill,
            content: const AppSidebarContent(
              items: [
                AppSidebarMenuItem(
                  id: 'selected',
                  label: 'Filled menu',
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
      of: find.text('Filled menu'),
      matching: find.byType(shad.Button),
    );
    final button = tester.widget<shad.Button>(buttonFinder);
    final context = tester.element(buttonFinder);
    final decoration = button.style.decoration(context, const {});
    final textStyle = button.style.textStyle(context, const {});

    expect((decoration as BoxDecoration).color, primary);
    expect(textStyle.color, config.lightTheme.colorScheme.primaryForeground);
  });

  testWidgets('sidebar can skip parent highlight when a child is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SizedBox(
          width: 260,
          height: 320,
          child: AppSidebar(
            selectParentWhenChildSelected: false,
            content: const AppSidebarContent(
              items: [
                AppSidebarMenuItem(
                  id: 'parent',
                  label: 'Parent',
                  icon: AppLucideIcons.folder,
                  children: [
                    AppSidebarMenuItem(
                      id: 'child',
                      label: 'Child',
                      icon: AppLucideIcons.file,
                    ),
                  ],
                ),
              ],
            ),
            selectedId: 'child',
            onDestinationSelected: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final parentButton = tester.widget<shad.Button>(
      find.ancestor(
        of: find.text('Parent'),
        matching: find.byType(shad.Button),
      ),
    );
    final childButton = tester.widget<shad.Button>(
      find.ancestor(
        of: find.text('Child'),
        matching: find.byType(shad.Button),
      ),
    );
    final parentContext = tester.element(
      find.ancestor(
        of: find.text('Parent'),
        matching: find.byType(shad.Button),
      ),
    );
    final childContext = tester.element(
      find.ancestor(
        of: find.text('Child'),
        matching: find.byType(shad.Button),
      ),
    );
    final parentDecoration =
        parentButton.style.decoration(parentContext, const {}) as BoxDecoration;
    final childDecoration =
        childButton.style.decoration(childContext, const {}) as BoxDecoration;
    final childTextStyle =
        childButton.style.textStyle(childContext, const {});

    expect(parentDecoration.color, isNot(childDecoration.color));
    expect(childTextStyle.color, isNotNull);
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
