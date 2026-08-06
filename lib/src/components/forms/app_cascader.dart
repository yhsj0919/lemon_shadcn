import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_option.dart';
import 'app_select.dart';

class AppCascadeOption<V> extends AppOption<V> {
  const AppCascadeOption({
    required super.value,
    required super.label,
    super.child,
    super.keywords,
    super.disabled,
    this.children = const [],
  });

  final List<AppCascadeOption<V>> children;
}

typedef AppCascadeLoader<V> =
    Future<List<AppCascadeOption<V>>> Function(int level, List<V> selectedPath);

class AppCascader<V> extends StatefulWidget {
  const AppCascader({
    super.key,
    required this.options,
    required this.levelCount,
    this.value = const [],
    this.onChanged,
    this.hintTexts = const [],
    this.optionConfig = const AppOptionConfig(),
    this.enabled = true,
    this.clearable = true,
    this.direction = Axis.horizontal,
    this.gap = 8,
    this.sourceKey,
    this.popupMinWidth = 160,
  }) : loadOptions = null,
       assert(levelCount > 0);

  const AppCascader.async({
    super.key,
    required this.loadOptions,
    required this.levelCount,
    this.value = const [],
    this.onChanged,
    this.hintTexts = const [],
    this.optionConfig = const AppOptionConfig(),
    this.enabled = true,
    this.clearable = true,
    this.direction = Axis.horizontal,
    this.gap = 8,
    this.sourceKey,
    this.popupMinWidth = 160,
  }) : options = null,
       assert(levelCount > 0);

  final List<AppCascadeOption<V>>? options;
  final AppCascadeLoader<V>? loadOptions;
  final int levelCount;
  final List<V> value;
  final ValueChanged<List<V>>? onChanged;
  final List<String> hintTexts;
  final AppOptionConfig<V> optionConfig;
  final bool enabled;
  final bool clearable;
  final Axis direction;
  final double gap;
  final Object? sourceKey;
  final double popupMinWidth;

  @override
  State<AppCascader<V>> createState() => _AppCascaderState<V>();
}

class _AppCascaderState<V> extends State<AppCascader<V>> {
  late List<List<AppCascadeOption<V>>> _asyncOptions;
  late List<bool> _loading;
  late List<Object?> _errors;
  late List<int> _generations;

