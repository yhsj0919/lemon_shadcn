import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('image input uses injected picker and image defaults', (
    tester,
  ) async {
    var images = <AppFileSelection>[];
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: StatefulBuilder(
          builder: (context, setState) => AppImageInput(
            files: images,
            multiple: false,
            pick: () async => const <AppFileSelection>[
              AppFileSelection(name: 'avatar.png', extension: 'png'),
            ],
            onChanged: (value) => setState(() => images = value),
          ),
        ),
      ),
    );

    await tester.tap(find.text('选择图片'));
    await tester.pump();
    expect(find.text('avatar.png'), findsOneWidget);
    expect(images.single.name, 'avatar.png');
  });

  testWidgets('image input form field participates in native Form', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Form(
          child: AppImageInputFormField(
            label: '封面',
            pick: () async => const <AppFileSelection>[],
          ),
        ),
      ),
    );

    expect(find.text('封面'), findsOneWidget);
    expect(find.text('选择图片'), findsOneWidget);
  });
}
