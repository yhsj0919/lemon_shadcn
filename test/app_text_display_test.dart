import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('display area and trailing action handle taps independently', (
    tester,
  ) async {
    var displayTaps = 0;
    var actionTaps = 0;

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppTextDisplay(
          text: '只读内容',
          onTap: () => displayTaps++,
          trailing: GestureDetector(
            key: const Key('action'),
            onTap: () => actionTaps++,
            child: const Text('复制'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('只读内容'));
    expect(displayTaps, 1);
    expect(actionTaps, 0);

    await tester.tap(find.byKey(const Key('action')));
    expect(displayTaps, 1);
    expect(actionTaps, 1);
  });

  testWidgets('form field exposes its display value to AppFormController', (
    tester,
  ) async {
    final controller = AppFormController();

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: AppTextDisplayFormField(
            name: 'status',
            label: '状态',
            value: '已完成',
          ),
        ),
      ),
    );

    expect(controller.value<String>('status'), '已完成');
    expect(find.text('状态'), findsOneWidget);
    expect(find.text('已完成'), findsOneWidget);
    expect(find.byType(EditableText), findsNothing);
  });

  testWidgets('shows placeholder for an empty value', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const AppTextDisplay(text: '', placeholder: '暂无内容'),
      ),
    );

    expect(find.text('暂无内容'), findsOneWidget);
  });
}
