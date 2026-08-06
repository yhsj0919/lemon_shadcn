import 'package:flutter/services.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

void _noop() {}

class DataDisplayPage extends StatelessWidget {
  const DataDisplayPage({
    super.key,
    this.visibleSections = const {
      '空状态与条目',
      '详情描述',
      '结果状态',
      '进度',
      '代码片段',
      '日历',
      '加载与位置状态',
      '状态轨迹',
      '溢出与可选文本',
      '异步视图',
      '聊天',
    },
    this.title = '数据展示',
    this.description = '用于身份、状态和值展示的紧凑组件。',
  });

  final Set<String>? visibleSections;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: title,
      description: description,
      sections:
          <ComponentSection>[
            const ComponentSection(
              title: '空状态与条目',
              child: Column(
                children: [
                  AppEmpty(
                    icon: Icon(LucideIcons.inbox),
                    title: Text('暂无数据'),
                    description: Text('创建第一条记录后会显示在这里。'),
                  ),
                  AppItemGroup(
                    children: [
                      AppItem(
                        leading: Icon(LucideIcons.file),
                        title: Text('项目说明.pdf'),
                        description: Text('240 KB'),
                        trailing: Icon(LucideIcons.chevronRight),
                      ),
                      AppItem(
                        leading: Icon(LucideIcons.settings),
                        title: Text('项目设置'),
                        trailing: Icon(LucideIcons.chevronRight),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '详情描述',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDescriptions(
                    title: const Text('纵向标签'),
                    bordered: true,
                    columns: 3,
                    items: [
                      const AppDescriptionItem(
                        label: Text('项目名称'),
                        value: Text('Lemon Admin'),
                      ),
                      const AppDescriptionItem(
                        label: Text('负责人'),
                        value: Text('张明'),
                      ),
                      AppDescriptionItem(
                        label: const Text('状态'),
                        value: AppBadge.primary(child: const Text('进行中')),
                      ),
                    ],
                  ),
                  const Gap(16),
                  const AppDescriptions(
                    title: Text('横向标签'),
                    bordered: true,
                    columns: 3,
                    minColumnWidth: 200,
                    layout: AppDescriptionLayout.horizontal,
                    labelWidth: 64,
                    items: [
                      AppDescriptionItem(
                        label: Text('项目名称'),
                        value: Text('Lemon Admin'),
                      ),
                      AppDescriptionItem(label: Text('负责人'), value: Text('张明')),
                      AppDescriptionItem(
                        label: Text('创建时间'),
                        value: Text('2026-08-04 10:30'),
                      ),
                      AppDescriptionItem(
                        label: Text('项目说明'),
                        value: Text('管理端组件库与示例应用。'),
                      ),
                      AppDescriptionItem(
                        label: Text('所属部门'),
                        value: Text('研发中心'),
                      ),
                      AppDescriptionItem(
                        label: Text('更新时间'),
                        value: Text('2026-08-04'),
                      ),
                    ],
                  ),
                  const Gap(16),
                  const Text('运行概览').h4(),
                  const Gap(8),
                  const AppDescriptions(
                    type: AppDescriptionsType.table,
                    columns: 3,
                    minColumnWidth: 150,
                    layout: AppDescriptionLayout.vertical,
                    items: [
                      AppDescriptionItem(
                        icon: Icon(LucideIcons.thermometer),
                        label: Text('温度'),
                        value: Text('41°C'),
                      ),
                      AppDescriptionItem(
                        icon: Icon(LucideIcons.sun),
                        label: Text('亮度'),
                        value: Text('78%'),
                      ),
                      AppDescriptionItem(
                        icon: Icon(LucideIcons.droplet),
                        label: Text('湿度'),
                        value: Text('48%'),
                      ),
                    ],
                  ),
                  const Gap(16),
                  const Text('基本信息').h4(),
                  const Gap(8),
                  const AppDescriptions(
                    type: AppDescriptionsType.table,
                    columns: 2,
                    minColumnWidth: 260,
                    layout: AppDescriptionLayout.horizontal,
                    labelWidth: 88,
                    items: [
                      AppDescriptionItem(
                        icon: Icon(LucideIcons.building2),
                        label: Text('所属区域'),
                        value: Text('广州天河'),
                      ),
                      AppDescriptionItem(
                        icon: Icon(LucideIcons.users),
                        label: Text('客户'),
                        value: Text('世贸物业'),
                      ),
                      AppDescriptionItem(
                        icon: Icon(LucideIcons.mapPin),
                        label: Text('详细地址'),
                        value: Text('广州市天河区林和西路 9 号'),
                      ),
                      AppDescriptionItem(
                        icon: Icon(LucideIcons.monitor),
                        label: Text('分辨率'),
                        value: Text('1920 × 1080'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '结果状态',
              child: const _ResultStatusShowcase(),
            ),
            ComponentSection(
              title: '头像与徽章',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  const AppAvatar(initials: 'LS'),
                  const AppAvatarGroup(
                    alignment: Alignment(-0.85, 0),
                    gap: 2,
                    children: [
                      AppAvatar(initials: 'A'),
                      AppAvatar(initials: 'B'),
                      AppAvatar(initials: 'C'),
                    ],
                  ),
                  AppBadge.primary(child: const Text('主要')),
                  AppBadge.secondary(
                    onPressed: _noop,
                    child: const Text('次要按钮'),
                  ),
                  AppBadge.outline(child: const Text('描边按钮')),
                  AppBadge.destructive(child: const Text('危险按钮')),
                  AppBadge.info(
                    leading: const Icon(AppLucideIcons.info, size: 12),
                    child: const Text('信息'),
                  ),
                  AppBadge.success(
                    leading: const Icon(AppLucideIcons.circleCheck, size: 12),
                    child: const Text('在线 33'),
                  ),
                  AppBadge.warning(
                    leading: const Icon(AppLucideIcons.triangleAlert, size: 12),
                    child: const Text('警告'),
                  ),
                  AppBadge.destructive(
                    appearance: AppBadgeStyle.soft,
                    leading: const Icon(AppLucideIcons.circleAlert, size: 12),
                    child: const Text('异常 4'),
                  ),
                  AppBadge.success(
                    fontWeight: FontWeight.bold,
                    appearance: AppBadgeStyle.plain,
                    leading: const Icon(AppLucideIcons.circleCheck, size: 12),
                    child: const Text('在线 33'),
                  ),
                  AppBadge.secondary(
                    appearance: AppBadgeStyle.plain,
                    leading: const Icon(AppLucideIcons.circleX, size: 12),
                    child: const Text('离线 13'),
                  ),
                  AppBadge.destructive(
                    appearance: AppBadgeStyle.plain,
                    leading: const Icon(AppLucideIcons.circleAlert, size: 12),
                    child: const Text('异常 4'),
                  ),
                  AppBadge.success(
                    appearance: AppBadgeStyle.outline,
                    child: const Text('成功描边'),
                  ),
                  AppBadge.success(
                    size: AppBadgeSize.small,
                    child: const Text('小'),
                  ),
                  AppBadge.success(child: const Text('默认')),
                  AppBadge.success(
                    size: AppBadgeSize.large,
                    child: const Text('大'),
                  ),
                  AppBadge.success(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
                    child: const Text('自定义边距'),
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '进度',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppProgress(progress: 0.64),
                  const Gap(12),
                  const Row(
                    children: [
                      SizedBox.square(
                        dimension: 24,
                        child: AppCircularProgressIndicator(value: .64),
                      ),
                      Gap(12),
                      Expanded(child: AppLinearProgressIndicator(value: .64)),
                    ],
                  ),
                  const Gap(12),
                  AppNumberTicker(
                    number: 1280,
                    formatter: (value) => '${value.round()}',
                  ),
                ],
              ),
            ),
            const ComponentSection(
              title: '代码片段',
              child: AppCodeSnippet(
                code: Text('final theme = AppThemeConfig.standard();'),
              ),
            ),
            ComponentSection(
              title: '日历',
              child: AppCalendar(
                view: AppCalendarView.now(),
                selectionMode: CalendarSelectionMode.single,
                value: AppCalendarValue.single(DateTime.now()),
              ),
            ),
            ComponentSection(
              title: '芯片',
              child: Wrap(
                spacing: 8,
                children: [
                  const AppChip(child: Text('Flutter')),
                  AppChip(onPressed: _noop, child: const Text('桌面端')),
                ],
              ),
            ),
            const ComponentSection(
              title: '加载与位置状态',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppSkeleton(
                    child: Row(
                      children: [
                        AppAvatar(initials: 'LS'),
                        Gap(8),
                        Text('正在加载资料'),
                      ],
                    ),
                  ),
                  Gap(16),
                  AppDotIndicator(index: 1, length: 4),
                  Gap(16),
                  AppKeyboardDisplay(
                    keys: [LogicalKeyboardKey.control, LogicalKeyboardKey.keyK],
                  ),
                ],
              ),
            ),
            const ComponentSection(
              title: '状态轨迹',
              child: AppTracker(
                data: [
                  AppTrackerData(level: TrackerLevel.fine, tooltip: Text('正常')),
                  AppTrackerData(
                    level: TrackerLevel.warning,
                    tooltip: Text('缓慢'),
                  ),
                  AppTrackerData(
                    level: TrackerLevel.critical,
                    tooltip: Text('故障'),
                  ),
                ],
              ),
            ),
            const ComponentSection(
              title: '溢出与可选文本',
              child: SizedBox(
                width: 300,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppOverflowMarquee(child: Text('长内容仅在超出可用宽度时滚动。')),
                    Gap(12),
                    AppSelectableText('这段内容可以选择并复制。'),
                    Gap(12),
                    SizedBox(
                      height: 56,
                      child: AppScrollbarView(child: Text('可滚动内容\n第二行\n第三行')),
                    ),
                  ],
                ),
              ),
            ),
            ComponentSection(
              title: '异步视图',
              child: AppAsyncView<List<String>>(
                load: () async => ['主题', '组件', '表单'],
                isEmpty: (items) => items.isEmpty,
                emptyBuilder: (context) => const Text('暂无模块'),
                builder: (context, items) => Wrap(
                  spacing: 8,
                  children: [
                    for (final item in items) AppChip(child: Text(item)),
                  ],
                ),
              ),
            ),
            const ComponentSection(
              title: '聊天',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppChat(
                    avatarPrefix: AppAvatar(initials: 'A'),
                    children: [
                      AppChatBubble(child: Text('主题可以共享吗？')),
                      AppChatBubble(child: Text('可以，通过 AppThemeConfig 共享。')),
                    ],
                  ),
                ],
              ),
            ),
          ].where((section) {
            return visibleSections?.contains(section.title) ?? true;
          }).toList(),
    );
  }
}

