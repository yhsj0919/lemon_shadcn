import 'dart:async';

import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import '../gallery/component_example_code.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'AppButton',
      description: '按钮变体、图标按钮、异步操作与 Toggle。',
      sections: [
        ComponentSection(
          title: '按钮变体',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton.primary(
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 900));
                },
                loadingLabel: '保存中',
                child: const Text('异步主按钮'),
              ),
              AppButton.secondary(onPressed: () {}, child: const Text('次要按钮')),
              AppButton.outline(onPressed: () {}, child: const Text('描边按钮')),
              AppButton.ghost(onPressed: () {}, child: const Text('幽灵按钮')),
              AppButton.destructive(
                onPressed: () {},
                child: const Text('危险按钮'),
              ),
              AppButton.link(onPressed: () {}, child: const Text('链接按钮')),
              AppButton.text(onPressed: () {}, child: const Text('文本按钮')),
            ],
          ),
        ),
        ComponentSection(
          title: '按钮尺寸',
          child: Wrap(
            spacing: 28,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.outline(
                    size: AppButtonSize.xSmall,
                    onPressed: () {},
                    child: const Text('超小号'),
                  ),
                  const SizedBox(width: 8),
                  AppIconButton(
                    size: AppButtonSize.xSmall,
                    tooltip: '超小号图标按钮',
                    onPressed: () {},
                    icon: const Icon(LucideIcons.arrowUpRight),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.outline(
                    size: AppButtonSize.small,
                    onPressed: () {},
                    child: const Text('小'),
                  ),
                  const SizedBox(width: 8),
                  AppIconButton(
                    size: AppButtonSize.small,
                    tooltip: '小号图标按钮',
                    onPressed: () {},
                    icon: const Icon(LucideIcons.arrowUpRight),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.outline(
                    size: AppButtonSize.normal,
                    onPressed: () {},
                    child: const Text('默认'),
                  ),
                  const SizedBox(width: 8),
                  AppIconButton(
                    size: AppButtonSize.normal,
                    tooltip: '默认图标按钮',
                    onPressed: () {},
                    icon: const Icon(LucideIcons.arrowUpRight),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppButton.outline(
                    size: AppButtonSize.large,
                    onPressed: () {},
                    child: const Text('大型'),
                  ),
                  const SizedBox(width: 8),
                  AppIconButton(
                    size: AppButtonSize.large,
                    tooltip: '大型图标按钮',
                    onPressed: () {},
                    icon: const Icon(LucideIcons.arrowUpRight),
                  ),
                ],
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '按钮动效',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppButton.primary(
                onPressed: () {},
                child: const Text('默认：悬停不动 · 按下下沉'),
              ),
              AppButton.primary(
                onPressed: () {},
                config: AppButtonConfig.plain,
                child: const Text('关闭动效'),
              ),
              AppIconButton(
                tooltip: '图标默认动效',
                variant: AppButtonVariant.primary,
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
              ),
              AppIconButton.circle(
                tooltip: '圆形默认动效',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
                icon: const Icon(LucideIcons.search),
              ),
              AppIconButton(
                tooltip: '图标关闭动效',
                variant: AppButtonVariant.outline,
                config: AppButtonConfig.plain,
                onPressed: () {},
                icon: const Icon(LucideIcons.settings),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '按钮组',
          child: Wrap(
            spacing: 20,
            runSpacing: 20,
            crossAxisAlignment: WrapCrossAlignment.start,
            children: [
              AppButtonGroup.horizontal(
                children: [
                  AppButton.outline(onPressed: () {}, child: const Text('上一页')),
                  AppButton.outline(onPressed: () {}, child: const Text('当前页')),
                  AppButton.outline(onPressed: () {}, child: const Text('下一页')),
                ],
              ),
              AppButtonGroup.horizontal(
                children: [
                  AppButton.secondary(
                    onPressed: () {},
                    child: const Text('列表'),
                  ),
                  AppButton.outline(onPressed: () {}, child: const Text('网格')),
                  AppButton.outline(onPressed: () {}, child: const Text('详情')),
                ],
              ),
              AppButtonGroup.vertical(
                children: [
                  AppButton.outline(onPressed: () {}, child: const Text('复制')),
                  AppButton.outline(onPressed: () {}, child: const Text('移动')),
                  AppButton.destructive(
                    onPressed: () {},
                    child: const Text('删除'),
                  ),
                ],
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '带图标按钮',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton.primary(
                onPressed: () {},
                leading: const Icon(LucideIcons.plus),
                child: const Text('新建页面'),
              ),
              AppButton.secondary(
                onPressed: () {},
                trailing: const Icon(LucideIcons.arrowRight),
                child: const Text('继续'),
              ),
              AppButton.outline(
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 900));
                },
                leading: const Icon(LucideIcons.download),
                loadingLabel: '下载中',
                child: const Text('下载'),
              ),
              AppButton.destructive(
                onPressed: () {},
                leading: const Icon(LucideIcons.trash2),
                child: const Text('删除'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '方形纯图标按钮',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppIconButton(
                key: const Key('square-icon-button-add'),
                tooltip: '添加页面',
                variant: AppButtonVariant.primary,
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
              ),
              AppIconButton(
                tooltip: '搜索',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
                icon: const Icon(LucideIcons.search),
              ),
              AppIconButton(
                key: const Key('square-icon-button-settings'),
                tooltip: '设置',
                onPressed: () {},
                icon: const Icon(LucideIcons.settings),
              ),
              AppIconButton(
                tooltip: '删除页面',
                variant: AppButtonVariant.destructive,
                onPressed: () {},
                icon: const Icon(LucideIcons.trash2),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '圆形纯图标按钮',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppIconButton.circle(
                key: const Key('icon-button-add'),
                tooltip: '添加页面',
                variant: AppButtonVariant.primary,
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
              ),
              AppIconButton.circle(
                key: const Key('icon-button-search'),
                tooltip: '搜索',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
                icon: const Icon(LucideIcons.search),
              ),
              AppIconButton.circle(
                key: const Key('icon-button-settings'),
                tooltip: '设置',
                onPressed: () {},
                icon: const Icon(LucideIcons.settings),
              ),
              AppIconButton.circle(
                key: const Key('icon-button-delete'),
                tooltip: '删除页面',
                variant: AppButtonVariant.destructive,
                onPressed: () {},
                icon: const Icon(LucideIcons.trash2),
              ),
            ],
          ),
        ),
        const ComponentSection(title: '共享异步操作', child: _SharedActionDemo()),
        const ComponentSection(title: '切换按钮', child: _ToggleDemo()),
      ],
    );
  }
}

class _SharedActionDemo extends StatefulWidget {
  const _SharedActionDemo();

  @override
  State<_SharedActionDemo> createState() => _SharedActionDemoState();
}

class _SharedActionDemoState extends State<_SharedActionDemo> {
  late final AppAsyncAction<void> _saveAction = AppAsyncAction(
    operation: () async {
      await Future<void>.delayed(const Duration(milliseconds: 900));
    },
    loadingDelay: const Duration(milliseconds: 120),
    minimumLoadingDuration: const Duration(milliseconds: 250),
  );

  @override
  void dispose() {
    _saveAction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        AppButton.primary(
          action: _saveAction,
          loadingLabel: '保存中',
          child: const Text('保存'),
        ),
        AppButton.outline(
          action: _saveAction,
          loadingLabel: '保存中',
          child: const Text('从工具栏保存'),
        ),
      ],
    );
  }
}

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo();

  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  bool _selected = true;
  String? _alignment = 'left';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppToggle(
          value: _selected,
          onChanged: (value) => setState(() => _selected = value),
          child: const Text('固定工具栏'),
        ),
        const Gap(12),
        AppToggleGroup<String>.single(
          value: _alignment,
          onChanged: (value) => setState(() => _alignment = value),
          items: const [
            AppToggleGroupItem(value: 'left', child: Text('左对齐')),
            AppToggleGroupItem(value: 'center', child: Text('居中')),
            AppToggleGroupItem(value: 'right', child: Text('右对齐')),
          ],
        ),
      ],
    );
  }
}

class ComponentPage extends StatelessWidget {
  const ComponentPage({
    super.key,
    required this.title,
    required this.description,
    required this.sections,
  });

  final String title;
  final String description;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title).h1(),
            const Gap(8),
            Text(description).muted(),
            const Gap(32),
            for (var index = 0; index < sections.length; index++) ...[
              if (index > 0) const Gap(24),
              sections[index],
            ],
          ],
        ),
      ),
    );
  }
}

class ComponentSection extends StatefulWidget {
  const ComponentSection({
    super.key,
    required this.title,
    required this.child,
    this.code,
  });

  final String title;
  final Widget child;
  final String? code;

  @override
  State<ComponentSection> createState() => _ComponentSectionState();
}

class _ComponentSectionState extends State<ComponentSection> {
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.none,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.title).h3(),
          const Gap(20),
          widget.child,
          const Gap(20),
          const AppDivider(),
          AppCollapsible(
            isExpanded: _showCode,
            onExpansionChanged: (value) => setState(() => _showCode = value),
            children: [
              const AppCollapsibleTrigger(child: Text('使用代码')),
              AppCollapsibleContent(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: AppCodeSnippet(
                    code: Text(
                      widget.code ?? ComponentExampleCode.resolve(widget.title),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
