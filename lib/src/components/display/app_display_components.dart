import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_compact_label_style.dart';
import '../../foundation/app_interactive_style.dart';

typedef AppAvatar = shad.Avatar;
typedef AppAvatarBadge = shad.AvatarBadge;
typedef AppAvatarGroup = shad.AvatarGroup;
typedef AppCodeSnippet = shad.CodeSnippet;
typedef AppProgress = shad.Progress;
typedef AppCircularProgressIndicator = shad.CircularProgressIndicator;
typedef AppLinearProgressIndicator = shad.LinearProgressIndicator;
typedef AppNumberTicker = shad.NumberTicker;
typedef AppKeyboardDisplay = shad.KeyboardDisplay;
typedef AppKeyboardKeyDisplay = shad.KeyboardKeyDisplay;
typedef AppTracker = shad.Tracker;
typedef AppChipButton = shad.ChipButton;
typedef AppTrackerData = shad.TrackerData;

class AppChip extends StatelessWidget {
  const AppChip({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.style,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final shad.AbstractButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final compactStyle = AppCompactLabelStyle.apply(
      style ?? shad.ButtonVariance.secondary,
    );
    return shad.ComponentTheme<shad.ChipTheme>(
      data: const shad.ChipTheme(padding: AppCompactLabelStyle.padding),
      child: shad.Chip(
        leading: leading,
        trailing: trailing,
        onPressed: onPressed,
        style: onPressed == null
            ? compactStyle
            : AppInteractiveStyle.hover(compactStyle),
        child: child,
      ),
    );
  }
}
