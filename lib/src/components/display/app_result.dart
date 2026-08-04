import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_empty.dart';

enum AppResultStatus { success, info, warning, error, forbidden, notFound }

/// A terminal operation or page-level result state.
class AppResult extends StatelessWidget {
  const AppResult({
    super.key,
    required this.status,
    required this.title,
    this.description,
    this.actions,
    this.icon,
    this.padding = const EdgeInsets.all(32),
  });

  final AppResultStatus status;
  final Widget title;
  final Widget? description;
  final Widget? actions;
  final Widget? icon;
  final EdgeInsetsGeometry padding;

  IconData get _icon => switch (status) {
    AppResultStatus.success => shad.LucideIcons.circleCheckBig,
    AppResultStatus.info => shad.LucideIcons.info,
    AppResultStatus.warning => shad.LucideIcons.triangleAlert,
    AppResultStatus.error => shad.LucideIcons.circleX,
    AppResultStatus.forbidden => shad.LucideIcons.shieldX,
    AppResultStatus.notFound => shad.LucideIcons.fileQuestion,
  };

  Color _color(shad.ThemeData theme) => switch (status) {
    AppResultStatus.success => const Color(0xff16a34a),
    AppResultStatus.info => theme.colorScheme.primary,
    AppResultStatus.warning => const Color(0xffd97706),
    AppResultStatus.error => theme.colorScheme.destructive,
    AppResultStatus.forbidden => theme.colorScheme.destructive,
    AppResultStatus.notFound => theme.colorScheme.mutedForeground,
  };

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return AppEmpty(
      icon: icon ?? Icon(_icon),
      iconColor: _color(theme),
      iconSize: 44,
      title: title,
      description: description,
      action: actions,
      padding: padding,
    );
  }
}
