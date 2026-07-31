# Lemon Shadcn 开发计划

## 1. 项目目标

`lemon_shadcn` 是基于 `shadcn_flutter` 的应用级组件适配层，目标是：

- 尽可能通过主题和配置改变视觉效果，而不是修改或复制上游源码。
- 能持续跟随 `shadcn_flutter` 更新，降低升级和维护成本。
- 不要求应用使用 `ShadcnApp`，能够与现有 `MaterialApp`、`CupertinoApp`、路由和页面共存。
- 为上游组件提供统一的 `App` 前缀和一套开箱即用的标准样式。
- 支持全局配置、局部覆盖、桌面鼠标动画和个性化动态阴影。
- 转换上游全部组件，并在 Demo 中按类别分别展示。

## 2. 核心原则

### 2.1 最小侵入

- 不修改 `shadcn_flutter` 源码。
- 原则上不复制上游组件实现。
- 视觉差异优先通过主题、component theme 和 design tokens 实现。
- 没有额外行为的组件优先使用类型别名。
- 只有存在变体、额外行为或上游无法覆盖的需求时才建立包装层。
- 始终允许直接使用上游 API，避免适配层缺少参数时阻塞业务开发。

### 2.2 跟随上游

- `shadcn_flutter` 作为唯一基础组件实现来源。
- App 适配层不追求复制上游全部构造参数。
- 升级时通过静态分析、单元测试、Widget 测试和 Demo 构建检查兼容性。
- 对不得不独立实现的组件记录原因、对应上游版本和退出条件。

### 2.3 开箱即用与模板代码预算

项目以“一次全局配置，业务代码只表达内容和行为”为产品级 API 原则。颜色、
字体、圆角、间距、密度、状态样式、阴影、动画、Hover、Focus、Loading、
Empty 和 Error 等通用视觉与交互规则不应在每个页面重复传递。

零配置时必须提供完整且可用于生产的标准样式：

```dart
AppShadcnScope(
  child: app,
)
```

现有应用推荐通过 `MaterialApp.builder` 或 `MaterialApp.router.builder` 一次接入：

```dart
MaterialApp.router(
  routerConfig: router,
  builder: (context, child) {
    return AppShadcnScope(
      config: AppThemeConfig.standard(
        primary: const Color(0xFF2563EB),
        radius: .6,
      ),
      child: child!,
    );
  },
)
```

全局配置完成后，页面组件只表达业务意图：

```dart
AppButton.primary(
  onPressed: save,
  child: const Text('保存'),
)

AppTextFormField.email(
  label: '邮箱',
  required: true,
)
```

普通业务代码不应重复设置颜色、圆角、边框、阴影、动画时长、Focus ring、
Disabled opacity 或状态 builder。

API 评审采用以下模板代码预算：

- 普通按钮不超过 4 至 6 行；
- 普通输入框不超过 5 行；
- 静态 Select 不超过 8 行；
- API AutoComplete 不超过 8 至 10 行；
- 标准 Form 不手写字段间距和错误展示；
- Demo 中出现大量重复样式参数时，优先完善全局主题抽象。

## 3. 与现有应用共存

项目不使用 `ShadcnApp` 作为接入要求，而是提供可局部挂载的作用域：

```dart
MaterialApp(
  home: AppShadcnScope(
    child: const ExistingPage(),
  ),
);
```

`AppShadcnScope` 计划基于上游 `ShadcnLayer` 提供：

- shadcn 主题和组件基础设施；
- Overlay、Popover、Toast 等能力；
- 全局 Lemon 样式配置；
- 动画、阴影、密度和圆角配置；
- 局部配置覆盖。

作用域既可以包裹整个应用页面，也可以只包裹部分组件树。

## 4. 组件 API 规则

### 4.1 无变体组件

仅增加 `App` 前缀，不添加没有实际意义的 `.default`：

```dart
AppAvatar(...)
AppAccordion(...)
AppCalendar(...)
AppTable(...)
```

不需要增强行为时，优先使用类型别名：

```dart
typedef AppAvatar = Avatar;
typedef AppAccordion = Accordion;
```

### 4.2 有变体组件

只有上游或 Lemon 设计规范确实存在平级语义变体时，才使用 `.xxx`：

```dart
AppButton.primary(...)
AppButton.secondary(...)
AppButton.outline(...)
AppButton.ghost(...)
AppButton.destructive(...)
```

标准形态可以使用默认构造；其他形态使用命名变体：

```dart
AppCard(...)
AppCard.interactive(...)

AppAlert(...)
AppAlert.destructive(...)
```

### 4.3 额外行为组件

