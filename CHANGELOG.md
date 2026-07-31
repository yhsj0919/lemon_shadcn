## Unreleased

* Stop re-exporting `shadcn_flutter` from `lemon_shadcn.dart` so Material pages
  can import App APIs without name clashes. Opt in via
  `package:lemon_shadcn/shadcn.dart` when upstream widgets or types are needed.
* Export icon font aliases (`AppLucideIcons`, `AppRadixIcons`,
  `AppBootstrapIcons`, `AppMaterialIcons`) from the default entry.
* Export design-theme aliases (`ShadcnTheme`, `AppThemeData`,
  `AppColorScheme`, `AppColorSchemes`, `AppThemeMode`, `AppComponentTheme`)
  so Material pages can read tokens without importing upstream.
* Add `AppTypography.system()` / `geist()` and default Lemon themes to system
  UI fonts (Windows: Microsoft YaHei UI). Marked `TODO(upstream)` until
  `shadcn_flutter` ships an equivalent default.
* Add `AppThemeConfig.standard(primary: …)` so brand accent avoids large
  `copyWith` on light/dark schemes.
* `AppShadcnScope` mirrors shadcn primary + sans `fontFamily` into Material
  `ThemeData` by default (`syncMaterialTheme`).
* Tighten `AppText` to an admin-compact scale, add section/helper/error/lead
  variants, and wire global `AppThemeConfig.textTheme`.
* Add `AppText.listItem` / `listSecondary` for nav and list rows; sidebar and
  Material `ListTileTheme` follow the same 14 / 12 scale.
* AppButton defaults to interactive motion; chrome (`AppIconButton`, sidebar,
  dropdown) passes `AppButtonConfig.plain` so they stay still. Opt out globally
  with `AppMotionTheme(interactive: false)` or per button with
  `config: AppButtonConfig.plain`.
* Drop `import … as material` across the package, example, and tests; use plain
  Material imports with App aliases (or `shadcn.dart as shad` when needed).
* Docs: default control height is 34 — examples no longer imply `height: 40`
  is required.

## 0.0.1

* Convert the generated plugin skeleton into a cross-platform component package.
* Add a MaterialApp-compatible `AppShadcnScope` without requiring `ShadcnApp`.
* Add the audited 84-component App-prefixed baseline for shadcn_flutter 0.0.53.
* Add native Form integration, formatted async option sources, shared async actions,
  categorized gallery pages, motion, dynamic shadows, theme tokens, and upgrade gates.
* Add the admin-oriented `AppShell`, semantic `AppText`, and anchored
  `AppDropdownButton` components.
* Add composable component-theme wrappers and built-in Chinese shadcn
  localizations.
* Redesign the example as an admin-style, grouped component gallery.
* Add link/text button variants, advanced star geometry, and compact
  navigation for narrow admin layouts.
* Register the merged admin components and add an interaction-tested dropdown
  trigger to the menu gallery.
* Add a dedicated Typography gallery page covering every semantic AppText role
  and local ComponentTheme overrides.
