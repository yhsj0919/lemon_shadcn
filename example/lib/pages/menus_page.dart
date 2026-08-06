import 'package:flutter/services.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

class MenusPage extends StatelessWidget {
  const MenusPage({super.key});
  static const _commands = ['新建', '打开', '保存', '导出', '设置', '退出'];

  List<AppMenuItem> get _items => [
    AppMenuButton(onPressed: (_) {}, child: const Text('新建窗口')),
    AppMenuButton(
      onPressed: (_) {},
      trailing: const AppMenuShortcut(
        activator: SingleActivator(LogicalKeyboardKey.comma, meta: true),
      ),
      child: const Text('偏好设置'),
    ),
    const AppMenuDivider(),
    AppMenuButton(onPressed: (_) {}, child: const Text('退出登录')),
  ];

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: '菜单与命令',
      description: '桌面菜单、上下文操作与命令搜索。',
      sections: [
        ComponentSection(
          title: '菜单栏',
          child: AppMenubar(
            children: [
              AppMenuButton(subMenu: _items, child: const Text('文件')),
              AppMenuButton(subMenu: _items, child: const Text('账户')),
            ],
          ),
        ),
        ComponentSection(
          title: '导航菜单',
          child: AppNavigationMenu(
            children: [
              AppNavigationMenuItem(onPressed: _noop, child: const Text('概览')),
              AppNavigationMenuItem(
                content: AppNavigationMenuContentList(
                  crossAxisCount: 2,
                  children: [
                    AppNavigationMenuContent(
                      onPressed: _noop,
                      title: const Text('组件'),
                      content: const Text('可复用的应用基础组件'),
                    ),
                    AppNavigationMenuContent(
                      onPressed: _noop,
                      title: const Text('主题'),
                      content: const Text('共享视觉配置'),
                    ),
                  ],
                ),
                child: const Text('产品'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '下拉与上下文菜单',
          child: Wrap(
            spacing: 16,
            runSpacing: 16,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              AppDropdownButton(
                items: _items,
                trailing: const Icon(LucideIcons.chevronDown),
                child: const Text('打开操作菜单'),
              ),
              AppDropdownMenu(children: _items),
              AppContextMenu(
                items: _items,
                child: const AppOutlinedContainer(
                  padding: EdgeInsets.all(20),
                  child: Text('右键单击或长按'),
                ),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: '命令面板',
          child: AppCommand(
            autofocus: false,
            searchHintText: '搜索命令…',
            builder: (context, query) async* {
              final q = (query ?? '').toLowerCase();
              final filtered = _commands
                  .where((command) => command.toLowerCase().contains(q))
                  .map(
                    (command) =>
                        AppCommandItem(title: Text(command), onTap: _noop),
                  )
                  .toList();
              yield filtered;
            },
          ),
        ),
      ],
    );
  }

  static void _noop() {}
}
