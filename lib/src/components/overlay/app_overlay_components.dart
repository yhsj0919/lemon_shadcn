import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_overlay_style.dart';

typedef AppTooltip = shad.Tooltip;
typedef AppInstantTooltip = shad.InstantTooltip;
typedef AppOverlayController = shad.OverlayController;
typedef AppOverlayCompleter<T> = shad.OverlayCompleter<T>;
typedef AppDialogConfiguration<T> = shad.DialogConfiguration<T>;
typedef AppDrawerConfiguration<T> = shad.DrawerConfiguration<T>;
typedef AppSheetConfiguration<T> = shad.SheetConfiguration<T>;
typedef AppPopoverConfiguration<T> = shad.PopoverConfiguration<T>;
typedef AppToastOverlay = shad.ToastOverlay;
typedef AppToastLocation = shad.ToastLocation;

class AppHoverCard extends StatelessWidget {
  const AppHoverCard({
    super.key,
    required this.child,
    required this.hoverBuilder,
    this.debounce,
    this.wait,
    this.popoverAlignment,
    this.anchorAlignment,
    this.popoverOffset,
    this.behavior,
    this.controller,
    this.handler,
  });

  final Widget child;
  final WidgetBuilder hoverBuilder;
  final Duration? debounce;
  final Duration? wait;
  final AlignmentGeometry? popoverAlignment;
  final AlignmentGeometry? anchorAlignment;
  final Offset? popoverOffset;
  final HitTestBehavior? behavior;
  final shad.OverlayController? controller;
  final shad.OverlayHandler? handler;

  @override
  Widget build(BuildContext context) {
    return shad.HoverCard(
      debounce: debounce,
      wait: wait,
      popoverAlignment: popoverAlignment,
      anchorAlignment: anchorAlignment,
      popoverOffset: popoverOffset,
      behavior: behavior,
      controller: controller,
      handler: handler,
      hoverBuilder: (context) =>
          AppOverlaySurfaceTheme(child: hoverBuilder(context)),
      child: child,
    );
  }
}

abstract final class AppOverlay {
  static Future<void> close<T>(BuildContext context, [T? value]) =>
      shad.closeOverlay<T>(context, value);
}

abstract final class AppDialog {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    Color? barrierColor,
    bool useRootNavigator = true,
    bool fullScreen = false,
    AlignmentGeometry? alignment,
  }) {
    return shad.DialogConfiguration<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor,
      useRootNavigator: useRootNavigator,
      fullScreen: fullScreen,
      alignment: alignment,
    ).show(context);
  }
}

/// A shadcn alert dialog with a softer application-level modal backdrop.
///
/// shadcn_flutter 0.0.53 hardcodes an 80% black barrier in [shad.AlertDialog]
/// when no color is supplied, so the ambient backdrop theme cannot override it.
class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    super.key,
    this.leading,
    this.title,
    this.content,
    this.actions,
    this.trailing,
    this.surfaceBlur,
    this.surfaceOpacity,
    this.barrierColor,
    this.padding,
  });

  final Widget? leading;
  final Widget? title;
  final Widget? content;
  final List<Widget>? actions;
  final Widget? trailing;
  final double? surfaceBlur;
  final double? surfaceOpacity;
  final Color? barrierColor;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return shad.AlertDialog(
      leading: leading,
      title: title,
      content: content,
      actions: actions,
      trailing: trailing,
      surfaceBlur: surfaceBlur,
      surfaceOpacity: surfaceOpacity,
      barrierColor: barrierColor ?? AppOverlayStyle.modalBarrier(context),
      padding: padding,
    );
  }
}

abstract final class AppDrawer {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    shad.OverlayPosition position = shad.OverlayPosition.bottom,
    bool draggable = true,
    bool expands = false,
    bool barrierDismissible = true,
    Color? barrierColor,
    BoxConstraints? constraints,
  }) {
    return shad.DrawerConfiguration<T>(
      builder: builder,
      position: position,
      draggable: draggable,
      expands: expands,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? AppOverlayStyle.modalBarrier(context),
      constraints: constraints,
    ).show(context);
  }
}

abstract final class AppSheet {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    shad.OverlayPosition position = shad.OverlayPosition.bottom,
    bool draggable = false,
    bool barrierDismissible = true,
    Color? barrierColor,
    BoxConstraints? constraints,
  }) {
    return shad.SheetConfiguration<T>(
      builder: builder,
      position: position,
      draggable: draggable,
      barrierDismissible: barrierDismissible,
      barrierColor: barrierColor ?? AppOverlayStyle.modalBarrier(context),
      constraints: constraints,
    ).show(context);
  }
}

abstract final class AppPopover {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    AlignmentGeometry alignment = AppOverlayStyle.popoverAlignment,
    AlignmentGeometry anchorAlignment =
        AppOverlayStyle.popoverAnchorAlignment,
    Offset offset = AppOverlayStyle.popoverOffset,
    bool modal = true,
    bool barrierDismissible = true,
  }) {
    return shad.PopoverConfiguration<T>(
      builder: (context) => AppOverlaySurfaceTheme(child: builder(context)),
      alignment: alignment,
      anchorAlignment: anchorAlignment,
      offset: offset,
      modal: modal,
      barrierDismissable: barrierDismissible,
    ).show(context);
  }
}

abstract final class AppToast {
  static shad.ToastOverlay show({
    required BuildContext context,
    required String title,
    String? message,
    shad.ToastLocation location = shad.ToastLocation.bottomRight,
    Duration showDuration = const Duration(seconds: 5),
  }) {
    return custom(
      context: context,
      location: location,
      showDuration: showDuration,
      builder: (context, overlay) => shad.Card(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title).semiBold(),
                  if (message != null) ...[
                    const shad.Gap(4),
                    Text(message).small().muted(),
                  ],
                ],
              ),
            ),
            const shad.Gap(12),
            shad.Button.ghost(
              onPressed: overlay.close,
              child: const Icon(shad.LucideIcons.x),
            ),
          ],
        ),
      ),
    );
  }

  static shad.ToastOverlay custom({
    required BuildContext context,
    required shad.ToastBuilder builder,
    shad.ToastLocation location = shad.ToastLocation.bottomRight,
    bool dismissible = true,
    Duration showDuration = const Duration(seconds: 5),
  }) {
    return shad.showToast(
      context: context,
      builder: (context, overlay) => AppOverlaySurfaceTheme(
        padding: AppOverlayStyle.toastPadding,
        child: builder(context, overlay),
      ),
      location: location,
      dismissible: dismissible,
      showDuration: showDuration,
    );
  }
}
