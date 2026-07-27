import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

typedef AppAlertDialog = shad.AlertDialog;
typedef AppHoverCard = shad.HoverCard;
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

abstract final class AppOverlay {
  static Future<void> close<T>(BuildContext context, [T? value]) =>
      shad.closeOverlay<T>(context, value);
}

abstract final class AppDialog {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    bool fullScreen = false,
    AlignmentGeometry? alignment,
  }) {
    return shad.DialogConfiguration<T>(
      builder: builder,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      fullScreen: fullScreen,
      alignment: alignment,
    ).show(context);
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
    BoxConstraints? constraints,
  }) {
    return shad.DrawerConfiguration<T>(
      builder: builder,
      position: position,
      draggable: draggable,
      expands: expands,
      barrierDismissible: barrierDismissible,
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
    BoxConstraints? constraints,
  }) {
    return shad.SheetConfiguration<T>(
      builder: builder,
      position: position,
      draggable: draggable,
      barrierDismissible: barrierDismissible,
      constraints: constraints,
    ).show(context);
  }
}

abstract final class AppPopover {
  static shad.OverlayCompleter<T?> show<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    AlignmentGeometry alignment = Alignment.bottomCenter,
    AlignmentGeometry? anchorAlignment,
    Offset? offset,
    bool modal = true,
    bool barrierDismissible = true,
  }) {
    return shad.PopoverConfiguration<T>(
      builder: builder,
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
        child: Padding(
          padding: const EdgeInsets.all(16),
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
      builder: builder,
      location: location,
      dismissible: dismissible,
      showDuration: showDuration,
    );
  }
}
