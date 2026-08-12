import 'package:flutter/widgets.dart';

import '../pages/actions_page.dart';
import '../pages/charts_page.dart';
import '../pages/data_display_page.dart';
import '../pages/data_grid_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/devices/devices_page.dart';
import '../pages/forms_page.dart';
import '../pages/layout_page.dart';
import '../pages/menus_page.dart';
import '../pages/motion_page.dart';
import '../pages/navigation_page.dart';
import '../pages/overlay_page.dart';
import '../pages/structured_layout_page.dart';
import '../pages/typography_page.dart';

class GalleryEntry {
  const GalleryEntry({
    required this.id,
    required this.label,
    required this.subtitle,
    required this.group,
    required this.builder,
  });

  final String id;
  final String label;
  final String subtitle;
  final String group;
  final WidgetBuilder builder;
}

abstract final class GalleryRegistry {
  /// One gallery entry per component family, with in-page sections for variants.
  static List<GalleryEntry> get entries => <GalleryEntry>[
    // —— 概览 / 场景 ——
    GalleryEntry(
      id: 'dashboard',
      label: '仪表盘',
      subtitle: '组件覆盖与示例入口概览',
      group: '概览',
      builder: (_) => const DashboardPage(),
    ),
    GalleryEntry(
      id: 'devices',
      label: '设备管理',
      subtitle: '左右分栏、筛选、表单弹窗的管理端场景示例',
      group: '场景示例',
      builder: (_) => const DevicesPage(),
    ),

    // —— 操作 ——
    GalleryEntry(
      id: 'app-button',
      label: 'AppButton',
      subtitle: '按钮变体、尺寸、图标与异步操作',
      group: '操作',
      builder: (_) => const ActionsPage(),
    ),

    // —— 表单 ——
    GalleryEntry(
      id: 'app-inline-edit',
      label: 'AppInlineEdit',
      subtitle: '双击进入编辑，失焦自动保存',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppInlineEdit',
        description: '数据展示场景的文本、选择、日期和其他表单控件就地编辑。',
        visibleSections: {'就地编辑'},
      ),
    ),
    GalleryEntry(
      id: 'app-text-field',
      label: 'AppTextFormField',
      subtitle: '布局、装饰、邮箱密码与异步校验',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppTextFormField',
        description: '文本输入的布局、装饰与校验变体。',
        visibleSections: {'布局与装饰', '邮箱与密码', '异步校验表单'},
      ),
    ),
    GalleryEntry(
      id: 'app-select',
      label: 'AppSelect',
      subtitle: '静态选项与异步加载',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppSelect',
        description: '下拉单选，支持静态与异步选项。',
        visibleSections: {'静态选项', '异步加载'},
      ),
    ),
    GalleryEntry(
      id: 'app-autocomplete',
      label: 'AppAutoComplete',
      subtitle: '选项源检索与分页检索',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppAutoComplete',
        description: '异步自动完成，支持选项源与分页加载。',
        visibleSections: {'选项源检索', '分页检索'},
      ),
    ),
    GalleryEntry(
      id: 'app-combobox',
      label: 'AppCombobox',
      subtitle: '静态检索与异步标签模式',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppCombobox',
        description: '可搜索组合框，支持对象值与标签展示。',
        visibleSections: {'静态检索', '异步标签'},
      ),
    ),
    GalleryEntry(
      id: 'app-region-picker',
      label: 'AppRegionPicker',
      subtitle: '静态/动态省市县与市县联动',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppRegionPicker',
        description: '省市县级联选择，支持静态树与按级异步加载。',
        visibleSections: {'静态省市县', '动态省市', '静态市县'},
      ),
    ),
    GalleryEntry(
      id: 'app-transfer',
      label: 'AppTransfer',
      subtitle: '双列表穿梭与响应式布局',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppTransfer',
        description: '双列表搜索、选择和批量移动。',
        visibleSections: {'权限分配'},
      ),
    ),
    GalleryEntry(
      id: 'app-file-picker',
      label: 'AppFilePicker',
      subtitle: '图片选择、多文件与上传进度',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppFilePicker',
        description: '系统文件选择、拖放、多选与上传进度。',
        visibleSections: {'图片选择', '文件选择与上传'},
      ),
    ),
    GalleryEntry(
      id: 'app-checkbox',
      label: 'AppCheckbox',
      subtitle: '带标签与校验的复选框',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppCheckbox',
        description: '表单复选框。',
        visibleSections: {'复选框', '多选复选框'},
      ),
    ),
    GalleryEntry(
      id: 'app-switch',
      label: 'AppSwitch',
      subtitle: '开关表单字段',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppSwitch',
        description: '开关表单字段。',
        visibleSections: {'开关'},
      ),
    ),
    GalleryEntry(
      id: 'app-radio',
      label: 'AppRadioGroup',
      subtitle: '单选组横纵向布局',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppRadioGroup',
        description: '单选组表单字段。',
        visibleSections: {'单选组'},
      ),
    ),
    GalleryEntry(
      id: 'app-slider',
      label: 'AppSlider',
      subtitle: '滑块与数值指示',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppSlider',
        description: '滑块表单字段。',
        visibleSections: {'滑块'},
      ),
    ),
    GalleryEntry(
      id: 'app-textarea',
      label: 'AppTextArea',
      subtitle: '多行文本输入',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppTextArea',
        description: '多行文本输入。',
        visibleSections: {'多行文本'},
      ),
    ),
    GalleryEntry(
      id: 'app-otp',
      label: 'AppInputOtp',
      subtitle: '分段验证码输入',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppInputOtp',
        description: 'OTP 验证码输入。',
        visibleSections: {'验证码'},
      ),
    ),
    GalleryEntry(
      id: 'app-phone',
      label: 'AppPhoneInput',
      subtitle: '国际区号与电话号码',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppPhoneInput',
        description: '国家/地区选择与电话号码输入。',
        visibleSections: {'电话号码'},
      ),
    ),
    GalleryEntry(
      id: 'app-chip-input',
      label: 'AppChipInput',
      subtitle: '标签芯片输入',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppChipInput',
        description: '输入并生成标签芯片。',
        visibleSections: {'标签输入'},
      ),
    ),
    GalleryEntry(
      id: 'app-star-rating',
      label: 'AppStarRating',
      subtitle: '星级评分',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppStarRating',
        description: '星级评分表单字段。',
        visibleSections: {'星级评分'},
      ),
    ),
    GalleryEntry(
      id: 'app-number-input',
      label: 'AppNumberInput',
      subtitle: '步进数字输入',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppNumberInput',
        description: '带上下限的数字输入。',
        visibleSections: {'数字输入'},
      ),
    ),
    GalleryEntry(
      id: 'app-date-time',
      label: '日期与时间',
      subtitle: '日期、范围、日期时间与时间选择',
      group: '表单',
      builder: (_) => const FormsPage(
        title: '日期与时间',
        description: '日期、日期范围、日期时间与时间选择。',
        visibleSections: {'日期', '日期范围', '日期时间', '时间'},
      ),
    ),
    GalleryEntry(
      id: 'app-formatted-input',
      label: 'AppFormattedInput',
      subtitle: '分段固定与可编辑格式化输入',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppFormattedInput',
        description: '格式化分段输入。',
        visibleSections: {'格式化输入'},
      ),
    ),
    GalleryEntry(
      id: 'app-color-input',
      label: 'AppColorInput',
      subtitle: '颜色选择',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppColorInput',
        description: '颜色选择输入。',
        visibleSections: {'颜色选择'},
      ),
    ),
    GalleryEntry(
      id: 'app-multiple-choice',
      label: 'AppMultipleChoice',
      subtitle: '方案卡片式选择',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppMultipleChoice',
        description: '方案卡片式选择。',
        visibleSections: {'多选方案', '多选控件'},
      ),
    ),
    GalleryEntry(
      id: 'app-multi-select',
      label: 'AppMultiSelectFormField',
      subtitle: '多选表单控件（固定高度与 +N 溢出）',
      group: '表单',
      builder: (_) => const FormsPage(
        title: '表单',
        description: '表单控件示例。',
        visibleSections: {'多选控件'},
      ),
    ),
    GalleryEntry(
      id: 'app-item-picker',
      label: 'AppItemPicker',
      subtitle: '弹层条目选择',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppItemPicker',
        description: '弹层中选择条目。',
        visibleSections: {'条目选择'},
      ),
    ),
    GalleryEntry(
      id: 'app-sortable-input',
      label: 'AppSortableInput',
      subtitle: '拖动排序列表',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppSortableInput',
        description: '可拖动排序的列表输入。',
        visibleSections: {'拖动排序'},
      ),
    ),
    GalleryEntry(
      id: 'app-object-input',
      label: 'AppObjectInput',
      subtitle: '分段对象输入',
      group: '表单',
      builder: (_) => const FormsPage(
        title: 'AppObjectInput',
        description: '对象分段输入。',
        visibleSections: {'对象输入'},
      ),
    ),

    // —— 展示 ——
    GalleryEntry(
      id: 'app-empty',
      label: 'AppEmpty',
      subtitle: '空状态占位',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppEmpty',
        description: '空数据占位展示。',
        visibleSections: {'空状态'},
      ),
    ),
    GalleryEntry(
      id: 'app-item',
      label: 'AppItem',
      subtitle: '列表条目与条目组',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppItem',
        description: '列表条目展示。',
        visibleSections: {'列表条目'},
      ),
    ),
    GalleryEntry(
      id: 'app-descriptions',
      label: 'AppDescriptions',
      subtitle: '键值详情描述',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppDescriptions',
        description: '响应式键值详情。',
        visibleSections: {'详情描述'},
      ),
    ),
    GalleryEntry(
      id: 'app-result',
      label: 'AppResult',
      subtitle: '成功、失败与无权限结果态',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppResult',
        description: '操作结果状态展示。',
        visibleSections: {'结果状态'},
      ),
    ),
    GalleryEntry(
      id: 'app-avatar',
      label: 'AppAvatar',
      subtitle: '圆形/方形头像与头像组',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppAvatar',
        description: '头像与头像组。',
        visibleSections: {'头像'},
      ),
    ),
    GalleryEntry(
      id: 'app-badge',
      label: 'AppBadge',
      subtitle: '语义色、外观与尺寸变体',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppBadge',
        description: '徽章的语义色、外观与尺寸变体。',
        visibleSections: {'徽章'},
      ),
    ),
    GalleryEntry(
      id: 'app-corner-badge',
      label: 'AppCornerBadge',
      subtitle: '数字、圆点与自定义角标覆盖',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppCornerBadge',
        description: '支持四角定位、偏移和自定义内容的角标。',
        visibleSections: {'角标'},
      ),
    ),
    GalleryEntry(
      id: 'app-chip',
      label: 'AppChip',
      subtitle: '芯片标签',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppChip',
        description: '芯片标签。',
        visibleSections: {'芯片'},
      ),
    ),
    GalleryEntry(
      id: 'app-progress',
      label: 'AppProgress',
      subtitle: '线性与环形进度',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppProgress',
        description: '进度指示变体。',
        visibleSections: {'进度条'},
      ),
    ),
    GalleryEntry(
      id: 'app-number-ticker',
      label: 'AppNumberTicker',
      subtitle: '数字滚动动画',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppNumberTicker',
        description: '数字滚动展示。',
        visibleSections: {'数字滚动'},
      ),
    ),
    GalleryEntry(
      id: 'app-code-snippet',
      label: 'AppCodeSnippet',
      subtitle: '代码片段展示',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppCodeSnippet',
        description: '代码片段展示。',
        visibleSections: {'代码片段'},
      ),
    ),
    GalleryEntry(
      id: 'app-calendar',
      label: 'AppCalendar',
      subtitle: '日历视图',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppCalendar',
        description: '日历展示。',
        visibleSections: {'日历'},
      ),
    ),
    GalleryEntry(
      id: 'app-skeleton',
      label: 'AppSkeleton',
      subtitle: '加载骨架屏',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppSkeleton',
        description: '加载骨架屏。',
        visibleSections: {'骨架屏'},
      ),
    ),
    GalleryEntry(
      id: 'app-dot-indicator',
      label: 'AppDotIndicator',
      subtitle: '圆点位置指示',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppDotIndicator',
        description: '圆点指示器。',
        visibleSections: {'圆点指示器'},
      ),
    ),
    GalleryEntry(
      id: 'app-keyboard-display',
      label: 'AppKeyboardDisplay',
      subtitle: '键盘按键展示',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppKeyboardDisplay',
        description: '键盘按键展示。',
        visibleSections: {'键盘按键'},
      ),
    ),
    GalleryEntry(
      id: 'app-tracker',
      label: 'AppTracker',
      subtitle: '状态轨迹',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppTracker',
        description: '状态轨迹展示。',
        visibleSections: {'状态轨迹'},
      ),
    ),
    GalleryEntry(
      id: 'app-overflow',
      label: 'AppOverflowMarquee',
      subtitle: '溢出滚动文本',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppOverflowMarquee',
        description: '溢出滚动文本。',
        visibleSections: {'溢出滚动'},
      ),
    ),
    GalleryEntry(
      id: 'app-selectable-text',
      label: 'AppSelectableText',
      subtitle: '可选中复制文本',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppSelectableText',
        description: '可选中复制文本。',
        visibleSections: {'可选文本'},
      ),
    ),
    GalleryEntry(
      id: 'app-scrollbar-view',
      label: 'AppScrollbarView',
      subtitle: '带滚动条的内容视图',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppScrollbarView',
        description: '滚动条视图。',
        visibleSections: {'滚动条视图'},
      ),
    ),
    GalleryEntry(
      id: 'app-async-view',
      label: 'AppAsyncView',
      subtitle: '异步数据视图',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppAsyncView',
        description: '异步视图状态。',
        visibleSections: {'异步视图'},
      ),
    ),
    GalleryEntry(
      id: 'app-chat',
      label: 'AppChat',
      subtitle: '聊天消息展示',
      group: '展示',
      builder: (_) => const DataDisplayPage(
        title: 'AppChat',
        description: '聊天消息展示。',
        visibleSections: {'聊天'},
      ),
    ),

    // —— 反馈 ——
    GalleryEntry(
      id: 'app-dialog',
      label: 'AppDialog',
      subtitle: '确认对话框',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppDialog',
        description: '确认对话框。',
        visibleSections: {'对话框'},
      ),
    ),
    GalleryEntry(
      id: 'app-form-dialog',
      label: 'AppFormDialog',
      subtitle: '表单对话框',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppFormDialog',
        description: '表单对话框。',
        visibleSections: {'表单对话框'},
      ),
    ),
    GalleryEntry(
      id: 'app-drawer',
      label: 'AppDrawer',
      subtitle: '侧边抽屉',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppDrawer',
        description: '侧边抽屉。',
        visibleSections: {'抽屉'},
      ),
    ),
    GalleryEntry(
      id: 'app-sheet',
      label: 'AppSheet',
      subtitle: '底部/拖拽面板',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppSheet',
        description: '面板浮层。',
        visibleSections: {'面板'},
      ),
    ),
    GalleryEntry(
      id: 'app-popover',
      label: 'AppPopover',
      subtitle: '锚点气泡弹层',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppPopover',
        description: '气泡弹层。',
        visibleSections: {'气泡弹层'},
      ),
    ),
    GalleryEntry(
      id: 'app-hover-card',
      label: 'AppHoverCard',
      subtitle: '悬浮卡片',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppHoverCard',
        description: '悬浮卡片。',
        visibleSections: {'悬浮卡片'},
      ),
    ),
    GalleryEntry(
      id: 'app-hover-overlay',
      label: 'AppHoverOverlay',
      subtitle: '鼠标划入覆盖布局',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppHoverOverlay',
        description: '鼠标划入后，用完全自定义的上层内容覆盖指定布局。',
        visibleSections: {'鼠标覆盖层'},
      ),
    ),
    GalleryEntry(
      id: 'app-tooltip',
      label: 'AppTooltip',
      subtitle: '工具提示',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppTooltip',
        description: '工具提示。',
        visibleSections: {'工具提示'},
      ),
    ),
    GalleryEntry(
      id: 'app-anchored-overlay',
      label: 'AppAnchoredOverlay',
      subtitle: '通用锚点浮层',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppAnchoredOverlay',
        description: '通用锚点浮层。',
        visibleSections: {'通用锚点浮层'},
      ),
    ),
    GalleryEntry(
      id: 'app-toast',
      label: 'AppToast',
      subtitle: '轻提示通知',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppToast',
        description: '全局轻提示。',
        visibleSections: {'轻提示'},
      ),
    ),
    GalleryEntry(
      id: 'app-refresh',
      label: 'AppRefreshTrigger',
      subtitle: '下拉刷新',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppRefreshTrigger',
        description: '下拉刷新。',
        visibleSections: {'下拉刷新'},
      ),
    ),
    GalleryEntry(
      id: 'app-swiper',
      label: 'AppSwiper',
      subtitle: '滑动触发抽屉',
      group: '反馈',
      builder: (_) => const OverlayPage(
        title: 'AppSwiper',
        description: '滑动触发器。',
        visibleSections: {'滑动触发器'},
      ),
    ),

    // —— 布局 ——
    GalleryEntry(
      id: 'app-aspect-ratio',
      label: 'AppAspectRatio',
      subtitle: '固定宽高比容器',
      group: '布局',
      builder: (_) => const LayoutPage(
        title: 'AppAspectRatio',
        description: '宽高比容器。',
        visibleSections: {'宽高比'},
      ),
    ),
    GalleryEntry(
      id: 'app-card',
      label: 'AppCard',
      subtitle: '卡片容器',
      group: '布局',
      builder: (_) => const LayoutPage(
        title: 'AppCard',
        description: '卡片容器。',
        visibleSections: {'卡片'},
      ),
    ),
    GalleryEntry(
      id: 'app-alert',
      label: 'AppAlert',
      subtitle: '信息、成功、警告与危险提示',
      group: '布局',
      builder: (_) => const LayoutPage(
        title: 'AppAlert',
        description: '提示变体。',
        visibleSections: {'提示变体'},
      ),
    ),
    GalleryEntry(
      id: 'app-accordion',
      label: 'AppAccordion',
      subtitle: '手风琴折叠',
      group: '布局',
      builder: (_) => const LayoutPage(
        title: 'AppAccordion',
        description: '手风琴折叠面板。',
        visibleSections: {'手风琴'},
      ),
    ),
    GalleryEntry(
      id: 'app-collapsible',
      label: 'AppCollapsible',
      subtitle: '纵向与横向折叠',
      group: '布局',
      builder: (_) => const LayoutPage(
        title: 'AppCollapsible',
        description: '折叠面板变体。',
        visibleSections: {'折叠面板'},
      ),
    ),
    GalleryEntry(
      id: 'app-divider',
      label: 'AppDivider',
      subtitle: '水平、垂直与文字分隔线',
      group: '布局',
      builder: (_) => const LayoutPage(
        title: 'AppDivider',
        description: '分隔线变体。',
        visibleSections: {'分隔线'},
      ),
    ),
    GalleryEntry(
      id: 'app-steps',
      label: 'AppSteps',
      subtitle: '水平与垂直步骤条',
      group: '布局',
      builder: (_) => const LayoutPage(
        title: 'AppSteps',
        description: '步骤条变体。',
        visibleSections: {'步骤'},
      ),
    ),
    GalleryEntry(
      id: 'app-timeline',
      label: 'AppTimeline',
      subtitle: '水平与垂直时间线',
      group: '布局',
      builder: (_) => const LayoutPage(
        title: 'AppTimeline',
        description: '时间线变体。',
        visibleSections: {'时间线'},
      ),
    ),
    GalleryEntry(
      id: 'app-carousel',
      label: 'AppCarousel',
      subtitle: '轮播面板',
      group: '布局',
      builder: (_) => const StructuredLayoutPage(
        title: 'AppCarousel',
        description: '轮播布局。',
        visibleSections: {'轮播'},
      ),
    ),
    GalleryEntry(
      id: 'app-resizable',
      label: 'AppResizable',
      subtitle: '可调整尺寸面板',
      group: '布局',
      builder: (_) => const StructuredLayoutPage(
        title: 'AppResizable',
        description: '可调整尺寸布局。',
        visibleSections: {'可调整尺寸'},
      ),
    ),
    GalleryEntry(
      id: 'app-stepper',
      label: 'AppStepper',
      subtitle: '水平与垂直步进器',
      group: '布局',
      builder: (_) => const StructuredLayoutPage(
        title: 'AppStepper',
        description: '步进器变体。',
        visibleSections: {'步进器'},
      ),
    ),
    GalleryEntry(
      id: 'app-tree',
      label: 'AppTree',
      subtitle: '树形结构与懒加载',
      group: '布局',
      builder: (_) => const StructuredLayoutPage(
        title: 'AppTree',
        description: '树形结构与异步懒加载。',
        visibleSections: {'树形结构', '异步树与懒加载'},
      ),
    ),
    GalleryEntry(
      id: 'app-expandable-grid',
      label: '悬浮展开网格',
      subtitle: '网格 Item 原地悬浮展开',
      group: '布局',
      builder: (_) => const StructuredLayoutPage(
        title: '悬浮展开网格',
        description: '网格 Item 原地悬浮展开。',
        visibleSections: {'网格 Item 原地悬浮展开'},
      ),
    ),
    GalleryEntry(
      id: 'app-table',
      label: 'AppTable',
      subtitle: '基础表格',
      group: '布局',
      builder: (_) => const StructuredLayoutPage(
        title: 'AppTable',
        description: '基础表格。',
        visibleSections: {'表格'},
      ),
    ),
    GalleryEntry(
      id: 'app-pinned-sheet',
      label: 'AppPinnedSheet',
      subtitle: '固定面板',
      group: '布局',
      builder: (_) => const StructuredLayoutPage(
        title: 'AppPinnedSheet',
        description: '固定面板。',
        visibleSections: {'固定面板'},
      ),
    ),
    GalleryEntry(
      id: 'app-window',
      label: 'AppWindow',
      subtitle: '可拖动桌面窗口',
      group: '布局',
      builder: (_) => const StructuredLayoutPage(
        title: 'AppWindow',
        description: '可拖动桌面窗口。',
        visibleSections: {'窗口'},
      ),
    ),

    // —— 导航 ——
    GalleryEntry(
      id: 'app-breadcrumb',
      label: 'AppBreadcrumb',
      subtitle: '面包屑路径',
      group: '导航',
      builder: (_) => const NavigationPage(
        title: 'AppBreadcrumb',
        description: '面包屑导航。',
        visibleSections: {'面包屑'},
      ),
    ),
    GalleryEntry(
      id: 'app-pagination',
      label: 'AppPagination',
      subtitle: '分页控件',
      group: '导航',
      builder: (_) => const NavigationPage(
        title: 'AppPagination',
        description: '分页控件。',
        visibleSections: {'分页'},
      ),
    ),
    GalleryEntry(
      id: 'app-tabs',
      label: 'AppTabs',
      subtitle: '标签页',
      group: '导航',
      builder: (_) => const NavigationPage(
        title: 'AppTabs',
        description: '标签页切换。',
        visibleSections: {'标签页'},
      ),
    ),
    GalleryEntry(
      id: 'app-tab-list',
      label: 'AppTabList',
      subtitle: '标签列表',
      group: '导航',
      builder: (_) => const NavigationPage(
        title: 'AppTabList',
        description: '标签列表。',
        visibleSections: {'标签列表'},
      ),
    ),
    GalleryEntry(
      id: 'app-switcher',
      label: 'AppSwitcher',
      subtitle: '面板切换器',
      group: '导航',
      builder: (_) => const NavigationPage(
        title: 'AppSwitcher',
        description: '面板切换动画。',
        visibleSections: {'面板切换器'},
      ),
    ),
    GalleryEntry(
      id: 'app-navigation-bar',
      label: 'AppNavigationBar',
      subtitle: '底部/应用导航栏',
      group: '导航',
      builder: (_) => const NavigationPage(
        title: 'AppNavigationBar',
        description: '应用级导航栏。',
        visibleSections: {'导航栏'},
      ),
    ),
    GalleryEntry(
      id: 'app-menubar',
      label: 'AppMenubar',
      subtitle: '桌面菜单栏',
      group: '导航',
      builder: (_) => const MenusPage(
        title: 'AppMenubar',
        description: '桌面菜单栏。',
        visibleSections: {'菜单栏'},
      ),
    ),
    GalleryEntry(
      id: 'app-navigation-menu',
      label: 'AppNavigationMenu',
      subtitle: '导航菜单与内容面板',
      group: '导航',
      builder: (_) => const MenusPage(
        title: 'AppNavigationMenu',
        description: '导航菜单。',
        visibleSections: {'导航菜单'},
      ),
    ),
    GalleryEntry(
      id: 'app-dropdown',
      label: 'AppDropdown',
      subtitle: '下拉按钮与菜单',
      group: '导航',
      builder: (_) => const MenusPage(
        title: 'AppDropdown',
        description: '下拉菜单。',
        visibleSections: {'下拉菜单'},
      ),
    ),
    GalleryEntry(
      id: 'app-context-menu',
      label: 'AppContextMenu',
      subtitle: '右键/长按上下文菜单',
      group: '导航',
      builder: (_) => const MenusPage(
        title: 'AppContextMenu',
        description: '上下文菜单。',
        visibleSections: {'上下文菜单'},
      ),
    ),
    GalleryEntry(
      id: 'app-command',
      label: 'AppCommand',
      subtitle: '命令面板搜索',
      group: '导航',
      builder: (_) => const MenusPage(
        title: 'AppCommand',
        description: '命令面板。',
        visibleSections: {'命令面板'},
      ),
    ),

    // —— 其它 ——
    GalleryEntry(
      id: 'app-text',
      label: 'AppText',
      subtitle: '语义化文本角色与局部主题',
      group: '其它',
      builder: (_) => const TypographyPage(),
    ),
    GalleryEntry(
      id: 'data-grid',
      label: 'AppDataGrid',
      subtitle: '固定列、排序、分页与无限滚动',
      group: '其它',
      builder: (_) => const DataGridPage(),
    ),
    GalleryEntry(
      id: 'charts',
      label: '图表',
      subtitle: '柱状、折线、面积、饼图与环形图',
      group: '其它',
      builder: (_) => const ChartsPage(),
    ),
    GalleryEntry(
      id: 'motion',
      label: '动效',
      subtitle: 'Hover、动画构建器与视觉状态',
      group: '其它',
      builder: (_) => const MotionPage(),
    ),
  ];

  static Iterable<String> get groups sync* {
    final seen = <String>{};
    for (final entry in entries) {
      if (seen.add(entry.group)) yield entry.group;
    }
  }

  @Deprecated('Use entries; the gallery is component-oriented now.')
  static List<GalleryEntry> get categories => entries;
}
