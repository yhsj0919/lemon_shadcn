/// Opt-in re-export of upstream `shadcn_flutter`.
///
/// Prefer [lemon_shadcn.dart] for App-prefixed APIs. Import this library only
/// when you need upstream widgets or types (`Card`, `Gap`, `Theme`, …).
/// Icon fonts are on the default entry as `AppLucideIcons` / `AppRadixIcons` /
/// `AppBootstrapIcons` / `AppMaterialIcons`.
///
/// Do **not** import this library unprefixed alongside
/// `package:flutter/material.dart`: upstream replaces layout primitives
/// (`Row`, `Column`, `Expanded`, …) and shares many Material names. Prefer
/// Material-first pages without this import, or use
/// `import 'package:lemon_shadcn/shadcn.dart' as shad`.
library;

export 'package:shadcn_flutter/shadcn_flutter.dart';
