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
            const Text('Opened without requiring ShadcnApp.'),
            const Gap(16),
            AppButton.outline(
              onPressed: () => AppOverlay.close(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Overlay and surfaces',
      description:
          'Dialogs, transient surfaces, hover help, and notifications.',
      sections: [
        ComponentSection(
          title: 'Modal surfaces',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton.outline(
                onPressed: () => AppDialog.show<void>(
                  context: context,
                  builder: (dialogContext) => AppAlertDialog(
                    title: const Text('Confirm action'),
                    content: const Text(
                      'The dialog uses the shared overlay host.',
                    ),
                    actions: [
                      AppButton.outline(
                        onPressed: () => AppOverlay.close(dialogContext),
                        child: const Text('Cancel'),
                      ),
                    ],
                  ),
                ),
                child: const Text('Dialog'),
              ),
              AppButton.outline(
                onPressed: () => AppDrawer.show<void>(
                  context: context,
                  position: OverlayPosition.right,
                  builder: (drawerContext) => _panel(drawerContext, 'Drawer'),
                ),
                child: const Text('Drawer'),
              ),
              AppButton.outline(
                onPressed: () => AppSheet.show<void>(
                  context: context,
                  draggable: true,
                  builder: (sheetContext) => _panel(sheetContext, 'Sheet'),
                ),
                child: const Text('Sheet'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Popover and hover',
          child: Wrap(
            spacing: 20,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Builder(
                builder: (anchorContext) => AppButton.outline(
                  onPressed: () => AppPopover.show<void>(
                    context: anchorContext,
                    offset: const Offset(0, 8),
                    builder: (context) => const AppCard(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('Popover content'),
                      ),
                    ),
                  ),
                  child: const Text('Popover'),
                ),
              ),
              const AppHoverCard(
                wait: Duration(milliseconds: 100),
                hoverBuilder: _buildHoverCard,
                child: Text('Hover card'),
              ),
              AppTooltip(
                tooltip: (context) => const Text('Helpful context'),
                child: const Icon(LucideIcons.circleHelp),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Toast',
          child: AppButton.primary(
            onPressed: () => AppToast.show(
              context: context,
              title: 'Saved',
              message: 'The global ToastLayer is provided by AppShadcnScope.',
            ),
            child: const Text('Show toast'),
          ),
        ),
        ComponentSection(
          title: 'Refresh and swipe triggers',
          child: Column(
            children: [
              SizedBox(
                height: 100,
                child: AppRefreshTrigger(
                  onRefresh: () async {},
                  child: ListView(
                    children: const [
                      AppCard(
                        child: Center(child: Text('Pull to refresh region')),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              AppSwiper(
                enabled: false,
                position: OverlayPosition.left,
                handler: SwiperHandler.drawer,
                builder: (context) => _panel(context, 'Swipe drawer'),
                child: const AppCard(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('Swipe trigger (disabled in gallery)'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _buildHoverCard(BuildContext context) => const AppCard(
    child: Padding(
      padding: EdgeInsets.all(12),
      child: Text('Details shown on hover'),
    ),
  );
}
