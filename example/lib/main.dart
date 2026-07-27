import 'package:flutter/material.dart' as material;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'gallery/gallery_registry.dart';

void main() => material.runApp(const ComponentGallery());

class ComponentGallery extends StatefulWidget {
  const ComponentGallery({super.key});

  @override
  State<ComponentGallery> createState() => _ComponentGalleryState();
}

class _ComponentGalleryState extends State<ComponentGallery> {
  var _preset = AppThemePreset.standard;

  @override
  Widget build(BuildContext context) {
    return material.MaterialApp(
      title: 'Lemon Shadcn',
      locale: const material.Locale('zh', 'CN'),
      supportedLocales: const [
        material.Locale('zh', 'CN'),
        material.Locale('en'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      themeMode: material.ThemeMode.system,
      builder: AppShadcnScope.builder(
        locale: const material.Locale('zh', 'CN'),
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

  @override
  Widget build(BuildContext context) {
    final selected = GalleryRegistry.entries[_selectedIndex];
    return AppShell(
      brandTitle: 'Lemon Shadcn',
      brandSubtitle: '管理端组件示例',
      destinations: [
        for (final group in GalleryRegistry.groups)
          AppNavDestination(
            id: 'group-${group.hashCode}',
            label: group,
            icon: _groupIcon(group),
            children: [
              for (final entry in GalleryRegistry.entries.where(
                (entry) => entry.group == group,
              ))
                AppNavDestination(
                  id: entry.id,
                  label: entry.label,
                  icon: _componentIcon(entry.id),
                ),
            ],
          ),
      ],
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
        material.DropdownButton<AppThemePreset>(
          key: const Key('theme-preset-picker'),
          value: widget.preset,
          underline: const SizedBox.shrink(),
          onChanged: (value) {
            if (value != null) widget.onPresetChanged(value);
          },
          items: [
            for (final preset in AppThemePreset.values)
              material.DropdownMenuItem(
                value: preset,
                child: Text(_presetLabel(preset)),
              ),
          ],
        ),
      ],
      sidebarFooter: const Card(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            children: [
              Icon(LucideIcons.sparkles),
              Gap(10),
              Expanded(child: AppText.muted('基于 shadcn_flutter 0.0.53 构建')),
            ],
          ),
        ),
      ),
      child: AppScaffold(child: selected.builder(context)),
    );
  }
}

IconData _groupIcon(String group) => switch (group) {
  '概览' => LucideIcons.layoutDashboard,
  'App 组件' => LucideIcons.component,
  '基础组件' => LucideIcons.blocks,
  '表单组件' => LucideIcons.listChecks,
  '反馈与展示' => LucideIcons.layoutPanelTop,
  '布局组件' => LucideIcons.panelsTopLeft,
  '导航组件' => LucideIcons.route,
  _ => LucideIcons.ellipsis,
};

IconData _componentIcon(String id) => switch (id) {
  'app-button' => LucideIcons.mousePointerClick,
  'app-text' => LucideIcons.type,
  'app-badge' => LucideIcons.tag,
  'dashboard' => LucideIcons.gauge,
  'form-basic' => LucideIcons.textCursorInput,
  'form-advanced' => LucideIcons.listChecks,
  'pickers' => LucideIcons.pipette,
  'date-time' => LucideIcons.calendar,
  'feedback' => LucideIcons.messageSquareWarning,
  'display' => LucideIcons.chartNoAxesColumn,
  'navigation' => LucideIcons.route,
  'navigation-chrome' => LucideIcons.panelLeft,
  'menus' => LucideIcons.menu,
  'layout' => LucideIcons.panelsTopLeft,
  'data-panel' => LucideIcons.tableProperties,
  'overlay' => LucideIcons.layers,
  'motion' => LucideIcons.sparkles,
  _ => LucideIcons.component,
};

String _presetLabel(AppThemePreset preset) => switch (preset) {
  AppThemePreset.standard => '默认',
  AppThemePreset.apple => 'Apple 风格',
  AppThemePreset.fluent => 'Fluent 风格',
  AppThemePreset.material => 'Material 风格',
};
