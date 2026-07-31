import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../display/app_text.dart';
import '../layout/app_layout_components.dart';
import '../overlay/app_overlay_components.dart';

enum AppSidebarMode { expanded, compact }

/// Shell-level sidebar presentation. [auto] follows the shell breakpoints,
/// while the other values pin the sidebar to a fixed presentation.
enum AppSidebarType { auto, expanded, compact, drawer }

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

  bool contains(String destinationId) =>
      id == destinationId ||
      children.any((child) => child.contains(destinationId));
}

/// Sidebar navigation with shared expanded and icon-only presentations.
class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.destinations,
    required this.selectedId,
    required this.onDestinationSelected,
    this.mode = AppSidebarMode.expanded,
    this.header,
    this.footer,
    this.expandedWidth = 248,
    this.compactWidth = 64,
  });

  final List<AppNavDestination> destinations;
  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final AppSidebarMode mode;
  final Widget? header;
  final Widget? footer;
  final double expandedWidth;
  final double compactWidth;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    _expandSelectedBranch();
  }

  @override
  void didUpdateWidget(covariant AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId ||
        oldWidget.destinations != widget.destinations) {
      _expandSelectedBranch();
    }
  }

  void _expandSelectedBranch() {
    for (final destination in widget.destinations) {
      _expandAncestors(destination);
    }
  }

  bool _expandAncestors(AppNavDestination destination) {
    if (destination.id == widget.selectedId) return true;
    final containsSelection = destination.children.any(_expandAncestors);
    if (containsSelection) _expanded.add(destination.id);
    return containsSelection;
  }

  @override
  Widget build(BuildContext context) {
    final compact = widget.mode == AppSidebarMode.compact;
    return AppButtonMotionScope.disable(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        width: compact ? widget.compactWidth : widget.expandedWidth,
        child: AppCard(
          padding: EdgeInsets.zero,
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (widget.header != null)
                Padding(
                  padding: EdgeInsets.all(compact ? 8 : 16),
                  child: widget.header,
                ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(horizontal: compact ? 8 : 10),
                  children: [
                    for (final destination in widget.destinations)
                      compact
                          ? _CompactDestination(
                              destination: destination,
                              selectedId: widget.selectedId,
                              onSelected: widget.onDestinationSelected,
                            )
                          : _ExpandedDestination(
                              destination: destination,
                              selectedId: widget.selectedId,
                              expandedIds: _expanded,
                              onToggle: (id) => setState(() {
                                if (!_expanded.remove(id)) _expanded.add(id);
                              }),
                              onSelected: widget.onDestinationSelected,
                            ),
                  ],
                ),
              ),
              if (widget.footer != null)
                Padding(
                  padding: EdgeInsets.all(compact ? 8 : 12),
                  child: widget.footer,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExpandedDestination extends StatelessWidget {
  const _ExpandedDestination({
    required this.destination,
    required this.selectedId,
    required this.expandedIds,
    required this.onToggle,
    required this.onSelected,
    this.depth = 0,
  });

  final AppNavDestination destination;
  final String selectedId;
  final Set<String> expandedIds;
  final ValueChanged<String> onToggle;
  final ValueChanged<String> onSelected;
  final int depth;

  @override
  Widget build(BuildContext context) {
    final hasChildren = destination.children.isNotEmpty;
    final selected = destination.id == selectedId;
    final expanded = expandedIds.contains(destination.id);
    return Padding(
      padding: EdgeInsets.only(left: depth == 0 ? 0 : 14, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SidebarButton(
            destination: destination,
            selected: selected || destination.contains(selectedId),
            trailing: hasChildren
                ? AnimatedRotation(
                    turns: expanded ? .25 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: const Icon(shad.LucideIcons.chevronRight, size: 16),
                  )
                : null,
            onPressed: hasChildren
                ? () => onToggle(destination.id)
                : () => onSelected(destination.id),
          ),
          if (hasChildren)
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: expanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Column(
                        children: [
                          for (final child in destination.children)
                            _ExpandedDestination(
                              destination: child,
                              selectedId: selectedId,
                              expandedIds: expandedIds,
                              onToggle: onToggle,
                              onSelected: onSelected,
                              depth: depth + 1,
                            ),
                        ],
                      ),
                    )
                  : const SizedBox(width: double.infinity),
            ),
        ],
      ),
    );
  }
}

class _CompactDestination extends StatelessWidget {
  const _CompactDestination({
    required this.destination,
    required this.selectedId,
    required this.onSelected,
  });

  final AppNavDestination destination;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = destination.contains(selectedId);
    final trigger = SizedBox.square(
      dimension: 46,
      child: selected
          ? AppButton.secondary(
              onPressed: destination.children.isEmpty
                  ? () => onSelected(destination.id)
                  : () {},
              config: AppButtonConfig.plain,
              child: Icon(destination.icon, size: 19),
            )
          : AppButton.ghost(
              onPressed: destination.children.isEmpty
                  ? () => onSelected(destination.id)
                  : () {},
              config: AppButtonConfig.plain,
              child: Icon(destination.icon, size: 19),
            ),
    );
    if (destination.children.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: shad.Tooltip(
          tooltip: (context) => AppText.listItem(destination.label),
          child: trigger,
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: AppHoverCard(
        popoverAlignment: Alignment.topLeft,
        anchorAlignment: Alignment.topRight,
        popoverOffset: const Offset(8, 0),
        hoverBuilder: (context) => shad.Card(
          padding: const EdgeInsets.all(8),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 180, maxWidth: 240),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                  child: AppText.listSecondary(destination.label),
                ),
                for (final child in destination.children)
                  _PopoverDestination(
                    destination: child,
                    selectedId: selectedId,
                    onSelected: onSelected,
                  ),
              ],
            ),
          ),
        ),
        child: trigger,
      ),
    );
  }
}

class _PopoverDestination extends StatelessWidget {
  const _PopoverDestination({
    required this.destination,
    required this.selectedId,
    required this.onSelected,
    this.depth = 0,
  });

  final AppNavDestination destination;
  final String selectedId;
  final ValueChanged<String> onSelected;
  final int depth;

  @override
  Widget build(BuildContext context) {
    if (destination.children.isEmpty) {
      return Padding(
        padding: EdgeInsets.only(left: depth * 12),
        child: _SidebarButton(
          destination: destination,
          selected: destination.id == selectedId,
          onPressed: () {
            AppOverlay.close<void>(context);
            onSelected(destination.id);
          },
        ),
      );
    }
    return Padding(
      padding: EdgeInsets.only(left: depth * 12, top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 4, 10, 6),
            child: AppText.listSecondary(destination.label),
          ),
          for (final child in destination.children)
            _PopoverDestination(
              destination: child,
              selectedId: selectedId,
              onSelected: onSelected,
              depth: depth + 1,
            ),
        ],
      ),
    );
  }
}

class _SidebarButton extends StatelessWidget {
  const _SidebarButton({
    required this.destination,
    required this.selected,
    required this.onPressed,
    this.trailing,
  });

  final AppNavDestination destination;
  final bool selected;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = AppText.listItem(destination.label);
    final button = selected
        ? AppButton.secondary(
            onPressed: onPressed,
            leading: Icon(destination.icon, size: 18),
            trailing: trailing,
            config: const AppButtonConfig(
              alignment: Alignment.centerLeft,
            ),

            child: label,
          )
        : AppButton.ghost(
            onPressed: onPressed,
            leading: Icon(destination.icon, size: 18),
            trailing: trailing,
            config: const AppButtonConfig(
              alignment: Alignment.centerLeft,
            ),

            child: label,
          );
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: button);
  }
}
