import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../../foundation/app_overlay_style.dart';

// Keep these public surfaces as aliases so constructor and behavior changes in
// shadcn_flutter remain visible during upgrades instead of being copied here.
class AppMenubar extends StatelessWidget {
  const AppMenubar({
    super.key,
    required this.children,
    this.popoverOffset,
    this.border = true,
  });

  final List<shad.MenuItem> children;
  final Offset? popoverOffset;
  final bool border;

  @override
  Widget build(BuildContext context) {
    return shad.Menubar(
      popoverOffset: popoverOffset,
      border: border,
      children: children,
    );
  }
}

typedef AppNavigationMenuContent = shad.NavigationMenuContent;

class AppNavigationMenuContentList extends StatelessWidget {
  const AppNavigationMenuContentList({
    super.key,
    required this.children,
    this.crossAxisCount = 3,
    this.spacing,
    this.runSpacing,
    this.reverse = false,
  });

  final List<Widget> children;
  final int crossAxisCount;
  final double? spacing;
  final double? runSpacing;
  final bool reverse;

  @override
  Widget build(BuildContext context) {
    final scaling = shad.Theme.of(context).scaling;
    final defaultGap = 4 * scaling;
    return shad.NavigationMenuContentList(
      crossAxisCount: crossAxisCount,
      spacing: spacing ?? defaultGap,
      runSpacing: runSpacing ?? defaultGap,
      reverse: reverse,
      children: children,
    );
  }
}

class AppNavigationMenu extends StatefulWidget {
  const AppNavigationMenu({
    super.key,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.contentPadding,
    required this.children,
  });

  final double? surfaceOpacity;
  final double? surfaceBlur;
  final EdgeInsetsGeometry? contentPadding;
  final List<Widget> children;

  @override
  State<AppNavigationMenu> createState() => _AppNavigationMenuState();
}

class _AppNavigationMenuState extends State<AppNavigationMenu> {
  static const _closeDelay = Duration(milliseconds: 200);
  final _overlayController = shad.OverlayController();
  AppNavigationMenuItemState? _activeItem;
  int _hoverVersion = 0;

  bool isActive(AppNavigationMenuItemState item) =>
      _activeItem == item && _overlayController.hasOpenOverlay;

  void openItem(AppNavigationMenuItemState item) {
    if (item.widget.content == null) {
      close();
      return;
    }
    _activeItem = item;
    if (_overlayController.hasOpenOverlay) _overlayController.close();
    final theme = shad.Theme.of(item.context);
    final gap = theme.density.baseGap * theme.scaling;
    final compTheme = shad.ComponentTheme.maybeOf<shad.NavigationMenuTheme>(
      item.context,
    );
    _overlayController.show(
      item.context,
      shad.PopoverConfiguration<void>(
        alignment: Alignment.topCenter,
        offset: compTheme?.offset ?? Offset(0, gap * 0.5),
        modal: false,
        allowInvertHorizontal: false,
        allowInvertVertical: false,
        builder: _buildPopover,
      ),
    );
    setState(() {});
  }

  Widget _buildPopover(BuildContext context) {
    final theme = shad.Theme.of(context);
    final contentPadding =
        widget.contentPadding ??
        EdgeInsets.all(theme.density.baseContentPadding * theme.scaling * 0.25);
    final compTheme = shad.ComponentTheme.maybeOf<shad.NavigationMenuTheme>(
      context,
    );
    final item = _activeItem;
    if (item == null || item.widget.content == null) {
      return const SizedBox.shrink();
    }
    return MouseRegion(
      onEnter: (_) => _hoverVersion++,
      onExit: (_) => _scheduleClose(),
      child: AppOverlayShadow(
        child: shad.OutlinedContainer(
          clipBehavior: Clip.antiAlias,
          borderRadius: theme.borderRadiusMd,
          surfaceOpacity: widget.surfaceOpacity ?? compTheme?.surfaceOpacity,
          surfaceBlur: widget.surfaceBlur ?? compTheme?.surfaceBlur,
          padding: contentPadding,
          child: item.widget.content!,
        ),
      ),
    );
  }

  void _scheduleClose() {
    final version = ++_hoverVersion;
    Future.delayed(_closeDelay, () {
      if (mounted && version == _hoverVersion) close();
    });
  }

  void close() {
    _activeItem = null;
    _overlayController.close();
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _hoverVersion++,
      onExit: (_) => _scheduleClose(),
      child: shad.Data<_AppNavigationMenuState>.inherit(
        data: this,
        child: Row(mainAxisSize: MainAxisSize.min, children: widget.children),
      ),
    );
  }
}

