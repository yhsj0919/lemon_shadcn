import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'gallery/gallery_registry.dart';

void main() => runApp(const ComponentGallery());

class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  var _preset = AppThemePreset.standard;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lemon Shadcn',
      locale: const Locale('zh', 'CN'),
      supportedLocales: const [Locale('zh', 'CN'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: ThemeMode.system,
      builder: AppShadcnScope.builder(
        locale: const Locale('zh', 'CN'),
        config: AppThemeConfig.preset(_preset),
      ),
      home: GalleryShell(
        preset: _preset,
        onPresetChanged: (value) => setState(() => _preset = value),
      ),
    );
  }
}

class GalleryShell extends StatefulWidget {
  const GalleryShell({
    super.key,
    required this.preset,
    required this.onPresetChanged,
  });

  final AppThemePreset preset;
  final ValueChanged<AppThemePreset> onPresetChanged;

  @override
  State<GalleryShell> createState() => _GalleryShellState();
}

class _GalleryShellState extends State<GalleryShell> {
  var _selectedIndex = 0;
  var _sidebarMode = AppSidebarType.auto;

  @override
  Widget build(BuildContext context) {
    final selected = GalleryRegistry.entries[_selectedIndex];
    return AppShell(
      brandTitle: 'Lemon Shadcn',
      brandSubtitle: '管理端组件示例',
      sidebarMode: _sidebarMode,
      onSidebarModeChanged: (mode) => setState(() => _sidebarMode = mode),
      contentTransitionDuration: const Duration(milliseconds: 180),
      sidebarFrame: (sidebar) => AppCard(
        padding: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        child: sidebar,
      ),
      sidebarContent: AppSidebarContent(
        groups: [
          AppSidebarGroup(
            label: '组件分类',
            items: [
              for (final group in GalleryRegistry.groups)
                AppSidebarMenuItem(
                  id: 'group-${group.hashCode}',
                  label: group,
                  icon: _groupIcon(group),
                  children: [
                    for (final entry in GalleryRegistry.entries.where(
                      (entry) => entry.group == group,
                    ))
                      AppSidebarMenuItem(
                        id: entry.id,
                        label: entry.label,
                        icon: _componentIcon(entry.id),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
      selectedId: selected.id,
      onDestinationSelected: (id) {
        final index = GalleryRegistry.entries.indexWhere(
          (entry) => entry.id == id,
        );
        if (index >= 0) setState(() => _selectedIndex = index);
      },
      pageTitle: selected.label,
      pageSubtitle: selected.subtitle,
      headerActions: [
        SizedBox(
          key: const Key('theme-preset-picker'),
          width: 152,
          child: AppSelect<AppThemePreset>(
            value: widget.preset,
            hintText: '选择主题',
            onChanged: (value) {
              if (value != null) widget.onPresetChanged(value);
            },
            options: [
              for (final preset in AppThemePreset.values)
                AppOption(value: preset, label: _presetLabel(preset)),
            ],
          ),
        ),
      ],
      sidebarFooter: AppCard(
        padding: const EdgeInsets.all(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth < 96) {
              return const Center(child: Icon(AppLucideIcons.sparkles));
            }
            return const Row(
              children: [
                Icon(AppLucideIcons.sparkles),
                SizedBox(width: 10),
                Expanded(child: AppText.muted('基于 shadcn_flutter 0.0.53 构建')),
              ],
            );
          },
        ),
      ),
      child: AppScaffold(child: selected.builder(context)),
    );
  }
}

IconData _groupIcon(String group) => switch (group) {
  '概览' => AppLucideIcons.layoutDashboard,
  '场景示例' => AppLucideIcons.monitor,
  '操作' => AppLucideIcons.mousePointerClick,
  '表单' => AppLucideIcons.listChecks,
  '展示' => AppLucideIcons.chartNoAxesColumn,
  '反馈' => AppLucideIcons.messageSquareWarning,
  '布局' => AppLucideIcons.panelsTopLeft,
  '导航' => AppLucideIcons.route,
  '其它' => AppLucideIcons.ellipsis,
  _ => AppLucideIcons.component,
};

IconData _componentIcon(String id) => switch (id) {
  'dashboard' => AppLucideIcons.gauge,
  'devices' => AppLucideIcons.monitor,
  'app-button' => AppLucideIcons.mousePointerClick,
  'app-text-field' => AppLucideIcons.textCursorInput,
  'app-select' => AppLucideIcons.chevronsUpDown,
  'app-autocomplete' => AppLucideIcons.search,
  'app-combobox' => AppLucideIcons.listFilter,
  'app-region-picker' => AppLucideIcons.mapPinned,
  'app-transfer' => AppLucideIcons.arrowLeftRight,
  'app-file-picker' => AppLucideIcons.paperclip,
  'app-checkbox' => AppLucideIcons.squareCheck,
  'app-switch' => AppLucideIcons.toggleLeft,
  'app-radio' => AppLucideIcons.circleDot,
  'app-slider' => AppLucideIcons.slidersHorizontal,
  'app-textarea' => AppLucideIcons.alignLeft,
  'app-otp' => AppLucideIcons.hash,
  'app-phone' => AppLucideIcons.phone,
  'app-chip-input' => AppLucideIcons.tags,
  'app-star-rating' => AppLucideIcons.star,
  'app-number-input' => AppLucideIcons.binary,
  'app-date-time' => AppLucideIcons.calendar,
  'app-formatted-input' => AppLucideIcons.textCursorInput,
  'app-color-input' => AppLucideIcons.pipette,
  'app-multiple-choice' => AppLucideIcons.layoutGrid,
  'app-item-picker' => AppLucideIcons.listChecks,
  'app-sortable-input' => AppLucideIcons.listOrdered,
  'app-object-input' => AppLucideIcons.braces,
  'app-empty' => AppLucideIcons.inbox,
  'app-item' => AppLucideIcons.list,
  'app-descriptions' => AppLucideIcons.tableProperties,
  'app-result' => AppLucideIcons.circleCheck,
  'app-avatar' => AppLucideIcons.userRound,
  'app-badge' => AppLucideIcons.tag,
  'app-chip' => AppLucideIcons.tag,
  'app-progress' => AppLucideIcons.loader,
  'app-number-ticker' => AppLucideIcons.hash,
  'app-code-snippet' => AppLucideIcons.code,
  'app-calendar' => AppLucideIcons.calendarDays,
  'app-skeleton' => AppLucideIcons.squareDashed,
  'app-dot-indicator' => AppLucideIcons.ellipsis,
  'app-keyboard-display' => AppLucideIcons.keyboard,
  'app-tracker' => AppLucideIcons.activity,
  'app-overflow' => AppLucideIcons.moveHorizontal,
  'app-selectable-text' => AppLucideIcons.textSelect,
  'app-scrollbar-view' => AppLucideIcons.scrollText,
  'app-async-view' => AppLucideIcons.refreshCw,
  'app-chat' => AppLucideIcons.messagesSquare,
  'app-dialog' => AppLucideIcons.messageSquare,
  'app-form-dialog' => AppLucideIcons.filePenLine,
  'app-drawer' => AppLucideIcons.panelRight,
  'app-sheet' => AppLucideIcons.panelBottom,
  'app-popover' => AppLucideIcons.messageCircle,
  'app-hover-card' => AppLucideIcons.squareMousePointer,
  'app-tooltip' => AppLucideIcons.circleHelp,
  'app-anchored-overlay' => AppLucideIcons.layers,
  'app-toast' => AppLucideIcons.bell,
  'app-refresh' => AppLucideIcons.refreshCcw,
  'app-swiper' => AppLucideIcons.panelLeft,
  'app-aspect-ratio' => AppLucideIcons.ratio,
  'app-card' => AppLucideIcons.square,
  'app-alert' => AppLucideIcons.triangleAlert,
  'app-accordion' => AppLucideIcons.chevronsDownUp,
  'app-collapsible' => AppLucideIcons.foldVertical,
  'app-divider' => AppLucideIcons.minus,
  'app-steps' => AppLucideIcons.listOrdered,
  'app-timeline' => AppLucideIcons.gitCommitHorizontal,
  'app-carousel' => AppLucideIcons.galleryHorizontal,
  'app-resizable' => AppLucideIcons.columns2,
  'app-stepper' => AppLucideIcons.listTodo,
  'app-tree' => AppLucideIcons.folderTree,
  'app-expandable-grid' => AppLucideIcons.layoutGrid,
  'app-table' => AppLucideIcons.table,
  'app-pinned-sheet' => AppLucideIcons.pin,
  'app-window' => AppLucideIcons.appWindow,
  'app-breadcrumb' => AppLucideIcons.cornerDownRight,
  'app-pagination' => AppLucideIcons.ellipsis,
  'app-tabs' => AppLucideIcons.folder,
  'app-tab-list' => AppLucideIcons.rows3,
  'app-switcher' => AppLucideIcons.panelsTopLeft,
  'app-navigation-bar' => AppLucideIcons.panelBottom,
  'app-menubar' => AppLucideIcons.menu,
  'app-navigation-menu' => AppLucideIcons.navigation,
  'app-dropdown' => AppLucideIcons.chevronDown,
  'app-context-menu' => AppLucideIcons.mousePointerClick,
  'app-command' => AppLucideIcons.terminal,
  'app-text' => AppLucideIcons.type,
  'data-grid' => AppLucideIcons.tableProperties,
  'charts' => AppLucideIcons.chartColumn,
  'motion' => AppLucideIcons.sparkles,
  _ => AppLucideIcons.component,
};

String _presetLabel(AppThemePreset preset) => switch (preset) {
  AppThemePreset.standard => '默认',
  AppThemePreset.apple => 'Apple 风格',
  AppThemePreset.fluent => 'Fluent 风格',
  AppThemePreset.material => 'Material 风格',
};
