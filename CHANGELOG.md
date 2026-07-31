## Unreleased

* Stop re-exporting `shadcn_flutter` from `lemon_shadcn.dart` so Material pages
  can import App APIs without name clashes. Opt in via
  `package:lemon_shadcn/shadcn.dart` when upstream widgets or types are needed.
* Export icon font aliases (`AppLucideIcons`, `AppRadixIcons`,
  `AppBootstrapIcons`, `AppMaterialIcons`) from the default entry.
* Export design-theme aliases (`ShadcnTheme`, `AppThemeData`,
  `AppColorScheme`, `AppColorSchemes`, `AppThemeMode`, `AppTypography`,
  `AppComponentTheme`) so Material pages can read tokens without importing
  upstream.
* Drop `import … as material` across the package, example, and tests; use plain
  Material imports with App aliases (or `shadcn.dart as shad` when needed).

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
