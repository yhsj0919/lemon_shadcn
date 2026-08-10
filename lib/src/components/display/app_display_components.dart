import 'dart:async';

import 'package:flutter/material.dart' show SelectionArea;
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_compact_label_style.dart';
import '../../foundation/app_interactive_style.dart';

export 'app_avatar.dart';
export 'app_corner_badge.dart';

typedef AppAvatarBadge = shad.AvatarBadge;
typedef AppAvatarGroup = shad.AvatarGroup;
typedef AppProgress = shad.Progress;
typedef AppCircularProgressIndicator = shad.CircularProgressIndicator;
typedef AppLinearProgressIndicator = shad.LinearProgressIndicator;
typedef AppNumberTicker = shad.NumberTicker;
typedef AppKeyboardDisplay = shad.KeyboardDisplay;
typedef AppKeyboardKeyDisplay = shad.KeyboardKeyDisplay;
typedef AppTracker = shad.Tracker;
typedef AppChipButton = shad.ChipButton;
typedef AppTrackerData = shad.TrackerData;

/// Displays code with a built-in copy action.
///
/// Plain [Text] content is copied automatically. Supply [copyText] when
/// [code] is a rich or syntax-highlighted widget.
class AppCodeSnippet extends StatefulWidget {
  const AppCodeSnippet({
    super.key,
    required this.code,
    this.copyText,
    this.constraints,
    this.actions = const [],
    this.copyable = true,
    this.selectable = true,
  });

  final Widget code;
  final String? copyText;
  final BoxConstraints? constraints;
  final List<Widget> actions;
  final bool copyable;
  final bool selectable;

  @override
  State<AppCodeSnippet> createState() => _AppCodeSnippetState();
}

class _AppCodeSnippetState extends State<AppCodeSnippet> {
  Timer? _feedbackTimer;
  bool _copied = false;

  String? get _resolvedCopyText {
    final explicitText = widget.copyText;
    if (explicitText != null) return explicitText;
    final code = widget.code;
    return code is Text ? code.data : null;
  }

  Future<void> _copy() async {
    final text = _resolvedCopyText;
    if (text == null) return;
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    _feedbackTimer?.cancel();
    setState(() => _copied = true);
    _feedbackTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  void dispose() {
    _feedbackTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = _resolvedCopyText;
    final snippet = shad.CodeSnippet(
      code: widget.code,
      constraints: widget.constraints,
      actions: [
        ...widget.actions,
        if (widget.copyable && text != null)
          shad.GhostButton(
            density: shad.ButtonDensity.icon,
            onPressed: _copy,
            child: Icon(
              _copied ? shad.LucideIcons.copyCheck : shad.LucideIcons.copy,
              size: 16,
            ),
          ),
      ],
    );
    return widget.selectable ? SelectionArea(child: snippet) : snippet;
  }
}

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
    ).copyWith(
      mouseCursor: (context, states, current) =>
          onPressed == null ? SystemMouseCursors.basic : SystemMouseCursors.click,
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
