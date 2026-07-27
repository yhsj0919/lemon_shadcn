# Lemon Shadcn 开发状态

最后更新：2026-07-27

## 当前里程碑

0.0.53 首轮可交付基线：已完成，等待用户依据集中测试清单进行桌面与产品视觉验收。

## 已完成

- [x] 合并 admin_ui 的语义文本、后台 Shell、Dropdown Button、中文本地化与
  ComponentTheme 包装能力；Demo 改为后台式分组组件浏览器。
- [x] `AppShell` 支持桌面侧栏和窄屏横向导航，新增组件已纳入 registry 与测试矩阵。

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
- [x] `AppField` 在有界布局中固定占满可用宽度，Label、Description、Error、
  Loading 和选中内容切换时不改变字段宽度。
- [x] 所有现有 FormField 支持可选 `width`，未指定时继续占满父级可用宽度。
- [x] Form 错误信息默认显示在 Label 与必填标记之后，单行省略；验证状态切换
  不新增字段高度，不改变表单布局。
- [x] 无 Label 的 Form 字段预留固定尾部状态槽；错误时显示警告图标，鼠标悬停或
  键盘聚焦显示完整错误信息，验证状态切换不改变字段尺寸。
- [x] 实现标准化 `AppOption<V>`、静态 `AppSelect<V>`、原生 Form 兼容的
  `AppSelectFormField<V>` 和一次异步 Loader 入口。
- [x] 实现 `AppAutoCompleteFormField<V>.async` 搜索骨架、默认 300ms 防抖、
  过期结果保护和格式化选项展示。
- [x] 实现可复用 `AppAsyncOptionSource<V>`：Form 只消费格式化 `AppOption`，不关心
  request/response；支持同查询请求合并、限量缓存、主动失效、显式重试和旧结果保护。
- [x] `AppSelectFormField` 与 `AppAutoCompleteFormField` 保留原 `.async` 入口，并新增
  `.source` 入口用于多字段共享缓存，Demo 已提供共享数据源示例。
- [x] 实现原生 `Form` 兼容的 `AppForm` / `AppFormController`：可选字段命名、值快照、
  同步与异步联合验证、保存、重置、异步错误展示和过期验证结果保护。
- [x] Text、Select、AutoComplete 均可选接入 `name` 和 `asyncValidator`；未命名字段
  保持普通 Flutter `FormField` 行为，不要求页面迁移到新 Form 系统。
- [x] 实现 `AppCheckbox`、`AppSwitch`、`AppRadioGroup<V>`、`AppSlider` 及对应
  FormField 包装；支持原生验证/保存/重置、AppForm 值收集与异步验证。
- [x] Radio Group 默认消费 `AppOption<V>` 自动生成选项，减少重复 RadioItem 模板；
  Checkbox/Switch 支持内联 control label；横向 Radio 在窄约束下自动换行，避免溢出。
- [x] Checkbox、Switch、Radio item、Slider 的默认交互区域接入 Control Metrics 高度，
  Forms Demo 增加独立 Boolean and choice controls 示例。
- [x] `AppThemeConfig.controlPalette` 接入 Checkbox、Switch、Radio、Slider 内部状态色；
  selected/disabled 可联动背景、前景和边框，组件显式颜色参数保持最高优先级。
- [x] 实现 `AppTextArea` 上游别名与 `AppTextAreaFormField`；多行输入不强制单行高度，
  默认高度由 `AppControlMetrics.textAreaHeight` 全局配置，并支持 Form reset 同步。
- [x] 实现低模板 `AppInputOtp` / `AppInputOtpFormField`：默认数字六位、可配置长度、
  分隔、遮挡、粘贴、提交，补齐上游外部值变化与 reset 同步。
- [x] 实现 `AppPhoneInput` / `AppPhoneInputFormField`：保留国家识别与选择弹层，统一
  controller 所有权、Disabled 行为、Form 值收集和 reset。
- [x] 增加 `AppValidators.exactLength`，Forms Demo 新增 Specialized inputs 分组。
- [x] 实现 `AppDatePicker` 默认单日与真实 `.range` 变体，并提供强类型的
  `AppDatePickerFormField` / `AppDateRangePickerFormField`。
