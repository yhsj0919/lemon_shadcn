import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class NavigationPage extends StatefulWidget {
  const NavigationPage({super.key});

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
      AppTabItem(child: Text('Overview')),
      AppTabItem(child: Text('Activity')),
      AppTabItem(child: Text('Settings')),
    ];
    return ComponentPage(
      title: 'Navigation',
      description: 'Location, paging, and view-switching components.',
      sections: [
        const ComponentSection(
          title: 'Breadcrumb',
          child: AppBreadcrumb(
            children: [Text('Home'), Text('Components'), Text('Navigation')],
          ),
        ),
        ComponentSection(
          title: 'Pagination',
          child: AppPagination(
            page: _page,
            totalPages: 8,
            onPageChanged: (value) => setState(() => _page = value),
          ),
        ),
        ComponentSection(
          title: 'Tabs',
          child: AppTabs(
            index: _tab,
            onChanged: (value) => setState(() => _tab = value),
            children: tabs,
          ),
        ),
        ComponentSection(
          title: 'Tab list and switcher',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTabList(
                index: _tab,
                onChanged: (value) => setState(() => _tab = value),
                children: tabs,
              ),
              const Gap(12),
              SizedBox(
                height: 72,
                child: AppSwitcher(
                  index: _tab,
                  direction: AxisDirection.right,
                  onIndexChanged: (value) => setState(() => _tab = value),
                  children: const [
                    Center(child: Text('Overview panel')),
                    Center(child: Text('Activity panel')),
                    Center(child: Text('Settings panel')),
                  ],
                ),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Navigation bar',
          child: AppNavigationBar(
            selectedKey: _destination,
            onSelected: (value) => setState(() => _destination = value),
            alignment: AppNavigationBarAlignment.center,
            children: const [
              AppNavigationItem(
                key: ValueKey('home'),
                label: Text('Home'),
                child: Text('H'),
              ),
              AppNavigationItem(
                key: ValueKey('search'),
                label: Text('Search'),
                child: Text('S'),
              ),
              AppNavigationItem(
                key: ValueKey('profile'),
                label: Text('Profile'),
                child: Text('P'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
