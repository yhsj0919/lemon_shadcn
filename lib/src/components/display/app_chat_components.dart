import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

typedef AppChatBubbleType = shad.ChatBubbleType;
typedef AppSharpCornerChatBubbleType = shad.SharpCornerChatBubbleType;
typedef AppPlainChatBubbleType = shad.PlainChatBubbleType;
typedef AppTailChatBubbleType = shad.TailChatBubbleType;
typedef AppChatBubbleCorner = shad.ChatBubbleCorner;
typedef AppChatBubbleCornerDirectional = shad.ChatBubbleCornerDirectional;
typedef AppChatConstrainedBox = shad.ChatConstrainedBox;

class AppChat extends StatelessWidget {
  const AppChat({
    super.key,
    required this.children,
    this.avatarPrefix,
    this.avatarSuffix,
    this.alignment,
    this.color,
    this.type,
    this.borderRadius,
    this.padding,
    this.border,
    this.spacing,
    this.avatarAlignment,
    this.avatarSpacing,
  });

  final List<Widget> children;
  final Widget? avatarPrefix;
  final Widget? avatarSuffix;
  final shad.AxisAlignmentGeometry? alignment;
  final Color? color;
  final shad.ChatBubbleType? type;
  final BorderRadiusGeometry? borderRadius;
  final EdgeInsetsGeometry? padding;
  final BorderSide? border;
  final double? spacing;
  final shad.AxisAlignmentGeometry? avatarAlignment;
  final double? avatarSpacing;

  @override
  Widget build(BuildContext context) {
    return shad.ChatGroup(
      avatarPrefix: avatarPrefix,
      avatarSuffix: avatarSuffix,
      alignment: alignment,
      color: color,
      type: type,
      borderRadius: borderRadius,
      padding: padding,
      border: border,
      spacing: spacing,
      avatarAlignment: avatarAlignment,
      avatarSpacing: avatarSpacing,
      children: children,
    );
  }
}

class AppChatBubble extends StatelessWidget {
  const AppChatBubble({
    super.key,
    required this.child,
    this.type,
    this.color,
    this.alignment,
    this.border,
    this.padding,
    this.borderRadius,
    this.widthFactor,
  });

  final Widget child;
  final shad.ChatBubbleType? type;
  final Color? color;
  final shad.AxisAlignmentGeometry? alignment;
  final BorderSide? border;
  final EdgeInsetsGeometry? padding;
  final BorderRadiusGeometry? borderRadius;
  final double? widthFactor;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final chatTheme = shad.ComponentTheme.maybeOf<shad.ChatTheme>(context);
    final inheritedColor = chatTheme?.color;
    final background = color ?? inheritedColor ?? theme.colorScheme.primary;
    final foreground = color == null && inheritedColor == null
        ? theme.colorScheme.primaryForeground
        : background.computeLuminance() < 0.45
        ? const Color(0xFFFFFFFF)
        : const Color(0xFF111111);

    return shad.ChatBubble(
      type: type,
      color: color,
      alignment: alignment,
      border: border,
      padding: padding,
      borderRadius: borderRadius,
      widthFactor: widthFactor,
      child: DefaultTextStyle.merge(
        style: TextStyle(color: foreground),
        child: child,
      ),
    );
  }
}

typedef AppPinnedSheet = shad.PinnedSheet;
typedef AppPinnedSheetController = shad.SheetController;
typedef AppPinnedSheetStage = shad.SheetStage;
typedef AppClosedSheetStage = shad.ClosedSheetStage;
typedef AppExpandedSheetStage = shad.ExpandedSheetStage;
typedef AppFixedSheetStage = shad.FixedSheetStage;
typedef AppFractionSheetStage = shad.FractionSheetStage;
typedef AppPeekDragHandleSheetStage = shad.PeekDragHandleSheetStage;
