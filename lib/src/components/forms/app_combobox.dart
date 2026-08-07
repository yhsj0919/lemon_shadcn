import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_overlay_style.dart';
import '../../foundation/app_shadcn_scope.dart';
import 'app_async_option_source.dart';
import 'app_chip_input.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_input_group.dart';
import 'app_option.dart';
import 'app_select.dart' show AppDependentValuePolicy;

typedef AppComboboxSearcher<V> =
    Future<List<AppOption<V>>> Function(String query);
typedef AppComboboxErrorBuilder =
    Widget Function(BuildContext context, Object error, VoidCallback retry);

enum AppComboboxDisplayMode { text, token }

enum AppComboboxEditBehavior { retainSelection, clearSelectionOnEdit }

class AppCombobox<V> extends StatefulWidget {
  const AppCombobox({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.optionConfig = const AppOptionConfig(),
    this.initialOption,
    this.hintText = 'Search and select',
    this.enabled = true,
    this.clearable = false,
    this.displayMode = AppComboboxDisplayMode.text,
    this.editBehavior = AppComboboxEditBehavior.retainSelection,
    this.sourceKey,
    this.dependentValuePolicy = AppDependentValuePolicy.clearImmediately,
    this.emptyBuilder,
    this.maxPopupHeight = 280,
    this.minWidth = 160,
  }) : searchOptions = null,
       optionSource = null,
       debounce = Duration.zero,
       cacheDuration = Duration.zero,
       loadingBuilder = null,
       errorBuilder = null;

  const AppCombobox.async({
    super.key,
    required this.searchOptions,
    this.value,
    this.onChanged,
    this.optionConfig = const AppOptionConfig(),
    this.initialOption,
    this.hintText = 'Search and select',
    this.enabled = true,
    this.clearable = false,
    this.displayMode = AppComboboxDisplayMode.text,
    this.editBehavior = AppComboboxEditBehavior.retainSelection,
    this.debounce = const Duration(milliseconds: 300),
    this.cacheDuration = const Duration(minutes: 5),
    this.sourceKey,
    this.dependentValuePolicy = AppDependentValuePolicy.clearImmediately,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.maxPopupHeight = 280,
    this.minWidth = 160,
  }) : options = null,
       optionSource = null;

  const AppCombobox.source({
    super.key,
    required this.optionSource,
    this.value,
    this.onChanged,
    this.optionConfig = const AppOptionConfig(),
    this.initialOption,
    this.hintText = 'Search and select',
    this.enabled = true,
    this.clearable = false,
    this.displayMode = AppComboboxDisplayMode.text,
    this.editBehavior = AppComboboxEditBehavior.retainSelection,
    this.debounce = const Duration(milliseconds: 300),
    this.sourceKey,
    this.dependentValuePolicy = AppDependentValuePolicy.clearImmediately,
    this.loadingBuilder,
    this.emptyBuilder,
    this.errorBuilder,
    this.maxPopupHeight = 280,
    this.minWidth = 160,
  }) : options = null,
       searchOptions = null,
       cacheDuration = Duration.zero;

  final List<AppOption<V>>? options;
  final AppComboboxSearcher<V>? searchOptions;
  final AppAsyncOptionSource<V>? optionSource;
  final V? value;
  final ValueChanged<V?>? onChanged;
  final AppOptionConfig<V> optionConfig;
  final AppOption<V>? initialOption;
  final String hintText;
  final bool enabled;
  final bool clearable;
  final AppComboboxDisplayMode displayMode;
  final AppComboboxEditBehavior editBehavior;
  final Duration debounce;
  final Duration cacheDuration;
  final Object? sourceKey;
  final AppDependentValuePolicy dependentValuePolicy;
  final WidgetBuilder? loadingBuilder;
  final WidgetBuilder? emptyBuilder;
  final AppComboboxErrorBuilder? errorBuilder;
  final double maxPopupHeight;
  final double minWidth;

  @override
  State<AppCombobox<V>> createState() => _AppComboboxState<V>();
}

class _AppComboboxState<V> extends State<AppCombobox<V>> {
  static const double _asyncPopupMinHeight = 160;
  final LayerLink _layerLink = LayerLink();
  final OverlayPortalController _overlay = OverlayPortalController();
  final GlobalKey _anchorKey = GlobalKey();
  final FocusNode _focusNode = FocusNode();
  late final TextEditingController _textController;
  Timer? _debounceTimer;
  AppAsyncOptionSource<V>? _source;
  List<AppOption<V>> _results = const [];
  final List<AppOption<V>> _knownOptions = [];
  Object? _error;
  bool _loading = false;
  bool _syncingText = false;
  int _generation = 0;
  int _highlightedIndex = -1;
  bool _validateValueAfterLoad = false;
  double _anchorWidth = 240;
  double _anchorHeight = 32;

