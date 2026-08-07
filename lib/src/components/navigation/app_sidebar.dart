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
class AppSidebarMenuItem {
  const AppSidebarMenuItem({
    required this.id,
    required this.label,
    required this.icon,
    this.children = const [],
  });

  final String id;
  final String label;
  final IconData icon;
  final List<AppSidebarMenuItem> children;

  bool contains(String destinationId) =>
      id == destinationId ||
      children.any((child) => child.contains(destinationId));
}

/// A titled top-level section in sidebar navigation.
@immutable
class AppSidebarGroup {
  const AppSidebarGroup({this.label, required this.items});

  final String? label;
  final List<AppSidebarMenuItem> items;
}

/// Navigation content slot for [AppSidebar].
@immutable
class AppSidebarContent {
  const AppSidebarContent({this.groups = const [], this.items = const []});

  final List<AppSidebarGroup> groups;
  final List<AppSidebarMenuItem> items;
}

class AppSidebarHeader extends StatelessWidget {
  const AppSidebarHeader({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

class AppSidebarFooter extends StatelessWidget {
  const AppSidebarFooter({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

/// Sidebar navigation with shared expanded and icon-only presentations.
class AppSidebar extends StatefulWidget {
  const AppSidebar({
    super.key,
    required this.content,
    required this.selectedId,
    required this.onDestinationSelected,
    this.mode = AppSidebarMode.expanded,
    this.header,
    this.footer,
    this.expandedWidth = 248,
    this.compactWidth = 64,
    this.selectedColor,
  });

  final AppSidebarContent content;
  final String selectedId;
  final ValueChanged<String> onDestinationSelected;
  final AppSidebarMode mode;
  final Widget? header;
  final Widget? footer;
  final double expandedWidth;
  final double compactWidth;
  final Color? selectedColor;

  @override
  State<AppSidebar> createState() => _AppSidebarState();
}

class _AppSidebarState extends State<AppSidebar> {
  final Set<String> _expanded = {};

  List<AppSidebarGroup> get _groups => widget.content.groups.isEmpty
      ? [AppSidebarGroup(items: widget.content.items)]
      : widget.content.groups;

  @override
  void initState() {
    super.initState();
    _expandSelectedBranch();
  }

  @override
  void didUpdateWidget(covariant AppSidebar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedId != widget.selectedId ||
        oldWidget.content != widget.content) {
      _expandSelectedBranch();
    }
  }

  void _expandSelectedBranch() {
    for (final group in _groups) {
      for (final destination in group.items) {
        _expandAncestors(destination);
      }
    }
  }

  bool _expandAncestors(AppSidebarMenuItem destination) {
    if (destination.id == widget.selectedId) return true;
    final containsSelection = destination.children.any(_expandAncestors);
    if (containsSelection) _expanded.add(destination.id);
    return containsSelection;
  }

  @override
  Widget build(BuildContext context) {
    final targetWidth = widget.mode == AppSidebarMode.compact
        ? widget.compactWidth
        : widget.expandedWidth;
    // Keep menu chrome in sync with the animating width so expanded rows are
    // not laid out inside a still-narrow sidebar during resize transitions.
    final switchWidth = (widget.compactWidth + widget.expandedWidth) / 2;
    return _SidebarSelectionScope(
      color: widget.selectedColor,
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOutCubic,
        tween: Tween<double>(end: targetWidth),
        builder: (context, width, _) {
          final compact = width < switchWidth;
          return SizedBox(
            width: width,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: compact ? 8 : 10,
                    ),
                    children: [
                      for (final (groupIndex, group) in _groups.indexed) ...[
                        if (compact && groupIndex > 0)
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 6),
                            child: AppDivider.horizontal(),
                          ),
                        if (!compact && group.label != null)
                          _SidebarGroupTitle(
                            label: group.label!,
                            first: groupIndex == 0,
                          ),
                        for (final destination in group.items)
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
                                    if (!_expanded.remove(id)) {
                                      _expanded.add(id);
                                    }
                                  }),
                                  onSelected: widget.onDestinationSelected,
                                ),
                      ],
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
          );
        },
      ),
    );
  }
}

class _SidebarGroupTitle extends StatelessWidget {
  const _SidebarGroupTitle({required this.label, required this.first});

  final String label;
  final bool first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(10, first ? 4 : 16, 10, 8),
      child: AppText.listSecondary(label),
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

  final AppSidebarMenuItem destination;
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

  final AppSidebarMenuItem destination;
  final String selectedId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final selected = destination.contains(selectedId);
    final trigger = SizedBox.square(
      dimension: 46,
      child: selected
          ? AppButton.selected(
              onPressed: destination.children.isEmpty
                  ? () => onSelected(destination.id)
                  : () {},
              color: _SidebarSelectionScope.colorOf(context),
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
        child: AppTooltip(
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
        hoverBuilder: (context) {
          final maxHeight = MediaQuery.sizeOf(context).height - 32;
          return shad.Card(
            padding: const EdgeInsets.all(8),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: 180,
                maxWidth: 240,
                maxHeight: maxHeight,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(10, 4, 10, 8),
                    child: AppText.listSecondary(destination.label),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: shad.Scrollbar(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
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
                  ),
                ],
              ),
            ),
          );
        },
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

  final AppSidebarMenuItem destination;
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

  final AppSidebarMenuItem destination;
  final bool selected;
  final VoidCallback? onPressed;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final label = AppText.listItem(
      destination.label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
    final button = selected
        ? AppButton.selected(
            onPressed: onPressed,
            color: _SidebarSelectionScope.colorOf(context),
            config: const AppButtonConfig(
              alignment: Alignment.centerLeft,
              pressEffect: AppButtonPressEffect.none,
            ),
            child: Row(
              children: [
                Icon(destination.icon, size: 18),
                const SizedBox(width: 8),
                Expanded(child: label),
                ?trailing,
              ],
            ),
          )
        : AppButton.ghost(
            onPressed: onPressed,
            leading: Icon(destination.icon, size: 18),
            trailing: trailing,
            config: const AppButtonConfig(
              alignment: Alignment.centerLeft,
              pressEffect: AppButtonPressEffect.none,
            ),
            child: label,
          );
    return Padding(padding: const EdgeInsets.only(bottom: 4), child: button);
  }
}

class _SidebarSelectionScope extends InheritedWidget {
  const _SidebarSelectionScope({required this.color, required super.child});

  final Color? color;

  static Color? colorOf(BuildContext context) => context
      .dependOnInheritedWidgetOfExactType<_SidebarSelectionScope>()
      ?.color;

  @override
  bool updateShouldNotify(_SidebarSelectionScope oldWidget) =>
      color != oldWidget.color;
}
