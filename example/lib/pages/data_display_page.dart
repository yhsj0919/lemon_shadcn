import 'package:flutter/services.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

void _noop() {}

Widget _descriptionHeaderActions() => Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    AppIconButton(
      icon: const Icon(LucideIcons.pencil),
      tooltip: '编辑',
      variant: AppButtonVariant.ghost,
      onPressed: _noop,
    ),
    AppDropdownButton(
      variant: AppDropdownButtonVariant.ghost,
      items: [
        AppMenuButton(onPressed: (_) {}, child: const Text('刷新数据')),
        AppMenuButton(onPressed: (_) {}, child: const Text('复制信息')),
      ],
      child: const Icon(LucideIcons.ellipsis),
    ),
  ],
);

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
            const ComponentSection(
              title: '空状态',
              child: AppEmpty(
                icon: Icon(LucideIcons.inbox),
                title: Text('暂无数据'),
                description: Text('创建第一条记录后会显示在这里。'),
              ),
            ),
            const ComponentSection(
              title: '列表条目',
              child: AppItemGroup(
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
            ),
            ComponentSection(
              title: '详情描述',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppDescriptions(
                    title: const Text('纵向标签'),
                    actions: _descriptionHeaderActions(),
                    bordered: true,
                    columns: 3,
                    items: [
                      const AppDescriptionItem(
                        label: Text('项目名称'),
                        value: Text('柠檬管理后台'),
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
                  AppDescriptions(
                    title: const Text('横向标签'),
                    actions: _descriptionHeaderActions(),
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
                  const Gap(20),
                  const Text('详情描述变体').h4(),
                  const Gap(8),
                  AppDescriptions(
                    title: const Text('普通模式'),
                    actions: _descriptionHeaderActions(),
                    bordered: true,
                    columns: 3,
                    items: [
                      AppDescriptionItem(
                        label: Text('项目名称'),
                        value: Text('Lemon Admin'),
                      ),
                      AppDescriptionItem(label: Text('负责人'), value: Text('张明')),
                      AppDescriptionItem(
                        label: Text('更新时间'),
                        value: Text('2026-08-11'),
                      ),
                    ],
                  ),
                  const Gap(12),
                  AppDescriptions(
                    title: const Text('普通横向模式'),
                    actions: _descriptionHeaderActions(),
                    layout: AppDescriptionLayout.horizontal,
                    labelWidth: 72,
                    bordered: true,
                    columns: 3,
                    minColumnWidth: 220,
                    items: [
                      AppDescriptionItem(
                        label: Text('项目名称'),
                        value: Text('柠檬管理后台'),
                      ),
                      AppDescriptionItem(label: Text('负责人'), value: Text('张明')),
                      AppDescriptionItem(
                        label: Text('当前状态'),
                        value: Text('运行中'),
                      ),
                      AppDescriptionItem(
                        label: Text('所属部门'),
                        value: Text('研发中心'),
                      ),
                      AppDescriptionItem(
                        label: Text('部署环境'),
                        value: Text('生产环境'),
                      ),
                      AppDescriptionItem(
                        label: Text('更新时间'),
                        value: Text('2026-08-11'),
                      ),
                    ],
                  ),
                  const Gap(12),
                  AppDescriptions(
                    title: const Text('普通垂直单列'),
                    actions: _descriptionHeaderActions(),
                    bordered: true,
                    columns: 1,
                    items: [
                      AppDescriptionItem(
                        label: Text('项目名称'),
                        value: Text('柠檬管理后台'),
                      ),
                      AppDescriptionItem(label: Text('负责人'), value: Text('张明')),
                      AppDescriptionItem(
                        label: Text('项目说明'),
                        value: Text('用于管理后台页面、业务组件和主题配置。'),
                      ),
                    ],
                  ),
                  const Gap(12),
                  AppDescriptions(
                    title: Text('紧凑模式'),
                    actions: _descriptionHeaderActions(),
                    density: AppDescriptionsDensity.compact,
                    bordered: true,
                    columns: 3,
                    items: [
                      AppDescriptionItem(
                        label: Text('项目名称'),
                        value: Text('柠檬管理后台'),
                      ),
                      AppDescriptionItem(label: Text('负责人'), value: Text('张明')),
                      AppDescriptionItem(
                        label: Text('更新时间'),
                        value: Text('2026-08-11'),
                      ),
                      AppDescriptionItem(
                        label: Text('所属部门'),
                        value: Text('研发中心'),
                      ),
                      AppDescriptionItem(
                        label: Text('当前状态'),
                        value: AppBadge.success(child: Text('运行中')),
                      ),
                      AppDescriptionItem(
                        label: Text('部署环境'),
                        value: Text('生产环境'),
                      ),
                    ],
                  ),
                  const Gap(12),
                  AppDescriptions(
                    title: const Text('紧凑横向模式'),
                    actions: _descriptionHeaderActions(),
                    density: AppDescriptionsDensity.compact,
                    layout: AppDescriptionLayout.horizontal,
                    labelWidth: 64,
                    bordered: true,
                    columns: 3,
                    minColumnWidth: 220,
                    items: [
                      AppDescriptionItem(
                        label: Text('项目名称'),
                        value: Text('柠檬管理后台'),
                      ),
                      AppDescriptionItem(label: Text('负责人'), value: Text('张明')),
                      AppDescriptionItem(label: Text('状态'), value: Text('运行中')),
                      AppDescriptionItem(
                        label: Text('部门'),
                        value: Text('研发中心'),
                      ),
                      AppDescriptionItem(
                        label: Text('环境'),
                        value: Text('生产环境'),
                      ),
                      AppDescriptionItem(
                        label: Text('更新时间'),
                        value: Text('2026-08-11'),
                      ),
                    ],
                  ),
                  const Gap(12),
                  ComponentTheme<AppDescriptionsTheme>(
                    data: const AppDescriptionsTheme(
                      density: AppDescriptionsDensity.compact,
                      labelStyle: TextStyle(color: Color(0xff7c3aed)),
                      valueStyle: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                      tableCellPadding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 0,
                      ),
                    ),
                    child: AppDescriptions(
                      title: const Text('紧凑模式内嵌控件'),
                      actions: _descriptionHeaderActions(),
                      type: AppDescriptionsType.table,
                      columns: 3,
                      minColumnWidth: 220,
                      layout: AppDescriptionLayout.horizontal,
                      labelWidth: 72,
                      items: [
                        AppDescriptionItem(
                          label: const Text('操作'),
                          value: AppButton.outline(
                            onPressed: _noop,
                            child: const Text('编辑'),
                          ),
                        ),
                        AppDescriptionItem(
                          label: const Text('名称'),
                          valueWidth: 200,
                          value: AppTextFormField(
                            name: 'descriptions-demo-name',
                            initialValue: '柠檬管理后台',
                          ),
                        ),
                        AppDescriptionItem(
                          label: const Text('就地编辑'),
                          valueWidth: 160,
                          value: AppInlineEdit.text(
                            value: '张明',
                            onSaved: (_) {},
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Gap(12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const gap = 12.0;
                      final itemWidth = constraints.maxWidth >= 720
                          ? (constraints.maxWidth - gap) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          SizedBox(
                            width: itemWidth,
                            child: AppDescriptions.custom(
                              titleIcon: const Icon(LucideIcons.triangleAlert),
                              title: const Text('告警数据'),
                              actions: AppDropdownButton(
                                variant: AppDropdownButtonVariant.ghost,
                                items: [
                                  AppMenuButton(
                                    onPressed: (_) {},
                                    child: const Text('查看全部告警'),
                                  ),
                                  AppMenuButton(
                                    onPressed: (_) {},
                                    child: const Text('导出记录'),
                                  ),
                                ],
                                child: const Icon(LucideIcons.ellipsis),
                              ),
                              bordered: true,
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                16,
                                16,
                                18,
                              ),
                              child: const Column(
                                children: [
                                  _CustomDescriptionRow(
                                    label: '异常次数',
                                    child: Text('0'),
                                  ),
                                  _CustomDescriptionRow(
                                    label: '最近离线',
                                    child: Text('-'),
                                  ),
                                  _CustomDescriptionRow(
                                    label: '告警记录',
                                    child: Text(
                                      '查看',
                                      style: TextStyle(
                                        color: Color(0xff6366f1),
                                      ),
                                    ),
                                  ),
                                  _CustomDescriptionRow(
                                    label: '操作日志',
                                    child: Text(
                                      '查看',
                                      style: TextStyle(
                                        color: Color(0xff6366f1),
                                      ),
                                    ),
                                  ),
                                  _CustomDescriptionRow(
                                    label: '运行历史',
                                    bottomGap: 0,
                                    child: Text(
                                      '查看',
                                      style: TextStyle(
                                        color: Color(0xff6366f1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            width: itemWidth,
                            child: AppDescriptions.custom(
                              titleIcon: const Icon(LucideIcons.monitor),
                              title: const Text('设备信息'),
                              actions: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  AppIconButton(
                                    icon: const Icon(LucideIcons.pencil),
                                    tooltip: '编辑设备',
                                    variant: AppButtonVariant.ghost,
                                    onPressed: _noop,
                                  ),
                                  AppDropdownButton(
                                    variant: AppDropdownButtonVariant.ghost,
                                    items: [
                                      AppMenuButton(
                                        onPressed: (_) {},
                                        child: const Text('复制设备编号'),
                                      ),
                                      AppMenuButton(
                                        onPressed: (_) {},
                                        child: const Text('设备设置'),
                                      ),
                                    ],
                                    child: const Icon(LucideIcons.ellipsis),
                                  ),
                                ],
                              ),
                              bordered: true,
                              child: Column(
                                children: [
                                  const _CustomDescriptionRow(
                                    label: '设备序列号',
                                    child: Text('site-shimano-01'),
                                  ),
                                  const _CustomDescriptionRow(
                                    label: '所属项目',
                                    child: Text('园区监控'),
                                  ),
                                  _CustomDescriptionRow(
                                    label: '在线状态',
                                    child: AppBadge.success(child: Text('在线')),
                                  ),
                                  const _CustomDescriptionRow(
                                    label: '最后更新',
                                    bottomGap: 0,
                                    child: Text('2026-08-11 14:30'),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '结果状态',
              child: const _ResultStatusShowcase(),
            ),
            ComponentSection(
              title: '头像',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.label('中文姓名'),
                  Gap(10),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      AppAvatar.circle(name: '林晓', initialsCount: 1, size: 40),
                      AppAvatar.circle(name: '张三', initialsCount: 2, size: 48),
                      AppAvatar.square(name: '王小明', initialsCount: 2, size: 48),
                      AppAvatar.square(
                        name: '产品设计',
                        initialsCount: 2,
                        size: 56,
                      ),
                    ],
                  ),
                  Gap(20),
                  AppText.label('中文头像组'),
                  Gap(10),
                  AppAvatarGroup(
                    alignment: Alignment(-0.85, 0),
                    gap: 2,
                    children: [
                      AppAvatar.circle(name: '王芳', initialsCount: 1),
                      AppAvatar.square(name: '李雷', initialsCount: 1),
                      AppAvatar.circle(name: '赵敏', initialsCount: 1),
                      AppAvatar.square(name: '周宁', initialsCount: 1),
                    ],
                  ),
                  Gap(20),
                  AppText.label('自定义文字样式'),
                  Gap(10),
                  Wrap(
                    spacing: 12,
                    children: [
                      AppAvatar.square(
                        name: '世茂',
                        appearance: AppAvatarAppearance.soft,
                        size: 48,
                      ),
                      AppAvatar.square(
                        name: '运营',
                        appearance: AppAvatarAppearance.soft,
                        color: Color(0xffd97706),
                        size: 48,
                      ),
                      AppAvatar.square(
                        icon: Icon(AppLucideIcons.building2),
                        color: Color(0xffd97706),
                        size: 48,
                      ),
                      AppAvatar.square(
                        icon: Icon(AppLucideIcons.heart),
                        color: Color(0xffef4444),
                        size: 48,
                      ),
                      AppAvatar.square(
                        icon: Icon(AppLucideIcons.leaf),
                        color: Color(0xff22c55e),
                        size: 48,
                      ),
                      AppAvatar.square(
                        icon: Icon(AppLucideIcons.droplet),
                        color: Color(0xff3b82f6),
                        size: 48,
                      ),
                      AppAvatar.square(
                        icon: Icon(AppLucideIcons.sparkles),
                        color: Color(0xff8b5cf6),
                        size: 48,
                      ),
                      AppAvatar.circle(
                        initials: '陈',
                        size: 48,
                        backgroundColor: Color(0xffdbeafe),
                        textStyle: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      AppAvatar.square(
                        initials: '设计',
                        size: 48,
                        backgroundColor: Color(0xfffee2e2),
                        foregroundColor: Color(0xffb91c1c),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '角标',
              child: Wrap(
                spacing: 28,
                runSpacing: 28,
                children: [
                  AppCornerBadge.count(
                    count: 42,
                    child: AppAvatar.square(
                      icon: Icon(AppLucideIcons.folder),
                      color: Color(0xff0891b2),
                      size: 52,
                    ),
                  ),
                  AppCornerBadge.count(
                    count: 18,
                    position: AppCornerBadgePosition.topLeft,
                    color: Color(0xff7c3aed),
                    shape: AppBadgeShape.square,
                    child: AppAvatar.square(
                      icon: Icon(AppLucideIcons.keyRound),
                      color: Color(0xff7c3aed),
                      size: 52,
                    ),
                  ),
                  AppCornerBadge.dot(
                    position: AppCornerBadgePosition.bottomLeft,
                    color: Color(0xff22c55e),
                    child: AppAvatar.circle(
                      icon: Icon(AppLucideIcons.user),
                      color: Color(0xff3b82f6),
                      size: 52,
                    ),
                  ),
                  AppCornerBadge.count(
                    count: 7,
                    position: AppCornerBadgePosition.bottomRight,
                    color: Color(0xffef4444),
                    borderRadius: BorderRadius.all(Radius.circular(2)),
                    child: AppAvatar.square(
                      icon: Icon(AppLucideIcons.mail),
                      color: Color(0xffef4444),
                      size: 52,
                    ),
                  ),
                  AppCornerBadge(
                    position: AppCornerBadgePosition.bottomRight,
                    // offset: Offset(2, 2),
                    badge: AppBadge.warning(
                      size: AppBadgeSize.small,
                      child: Text('新'),
                    ),
                    child: AppAvatar.square(
                      icon: Icon(AppLucideIcons.bell),
                      color: Color(0xffd97706),
                      size: 52,
                    ),
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '徽章',
              child: Wrap(
                spacing: 12,
                runSpacing: 12,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
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
                  AppBadge.warning(
                    shape: AppBadgeShape.square,
                    child: const Text('方形'),
                  ),
                  AppBadge.info(
                    borderRadius: BorderRadius.circular(3),
                    child: const Text('自定义圆角'),
                  ),
                  AppBadge.custom(
                    color: Color(0xff7c3aed),
                    child: Text('自定义颜色'),
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
              title: '进度条',
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppProgress(progress: 0.64),
                  Gap(12),
                  Row(
                    children: [
                      SizedBox.square(
                        dimension: 24,
                        child: AppCircularProgressIndicator(value: .64),
                      ),
                      Gap(12),
                      Expanded(child: AppLinearProgressIndicator(value: .64)),
                    ],
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '数字滚动',
              child: AppNumberTicker(
                number: 1280,
                formatter: (value) => '${value.round()}',
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
              title: '骨架屏',
              child: AppSkeleton(
                child: Row(
                  children: [
                    AppAvatar.circle(initials: 'LS'),
                    Gap(8),
                    Text('正在加载资料'),
                  ],
                ),
              ),
            ),
            const ComponentSection(
              title: '圆点指示器',
              child: AppDotIndicator(index: 1, length: 4),
            ),
            const ComponentSection(
              title: '键盘按键',
              child: AppKeyboardDisplay(
                keys: [LogicalKeyboardKey.control, LogicalKeyboardKey.keyK],
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
              title: '溢出滚动',
              child: SizedBox(
                width: 300,
                child: AppText.body(
                  '长内容默认保持静止，鼠标划入且内容溢出时开始滚动。',
                  scrollMode: AppTextScrollMode.hover,
                ),
              ),
            ),
            const ComponentSection(
              title: '可选文本',
              child: AppSelectableText('这段内容可以选择并复制。'),
            ),
            const ComponentSection(
              title: '滚动条视图',
              child: SizedBox(
                height: 56,
                width: 300,
                child: AppScrollbarView(child: Text('可滚动内容\n第二行\n第三行')),
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
                    avatarPrefix: AppAvatar.square(initials: 'A'),
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

class _CustomDescriptionRow extends StatelessWidget {
  const _CustomDescriptionRow({
    required this.label,
    required this.child,
    this.bottomGap = 14,
  });

  final String label;
  final Widget child;
  final double bottomGap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomGap),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              label,
              style: TextStyle(
                color: Theme.of(context).colorScheme.mutedForeground,
              ),
            ),
          ),
          const Gap(12),
          Expanded(child: child),
        ],
      ),
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