class _ResultStatusShowcase extends StatelessWidget {
  const _ResultStatusShowcase();

  static const _items =
      <({AppResultStatus status, String title, String description})>[
        (
          status: AppResultStatus.success,
          title: '操作成功',
          description: '新的配置已经生效。',
        ),
        (
          status: AppResultStatus.info,
          title: '提交信息',
          description: '申请已提交，正在等待处理。',
        ),
        (
          status: AppResultStatus.warning,
          title: '需要确认',
          description: '该操作可能影响现有数据。',
        ),
        (
          status: AppResultStatus.error,
          title: '操作失败',
          description: '服务暂时不可用，请稍后重试。',
        ),
        (
          status: AppResultStatus.forbidden,
          title: '无权访问',
          description: '当前账号没有查看该内容的权限。',
        ),
        (
          status: AppResultStatus.notFound,
          title: '内容不存在',
          description: '请检查地址，或返回上一页。',
        ),
      ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 12.0;
        final columns = constraints.maxWidth >= 900
            ? 3
            : constraints.maxWidth >= 560
            ? 2
            : 1;
        final itemWidth =
            (constraints.maxWidth - spacing * (columns - 1)) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: [
            for (final item in _items)
              SizedBox(
                width: itemWidth,
                child: AppCard(
                  padding: EdgeInsets.zero,
                  child: AppResult(
                    status: item.status,
                    title: Text(item.title),
                    description: Text(item.description),
                    padding: const EdgeInsets.all(20),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
