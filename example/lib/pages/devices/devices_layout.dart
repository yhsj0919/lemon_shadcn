import 'package:flutter/widgets.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

/// Demo-local split page body (from palsmon_saas AppPageBody.split).
class DevicesPageBody extends StatelessWidget {
  const DevicesPageBody.split({
    super.key,
    required this.list,
    required this.content,
    this.listWidth = 320,
    this.listPadding = EdgeInsets.zero,
    this.contentPadding = const EdgeInsets.fromLTRB(28, 24, 28, 24),
  });

  final Widget list;
  final Widget content;
  final double listWidth;
  final EdgeInsetsGeometry listPadding;
  final EdgeInsetsGeometry contentPadding;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return ColoredBox(
      color: colors.card,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: listWidth,
            child: ColoredBox(
              color: colors.card,
              child: Padding(padding: listPadding, child: list),
            ),
          ),
          ColoredBox(color: colors.border, child: const SizedBox(width: 1)),
          Expanded(
            child: ColoredBox(
              color: colors.card,
              child: Padding(
                padding: contentPadding,
                child: SizedBox.expand(child: content),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DevicesContentWidth extends StatelessWidget {
  const DevicesContentWidth({
    super.key,
    required this.child,
    this.maxWidth = 1200,
  });

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: SizedBox(width: double.infinity, child: child),
      ),
    );
  }
}

class DevicesDetailHeader extends StatelessWidget {
  const DevicesDetailHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.status,
    this.meta = const [],
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final Widget? status;
  final List<Widget> meta;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final hasMeta = status != null || meta.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h3(title),
                  if (subtitle != null && subtitle!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    AppText.muted(subtitle!),
                  ],
                ],
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(width: 12),
              Wrap(spacing: 8, runSpacing: 8, children: actions),
            ],
          ],
        ),
        if (hasMeta) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 16,
            runSpacing: 10,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [?status, ...meta],
          ),
        ],
      ],
    );
  }
}

class DevicesDetailHeaderMeta extends StatelessWidget {
  const DevicesDetailHeaderMeta({
    super.key,
    required this.icon,
    required this.text,
  });

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: colors.mutedForeground),
        const SizedBox(width: 6),
        AppText.caption(text),
      ],
    );
  }
}