  bool get _isAsync => widget.loadOptions != null;
  bool get _interactive => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _resetAsyncState();
    if (_isAsync) _loadReachableLevels();
  }

  @override
  void didUpdateWidget(AppCascader<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    final structureChanged =
        widget.levelCount != oldWidget.levelCount ||
        (widget.loadOptions == null) != (oldWidget.loadOptions == null) ||
        widget.sourceKey != oldWidget.sourceKey;
    if (structureChanged) {
      _resetAsyncState();
      if (_isAsync) _loadReachableLevels();
      return;
    }
    if (_isAsync && !_pathsEqual(widget.value, oldWidget.value)) {
      final changedAt = _firstChangedLevel(widget.value, oldWidget.value);
      _clearAfter(changedAt);
      for (
        var level = changedAt + 1;
        level < widget.levelCount && level <= widget.value.length;
        level++
      ) {
        unawaited(_loadLevel(level));
      }
    }
  }

  void _resetAsyncState() {
    _asyncOptions = List.generate(widget.levelCount, (_) => const []);
    _loading = List.filled(widget.levelCount, false);
    _errors = List.filled(widget.levelCount, null);
    _generations = List.filled(widget.levelCount, 0);
  }

  bool _equal(V left, V right) => widget.optionConfig.isEqual(left, right);

  bool _pathsEqual(List<V> left, List<V> right) {
    if (left.length != right.length) return false;
    for (var index = 0; index < left.length; index++) {
      if (!_equal(left[index], right[index])) return false;
    }
    return true;
  }

  int _firstChangedLevel(List<V> current, List<V> previous) {
    final commonLength = current.length < previous.length
        ? current.length
        : previous.length;
    for (var index = 0; index < commonLength; index++) {
      if (!_equal(current[index], previous[index])) return index;
    }
    return commonLength;
  }

  void _loadReachableLevels() {
    for (
      var level = 0;
      level < widget.levelCount && level <= widget.value.length;
      level++
    ) {
      unawaited(_loadLevel(level));
    }
  }

  Future<void> _loadLevel(int level, {List<V>? path}) async {
    if (!_isAsync || level < 0 || level >= widget.levelCount) return;
    final selectedPath = List<V>.unmodifiable(
      (path ?? widget.value).take(level),
    );
    if (selectedPath.length != level) return;
    final generation = ++_generations[level];
    setState(() {
      _loading[level] = true;
      _errors[level] = null;
    });
    try {
      final options = await widget.loadOptions!(level, selectedPath);
      if (!mounted || generation != _generations[level]) return;
      setState(() {
        _asyncOptions[level] = List.unmodifiable(options);
        _loading[level] = false;
      });
    } catch (error) {
      if (!mounted || generation != _generations[level]) return;
      setState(() {
        _loading[level] = false;
        _errors[level] = error;
      });
    }
  }

  void _clearAfter(int level) {
    if (!_isAsync) return;
    for (var index = level + 1; index < widget.levelCount; index++) {
      _generations[index]++;
      _asyncOptions[index] = const [];
      _loading[index] = false;
      _errors[index] = null;
    }
  }

  List<AppCascadeOption<V>> _staticOptionsFor(int level) {
    var options = widget.options ?? <AppCascadeOption<V>>[];
    for (var index = 0; index < level; index++) {
      if (index >= widget.value.length) return const [];
      AppCascadeOption<V>? selected;
      for (final option in options) {
        if (_equal(option.value, widget.value[index])) {
          selected = option;
          break;
        }
      }
      if (selected == null) return const [];
      options = selected.children;
    }
    return options;
  }

  List<AppCascadeOption<V>> _optionsFor(int level) =>
      _isAsync ? _asyncOptions[level] : _staticOptionsFor(level);

  void _changeLevel(int level, V? selected) {
    final next = <V>[...widget.value.take(level)];
    if (selected != null) next.add(selected);
    _clearAfter(level);
    final value = List<V>.unmodifiable(next);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged?.call(value);
    });
  }

  String _placeholderFor(int level) =>
      level < widget.hintTexts.length ? widget.hintTexts[level] : '请选择';

  Widget _buildLevel(int level) {
    final parentReady = level == 0 || widget.value.length >= level;
    final options = _optionsFor(level);
    final error = _errors[level];
    final loading = _loading[level];
    final placeholder = loading
        ? '加载中…'
        : error != null
        ? '加载失败，点击重试'
        : _placeholderFor(level);
    return shad.ComponentTheme<shad.SelectTheme>(
      data: const shad.SelectTheme(borderRadius: BorderRadius.zero),
      child: AppSelect<V>(
        options: options,
        value: level < widget.value.length ? widget.value[level] : null,
        enabled: widget.enabled && parentReady && !loading,
        clearable: widget.clearable,
        hintText: placeholder,
        optionConfig: widget.optionConfig,
        popupMinWidth: widget.popupMinWidth,
        onChanged: !_interactive || !parentReady || loading
            ? null
            : error != null
            ? (_) => _loadLevel(level)
            : (value) => _changeLevel(level, value),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final children = [
      for (var level = 0; level < widget.levelCount; level++)
        _buildLevel(level),
    ];
    if (widget.direction == Axis.vertical) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var index = 0; index < children.length; index++) ...[
            if (index > 0) SizedBox(height: widget.gap),
            children[index],
          ],
        ],
      );
    }
    return AppWidgetGroup.horizontal(expands: true, children: children);
  }
}

class AppCascaderFormField<V> extends FormField<List<V>> {
  AppCascaderFormField({
    super.key,
    required List<AppCascadeOption<V>> options,
    required int levelCount,
    String? name,
    String? label,
    String? description,
    bool required = false,
    double? width,
    List<String> hintTexts = const [],
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    bool clearable = true,
    Axis direction = Axis.horizontal,
    double gap = 8,
    double popupMinWidth = 160,
    Object? sourceKey,
    ValueChanged<List<V>>? onChanged,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    AppAsyncFieldValidator<List<V>>? asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) => AppFormFieldBinding<List<V>>(
           name: name,
           value: state.value,
           asyncValidator: asyncValidator,
           builder: (context, asyncError) => AppField(
             label: label,
             description: description,
             errorText: state.errorText ?? asyncError,
             required: required,
             width: width,
             child: AppCascader<V>(
               options: options,
               levelCount: levelCount,
               value: state.value ?? const [],
               enabled: state.widget.enabled,
               hintTexts: hintTexts,
               optionConfig: optionConfig,
               clearable: clearable,
               direction: direction,
               gap: gap,
               popupMinWidth: popupMinWidth,
               sourceKey: sourceKey,
               onChanged: (value) {
                 state.didChange(value);
                 onChanged?.call(value);
               },
             ),
           ),
         ),
       );