  bool get _interactive => widget.enabled && widget.onChanged != null;

  @override
  void initState() {
    super.initState();
    _configureSource();
    _remember([...?widget.options, ?widget.initialOption]);
    _textController = TextEditingController(text: _initialText());
    _focusNode.addListener(_handleFocus);
  }

  @override
  void didUpdateWidget(AppCombobox<V> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.options != oldWidget.options ||
        widget.searchOptions != oldWidget.searchOptions ||
        widget.optionSource != oldWidget.optionSource ||
        widget.cacheDuration != oldWidget.cacheDuration) {
      _configureSource();
      _remember([...?widget.options]);
      if (_overlay.isShowing) _search(_textController.text);
    }
    if (widget.sourceKey != oldWidget.sourceKey) {
      _source?.invalidate();
      _setText('');
      _results = const [];
      _validateValueAfterLoad =
          widget.dependentValuePolicy == AppDependentValuePolicy.keepIfValid;
      if (widget.value != null &&
          widget.dependentValuePolicy ==
              AppDependentValuePolicy.clearImmediately) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) widget.onChanged?.call(null);
        });
      }
      if (_overlay.isShowing) _search('');
    }
    if (!_valuesEqual(widget.value, oldWidget.value) ||
        widget.initialOption != oldWidget.initialOption) {
      if (widget.initialOption case final option?) _remember([option]);
      if (!_focusNode.hasFocus ||
          widget.displayMode == AppComboboxDisplayMode.token) {
        _setText(
          widget.displayMode == AppComboboxDisplayMode.text
              ? _selectedOption()?.label ?? ''
              : '',
        );
      }
    }
  }

  void _configureSource() {
    _source = widget.options != null
        ? null
        : widget.optionSource ??
              AppAsyncOptionSource<V>(
                loader: widget.searchOptions!,
                cacheDuration: widget.cacheDuration,
              );
  }

  String _initialText() => widget.displayMode == AppComboboxDisplayMode.text
      ? _selectedOption()?.label ?? widget.initialOption?.label ?? ''
      : '';

  bool _equals(V left, V right) => widget.optionConfig.isEqual(left, right);

  bool _valuesEqual(V? left, V? right) {
    if (left == null || right == null) return left == right;
    return _equals(left, right);
  }

  AppOption<V>? _selectedOption() {
    final value = widget.value;
    if (value == null) return null;
    for (final option in _knownOptions) {
      if (_equals(option.value, value)) return option;
    }
    final initial = widget.initialOption;
    return initial != null && _equals(initial.value, value) ? initial : null;
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

  void _setText(String text) {
    if (_textController.text == text) return;
    _syncingText = true;
    _textController.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _syncingText = false;
  }

  void _handleFocus() {
    if (_focusNode.hasFocus) {
      _open();
    } else if (widget.displayMode == AppComboboxDisplayMode.text) {
      _setText(_selectedOption()?.label ?? '');
    }
  }

  void _measureAnchor() {
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    _anchorWidth = box.size.width;
    _anchorHeight = box.size.height;
  }

  void _handleAnchorGeometryChanged() {
    if (!mounted) return;
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final size = box.size;
    if (_anchorWidth == size.width && _anchorHeight == size.height) return;
    setState(() {
      _anchorWidth = size.width;
      _anchorHeight = size.height;
    });
  }

  void _showOverlay() {
    if (!_interactive) return;
    _measureAnchor();
    if (!_overlay.isShowing) _overlay.show();
  }

  void _open() {
    final wasShowing = _overlay.isShowing;
    _showOverlay();
    if (!wasShowing && _overlay.isShowing) _search('');
  }

  void _close() {
    if (_overlay.isShowing) _overlay.hide();
  }

  void _handleTextChanged(String query) {
    if (_syncingText) return;
    final clearedText =
        widget.displayMode == AppComboboxDisplayMode.text && query.isEmpty;
    if (widget.value != null &&
        (clearedText ||
            widget.editBehavior ==
                AppComboboxEditBehavior.clearSelectionOnEdit)) {
      widget.onChanged?.call(null);
    }
    _showOverlay();
    _search(query);
  }

  void _search(String query, {bool force = false}) {
    _debounceTimer?.cancel();
    final generation = ++_generation;
    final normalized = query.trim().toLowerCase();
    if (widget.options case final options?) {
      final filtered = options
          .where((option) {
            return normalized.isEmpty ||
                widget.optionConfig
                    .searchableText(option)
                    .toLowerCase()
                    .contains(normalized);
          })
          .toList(growable: false);
      _remember(filtered);
      _validateDependentValue(filtered);
      setState(() {
        _results = filtered;
        _loading = false;
        _error = null;
        _highlightedIndex = -1;
      });
      return;
    }
    if (!_loading || _error != null) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    _debounceTimer = Timer(force ? Duration.zero : widget.debounce, () async {
      if (!mounted || generation != _generation) return;
      try {
        final options = force
            ? await _source!.retry(query)
            : await _source!.load(query);
        if (!mounted || generation != _generation) return;
        _remember(options);
        _validateDependentValue(options);
        setState(() {
          _results = options;
          _loading = false;
          _highlightedIndex = -1;
        });
      } catch (error) {
        if (!mounted || generation != _generation) return;
        setState(() {
          _loading = false;
          _error = error;
          _highlightedIndex = -1;
        });
      }
    });
  }

  void _validateDependentValue(List<AppOption<V>> options) {
    if (!_validateValueAfterLoad || widget.value == null) return;
    _validateValueAfterLoad = false;
    final valid = options.any(
      (option) => _equals(option.value, widget.value as V),
    );
    if (!valid) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) widget.onChanged?.call(null);
      });
    }
  }

  void _select(AppOption<V> option) {
    if (option.disabled) return;
    _remember([option]);
    widget.onChanged?.call(option.value);
    _setText(
      widget.displayMode == AppComboboxDisplayMode.text ? option.label : '',
    );
    _close();
  }

  void _clear() {
    widget.onChanged?.call(null);
    _setText('');
    _search('');
    _focusNode.requestFocus();
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      _close();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown ||
        event.logicalKey == LogicalKeyboardKey.arrowUp) {
      if (!_overlay.isShowing) _open();
      if (_results.isEmpty) return KeyEventResult.handled;
      final delta = event.logicalKey == LogicalKeyboardKey.arrowDown ? 1 : -1;
      setState(() {
        if (_highlightedIndex < 0) {
          _highlightedIndex = delta > 0 ? 0 : _results.length - 1;
        } else {
          _highlightedIndex = (_highlightedIndex + delta) % _results.length;
          if (_highlightedIndex < 0) _highlightedIndex += _results.length;
        }
      });
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter &&
        _highlightedIndex >= 0 &&
        _highlightedIndex < _results.length) {
      _select(_results[_highlightedIndex]);
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.backspace &&
        widget.displayMode == AppComboboxDisplayMode.token &&
        _textController.text.isEmpty &&
        widget.value != null) {
      _clear();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  Widget? _token(BuildContext context) {
    if (widget.displayMode != AppComboboxDisplayMode.token) return null;
    final option = _selectedOption();
    if (option == null) return null;
    final custom = widget.optionConfig.tokenBuilder;
    if (custom != null) return custom(context, option, _clear);
    return AppInputChipTheme(
      child: shad.Chip(
        trailing: GestureDetector(
          onTap: _clear,
          child: const Icon(shad.LucideIcons.x, size: 14),
        ),
        child: Text(option.label),
      ),
    );
  }

  Widget _buildField(BuildContext context) {
    final theme = shad.Theme.of(context);
    final token = _token(context);
    return Focus(
      onKeyEvent: _handleKey,
      child: AppControlBox(
        child: shad.TextField(
          controller: _textController,
          focusNode: _focusNode,
          enabled: widget.enabled,
          hintText: widget.hintText,
          placeholder: Text(widget.hintText),
          textAlignVertical: TextAlignVertical.center,
          border: Border.all(
            color: theme.colorScheme.border,
            width: 1,
            strokeAlign: BorderSide.strokeAlignInside,
          ),
          padding: EdgeInsets.symmetric(
            horizontal:
                AppTheme.maybeOf(context)?.controls.horizontalPadding ?? 12,
          ),
          features: [
            shad.InputFeature.leading(
              AppInputGroupAddon(child: token ?? const SizedBox.shrink()),
            ),
            shad.InputFeature.trailing(
              AppInputGroupAddon(
                child: SizedBox.square(
                  dimension: 28,
                  child: Center(
                    child: _loading
                        ? const SizedBox.square(
                            dimension: 16,
                            child: shad.CircularProgressIndicator(
                              strokeWidth: 1.5,
                            ),
                          )
                        : widget.clearable && widget.value != null
                        ? shad.IconButton.text(
                            density: shad.ButtonDensity.compact,
                            onPressed: _clear,
                            icon: const Icon(shad.LucideIcons.x, size: 16),
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ),
            ),
          ],
          onChanged: _handleTextChanged,
          onTap: _open,
        ),
      ),
    );
  }

  Widget _buildPopup(BuildContext context) {
    final minimumHeight = widget.options == null
        ? _asyncPopupMinHeight.clamp(0, widget.maxPopupHeight).toDouble()
        : 0.0;
    Widget content;
    if (_loading && _results.isEmpty) {
      content =
          widget.loadingBuilder?.call(context) ??
          const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              shad.LinearProgressIndicator(minHeight: 2),
              Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('正在搜索…')),
              ),
            ],
          );
    } else if (_error case final error?) {
      content =
          widget.errorBuilder?.call(
            context,
            error,
            () => _search(_textController.text, force: true),
          ) ??
          Padding(
            padding: const EdgeInsets.all(12),
            child: shad.OutlineButton(
              onPressed: () => _search(_textController.text, force: true),
              child: const Text('加载失败，点击重试'),
            ),
          );
    } else if (_results.isEmpty) {
      content =
          widget.emptyBuilder?.call(context) ??
          const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: Text('没有匹配的选项')),
          );
    } else {
      content = ListView.builder(
        shrinkWrap: true,
        padding: const EdgeInsets.all(4),
        itemCount: _results.length,
        itemBuilder: (context, index) {
          final option = _results[index];
          final selected =
              widget.value != null && _equals(widget.value as V, option.value);
          final highlighted = index == _highlightedIndex;
          return shad.Button(
            enabled: !option.disabled,
            alignment: AlignmentDirectional.centerStart,
            style: highlighted || selected
                ? const shad.ButtonStyle.secondary()
                : const shad.ButtonStyle.ghost(),
            onPressed: option.disabled ? null : () => _select(option),
            trailing: selected
                ? const Icon(shad.LucideIcons.check, size: 16)
                : null,
            child: widget.optionConfig.buildOption(
              context,
              option,
              AppOptionViewState(
                selected: selected,
                highlighted: highlighted,
                disabled: option.disabled,
                query: _textController.text,
              ),
            ),
          );
        },
      );
    }
    if (_loading && _results.isNotEmpty) {
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const shad.LinearProgressIndicator(minHeight: 2),
          Flexible(fit: FlexFit.loose, child: content),
        ],
      );
    }
    return CompositedTransformFollower(
      link: _layerLink,
      showWhenUnlinked: false,
      offset: Offset(0, _anchorHeight + 6),
      child: Align(
        alignment: Alignment.topLeft,
        child: SizedBox(
          width: _anchorWidth,
          child: AppOverlaySurfaceTheme(
            padding: EdgeInsets.zero,
            child: shad.Card(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: minimumHeight,
                  maxHeight: widget.maxPopupHeight,
                ),
                child: content,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(minWidth: widget.minWidth),
      child: TapRegion(
        groupId: this,
        onTapOutside: (_) {
          _focusNode.unfocus();
          _close();
        },
        child: CompositedTransformTarget(
          link: _layerLink,
          child: OverlayPortal(
            controller: _overlay,
            overlayChildBuilder: (context) =>
                TapRegion(groupId: this, child: _buildPopup(context)),
            child: AppOverlayAnchorTracker(
              onGeometryChanged: _handleAnchorGeometryChanged,
              child: KeyedSubtree(key: _anchorKey, child: _buildField(context)),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    _textController.dispose();
    super.dispose();
  }
}

class AppComboboxFormField<V> extends FormField<V> {
  AppComboboxFormField({
    super.key,
    required List<AppOption<V>> options,
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    AppOption<V>? initialOption,
    String? label,
    String? name,
    String? description,
    String hintText = 'Search and select',
    bool required = false,
    double? width,
    bool clearable = false,
    AppComboboxDisplayMode displayMode = AppComboboxDisplayMode.text,
    AppComboboxEditBehavior editBehavior =
        AppComboboxEditBehavior.retainSelection,
    Object? sourceKey,
    AppDependentValuePolicy dependentValuePolicy =
        AppDependentValuePolicy.clearImmediately,
    ValueChanged<V?>? onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    AppAsyncFieldValidator<V>? asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) => AppFormFieldBinding<V>(
           name: name,
           value: state.value,
           asyncValidator: asyncValidator,
           builder: (context, asyncError) => AppField(
             label: label,
             description: description,
             errorText: state.errorText ?? asyncError,
             required: required,
             width: width,
             child: AppCombobox<V>(
               options: options,
               value: state.value,
               enabled: state.widget.enabled,
               hintText: hintText,
               clearable: clearable,
               displayMode: displayMode,
               editBehavior: editBehavior,
               sourceKey: sourceKey,
               dependentValuePolicy: dependentValuePolicy,
               optionConfig: optionConfig,
               initialOption: initialOption,
               onChanged: (value) {
                 state.didChange(value);
                 onChanged?.call(value);
               },
             ),
           ),
         ),
       );

  AppComboboxFormField.async({
    super.key,
    required AppComboboxSearcher<V> searchOptions,
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    AppOption<V>? initialOption,
    String? label,
    String? name,
    String? description,
    String hintText = 'Search and select',
    bool required = false,
    double? width,
    bool clearable = false,
    AppComboboxDisplayMode displayMode = AppComboboxDisplayMode.text,
    AppComboboxEditBehavior editBehavior =
        AppComboboxEditBehavior.retainSelection,
    Duration debounce = const Duration(milliseconds: 300),
    Duration cacheDuration = const Duration(minutes: 5),
    Object? sourceKey,
    AppDependentValuePolicy dependentValuePolicy =
        AppDependentValuePolicy.clearImmediately,
    ValueChanged<V?>? onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    AppAsyncFieldValidator<V>? asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) => AppFormFieldBinding<V>(
           name: name,
           value: state.value,
           asyncValidator: asyncValidator,
           builder: (context, asyncError) => AppField(
             label: label,
             description: description,
             errorText: state.errorText ?? asyncError,
             required: required,
             width: width,
             child: AppCombobox<V>.async(
               searchOptions: searchOptions,
               value: state.value,
               enabled: state.widget.enabled,
               hintText: hintText,
               clearable: clearable,
               displayMode: displayMode,
               editBehavior: editBehavior,
               debounce: debounce,
               cacheDuration: cacheDuration,
               sourceKey: sourceKey,
               dependentValuePolicy: dependentValuePolicy,
               optionConfig: optionConfig,
               initialOption: initialOption,
               onChanged: (value) {
                 state.didChange(value);
                 onChanged?.call(value);
               },
             ),
           ),
         ),
       );

  AppComboboxFormField.source({
    super.key,
    required AppAsyncOptionSource<V> optionSource,
    AppOptionConfig<V> optionConfig = const AppOptionConfig(),
    AppOption<V>? initialOption,
    String? label,
    String? name,
    String? description,
    String hintText = 'Search and select',
    bool required = false,
    double? width,
    bool clearable = false,
    AppComboboxDisplayMode displayMode = AppComboboxDisplayMode.text,
    AppComboboxEditBehavior editBehavior =
        AppComboboxEditBehavior.retainSelection,
    Duration debounce = const Duration(milliseconds: 300),
    Object? sourceKey,
    AppDependentValuePolicy dependentValuePolicy =
        AppDependentValuePolicy.clearImmediately,
    ValueChanged<V?>? onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    AppAsyncFieldValidator<V>? asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) => AppFormFieldBinding<V>(
           name: name,
           value: state.value,
           asyncValidator: asyncValidator,
           builder: (context, asyncError) => AppField(
             label: label,
             description: description,
             errorText: state.errorText ?? asyncError,
             required: required,
             width: width,
             child: AppCombobox<V>.source(
               optionSource: optionSource,
               value: state.value,
               enabled: state.widget.enabled,
               hintText: hintText,
               clearable: clearable,
               displayMode: displayMode,
               editBehavior: editBehavior,
               debounce: debounce,
               sourceKey: sourceKey,
               dependentValuePolicy: dependentValuePolicy,
               optionConfig: optionConfig,
               initialOption: initialOption,
               onChanged: (value) {
                 state.didChange(value);
                 onChanged?.call(value);
               },
             ),
           ),
         ),
       );
}
