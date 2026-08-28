import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({
    super.key,
    this.visibleSections,
    this.title = '导航',
    this.description = '用于定位、分页和视图切换的组件。',
  });

  final Set<String>? visibleSections;
  final String title;
  final String description;

  @override
  State<NavigationPage> createState() => _NavigationPageState();
}

class _NavigationPageState extends State<NavigationPage> {
  int _page = 2;
  int _tab = 0;
  Key? _destination = const ValueKey('home');

  @override
  Widget build(BuildContext context) {
    const tabs = [
      AppTabItem(child: Text('概览')),
      AppTabItem(child: Text('动态')),
      AppTabItem(child: Text('设置')),
    ];
    return ComponentPage(
      title: widget.title,
      description: widget.description,
      sections:
          <ComponentSection>[
            const ComponentSection(
              title: '面包屑',
              child: AppBreadcrumb(
                children: [Text('首页'), Text('组件'), Text('导航')],
              ),
            ),
            ComponentSection(
              title: '分页',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppPagination(
                    page: _page,
                    totalPages: 8,
                    onPageChanged: (value) => setState(() => _page = value),
                  ),
                  const SizedBox(height: 16),
                  AppPagination(
                    page: _page,
                    totalPages: 8,
                    variant: AppPaginationVariant.iconOnly,
                    showSkipToFirstPage: false,
                    showSkipToLastPage: false,
                    onPageChanged: (value) => setState(() => _page = value),
                  ),
                ],
              ),
            ),
            ComponentSection(
              title: '标签页',
              child: AppTabs(
                index: _tab,
                onChanged: (value) => setState(() => _tab = value),
                children: tabs,
              ),
            ),
            ComponentSection(
              title: '标签列表',
              child: AppTabList(
                index: _tab,
                onChanged: (value) => setState(() => _tab = value),
                children: tabs,
              ),
            ),
            ComponentSection(
              title: '面板切换器',
              child: SizedBox(
                height: 72,
                child: AppSwitcher(
                  index: _tab,
                  direction: AxisDirection.left,
                  onIndexChanged: (value) => setState(() => _tab = value),
                  children: const [
                    Center(child: Text('概览面板')),
                    Center(child: Text('动态面板')),
                    Center(child: Text('设置面板')),
                  ],
                ),
              ),
            ),
            ComponentSection(
              title: '导航栏',
              child: AppNavigationBar(
                selectedKey: _destination,
                onSelected: (value) => setState(() => _destination = value),
                children: const [
                  AppNavigationItem(
                    key: ValueKey('home'),
                    label: Text('首页'),
                    child: Icon(LucideIcons.house),
                  ),
                  AppNavigationItem(
                    key: ValueKey('search'),
                    label: Text('搜索'),
                    child: Icon(LucideIcons.search),
                  ),
                  AppNavigationItem(
                    key: ValueKey('profile'),
                    selectedColor: Color(0xff0f9f6e),
                    label: Text('个人资料'),
                    child: Icon(LucideIcons.user),
                  ),
                ],
              ),
            ),
          ].where((section) {
            return widget.visibleSections?.contains(section.title) ?? true;
          }).toList(),
    );
  }
}
