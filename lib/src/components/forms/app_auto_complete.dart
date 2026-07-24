import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_field.dart';
import 'app_option.dart';
import 'app_select.dart';

typedef AppOptionSearcher<V> =
    Future<List<AppOption<V>>> Function(String query);

class AppAutoCompleteFormField<V> extends FormField<V> {
  const AppAutoCompleteFormField.async({
    super.key,
    required this.searchOptions,
    this.initialOption,
    this.label,
    this.description,
    this.placeholder = 'Search and select',
    this.searchPlaceholder = 'Search',
    this.required = false,
    this.clearable = false,
    this.debounce = const Duration(milliseconds: 300),
    this.equals,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(builder: _buildField<V>);

  final AppOptionSearcher<V> searchOptions;
  final AppOption<V>? initialOption;
  final String? label;
  final String? description;
  final String placeholder;
  final String searchPlaceholder;
  final bool required;
  final bool clearable;
  final Duration debounce;
  final AppOptionEquals<V>? equals;
  final ValueChanged<V?>? onChanged;

  static Widget _buildField<T>(FormFieldState<T> state) {
    final field = state.widget as AppAutoCompleteFormField<T>;
    return AppField(
      label: field.label,
      description: field.description,
      errorText: state.errorText,
      required: field.required,
      child: _AppAutoCompleteControl<T>(
        searchOptions: field.searchOptions,
        initialOption: field.initialOption,
        value: state.value,
        enabled: field.enabled,
        placeholder: field.placeholder,
        searchPlaceholder: field.searchPlaceholder,
        clearable: field.clearable,
        debounce: field.debounce,
        equals: field.equals,
        onChanged: (value) {
          state.didChange(value);
          field.onChanged?.call(value);
        },
      ),
    );
  }
}

class _AppAutoCompleteControl<V> extends StatefulWidget {
  const _AppAutoCompleteControl({
    required this.searchOptions,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.placeholder,
    required this.searchPlaceholder,
    required this.clearable,
    required this.debounce,
    this.initialOption,
    this.equals,
  });

  final AppOptionSearcher<V> searchOptions;
  final AppOption<V>? initialOption;
  final V? value;
  final ValueChanged<V?> onChanged;
  final bool enabled;
  final String placeholder;
  final String searchPlaceholder;
  final bool clearable;
  final Duration debounce;
  final AppOptionEquals<V>? equals;

  @override
  State<_AppAutoCompleteControl<V>> createState() =>
      _AppAutoCompleteControlState<V>();
}

class _AppAutoCompleteControlState<V>
    extends State<_AppAutoCompleteControl<V>> {
  final List<AppOption<V>> _knownOptions = [];
  int _searchGeneration = 0;

  @override
  void initState() {
    super.initState();
    if (widget.initialOption != null) _knownOptions.add(widget.initialOption!);
  }

  bool _equals(V left, V right) =>
      widget.equals?.call(left, right) ?? left == right;

  AppOption<V>? _findOption(V value) {
    for (final option in _knownOptions) {
      if (_equals(option.value, value)) return option;
    }
    return null;
  }

  void _remember(Iterable<AppOption<V>> options) {
    for (final option in options) {
      final index = _knownOptions.indexWhere(
        (known) => _equals(known.value, option.value),
      );
      if (index < 0) {
        _knownOptions.add(option);
      } else {
        _knownOptions[index] = option;
      }
    }
  }

  Future<shad.SelectItemDelegate> _search(
    BuildContext context,
    String? query,
  ) async {
    final generation = ++_searchGeneration;
    await Future<void>.delayed(widget.debounce);
    if (generation != _searchGeneration) return shad.SelectItemDelegate.empty;

    final options = await widget.searchOptions(query ?? '');
    if (generation != _searchGeneration) return shad.SelectItemDelegate.empty;
    _remember(options);
    return shad.SelectItemList(
      children: [
        for (final option in options)
          shad.SelectItemButton<V>(
            value: option.value,
            enabled: !option.disabled,
            child: option.child ?? Text(option.label),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return shad.Select<V>(
      value: widget.value,
      enabled: widget.enabled,
      canUnselect: widget.clearable,
      onChanged: widget.onChanged,
      placeholder: Text(widget.placeholder).muted(),
      valueSelectionPredicate: (selected, candidate) {
        return selected != null &&
            candidate is V &&
            _equals(selected, candidate);
      },
      itemBuilder: (context, value) {
        final option = _findOption(value);
        return option?.child ?? Text(option?.label ?? value.toString());
      },
      popup: shad.SelectPopup<V>.builder(
        builder: _search,
        searchPlaceholder: Text(widget.searchPlaceholder),
        loadingBuilder: (context) => const Padding(
          padding: EdgeInsets.all(16),
          child: Center(child: shad.CircularProgressIndicator()),
        ),
        emptyBuilder: (context) => const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No options found'),
        ),
        errorBuilder: (context, error, stackTrace) => const Padding(
          padding: EdgeInsets.all(16),
          child: Text('Unable to load options'),
        ),
      ).call,
    );
  }
}
