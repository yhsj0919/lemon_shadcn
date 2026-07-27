import 'package:flutter/services.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class MenusPage extends StatelessWidget {
  const MenusPage({super.key});

  List<AppMenuItem> get _items => [
    AppMenuButton(onPressed: (_) {}, child: const Text('New window')),
    AppMenuButton(
      onPressed: (_) {},
      trailing: const AppMenuShortcut(
        activator: SingleActivator(LogicalKeyboardKey.comma, meta: true),
      ),
      child: const Text('Preferences'),
    ),
    const AppMenuDivider(),
    AppMenuButton(onPressed: (_) {}, child: const Text('Sign out')),
  ];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Menus and commands',
      description: 'Desktop menus, contextual actions, and command search.',
      sections: [
        ComponentSection(
          title: 'Menubar',
          child: AppMenubar(
            children: [
              AppMenuButton(subMenu: _items, child: const Text('File')),
              AppMenuButton(subMenu: _items, child: const Text('Account')),
            ],
          ),
        ),
        ComponentSection(
          title: 'Navigation menu',
          child: AppNavigationMenu(
            children: [
              const AppNavigationMenuItem(
                onPressed: _noop,
                child: Text('Overview'),
              ),
              AppNavigationMenuItem(
                content: AppNavigationMenuContentList(
                  crossAxisCount: 2,
                  children: const [
                    AppNavigationMenuContent(
                      title: Text('Components'),
                      content: Text('Reusable application primitives'),
                    ),
                    AppNavigationMenuContent(
                      title: Text('Themes'),
                      content: Text('Shared visual configuration'),
                    ),
                  ],
                ),
                child: const Text('Products'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Dropdown and context menu',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppDropdownMenu(children: _items),
              AppContextMenu(
                items: _items,
                child: const AppOutlinedContainer(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Right-click or long-press'),
                  ),
                ),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Command',
          child: SizedBox(
            height: 260,
            child: AppCommand(
              autofocus: false,
              searchPlaceholder: const Text('Search actions…'),
              builder: (context, query) async* {
                final normalized = (query ?? '').toLowerCase();
                final labels = [
                  'Open project',
                  'Create component',
                  'Settings',
                ].where((label) => label.toLowerCase().contains(normalized));
                yield [
                  AppCommandCategory(
                    title: const Text('Actions'),
                    children: [
                      for (final label in labels)
                        AppCommandItem(title: Text(label), onTap: _noop),
                    ],
                  ),
                ];
              },
            ),
          ),
        ),
      ],
    );
  }

  static void _noop() {}
}