- [x] 实现 `AppTimePicker` / `AppTimePickerFormField`，支持 Dialog/Popover、24 小时制、
  秒选择、原生 Form 生命周期与统一控件高度。
- [x] 增加 `AppCalendar` 及 Calendar value/view 前缀别名；Data Display Demo 展示日历，
  Forms Demo 独立展示日期和时间输入。
- [x] `AppShadcnScope` 在宿主未配置时自动补充 `ShadcnLocalizations` 英文 fallback；
  宿主已配置时直接复用，日期/时间组件无需 `ShadcnApp` 即可运行。
- [x] 建立 `AppControlMetrics` 与 `AppControlBox`，默认 Button、TextField、Select、
  AutoComplete（包括异步 Loading/Error 替身）统一由全局高度配置约束。
- [x] 将默认控件一致性确立为组件完成门槛：同类控件共享高度、点击区域、内容对齐和
  状态行为；仅显式局部尺寸或尺寸变体允许覆盖，内容与状态切换不得导致尺寸变化。
- [x] 建立组件 registry 基础结构，记录名称、上游映射、分类、适配方式和状态。
- [x] 建立 `docs/component-inventory.md`：将 0.0.53 README 的 57 项与源码新增
  27 项合并为当前 84 项版本化转换基线，并记录每项 App API 与状态。
- [x] 完成首批低风险 App 映射：Avatar、AvatarGroup、CodeSnippet、Progress、
  Circular/Linear Progress、NumberTicker、KeyboardDisplay、Tracker、Accordion、
  Collapsible、Alert、Card、Divider、OutlinedContainer；纯映射使用 typedef 以直接
  跟随上游构造参数和行为。
- [x] `AppBadge.primary/secondary/outline/destructive` 使用统一变体门面，只有真实
  语义变体采用 `.xxx`。
- [x] Demo 拆分为独立 Actions 与 Forms 分类页面。
- [x] Demo 新增独立 Data Display 与 Layout 分类页面，未将首批组件混入现有页面。
- [x] 实现 `AppVisualStyle` 视觉颜色上下文。
- [x] 实现 `AppMotion` 的 Lift、Scale、Glow、Tint 通用 Hover/Press 效果。
- [x] 动态阴影根据显式颜色、语义色、边框、Accent、背景或 Primary 派生，
  默认生成环境层和色彩层，不使用固定黑白阴影。
- [x] Demo 增加独立 Motion 分类页面。
- [x] 实现 `AppVisualPalette` 状态优先级和 `AppAnimatedVisualStyle` 颜色联动。
- [x] 实现 `AppMotion.depth`，鼠标横向位置驱动 Y 轴旋转，Hover 同时沿
  Z 轴前移，并在 Motion Demo 中独立展示。
- [x] Depth Hover 同时执行负向 `translateY` 向上抬升和正向
  `translateZ` 前移；Y 轴旋转继续用于鼠标横向跟随。
- [x] Depth 改为分量插值，角落同时驱动 `rotateX` 和 `rotateY`；按压时降低
  Y/Z 抬升与阴影强度，避免整张 Matrix 插值造成抖动。
- [x] Depth 倾斜与抬升拆分动画：X/Y 使用 100ms 快速跟手，Y/Z 抬升使用
  320ms 轻微回弹，按压使用 150ms 柔和收缩；默认按压回收 42% 抬升。
- [x] 实现 `AppToggle` / `AppToggleFormField` 与 `AppStarRating` /
  `AppStarRatingFormField`；普通横向控件接入统一高度，Toggle 选中态和评分颜色接入全局
  `controlPalette`。
- [x] 实现受控 `AppChipInput<T>` / `AppChipInputFormField<T>`：Form 直接保存格式化
  `List<T>`，字符串零解析模板，领域对象可注入解析器；默认拒绝重复、支持数量上限和 reset 同步。
- [x] 在 App 层规避上游 0.0.53 `ChipEditingController.chips=` 替换后残留内部映射的问题，
  不修改上游源码；增加 `AppChip` / `AppChipButton` 低侵入别名。
