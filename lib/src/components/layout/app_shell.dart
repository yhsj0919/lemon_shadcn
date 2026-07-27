import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../display/app_text.dart';
import '../navigation/app_sidebar.dart';
import '../overlay/app_overlay_components.dart';

/// Responsive admin shell with expanded, compact, drawer, and auto sidebar modes.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onDestinationSelected,
    required this.child,
    this.brandTitle = 'Lemon Shadcn',
    this.brandSubtitle,
    this.pageTitle,
    this.pageSubtitle,
    this.headerActions = const [],
    this.sidebarFooter,
    this.sidebarWidth = 248,
    this.compactSidebarWidth = 64,
    this.expandedBreakpoint = 1080,
    this.compactBreakpoint = 720,
    this.sidebarMode = AppSidebarType.auto,
    this.onSidebarModeChanged,
  });

  final List<AppNavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final Widget child;
  final String brandTitle;
  final String? brandSubtitle;
  final String? pageTitle;
  final String? pageSubtitle;
  final List<Widget> headerActions;
  final Widget? sidebarFooter;
  final double sidebarWidth;
  final double compactSidebarWidth;
  final double expandedBreakpoint;
  final double compactBreakpoint;
  final AppSidebarType sidebarMode;
  final ValueChanged<AppSidebarType>? onSidebarModeChanged;

  AppSidebarType _responsiveType(double width) {
    if (width >= expandedBreakpoint) return AppSidebarType.expanded;
    if (width >= compactBreakpoint) return AppSidebarType.compact;
    return AppSidebarType.drawer;
  }

  AppSidebarType _effectiveType(double width) {
    return sidebarMode == AppSidebarType.auto
        ? _responsiveType(width)
        : sidebarMode;
  }

  AppSidebarType _nextType(AppSidebarType type) => switch (type) {
        AppSidebarType.auto => AppSidebarType.expanded,
        AppSidebarType.expanded => AppSidebarType.compact,
        AppSidebarType.compact => AppSidebarType.drawer,
        AppSidebarType.drawer => AppSidebarType.auto,
      };

  Widget _modeButton(AppSidebarType type) {
    return AppIconButton(
      tooltip: '切换侧边栏模式',
      icon: Icon(switch (type) {
        AppSidebarType.auto => shad.LucideIcons.monitorSmartphone,
        AppSidebarType.expanded => shad.LucideIcons.panelLeftClose,
        AppSidebarType.compact => shad.LucideIcons.panelLeft,
        AppSidebarType.drawer => shad.LucideIcons.menu,
      }),
      onPressed: onSidebarModeChanged == null
          ? null
          : () => onSidebarModeChanged!(_nextType(type)),
    );
  }

  Widget _brand({bool compact = false}) {
    if (compact) {
      return const Center(child: Icon(shad.LucideIcons.panelLeft, size: 20));
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.title(brandTitle),
        if (brandSubtitle != null) ...[
          const SizedBox(height: 4),
          AppText.muted(brandSubtitle!),
        ],
      ],
    );
  }

  void _showDrawer(BuildContext context) {
    AppDrawer.show<void>(
      context: context,
      position: shad.OverlayPosition.left,
      draggable: false,
      expands: false,
      constraints: BoxConstraints.tightFor(width: sidebarWidth + 24),
      builder: (overlayContext) => Padding(
        padding: const EdgeInsets.all(12),
        child: AppSidebar(
          destinations: destinations,
          selectedId: selectedId,
          onDestinationSelected: (id) {
            onDestinationSelected(id);
            AppOverlay.close<void>(overlayContext);
          },
          header: _brand(),
          footer: sidebarFooter,
          expandedWidth: sidebarWidth,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveType = _effectiveType(constraints.maxWidth);
        final drawer = effectiveType == AppSidebarType.drawer;
        final mode = effectiveType == AppSidebarType.compact
            ? AppSidebarMode.compact
            : AppSidebarMode.expanded;
        return shad.Scaffold(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (!drawer)
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
                  child: AppSidebar(
                    destinations: destinations,
                    selectedId: selectedId,
                    onDestinationSelected: onDestinationSelected,
                    mode: mode,
                    header: _brand(compact: mode == AppSidebarMode.compact),
                    footer: mode == AppSidebarMode.expanded
                        ? sidebarFooter
                        : null,
                    expandedWidth: sidebarWidth,
                    compactWidth: compactSidebarWidth,
                  ),
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (drawer ||
                        pageTitle != null ||
                        headerActions.isNotEmpty ||
                        onSidebarModeChanged != null)
                      Padding(
                        padding: EdgeInsets.fromLTRB(
                          drawer ? 12 : 24,
                          14,
                          drawer ? 12 : 24,
                          10,
                        ),
                        child: Row(
                          children: [
                            if (drawer) ...[
                              AppIconButton(
                                tooltip: '打开菜单',
                                icon: const Icon(shad.LucideIcons.menu),
                                onPressed: () => _showDrawer(context),
                              ),
                              const SizedBox(width: 12),
                            ],
                            if (onSidebarModeChanged != null) ...[
                              _modeButton(sidebarMode),
                              const SizedBox(width: 12),
                            ],
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (pageTitle != null) AppText.h3(pageTitle!),
                                  if (pageSubtitle != null)
                                    AppText.muted(pageSubtitle!),
                                ],
                              ),
                            ),
                            ...headerActions,
                          ],
                        ),
                      ),
                    Expanded(child: child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