只有需要状态、行为或 Lemon 特有能力时，才建立真正的 Widget 包装，例如：

- 交互卡片；
- 组合式命令面板；
- 上游暂时无法满足的业务组件。

### 4.4 Button 异步行为

异步是 Button 的通用行为能力，不是与 `primary`、`secondary` 等并列的视觉
变体。所有 `AppButton.xxx` 都应支持返回 `FutureOr<void>` 的回调，并自动管理
请求过程状态：

```dart
AppButton.primary(
  onPressed: () async {
    await repository.save();
  },
  child: const Text('保存'),
)
```

计划回调类型：

```dart
typedef AppButtonCallback = FutureOr<void> Function();
```

组件发现回调返回 Future 时自动：

1. 进入 Loading 状态；
2. 禁止重复点击；
3. 播放统一加载动画；
4. Future 完成或抛错后恢复状态；
5. Widget 销毁后不再更新内部状态。

同步回调继续使用相同 API，不进入 Loading。

同时支持由 Bloc、Riverpod、ViewModel 等外部状态管理的受控模式：

```dart
AppButton.primary(
  loading: state.isSubmitting,
  onPressed: submit,
  child: const Text('保存'),
)
```

状态规则：

- `loading == null` 时由按钮自动管理回调返回的 Future；
- 显式传入 `loading` 时由外部完全控制；
- Loading 时默认禁用点击；
- Disabled 优先级高于 Loading；
- Loading 时停止 Hover 和 Pressed 动画，但不应自动丢失 Focus；
- 加载内容切换不得导致按钮尺寸跳动。

默认 Loading 视觉、Spinner、文案、动画时长和行为由全局 `AppButtonTheme`
配置，允许局部通过 `loadingLabel` 或 `loadingBuilder` 覆盖。主题应支持
`loadingDelay` 和 `minimumLoadingDuration`，避免极短请求造成视觉闪烁。

按钮必须在异常发生后恢复 Loading 状态，但默认不吞掉异常、不擅自重试有副
作用的请求，也不强制显示 Toast。全局主题和局部参数可以提供统一的
`onAsyncError` 处理入口。

Form 计划提供 `AppFormSubmitButton.xxx`，在异步按钮行为之上负责：

1. 执行同步字段验证；
2. 等待异步字段验证；
3. 验证失败时定位第一个错误字段；
4. 验证通过后进入提交 Loading；
5. 提交期间阻止重复提交；
6. 提交完成或失败后恢复状态。

## 5. 全局样式配置

计划由 `AppThemeConfig` 统一管理，并拆分为职责明确的 tokens：

```dart
AppThemeConfig(
  colors: AppColorTokens(...),
  geometry: AppGeometryTokens(...),
  motion: AppMotionTheme(...),
  shadows: AppShadowTheme(...),
  components: AppComponentThemes(...),
)
```

配置系统需要支持：

- 默认标准配置，零参数开箱即用；
- 亮色和暗色主题；
- `copyWith`；
- 全局设置和局部覆盖；
- 组件级 theme；
- 密度、间距、圆角、字体和颜色设置；
- 动画总开关和系统 reduced motion；
- 桌面与触摸平台差异。

首个版本只保证一套 `standard` 标准样式，其他预设后续按需要增加。

### 5.1 配置覆盖优先级

样式使用固定的三级覆盖机制：

```text
组件局部 style / 参数
    ↓
局部 AppThemeOverride
    ↓
全局 AppThemeConfig
    ↓
内置 standard 默认值
```

局部区域可以只覆盖需要改变的 token，不要求复制整套配置：

```dart
AppThemeOverride(
  density: AppDensity.compact,
  child: const Toolbar(),
)
```

`AppThemeConfig.standard()` 必须为所有字段提供完整默认值，并允许通过便捷参数
修改品牌色、圆角和密度；高级场景再通过细分 token 和 component theme 覆盖。

### 5.2 组件参数设计

组件公共参数优先表达：

- 内容；
- 值；
- 用户行为回调；
- 业务状态；
- 必要的语义变体。

高频简单内容允许使用字符串等便捷参数，同时保留 Widget 或 builder 作为高级
逃生口。例如 Form 的 `label`、`description` 可以直接传字符串，高级布局使用
对应 builder。

状态页面的 Loading、Empty、Error、Retry 和本地化文案由全局主题提供默认
实现，组件允许按需局部覆盖。

## 6. 通用动画组件

动画独立为通用包裹组件，不侵入所有 App 组件：

```dart
AppMotion.lift(
  child: AppCard(...),
);
```

计划提供的基础效果：

- `none`；
- `tint`；
- `lift`；
- `scale`；
- `glow`。

