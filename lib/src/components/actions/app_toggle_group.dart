import 'package:flutter/widgets.dart';

import 'app_button.dart';
import 'app_toggle.dart';

class AppToggleGroupItem<T> {
  const AppToggleGroupItem({
    required this.value,
    required this.child,
    this.enabled = true,
  });

  final T value;
  final Widget child;
  final bool enabled;
}

class AppToggleGroup<T> extends StatelessWidget {
  factory AppToggleGroup.single({
    Key? key,
    required T? value,
    required ValueChanged<T?> onChanged,
    required List<AppToggleGroupItem<T>> items,
    Axis direction = Axis.horizontal,
    AppWidgetGroupMode mode = AppWidgetGroupMode.compact,
    double spacing = 8,
    bool allowEmpty = false,
    AppButtonSize? size,
    Color? selectedColor,
    Color? unselectedColor,
  }) => AppToggleGroup._(
    key: key,
    values: value == null ? const {} : {value},
    items: items,
    direction: direction,
    mode: mode,
    spacing: spacing,
    allowEmpty: allowEmpty,
    multiple: false,
    size: size,
    selectedColor: selectedColor,
    unselectedColor: unselectedColor,
    onSingleChanged: onChanged,
  );

  factory AppToggleGroup.multiple({
    Key? key,
    required Set<T> values,
    required ValueChanged<Set<T>> onChanged,
    required List<AppToggleGroupItem<T>> items,
    Axis direction = Axis.horizontal,
    AppWidgetGroupMode mode = AppWidgetGroupMode.compact,
    double spacing = 8,
    AppButtonSize? size,
    Color? selectedColor,
    Color? unselectedColor,
  }) => AppToggleGroup._(
    key: key,
    values: values,
    items: items,
    direction: direction,
    mode: mode,
    spacing: spacing,
    allowEmpty: true,
    multiple: true,
    size: size,
    selectedColor: selectedColor,
    unselectedColor: unselectedColor,
    onMultipleChanged: onChanged,
  );

  const AppToggleGroup._({
    super.key,
    required this.values,
    required this.items,
    required this.direction,
    required this.mode,
    required this.spacing,
    required this.allowEmpty,
    required this.multiple,
    required this.size,
    required this.selectedColor,
    required this.unselectedColor,
    this._onSingleChanged,
    this._onMultipleChanged,
  });

  final Set<T> values;
  final List<AppToggleGroupItem<T>> items;
  final Axis direction;
  final AppWidgetGroupMode mode;
  final double spacing;
  final bool allowEmpty;
  final bool multiple;
  final AppButtonSize? size;
  final Color? selectedColor;
  final Color? unselectedColor;
  final ValueChanged<T?>? _onSingleChanged;
  final ValueChanged<Set<T>>? _onMultipleChanged;

  void _toggle(AppToggleGroupItem<T> item) {
    final selected = values.contains(item.value);
    if (multiple) {
      final next = Set<T>.of(values);
      selected ? next.remove(item.value) : next.add(item.value);
      _onMultipleChanged!(Set<T>.unmodifiable(next));
      return;
    }
    if (selected) {
      if (allowEmpty) _onSingleChanged!(null);
    } else {
      _onSingleChanged!(item.value);
    }
  }

  @override
  Widget build(BuildContext context) => AppWidgetGroup(
    direction: direction,
    mode: mode,
    spacing: spacing,
    children: [
      for (final item in items)
        AppToggle(
          value: values.contains(item.value),
          onChanged: item.enabled ? (_) => _toggle(item) : null,
          size: size,
          selectedColor: selectedColor,
          unselectedColor: unselectedColor,
          child: item.child,
        ),
    ],
  );
}
