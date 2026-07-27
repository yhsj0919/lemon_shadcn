import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class OverlayPage extends StatelessWidget {
  const OverlayPage({super.key});

  Widget _panel(BuildContext context, String title) {
    return SizedBox(
      width: 320,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title).h3(),
            const Gap(8),
            const Text('无需 ShadcnApp 即可打开。'),
            const Gap(16),
            AppButton.outline(
              onPressed: () => AppOverlay.close(context),
              child: const Text('关闭'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: '弹层与浮层',
      description: '对话框、临时浮层、悬浮帮助和通知。',
      sections: [
        ComponentSection(
          title: '模态浮层',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton.outline(
                onPressed: () => AppDialog.show<void>(
                  context: context,
                  builder: (dialogContext) => AppAlertDialog(
                    title: const Text('确认操作'),
                    content: const Text('该对话框使用共享浮层宿主。'),
                    actions: [
                      AppButton.outline(
                        onPressed: () => AppOverlay.close(dialogContext),
                        child: const Text('取消'),
                      ),
                    ],
                  ),
                ),
                child: const Text('对话框'),
              ),
              AppButton.outline(
                onPressed: () => AppDrawer.show<void>(
                  context: context,
                  position: OverlayPosition.right,
                  builder: (drawerContext) => _panel(drawerContext, '抽屉'),
                ),
                child: const Text('抽屉'),
              ),
              AppButton.outline(
                onPressed: () => AppSheet.show<void>(
                  context: context,
                  draggable: true,
                  builder: (sheetContext) => _panel(sheetContext, '面板'),
                ),
                child: const Text('面板'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '气泡与悬浮',
          child: Wrap(
            spacing: 20,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Builder(
                builder: (anchorContext) => AppButton.outline(
                  onPressed: () => AppPopover.show<void>(
                    context: anchorContext,
                    builder: (context) =>
                        const AppCard(child: Text('气泡内容')),
                  ),
                  child: const Text('气泡弹层'),
                ),
              ),
              const AppHoverCard(
                wait: Duration(milliseconds: 100),
                hoverBuilder: _buildHoverCard,
                child: Text('悬浮卡片'),
              ),
              AppTooltip(
                tooltip: (context) => const Text('辅助说明'),
                child: const Icon(LucideIcons.circleHelp),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '轻提示',
          child: AppButton.primary(
            onPressed: () => AppToast.show(
              context: context,
              title: '已保存',
              message: '全局 ToastLayer 由 AppShadcnScope 提供。',
            ),
            child: const Text('显示轻提示'),
          ),
        ),
        ComponentSection(
          title: '刷新与滑动触发器',
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: AppRefreshTrigger(
                  onRefresh: () async {},
                  child: ListView(
                    children: const [
                      AppCard(child: Center(child: Text('下拉刷新区域'))),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              AppSwiper(
                enabled: false,
                position: OverlayPosition.left,
                handler: SwiperHandler.drawer,
                builder: (context) => _panel(context, '滑动抽屉'),
                child: const AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('滑动触发器（示例中已禁用）'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildHoverCard(BuildContext context) =>
      const AppCard(child: Text('悬浮时显示详情'));
}