动画规则：

- 默认效果短促、克制并保持一致。
- 不拦截子组件原有的点击、焦点、键盘和语义行为。
- Hover 使用 `MouseRegion` 获取。
- 触摸设备默认不启用 Hover，仍可保留按压反馈。
- Disabled 状态不播放动画。
- 支持 Focus Visible 和桌面键盘操作。
- 遵循系统 reduced motion 设置。
- 时长、曲线、缩放、位移和效果均可由全局配置控制或局部覆盖。

## 7. 个性化动态阴影

阴影不能固定为黑色或白色，而应根据组件自身视觉颜色动态生成。

### 7.1 颜色解析顺序

自动阴影按以下优先级解析颜色：

1. 局部显式传入的阴影颜色；
2. 组件提供的语义颜色；
3. 组件边框颜色；
4. 组件背景颜色；
5. 当前主题的 primary 颜色；
6. 主题 fallback shadow。

计划支持以下颜色模式：

```dart
enum AppShadowColorMode {
  auto,
  background,
  border,
  foreground,
  primary,
  custom,
}
```

### 7.2 阴影结构

默认阴影由两层构成：

- 环境阴影：提供空间层次；
- 色彩阴影：根据组件色或边框色生成柔和色调。

暗色主题需要独立调整透明度和饱和度，避免产生过强的霓虹效果。

```dart
AppMotion.lift(
  shadow: const AppShadowStyle.border(),
  child: AppCard(...),
);
```

### 7.3 视觉上下文

通用动画组件不能可靠遍历任意 Widget 并推断其内部样式，因此计划通过
`AppVisualStyle` 向子树提供视觉语义：

```dart
AppVisualStyle(
  backgroundColor: backgroundColor,
  borderColor: borderColor,
  foregroundColor: foregroundColor,
  child: AppCard(...),
);
```

App 组件应自动提供自己的视觉上下文；包装第三方组件时允许显式提供颜色。

职责划分：

- `AppVisualStyle`：声明背景、边框、前景和语义颜色；
- `AppShadowTheme`：定义全局阴影生成规则；
- `AppShadow`：单独添加动态阴影；
- `AppMotion`：在 Hover、Pressed 和 Focus 状态之间动画阴影；
- `AppXxx`：在可能时自动提供自身视觉上下文。

## 8. 选中状态与内部组件变色

部分组件在默认、悬停、按下、选中和禁用状态下，不仅容器颜色不同，内部的
文字、图标、边框、Badge 和阴影颜色也会同时变化。该能力计划通过统一的状态
视觉上下文实现，不由父组件遍历或逐个修改内部 Widget。

> 本节暂时只记录设计方向，计划在基础组件和主题系统稳定后实现；具体顺序可
> 根据首批组件验证结果调整。

### 8.1 状态模型

状态系统优先兼容 Flutter 的 `WidgetState` / `WidgetStateProperty` 思路，覆盖：

- Normal；
- Hovered；
- Focused；
- Pressed；
- Selected；
- Disabled。

多个状态同时存在时使用固定优先级，初步约定为：

1. Disabled；
2. Pressed；
3. Selected + Hovered；
4. Selected；
5. Focused；
6. Hovered；
7. Normal。

### 8.2 语义颜色槽位

不为每种内部元素分别增加大量类似 `selectedIconColor`、
`selectedTitleColor` 的参数，而是使用统一的语义 palette：

```dart
class AppVisualPalette {
  final Color background;
  final Color foreground;
  final Color mutedForeground;
  final Color border;
  final Color accent;
  final Color accentForeground;
  final Color shadow;
}
```

内部元素根据语义读取颜色：

- 普通文字和图标使用 `foreground`；
- 次要文字使用 `mutedForeground`；
- Badge 使用 `accent` / `accentForeground`；
- 分隔线和描边使用 `border`；
- 动态阴影使用 `shadow`，或按规则从 `border`、`accent`、`background`
  派生。

### 8.3 状态 Palette 解析

组件样式按状态解析整套 palette，而不是分别解析每个内部元素：

```dart
AppStateProperty<AppVisualPalette>(
  normal: normalPalette,
  selected: selectedPalette,
  disabled: disabledPalette,
)
```

父组件通过 `AppVisualState` 向子树传递当前状态，App 组件内部从
`AppVisualStyle` 读取已经解析的 palette。这样选中状态可以同步改变容器、
文字、图标、边框、Badge 和阴影。

### 8.4 对外状态 API

简单组件使用受控属性：

```dart
AppNavigationItem(
  selected: currentPage == page,
  onSelectedChanged: onSelectedChanged,
  child: ...,
)
```