  AppCascaderFormField.async({
    super.key,
    required AppCascadeLoader<V> loadOptions,
    required int levelCount,
    String? name,
    String? label,
    String? description,
    bool required = false,
    double? width,
    List<String> hintTexts = const [],
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    bool clearable = true,
    Axis direction = Axis.horizontal,
    double gap = 8,
    double popupMinWidth = 160,
    Object? sourceKey,
    ValueChanged<List<V>>? onChanged,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    AppAsyncFieldValidator<List<V>>? asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) => AppFormFieldBinding<List<V>>(
           name: name,
           value: state.value,
           asyncValidator: asyncValidator,
           builder: (context, asyncError) => AppField(
             label: label,
             description: description,
             errorText: state.errorText ?? asyncError,
             required: required,
             width: width,
             child: AppCascader<V>.async(
               loadOptions: loadOptions,
               levelCount: levelCount,
               value: state.value ?? const [],
               enabled: state.widget.enabled,
               hintTexts: hintTexts,
               optionConfig: optionConfig,
               clearable: clearable,
               direction: direction,
               gap: gap,
               popupMinWidth: popupMinWidth,
               sourceKey: sourceKey,
               onChanged: (value) {
                 state.didChange(value);
                 onChanged?.call(value);
               },
             ),
           ),
         ),
       );
}

enum AppRegionLevel { province, city, county }

enum AppRegionPickerVariant { provinceCityCounty, provinceCity, cityCounty }

typedef AppRegionLoader<V> =
    Future<List<AppCascadeOption<V>>> Function(
      AppRegionLevel level,
      List<V> selectedPath,
    );

class AppRegionPicker<V> extends StatelessWidget {
  const AppRegionPicker({
    super.key,
    required this.options,
    this.variant = AppRegionPickerVariant.provinceCityCounty,
    this.value = const [],
    this.onChanged,
    this.optionConfig = const AppOptionConfig(),
    this.enabled = true,
    this.clearable = true,
    this.direction = Axis.horizontal,
    this.gap = 8,
    this.popupMinWidth = 160,
    this.sourceKey,
  }) : loadOptions = null;

  const AppRegionPicker.provinceCity({
    super.key,
    required this.options,
    this.value = const [],
    this.onChanged,
    this.optionConfig = const AppOptionConfig(),
    this.enabled = true,
    this.clearable = true,
    this.direction = Axis.horizontal,
    this.gap = 8,
    this.popupMinWidth = 160,
    this.sourceKey,
  }) : variant = AppRegionPickerVariant.provinceCity,
       loadOptions = null;

  const AppRegionPicker.cityCounty({
    super.key,
    required this.options,
    this.value = const [],
    this.onChanged,
    this.optionConfig = const AppOptionConfig(),
    this.enabled = true,
    this.clearable = true,
    this.direction = Axis.horizontal,
    this.gap = 8,
    this.popupMinWidth = 160,
    this.sourceKey,
  }) : variant = AppRegionPickerVariant.cityCounty,
       loadOptions = null;

  const AppRegionPicker.async({
    super.key,
    required this.loadOptions,
    this.variant = AppRegionPickerVariant.provinceCityCounty,
    this.value = const [],
    this.onChanged,
    this.optionConfig = const AppOptionConfig(),
    this.enabled = true,
    this.clearable = true,
    this.direction = Axis.horizontal,
    this.gap = 8,
    this.popupMinWidth = 160,
    this.sourceKey,
  }) : options = null;

  final List<AppCascadeOption<V>>? options;
  final AppRegionLoader<V>? loadOptions;
  final AppRegionPickerVariant variant;
  final List<V> value;
  final ValueChanged<List<V>>? onChanged;
  final AppOptionConfig<V> optionConfig;
  final bool enabled;
  final bool clearable;
  final Axis direction;
  final double gap;
  final double popupMinWidth;
  final Object? sourceKey;

