# Lemon Shadcn 集中测试清单

测试基线：`shadcn_flutter 0.0.53`，84 项组件，2026-07-25。

## 启动

```shell
flutter analyze
dart run tool/check_upstream.dart
flutter test
cd example
flutter test
flutter run -d windows
```

## 建议测试顺序

1. Actions：五种 Button、自动异步 Loading、两个按钮共享 Action、Toggle。
2. Forms：固定宽度、错误槽、无 Label Tooltip、Password 显隐、Select、AutoComplete、
   分页/Retry、日期时间、颜色、图片、排序、对象输入、跨字段验证与异步提交。
3. Data display：Avatar、进度、Ticker、Tracker、快捷键、异步状态和 Chat。
4. Navigation 与 Menus：选中内部颜色、键盘焦点、菜单 Hover、Command 搜索和右键菜单。
5. Layout 与 Structured layout：折叠、拖拽分栏、Carousel、Tree、Table、Pinned Sheet 和 Window。
6. Overlay：Dialog/Drawer/Sheet 中继续打开输入或 Popover，验证 Escape、外部点击和层级。
7. Motion：Lift/Scale/Glow/Tint/Depth 的 Hover、按压、角落倾斜、上浮和动态阴影。

## 全局配置回归

- 修改 `AppControlMetrics.height`，Button、TextField、Select、AutoComplete 和单行 Form 控件
  应同步变化，Loading/Error/Selected 切换不得改变尺寸。
- 修改 `horizontalPadding`、`iconSize`、`contentGap`，检查 Button、OTP 和相关组合控件。
- 同时切换 light/dark theme、radius、controlPalette、motion 和 shadows。
- 设置 `errorPresenter`，异步视图和 Form 提交不应泄露技术异常文案。
- 在局部 `ComponentTheme` 或 `AppButtonConfig` 覆盖后，确认局部值优先于全局默认。

## Form 重点

- 原生 `FormState.validate/save/reset` 与 `AppFormController` 均可工作。
- 字段错误出现在 Label 后；无 Label 时只显示固定警告位和 Hover/Focus Tooltip。
- Sync、Async、Cross-field 和 Submit 错误不会改变字段宽高。
- 动态字段必须使用稳定 Key；卸载后应离开 values/dirty/验证集合。
- disabled 字段保留值，并遵循 Flutter 原生显式验证行为。
- `markClean` 后 dirty 基线更新；List/Map/Set 使用结构比较。
- API loader 返回 `AppOption<T>` 或分页结构，Form values 中只出现领域值。

## 当前已知边界

- 上游仍为 0.x；任何版本变化必须重新运行升级门槛并复核映射。
- 上游 0.0.53 的 `RawSortableList.build` 尚未实现，`AppSortableInput` 使用 Flutter
  `ReorderableListView`，以后上游修复后再评估退回薄映射。
- 上游 Image Input 文件为空；图片选择器由业务注入，组件不绑定平台权限或网络协议。
- Window 是上游实验组件，桌面拖拽、缩放和多窗口仍应重点人工测试。
- 默认文案目前以英文为主，可通过 builders、validators 和 `errorPresenter` 覆盖；完整产品
  本地化需在具体宿主应用中验收。
