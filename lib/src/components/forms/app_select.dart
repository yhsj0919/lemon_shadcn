import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_shadcn_scope.dart';
import 'app_async_option_source.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_option.dart';
import 'app_select_control_shell.dart';

typedef AppOptionLoader<V> = Future<List<AppOption<V>>> Function();
typedef AppSelectErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

enum AppDependentValuePolicy { clearImmediately, keepIfValid, preserve }

class AppSelect<V> extends StatefulWidget {
  const AppSelect({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.hintText = 'Select an option',
    this.enabled = true,
    this.clearable = false,
    this.sourceKey,
    this.dependentValuePolicy = AppDependentValuePolicy.clearImmediately,
    this.optionConfig = const AppOptionConfig(),
    this.initialOption,
    this.popupMinWidth,
    this.maxPopupHeight = 320,
    this.minWidth = 160,
  }) : assert(maxPopupHeight > 0);

  factory AppSelect.async({
    Key? key,
    required AppOptionLoader<V> loadOptions,
    V? value,
    ValueChanged<V?>? onChanged,
    String hintText = 'Select an option',
    bool enabled = true,
    bool clearable = false,
    Duration cacheDuration = const Duration(minutes: 5),
    Object? sourceKey,
    AppDependentValuePolicy dependentValuePolicy =
        AppDependentValuePolicy.clearImmediately,
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    AppOption<V>? initialOption,
    double? popupMinWidth,
    double maxPopupHeight = 320,
    double minWidth = 160,
    WidgetBuilder? loadingBuilder,
    AppSelectErrorBuilder? errorBuilder,
    WidgetBuilder? emptyBuilder,
  }) => _AppAsyncSelect<V>(
    key: key,
    loadOptions: loadOptions,
    optionSource: null,
    cacheDuration: cacheDuration,
    sourceKey: sourceKey,
    dependentValuePolicy: dependentValuePolicy,
    value: value,
    onChanged: onChanged,
    enabled: enabled,
    hintText: hintText,
    clearable: clearable,
    optionConfig: optionConfig,
    initialOption: initialOption,
    popupMinWidth: popupMinWidth,
    maxPopupHeight: maxPopupHeight,
    minWidth: minWidth,
    loadingBuilder: loadingBuilder,
    errorBuilder: errorBuilder,
    emptyBuilder: emptyBuilder,
  );

  factory AppSelect.source({
    Key? key,
    required AppAsyncOptionSource<V> optionSource,
    V? value,
    ValueChanged<V?>? onChanged,
    String hintText = 'Select an option',
    bool enabled = true,
    bool clearable = false,
    Object? sourceKey,
    AppDependentValuePolicy dependentValuePolicy =
        AppDependentValuePolicy.clearImmediately,
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    AppOption<V>? initialOption,
    double? popupMinWidth,
    double maxPopupHeight = 320,
    double minWidth = 160,
    WidgetBuilder? loadingBuilder,
    AppSelectErrorBuilder? errorBuilder,
    WidgetBuilder? emptyBuilder,
  }) => _AppAsyncSelect<V>(
    key: key,
    loadOptions: null,
    optionSource: optionSource,
    cacheDuration: Duration.zero,
    sourceKey: sourceKey,
    dependentValuePolicy: dependentValuePolicy,
    value: value,
    onChanged: onChanged,
    enabled: enabled,
    hintText: hintText,
    clearable: clearable,
    optionConfig: optionConfig,
    initialOption: initialOption,
    popupMinWidth: popupMinWidth,
    maxPopupHeight: maxPopupHeight,
    minWidth: minWidth,
    loadingBuilder: loadingBuilder,
    errorBuilder: errorBuilder,
    emptyBuilder: emptyBuilder,
  );

  final List<AppOption<V>> options;
  final V? value;
  final ValueChanged<V?>? onChanged;
  final String hintText;
  final bool enabled;
  final bool clearable;
  final Object? sourceKey;
  final AppDependentValuePolicy dependentValuePolicy;
  final AppOptionConfig<V> optionConfig;
  final AppOption<V>? initialOption;
  final double? popupMinWidth;
  final double maxPopupHeight;
  final double minWidth;

  @override
  State<AppSelect<V>> createState() => _AppSelectState<V>();
}

class _AppSelectState<V> extends State<AppSelect<V>> {
  bool _equals(V left, V right) => widget.optionConfig.isEqual(left, right);

  AppOption<V>? _optionFor(V value) {
    for (final option in widget.options) {
      if (_equals(option.value, value)) return option;
    }
    final initial = widget.initialOption;
    return initial != null && _equals(initial.value, value) ? initial : null;
  }

