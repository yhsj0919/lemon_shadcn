import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_cascader.dart';
import 'app_select_control_shell.dart';

/// Single-trigger cascader: the trigger shows the full path (e.g. `A / B`)
/// and the popup lays out one column per level of an arbitrarily deep tree.
///
/// ```dart
/// AppCascadeSelect<int>(
///   options: tree,
///   value: path,
///   hintText: 'Industry',
///   onChanged: (path) => setState(() => this.path = path),
/// )
/// ```
class AppCascadeSelect<V> extends StatefulWidget {
  const AppCascadeSelect({
    super.key,
    required this.options,
    this.value = const [],
    this.onChanged,
    this.hintText = 'Select an option',
    this.enabled = true,
    this.clearable = false,
    this.changeOnSelect = false,
    this.separator = ' / ',
    this.columnWidth = 180,
    this.maxPopupHeight = 320,
    this.minWidth = 160,
  }) : assert(maxPopupHeight > 0);

  final List<AppCascadeOption<V>> options;

  /// Selected path from root to the chosen node; empty when nothing selected.
  final List<V> value;
  final ValueChanged<List<V>>? onChanged;
  final String hintText;
  final bool enabled;

  /// Tapping the selected node again clears the value.
  final bool clearable;

  /// Commits the path on every level instead of only on leaves.
  final bool changeOnSelect;
  final String separator;
  final double columnWidth;
  final double maxPopupHeight;
  final double minWidth;

  @override
  State<AppCascadeSelect<V>> createState() => _AppCascadeSelectState<V>();
}

class _AppCascadeSelectState<V> extends State<AppCascadeSelect<V>> {
  List<AppCascadeOption<V>> _resolve(List<V> path) {
    final nodes = <AppCascadeOption<V>>[];
    var level = widget.options;
    for (final value in path) {
      final node = level.where((e) => e.value == value).firstOrNull;
      if (node == null) break;
      nodes.add(node);
      level = node.children;
    }
    return nodes;
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final enabled = widget.enabled && widget.onChanged != null;
    final nodes = _resolve(widget.value);
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: widget.minWidth),
      child: AppSelectControlShell(
        enabled: enabled,
        builder: (context, popup, focusNode) => shad.Select<List<V>>(
          value: nodes.isEmpty ? null : widget.value,
          focusNode: focusNode,
          enabled: enabled,
          expandIcon: const Icon(shad.LucideIcons.chevronDown).iconSmall(),
          overlayConfiguration: shad.PopoverConfiguration(
            offset: Offset(0, theme.density.baseGap * theme.scaling),
            alignment: Alignment.topLeft,
            anchorAlignment: Alignment.bottomLeft,
            widthConstraint: shad.PopoverConstraint.flexible,
          ),
          popupConstraints: BoxConstraints(
            maxHeight: widget.maxPopupHeight + 2,
          ),
          onChanged: (value) => widget.onChanged?.call(value ?? const []),
          placeholder: Text(
            widget.hintText,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ).muted(),
          valueSelectionPredicate: (selected, candidate) =>
              selected != null &&
              candidate is List<V> &&
              listEquals(selected, candidate),
          itemBuilder: (context, _) => Text(
            nodes.map((e) => e.label).join(widget.separator),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          popup: (context) => popup(
            _AppCascadePanel<V>(
              options: widget.options,
              value: widget.value,
              clearable: widget.clearable,
              changeOnSelect: widget.changeOnSelect,
              columnWidth: widget.columnWidth,
              maxHeight: widget.maxPopupHeight,
              onChanged: (value) => widget.onChanged?.call(value),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppCascadePanel<V> extends StatefulWidget {
  const _AppCascadePanel({
    required this.options,
    required this.value,
    required this.clearable,
    required this.changeOnSelect,
    required this.columnWidth,
    required this.maxHeight,
    required this.onChanged,
  });

  final List<AppCascadeOption<V>> options;
  final List<V> value;
  final bool clearable;
  final bool changeOnSelect;
  final double columnWidth;
  final double maxHeight;
  final ValueChanged<List<V>> onChanged;

  @override
  State<_AppCascadePanel<V>> createState() => _AppCascadePanelState<V>();
}

class _AppCascadePanelState<V> extends State<_AppCascadePanel<V>> {
  late List<V> _active = List.of(widget.value);

  List<List<AppCascadeOption<V>>> get _columns {
    final columns = [widget.options];
    for (final value in _active) {
      final node = columns.last.where((e) => e.value == value).firstOrNull;
      if (node == null || node.children.isEmpty) break;
      columns.add(node.children);
    }
    return columns;
  }

  void _select(int level, AppCascadeOption<V> node) {
    final path = [..._active.take(level), node.value];
    final selected = listEquals(path, widget.value);
    if (node.children.isNotEmpty) {
      setState(() => _active = path);
      if (widget.changeOnSelect && !selected) widget.onChanged(path);
      return;
    }
    widget.onChanged(selected && widget.clearable ? const [] : path);
    shad.closeOverlay(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final itemExtent = 32 * scaling;
    final padding = 4 * scaling;
    final columns = _columns;
    final longest = columns.fold(0, (m, e) => e.length > m ? e.length : m);
    final height = (longest * itemExtent + padding * 2).clamp(
      0.0,
      widget.maxHeight,
    );
    return shad.ModalContainer(
      clipBehavior: Clip.hardEdge,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var level = 0; level < columns.length; level++)
            Container(
              width: widget.columnWidth * scaling,
              height: height,
              decoration: level == 0
                  ? null
                  : BoxDecoration(
                      border: Border(
                        left: BorderSide(color: theme.colorScheme.border),
                      ),
                    ),
              child: ListView(
                padding: EdgeInsets.all(padding),
                itemExtent: itemExtent,
                children: [
                  for (final node in columns[level])
                    _AppCascadeItem(
                      label: node.child ?? Text(node.label),
                      active:
                          _active.length > level &&
                          _active[level] == node.value,
                      checked: listEquals([
                        ..._active.take(level),
                        node.value,
                      ], widget.value),
                      hasChildren: node.children.isNotEmpty,
                      enabled: !node.disabled,
                      onPressed: () => _select(level, node),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _AppCascadeItem extends StatelessWidget {
  const _AppCascadeItem({
    required this.label,
    required this.active,
    required this.checked,
    required this.hasChildren,
    required this.enabled,
    required this.onPressed,
  });

  final Widget label;
  final bool active;
  final bool checked;
  final bool hasChildren;
  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final highlighted = active || checked;
    final color = highlighted ? theme.colorScheme.primary : null;
    return shad.Button(
      enabled: enabled,
      disableTransition: true,
      alignment: AlignmentDirectional.centerStart,
      onPressed: onPressed,
      style: const shad.ButtonStyle.ghost().copyWith(
        padding: (context, states, value) =>
            EdgeInsets.symmetric(horizontal: 8 * scaling),
        mouseCursor: (context, states, value) => SystemMouseCursors.basic,
      ),
      trailing: hasChildren
          ? Icon(shad.LucideIcons.chevronRight, color: color).iconSmall()
          : checked
          ? Icon(shad.LucideIcons.check, color: color).iconSmall()
          : null,
      child: DefaultTextStyle.merge(
        style: TextStyle(
          color: color,
          fontWeight: highlighted ? FontWeight.w600 : FontWeight.w400,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        child: label,
      ),
    );
  }
}