class AppNavigationMenuItem extends StatefulWidget {
  const AppNavigationMenuItem({
    super.key,
    this.onPressed,
    this.content,
    required this.child,
  });

  final VoidCallback? onPressed;
  final Widget? content;
  final Widget child;

  @override
  State<AppNavigationMenuItem> createState() => AppNavigationMenuItemState();
}

class AppNavigationMenuItemState extends State<AppNavigationMenuItem> {
  @override
  Widget build(BuildContext context) {
    final menu = shad.Data.of<_AppNavigationMenuState>(context);
    final theme = shad.Theme.of(context);
    return AnimatedBuilder(
      animation: menu._overlayController,
      builder: (context, child) => shad.Button(
        style: const shad.ButtonStyle.ghost().copyWith(
          decoration: (context, states, value) => menu.isActive(this)
              ? (value as BoxDecoration).copyWith(
                  borderRadius: BorderRadius.circular(theme.radiusMd),
                  color: theme.colorScheme.muted.scaleAlpha(0.8),
                )
              : value,
        ),
        trailing: widget.content == null
            ? null
            : AnimatedRotation(
                duration: const Duration(milliseconds: 150),
                turns: menu.isActive(this) ? 0.5 : 0,
                child: const shad.Icon(
                  shad.RadixIcons.chevronDown,
                ).iconXSmall(),
              ),
        onHover: (hovered) {
          if (hovered) menu.openItem(this);
        },
        onPressed: widget.onPressed != null || widget.content != null
            ? () {
                widget.onPressed?.call();
                if (widget.content != null) menu.openItem(this);
              }
            : null,
        child: widget.child,
      ),
    );
  }
}

typedef AppMenuItem = shad.MenuItem;
typedef AppMenuLabel = shad.MenuLabel;
typedef AppMenuDivider = shad.MenuDivider;
typedef AppMenuGap = shad.MenuGap;
typedef AppMenuCheckbox = shad.MenuCheckbox;
typedef AppMenuRadio<T> = shad.MenuRadio<T>;
typedef AppMenuRadioGroup<T> = shad.MenuRadioGroup<T>;
typedef AppMenuShortcut = shad.MenuShortcut;

class AppMenuPopup extends StatelessWidget {
  const AppMenuPopup({
    super.key,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.padding,
    this.fillColor,
    this.borderColor,
    this.borderRadius,
    required this.children,
  });

  final double? surfaceOpacity;
  final double? surfaceBlur;
  final EdgeInsetsGeometry? padding;
  final Color? fillColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppButtonMotionScope.disable(
      child: AppOverlayShadow(
        borderRadius: borderRadius ?? shad.Theme.of(context).borderRadiusMd,
        child: shad.MenuPopup(
          surfaceOpacity: surfaceOpacity,
          surfaceBlur: surfaceBlur,
          padding: padding,
          fillColor: fillColor,
          borderColor: borderColor,
          borderRadius: borderRadius,
          children: children,
        ),
      ),
    );
  }
}

class AppMenuButton extends shad.MenuButton {
  const AppMenuButton({
    super.key,
    required super.child,
    super.subMenu,
    super.onPressed,
    super.trailing,
    super.leading,
    super.enabled = true,
    super.focusNode,
    super.autoClose = true,
    super.overlayController,
  });

  @override
  State<AppMenuButton> createState() => _AppMenuButtonState();
}

class _AppMenuButtonState extends State<AppMenuButton> {
  final ValueNotifier<List<shad.MenuItem>> _children = ValueNotifier([]);

  @override
  void initState() {
    super.initState();
    _children.value = widget.subMenu ?? [];
  }

  @override
  void didUpdateWidget(covariant AppMenuButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.subMenu, oldWidget.subMenu)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _children.value = widget.subMenu ?? [];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final menuBarData = shad.Data.maybeOf<shad.MenubarState>(context);
    final menuData = shad.Data.maybeOf<shad.MenuData>(context);
    final menuGroupData = shad.Data.maybeOf<shad.MenuGroupData>(context);
    assert(menuGroupData != null, 'AppMenuButton must be a child of MenuGroup');
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final compTheme = shad.ComponentTheme.maybeOf<shad.MenuTheme>(context);
    final isSheetOverlay = shad.SheetOverlayHandler.isSheetOverlay(context);
    final isDialogOverlay = shad.DialogOverlayHandler.isDialogOverlay(context);
    final isIndependentOverlay = isSheetOverlay || isDialogOverlay;

