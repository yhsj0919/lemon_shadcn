import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn_example/main.dart';

void main() {
  testWidgets('renders the component gallery', (tester) async {
    Future<void> expandGroup(String label) async {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> selectCategory(String label) async {
      final finder = find.text(label);
      await tester.ensureVisible(finder);
      await tester.pump(const Duration(milliseconds: 400));
      await tester.tap(finder);
      await tester.pump(const Duration(milliseconds: 400));
    }

    await tester.binding.setSurfaceSize(const Size(1400, 900));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(const ComponentGallery());
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('theme-preset-picker')), findsOneWidget);
    expect(find.text('默认'), findsOneWidget);
    await tester.tap(find.byKey(const Key('theme-preset-picker')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fluent 风格').last);
    await tester.pumpAndSettle();
    expect(find.text('Fluent 风格'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await expandGroup('场景示例');
    await selectCategory('设备管理');
    expect(find.text('搜索设备'), findsOneWidget);
    expect(find.text('世贸国际'), findsWidgets);

    await expandGroup('App 组件');
    await selectCategory('AppButton');

    expect(find.text('按钮变体'), findsOneWidget);
    expect(find.text('异步主按钮'), findsOneWidget);
    expect(find.text('带图标按钮'), findsOneWidget);
    expect(find.text('方形纯图标按钮'), findsOneWidget);
    expect(find.text('圆形纯图标按钮'), findsOneWidget);
    expect(find.byKey(const Key('square-icon-button-add')), findsOneWidget);
    expect(
      find.byKey(const Key('square-icon-button-settings')),
      findsOneWidget,
    );
    expect(find.byKey(const Key('icon-button-add')), findsOneWidget);
    expect(find.byKey(const Key('icon-button-settings')), findsOneWidget);

    await selectCategory('AppText');

    expect(find.text('局部覆盖后的标题'), findsOneWidget);

    await selectCategory('表单基础');

    expect(find.text('文本输入'), findsOneWidget);

    await selectCategory('展示');

    expect(find.text('代码片段'), findsOneWidget);
    expect(find.text('状态轨迹'), findsOneWidget);

    await selectCategory('导航');

    expect(find.text('面包屑'), findsOneWidget);
    expect(find.text('分页'), findsOneWidget);

    await selectCategory('布局');

    expect(find.text('提示变体'), findsOneWidget);

    await selectCategory('数据面板');

    expect(find.text('轮播'), findsOneWidget);
    expect(find.text('可调整尺寸'), findsOneWidget);

    await selectCategory('反馈');

    expect(find.text('模态浮层'), findsOneWidget);
    expect(find.text('气泡与悬浮'), findsOneWidget);
    expect(find.text('刷新与滑动触发器'), findsOneWidget);

    await selectCategory('其它');

    expect(find.text('悬浮效果'), findsOneWidget);
    expect(find.text('动画构建器'), findsOneWidget);
  });
}