集合组件由父级统一维护选择状态，例如通过 `selectedKey` 和 `onSelected`
控制。App 组件原则上不私自持有选中状态；如确有需要，可同时提供明确的
uncontrolled 用法。

默认状态颜色来自全局 `AppThemeConfig`，同时支持组件 style 和局部子树覆盖。

### 8.5 状态切换动画

计划由 `AppAnimatedVisualStyle` 统一插值整个 palette，确保背景、文字、图标、
边框和阴影同步过渡，而不是由内部元素分别启动不同步的动画。

动画时长和曲线由 `AppMotionTheme` 控制，并遵循 Disabled、Reduced Motion
和平台差异规则。

### 8.6 上游兼容边界

对于直接使用类型别名的上游组件，不能假设它们会读取 Lemon 的视觉上下文。
处理顺序为：

1. 优先使用上游 Component Theme；
2. 映射上游已有的 `selected`、style、状态解析器或 builder；
3. 确实需要同时改变多个内部颜色时才建立薄包装；
4. 不为强行统一状态系统而复制上游组件源码。

状态视觉系统与动态阴影系统共享 `AppVisualPalette`。状态变化后，阴影颜色应
自动跟随新的 `shadow` 或相应语义颜色。

## 9. Form 系统重新设计

Form 是高优先级基础设施。必须在批量转换 Input、Select、Checkbox、
DatePicker 等输入类组件之前完成协议设计，避免后期调整影响全部表单组件。

### 9.1 原生兼容原则

- 以 Flutter 原生 `Form`、`FormField<T>` 和 `FormState` 为兼容核心。
- 不将 `shadcn_flutter` 自有 Form 系统作为业务接入前提。
- 所有 App 表单字段最终必须基于或兼容 `FormField<T>`。
- App 表单字段可以直接放入原生 `Form`，不强制使用 `AppForm`。
- `validate()`、`save()`、`reset()` 和 `AutovalidateMode` 等原生能力必须正常工作。
- 字段值变化时必须正确调用 `FormFieldState.didChange()`。

原生兼容用法：

```dart
Form(
  key: formKey,
  child: AppTextFormField(
    validator: validateEmail,
  ),
)
```

`AppForm` 是对原生系统的可选增强，不建立互不兼容的第二套表单协议：

```dart
AppForm(
  controller: controller,
  validationMode: AppValidationMode.onInteraction,
  child: ...,
)
```

### 9.2 展示组件与 FormField 分离

普通交互组件和表单生命周期组件分别设计：

```dart
AppInput(...)
AppTextFormField(...)

AppSelect(...)
AppSelectFormField<T>(...)

AppCheckbox(...)
AppCheckboxFormField(...)
```

普通组件不应被保存、重置和错误状态逻辑污染；FormField 负责连接原生 Form，
并复用对应的普通交互组件。

为高频真实输入类型提供语义构造，自动设置键盘、Autofill、输入格式、图标和
默认验证规则：

```dart
AppTextFormField.email(...)
AppTextFormField.password(...)
AppTextFormField.phone(...)
AppTextFormField.search(...)
```

提供 `AppValidators` 内置常用验证器，减少重复的必填、邮箱和长度验证代码。
同时提供 `AppFormSection`、`AppFormRow` 等响应式布局组件，统一字段间距和窄屏
换行，避免页面反复编写 `Column`、`Padding` 和 `Gap`。

### 9.3 过程验证模式

在 Flutter `AutovalidateMode` 基础上，提供语义更明确的验证模式：

```dart
enum AppValidationMode {
  disabled,
  onSubmit,
  onInteraction,
  onChange,
  onBlur,
}
```

- `disabled`：不自动验证；
- `onSubmit`：调用 `validate()` 时验证；
- `onInteraction`：用户首次修改后持续验证；
- `onChange`：每次值变化时验证；
- `onBlur`：字段失去焦点时验证。

默认计划使用 `onInteraction`：用户尚未操作时不显示错误，开始填写后及时反馈。

同步验证继续使用 Flutter 原生签名：

```dart
String? Function(T? value)
```

### 9.4 异步验证

Flutter 原生 `FormField.validator` 只支持同步验证，因此异步验证作为可选增强能力，
不改变原生 validator 语义：

```dart
AppTextFormField(
  validator: validateFormat,
  asyncValidator: checkAvailability,
  validationDebounce: const Duration(milliseconds: 400),
)
```

异步验证需要处理：

- 输入防抖；
- 旧请求结果不得覆盖新请求；
- Widget 销毁后的异步回调；
- 同步验证失败时不启动异步验证；
- 提交时等待正在进行的异步验证。

