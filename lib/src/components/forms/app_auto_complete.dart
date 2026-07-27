import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_async_option_source.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_option.dart';
import 'app_select.dart';
import 'app_select_control_shell.dart';

typedef AppOptionSearcher<V> =
    Future<List<AppOption<V>>> Function(String query);
typedef AppAutoCompleteErrorBuilder<V> =
    Widget Function(
      BuildContext context,
      Object error,
      Future<List<AppOption<V>>> Function() retry,
    );

class AppAutoCompleteFormField<V> extends FormField<V> {
  const AppAutoCompleteFormField.async({
    super.key,
    required this.searchOptions,
    this.initialOption,
    this.label,
    this.name,
    this.description,
    this.placeholder = 'Search and select',
    this.searchPlaceholder = 'Search',
    this.required = false,
    this.width,
    this.clearable = false,
    this.debounce = const Duration(milliseconds: 300),
    this.cacheDuration = const Duration(minutes: 5),
    this.equals,
    this.loadingBuilder,
    this.emptyBuilder,
    this.loadErrorBuilder,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : optionSource = null,
       pagedOptionSource = null,
       super(builder: _buildField<V>);

  const AppAutoCompleteFormField.source({
    super.key,
    required this.optionSource,
    this.initialOption,
    this.label,
    this.name,
    this.description,
    this.placeholder = 'Search and select',
    this.searchPlaceholder = 'Search',
    this.required = false,
    this.width,
    this.clearable = false,
    this.debounce = const Duration(milliseconds: 300),
    this.equals,
    this.loadingBuilder,
    this.emptyBuilder,
    this.loadErrorBuilder,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : searchOptions = null,
       pagedOptionSource = null,
       cacheDuration = Duration.zero,
       super(builder: _buildField<V>);

  const AppAutoCompleteFormField.paged({
    super.key,
    required this.pagedOptionSource,
    this.initialOption,
    this.label,
    this.name,
    this.description,
    this.placeholder = 'Search and select',
    this.searchPlaceholder = 'Search',
    this.required = false,
    this.width,
    this.clearable = false,
    this.debounce = const Duration(milliseconds: 300),
    this.equals,
    this.loadingBuilder,
    this.emptyBuilder,
    this.loadErrorBuilder,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : searchOptions = null,
       optionSource = null,
       cacheDuration = Duration.zero,
       super(builder: _buildField<V>);

  final AppOptionSearcher<V>? searchOptions;
  final AppAsyncOptionSource<V>? optionSource;
  final AppAsyncPagedOptionSource<V>? pagedOptionSource;
  final AppOption<V>? initialOption;
  final String? label;
  final String? name;
  final String? description;
  final String placeholder;
  final String searchPlaceholder;
  final bool required;
  final double? width;
  final bool clearable;
  final Duration debounce;
  final Duration cacheDuration;
  final AppOptionEquals<V>? equals;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final AppAutoCompleteErrorBuilder<V>? loadErrorBuilder;
  final ValueChanged<V?>? onChanged;
  final AppAsyncFieldValidator<V>? asyncValidator;

  static Widget _buildField<T>(FormFieldState<T> state) {
    final field = state.widget as AppAutoCompleteFormField<T>;
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
        child: _AppAutoCompleteControl<T>(
          searchOptions: field.searchOptions,
          optionSource: field.optionSource,
          pagedOptionSource: field.pagedOptionSource,
          cacheDuration: field.cacheDuration,
          initialOption: field.initialOption,
          value: state.value,
          enabled: field.enabled,
          placeholder: field.placeholder,
          searchPlaceholder: field.searchPlaceholder,
          clearable: field.clearable,
          debounce: field.debounce,
          equals: field.equals,
          loadingBuilder: field.loadingBuilder,
          emptyBuilder: field.emptyBuilder,
          loadErrorBuilder: field.loadErrorBuilder,
          onChanged: (value) {
            state.didChange(value);
            field.onChanged?.call(value);
          },
        ),
      ),
    );
  }
}

class _AppAutoCompleteControl<V> extends StatefulWidget {
  const _AppAutoCompleteControl({
    required this.searchOptions,
    required this.optionSource,
    required this.pagedOptionSource,
    required this.cacheDuration,
    required this.value,
    required this.onChanged,
    required this.enabled,
    required this.placeholder,
    required this.searchPlaceholder,
    required this.clearable,
    required this.debounce,
    this.initialOption,
    this.equals,
    this.loadingBuilder,
    this.emptyBuilder,
    this.loadErrorBuilder,
  });

  final AppOptionSearcher<V>? searchOptions;
  final AppAsyncOptionSource<V>? optionSource;
  final AppAsyncPagedOptionSource<V>? pagedOptionSource;
  final Duration cacheDuration;
  final AppOption<V>? initialOption;
  final V? value;
  final ValueChanged<V?> onChanged;
  final bool enabled;
  final String placeholder;
  final String searchPlaceholder;
  final bool clearable;
  final Duration debounce;
  final AppOptionEquals<V>? equals;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final AppAutoCompleteErrorBuilder<V>? loadErrorBuilder;

  @override
  State<_AppAutoCompleteControl<V>> createState() =>
      _AppAutoCompleteControlState<V>();
}

class _AppAutoCompleteControlState<V>
    extends State<_AppAutoCompleteControl<V>> {
  final List<AppOption<V>> _knownOptions = [];
  int _searchGeneration = 0;
  String _lastQuery = '';
  AppAsyncOptionSource<V>? _source;

  @override
  void initState() {
    super.initState();
    _configureSource();
    if (widget.initialOption != null) _knownOptions.add(widget.initialOption!);
  }

  @override
  void didUpdateWidget(_AppAutoCompleteControl<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.optionSource != oldWidget.optionSource ||
        widget.pagedOptionSource != oldWidget.pagedOptionSource ||
        widget.searchOptions != oldWidget.searchOptions ||
        widget.cacheDuration != oldWidget.cacheDuration) {
      _configureSource();
      _searchGeneration++;
    }
  }

  void _configureSource() {
    _source = widget.pagedOptionSource != null
        ? null
        : widget.optionSource ??
              AppAsyncOptionSource<V>(
                loader: widget.searchOptions!,
                cacheDuration: widget.cacheDuration,
              );
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

    final normalizedQuery = query ?? '';
    _lastQuery = normalizedQuery;
    final firstPage = widget.pagedOptionSource == null
        ? null
        : await widget.pagedOptionSource!.load(normalizedQuery);
    final options = firstPage?.options ?? await _source!.load(normalizedQuery);
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
        if (firstPage?.nextCursor != null)
          _AppLoadMoreOptions<V>(
            query: normalizedQuery,
            cursor: firstPage!.nextCursor,
            source: widget.pagedOptionSource!,
            equals: _equals,
            onLoaded: _remember,
            existingOptions: options,
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppSelectControlShell(
      enabled: widget.enabled,
      builder: (context, popup) => shad.Select<V>(
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
            popup: (context) => popup(
              shad.SelectPopup<V>.builder(
                  builder: _search,
                  searchPlaceholder: Text(widget.searchPlaceholder),
                  loadingBuilder:
                      widget.loadingBuilder ??
                      (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(child: shad.CircularProgressIndicator()),
                      ),
                  emptyBuilder:
                      widget.emptyBuilder ??
                      (context) => const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No options found'),
                      ),
                  errorBuilder: (context, error, stackTrace) {
                    Future<List<AppOption<V>>> retry() async {
                      final options = widget.pagedOptionSource == null
                          ? await _source!.retry(_lastQuery)
                          : (await widget.pagedOptionSource!.retry(_lastQuery))
                                .options;
                      _remember(options);
                      return options;
                    }

                    return widget.loadErrorBuilder?.call(
                          context,
                          error,
                          retry,
                        ) ??
                        _AppInitialLoadError<V>(error: error, retry: retry);
                  },
              ),
            ),
      ),
    );
  }
}

class _AppInitialLoadError<V> extends StatefulWidget {
  const _AppInitialLoadError({required this.error, required this.retry});
  final Object error;
  final Future<List<AppOption<V>>> Function() retry;

  @override
  State<_AppInitialLoadError<V>> createState() =>
      _AppInitialLoadErrorState<V>();
}

class _AppInitialLoadErrorState<V> extends State<_AppInitialLoadError<V>> {
  bool _loading = false;
  Object? _error;
  List<AppOption<V>>? _options;

  Future<void> _retry() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final options = await widget.retry();
      if (!mounted) return;
      setState(() {
        _loading = false;
        _options = options;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final options = _options;
    if (options != null) {
      if (options.isEmpty) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Text('No options found'),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_error == null ? 'Unable to load options' : 'Retry failed'),
          const shad.Gap(8),
          shad.Button.outline(
            onPressed: _loading ? null : _retry,
            child: Text(_loading ? 'Loading' : 'Retry'),
          ),
        ],
      ),
    );
  }
}

class _AppLoadMoreOptions<V> extends StatefulWidget {
  const _AppLoadMoreOptions({
    required this.query,
    required this.cursor,
    required this.source,
    required this.equals,
    required this.onLoaded,
    required this.existingOptions,
  });

