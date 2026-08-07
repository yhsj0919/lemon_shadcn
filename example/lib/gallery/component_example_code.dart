abstract final class ComponentExampleCode {
  static String resolve(String title) =>
      _examples[title] ??
      '''// $title
// 此区块由多个组件组合，请参考上方展示并按需配置。''';

  static const _examples = <String, String>{
    '就地编辑': '''AppInlineEdit.text(
  value: user.name,
  validator: (value) => value.trim().isEmpty ? '名称不能为空' : null,
  onSaved: (value) async => repository.updateName(value),
);

// 任意现有表单控件都可以通过 control 接入。
AppInlineEdit<MyValue>.immediate(
  value: value,
  displayBuilder: (_, value) => Text(value.label),
  editorBuilder: (_, details) => MyFormControl(
    value: details.value,
    onChanged: details.onChanged,
  ),
  onSaved: save,
);''',
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
AppButton.primary(shadow: true, onPressed: () {}, child: const Text('阴影按钮'));
AppButton.outline(onPressed: () {}, child: const Text('描边按钮'));''',
    '按钮阴影': '''AppButton.primary(
  shadow: true,
  onPressed: () {},
  child: const Text('主题色阴影'),
);
AppButton.outline(
  shadow: true,
  onPressed: () {},
  child: const Text('边框色阴影'),
);
AppIconButton.circle(
  shadow: true,
  variant: AppButtonVariant.outline,
  tooltip: '阴影图标按钮',
  onPressed: () {},
  icon: const Icon(AppLucideIcons.arrowUpRight),
);''',
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
    '布局与装饰': '''AppFieldScope.horizontal(
  labelWidth: 80,
  child: const AppTextFormField(label: '名称'),
);''',
    '邮箱与密码': '''AppTextFormField(
  label: '邮箱',
  hintText: 'name@example.com',
  validator: AppValidators.required(),
);''',
    '异步校验表单': '''AppTextFormField(
  label: '用户名',
  asyncValidator: (value) => repository.validateName(value),
);''',
    '图片选择': '''AppFilePickerFormField(
  label: '头像',
  allowedExtensions: const ['png', 'jpg'],
);''',
    '文件选择与上传': '''AppFilePickerFormField(
  label: '附件',
  allowedExtensions: const ['png', 'jpg'],
  multiple: true,
);''',
    '静态选项': '''AppSelectFormField<String>(
  label: '静态角色',
  options: const [AppOption(value: 'admin', label: '管理员')],
);''',
    '异步加载': '''AppSelectFormField<String>.async(
  label: '异步角色',
  loadOptions: repository.loadRoles,
  sourceKey: tenantId,
);''',
    '选项源检索': '''AppAutoCompleteFormField<String>.source(
  label: '负责人',
  optionSource: roleSource,
);''',
    '分页检索': '''AppAutoCompleteFormField<String>.paginated(
  label: '负责人',
  loadPage: repository.loadUsersPage,
);''',
    '静态检索': '''AppComboboxFormField<String>(
  label: '标签',
  options: const [AppOption(value: 'a', label: 'A')],
);''',
    '异步标签': '''AppComboboxFormField<User>.async(
  label: '负责人',
  searchOptions: repository.searchUsers,
  displayMode: AppComboboxDisplayMode.token,
);''',
    '静态省市县': '''AppRegionPickerFormField<String>(
  label: '省市县',
  options: regionTree,
);''',
    '动态省市': '''AppRegionPickerFormField<String>.async(
  label: '省市',
  variant: AppRegionPickerVariant.provinceCity,
  loadOptions: (level, selectedPath) => repository.loadRegions(
    level: level,
    parents: selectedPath,
  ),
);''',
    '静态市县': '''AppRegionPickerFormField<String>(
  label: '市县',
  variant: AppRegionPickerVariant.cityCounty,
  options: cityTree,
);''',
    '权限分配': '''AppTransferFormField<String>(
  label: '角色权限',
  options: const [
    AppOption(value: 'member', label: '管理成员'),
    AppOption(value: 'report', label: '导出报表'),
  ],
  initialValue: const ['report'],
  onChanged: (value) {},
);''',
    '复选框': '''AppCheckboxFormField(controlLabel: const Text('接受条款'));''',
    '开关': '''AppSwitchFormField(controlLabel: const Text('启用通知'));''',
    '单选组': '''AppRadioGroupFormField<String>(
  label: '角色',
  options: const [AppOption(value: 'admin', label: '管理员')],
);''',
    '滑块': '''AppSliderFormField(label: '音量', min: 0, max: 100);''',
    '多行文本': '''AppTextAreaFormField(label: '备注');''',
    '验证码': '''AppInputOtpFormField(label: '验证码', length: 6);''',
    '电话号码': '''AppPhoneInputFormField(label: '电话号码');''',
    '标签输入': '''AppChipInputFormField(label: '标签');''',
    '星级评分': '''AppStarRatingFormField(label: '评分');''',
    '数字输入': '''AppNumberInputFormField(label: '数量');''',
    '日期': '''AppDatePickerFormField(label: '日期');''',
    '日期范围': '''AppDateRangePickerFormField(label: '日期范围');''',
    '日期时间': '''AppDateTimePickerFormField(label: '日期时间');''',
    '时间': '''AppTimeStepperPickerFormField(label: '时间');''',
    '格式化输入': '''AppFormattedInputFormField(label: '参考编号');''',
    '颜色选择': '''AppColorInputFormField(label: '强调色');''',
    '多选方案': '''AppMultipleChoiceFormField<String>(
  label: '方案',
  options: choices,
);''',
    '条目选择': '''AppItemPickerFormField<String>(
  label: '条目',
  options: items,
);''',
    '拖动排序': '''AppSortableInputFormField<String>(
  label: '章节顺序',
  initialValue: const ['概览', '动态', '设置'],
  itemBuilder: (context, index, item) => Text(item),
);''',
    '对象输入': '''AppObjectInputFormField(label: '对象');''',
    '空状态': '''AppEmpty(
  icon: const Icon(AppLucideIcons.inbox),
  title: const Text('暂无数据'),
);''',
    '列表条目': '''AppItem(title: const Text('项目说明.pdf'));''',
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
    '无内部线与独立配色': '''AppDataGrid<User>.local(
  columns: columns,
  rows: users,
  rowKey: (user) => user.id,
  showInternalDividers: false,
  headerBackgroundColor: colors.primary,
  headerForegroundColor: colors.primaryForeground,
  cellBackgroundColor: colors.card,
  cellForegroundColor: colors.cardForeground,
  rowBackgroundColor: (user) => user.disabled
      ? colors.destructive.withValues(alpha: 0.08)
      : null,
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
    '头像': '''const AppAvatar.circle(name: '林晓', initialsCount: 1);
const AppAvatar.square(name: '张三', initialsCount: 2);
const AppAvatar.square(
  name: '世茂',
  appearance: AppAvatarAppearance.soft,
);
const AppAvatar.square(
  icon: Icon(AppLucideIcons.building2),
  color: Color(0xffd97706),
);
const AppAvatarGroup(children: [
  AppAvatar.circle(name: '王芳', initialsCount: 1),
  AppAvatar.square(name: '李雷', initialsCount: 1),
  AppAvatar.circle(name: '赵敏', initialsCount: 1),
]);''',
    '角标': '''AppCornerBadge.count(
  count: 42,
  position: AppCornerBadgePosition.topRight,
  child: const AppAvatar.square(
    icon: Icon(AppLucideIcons.folder),
    color: Color(0xff0891b2),
  ),
);

AppCornerBadge.dot(
  position: AppCornerBadgePosition.bottomLeft,
  child: yourWidget,
);''',
    '徽章': '''AppBadge.success(size: AppBadgeSize.large, child: const Text('大'));
AppBadge.success(
  padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
  child: const Text('自定义内边距'),
);''',
    '进度条': '''const AppProgress(progress: 0.64);
const AppLinearProgressIndicator(value: 0.64);''',
    '数字滚动': '''AppNumberTicker(number: 1280);''',
    '代码片段': '''const AppCodeSnippet(
  code: Text('final theme = AppThemeConfig.standard();'),
);''',
    '日历': '''AppCalendar(
  view: AppCalendarView.now(),
  selectionMode: CalendarSelectionMode.single,
);''',
    '芯片': '''const AppChip(child: Text('Flutter'));''',
    '骨架屏': '''const AppSkeleton(child: Text('正在加载资料'));''',
    '圆点指示器': '''const AppDotIndicator(index: 1, length: 4);''',
    '键盘按键': '''const AppKeyboardDisplay(
  keys: [LogicalKeyboardKey.control, LogicalKeyboardKey.keyK],
);''',
    '状态轨迹': '''const AppTracker(data: [
  AppTrackerData(level: TrackerLevel.fine, tooltip: Text('正常')),
]);''',
    '溢出滚动': '''const AppText.body(
  '鼠标划入后滚动的较长内容',
  scrollMode: AppTextScrollMode.hover,
);''',
    '可选文本': '''const AppSelectableText('这段内容可以复制');''',
    '滚动条视图': '''const AppScrollbarView(child: Text('可滚动内容'));''',
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
);
const AppCard.soft(
  color: Color(0xffd97706),
  child: Text('颜色驱动卡片'),
);
const AppCard.elevated(
  shadow: false,
  child: Text('快捷关闭阴影'),
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
    '折叠面板': '''const AppCollapsible(children: [
  AppCollapsibleTrigger(child: Text('高级详情')),
  AppCollapsibleContent(child: Text('隐藏内容')),
]);''',
    '分隔线': '''AppDivider.horizontal();
AppDivider.text('OR');
AppDivider.vertical(width: 32);''',
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
    '下拉菜单': '''AppDropdownButton(
  items: items,
  child: const Text('更多操作'),
);''',
    '上下文菜单': '''AppContextMenu(
  items: items,
  child: const Text('右键打开菜单'),
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
    '标签列表': '''AppTabList(
  index: index,
  onChanged: onChanged,
  children: const [AppTabItem(child: Text('列表'))],
);''',
    '面板切换器': '''AppSwitcher(
  index: index,
  children: const [Text('面板 A'), Text('面板 B')],
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
    '对话框': '''AppDialog.show(
  context: context,
  builder: (context) => AppAlertDialog(
    title: const Text('确认操作'),
    content: const Text('内容'),
  ),
);''',
    '表单对话框': '''AppDialog.show(
  context: context,
  builder: (context) => AppFormDialog(
    title: const Text('编辑'),
    content: const AppTextFormField(label: '名称'),
  ),
);''',
    '抽屉': '''AppDrawer.show(
  context: context,
  builder: (context) => content,
);''',
    '面板': '''AppSheet.show(
  context: context,
  builder: (context) => content,
);''',
    '气泡弹层': '''AppPopover.show(
  context: context,
  builder: (context) => const AppCard(child: Text('气泡内容')),
);''',
    '悬浮卡片': '''AppHoverCard(
  child: const Text('悬浮卡片'),
  hoverBuilder: (context) => const Text('详细内容'),
);''',
    '工具提示': '''AppTooltip(
  tooltip: (context) => const Text('辅助说明'),
  child: const Icon(AppLucideIcons.circleHelp),
);''',
    '通用锚点浮层': '''AppAnchoredOverlay(
  placement: AppAnchoredOverlayPlacement.auto,
  triggers: {AppAnchoredOverlayTrigger.manual},
  anchorBuilder: (_, actions) => AppButton.outline(
    onPressed: actions.toggle,
    child: const Text('锚点'),
  ),
  overlayBuilder: (_, actions) => DetailPanel(onClose: actions.close),
);''',
    '轻提示': '''AppToast.show(context: context, title: '已保存');''',
    '下拉刷新':
        '''AppRefreshTrigger(onRefresh: repository.refresh, child: list);''',
    '滑动触发器': '''AppSwiper(
  position: OverlayPosition.left,
  handler: SwiperHandler.drawer,
  builder: (context) => drawer,
  child: content,
);''',
    '表格': '''const AppTable(
  striped: true,
  showInternalDividers: false,
  headerBackgroundColor: Color(0xFFF1F5F9),
  rows: [
    AppTableHeader(cells: [
      AppTableCell(child: Text('组件')),
      AppTableCell(child: Text('状态')),
    ]),
    AppTableRow(cells: [
      AppTableCell(child: Text('AppForm')),
      AppTableCell(child: Text('正常')),
    ]),
  ],
);''',
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
    '异步树与懒加载': '''AppTree<String>.async(
  loadChildren: repository.loadChildren,
  onSelected: onSelected,
);''',
    '网格 Item 原地悬浮展开': '''AppExpandableGrid(items: items);''',
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
