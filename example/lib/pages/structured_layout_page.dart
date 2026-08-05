import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

class StructuredLayoutPage extends StatefulWidget {
  const StructuredLayoutPage({super.key});

  @override
  State<StructuredLayoutPage> createState() => _StructuredLayoutPageState();
}

class _StructuredLayoutPageState extends State<StructuredLayoutPage> {
  final _stepper = AppStepperController();
  final _verticalStepper = AppStepperController();
  List<AppTreeNode<String>> _treeNodes = [
    AppTreeItemNode(
      data: '项目目录',
      expanded: true,
      children: [
        AppTreeItemNode(
          data: '组件',
          expanded: true,
          children: [
            AppTreeItemNode(data: '按钮.dart'),
            AppTreeItemNode(data: '表单.dart'),
          ],
        ),
        AppTreeItemNode(data: '基础设施'),
      ],
    ),
    AppTreeItemNode(data: '测试'),
  ];

  @override
  void dispose() {
    _stepper.dispose();
    _verticalStepper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: '结构化布局',
      description: '可调整尺寸、顺序、层级和表格布局。',
      sections: [
        ComponentSection(
          title: '轮播',
          child: SizedBox(
            height: 120,
            child: AppCarousel(
              itemCount: 3,
              wrap: false,
              transition: const AppCarouselTransition.sliding(gap: 12),
              sizeConstraint: const AppCarouselFractionalConstraint(.72),
              itemBuilder: (context, index) =>
                  AppCard(child: Center(child: Text('面板 ${index + 1}'))),
            ),
          ),
        ),
        const ComponentSection(
          title: '可调整尺寸',
          child: SizedBox(
            height: 140,
            child: AppResizable.horizontal(
              children: [
                AppResizablePane(
                  initialSize: 180,
                  child: Center(child: Text('文件')),
                ),
                AppResizablePane.flex(child: Center(child: Text('编辑者'))),
              ],
            ),
          ),
        ),
        ComponentSection(
          title: '步进器',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStepper.horizontal(
                controller: _stepper,
                steps: const [
                  AppStep(title: Text('账户')),
                  AppStep(title: Text('个人资料')),
                  AppStep(title: Text('确认')),
                ],
              ),
              const Gap(12),
              AppButton.outline(
                onPressed: () => _stepper.nextStep(),
                child: const Text('下一步'),
              ),
              const Gap(24),
              const Text('垂直步进器'),
              const Gap(12),
              AppStepper.vertical(
                controller: _verticalStepper,
                steps: const [
                  AppStep(title: Text('创建账户')),
                  AppStep(title: Text('填写资料')),
                  AppStep(title: Text('完成确认')),
                ],
              ),
              const Gap(12),
              AppButton.outline(
                onPressed: () => _verticalStepper.nextStep(),
                child: const Text('下一步'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '树形结构',
          child: SizedBox(
            height: 220,
            child: AppTree<String>(
              nodes: _treeNodes,
              shrinkWrap: true,
              branchLine: BranchLine.line,
              allowMultiSelect: false,
              recursiveSelection: false,
              onSelectionChanged: Tree.defaultSelectionHandler<String>(
                _treeNodes,
                (nodes) => setState(() => _treeNodes = nodes),
              ),
              builder: (context, item) => AppTreeItem(
                onExpand: item.leaf
                    ? null
                    : (expanded) => setState(() {
                        final selected = Tree.setSelectedItems<String>(
                          _treeNodes,
                          [item.data],
                        );
                        _treeNodes = expanded
                            ? Tree.expandItem<String>(selected, item.data)
                            : Tree.collapseItem<String>(selected, item.data);
                      }),
                child: Text(item.data),
              ),
            ),
          ),
        ),
        ComponentSection(
          title: '异步树与懒加载',
          code: '''AppAsyncTree<String>.future(
  loadRoots: loadRootNodes,
  loadChildren: (parent) => loadChildren(parent.id),
  builder: (_, node) => Text(node.data),
  // 完全接管整行时使用：
  // itemBuilder: (_, details) => MyTreeRow(details: details),
)''',
          child: SizedBox(
            height: 220,
            child: AppAsyncTree<String>.future(
              loadRoots: () async => const <AppAsyncTreeNode<String>>[
                AppAsyncTreeNode(id: 'services', data: '服务', hasChildren: true),
                AppAsyncTreeNode(
                  id: 'documents',
                  data: '文档',
                  hasChildren: true,
                ),
              ],
              loadChildren: (parent) async {
                await Future<void>.delayed(const Duration(milliseconds: 450));
                return <AppAsyncTreeNode<String>>[
                  AppAsyncTreeNode(
                    id: '${parent.id}-1',
                    data: parent.id == 'services' ? '用户服务' : '快速开始.md',
                  ),
                  AppAsyncTreeNode(
                    id: '${parent.id}-2',
                    data: parent.id == 'services' ? '订单服务' : '主题配置.md',
                  ),
                ];
              },
              builder: (context, node) => Text(node.data),
            ),
          ),
        ),
        const ComponentSection(
          title: '网格 Item 原地悬浮展开',
          code: '''// 保留主显示区，在指定方向追加展开区
AppExpandableOverlay.sections(
  expandedSize: const Size(420, 240),
  direction: AppExpandDirection.auto,
  // axis: AppExpandAxis.both, // 需要同时改变宽高时显式开启
  mainBuilder: (_, open) => SummaryCard(onTap: open),
  overlayMainBuilder: (_, close) => SummaryContent(onTap: close),
  contentBuilder: (_, close) => DetailPanel(onClose: close),
)

// 主显示与展开视图完全不同时，使用默认构造
AppExpandableOverlay(
  expandedSize: const Size(420, 240),
  collapsedBuilder: (_, open) => SummaryCard(onTap: open),
  expandedBuilder: (_, close) => FullDetailCard(onClose: close),
)''',
          child: SizedBox(height: 280, child: _ExpandableGridDemo()),
        ),
        const ComponentSection(
          title: '表格',
          child: AppTable(
            rows: [
              AppTableHeader(
                cells: [
                  AppTableCell(child: Text('组件')),
                  AppTableCell(child: Text('状态')),
                ],
              ),
              AppTableRow(
                cells: [
                  AppTableCell(child: Text('AppForm')),
                  AppTableCell(child: Text('正常')),
                ],
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: '固定面板',
          child: SizedBox(
            height: 180,
            child: AppPinnedSheet(
              initialStage: AppPinnedSheetStage.expanded(),
              backdropTransform: AppScaleBackdropTransform(),
              backdrop: Center(child: Text('背景内容')),
              child: AppCard(child: Center(child: Text('固定工具'))),
            ),
          ),
        ),
        ComponentSection(
          title: '窗口',
          child: SizedBox(
            height: 260,
            child: AppWindowNavigator(
              showTopSnapBar: false,
              initialWindows: [
                AppWindow(
                  title: Text('主题预览'),
                  content: Center(child: Text('可拖动桌面窗口')),
                  bounds: Rect.fromLTWH(24, 18, 320, 200),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ExpandableGridDemo extends StatelessWidget {
  const _ExpandableGridDemo();

  @override
  Widget build(BuildContext context) {
    const directions = <AppExpandDirection>[
      AppExpandDirection.right,
      AppExpandDirection.down,
      AppExpandDirection.up,
      AppExpandDirection.left,
    ];
    const labels = <String>['向右展开', '向下展开', '向上展开', '向左展开'];
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.4,
      ),
      itemCount: directions.length,
      itemBuilder: (context, index) => AppExpandableOverlay.sections(
        expandedSize:
            directions[index] == AppExpandDirection.left ||
                directions[index] == AppExpandDirection.right
            ? const Size(480, 0)
            : const Size(0, 300),
        direction: directions[index],
        mainBuilder: (context, open) => GestureDetector(
          onTap: open,
          child: AppCard(child: Center(child: Text('${labels[index]} · 点击卡片'))),
        ),
        overlayMainBuilder: (context, close) => GestureDetector(
          onTap: close,
          child: Center(child: Text('${labels[index]} · 点击卡片')),
        ),
        contentBuilder: (context, close) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(child: Text(labels[index]).h3()),
                  AppIconButton(
                    icon: const Icon(LucideIcons.x),
                    tooltip: '收起',
                    variant: AppButtonVariant.ghost,
                    onPressed: close,
                  ),
                ],
              ),
              const Gap(16),
              const Text('浮层完整覆盖原 Item，底层网格尺寸和相邻卡片位置保持不变。'),
            ],
          ),
        ),
      ),
    );
  }
}
