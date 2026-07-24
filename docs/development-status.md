# Lemon Shadcn 开发状态

最后更新：2026-07-24

## 当前里程碑

首个垂直验证切片：进行中。

## 已完成

- [x] 将原生插件模板转换为纯 Flutter 组件 package。
- [x] 接入 `shadcn_flutter 0.0.53`。
- [x] 确立开发原则、Form 边界、异步数据边界和工程规则。
- [x] 验证 `ShadcnLayer` 可用于非 `ShadcnApp` 宿主。
- [x] 实现 `AppShadcnScope` 和 `AppThemeConfig.standard()`。
- [x] Scope 默认提供透明 Material Surface，兼容 Ink 和依赖 Material
  ancestor 的现有组件，同时不改变页面背景。
- [x] Scope 补齐移动端 Select、Popover 等 Sheet handler 依赖的
  `DrawerOverlay`。
- [x] Scope 为 Drawer/Sheet 内的输入组件提供稳定的 Flutter Overlay 宿主，
  支持 AutoComplete 搜索框的光标和文本选择层。
- [x] 实现 `AppButton` 五种语义变体和异步 Loading 基线。
- [x] Button Loading 使用固定内容占位，切换 Spinner/进度状态时保持宽度不变。
- [x] 实现 `AppField` 和原生 `FormField<String>` 兼容的
  `AppTextFormField` 基线。
- [x] 实现标准化 `AppOption<V>`、静态 `AppSelect<V>`、原生 Form 兼容的
  `AppSelectFormField<V>` 和一次异步 Loader 入口。
- [x] 实现 `AppAutoCompleteFormField<V>.async` 搜索骨架、默认 300ms 防抖、
  过期结果保护和格式化选项展示。

## 进行中

- [ ] AutoComplete 缓存、分页、显式重试和高级状态 builder。

## 尚未完成

- [ ] 通用视觉状态、动画和动态阴影。
- [ ] Button 高级参数透传、全局错误呈现和共享 `AppAsyncAction`。
- [ ] Form 异步验证、跨字段验证、Controller 和更多语义输入变体。
- [ ] `AppOption`、Select 和 AutoComplete。
- [ ] 分类 Demo 与组件 registry。
- [ ] 上游全部目标组件的 App 前缀映射。
- [ ] 完整测试矩阵与升级检查。

## 当前决策与风险

- 使用 `ShadcnLayer` 接入现有 `MaterialApp`，不要求 `ShadcnApp`。
- 上游仍处于 0.x，升级可能包含 breaking changes，批量映射前需稳定公共 API。
- 根级旧 Android 插件目录仍有无效模板文件，但不参与 package 构建。
