abstract final class ComponentExampleCode {
  static String resolve(String title) =>
      _examples[title] ??
      '''// $title
// 此区块由多个组件组合，请参考上方展示并按需配置。''';

  static const _examples = <String, String>{
    '组件概览': '''const categories = <String>[
  '按钮',
  '表单',
  '选择器',
  '导航',
];

Wrap(
  spacing: 12,
  children: categories.map((label) => AppChip(child: Text(label))).toList(),
);''',
    '使用说明': '''const AppText.body(
  '从导航中选择组件分类，查看组件状态、交互方式和推荐用法。',
);''',
    '按钮变体': '''AppButton.primary(onPressed: () {}, child: const Text('主要按钮'));
AppButton.outline(onPressed: () {}, child: const Text('描边按钮'));''',
    '按钮尺寸': '''AppButton.outline(
  size: AppButtonSize.small,
  onPressed: () {},
  child: const Text('小'),
);''',
    '按钮动效': '''AppButton.primary(onPressed: () {}, child: const Text('默认动效'));
AppButton.primary(
  config: AppButtonConfig.plain,
  onPressed: () {},
  child: const Text('关闭动效'),
);''',
    '组件组': '''AppWidgetGroup.horizontal(children: [
  AppButton.outline(onPressed: () {}, child: const Text('上一页')),
  AppButton.outline(onPressed: () {}, child: const Text('下一页')),
]);''',
    '带图标按钮': '''AppButton.primary(
  leading: const Icon(AppLucideIcons.plus),
  onPressed: () {},
  child: const Text('新建'),
);''',
    '方形纯图标按钮': '''AppIconButton(
  tooltip: '设置',
  onPressed: () {},
  icon: const Icon(AppLucideIcons.settings),
);''',
    '圆形纯图标按钮': '''AppIconButton.circle(
  tooltip: '搜索',
  onPressed: () {},
  icon: const Icon(AppLucideIcons.search),
);''',
    '共享异步操作': '''final action = AppAsyncAction<void>(operation: save);
AppButton.primary(action: action, child: const Text('保存'));''',
    '切换按钮': '''AppToggle(
  value: selected,
  onChanged: (value) => setState(() => selected = value),
  child: const Text('固定工具栏'),
);''',
    '表单布局与输入组': '''AppFieldScope.horizontal(
  labelWidth: 80,
  child: const AppTextFormField(label: '名称'),
);''',
    '文本输入': '''AppTextFormField(
  label: '邮箱',
  hintText: 'name@example.com',
  validator: AppValidators.required(),
);''',
    '选择框': '''AppSelectFormField<String>(
  label: '静态角色',
  options: const [AppOption(value: 'admin', label: '管理员')],
);

AppSelectFormField<String>.async(
  label: '异步角色',
  loadOptions: repository.loadRoles,
  sourceKey: tenantId,
);''',
    '布尔与单选控件': '''AppCheckboxFormField(controlLabel: const Text('接受条款'));
AppSwitchFormField(controlLabel: const Text('启用通知'));''',
    '异步自动完成': '''AppAutoCompleteFormField<String>.source(
  label: '负责人',
  optionSource: roleSource,
);''',
    '组合框': '''AppComboboxFormField<User>.async(
  label: '负责人',
  searchOptions: repository.searchUsers,
  optionConfig: AppOptionConfig(
    equals: (a, b) => a.id == b.id,
    optionBuilder: (context, option, state) => UserListItem(option.value),
  ),
  displayMode: AppComboboxDisplayMode.token,
);''',
    '省市县联动': '''AppRegionPickerFormField<String>(
  label: '省市县',
  options: regionTree,
);

AppRegionPickerFormField<String>.async(
  label: '省市',
  variant: AppRegionPickerVariant.provinceCity,
  loadOptions: (level, selectedPath) => repository.loadRegions(
    level: level,
    parents: selectedPath,
  ),
);

AppRegionPickerFormField<String>(
  label: '市县',
  variant: AppRegionPickerVariant.cityCounty,
  options: cityTree,
);''',
    '穿梭框': '''AppTransferFormField<String>(
  label: '角色权限',
  options: const [
    AppOption(value: 'member', label: '管理成员'),
    AppOption(value: 'report', label: '导出报表'),
  ],
  initialValue: const ['report'],
  onChanged: (value) {},
);''',
    '文件选择': '''AppFilePickerFormField(
  label: '附件',
  allowedExtensions: const ['png', 'jpg'],
  multiple: true,
);''',
    '专用输入': '''AppInputOtpFormField(label: '验证码', length: 6);
AppPhoneInputFormField(label: '电话号码');
AppNumberInputFormField(label: '数量');''',
    '托管异步校验': '''AppTextFormField(
  label: '用户名',
  asyncValidator: (value) => repository.validateName(value),
);''',
    '格式化与可视化选择': '''AppColorInputFormField(label: '强调色');
AppFormattedInputFormField(label: '参考编号');''',
    '排序与对象输入': '''AppSortableInputFormField<String>(
  label: '章节顺序',
  initialValue: const ['概览', '动态', '设置'],
  itemBuilder: (context, index, item) => Text(item),
);''',
    '日期与时间': '''AppDatePickerFormField(label: '日期');
AppTimeStepperPickerFormField(label: '时间');
AppDateTimePickerFormField(label: '日期时间');''',
    '空状态与条目': '''AppEmpty(
  icon: const Icon(AppLucideIcons.inbox),
  title: const Text('暂无数据'),
);
AppItem(title: const Text('项目说明.pdf'));''',
    '详情描述': '''AppDescriptions(
      title: const Text('项目资料'),
      bordered: true,
      columns: 3,
  items: const [
    AppDescriptionItem(label: Text('项目名称'), value: Text('Lemon Admin')),
    AppDescriptionItem(label: Text('负责人'), value: Text('张明')),
      ],
);

AppDescriptions(
  layout: AppDescriptionLayout.horizontal,
  labelWidth: 72,
  columns: 3,
  minColumnWidth: 200,
  items: const [
    AppDescriptionItem(label: Text('项目名称'), value: Text('Lemon Admin')),
  ],
);

AppDescriptions(
  type: AppDescriptionsType.table,
  columns: 2,
  layout: AppDescriptionLayout.horizontal,
  items: const [
    AppDescriptionItem(
      icon: Icon(AppLucideIcons.mapPin),
      label: Text('详细地址'),
      value: Text('广州市天河区林和西路 9 号'),
    ),
  ],
);''',
    '结果状态': '''AppResult(
  status: AppResultStatus.success,
  title: const Text('操作成功'),
  description: const Text('新的配置已经生效。'),
);

// 其他内置状态
// AppResultStatus.info
// AppResultStatus.warning
// AppResultStatus.error
// AppResultStatus.forbidden
// AppResultStatus.notFound''',
    '本地数据与拖动排序': '''AppDataGrid<User>.local(
  columns: columns, // name 列 editable: true
  rows: users,
  rowKey: (user) => user.id,
  sortable: true,
  selectionMode: AppDataGridSelectionMode.multiple,
  onCellChanged: (row, field, value, oldValue) {},
  reorderableRows: true,
  reorderableColumns: true,
  onRowsReordered: (orderedKeys, orderedRows) {},
);''',
    '单选': '''AppDataGrid<User>.local(
  columns: columns,
  rows: users,
  rowKey: (user) => user.id,
  selectionMode: AppDataGridSelectionMode.single,
  // autoSelectFirstRow: true, // 默认 false；开启后会回调 onSelectionChanged
  selectedKeys: selected == null ? {} : {selected.id},
  onSelectionChanged: (rows) {},
);''',
    '服务端分页': '''AppDataGrid<User>.paginated(
  columns: columns,
  rowKey: (user) => user.id,
  loader: (query) => repository.loadUsers(query),
);''',
    '无限滚动': '''AppDataGrid<User>.infinite(
  columns: columns,
  rowKey: (user) => user.id,
  loader: (query) => repository.loadMoreUsers(query),
);''',
    '头像与徽章': '''const AppAvatar(initials: 'LS');
AppBadge.primary(child: const Text('主要'));''',
    '进度': '''const AppProgress(progress: 0.64);
const AppLinearProgressIndicator(value: 0.64);''',
    '代码片段': '''const AppCodeSnippet(
  code: Text('final theme = AppThemeConfig.standard();'),
);''',
    '日历': '''AppCalendar(
  view: AppCalendarView.now(),
  selectionMode: CalendarSelectionMode.single,
);''',
    '芯片': '''const AppChip(child: Text('Flutter'));''',
    '加载与位置状态': '''const AppSkeleton(child: Text('正在加载资料'));
const AppDotIndicator(index: 1, length: 4);''',
    '状态轨迹': '''const AppTracker(data: [
  AppTrackerData(level: TrackerLevel.fine, tooltip: Text('正常')),
]);''',
    '溢出与可选文本': '''const AppOverflowMarquee(child: Text('较长的滚动内容'));
const AppSelectableText('这段内容可以复制');''',
    '异步视图': '''AppAsyncView<List<String>>(
  load: repository.load,
  builder: (context, items) => Text('\${items.length} 项'),
);''',
    '聊天': '''const AppChat(children: [
  AppChatBubble(child: Text('消息内容')),
]);''',
    '宽高比': '''const AppAspectRatio(
  aspectRatio: 16 / 9,
  child: ColoredBox(color: Color(0xffeeeeee)),
);''',
    '卡片': '''const AppCard(
  child: Text('卡片内容'),
);''',
    '提示变体': '''AppAlert.warning(
  title: const Text('订阅即将到期'),
  description: const Text('请及时续订。'),
);''',
    '手风琴': '''AppAccordion(items: [
  AppAccordionItem(
    trigger: const AppAccordionTrigger(child: Text('主题策略')),
    content: const Text('详细内容'),
  ),
]);''',
    '折叠与分隔线': '''const AppCollapsible(children: [
  AppCollapsibleTrigger(child: Text('高级详情')),
  AppCollapsibleContent(child: Text('隐藏内容')),
]);''',
    '步骤': '''const AppSteps.horizontal(children: [
  Text('配置主题'), Text('添加组件'), Text('检查示例'),
]);''',
    '时间线': '''const AppTimeline.horizontal(data: [
  AppTimelineData(time: Text('09:00'), title: Text('配置主题')),
]);''',
    '菜单栏': '''AppMenubar(children: [
  AppMenuButton(subMenu: items, child: const Text('文件')),
]);''',
    '导航菜单': '''AppNavigationMenu(children: [
  AppNavigationMenuItem(onPressed: onPressed, child: const Text('概览')),
]);''',
    '下拉与上下文菜单': '''AppDropdownButton(
  items: items,
  child: const Text('更多操作'),
);''',
    '命令面板': '''AppCommand(
  builder: (context, query) async* {
    yield [AppCommandItem(title: const Text('新建'), onTap: onTap)];
  },
);''',
    '面包屑': '''const AppBreadcrumb(children: [
  Text('首页'), Text('组件'), Text('导航'),
]);''',
    '分页':
        '''AppPagination(page: page, totalPages: 10, onPageChanged: onPageChanged);''',
    '标签页': '''AppTabs(
  index: tab,
  onChanged: onTabChanged,
  children: const [AppTabItem(child: Text('概览'))],
);''',
    '标签列表与切换器': '''AppTabList(
  index: index,
  onChanged: onChanged,
  children: const [AppTabItem(child: Text('列表'))],
);''',
    '导航栏': '''AppNavigationBar(
  selectedKey: selectedKey,
  onSelected: onSelected,
  children: const [
    AppNavigationItem(
      key: ValueKey('home'),
      label: Text('首页'),
      child: Icon(AppLucideIcons.house),
    ),
  ],
);''',
    '模态浮层':
        '''showAppSheet(context: context, builder: (context) => content);''',
    '气泡与悬浮': '''AppHoverCard(
  child: const Text('悬浮卡片'),
  hoverBuilder: (context) => const Text('详细内容'),
);''',
    '轻提示': '''AppToast.show(context: context, title: '已保存');''',
    '刷新与滑动触发器':
        '''AppRefreshTrigger(onRefresh: repository.refresh, child: list);''',
    '表格': '''const AppTable(rows: [
  AppTableHeader(cells: [AppTableCell(child: Text('组件'))]),
  AppTableRow(cells: [AppTableCell(child: Text('AppForm'))]),
]);''',
    '步进器': '''AppStepper.vertical(controller: controller, steps: steps);''',
    '窗口': '''AppWindow(
  title: const Text('窗口'),
  content: content,
  builder: (context) => panel,
);''',
    '固定面板': '''AppResizablePanelGroup(children: panels);''',
    '可调整尺寸': '''AppResizablePanelGroup(
  direction: Axis.horizontal,
  children: panels,
);''',
    '轮播': r'''AppCarousel(
  itemCount: 3,
  transition: const AppCarouselTransition.sliding(),
  itemBuilder: (context, index) => Text('面板 ${index + 1}'),
);''',
    '树形结构': '''AppTree<String>(nodes: nodes, onSelected: onSelected);''',
    '标题层级': '''AppText.h1('页面标题');
AppText.h2('区块标题');''',
    '内容角色': '''AppText.body('正文内容');
AppText.caption('说明文字');''',
    '列表角色': '''AppText.listItem('列表项目');
AppText.listSecondary('辅助信息');''',
    '局部主题覆盖': '''AppTextThemeScope(
  theme: customTextTheme,
  child: const AppText.body('局部样式'),
);''',
    '动画构建器': '''AppMotion.fadeIn(child: const Text('淡入内容'));''',
    'Y 轴上浮与 Z 轴景深': '''AppMotion.hoverLift(child: card);''',
    '选中状态色板': '''AppVisualStyle(colors: selectedColors, child: control);''',
    '数值动画': '''AppNumberTicker(number: 1280);''',
    '悬浮效果': '''AppHoverEffect(
  effect: AppHoverEffectType.lift,
  child: card,
);''',
  };
}
