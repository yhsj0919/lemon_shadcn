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

typedef AppCommand = shad.Command;
typedef AppCommandCategory = shad.CommandCategory;
typedef AppCommandItem = shad.CommandItem;
typedef AppCommandEmpty = shad.CommandEmpty;
typedef AppCommandBuilder = shad.CommandBuilder;
