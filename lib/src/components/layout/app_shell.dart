import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../display/app_text.dart';
import '../navigation/app_sidebar.dart';
import '../overlay/app_overlay_components.dart';
import '../../foundation/app_shadow_types.dart';
import '../../motion/app_page_transition.dart';

/// Responsive admin shell with expanded, compact, drawer, and auto sidebar modes.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.sidebarContent,
    required this.selectedId,
    required this.onDestinationSelected,
    required this.child,
    this.brandTitle = 'Lemon Shadcn',
    this.brandSubtitle,
    this.pageTitle,
    this.pageSubtitle,
    this.headerActions = const [],
    this.sidebarFooter,
    this.sidebarFrame,
    this.sidebarWidth = 248,
    this.compactSidebarWidth = 64,
    this.expandedBreakpoint = 1080,
    this.compactBreakpoint = 720,
    this.sidebarMode = AppSidebarType.auto,
    this.onSidebarModeChanged,
    this.contentTransitionDuration,
    this.contentTransitionCurve = Curves.easeOutCubic,
    this.transitionShadowQuality = AppShadowQuality.reduced,
    this.selectedColor,
  });

  final AppSidebarContent sidebarContent;
  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final Widget child;
  final String brandTitle;
  final String? brandSubtitle;
  final String? pageTitle;
  final String? pageSubtitle;
  final List<Widget> headerActions;
  final Widget? sidebarFooter;

  /// App-layer chrome around [AppSidebar] (e.g. wrap with [AppCard]).
  final Widget Function(Widget sidebar)? sidebarFrame;
  final double sidebarWidth;
  final double compactSidebarWidth;
  final double expandedBreakpoint;
  final double compactBreakpoint;
  final AppSidebarType sidebarMode;
  final ValueChanged<AppSidebarType>? onSidebarModeChanged;

  /// Enables transition-friendly switching for the shell content when set.
  /// The current [selectedId] is used as the page identity.
  final Duration? contentTransitionDuration;
  final Curve contentTransitionCurve;
  final AppShadowQuality transitionShadowQuality;
  final Color? selectedColor;

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
      config: AppButtonConfig.plain,
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

  Widget _frame(Widget sidebar) =>
      sidebarFrame == null ? sidebar : sidebarFrame!(sidebar);

  Widget _content() {
    final duration = contentTransitionDuration;
    if (duration == null) return child;
    return AppPageTransition(
      duration: duration,
      curve: contentTransitionCurve,
      shadowQuality: transitionShadowQuality,
      child: KeyedSubtree(key: ValueKey(selectedId), child: child),
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
        child: _frame(
          AppSidebar(
            content: sidebarContent,
            selectedId: selectedId,
            onDestinationSelected: (id) {
              onDestinationSelected(id);
              AppOverlay.close<void>(overlayContext);
            },
            header: AppSidebarHeader(child: _brand()),
            footer: sidebarFooter == null
                ? null
                : AppSidebarFooter(child: sidebarFooter!),
            expandedWidth: sidebarWidth,
            selectedColor: selectedColor,
          ),
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
                  child: _frame(
                    AppSidebar(
                      content: sidebarContent,
                      selectedId: selectedId,
                      onDestinationSelected: onDestinationSelected,
                      mode: mode,
                      header: AppSidebarHeader(
                        child: _brand(compact: mode == AppSidebarMode.compact),
                      ),
                      footer: mode == AppSidebarMode.expanded
                          ? sidebarFooter == null
                                ? null
                                : AppSidebarFooter(child: sidebarFooter!)
                          : null,
                      expandedWidth: sidebarWidth,
                      compactWidth: compactSidebarWidth,
                      selectedColor: selectedColor,
                    ),
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
                                config: AppButtonConfig.plain,
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
                            for (
                              var index = 0;
                              index < headerActions.length;
                              index++
                            ) ...[
                              if (index > 0) const SizedBox(width: 12),
                              headerActions[index],
                            ],
                          ],
                        ),
                      ),
                    Expanded(child: _content()),
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
