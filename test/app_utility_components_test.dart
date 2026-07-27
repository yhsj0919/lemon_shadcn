import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('utility display aliases render inside a Material host', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const Column(
          children: [
            AppSkeleton(enabled: false, child: Text('Loaded')),
            AppDotIndicator(index: 1, length: 3),
            SizedBox(
              width: 180,
              child: AppOverflowMarquee(child: Text('Short text')),
            ),
            AppSelectableText('Copy me'),
          ],
        ),
      ),
    );

    expect(find.text('Loaded'), findsOneWidget);
    expect(find.byType(DotIndicator), findsOneWidget);
    expect(find.byType(OverflowMarquee), findsOneWidget);
    expect(find.byType(SelectableText), findsOneWidget);
  });
}
