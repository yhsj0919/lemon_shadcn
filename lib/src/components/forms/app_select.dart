import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_field.dart';
import 'app_option.dart';

typedef AppOptionLoader<V> = Future<List<AppOption<V>>> Function();
typedef AppOptionEquals<V> = bool Function(V left, V right);

class AppSelect<V> extends StatelessWidget {
  const AppSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.placeholder = 'Select an option',
    this.enabled = true,
    this.clearable = false,
    this.equals,
  });

  final List<AppOption<V>> options;
  final V? value;
  final ValueChanged<V?>? onChanged;
  final String placeholder;
  final bool enabled;
  final bool clearable;
  final AppOptionEquals<V>? equals;

  bool _equals(V left, V right) => equals?.call(left, right) ?? left == right;

  AppOption<V>? _optionFor(V value) {
    for (final option in options) {
      if (_equals(option.value, value)) return option;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return shad.Select<V>(
      value: value,
      enabled: enabled,
      canUnselect: clearable,
      onChanged: enabled ? onChanged : null,
      placeholder: Text(placeholder).muted(),
      valueSelectionPredicate: (selected, candidate) {
        return selected != null &&
            candidate is V &&
            _equals(selected, candidate);
      },
      itemBuilder: (context, selected) {
        final option = _optionFor(selected);
        return option?.child ?? Text(option?.label ?? selected.toString());
      },
      popup: shad.SelectPopup<V>(
        items: shad.SelectItemList(
          children: [
            for (final option in options)
              shad.SelectItemButton<V>(
                value: option.value,
                enabled: !option.disabled,
                child: option.child ?? Text(option.label),
              ),
          ],
        ),
      ).call,
    );
  }
}

class AppSelectFormField<V> extends FormField<V> {
  const AppSelectFormField({
    super.key,
    required this.options,
    this.label,
    this.description,
    this.placeholder = 'Select an option',
    this.required = false,
    this.clearable = false,
    this.equals,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : loadOptions = null,
       super(builder: _buildField<V>);

  const AppSelectFormField.async({
    super.key,
    required this.loadOptions,
    this.label,
    this.description,
    this.placeholder = 'Select an option',
    this.required = false,
    this.clearable = false,
    this.equals,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : options = null,
       super(builder: _buildField<V>);

  final List<AppOption<V>>? options;
  final AppOptionLoader<V>? loadOptions;
  final String? label;
  final String? description;
  final String placeholder;
  final bool required;
  final bool clearable;
  final AppOptionEquals<V>? equals;
  final ValueChanged<V?>? onChanged;

  static Widget _buildField<T>(FormFieldState<T> state) {
    final field = state.widget as AppSelectFormField<T>;
    final select = field.options != null
        ? AppSelect<T>(
            options: field.options!,
            value: state.value,
            enabled: field.enabled,
            placeholder: field.placeholder,
            clearable: field.clearable,
            equals: field.equals,
            onChanged: (value) {
              state.didChange(value);
              field.onChanged?.call(value);
            },
          )
        : _AppAsyncSelect<T>(
            loadOptions: field.loadOptions!,
            value: state.value,
            enabled: field.enabled,
            placeholder: field.placeholder,
            clearable: field.clearable,
            equals: field.equals,
            onChanged: (value) {
              state.didChange(value);
              field.onChanged?.call(value);
            },
          );

    return AppField(
      label: field.label,
      description: field.description,
      errorText: state.errorText,
      required: field.required,
      child: select,
    );
  }
}

class _AppAsyncSelect<V> extends StatefulWidget {
  const _AppAsyncSelect({
    required this.loadOptions,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.placeholder,
    required this.clearable,
    this.equals,
  });

  final AppOptionLoader<V> loadOptions;
  final V? value;
  final ValueChanged<V?> onChanged;
  final bool enabled;
  final String placeholder;
  final bool clearable;
  final AppOptionEquals<V>? equals;

  @override
  State<_AppAsyncSelect<V>> createState() => _AppAsyncSelectState<V>();
}

class _AppAsyncSelectState<V> extends State<_AppAsyncSelect<V>> {
  late Future<List<AppOption<V>>> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loadOptions();
  }

  @override
  void didUpdateWidget(_AppAsyncSelect<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loadOptions != oldWidget.loadOptions) {
      _future = widget.loadOptions();
    }
  }

  void _retry() => setState(() => _future = widget.loadOptions());

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppOption<V>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return shad.OutlineButton(
            onPressed: _retry,
            child: const Text('Unable to load. Retry'),
          );
        }
        if (!snapshot.hasData) {
          return const shad.OutlineButton(
            onPressed: null,
            leading: SizedBox.square(
              dimension: 16,
              child: shad.CircularProgressIndicator(),
            ),
            child: Text('Loading'),
          );
        }
        return AppSelect<V>(
          options: snapshot.data!,
          value: widget.value,
          onChanged: widget.onChanged,
          enabled: widget.enabled,
          placeholder: widget.placeholder,
          clearable: widget.clearable,
          equals: widget.equals,
        );
      },
    );
  }
}