  final String query;
  final Object? cursor;
  final AppAsyncPagedOptionSource<V> source;
  final bool Function(V left, V right) equals;
  final ValueChanged<Iterable<AppOption<V>>> onLoaded;
  final List<AppOption<V>> existingOptions;

  @override
  State<_AppLoadMoreOptions<V>> createState() => _AppLoadMoreOptionsState<V>();
}

class _AppLoadMoreOptionsState<V> extends State<_AppLoadMoreOptions<V>> {
  final List<AppOption<V>> _options = [];
  late Object? _cursor = widget.cursor;
  bool _loading = false;
  Object? _error;

  bool _contains(V value) => [
    ...widget.existingOptions,
    ..._options,
  ].any((option) => widget.equals(option.value, value));

  Future<void> _load() async {
    if (_loading || _cursor == null) return;
    final cursor = _cursor;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await widget.source.load(widget.query, cursor: cursor);
      if (!mounted) return;
      final additions = page.options
          .where((option) => !_contains(option.value))
          .toList();
      setState(() {
        _options.addAll(additions);
        _cursor = page.nextCursor;
        _loading = false;
      });
      widget.onLoaded(additions);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = error;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (final option in _options)
          shad.SelectItemButton<V>(
            value: option.value,
            enabled: !option.disabled,
            child: option.child ?? Text(option.label),
          ),
        if (_cursor != null)
          Padding(
            padding: const EdgeInsets.all(8),
            child: shad.Button.outline(
              onPressed: _loading ? null : _load,
              child: _loading
                  ? const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox.square(
                          dimension: 14,
                          child: shad.CircularProgressIndicator(),
                        ),
                        shad.Gap(8),
                        Text('Loading'),
                      ],
                    )
                  : Text(_error == null ? 'Load more' : 'Retry loading'),
            ),
          ),
      ],
    );
  }
}
