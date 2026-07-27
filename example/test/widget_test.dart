import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn_example/main.dart';

void main() {
  testWidgets('renders the component gallery', (tester) async {
    await tester.pumpWidget(const ComponentGallery());

    expect(find.byKey(const Key('theme-preset-picker')), findsOneWidget);
    expect(find.text('Default'), findsOneWidget);
    await tester.tap(find.byKey(const Key('theme-preset-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fluent inspired').last);
    await tester.pumpAndSettle();
    expect(find.text('Fluent inspired'), findsOneWidget);
    expect(tester.takeException(), isNull);
    expect(find.text('Button variants'), findsOneWidget);
    expect(find.text('Async primary'), findsOneWidget);
    expect(find.text('Buttons with icons'), findsOneWidget);
    expect(find.text('Square icon-only buttons'), findsOneWidget);
    expect(find.text('Circular icon-only buttons'), findsOneWidget);
    expect(find.byKey(const Key('square-icon-button-add')), findsOneWidget);
    expect(
      find.byKey(const Key('square-icon-button-settings')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('icon-button-add')), findsOneWidget);
    expect(find.byKey(const Key('icon-button-settings')), findsOneWidget);

    await tester.tap(find.text('Forms'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Text fields'), findsOneWidget);
    expect(find.text('Async autocomplete'), findsOneWidget);

    await tester.tap(find.text('Data display'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Avatar and badges'), findsOneWidget);
    expect(find.text('Code snippet'), findsOneWidget);
    expect(find.text('Tracker'), findsOneWidget);

    await tester.tap(find.text('Navigation'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Breadcrumb'), findsOneWidget);
    expect(find.text('Pagination'), findsOneWidget);

    await tester.tap(find.text('Menus and commands'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Menubar'), findsOneWidget);
    expect(find.text('Command'), findsOneWidget);

    await tester.tap(find.text('Layout'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Alert variants'), findsOneWidget);
    expect(find.text('Accordion'), findsOneWidget);
    expect(find.text('Collapsible and divider'), findsOneWidget);

    await tester.tap(find.text('Structured layout'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Carousel'), findsOneWidget);
    expect(find.text('Resizable'), findsOneWidget);

    await tester.tap(find.text('Overlay'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Modal surfaces'), findsOneWidget);
    expect(find.text('Popover and hover'), findsOneWidget);
    expect(find.text('Refresh and swipe triggers'), findsOneWidget);

    await tester.tap(find.text('Motion'));
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('Hover effects'), findsOneWidget);
    expect(find.text('Animation builders'), findsOneWidget);
  });
}
