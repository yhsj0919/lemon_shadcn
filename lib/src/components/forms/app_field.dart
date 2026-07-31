import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart' show Tooltip;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.errorText,
    this.required = false,
    this.width,
  });

  final Widget child;
  final String? label;
  final String? description;
  final String? errorText;
  final bool required;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final content = Column(
          crossAxisAlignment: constraints.hasBoundedWidth || width != null
              ? CrossAxisAlignment.stretch
              : CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (label != null) ...[
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label!).small().medium(),
                  if (required)
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        color: shad.Theme.of(context).colorScheme.destructive,
                      ),
                      child: const Text(' *').small(),
                    ),
                  if (errorText != null) const shad.Gap(8),
                  if (errorText != null)
                    Flexible(
                      child: Semantics(
                        liveRegion: true,
                        child: DefaultTextStyle.merge(
                          style: TextStyle(
                            color: shad.Theme.of(
                              context,
                            ).colorScheme.destructive,
                          ),
                          child: Text(
                            errorText!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ).small(),
                        ),
                      ),
                    ),
                ],
              ),
              const shad.Gap(6),
            ],
            if (label == null)
              _UnlabelledFieldControl(
                bounded: constraints.hasBoundedWidth || width != null,
                errorText: errorText,
                child: child,
              )
            else
              child,
            if (description != null) ...[
              const shad.Gap(6),
              Text(description!).small().muted(),
            ],
          ],
        );

        final targetWidth =
            width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        if (targetWidth == null) return content;
        return SizedBox(width: targetWidth, child: content);
      },
    );
  }
}

class _UnlabelledFieldControl extends StatelessWidget {
  const _UnlabelledFieldControl({
    required this.bounded,
    required this.errorText,
    required this.child,
  });

  final bool bounded;
  final String? errorText;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final control = bounded ? Expanded(child: child) : child;
    return Row(
      mainAxisSize: bounded ? MainAxisSize.max : MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        control,
        const shad.Gap(8),
        SizedBox(
          width: 20,
          child: errorText == null
              ? null
              : Semantics(
                  liveRegion: true,
                  label: errorText,
                  child: Tooltip(
                    message: errorText!,
                    child: Icon(
                      shad.LucideIcons.triangleAlert,
                      size: 16,
                      color: shad.Theme.of(context).colorScheme.destructive,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}
