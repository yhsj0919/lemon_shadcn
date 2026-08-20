import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('double click edits and Enter saves text', (tester) async {
    var value = '旧名称';
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.StatefulBuilder(
          builder: (context, setState) => AppInlineEdit.text(
            value: value,
            onSaved: (next) => setState(() => value = next),
          ),
        ),
      ),
    );

    await _doubleTap(tester, find.text('旧名称'));
    await tester.pump();
    await tester.enterText(find.byType(AppTextFormField), '新名称');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();

    expect(value, '新名称');
    expect(find.text('新名称'), findsOneWidget);
  });

  testWidgets('empty text still has a tappable display area', (tester) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppInlineEdit.text(value: '', onSaved: (_) {}),
        ),
      ),
    );

    final inlineEdit = find.byType(AppInlineEdit<String>);
    expect(tester.getSize(inlineEdit).height, 32);

    await _doubleTap(tester, inlineEdit);

    expect(find.byType(AppTextFormField), findsOneWidget);
  });

  testWidgets('display and edit states share the form control height', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Align(
          alignment: Alignment.topLeft,
          child: AppInlineEdit.text(value: '名称', onSaved: (_) {}),
        ),
      ),
    );

    Finder fixedArea() => find.descendant(
      of: find.byType(AppInlineEdit<String>),
      matching: find.byWidgetPredicate(
        (widget) => widget is SizedBox && widget.height == 32,
      ),
    );

    expect(tester.getSize(fixedArea().first).height, 32);
    await _doubleTap(tester, find.text('名称'));
    expect(tester.getSize(fixedArea().first).height, 32);
  });

  testWidgets('clicking non-focusable blank space exits edit mode', (
    tester,
  ) async {
    var saves = 0;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: Column(
          children: [
            AppInlineEdit.text(value: '设备名称', onSaved: (_) => saves++),
            const SizedBox(key: Key('blank'), width: 300, height: 100),
          ],
        ),
      ),
    );

    await _doubleTap(tester, find.text('设备名称'));
    await tester.tap(find.byKey(const Key('blank')), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.byType(AppTextFormField), findsNothing);
    expect(find.text('设备名称'), findsOneWidget);
    expect(saves, 0);
  });

  testWidgets('invalid value on blur cancels and restores display value', (
    tester,
  ) async {
    var saves = 0;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.Column(
          children: [
            AppInlineEdit.text(
              value: '有效值',
              validator: (value) => value.isEmpty ? '不能为空' : null,
              onSaved: (_) => saves++,
            ),
            const material.TextButton(onPressed: null, child: Text('外部')),
          ],
        ),
      ),
    );

    await _doubleTap(tester, find.text('有效值'));
    await tester.pump();
    await tester.enterText(find.byType(AppTextFormField), '');
    material.FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(saves, 0);
    expect(find.text('有效值'), findsOneWidget);
    expect(find.byType(AppTextFormField), findsNothing);
  });

  testWidgets('save failure keeps editor open and exposes the error', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppInlineEdit.text(
          value: '原值',
          onSaved: (_) => Future<void>.error('保存失败'),
        ),
      ),
    );

    await _doubleTap(tester, find.text('原值'));
    await tester.pump();
    await tester.enterText(find.byType(AppTextFormField), '修改值');
    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    await tester.pump();

    expect(find.byType(AppTextFormField), findsOneWidget);
    expect(find.textContaining('保存失败'), findsOneWidget);
  });

  testWidgets('control variant commits popup-style values on change', (
    tester,
  ) async {
    var saved = false;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppInlineEdit<bool>.control(
          value: false,
          displayBuilder: (_, value) => Text('$value'),
          commitOnChanged: true,
          saveOnBlur: false,
          onSaved: (value) => saved = value,
          editorBuilder: (_, details) => _DisposeEmitter(
            onTap: () => details.onChanged(true),
            onDispose: () => details.onChanged(false),
          ),
        ),
      ),
    );

    await _doubleTap(tester, find.text('false'));
    await tester.pump();
    await tester.tap(find.text('切换'));
    await tester.pumpAndSettle();

    expect(saved, isTrue);
    expect(find.text('true'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('star rating saves the last settled gesture value', (
    tester,
  ) async {
    double? saved;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppInlineEdit.starRating(
          value: 1,
          onSaved: (value) => saved = value,
        ),
      ),
    );

    await _doubleTap(tester, find.text('1.0 / 5.0'));
    final rating = tester.widget<AppStarRating>(find.byType(AppStarRating));
    rating.onChanged!(2);
    rating.onChanged!(3);
    rating.onChanged!(4);
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    expect(saved, 4);
    expect(find.text('4.0 / 5.0'), findsOneWidget);
  });

  testWidgets('unchanged values exit without calling onSaved', (tester) async {
    var saves = 0;
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppInlineEdit.text(value: '未修改', onSaved: (_) => saves++),
      ),
    );

    await _doubleTap(tester, find.text('未修改'));
    material.FocusManager.instance.primaryFocus?.unfocus();
    await tester.pumpAndSettle();

    expect(saves, 0);
    expect(find.text('未修改'), findsOneWidget);
    expect(find.byType(AppTextFormField), findsNothing);
  });
}

class _DisposeEmitter extends StatefulWidget {
  const _DisposeEmitter({required this.onTap, required this.onDispose});

  final VoidCallback onTap;
  final VoidCallback onDispose;

  @override
  State<_DisposeEmitter> createState() => _DisposeEmitterState();
}

class _DisposeEmitterState extends State<_DisposeEmitter> {
  @override
  void dispose() {
    widget.onDispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      GestureDetector(onTap: widget.onTap, child: const Text('切换'));
}

Future<void> _doubleTap(WidgetTester tester, Finder finder) async {
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 40));
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 400));
}