    void openSubMenu(BuildContext context, bool autofocus) {
      menuGroupData!.closeOthers();
      final overlayManager = shad.OverlayManager.of(context);
      menuData!.overlayController.show(
        context,
        shad.PopoverConfiguration(
          regionGroupId: menuGroupData.regionGroupId,
          consumeOutsideTaps: false,
          dismissBackdropFocus: false,
          modal: true,
          handler: shad.MenuOverlayHandler(overlayManager),
          overlayBarrier: shad.OverlayBarrier(
            borderRadius: BorderRadius.circular(theme.radiusMd),
          ),
          builder: (context) {
            final theme = shad.Theme.of(context);
            final scaling = theme.scaling;
            final densityGap = theme.density.baseGap * scaling;
            var itemPadding = menuGroupData.itemPadding;
            final isSheetOverlay = shad.SheetOverlayHandler.isSheetOverlay(
              context,
            );
            if (isSheetOverlay) {
              itemPadding = EdgeInsets.symmetric(horizontal: densityGap * 0.5);
            }
            return ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 192) * scaling,
              child: AnimatedBuilder(
                animation: _children,
                builder: (context, child) {
                  return shad.MenuGroup(
                    direction: menuGroupData.direction,
                    parent: menuGroupData,
                    onDismissed: menuGroupData.onDismissed,
                    regionGroupId: menuGroupData.regionGroupId,
                    subMenuOffset:
                        compTheme?.subMenuOffset ??
                        Offset(densityGap, -densityGap * 0.625),
                    itemPadding: itemPadding,
                    autofocus: autofocus,
                    builder: (context, children) {
                      return AppMenuPopup(children: children);
                    },
                    children: _children.value,
                  );
                },
              ),
            );
          },
          alignment: Alignment.topLeft,
          anchorAlignment: menuBarData != null
              ? Alignment.bottomLeft
              : Alignment.topRight,
          offset: menuGroupData.subMenuOffset ?? compTheme?.subMenuOffset,
        ),
        adaptive: false,
      );
    }

    return Actions(
      actions: {
        shad.OpenSubMenuIntent:
            shad.ContextCallbackAction<shad.OpenSubMenuIntent>(
              onInvoke: (intent, [context]) {
                if (widget.subMenu?.isNotEmpty ?? false) {
                  openSubMenu(this.context, true);
                  return true;
                }
                return false;
              },
            ),
        ActivateIntent: CallbackAction<ActivateIntent>(
          onInvoke: (intent) {
            widget.onPressed?.call(context);
            if (widget.subMenu?.isNotEmpty ?? false) {
              openSubMenu(context, true);
            }
            if (widget.autoClose) {
              menuGroupData!.closeAll();
            }
            return null;
          },
        ),
      },
      child: shad.SubFocus(
        enabled: widget.enabled,
        builder: (context, subFocusState) {
          final hasFocus = subFocusState.isFocused && menuBarData == null;
          return shad.Data<shad.MenuData>.boundary(
            child: shad.Data<shad.MenubarState>.boundary(
              child: TapRegion(
                groupId: menuGroupData!.root,
                child: AnimatedBuilder(
                  animation: menuData!.overlayController,
                  builder: (context, child) {
                    final theme = shad.Theme.of(context);
                    final densityGap = theme.density.baseGap * scaling;
                    return shad.Button(
                      disableFocusOutline: true,
                      alignment: menuGroupData.direction == Axis.vertical
                          ? AlignmentDirectional.centerStart
                          : Alignment.center,
                      style:
                          (menuBarData == null
                                  ? shad.ButtonVariance.menu
                                  : shad.ButtonVariance.menubar)
                              .copyWith(
                                padding: (context, states, value) {
                                  return value.optionallyResolve(context) +
                                      menuGroupData.itemPadding;
                                },
                                decoration: (context, states, value) {
                                  final theme = shad.Theme.of(context);
                                  return (value as BoxDecoration).copyWith(
                                    color:
                                        menuData
                                                .overlayController
                                                .hasOpenOverlay ||
                                            hasFocus
                                        ? theme.colorScheme.accent
                                        : null,
                                    borderRadius: BorderRadius.circular(
                                      theme.radiusMd,
                                    ),
                                  );
                                },
                              ),
                      trailing: menuBarData != null
                          ? widget.trailing
                          : widget.trailing != null ||
                                (widget.subMenu != null && menuBarData == null)
                          ? Row(
                              children: [
                                if (widget.trailing != null) widget.trailing!,
                                if (widget.trailing != null &&
                                    widget.subMenu != null)
                                  SizedBox(width: densityGap),
                                if (widget.subMenu != null &&
                                    menuBarData == null)
                                  const shad.Icon(
                                    shad.RadixIcons.chevronRight,
                                  ).iconSmall(),
                              ],
                            )
                          : null,
                      leading:
                          widget.leading == null &&
                              menuGroupData.hasLeading &&
                              menuBarData == null
                          ? SizedBox(width: densityGap * 2)
                          : widget.leading == null
                          ? null
                          : SizedBox(
                              width: densityGap * 2,
                              height: densityGap * 2,
                              child: widget.leading!.iconSmall(),
                            ),
                      disableTransition: true,
                      enabled: widget.enabled,
                      focusNode: widget.focusNode,
                      onHover: (value) {
                        if (value) {
                          subFocusState.requestFocus();
                          if ((menuBarData == null ||
                                  menuGroupData.hasOpenOverlays) &&
                              widget.subMenu != null &&
                              widget.subMenu!.isNotEmpty) {
                            if (!menuData.overlayController.hasOpenOverlay &&
                                !isIndependentOverlay) {
                              openSubMenu(context, false);
                            }
                          } else {
                            menuGroupData.closeOthers();
                          }
                        } else {
                          subFocusState.unfocus();
                        }
                      },
                      onPressed: () {
                        widget.onPressed?.call(context);
                        if (widget.subMenu != null &&
                            widget.subMenu!.isNotEmpty) {
                          if (!menuData.overlayController.hasOpenOverlay) {
                            openSubMenu(context, false);
                          }
                        } else {
                          if (widget.autoClose) {
                            menuGroupData.closeAll();
                          }
                        }
                      },
                      child: widget.child,
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class AppDropdownMenu extends StatelessWidget {
  const AppDropdownMenu({
    super.key,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.direction = Axis.vertical,
    required this.children,
  });

  final double? surfaceOpacity;
  final double? surfaceBlur;
  final Axis direction;
  final List<shad.MenuItem> children;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final densityGap = theme.density.baseGap * theme.scaling;
    final densityContentPadding =
        theme.density.baseContentPadding * theme.scaling;
    final isSheetOverlay = shad.SheetOverlayHandler.isSheetOverlay(context);
    final compTheme = shad.ComponentTheme.maybeOf<shad.DropdownMenuTheme>(
      context,
    );
    return ConstrainedBox(
      constraints: const BoxConstraints(minWidth: 192),
      child: shad.MenuGroup(
        regionGroupId: shad.Data.maybeOf<shad.DropdownMenuData>(context)?.key,
        subMenuOffset: Offset(densityGap, -densityGap * 0.5),
        itemPadding: isSheetOverlay
            ? EdgeInsets.symmetric(horizontal: densityContentPadding * 0.5)
            : EdgeInsets.zero,
        onDismissed: () {
          shad.closeOverlay(context);
        },
        direction: direction,
        builder: (context, children) {
          return AppMenuPopup(
            surfaceOpacity: surfaceOpacity ?? compTheme?.surfaceOpacity,
            surfaceBlur: surfaceBlur ?? compTheme?.surfaceBlur,
            children: children,
          );
        },
        children: children,
      ),
    );
  }
}

/// Anchors an [AppDropdownMenu] to an arbitrary widget.
///
/// Use this for compact triggers such as table header icons. It keeps popup
/// positioning and the menu surface in the same implementation used by the
/// rest of the component library.
class AppMenuAnchor extends StatelessWidget {
  const AppMenuAnchor({
    super.key,
    required this.child,
    required this.items,
    this.enabled = true,
    this.alignment = Alignment.topRight,
    this.anchorAlignment = Alignment.bottomRight,
    this.offset,
    this.allowInvertVertical = false,
  });

  final Widget child;
  final List<shad.MenuItem> items;
  final bool enabled;
  final AlignmentGeometry alignment;
  final AlignmentGeometry anchorAlignment;
  final Offset? offset;
  final bool allowInvertVertical;

  @override
  Widget build(BuildContext context) {
    void open() {
      if (!enabled || items.isEmpty) return;
      shad.PopoverConfiguration<void>(
        alignment: alignment,
        anchorAlignment: anchorAlignment,
        offset: offset,
        allowInvertVertical: allowInvertVertical,
        builder: (context) => AppDropdownMenu(children: items),
      ).show(context);
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: enabled ? open : null,
      // Keep header drag/sort gestures outside a compact menu trigger.
      onHorizontalDragStart: enabled ? (_) {} : null,
      onHorizontalDragUpdate: enabled ? (_) {} : null,
      onHorizontalDragEnd: enabled ? (_) {} : null,
      child: IgnorePointer(child: child),
    );
  }
}

class AppContextMenu extends StatefulWidget {
  const AppContextMenu({
    super.key,
    required this.child,
    required this.items,
    this.behavior = HitTestBehavior.translucent,
    this.direction = Axis.vertical,
    this.enabled = true,
  });

  final Widget child;
  final List<shad.MenuItem> items;
  final HitTestBehavior behavior;
  final Axis direction;
  final bool enabled;

  @override
  State<AppContextMenu> createState() => _AppContextMenuState();
}

class _AppContextMenuState extends State<AppContextMenu> {
  final _overlayController = shad.OverlayController();

  @override
  void dispose() {
    _overlayController.dispose();
    super.dispose();
  }

  void _show(Offset position) {
    final theme = shad.Theme.of(context);
    _overlayController.show(
      context,
      shad.PopoverConfiguration<void>(
        position: position + const Offset(8, 0),
        alignment: Alignment.topLeft,
        anchorAlignment: Alignment.topRight,
        follow: false,
        modal: true,
        consumeOutsideTaps: false,
        dismissBackdropFocus: false,
        overlayBarrier: shad.OverlayBarrier(
          borderRadius: BorderRadius.circular(theme.radiusMd),
          barrierColor: const Color(0xB2000000),
        ),
        builder: (context) => AppDropdownMenu(
          direction: widget.direction,
          children: widget.items,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final platform = shad.Theme.of(context).platform;
    final enableLongPress =
        platform == TargetPlatform.iOS ||
        platform == TargetPlatform.android ||
        platform == TargetPlatform.fuchsia;
    return GestureDetector(
      behavior: widget.behavior,
      onSecondaryTapDown: widget.enabled
          ? (details) => _show(details.globalPosition)
          : null,
      onLongPressStart: widget.enabled && enableLongPress
          ? (details) => _show(details.globalPosition)
          : null,
      child: widget.child,
    );
  }
}

class AppContextMenuPopup extends StatelessWidget {
  const AppContextMenuPopup({
    super.key,
    required this.anchorContext,
    required this.position,
    required this.children,
    this.themes,
    this.direction = Axis.vertical,
    this.onTickFollow,
    this.anchorSize,
  });

  final BuildContext anchorContext;
  final Offset position;
  final List<shad.MenuItem> children;
  final CapturedThemes? themes;
  final Axis direction;
  final ValueChanged<shad.PopoverOverlayWidgetState>? onTickFollow;
  final Size? anchorSize;

  @override
  Widget build(BuildContext context) {
    return shad.PopoverOverlayWidget(
      anchor: shad.ContextAnchor(anchorContext),
      position: position,
      anchorSize: anchorSize,
      alignment: Alignment.topLeft,
      anchorAlignment: Alignment.topRight,
      themes: themes,
      follow: onTickFollow != null,
      onTickFollow: onTickFollow,
      animation: const AlwaysStoppedAnimation(1),
      builder: (context) =>
          AppDropdownMenu(direction: direction, children: children),
    );
  }
}

/// A command palette that always receives a finite, full-width layout.
///
/// The upstream command's internal paint-order flex requires a tight width
/// during pointer hit testing. In a start-aligned [Column] the raw widget can
/// otherwise shrink-wrap, which may leave its sorted child list inconsistent
/// while search results update.
class AppCommand extends StatelessWidget {
  const AppCommand({
    super.key,
    required this.builder,
    this.autofocus = true,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.emptyBuilder,
    this.errorBuilder,
    this.loadingBuilder,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.searchHintText,
    this.height = 280,
  });

  final shad.CommandBuilder builder;
  final bool autofocus;
  final Duration debounceDuration;
  final WidgetBuilder? emptyBuilder;
  final shad.ErrorWidgetBuilder? errorBuilder;
  final WidgetBuilder? loadingBuilder;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final String? searchHintText;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: shad.ComponentTheme<shad.OutlinedContainerTheme>(
        data: const shad.OutlinedContainerTheme(borderWidth: 1),
        child: shad.Command(
          autofocus: autofocus,
          debounceDuration: debounceDuration,
          emptyBuilder: emptyBuilder,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          surfaceOpacity: surfaceOpacity,
          surfaceBlur: surfaceBlur,
          searchPlaceholder: searchHintText == null ? null : Text(searchHintText!),
          builder: builder,
        ),
      ),
    );
  }
}

typedef AppCommandCategory = shad.CommandCategory;
typedef AppCommandItem = shad.CommandItem;
typedef AppCommandEmpty = shad.CommandEmpty;
typedef AppCommandBuilder = shad.CommandBuilder;
