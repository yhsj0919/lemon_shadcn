import 'dart:async';

import 'package:lemon_shadcn/lemon_shadcn.dart';

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
          title: '按钮动效',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton.primary(
                onPressed: () {},
                config: const AppButtonConfig(
                  hoverLift: true,
                  pressEffect: AppButtonPressEffect.returnToBase,
                ),
                child: const Text('悬浮上移 · 按下回位'),
              ),
              AppButton.secondary(
                onPressed: () {},
                config: const AppButtonConfig(
                  hoverLift: true,
                  pressEffect: AppButtonPressEffect.lift,
                ),
                child: const Text('悬浮上移 · 按下上浮'),
              ),
              AppButton.text(
                onPressed: () {},
                config: const AppButtonConfig(hoverLift: true),
                child: const Text('纯文字悬浮'),
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
                child: const Text('新建项目'),
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
                tooltip: '添加项目',
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
                tooltip: '删除项目',
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
                tooltip: '添加项目',
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
                tooltip: '删除项目',
                variant: AppButtonVariant.destructive,
                onPressed: () {},
                icon: const Icon(LucideIcons.trash2),
              ),
            ],
          ),
        ),
        const ComponentSection(title: '共享异步操作', child: _SharedActionDemo()),
        ComponentSection(title: '切换按钮', child: const _ToggleDemo()),
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
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return AppToggle(
      value: _selected,
      onChanged: (value) => setState(() => _selected = value),
      child: const Text('固定工具栏'),
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

class ComponentSection extends StatelessWidget {
  const ComponentSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text(title).h3(), const Gap(20), child],
      ),
    );
  }
}
