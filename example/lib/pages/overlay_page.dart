import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

class OverlayPage extends StatelessWidget {
  const OverlayPage({
    super.key,
    this.visibleSections,
    this.title = '弹层与浮层',
    this.description = '对话框、临时浮层、悬浮帮助和通知。',
  });

  final Set<String>? visibleSections;
  final String title;
  final String description;

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
      title: title,
      description: description,
      sections:
          [
            ComponentSection(
              title: '鼠标覆盖层',
              code: '''AppHoverOverlay(
  borderRadius: BorderRadius.circular(20),
  child: YourLayout(),
  overlay: YourCustomOverlay(),
)''',
              child: AppHoverOverlay(
                borderRadius: BorderRadius.circular(20),
                overlay: ColoredBox(
                  color: const Color(0xffb8b8b8),
                  child: Center(
                    child: Wrap(
                      spacing: 20,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        AppButton.primary(
                          onPressed: () {},
                          child: const Text('设备信息'),
                        ),
                        AppButton.primary(
                          onPressed: () {},
                          child: const Text('节目编排'),
                        ),
                      ],
                    ),
                  ),
                ),
                child: Container(
                  width: 480,
                  height: 180,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xfff3f4f6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xffd1d5db)),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('世茂国际'),
                      Gap(12),
                      Text('济南市 · 历下区'),
                      Spacer(),
                      Text('在线 5   离线 1   异常 0'),
                    ],
                  ),
                ),
              ),
            ),
            ComponentSection(
              title: '对话框',
              child: AppButton.outline(
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
                child: const Text('打开对话框'),
              ),
            ),
            ComponentSection(
              title: '表单对话框',
              child: AppButton.outline(
                onPressed: () => AppDialog.show<void>(
                  context: context,
                  builder: (dialogContext) => AppFormDialog(
                    title: const Text('编辑名称'),
                    constraints: const BoxConstraints(maxWidth: 420),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text('表单弹窗保持正文色，不对 content 强制 muted。'),
                        const Gap(12),
                        const AppTextFormField(label: '名称', hintText: '请输入名称'),
                      ],
                    ),
                    actions: [
                      AppButton.outline(
                        onPressed: () => AppOverlay.close(dialogContext),
                        child: const Text('取消'),
                      ),
                      AppButton.primary(
                        onPressed: () => AppOverlay.close(dialogContext),
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ),
                child: const Text('打开表单对话框'),
              ),
            ),
            ComponentSection(
              title: '抽屉',
              child: AppButton.outline(
                onPressed: () => AppDrawer.show<void>(
                  context: context,
                  position: OverlayPosition.right,
                  builder: (drawerContext) => _panel(drawerContext, '抽屉'),
                ),
                child: const Text('打开抽屉'),
              ),
            ),
            ComponentSection(
              title: '面板',
              child: AppButton.outline(
                onPressed: () => AppSheet.show<void>(
                  context: context,
                  draggable: true,
                  builder: (sheetContext) => _panel(sheetContext, '面板'),
                ),
                child: const Text('打开面板'),
              ),
            ),
            ComponentSection(
              title: '气泡弹层',
              child: Builder(
                builder: (anchorContext) => AppButton.outline(
                  onPressed: () => AppPopover.show<void>(
                    context: anchorContext,
                    builder: (context) => const AppCard(child: Text('气泡内容')),
                  ),
                  child: const Text('打开气泡'),
                ),
              ),
            ),
            const ComponentSection(
              title: '悬浮卡片',
              child: AppHoverCard(
                wait: Duration(milliseconds: 100),
                hoverBuilder: _buildHoverCard,
                child: Text('悬浮卡片'),
              ),
            ),
            ComponentSection(
              title: '工具提示',
              child: AppTooltip(
                tooltip: (context) => const Text('辅助说明'),
                child: const Icon(LucideIcons.circleHelp),
              ),
            ),
            ComponentSection(
              title: '通用锚点浮层',
              code: '''AppAnchoredOverlay(
  placement: AppAnchoredOverlayPlacement.auto,
  triggers: {AppAnchoredOverlayTrigger.manual},
  width: AppAnchoredOverlayWidth.matchAnchor,
  anchorBuilder: (_, actions) => AppButton.outline(
    onPressed: actions.toggle,
    child: const Text('任意锚点'),
  ),
  overlayBuilder: (_, actions) => DetailPanel(onClose: actions.close),
)''',
              child: AppAnchoredOverlay(
                placement: AppAnchoredOverlayPlacement.auto,
                triggers: const <AppAnchoredOverlayTrigger>{
                  AppAnchoredOverlayTrigger.manual,
                },
                width: AppAnchoredOverlayWidth.fixed,
                fixedWidth: 280,
                anchorBuilder: (context, actions) => AppButton.outline(
                  onPressed: actions.toggle,
                  child: const Text('打开通用锚点浮层'),
                ),
                overlayBuilder: (context, actions) => Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      const Text('任意浮层内容').h4(),
                      const Gap(8),
                      const Text('自动选择空间更充足的方向，并跟随锚点和窗口尺寸变化。'),
                      const Gap(12),
                      AppButton.outline(
                        onPressed: actions.close,
                        child: const Text('关闭'),
                      ),
                    ],
                  ),
                ),
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
              title: '下拉刷新',
              child: SizedBox(
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
            ),
            ComponentSection(
              title: '滑动触发器',
              child: AppSwiper(
                enabled: false,
                position: OverlayPosition.left,
                handler: SwiperHandler.drawer,
                builder: (context) => _panel(context, '滑动抽屉'),
                child: const AppCard(
                  padding: EdgeInsets.all(16),
                  child: Text('滑动触发器（示例中已禁用）'),
                ),
              ),
            ),
          ].where((section) {
            return visibleSections?.contains(section.title) ?? true;
          }).toList(),
    );
  }

  static Widget _buildHoverCard(BuildContext context) =>
      const AppCard(child: Text('悬浮时显示详情'));
}