- [x] Actions、Forms、Data Display 分类 Demo 分别增加 Toggle、Chip Input / Star Rating、Chip 示例。
- [x] 完成第二批低侵入公共映射：`AppAnimatedValueBuilder`、`AppRepeatedAnimationBuilder`、
  `AppDotIndicator`、`AppRefreshTrigger`、`AppSwiper`、`AppBackdropTransform`、
  `AppOverflowMarquee`、`AppScrollbar`、`AppSelectableText`；别名直接跟随上游构造签名。
- [x] Skeleton 上游仅公开扩展入口，因此提供薄包装 `AppSkeleton`，保留主题感知能力并减少页面模板；
  Data Display Demo 独立增加 Loading、位置指示、溢出滚动和可选文本示例。
- [x] 新增格式化游标分页协议 `AppOptionPage<V>` / `AppAsyncPagedOptionSource<V>` 与
  `AppAutoCompleteFormField<V>.paged`；游标保持 opaque，Form 仍只保存领域值，不感知 request/response。
- [x] 分页弹层支持原位 Load more、下一页失败后 Retry loading、跨页按领域值去重；首次加载失败提供
  默认 Retry 操作，并开放 loading/empty/load-error builders 供产品覆盖。
- [x] `AppFormController` 支持同步或异步跨字段验证器，返回字段名到错误文本的映射；错误复用字段固定
  错误位，编辑任意字段会清理旧跨字段结果，异步旧结果不会覆盖新输入，且保留原生 Form validator。
- [x] 完成 Breadcrumb、Pagination、Tabs、TabList、Switcher、Steps、Timeline 的 App 前缀低侵入映射；
  新增独立 Navigation Demo 页面，Steps/Timeline 继续归入 Layout，避免不同类别示例混放。
- [x] 完成 Carousel、Resizable、Stepper、Tree、Table、Scaffold 及必要数据/控制器类型的 App 前缀映射；
  Resizable 同时提供清单入口 `AppResizable` 和语义准确的 `AppResizablePanel`。
- [x] Demo 新增独立 Structured layout 分类，分别展示轮播、桌面拖拽分栏、步骤、树和表格；
  Gallery Shell 自身改用 `AppScaffold` / `AppAppBar`，形成真实共存示例。
- [x] 完成 Dialog、AlertDialog、Drawer、Sheet、Popover、HoverCard、Tooltip、Toast 的 App 公共入口；
  打开型组件使用上游 `*Configuration.show` 薄门面，高级配置类型仍公开，不依赖旧兼容函数。
- [x] `AppShadcnScope` 全局补齐 `ToastLayer`，原 Material 页面不使用 `AppScaffold` 也可直接调用
  `AppToast.show`；新增独立 Overlay Demo 分类验证共存方式。
- [x] 完成 Input、Formatted Input、Color Picker/Input、Multiple Choice、Item Picker 的 App 前缀入口；
  原始 Input 保持上游别名，常规表单继续推荐 `AppTextFormField`。
- [x] 新增 FormField 适配：Formatted/Color 保存强类型值并支持 reset；Multiple Choice/Item Picker
  直接消费 `AppOption<V>` 自动生成选项，减少页面 Choice/Data delegate 模板。
- [x] 完成 Menubar、Navigation Menu、Command、Context Menu、Dropdown Menu 的 App 前缀
  低侵入映射及其关联 Menu/Command 类型；新增独立 Menus and commands 分类 Demo。
- [x] 实现开箱即用的 `AppAsyncView<T>`：统一 Loading/Error/Empty/Data 状态，支持
  `FutureOr` loader、默认 Retry、自定义状态 builder、显式 reload key 与旧结果保护。
- [x] 完成 Chat、Pinned Sheet、Navigation Bar、Window 及必要关联类型的 App 前缀
  低侵入映射；示例分别归入 Data Display、Navigation、Structured layout 分类。
- [x] 完成 84 项基线清单的公共 App 入口；最后补齐 Image、Sortable、Object Input 及
  原生 FormField 适配。Image picker 由业务注入并返回格式化领域值，不绑定平台插件或 request；
  Sortable 使用 Flutter 已实现的重排列表，规避上游 0.0.53 `RawSortableList.build` 尚未实现的问题。
