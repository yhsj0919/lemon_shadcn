import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.errorText,
    this.required = false,
  });

  final Widget child;
  final String? label;
  final String? description;
  final String? errorText;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
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
            ],
          ),
          const shad.Gap(6),
        ],
        child,
        if (errorText != null) ...[
          const shad.Gap(6),
          DefaultTextStyle.merge(
            style: TextStyle(
              color: shad.Theme.of(context).colorScheme.destructive,
            ),
            child: Text(errorText!).small(),
          ),
        ] else if (description != null) ...[
          const shad.Gap(6),
          Text(description!).small().muted(),
        ],
      ],
    );
  }
}