  List<AppRegionLevel> get _levels => switch (variant) {
    AppRegionPickerVariant.provinceCityCounty => const [
      AppRegionLevel.province,
      AppRegionLevel.city,
      AppRegionLevel.county,
    ],
    AppRegionPickerVariant.provinceCity => const [
      AppRegionLevel.province,
      AppRegionLevel.city,
    ],
    AppRegionPickerVariant.cityCounty => const [
      AppRegionLevel.city,
      AppRegionLevel.county,
    ],
  };

  String _placeholder(AppRegionLevel level) => switch (level) {
    AppRegionLevel.province => '请选择省份',
    AppRegionLevel.city => '请选择城市',
    AppRegionLevel.county => '请选择区县',
  };

  @override
  Widget build(BuildContext context) {
    final levels = _levels;
    final hintTexts = [for (final level in levels) _placeholder(level)];
    final loader = loadOptions;
    if (loader != null) {
      return AppCascader<V>.async(
        levelCount: levels.length,
        loadOptions: (index, path) => loader(levels[index], path),
        value: value,
        onChanged: onChanged,
        hintTexts: hintTexts,
        optionConfig: optionConfig,
        enabled: enabled,
        clearable: clearable,
        direction: direction,
        gap: gap,
        popupMinWidth: popupMinWidth,
        sourceKey: sourceKey,
      );
    }
    return AppCascader<V>(
      options: options ?? const [],
      levelCount: levels.length,
      value: value,
      onChanged: onChanged,
      hintTexts: hintTexts,
      optionConfig: optionConfig,
      enabled: enabled,
      clearable: clearable,
      direction: direction,
      gap: gap,
      popupMinWidth: popupMinWidth,
      sourceKey: sourceKey,
    );
  }
}

class AppRegionPickerFormField<V> extends FormField<List<V>> {
  AppRegionPickerFormField({
    super.key,
    required List<AppCascadeOption<V>> options,
    AppRegionPickerVariant variant = AppRegionPickerVariant.provinceCityCounty,
    String? name,
    String? label,
    String? description,
    bool required = false,
    double? width,
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    bool clearable = true,
    Axis direction = Axis.horizontal,
    double gap = 8,
    double popupMinWidth = 160,
    Object? sourceKey,
    ValueChanged<List<V>>? onChanged,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    AppAsyncFieldValidator<List<V>>? asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) => AppFormFieldBinding<List<V>>(
           name: name,
           value: state.value,
           asyncValidator: asyncValidator,
           builder: (context, asyncError) => AppField(
             label: label,
             description: description,
             errorText: state.errorText ?? asyncError,
             required: required,
             width: width,
             child: AppRegionPicker<V>(
               options: options,
               variant: variant,
               value: state.value ?? const [],
               enabled: state.widget.enabled,
               optionConfig: optionConfig,
               clearable: clearable,
               direction: direction,
               gap: gap,
               popupMinWidth: popupMinWidth,
               sourceKey: sourceKey,
               onChanged: (value) {
                 state.didChange(value);
                 onChanged?.call(value);
               },
             ),
           ),
         ),
       );

  AppRegionPickerFormField.async({
    super.key,
    required AppRegionLoader<V> loadOptions,
    AppRegionPickerVariant variant = AppRegionPickerVariant.provinceCityCounty,
    String? name,
    String? label,
    String? description,
    bool required = false,
    double? width,
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    bool clearable = true,
    Axis direction = Axis.horizontal,
    double gap = 8,
    double popupMinWidth = 160,
    Object? sourceKey,
    ValueChanged<List<V>>? onChanged,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    AppAsyncFieldValidator<List<V>>? asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) => AppFormFieldBinding<List<V>>(
           name: name,
           value: state.value,
           asyncValidator: asyncValidator,
           builder: (context, asyncError) => AppField(
             label: label,
             description: description,
             errorText: state.errorText ?? asyncError,
             required: required,
             width: width,
             child: AppRegionPicker<V>.async(
               loadOptions: loadOptions,
               variant: variant,
               value: state.value ?? const [],
               enabled: state.widget.enabled,
               optionConfig: optionConfig,
               clearable: clearable,
               direction: direction,
               gap: gap,
               popupMinWidth: popupMinWidth,
               sourceKey: sourceKey,
               onChanged: (value) {
                 state.didChange(value);
                 onChanged?.call(value);
               },
             ),
           ),
         ),
       );
}
