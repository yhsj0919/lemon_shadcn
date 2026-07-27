# lemon_shadcn

基于 `shadcn_flutter` 的低侵入 Flutter 应用组件层。它可以直接与现有
`MaterialApp` 共存，不要求迁移到 `ShadcnApp`。

## 接入

只需在现有应用的 builder 中配置一次：

```dart
import 'package:flutter/material.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

MaterialApp(
  builder: AppShadcnScope.builder(
    config: AppThemeConfig.standard(
      radius: .6,
      controls: const AppControlMetrics(height: 40),
    ),
  ),
  home: const ExistingPage(),
);
```

之后页面只表达内容和行为：

```dart
AppButton.primary(onPressed: save, child: const Text('Save'));

AppTextFormField.email(
  name: 'email',
  label: 'Email',
  required: true,
);
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
- 控件高度、内边距、图标尺寸和内容间距；
- Hover/Press/Depth 动画；
- 根据背景、边框、Accent 或组件颜色派生的动态阴影；
- selected/hovered/focused/disabled/error 状态 Palette；
- 技术异常到用户文案的 `errorPresenter`。

局部例外可使用组件显式参数、`AppButtonConfig`、`AppVisualStyle` 或上游
`ComponentTheme`，无需修改上游源码。

内置主题预设可以直接用于全局 Scope，并在此基础上覆盖少量产品 token：

```dart
final theme = AppThemeConfig.preset(AppThemePreset.apple).copyWith(
  controls: const AppControlMetrics(height: 40),
);

MaterialApp(builder: AppShadcnScope.builder(config: theme));
```

当前提供 `standard`、`apple`、`fluent`、`material`；后三者是相应设计语言的灵感基线，
仍保持 Lemon Shadcn 的统一 API 和上游适配方式。

## 组件与 Demo

当前审计基线为 `shadcn_flutter 0.0.53`，84 项组件均有 App 公共入口，并在 example
中按 Actions、Forms、Data display、Navigation、Menus、Layout、Structured layout、
Overlay、Motion 分类展示。完整映射见
[`docs/component-inventory.md`](docs/component-inventory.md)。

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