- [x] 当前回归基线：`flutter analyze` 无问题，package 72 项测试与 example gallery 测试通过。
- [x] 实现共享 `AppAsyncAction<T>`：提供 idle/loading/success/error、结果与异常、重复请求
  合并、强制重试、请求代次保护、Loading 延迟和最短展示时间，并显式保留异常传播。
- [x] 所有 `AppButton.xxx` 支持注入共享 Action，统一透传 leading/trailing/loadingLabel；
  请求开始立即禁用，视觉 Loading 可延迟出现，修复延迟窗口内重复点击风险且保持按钮尺寸稳定。
- [x] Actions Demo 增加两个按钮共享一次保存请求的示例。
- [x] Actions Demo 独立展示前置/后置图标按钮与纯图标按钮；纯图标示例使用统一图标密度、
  圆形点击区域和 Tooltip，不改变默认控件高度规范。
- [x] 纯图标按钮 Demo 补充方形样式，并与圆形样式分组对照展示；两者共享全局高度、
  图标尺寸、状态行为和 Tooltip 约束。
- [x] 新增低模板 `AppIconButton` / `AppIconButton.circle` 快捷入口，自动应用图标密度、
  Tooltip、语义标签和正方形宽高约束；宽高统一跟随全局控件高度或局部 `height`。
- [x] 新增 `AppThemePreset.standard/apple/fluent/material` 四套主题基线；预设仅组合公开的
  ThemeData、控件尺寸、动画和阴影 token，可通过 `AppThemeConfig.copyWith` 继续覆盖，
  Gallery 顶栏支持运行时切换对照。
- [x] 修复 `AppSlider` 被统一控件高度强制拉伸后，轨道居中但 Thumb 仍顶对齐的问题；
  Slider 保持上游 16px 内部布局并整体垂直居中于全局控件高度。
- [x] 修复 `AppFormattedInputFormField` 每次输入都因 ValueKey 重建而丢失焦点的问题；改用
  持久 `FormattedInputController` 双向同步 Form/reset，并将上游缩放后高度精确绑定到统一控件高度，
  Reference code 可连续输入且内容垂直居中。
- [x] `AppObjectInputFormField`（Short code）同步移除值驱动重建，使用持久对象 Controller，
  共享格式化输入的统一高度和垂直居中规则。
- [x] Fluent 预设不再使用会与上游文字缩放冲突的 32px 控件高度；恢复 36px 安全基线，
  紧凑感改由 padding、contentGap、圆角和动画表达，避免文字偏心及上下裁剪。
- [x] Reference code / Short code 的内部 EditablePart 改为薄 App 实现：保留上游
  FormattedValue、Controller、焦点流转和格式化协议，显式使用 `TextAlignVertical.center`；
  回归测试直接测量 EditableText 中心，不再只验证外框中心。
- [x] App EditablePart 复刻上游专用 TextEditingController 的 `_` 剩余长度占位与 muted
  着色逻辑，修复居中改造后格式化输入只剩外框、缺少下划线占位的视觉回归。
- [x] `AppScrollbar` 改为强制显式共享 ScrollController；新增低模板 `AppScrollbarView`，
  自动创建/共享/释放 Controller 并构建 SingleChildScrollView，修复桌面端滚动条动画绘制时
  没有 ScrollPosition 的断言。
- [x] `AppFormController.submit` 统一执行同步、异步、跨字段验证，验证通过后调用原生
  `FormState.save` 并向 handler 传递不可变的格式化 values 快照；无效表单不会触发请求。
- [x] `createSubmitAction` 可直接连接 `AppButton(action: ...)`，复用提交验证和共享请求状态；
  Forms Demo 已由手动 validate 改为完整异步 submit 示例，返回的 Action 由调用方显式 dispose。
- [x] `AppFormController` 增加 `isDirty`、`dirtyFields`、`markClean`，对 List/Map/Set 使用
  结构比较和不可变快照，支持保存后建立新基线，不要求各领域类型引入额外模板。
