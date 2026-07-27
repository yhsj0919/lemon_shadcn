import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../display/app_text.dart';

@immutable
class AppNavDestination {
  const AppNavDestination({
    required this.id,
    required this.label,
    required this.icon,
    this.children = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final List<AppNavDestination> children;
}

/// Router-agnostic admin shell with a grouped component sidebar.
class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onDestinationSelected,
    required this.child,
    this.brandTitle = 'Lemon Shadcn',
    this.brandSubtitle,
    this.pageTitle,
    this.pageSubtitle,
    this.headerActions = const [],
    this.sidebarFooter,
    this.sidebarWidth = 248,
    this.compactBreakpoint = 720,
  });

  final List<AppNavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final Widget child;
  final String brandTitle;
  final String? brandSubtitle;
  final String? pageTitle;
  final String? pageSubtitle;
  final List<Widget> headerActions;
  final Widget? sidebarFooter;
  final double sidebarWidth;
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final wideShell = shad.Scaffold(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 0, 12),
            child: SizedBox(
              width: sidebarWidth,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: ColoredBox(
                  color: theme.colorScheme.card,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.title(brandTitle),
                            if (brandSubtitle != null) ...[
                              const SizedBox(height: 4),
                              AppText.muted(brandSubtitle!),
                            ],
                          ],
                        ),
                      ),
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          children: [
                            for (final destination in destinations)
                              _NavigationSection(
                                destination: destination,
                                selectedId: selectedId,
                                onSelected: onDestinationSelected,
                              ),
                          ],
                        ),
                      ),
                      if (sidebarFooter != null)
                        Padding(
                          padding: const EdgeInsets.all(12),
                          child: sidebarFooter,
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (pageTitle != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 18, 24, 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              AppText.h3(pageTitle!),
                              if (pageSubtitle != null)
                                AppText.muted(pageSubtitle!),
                            ],
                          ),
                        ),
                        ...headerActions,
                      ],
                    ),
                  ),
                Expanded(child: child),
              ],
            ),
          ),
        ],
      ),
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= compactBreakpoint) return wideShell;
        return _CompactAppShell(
          destinations: destinations,
          selectedId: selectedId,
          onDestinationSelected: onDestinationSelected,
          brandTitle: brandTitle,
          pageTitle: pageTitle,
          pageSubtitle: pageSubtitle,
          headerActions: headerActions,
          child: child,
        );
      },
    );
  }
}

class _CompactAppShell extends StatelessWidget {
  const _CompactAppShell({
    required this.destinations,
    required this.selectedId,
    required this.onDestinationSelected,
    required this.brandTitle,
    required this.pageTitle,
    required this.pageSubtitle,
    required this.headerActions,
    required this.child,
  });

  final List<AppNavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final String brandTitle;
  final String? pageTitle;
  final String? pageSubtitle;
  final List<Widget> headerActions;
  final Widget child;

  Iterable<AppNavDestination> get _pages sync* {
    for (final destination in destinations) {
      if (destination.children.isEmpty) {
        yield destination;
      } else {
        yield* destination.children;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return shad.Scaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Row(
              children: [
                Expanded(child: AppText.title(brandTitle)),
                ...headerActions,
              ],
            ),
          ),
          SizedBox(
            height: 48,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                for (final destination in _pages)
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: destination.id == selectedId
                        ? AppButton.secondary(
                            onPressed: () =>
                                onDestinationSelected(destination.id),
                            leading: Icon(destination.icon),
                            child: Text(destination.label),
                          )
                        : AppButton.ghost(
                            onPressed: () =>
                                onDestinationSelected(destination.id),
                            leading: Icon(destination.icon),
                            child: Text(destination.label),
                          ),
                  ),
              ],
            ),
          ),
          if (pageTitle != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText.h3(pageTitle!),
                  if (pageSubtitle != null) AppText.muted(pageSubtitle!),
                ],
              ),
            ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavigationSection extends StatelessWidget {
  const _NavigationSection({
    required this.destination,
    required this.selectedId,
    required this.onSelected,
  });

  final AppNavDestination destination;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (destination.children.isEmpty) {
      return _NavigationButton(
        destination: destination,
        selected: destination.id == selectedId,
        onSelected: onSelected,
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: AppText.caption(destination.label),
          ),
          for (final child in destination.children)
            _NavigationButton(
              destination: child,
              selected: child.id == selectedId,
              onSelected: onSelected,
            ),
        ],
      ),
    );
  }
}

class _NavigationButton extends StatelessWidget {
  const _NavigationButton({
    required this.destination,
    required this.selected,
    required this.onSelected,
  });

  final AppNavDestination destination;
  final bool selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: selected
          ? AppButton.secondary(
              onPressed: () => onSelected(destination.id),
              leading: Icon(destination.icon),
              config: const AppButtonConfig(alignment: Alignment.centerLeft),
              child: Text(destination.label),
            )
          : AppButton.ghost(
              onPressed: () => onSelected(destination.id),
              leading: Icon(destination.icon),
              config: const AppButtonConfig(alignment: Alignment.centerLeft),
              child: Text(destination.label),
            ),
    );
  }
}
