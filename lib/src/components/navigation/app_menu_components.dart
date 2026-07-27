import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

// Keep these public surfaces as aliases so constructor and behavior changes in
// shadcn_flutter remain visible during upgrades instead of being copied here.
typedef AppMenubar = shad.Menubar;
typedef AppNavigationMenu = shad.NavigationMenu;
typedef AppNavigationMenuItem = shad.NavigationMenuItem;
typedef AppNavigationMenuContent = shad.NavigationMenuContent;
typedef AppNavigationMenuContentList = shad.NavigationMenuContentList;

typedef AppMenuItem = shad.MenuItem;
typedef AppMenuButton = shad.MenuButton;
typedef AppMenuLabel = shad.MenuLabel;
typedef AppMenuDivider = shad.MenuDivider;
typedef AppMenuGap = shad.MenuGap;
typedef AppMenuCheckbox = shad.MenuCheckbox;
typedef AppMenuRadio<T> = shad.MenuRadio<T>;
typedef AppMenuRadioGroup<T> = shad.MenuRadioGroup<T>;
typedef AppMenuShortcut = shad.MenuShortcut;

typedef AppDropdownMenu = shad.DropdownMenu;
typedef AppContextMenu = shad.ContextMenu;
typedef AppContextMenuPopup = shad.ContextMenuPopup;

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
    this.searchPlaceholder,
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
  final Widget? searchPlaceholder;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: shad.Command(
        autofocus: autofocus,
        debounceDuration: debounceDuration,
        emptyBuilder: emptyBuilder,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        surfaceOpacity: surfaceOpacity,
        surfaceBlur: surfaceBlur,
        searchPlaceholder: searchPlaceholder,
        builder: builder,
      ),
    );
  }
}

typedef AppCommandCategory = shad.CommandCategory;
typedef AppCommandItem = shad.CommandItem;
typedef AppCommandEmpty = shad.CommandEmpty;
typedef AppCommandBuilder = shad.CommandBuilder;
