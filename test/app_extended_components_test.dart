import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('chat and navigation bar aliases render and select', (
    tester,
  ) async {
    Key? selected;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Column(
          children: [
            const AppChat(children: [AppChatBubble(child: Text('Hello'))]),
            AppNavigationBar(
              selectedKey: selected,
              onSelected: (value) => selected = value,
              children: const [
                AppNavigationItem(
                  key: ValueKey('home'),
                  label: Text('Home'),
                  child: Text('H'),
                ),
              ],
            ),
          ],
        ),
      ),
    );

    expect(find.text('Hello'), findsOneWidget);
    await tester.tap(find.text('H'));
    expect(selected, const ValueKey('home'));
    expect(tester.takeException(), isNull);
  });

  test('window entry maps configuration and rendering primitives', () {
    final window = AppWindow(
      title: const Text('Editor'),
      bounds: const Rect.fromLTWH(0, 0, 320, 200),
    );
    expect(window.title, isA<Text>());
    expect(window.bounds, const Rect.fromLTWH(0, 0, 320, 200));
  });

  testWidgets('navigation item resolves selected internal palette colors', (
    tester,
  ) async {
    const selectedBackground = Color(0xff2457d6);
    const selectedForeground = Color(0xfff8fafc);
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controlPalette: const AppVisualPalette(
              normal: AppVisualColors(),
              selected: AppVisualColors(
                background: selectedBackground,
                foreground: selectedForeground,
              ),
            ),
          ),
        ),
        home: const AppNavigationItem(
          selected: true,
          label: Text('Selected'),
          child: Text('S'),
        ),
      ),
    );

    final item = tester.widget<NavigationItem>(find.byType(NavigationItem));
    final context = tester.element(find.byType(NavigationItem));
    final decoration = item.selectedStyle!.decoration(context, {
      WidgetState.selected,
    });
    final textStyle = item.selectedStyle!.textStyle(context, {
      WidgetState.selected,
    });
    expect((decoration as BoxDecoration).color, selectedBackground);
    expect(textStyle.color, selectedForeground);
  });
}