字段验证状态计划包括：

```dart
enum AppFieldValidationStatus {
  idle,
  validating,
  valid,
  invalid,
}
```

原生 `FormState.validate()` 继续负责同步验证；增强模式通过
`AppFormController.validate()` 等待并汇总同步和异步验证结果。

### 9.5 字段结构与视觉状态

统一使用 `AppField` 组织 Label、必填标记、Description、输入控件、验证进度和
Error，保证所有输入组件的间距、错误展示和可访问性一致。

表单视觉状态包括：

- Normal；
- Hovered；
- Focused；
- Validating；
- Valid；
- Invalid；
- Disabled。

这些状态接入 `AppVisualPalette`：

- Focused 使用 focus ring；
- Validating 显示轻量进度反馈；
- Invalid 联动修改边框、提示文字和相关图标；
- Valid 默认不强制显示绿色边框，由主题配置决定；
- Disabled 停止验证并降低视觉对比度。

### 9.6 可选增强控制器

原生 Flutter Form 不提供按名称读取和联动其他字段的能力，因此计划提供可选的
`AppFormController`，用于增强模式下的跨字段验证、异步验证和表单状态汇总。

计划 API：

```dart
controller.valueOf<T>('fieldName');
controller.validateField('email');
controller.validateFields(['password', 'confirmPassword']);
await controller.validate();
controller.reset();
controller.values;
controller.errors;
controller.isDirty;
controller.isValidating;
```

字段 `name` 只在使用增强控制器、跨字段取值或统一数据收集时要求提供；原生兼容
模式不应强制使用字符串字段名。

### 9.7 Form 实施边界

- 优先完成协议和代表性字段，不立即一次性实现全部 FormField。
- 第一批验证 `AppTextFormField`、`AppSelectFormField` 和
  `AppCheckboxFormField`。
- 先保证同步验证和原生 Form 兼容，再实现异步和跨字段增强。
- Form 组件的错误色、选中色和动态阴影复用统一状态视觉系统。
- 不因兼容 Lemon 增强能力而破坏 Flutter 原生 Form 的生命周期语义。

### 9.8 异步选项的数据边界

Form 和 FormField 不关心 API request、response、JSON parser 或具体网络协议。
进入 Form 组件的数据原则上必须已经由 Repository、ViewModel 或调用方完成格式化。

职责边界：

```text
API / Repository
    ↓ 请求、解析、DTO 转换和业务规则
格式化后的 AppOption / AppOptionPage
    ↓
App FormField
    ↓ 选择、验证和保存
Form value
```

统一选项模型初步设计为：

```dart
class AppOption<V> {
  final V value;
  final String label;
  final Widget? child;
  final List<String> keywords;
  final bool disabled;
}
```

普通 FormField 直接接受格式化后的选项：

```dart
AppSelectFormField<String>(
  options: formattedOptions,
)
```

为了减少 `FutureBuilder` 等模板代码，可以提供返回标准化选项的异步入口：

```dart
AppSelectFormField<String>.async(
  loadOptions: () async => repository.getFormattedUserOptions(),
)
```

异步搜索同样只接收查询文本并返回标准化选项：

```dart
AppAutoCompleteFormField<String>.async(
  searchOptions: repository.searchFormattedUserOptions,
)
```

组件可以负责防抖、加载、空结果、错误重试和过期结果处理，但不解析业务响应。

已有值的回显数据由调用方提前格式化，通过 `initialOption` 等参数传入。Form
组件不应仅根据 ID 私自发起业务请求。

### 9.9 分页选项协议

分页涉及下拉列表滚动和继续加载，是 Form 数据边界中的特殊情况。允许提供一个
薄分页协议，但协议结果仍必须是格式化后的 `AppOption`：

```dart
abstract interface class AppOptionPager<V> {
  Future<AppOptionPage<V>> loadInitial();
  Future<AppOptionPage<V>> loadMore(Object? cursor);
  Future<AppOptionPage<V>> search(String keyword);
}

class AppOptionPage<V> {
  final List<AppOption<V>> options;
  final Object? nextCursor;
  final bool hasMore;
}
```

分页适配器的实现方负责把具体 API 分页协议转换为该标准结构。FormField 只协调
滚动加载、搜索和选中值，不理解页码、HTTP 参数或业务响应格式。

最终数据入口计划为：

```dart
AppSelectFormField<V>(options: options)
AppSelectFormField<V>.async(loadOptions: loader)
AppAutoCompleteFormField<V>.async(searchOptions: searcher)
AppSelectFormField<V>.paged(pager: pager)
```