- [x] 明确动态与 disabled 字段策略：带稳定 Key 的动态字段卸载后从 values/dirty/验证中移除；
  disabled 字段保留值并遵循 Flutter 原生显式验证行为。
- [x] `AppThemeConfig.errorPresenter` 提供全局技术异常到用户文案的转换入口，`AppAsyncView`
  默认错误态已接入并保留局部 errorBuilder 的最高优先级。
- [x] Select 异步状态新增 loading/error/empty 局部 builders，默认错误文案接入全局
  `errorPresenter`；Option value 按自定义 equals 检查重复身份，避免含糊选中。
- [x] 修复异步 Select Retry 将 Future 从 `setState` callback 返回而触发 Flutter 断言的问题，
  并增加真实点击 Retry 的回归测试。
- [x] 重构 `AppTextFormField` 共用单一 Form builder，补充 autofocus、autocorrect、suggestions、
  maxLength 和上游 InputFeature 透传；Email 与默认输入继续共享相同尺寸和生命周期实现。
- [x] 新增真实 `.password` 语义变体：自动配置密码键盘、autofill、建议策略和可访问的显隐
  按钮；显隐切换不改变控件尺寸，Forms Demo 的密码字段已迁移。
- [x] Form 提交异常继续传播给 `AppAsyncAction`，同时由 Controller 保存 error/stackTrace；
  新增固定宽高的 `AppFormErrorSummary`，接入全局错误文案并在字段编辑时清理旧提交错误。
- [x] 新增 `AppButtonConfig` 局部高级配置，统一透传 enabled、alignment、上游 size/density/shape、
  Focus、Hover、transition 和 feedback；显式 height 是唯一局部尺寸覆盖入口，默认仍使用全局 Metrics。
- [x] `AppShadcnScope` 将 `AppControlMetrics.horizontalPadding/iconSize` 转换为五种上游 Button
  ComponentTheme；局部 ComponentTheme 仍可就近覆盖，全局配置不再只是声明未生效的 token。
- [x] `AppNavigationItem` 由别名升级为薄包装，保留上游参数并将 normal/hover/focus/disabled/
  selected 状态接入 `controlPalette`，选中背景、文字、图标和边框可全局联动。
- [x] 新增 `tool/check_upstream.dart` 升级门槛，验证 pubspec 约束、lock 实际版本、清单基线
  和 84 行审计数量一致；当前 0.0.53 基线检查通过。
- [x] 补齐动画、Avatar Group、进度、Ticker、Tracker、快捷键、Collapsible、Divider、
  Scrollbar、Refresh、Swiper、Backdrop 等分类示例；升级检查会逐行验证 84 项至少有一个 App API
  在 gallery 中真实使用，防止只登记清单而没有 Demo。

## 进行中

- [x] 84 项入口已完成 API 与 Demo 覆盖审计；自动门槛验证每一行至少有一个分类示例。
- [x] 主要单行控件统一高度，Button 的 padding/icon、OTP 的 contentGap、全局主题 radius
  已接入；Hover/Focus/Pressed/Disabled/Loading/Selected 关键状态有回归测试。

## 尚未完成

- [x] 状态 Palette 已接入主要 Form 选中控件及 `AppNavigationItem`。
- [x] Button 高级配置、全局错误呈现和共享 `AppAsyncAction` 已完成。
- [x] Form 提交级错误汇总、动态字段策略和 Email/Password 语义输入变体已完成。
- [x] 上游 0.0.53 的 84 项目标组件均已有 App 前缀公共入口。
- [x] 自动测试矩阵、gallery 分类遍历、上游版本/清单/Demo 覆盖检查已完成；人工集中测试
  清单见 `docs/test-handoff.md`。

## 当前决策与风险

- 使用 `ShadcnLayer` 接入现有 `MaterialApp`，不要求 `ShadcnApp`。
- 上游仍处于 0.x，升级可能包含 breaking changes，批量映射前需稳定公共 API。
- 公共入口会 re-export 上游 API；与 Material 同名类型并存时，推荐
  `import 'package:flutter/material.dart' as material`。
- 本仓库设置 `publish_to: none`，仅通过 Git / path 依赖接入，不发布到 pub.dev。
