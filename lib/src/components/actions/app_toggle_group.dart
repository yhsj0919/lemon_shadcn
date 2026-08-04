import 'package:flutter/widgets.dart';

import 'app_button.dart';

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
    bool allowEmpty = false,
    AppButtonSize? size,
  }) => AppToggleGroup._(
    key: key,
    values: value == null ? const {} : {value},
    items: items,
    direction: direction,
    allowEmpty: allowEmpty,
    multiple: false,
    size: size,
    onSingleChanged: onChanged,
  );

  factory AppToggleGroup.multiple({
    Key? key,
    required Set<T> values,
    required ValueChanged<Set<T>> onChanged,
    required List<AppToggleGroupItem<T>> items,
    Axis direction = Axis.horizontal,
    AppButtonSize? size,
  }) => AppToggleGroup._(
    key: key,
    values: values,
    items: items,
    direction: direction,
    allowEmpty: true,
    multiple: true,
    size: size,
    onMultipleChanged: onChanged,
  );

  const AppToggleGroup._({
    super.key,
    required this.values,
    required this.items,
    required this.direction,
    required this.allowEmpty,
    required this.multiple,
    required this.size,
    this._onSingleChanged,
    this._onMultipleChanged,
  });

  final Set<T> values;
  final List<AppToggleGroupItem<T>> items;
  final Axis direction;
  final bool allowEmpty;
  final bool multiple;
  final AppButtonSize? size;
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
    children: [
      for (final item in items)
        values.contains(item.value)
            ? AppButton.selected(
                size: size,
                onPressed: item.enabled ? () => _toggle(item) : null,
                config: AppButtonConfig.plain,
                child: item.child,
              )
            : AppButton.text(
                size: size,
                onPressed: item.enabled ? () => _toggle(item) : null,
                config: AppButtonConfig.plain,
                child: item.child,
              ),
    ],
  );
}