这里的 `.async` 和 `.paged` 表示真实的数据交互变体，符合组件变体命名规则。

## 10. Demo 组织

Demo 不在单个页面混合展示全部组件。组件通过 registry 登记，并按类别导航：

- Foundation；
- Actions；
- Forms；
- Data Display；
- Navigation；
- Feedback；
- Overlay；
- Layout。

每个组件拥有独立展示页面，按适用情况包含：

- 标准样式；
- 所有语义变体；
- Disabled、Loading、Error 等状态；
- 亮色和暗色主题；
- Hover、Pressed 和 Focus 效果；
- 局部配置覆盖；
- 示例代码。

组件 registry 作为名称、分类、Demo 和测试完整性的单一数据来源。

## 11. 分阶段实施

### 阶段一：基础设施

- `AppShadcnScope`；
- `AppThemeConfig` 和 tokens；
- `AppVisualStyle`；
- `AppMotion`；
- `AppShadow` 和动态阴影；
- Demo 分类导航和组件 registry。

### 阶段二：Form 协议与基础字段

- 确定原生 `Form` / `FormField<T>` 兼容协议；
- `AppField` 统一布局和错误展示；
- `AppForm` 可选增强入口；
- 同步过程验证；
- `AppTextFormField`、`AppSelectFormField`、
  `AppCheckboxFormField`；
- 确定异步验证与 `AppFormController` 接口，复杂增强可分步实现。

### 阶段三：验证通用组件 API

使用以下代表性组件验证设计：

- `AppAvatar`：验证无变体类型别名；
- `AppButton.xxx`：验证多变体工厂；
- `AppCard` / `AppCard.interactive`：验证标准构造和行为增强；
- App Input：验证表单、Focus 和主题；
- App Dialog：验证 Overlay 和现有应用共存。

### 阶段四：完整组件转换

- 建立上游全部组件清单；
- 按类别转换并增加 `App` 前缀；
- 只为确实存在的变体提供 `.xxx`；
- 同步完成分类 Demo 和基本测试。

### 阶段五：升级与发布保障

- 上游版本兼容检查；
- 静态分析和全量编译；
- Widget 测试；
- 关键组件 Golden 测试；
- 桌面 Hover、Focus 和动态阴影测试；
- Demo 各目标平台构建检查。

### 待排期：状态视觉系统

选中状态和内部组件联动变色暂定在基础组件 API、主题配置及动态阴影验证稳定
后实现。若首批验证组件（例如 Navigation、Toggle、Select）较早依赖该能力，
可以将其并入阶段二或阶段三；实现前应先以实际组件验证 palette 和状态优先级
设计。

## 12. 当前待确认事项

- 上游组件的最终分类和 App 命名映射表；
- 哪些上游组件被认定为拥有语义变体；
- 默认标准主题的品牌颜色、字体、圆角和密度；
- 默认动画幅度与动态阴影强度；
- 首批支持和验证的桌面平台。

## 13. 补充工程规则

本节记录产品化过程中需要遵循的补充规则。标记为“实现前”的内容需要在对应
基础组件开发前确定；“后期增强”不进入首个垂直切片的强制范围。

### 13.0 上游升级门槛

每次修改 `shadcn_flutter` 版本后，必须先运行 `dart run tool/check_upstream.dart`。
锁文件版本、清单基线和 pubspec 约束必须一致；版本变化时重新核对公开导出、组件数量、
App 映射、分类 Demo 和相关回归测试，不能只更新版本号使检查通过。

### 13.1 统一异步操作模型（实现前）

Button、Form 提交、分页、搜索和刷新共享 `idle`、`loading`、`success`、
`error` 等异步状态。底层计划提供统一的 `AppAsyncAction<T>`，集中处理：

- 防止重复执行；
- 当前结果和异常；
- 请求序号与过期结果；
- Loading 延迟和最短展示时间；
- Retry；
- 生命周期和状态监听。

简单场景不要求显式创建 Action，组件应自动管理 Future。只有多个组件需要共享
同一个请求状态时才显式传入 `AppAsyncAction<T>`。

### 13.2 统一反馈和错误呈现（实现前）

- Button 默认不吞异常、不擅自显示 Toast。
- 全局可以配置 `AppErrorPresenter`，把技术异常转换为用户可读文案。
- Toast、Inline Alert、Form Error 和 Dialog Error 使用统一的反馈语义。
- 成功、错误和重试反馈允许局部声明，但默认不替业务决定文案。
- 不自动重试删除、提交等具有副作用的请求。

### 13.3 Overlay 基础设施（实现前）

