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
            placeholder: '选择主题',
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
  'App 组件' => AppLucideIcons.component,
  '基础组件' => AppLucideIcons.blocks,
  '表单组件' => AppLucideIcons.listChecks,
  '反馈与展示' => AppLucideIcons.layoutPanelTop,
  '布局组件' => AppLucideIcons.panelsTopLeft,
  '导航组件' => AppLucideIcons.route,
  _ => AppLucideIcons.ellipsis,
};

IconData _componentIcon(String id) => switch (id) {
  'app-button' => AppLucideIcons.mousePointerClick,
  'app-text' => AppLucideIcons.type,
  'app-badge' => AppLucideIcons.tag,
  'dashboard' => AppLucideIcons.gauge,
  'devices' => AppLucideIcons.monitor,
  'form-basic' => AppLucideIcons.textCursorInput,
  'form-advanced' => AppLucideIcons.listChecks,
  'pickers' => AppLucideIcons.pipette,
  'date-time' => AppLucideIcons.calendar,
  'feedback' => AppLucideIcons.messageSquareWarning,
  'display' => AppLucideIcons.chartNoAxesColumn,
  'navigation' => AppLucideIcons.route,
  'navigation-chrome' => AppLucideIcons.panelLeft,
  'menus' => AppLucideIcons.menu,
  'layout' => AppLucideIcons.panelsTopLeft,
  'data-panel' => AppLucideIcons.tableProperties,
  'overlay' => AppLucideIcons.layers,
  'motion' => AppLucideIcons.sparkles,
  _ => AppLucideIcons.component,
};

String _presetLabel(AppThemePreset preset) => switch (preset) {
  AppThemePreset.standard => '默认',
  AppThemePreset.apple => 'Apple 风格',
  AppThemePreset.fluent => 'Fluent 风格',
  AppThemePreset.material => 'Material 风格',
};
