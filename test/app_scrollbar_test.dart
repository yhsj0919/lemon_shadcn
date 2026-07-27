import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('managed scrollbar shares an attached scroll controller', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Align(
          alignment: Alignment.topLeft,
          child: SizedBox(
            width: 200,
            height: 60,
            child: AppScrollbarView(
              thumbVisibility: true,
              child: SizedBox(height: 240, child: Text('Scrollable content')),
            ),
          ),
        ),
      ),
    );

    final scrollable = tester.widget<SingleChildScrollView>(
      find.byType(SingleChildScrollView),
    );
    final scrollbar = tester.widget<AppScrollbar>(find.byType(AppScrollbar));
    expect(scrollable.controller, same(scrollbar.controller));
    expect(scrollbar.controller.hasClients, isTrue);

    scrollbar.controller.jumpTo(40);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(tester.takeException(), isNull);
  });
}