由于不使用 `ShadcnApp`，必须优先验证并统一管理：

- 根 Overlay 与嵌套 Navigator；
- Dialog 内部打开 Select 或 Popover；
- Tooltip、Toast、Context Menu 和 AutoComplete；
- 锚点移动和窗口缩放后的重新定位；
- 桌面端越界翻转；
- Escape、点击外部和路由切换时关闭；
- 多层 Overlay 的层级顺序。

`AppShadcnScope` 应补齐必要设施，但不重复创建应用级 Navigator、MediaQuery 或
Localizations。

### 13.4 Controller 统一规则（实现前）

- 组件内部创建的 Controller 由组件自动 dispose。
- 外部传入的 Controller 由调用方 dispose。
- Controller 修改纯状态时尽量不依赖 `BuildContext`。
- 需要展示 Overlay 的操作在调用时提供 Context 或由内部宿主管理。
- 受控和非受控模式不得同时争夺状态。
- `initialValue` 只在初始化或明确 reset 时生效，不因普通 rebuild 重置。
- 所有 Controller 的命名、监听和生命周期 API 保持一致。

### 13.5 Null、清空与重置语义（实现前）

Form、Select、DatePicker 和 MultiSelect 必须统一定义：

- `null`、空字符串和空集合的含义；
- 是否允许清空及 `clearable` 行为；
- Required 对各类空值的判断；
- Reset 恢复 initialValue 还是空值；
- Disabled 或隐藏字段是否参与验证和 values；
- 多选的 `null` 与空集合是否区分。

当前实现约定：动态字段卸载后立即从 values、dirty 和验证集合移除；disabled 字段仍
保留格式化值并遵循 Flutter 原生 `FormField.validate` 行为参与显式验证。业务若希望某个
条件字段完全不参与提交，应将它从 widget tree 卸载，或由 validator 根据业务条件返回 null。
动态字段列表与 Flutter 其他有状态列表相同，插入、删除或重排时必须提供稳定 Key，避免
Element 复用使字段状态和 name 短暂错配。

### 13.6 Option 身份与相等性（实现前）

- Select 和 MultiSelect 默认通过 `AppOption.value` 识别选项。
- 默认使用 `==`，允许提供自定义 comparator。
- 必须定义重复 value 的处理规则。
- 异步刷新产生新对象时仍需维持正确选中状态。
- 实现前评估 `AppOption<V>` 是否需要保留格式化前的业务对象；优先保持简单，
  不轻易引入会显著增加调用复杂度的双泛型。

### 13.7 异步选项生命周期（实现前）

异步 Select 和 AutoComplete 需要统一处理：

- Loader 的首次执行和 rebuild 行为；
- Retry 时重新创建请求；
- 搜索防抖与结果竞态；
- 相同 query 的可选缓存；
- 下拉关闭后的结果保留策略；
- 清空搜索后的恢复策略；
- 分页失败后的局部重试；
- 已选项不在当前分页时的展示；
- Form reset 后是否重新加载。

主要 API 使用 Loader 回调；裸 Future 只作为便捷入口。

### 13.8 Form Controller 生命周期（实现前）

`AppFormController` 在实现前必须确定：

- 字段动态注册和注销；
- 同名字段处理；
- 动态列表字段命名；
- Dirty 比较和自定义 comparator；
- Reset 目标值；
- 隐藏、禁用字段的验证与提交策略；
- 异步验证期间的提交行为。

### 13.9 可访问性与键盘规则（实现前）

- 支持 Tab / Shift+Tab 焦点移动。
- Enter / Space 激活，Escape 关闭 Overlay。
- 列表支持方向键、Home、End 和必要的翻页按键。
- 正确暴露 Selected、Expanded、Invalid 和 Busy 语义。
- 错误信息与对应字段建立可访问性关联。
- 选中状态不能只依赖颜色表达。
- 支持 Reduced Motion 和高对比度场景。
- Hover 与 Focus 分离，键盘导航必须保留清晰的 Focus Visible。

### 13.10 动画布局与性能规则（实现前）

- Scale 使用绘制变换，不触发布局重排。
- Lift 不通过修改 margin 或 padding 实现。
- 包裹组件不得改变 Hit Test、Semantics、Focus 顺序、GlobalKey 或 Overlay 锚点。
- 阴影被 Clip、Scrollable、Table、Dialog 等父级裁剪时需专项验证。
- `RepaintBoundary` 按性能测试结果使用，不无差别包裹所有组件。
- 动态阴影限制透明度、饱和度和亮度，暗色主题避免霓虹效果。

### 13.10.1 默认控件尺寸与行为一致性（实现前）

