import 'package:flutter/services.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

void _noop() {}

class DataDisplayPage extends StatelessWidget {
  const DataDisplayPage({
    super.key,
    this.visibleSections,
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
