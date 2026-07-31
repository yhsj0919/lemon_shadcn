# lemon_shadcn

基于 `shadcn_flutter` 的低侵入 Flutter 应用组件层。它可以直接与现有
`MaterialApp` 共存，不要求迁移到 `ShadcnApp`。本仓库不发布到 pub.dev，请通过
Git / path / git dependency 接入。

## 接入

默认入口 `lemon_shadcn.dart` **只导出 App 前缀 API**，不会混入上游
`shadcn_flutter` 组件，因此可以直接与现有 Material 页面共存，无需给 Material
加前缀：

```dart
import 'package:flutter/material.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

MaterialApp(
  builder: AppShadcnScope.builder(
    config: AppThemeConfig.standard(
      primary: const Color(0xFF2563EB), // 品牌主色；省略则用 zinc 默认
      radius: .6,
    ),
  ),
  home: const ExistingPage(),
);
```

页面继续用 Material，需要时再换成 App 组件：

```dart
AppButton.primary(onPressed: save, child: const Text('Save'));

AppTextFormField.email(
  name: 'email',
  label: 'Email',
  required: true,
);
```

明确需要上游能力（如 `Gap`、`Card`、shadcn `Theme`）时再引入：

```dart
import 'package:lemon_shadcn/shadcn.dart';
// 或：import 'package:shadcn_flutter/shadcn_flutter.dart';
```

图标与设计主题已通过 App 别名从默认入口导出，无需再引上游：

```dart
Icon(AppLucideIcons.plus);

final colors = ShadcnTheme.of(context).colorScheme;
final theme = AppThemeConfig(
  lightTheme: AppThemeData(
    colorScheme: AppColorSchemes.zinc(AppThemeMode.light),
    typography: AppTypography.system(), // 默认；也可用 AppTypography.geist()
  ),
  textTheme: AppTextTheme.admin().copyWith(
    title: const TextStyle(fontWeight: FontWeight.w700),
  ),
);
```

语义文本直接用变体，少改字号：

```dart
AppText.h3('页面标题');
AppText.body('正文');
AppText.helper('表单说明');
AppText.error('校验失败');
```

> `AppTheme` 仍是配置 Scope（[AppThemeConfig]）；上游 shadcn `Theme` 对应
> `ShadcnTheme`，避免撞名。
>
> `AppShadcnScope` 默认会把 shadcn 的主色与 sans `fontFamily` 同步进 Material
> `ThemeData`，便于混用 Material 控件。可用 `syncMaterialTheme: false` 关闭。

与未加前缀的 `material.dart` 同时导入上游时仍会有命名冲突；需要上游时请：

```dart
import 'package:lemon_shadcn/shadcn.dart' as shad;
```

`AppShadcnScope` 会补齐上游主题、Material Surface、Overlay、Drawer、Toast 和
本地化 fallback，但不会替换现有 Navigator、路由或页面结构。

## Form 与异步提交

字段继续兼容 Flutter 原生 `FormField` 生命周期。需要统一收集值、异步验证或跨字段
验证时，再使用 `AppFormController`：

```dart
final form = AppFormController();
late final submit = form.createSubmitAction((values) async {
  await api.save(values);
});

AppForm(
  controller: form,
  child: Column(
    children: [
      AppTextFormField(name: 'title', label: 'Title'),
      AppFormErrorSummary(controller: form),
      AppButton.primary(action: submit, child: const Text('Submit')),
    ],
  ),
);
```

调用方负责 dispose 自己创建的 Controller 和 Action。Select、AutoComplete 等异步输入
只消费格式化的 `AppOption<T>`；Form 不关心 request/response 协议。

## 全局配置

`AppThemeConfig` 集中管理：

- light/dark shadcn theme 与圆角；
- 控件高度、内边距、图标尺寸和内容间距（默认高度 34，无需特意配 `height: 40`）；
- Hover/Press/Depth 动画；
- 根据背景、边框、Accent 或组件颜色派生的动态阴影；
- selected/hovered/focused/disabled/error 状态 Palette；
- 技术异常到用户文案的 `errorPresenter`。

局部例外可使用组件显式参数、`AppButtonConfig`、`AppVisualStyle` 或上游
`ComponentTheme`，无需修改上游源码。

内置主题预设可以直接用于全局 Scope，并在此基础上覆盖少量产品 token：

```dart
final theme = AppThemeConfig.preset(AppThemePreset.apple);

MaterialApp(builder: AppShadcnScope.builder(config: theme));
```

仅改品牌主色时优先：

```dart
AppThemeConfig.standard(primary: Color(0xFF2563EB));
```

当前提供 `standard`、`apple`、`fluent`、`material`；后三者是相应设计语言的灵感基线，
仍保持 Lemon Shadcn 的统一 API 和上游适配方式。

## 组件与 Demo

Demo 使用后台组件库布局：左侧为分组导航，右侧展示当前组件页面，页头可切换主题预设。
`AppShell` 不绑定路由库，业务项目可以使用任意路由或本地状态驱动。

```dart
AppShell(
  destinations: const [
    AppNavDestination(
      id: 'components',
      label: 'Components',
      icon: AppLucideIcons.component,
      children: [
        AppNavDestination(
          id: 'forms',
          label: 'Forms',
          icon: AppLucideIcons.textCursorInput,
        ),
      ],
    ),
  ],
  selectedId: selectedId,
  onDestinationSelected: selectPage,
  pageTitle: 'Forms',
  child: const FormsPage(),
);
```

当前审计基线为 `shadcn_flutter 0.0.53`，84 项组件均有 App 公共入口，并在 example
中按 Actions、Forms、Data display、Navigation、Menus、Layout、Structured layout、
Overlay、Motion 分类展示。完整映射见
[`docs/component-inventory.md`](docs/component-inventory.md)。

## 已知边界

- 上游仍为 0.x；升级必须重新跑 `tool/check_upstream.dart` 并复核映射。
- 上游 `RawSortableList` 尚未实现，`AppSortableInput` 暂用 Flutter
  `ReorderableListView`；Chip 替换也在 App 层规避了上游残留映射问题。
- Image 选择由业务注入格式化领域值，不绑定平台插件。
- 默认文案以英文为主；中文产品请覆盖 `errorPresenter`、validators 和局部 builders。
- 更细的人工验收项见 [`docs/test-handoff.md`](docs/test-handoff.md)。

## 验证

```shell
flutter pub get
flutter analyze
dart run tool/check_upstream.dart
flutter test
cd example
flutter test
flutter run
```

上游版本变化时，`check_upstream.dart` 会要求 pubspec、lock、84 项清单基线和 Demo
覆盖保持一致。架构决策和实时进度分别见
[`docs/development-plan.md`](docs/development-plan.md) 与
[`docs/development-status.md`](docs/development-status.md)。