- 这是组件库的默认契约，不是可选的视觉优化；新增交互组件在进入“已完成”前必须通过一致性检查。
- 同一密度下，Button、Input、Select、AutoComplete 等默认交互控件使用统一高度。
- 相同用途的控件必须保持相同的点击区域、内容对齐和基本交互行为，禁止直接继承上游互不一致的默认尺寸。
- 默认内边距、圆角、图标尺寸、图标与文字间距由全局 Control Metrics 提供。
- Hover、Focus、Pressed、Disabled、Loading 和 Error 使用一致的状态优先级与过渡节奏。
- Loading、错误图标、前后缀和选中内容切换不得引起控件尺寸跳动。
- 只有明确声明的尺寸变体才允许改变高度，不因上游组件各自默认值产生无意的大、小差异。
- 组件允许通过局部 `height` 或未来的显式尺寸变体覆盖默认值，但不允许因内容、校验状态、加载状态或选中状态隐式改变尺寸。

### 13.11 桌面交互规则（实现前）

- Click、Disabled、Text、Grab、Grabbing 和 Resize 使用一致 Cursor。
- `AppMotion` 不覆盖子组件明确声明的特殊 Cursor。
- Hover、Focused、Pressed 和 Selected 是可组合但不同的状态。
- 密度通过 `AppDensity.compact/standard/comfortable` 配置，不只依赖平台判断。
- 响应式组件优先依据可用约束，而不是直接读取整屏尺寸。

### 13.12 标准确认操作（后期增强）

删除、覆盖和退出等操作可通过可选 `AppConfirmation` 或 `AppConfirmAction`
减少重复 Dialog 模板。确认后复用异步 Button 行为。确认机制不与 destructive
视觉变体强制绑定。

### 13.12a 表单弹窗 AppFormDialog

确认框继续用 `AppAlertDialog`（上游对 `content` 强制 `small` + `muted`）。
大表单使用 `AppFormDialog`：

- 外壳仍经 `AppDialog.show` 打开，字段为 `title` / `content` / `actions`（对齐 Alert 结构）；
- **不对** `content` 强制 muted/small，正文色保持主题默认；
- 可选 `constraints` 控制大表单最大宽度；
- 对话框内按钮默认静止动效（与现有 `AppButtonMotionScope.disable` 一致）。

见 `docs/component-inventory.md`「表单弹窗」与 Overlay Demo。

### 13.13 标准页面状态与响应式布局（后期增强）

计划按需要提供：

- `AppEmptyState`；
- `AppErrorState`；
- `AppLoadingState`；
- `AppAsyncView`；
- `AppPageContainer`；
- `AppResponsiveRow`；
- `AppFormSection`；
- `AppFormRow`。

同时统一断点、内容宽度和图标尺寸规则，减少页面级重复布局代码。

### 13.14 Demo 与测试规则

- Demo 同时作为人工兼容和视觉回归工具。
- 页面按适用情况覆盖亮暗主题、密度、Disabled、Hover、Focus、Selected、
  Loading、Error、长文本、中英文和不同宽度。
- 所有组件执行 Smoke Test。
- 关键视觉组件执行亮暗主题 Golden Test。
- 复杂状态组件只覆盖关键状态，避免测试矩阵无限膨胀。
- 动画测试关键帧与最终状态。
- Form 重点测试生命周期、验证和重置，不只测试截图。

### 13.15 上游覆盖与版本规则

“全部组件”定义为覆盖指定 `shadcn_flutter` 基线版本中纳入目标范围的公开组件，
不把固定数量作为永久不变的目标。

组件 registry 记录：

- 上游名称和 App 名称；
- 分类；
- Alias、Variant Facade、Wrapper 或 Independent 实现方式；
- 变体；
- Demo 与测试状态；
- 对应上游版本和备注。

升级时检查新增、删除、重命名、构造参数和变体变化。上游仍处于 `0.x` 阶段时
使用较窄版本约束，并通过独立升级任务主动验证，而不是无条件自动跟随。

### 13.16 首个垂直切片

在扩展全部组件前，优先完成一个最小但贯通的验证切片：

1. `AppShadcnScope` 与完整默认配置；
2. `AppButton.primary` 的同步、异步和 Loading；
3. `AppTextFormField` 的原生 Form 兼容和过程验证；
4. `AppSelectFormField` 消费格式化 `AppOption`；
5. `AppAutoCompleteFormField.async` 的防抖与异步状态；
6. 一个按分类组织的 Demo 页面。

该切片用于验证主题、状态、Form、异步、Overlay、桌面交互和模板代码预算，
接口稳定后再批量转换上游组件。
