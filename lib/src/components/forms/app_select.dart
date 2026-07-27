import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_shadcn_scope.dart';
import 'app_async_option_source.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_option.dart';

typedef AppOptionLoader<V> = Future<List<AppOption<V>>> Function();
typedef AppOptionEquals<V> = bool Function(V left, V right);
typedef AppSelectErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

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
    assert(_debugCheckUniqueOptions(options, _equals));
    return AppControlBox(
      child: shad.Select<V>(
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
      ),
    );
  }
}

class AppSelectFormField<V> extends FormField<V> {
  const AppSelectFormField({
    super.key,
    required this.options,
    this.label,
    this.name,
    this.description,
    this.placeholder = 'Select an option',
    this.required = false,
    this.width,
    this.clearable = false,
    this.equals,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : loadOptions = null,
       optionSource = null,
       cacheDuration = Duration.zero,
       loadingStateBuilder = null,
       loadErrorBuilder = null,
       emptyStateBuilder = null,
       super(builder: _buildField<V>);

  const AppSelectFormField.async({
    super.key,
    required this.loadOptions,
    this.label,
    this.name,
    this.description,
    this.placeholder = 'Select an option',
    this.required = false,
    this.width,
    this.clearable = false,
    this.cacheDuration = const Duration(minutes: 5),
    this.equals,
    this.onChanged,
    this.loadingStateBuilder,
    this.loadErrorBuilder,
    this.emptyStateBuilder,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : options = null,
       optionSource = null,
       super(builder: _buildField<V>);

  const AppSelectFormField.source({
    super.key,
    required this.optionSource,
    this.label,
    this.name,
    this.description,
    this.placeholder = 'Select an option',
    this.required = false,
    this.width,
    this.clearable = false,
    this.equals,
    this.onChanged,
    this.loadingStateBuilder,
    this.loadErrorBuilder,
    this.emptyStateBuilder,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : options = null,
       loadOptions = null,
       cacheDuration = Duration.zero,
       super(builder: _buildField<V>);

  final List<AppOption<V>>? options;
  final AppOptionLoader<V>? loadOptions;
  final AppAsyncOptionSource<V>? optionSource;
  final Duration cacheDuration;
  final String? label;
  final String? name;
  final String? description;
  final String placeholder;
  final bool required;
  final double? width;
  final bool clearable;
  final AppOptionEquals<V>? equals;
  final ValueChanged<V?>? onChanged;
  final WidgetBuilder? loadingStateBuilder;
  final AppSelectErrorBuilder? loadErrorBuilder;
  final WidgetBuilder? emptyStateBuilder;
  final AppAsyncFieldValidator<V>? asyncValidator;

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
            loadOptions: field.loadOptions,
            optionSource: field.optionSource,
            cacheDuration: field.cacheDuration,
            value: state.value,
            enabled: field.enabled,
            placeholder: field.placeholder,
            clearable: field.clearable,
            equals: field.equals,
            loadingBuilder: field.loadingStateBuilder,
            errorBuilder: field.loadErrorBuilder,
            emptyBuilder: field.emptyStateBuilder,
            onChanged: (value) {
              state.didChange(value);
              field.onChanged?.call(value);
            },
          );

    return AppFormFieldBinding<T>(
      name: field.name,
      value: state.value,
      asyncValidator: field.asyncValidator,
      builder: (context, asyncError) => AppField(
        label: field.label,
        description: field.description,
        errorText: state.errorText ?? asyncError,
        required: field.required,
        width: field.width,
        child: select,
      ),
    );
  }
}

class _AppAsyncSelect<V> extends StatefulWidget {
  const _AppAsyncSelect({
    required this.loadOptions,
    required this.optionSource,
    required this.cacheDuration,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.placeholder,
    required this.clearable,
    this.equals,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  final AppOptionLoader<V>? loadOptions;
  final AppAsyncOptionSource<V>? optionSource;
  final Duration cacheDuration;
  final V? value;
  final ValueChanged<V?> onChanged;
  final bool enabled;
  final String placeholder;
  final bool clearable;
  final AppOptionEquals<V>? equals;
  final WidgetBuilder? loadingBuilder;
  final AppSelectErrorBuilder? errorBuilder;
  final WidgetBuilder? emptyBuilder;

  @override
  State<_AppAsyncSelect<V>> createState() => _AppAsyncSelectState<V>();
}

class _AppAsyncSelectState<V> extends State<_AppAsyncSelect<V>> {
  late Future<List<AppOption<V>>> _future;
  late AppAsyncOptionSource<V> _source;

  @override
  void initState() {
    super.initState();
    _configureSource();
    _future = _source.load('');
  }

  @override
  void didUpdateWidget(_AppAsyncSelect<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loadOptions != oldWidget.loadOptions ||
        widget.optionSource != oldWidget.optionSource ||
        widget.cacheDuration != oldWidget.cacheDuration) {
      _configureSource();
      _future = _source.load('');
    }
  }

  void _configureSource() {
    _source =
        widget.optionSource ??
        AppAsyncOptionSource<V>.single(
          loader: widget.loadOptions!,
          cacheDuration: widget.cacheDuration,
        );
  }

  void _retry() {
    final future = _source.retry('');
    setState(() {
      _future = future;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<AppOption<V>>>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          final error = snapshot.error!;
          if (widget.errorBuilder case final builder?) {
            return builder(context, error, _retry);
          }
          final message =
              AppTheme.maybeOf(
                context,
              )?.errorPresenter?.call(error, snapshot.stackTrace) ??
              'Unable to load options';
          return AppControlBox(
            child: shad.OutlineButton(
              onPressed: _retry,
              child: Text('$message. Retry'),
            ),
          );
        }
        if (!snapshot.hasData) {
          if (widget.loadingBuilder case final builder?) {
            return builder(context);
          }
          return const AppControlBox(
            child: shad.OutlineButton(
              onPressed: null,
              leading: SizedBox.square(
                dimension: 16,
                child: shad.CircularProgressIndicator(),
              ),
              child: Text('Loading'),
            ),
          );
        }
        if (snapshot.data!.isEmpty && widget.emptyBuilder != null) {
          return widget.emptyBuilder!(context);
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

bool _debugCheckUniqueOptions<V>(
  List<AppOption<V>> options,
  bool Function(V left, V right) equals,
) {
  for (var left = 0; left < options.length; left++) {
    for (var right = left + 1; right < options.length; right++) {
      if (equals(options[left].value, options[right].value)) {
        throw FlutterError(
          'AppSelect options contain duplicate values at indexes $left and '
          '$right. Option identity must be unique under the configured equals '
          'function.',
        );
      }
    }
  }
  return true;
}
