import 'package:flutter/material.dart' as material;
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
      themeMode: material.ThemeMode.system,
      builder: AppShadcnScope.builder(config: AppThemeConfig.preset(_preset)),
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
    final selected = GalleryRegistry.categories[_selectedIndex];
    return AppScaffold(
      headers: [
        AppAppBar(
          title: const Text('Lemon Shadcn'),
          trailing: [
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
        ),
      ],
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 220,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Components').small().semiBold(),
                    const Gap(12),
                    for (
                      var index = 0;
                      index < GalleryRegistry.categories.length;
                      index++
                    )
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: index == _selectedIndex
                            ? AppButton.secondary(
                                onPressed: () =>
                                    setState(() => _selectedIndex = index),
                                child: Text(
                                  GalleryRegistry.categories[index].label,
                                ),
                              )
                            : AppButton.ghost(
                                onPressed: () =>
                                    setState(() => _selectedIndex = index),
                                child: Text(
                                  GalleryRegistry.categories[index].label,
                                ),
                              ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(child: selected.builder(context)),
        ],
      ),
    );
  }
}

String _presetLabel(AppThemePreset preset) => switch (preset) {
  AppThemePreset.standard => 'Default',
  AppThemePreset.apple => 'Apple inspired',
  AppThemePreset.fluent => 'Fluent inspired',
  AppThemePreset.material => 'Material inspired',
};