  bool _hasRoomForExpandIcon(BuildContext context, double? width) {
    if (width == null) return true;
    final option = widget.value == null ? null : _optionFor(widget.value as V);
    final label = option?.label ?? widget.value?.toString() ?? widget.hintText;
    final metrics = AppControlMetricsScope.resolve(context);
    final painter = TextPainter(
      text: TextSpan(
        text: label,
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(fontSize: metrics.fontSize),
      ),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final requiredWidth = painter.width + metrics.contentGap + metrics.iconSize;
    return width >= requiredWidth;
  }

  @override
  void didUpdateWidget(AppSelect<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sourceKey == oldWidget.sourceKey || widget.value == null) return;
    final shouldClear = switch (widget.dependentValuePolicy) {
      AppDependentValuePolicy.clearImmediately => true,
      AppDependentValuePolicy.keepIfValid => !widget.options.any(
        (option) => _equals(option.value, widget.value as V),
      ),
      AppDependentValuePolicy.preserve => false,
    };
    if (shouldClear) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged?.call(null);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(_debugCheckUniqueOptions(widget.options, _equals));
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: widget.minWidth),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final anchorWidth = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : null;
          final minimumPopupWidth = widget.popupMinWidth;
          final showExpandIcon = _hasRoomForExpandIcon(context, anchorWidth);
          final popupWidth = minimumPopupWidth == null
              ? null
              : anchorWidth == null
              ? minimumPopupWidth
              : anchorWidth < minimumPopupWidth
              ? minimumPopupWidth
              : anchorWidth;
          return AppSelectControlShell(
            enabled: widget.enabled && widget.onChanged != null,
            builder: (context, popup, focusNode) => shad.Select<V>(
              value: widget.value,
              focusNode: focusNode,
              enabled: widget.enabled,
              canUnselect: widget.clearable,
              expandIcon: showExpandIcon ? const shad.SelectExpandIcon() : null,
              popupWidthConstraint: popupWidth == null
                  ? shad.PopoverConstraint.anchorFixedSize
                  : shad.PopoverConstraint.flexible,
              popupConstraints: popupWidth == null
                  ? BoxConstraints(maxHeight: widget.maxPopupHeight)
                  : BoxConstraints.tightFor(
                      width: popupWidth,
                    ).copyWith(maxHeight: widget.maxPopupHeight),
              onChanged: widget.enabled ? widget.onChanged : null,
              placeholder: Text(
                widget.hintText,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ).muted(),
              valueSelectionPredicate: (selected, candidate) {
                return selected != null &&
                    candidate is V &&
                    _equals(selected, candidate);
              },
              itemBuilder: (context, selected) {
                final option = _optionFor(selected);
                return option == null
                    ? Text(
                        selected.toString(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      )
                    : widget.optionConfig.buildSelected(context, option);
              },
              popup: (context) => popup(
                shad.SelectPopup<V>(
                  items: shad.SelectItemList(
                    children: [
                      for (final option in widget.options)
                        shad.SelectItemButton<V>(
                          value: option.value,
                          enabled: !option.disabled,
                          child: widget.optionConfig.buildOption(
                            context,
                            option,
                            AppOptionViewState(
                              selected:
                                  widget.value != null &&
                                  _equals(widget.value as V, option.value),
                              highlighted: false,
                              disabled: option.disabled,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
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
    this.hintText = 'Select an option',
    this.required = false,
    this.width,
    this.clearable = false,
    this.sourceKey,
    this.dependentValuePolicy = AppDependentValuePolicy.clearImmediately,
    this.optionConfig = const AppOptionConfig(),
    this.initialOption,
    this.popupMinWidth,
    this.maxPopupHeight = 320,
    this.minWidth = 160,
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
    this.hintText = 'Select an option',
    this.required = false,
    this.width,
    this.clearable = false,
    this.cacheDuration = const Duration(minutes: 5),
    this.sourceKey,
    this.dependentValuePolicy = AppDependentValuePolicy.clearImmediately,
    this.optionConfig = const AppOptionConfig(),
    this.initialOption,
    this.popupMinWidth,
    this.maxPopupHeight = 320,
    this.minWidth = 160,
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
    this.hintText = 'Select an option',
    this.required = false,
    this.width,
    this.clearable = false,
    this.sourceKey,
    this.dependentValuePolicy = AppDependentValuePolicy.clearImmediately,
    this.optionConfig = const AppOptionConfig(),
    this.initialOption,
    this.popupMinWidth,
    this.maxPopupHeight = 320,
    this.minWidth = 160,
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
  final Object? sourceKey;
  final AppDependentValuePolicy dependentValuePolicy;
  final String? label;
  final String? name;
  final String? description;
  final String hintText;
  final bool required;
  final double? width;
  final bool clearable;
  final AppOptionConfig<V> optionConfig;
  final AppOption<V>? initialOption;
  final double? popupMinWidth;
  final double maxPopupHeight;
  final double minWidth;
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
            hintText: field.hintText,
            clearable: field.clearable,
            sourceKey: field.sourceKey,
            dependentValuePolicy: field.dependentValuePolicy,
            optionConfig: field.optionConfig,
            initialOption: field.initialOption,
            popupMinWidth: field.popupMinWidth,
            maxPopupHeight: field.maxPopupHeight,
            minWidth: field.minWidth,
            onChanged: (value) {
              state.didChange(value);
              field.onChanged?.call(value);
            },
          )
        : _AppAsyncSelect<T>(
            loadOptions: field.loadOptions,
            optionSource: field.optionSource,
            cacheDuration: field.cacheDuration,
            sourceKey: field.sourceKey,
            dependentValuePolicy: field.dependentValuePolicy,
            value: state.value,
            enabled: field.enabled,
            hintText: field.hintText,
            clearable: field.clearable,
            optionConfig: field.optionConfig,
            initialOption: field.initialOption,
            popupMinWidth: field.popupMinWidth,
            maxPopupHeight: field.maxPopupHeight,
            minWidth: field.minWidth,
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

class _AppAsyncSelect<V> extends AppSelect<V> {
  const _AppAsyncSelect({
    super.key,
    required this.loadOptions,
    required this.optionSource,
    required this.cacheDuration,
    super.sourceKey,
    super.dependentValuePolicy = AppDependentValuePolicy.clearImmediately,
    required super.value,
    required super.onChanged,
    required super.enabled,
    required super.hintText,
    required super.clearable,
    super.optionConfig = const AppOptionConfig(),
    super.initialOption,
    super.popupMinWidth,
    super.maxPopupHeight,
    super.minWidth,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  }) : super(options: const []);

  final AppOptionLoader<V>? loadOptions;
  final AppAsyncOptionSource<V>? optionSource;
  final Duration cacheDuration;
  final WidgetBuilder? loadingBuilder;
  final AppSelectErrorBuilder? errorBuilder;
  final WidgetBuilder? emptyBuilder;

  @override
  State<_AppAsyncSelect<V>> createState() => _AppAsyncSelectState<V>();
}

class _AppAsyncSelectState<V> extends State<_AppAsyncSelect<V>> {
  late Future<List<AppOption<V>>> _future;
  late AppAsyncOptionSource<V> _source;
  bool _validateValueAfterLoad = false;

  @override
  void initState() {
    super.initState();
    _configureSource();
    _future = _load();
  }

  @override
  void didUpdateWidget(_AppAsyncSelect<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.loadOptions != oldWidget.loadOptions ||
        widget.optionSource != oldWidget.optionSource ||
        widget.cacheDuration != oldWidget.cacheDuration ||
        widget.sourceKey != oldWidget.sourceKey) {
      _configureSource();
      _validateValueAfterLoad =
          widget.sourceKey != oldWidget.sourceKey &&
          widget.dependentValuePolicy == AppDependentValuePolicy.keepIfValid;
      _future = _load();
      if (widget.sourceKey != oldWidget.sourceKey &&
          widget.value != null &&
          widget.dependentValuePolicy ==
              AppDependentValuePolicy.clearImmediately) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onChanged?.call(null);
        });
      }
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

  Future<List<AppOption<V>>> _load({bool force = false}) async {
    final options = force ? await _source.retry('') : await _source.load('');
    if (_validateValueAfterLoad && widget.value != null) {
      _validateValueAfterLoad = false;
      final valid = options.any(
        (option) =>
            widget.optionConfig.isEqual(option.value, widget.value as V),
      );
      if (!valid) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onChanged?.call(null);
        });
      }
    }
    return options;
  }

  void _retry() {
    final completer = Completer<List<AppOption<V>>>();
    setState(() {
      _future = completer.future;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        completer.complete(await _load(force: true));
      } catch (error, stackTrace) {
        completer.completeError(error, stackTrace);
      }
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
          hintText: widget.hintText,
          clearable: widget.clearable,
          optionConfig: widget.optionConfig,
          initialOption: widget.initialOption,
          popupMinWidth: widget.popupMinWidth,
          maxPopupHeight: widget.maxPopupHeight,
          minWidth: widget.minWidth,
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
