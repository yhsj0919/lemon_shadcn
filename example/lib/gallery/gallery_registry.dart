import 'package:flutter/widgets.dart';

import '../pages/actions_page.dart';
import '../pages/data_display_page.dart';
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
  /// The demo is deliberately registered by component family rather than by
  /// broad UI category. This mirrors how consumers look components up in the
  /// package API and keeps the sidebar aligned with admin_ui's example app.
  static List<GalleryEntry> get entries => <GalleryEntry>[
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
    GalleryEntry(
      id: 'app-button',
      label: 'AppButton',
      subtitle: '按钮变体、图标按钮、异步操作与 Toggle',
      group: 'App 组件',
      builder: (_) => const ActionsPage(),
    ),
    GalleryEntry(
      id: 'app-text',
      label: 'AppText',
      subtitle: '语义化文本角色与局部主题覆盖',
      group: 'App 组件',
      builder: (_) => const TypographyPage(),
    ),
    GalleryEntry(
      id: 'app-badge',
      label: '徽章芯片',
      subtitle: '徽章、芯片、头像与状态展示',
      group: 'App 组件',
      builder: (_) => const DataDisplayPage(
        title: 'AppBadge / AppChip',
        description: '徽章、芯片、头像与紧凑状态标签。',
        visibleSections: {'头像与徽章', '芯片'},
      ),
    ),
    GalleryEntry(
      id: 'form-basic',
      label: '表单基础',
      subtitle: '输入框、选择框、复选框、开关与单选组',
      group: 'App 组件',
      builder: (_) => const FormsPage(
        title: '表单基础',
        description: '常用输入与选择控件。',
        visibleSections: {'表单布局与输入组', '文本输入', '选择框', '布尔与单选控件'},
      ),
    ),
    GalleryEntry(
      id: 'form-advanced',
      label: '表单进阶',
      subtitle: '自动完成、组合框、OTP、电话、评分与异步校验',
      group: 'App 组件',
      builder: (_) => const FormsPage(
        title: '表单进阶',
        description: '异步数据、专用输入与托管校验。',
        visibleSections: {'异步自动完成', '组合框', '专用输入', '托管异步校验'},
      ),
    ),
    GalleryEntry(
      id: 'file-picker',
      label: '文件选择',
      subtitle: '系统文件选择、拖放、多选与文件校验',
      group: 'App 组件',
      builder: (_) => const FormsPage(
        title: '文件选择',
        description: '支持点击选择与拖放文件，并统一处理格式、大小和数量限制。',
        visibleSections: {'文件选择'},
      ),
    ),
    GalleryEntry(
      id: 'combobox',
      label: '组合框',
      subtitle: '静态搜索、异步搜索、对象选择与标签显示',
      group: 'App 组件',
      builder: (_) => const FormsPage(
        title: '组合框',
        description: '支持本地或异步检索、自定义条目和对象值选择。',
        visibleSections: {'组合框'},
      ),
    ),
    GalleryEntry(
      id: 'pickers',
      label: '选择器',
      subtitle: '颜色、多选、条目与可排序输入',
      group: 'App 组件',
      builder: (_) => const FormsPage(
        title: '选择器',
        description: '格式化、可视化、媒体和排序选择。',
        visibleSections: {'格式化与可视化选择', '排序与对象输入'},
      ),
    ),
    GalleryEntry(
      id: 'date-time',
      label: '日期时间',
      subtitle: '日期、日期范围、时间与日历',
      group: 'App 组件',
      builder: (_) => const FormsPage(
        title: '日期与时间',
        description: '日期、日期范围、日历与时间选择。',
        visibleSections: {'日期与时间'},
      ),
    ),
    GalleryEntry(
      id: 'feedback',
      label: '反馈',
      subtitle: '进度、骨架屏、Toast 与异步状态',
      group: 'App 组件',
      builder: (_) => const OverlayPage(),
    ),
    GalleryEntry(
      id: 'display',
      label: '展示',
      subtitle: 'Avatar、Progress、Tracker、Code 与 Chat',
      group: 'App 组件',
      builder: (_) => const DataDisplayPage(),
    ),
    GalleryEntry(
      id: 'disclosure',
      label: '折叠',
      subtitle: 'Accordion、Collapsible 与 Divider',
      group: 'App 组件',
      builder: (_) => const LayoutPage(
        title: '折叠',
        description: '渐进式内容展示与分隔。',
        visibleSections: {'手风琴', '折叠与分隔线'},
      ),
    ),
    GalleryEntry(
      id: 'layout',
      label: '布局',
      subtitle: 'Card、Steps、Timeline 与基础布局',
      group: 'App 组件',
      builder: (_) => const LayoutPage(
        title: '布局',
        description: '卡片、提示、步骤与时间线。',
        visibleSections: {'宽高比', '卡片', '提示变体', '步骤', '时间线'},
      ),
    ),
    GalleryEntry(
      id: 'data-panel',
      label: '数据面板',
      subtitle: 'Carousel、Resizable、Stepper、Tree 与 Table',
      group: 'App 组件',
      builder: (_) => const StructuredLayoutPage(),
    ),
    GalleryEntry(
      id: 'navigation',
      label: '导航',
      subtitle: 'Breadcrumb、Pagination、Tabs 与 Switcher',
      group: 'App 组件',
      builder: (_) => const NavigationPage(
        title: '导航',
        description: '路径、分页、标签页与视图切换。',
        visibleSections: {'面包屑', '分页', '标签页', '标签列表与切换器'},
      ),
    ),
    GalleryEntry(
      id: 'navigation-chrome',
      label: '导航栏',
      subtitle: 'NavigationBar、侧栏与应用外壳',
      group: 'App 组件',
      builder: (_) => const NavigationPage(
        title: '导航栏',
        description: '应用级主导航。',
        visibleSections: {'导航栏'},
      ),
    ),
    GalleryEntry(
      id: 'menus',
      label: '菜单',
      subtitle: 'Menubar、Dropdown、ContextMenu 与 Command',
      group: 'App 组件',
      builder: (_) => const MenusPage(),
    ),
    GalleryEntry(
      id: 'motion',
      label: '其它',
      subtitle: 'Hover、动画构建器与视觉状态',
      group: 'App 组件',
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
