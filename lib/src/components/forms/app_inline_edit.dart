import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_shadcn_scope.dart';
import 'app_checkbox.dart';
import 'app_date_picker.dart';
import 'app_inline_edit_overlay_scope.dart';
import 'app_option.dart';
import 'app_radio_group.dart';
import 'app_select.dart';
import 'app_star_rating.dart';
import 'app_switch.dart';
import 'app_text_area.dart';
import 'app_text_form_field.dart';
import 'app_time_picker.dart';
import 'app_time_stepper_picker.dart';

enum AppInlineEditInvalidBlurBehavior { cancel, keepEditing }

typedef AppInlineEditValidator<T> = String? Function(T value);
typedef AppInlineEditSaver<T> = FutureOr<void> Function(T value);
typedef AppInlineEditEquality<T> = bool Function(T left, T right);
typedef AppInlineEditDisplayBuilder<T> =
    Widget Function(BuildContext context, T value);
typedef AppInlineEditEditorBuilder<T> =
    Widget Function(BuildContext context, AppInlineEditDetails<T> details);

@immutable
class AppInlineEditDetails<T> {
  const AppInlineEditDetails({
    required this.value,
    required this.onChanged,
    required this.submit,
    required this.cancel,
    required this.focusNode,
    required this.saving,
    required this.errorText,
  });

  final T value;
  final ValueChanged<T> onChanged;
  final Future<void> Function() submit;
  final VoidCallback cancel;
  final FocusNode focusNode;
  final bool saving;
  final String? errorText;
}

/// Displays a value normally and swaps in a form control after a double click.
///
/// Every App form control can be hosted through [AppInlineEdit.control]. Common
/// controls also have concise factories such as [text], [select], and [date].
class AppInlineEdit<T> extends StatefulWidget {
  const AppInlineEdit({
    super.key,
    required this.value,
    required this.displayBuilder,
    required this.editorBuilder,
    required this.onSaved,
    this.validator,
    this.enabled = true,
    this.saveOnBlur = true,
    this.invalidBlurBehavior = AppInlineEditInvalidBlurBehavior.cancel,
    this.commitOnChanged = false,
    this.submitOnEnter = false,
    this.activateOnLongPress = true,
    this.onEditingChanged,
    this.errorBuilder,
    this.valuesEqual,
    this.height,
    this.intrinsicHeight = false,
    this.alignment = AlignmentDirectional.centerStart,
    this.transitionDuration = const Duration(milliseconds: 120),
    this.transitionCurve = Curves.easeOut,
    this.width,
    this.expand = true,
  });

  const AppInlineEdit.control({
    super.key,
    required this.value,
    required this.displayBuilder,
    required this.editorBuilder,
    required this.onSaved,
    this.validator,
    this.enabled = true,
    this.saveOnBlur = true,
    this.invalidBlurBehavior = AppInlineEditInvalidBlurBehavior.cancel,
    this.commitOnChanged = false,
    this.submitOnEnter = false,
    this.activateOnLongPress = true,
    this.onEditingChanged,
    this.errorBuilder,
    this.valuesEqual,
    this.height,
    this.intrinsicHeight = false,
    this.alignment = AlignmentDirectional.centerStart,
    this.transitionDuration = const Duration(milliseconds: 120),
    this.transitionCurve = Curves.easeOut,
    this.width,
    this.expand = true,
  });

  /// Convenience host for selection, picker, upload, and other controls that
  /// finish editing by emitting a value from an overlay or direct gesture.
  const AppInlineEdit.immediate({
    super.key,
    required this.value,
    required this.displayBuilder,
    required this.editorBuilder,
    required this.onSaved,
    this.validator,
    this.enabled = true,
    this.invalidBlurBehavior = AppInlineEditInvalidBlurBehavior.cancel,
    this.activateOnLongPress = true,
    this.onEditingChanged,
    this.errorBuilder,
    this.valuesEqual,
    this.height,
    this.intrinsicHeight = false,
    this.alignment = AlignmentDirectional.centerStart,
    this.transitionDuration = const Duration(milliseconds: 120),
    this.transitionCurve = Curves.easeOut,
    this.width,
    this.expand = true,
  }) : saveOnBlur = true,
       commitOnChanged = true,
       submitOnEnter = false;

  static AppInlineEdit<String> text({
    Key? key,
    required String value,
    required AppInlineEditSaver<String> onSaved,
    AppInlineEditDisplayBuilder<String>? displayBuilder,
    AppInlineEditValidator<String>? validator,
    String? hintText,
    bool enabled = true,
    bool obscureText = false,
    int? maxLength,
    AppInlineEditInvalidBlurBehavior invalidBlurBehavior =
        AppInlineEditInvalidBlurBehavior.cancel,
  }) {
    return AppInlineEdit<String>(
      key: key,
      value: value,
      displayBuilder: displayBuilder ?? (_, value) => Text(value),
      validator: validator,
      enabled: enabled,
      invalidBlurBehavior: invalidBlurBehavior,
      submitOnEnter: true,
      onSaved: onSaved,
      editorBuilder: (context, details) => _InlineTextEditor(
        details: details,
        hintText: hintText,
        obscureText: obscureText,
        maxLength: maxLength,
      ),
    );
  }

  static AppInlineEdit<String> multiline({
    Key? key,
    required String value,
    required AppInlineEditSaver<String> onSaved,
    AppInlineEditDisplayBuilder<String>? displayBuilder,
    AppInlineEditValidator<String>? validator,
    String? hintText,
    double minHeight = 72,
    double maxHeight = 240,
    bool enabled = true,
  }) {
    return AppInlineEdit<String>(
      key: key,
      value: value,
      displayBuilder: displayBuilder ?? (_, value) => Text(value),
      validator: validator,
      enabled: enabled,
      intrinsicHeight: true,
      onSaved: onSaved,
      editorBuilder: (context, details) => _InlineTextAreaEditor(
        details: details,
        hintText: hintText,
        minHeight: minHeight,
        maxHeight: maxHeight,
      ),
    );
  }

  static AppInlineEdit<int> number({
    Key? key,
    required int value,
    required AppInlineEditSaver<int> onSaved,
    AppInlineEditDisplayBuilder<int>? displayBuilder,
    AppInlineEditValidator<int>? validator,
    int min = 0,
    int max = 999999,
    int step = 1,
    double width = 120,
    bool enabled = true,
  }) {
    return AppInlineEdit<int>(
      key: key,
      value: value,
      displayBuilder: displayBuilder ?? (_, value) => Text('$value'),
      validator: validator,
      enabled: enabled,
      onSaved: onSaved,
      editorBuilder: (context, details) => AppNumberInput(
        value: details.value,
        onChanged: details.onChanged,
        onSubmitted: (_) => details.submit(),
        onCancel: details.cancel,
        min: min,
        max: max,
        step: step,
        width: width,
        enabled: !details.saving,
      ),
    );
  }

  static AppInlineEdit<V?> select<V>({
    Key? key,
    required V? value,
    required List<AppOption<V>> options,
    required AppInlineEditSaver<V?> onSaved,
    AppInlineEditDisplayBuilder<V?>? displayBuilder,
    AppInlineEditValidator<V?>? validator,
    String hintText = 'Select an option',
    bool clearable = false,
    bool enabled = true,
  }) {
    Widget defaultDisplay(BuildContext context, V? value) {
      if (value == null) return Text(hintText);
      for (final option in options) {
        if (option.value == value) return option.child ?? Text(option.label);
      }
      return Text('$value');
    }

    return AppInlineEdit<V?>(
      key: key,
      value: value,
      displayBuilder: displayBuilder ?? defaultDisplay,
      validator: validator,
      enabled: enabled,
      saveOnBlur: true,
      commitOnChanged: true,
      onSaved: onSaved,
      editorBuilder: (context, details) => AppSelect<V>(
        options: options,
        value: details.value,
        onChanged: details.onChanged,
        hintText: hintText,
        clearable: clearable,
        enabled: !details.saving,
      ),
    );
  }

  static AppInlineEdit<DateTime?> date({
    Key? key,
    required DateTime? value,
    required AppInlineEditSaver<DateTime?> onSaved,
    AppInlineEditDisplayBuilder<DateTime?>? displayBuilder,
    AppInlineEditValidator<DateTime?>? validator,
    String? hintText,
    bool enabled = true,
  }) {
    return AppInlineEdit<DateTime?>(
      key: key,
      value: value,
      displayBuilder:
          displayBuilder ??
          (_, value) =>
              Text(value == null ? hintText ?? '-' : _formatDate(value)),
      validator: validator,
      enabled: enabled,
      saveOnBlur: true,
      commitOnChanged: true,
      onSaved: onSaved,
      editorBuilder: (context, details) => AppDatePicker(
        value: details.value,
        onChanged: details.onChanged,
        hintText: hintText,
        enabled: !details.saving,
      ),
    );
  }

  static AppInlineEdit<shad.TimeOfDay?> time({
    Key? key,
    required shad.TimeOfDay? value,
    required AppInlineEditSaver<shad.TimeOfDay?> onSaved,
    AppInlineEditDisplayBuilder<shad.TimeOfDay?>? displayBuilder,
    AppInlineEditValidator<shad.TimeOfDay?>? validator,
    String? hintText,
    bool enabled = true,
  }) {
    return AppInlineEdit<shad.TimeOfDay?>(
      key: key,
      value: value,
      displayBuilder:
          displayBuilder ??
          (_, value) =>
              Text(value == null ? hintText ?? '-' : _formatTime(value)),
      validator: validator,
      enabled: enabled,
      saveOnBlur: true,
      commitOnChanged: true,
      onSaved: onSaved,
      editorBuilder: (context, details) => AppTimePicker(
        value: details.value,
        onChanged: details.onChanged,
        hintText: hintText,
        enabled: !details.saving,
      ),
    );
  }

  static AppInlineEdit<bool> switchValue({
    Key? key,
    required bool value,
    required AppInlineEditSaver<bool> onSaved,
    AppInlineEditDisplayBuilder<bool>? displayBuilder,
    bool enabled = true,
  }) {
    return AppInlineEdit<bool>(
      key: key,
      value: value,
      displayBuilder: displayBuilder ?? (_, value) => Text(value ? '是' : '否'),
      enabled: enabled,
      saveOnBlur: true,
      commitOnChanged: true,
      onSaved: onSaved,
      editorBuilder: (context, details) => AppSwitch(
        value: details.value,
        onChanged: details.saving ? null : details.onChanged,
      ),
    );
  }

  static AppInlineEdit<bool> checkbox({
    Key? key,
    required bool value,
    required AppInlineEditSaver<bool> onSaved,
    AppInlineEditDisplayBuilder<bool>? displayBuilder,
    bool enabled = true,
  }) {
    return AppInlineEdit<bool>(
      key: key,
      value: value,
      displayBuilder: displayBuilder ?? (_, value) => Text(value ? '是' : '否'),
      enabled: enabled,
      saveOnBlur: true,
      commitOnChanged: true,
      onSaved: onSaved,
      editorBuilder: (context, details) => AppCheckbox(
        state: details.value
            ? shad.CheckboxState.checked
            : shad.CheckboxState.unchecked,
        onChanged: details.saving
            ? null
            : (state) => details.onChanged(state == shad.CheckboxState.checked),
      ),
    );
  }

  static AppInlineEdit<V> radio<V>({
    Key? key,
    required V value,
    required List<AppOption<V>> options,
    required AppInlineEditSaver<V> onSaved,
    AppInlineEditDisplayBuilder<V>? displayBuilder,
    bool enabled = true,
  }) {
    Widget defaultDisplay(BuildContext context, V value) {
      for (final option in options) {
        if (option.value == value) return option.child ?? Text(option.label);
      }
      return Text('$value');
    }

    return AppInlineEdit<V>(
      key: key,
      value: value,
      displayBuilder: displayBuilder ?? defaultDisplay,
      enabled: enabled,
      saveOnBlur: true,
      commitOnChanged: true,
      onSaved: onSaved,
      editorBuilder: (context, details) => AppRadioGroup<V>(
        options: options,
        value: details.value,
        onChanged: details.saving ? null : details.onChanged,
      ),
    );
  }

  static AppInlineEdit<double> starRating({
    Key? key,
    required double value,
    required AppInlineEditSaver<double> onSaved,
    AppInlineEditDisplayBuilder<double>? displayBuilder,
    double max = 5,
    double step = .5,
    bool enabled = true,
  }) {
    return AppInlineEdit<double>(
      key: key,
      value: value,
      displayBuilder: displayBuilder ?? (_, value) => Text('$value / $max'),
      enabled: enabled,
      saveOnBlur: true,
      onSaved: onSaved,
      editorBuilder: (context, details) =>
          _InlineStarRatingEditor(details: details, max: max, step: step),
    );
  }

  final T value;
  final AppInlineEditDisplayBuilder<T> displayBuilder;
  final AppInlineEditEditorBuilder<T> editorBuilder;
  final AppInlineEditSaver<T> onSaved;
  final AppInlineEditValidator<T>? validator;
  final bool enabled;
  final bool saveOnBlur;
  final AppInlineEditInvalidBlurBehavior invalidBlurBehavior;
  final bool commitOnChanged;
  final bool submitOnEnter;
  final bool activateOnLongPress;
  final ValueChanged<bool>? onEditingChanged;
  final Widget Function(BuildContext context, String message)? errorBuilder;
  final AppInlineEditEquality<T>? valuesEqual;

  /// Stable height shared by display and edit states. When omitted, this uses
  /// the same control-height token as the rest of the form components.
  final double? height;

  /// Lets multiline and other large controls determine their own height.
  final bool intrinsicHeight;
  final AlignmentGeometry alignment;
  final Duration transitionDuration;
  final Curve transitionCurve;
  final double? width;
  final bool expand;

  @override
  State<AppInlineEdit<T>> createState() => _AppInlineEditState<T>();
}

class _AppInlineEditState<T> extends State<AppInlineEdit<T>> {
  final FocusNode _editorFocusNode = FocusNode();
  late final AppInlineEditOverlayController _overlayController;
  bool _editing = false;
  bool _saving = false;
  bool _editorHasFocus = false;
  late T _draft;
  late T _displayValue;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _draft = widget.value;
    _displayValue = widget.value;
    _overlayController = AppInlineEditOverlayController(
      onClosed: _handleOverlayClosed,
    );
  }

  @override
  void didUpdateWidget(covariant AppInlineEdit<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_editing && oldWidget.value != widget.value) {
      _draft = widget.value;
      _displayValue = widget.value;
    }
  }

  @override
  void dispose() {
    _editorFocusNode.dispose();
    super.dispose();
  }

  void _beginEditing() {
    if (!widget.enabled || _editing) return;
    setState(() {
      _draft = _displayValue;
      _errorText = null;
      _editing = true;
    });
    widget.onEditingChanged?.call(true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _editorFocusNode.requestFocus();
    });
  }

  void _cancel() {
    if (!_editing || _saving) return;
    setState(() {
      _draft = _displayValue;
      _errorText = null;
      _editing = false;
    });
    widget.onEditingChanged?.call(false);
  }

  void _change(T value) {
    // Gesture-based controls can emit a final cancel/end callback while their
    // outgoing editor is being removed by AnimatedSwitcher. Ignore that late
    // event once editing has already finished to avoid setState during the
    // framework's locked disposal phase.
    if (!_editing || _saving) return;
    setState(() {
      _draft = value;
      _errorText = null;
    });
    if (widget.commitOnChanged) unawaited(_commit());
  }

  Future<void> _commit({bool fromBlur = false}) async {
    if (!_editing || _saving) return;
    if ((widget.valuesEqual ?? _defaultEquals)(_draft, _displayValue)) {
      setState(() {
        _draft = _displayValue;
        _errorText = null;
        _editing = false;
      });
      widget.onEditingChanged?.call(false);
      return;
    }
    final error = widget.validator?.call(_draft);
    if (error != null) {
      if (fromBlur &&
          widget.invalidBlurBehavior ==
              AppInlineEditInvalidBlurBehavior.cancel) {
        _cancel();
      } else {
        setState(() => _errorText = error);
        _editorFocusNode.requestFocus();
      }
      return;
    }

    setState(() {
      _saving = true;
      _errorText = null;
    });
    try {
      await widget.onSaved(_draft);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _editing = false;
        _displayValue = _draft;
      });
      widget.onEditingChanged?.call(false);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _errorText = error.toString();
      });
      _editorFocusNode.requestFocus();
    }
  }

  void _handleFocusChange(bool focused) {
    _editorHasFocus = focused;
    if (focused) return;
    if (!widget.saveOnBlur || _saving) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_editing || _editorHasFocus) return;
      if (!_overlayController.hasOpenOverlay) {
        unawaited(_commit(fromBlur: true));
      }
    });
  }

  void _handleOverlayClosed() {
    if (!widget.saveOnBlur || !mounted || !_editing) return;
    // Popup surfaces report disposal from a post-frame callback already.
    // Deferring again can leave the commit waiting forever when no new frame
    // is scheduled after the overlay disappears.
    unawaited(_commit(fromBlur: true));
  }

  @override
  Widget build(BuildContext context) {
    if (!_editing) {
      final display = Semantics(
        button: widget.enabled,
        enabled: widget.enabled,
        label: widget.enabled ? '双击编辑' : null,
        child: MouseRegion(
          cursor: widget.enabled
              ? SystemMouseCursors.click
              : SystemMouseCursors.basic,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onDoubleTap: widget.enabled ? _beginEditing : null,
            onLongPress: widget.enabled && widget.activateOnLongPress
                ? _beginEditing
                : null,
            child: widget.displayBuilder(context, _displayValue),
          ),
        ),
      );
      return _transition(
        editing: false,
        child: _fixedArea(display, stretchChild: false),
      );
    }

    final details = AppInlineEditDetails<T>(
      value: _draft,
      onChanged: _change,
      submit: _commit,
      cancel: _cancel,
      focusNode: _editorFocusNode,
      saving: _saving,
      errorText: _errorText,
    );
    final theme = shad.Theme.of(context);
    final editor = AppInlineEditOverlayScope(
      controller: _overlayController,
      child: Focus(
        autofocus: true,
        onFocusChange: _handleFocusChange,
        child: widget.editorBuilder(context, details),
      ),
    );

    final editingContent = CallbackShortcuts(
      bindings: {
        const SingleActivator(LogicalKeyboardKey.escape): _cancel,
        if (widget.submitOnEnter)
          const SingleActivator(LogicalKeyboardKey.enter): () => _commit(),
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TapRegion(
            onTapOutside: (_) {
              if (!widget.saveOnBlur ||
                  _saving ||
                  _overlayController.hasOpenOverlay) {
                return;
              }
              unawaited(_commit(fromBlur: true));
            },
            child: _fixedArea(
              IgnorePointer(ignoring: _saving, child: editor),
              stretchChild: true,
            ),
          ),
          if (_errorText case final error?) ...[
            const SizedBox(height: 4),
            widget.errorBuilder?.call(context, error) ??
                Text(
                  error,
                  style: theme.typography.small.copyWith(
                    color: theme.colorScheme.destructive,
                  ),
                ),
          ],
        ],
      ),
    );
    return _transition(editing: true, child: editingContent);
  }

  Widget _transition({required bool editing, required Widget child}) {
    return AnimatedSwitcher(
      duration: widget.transitionDuration,
      switchInCurve: widget.transitionCurve,
      switchOutCurve: widget.transitionCurve,
      transitionBuilder: (child, animation) =>
          FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(key: ValueKey(editing), child: child),
    );
  }

  Widget _fixedArea(Widget child, {required bool stretchChild}) {
    final resolvedWidth =
        widget.width ?? (widget.expand ? double.infinity : null);
    final content = stretchChild && resolvedWidth != null
        ? child
        : Align(alignment: widget.alignment, child: child);
    if (widget.intrinsicHeight) {
      return SizedBox(width: resolvedWidth, child: content);
    }
    final height =
        widget.height ?? AppTheme.maybeOf(context)?.controls.height ?? 32;
    return SizedBox(width: resolvedWidth, height: height, child: content);
  }
}

bool _defaultEquals<T>(T left, T right) => left == right;

class _InlineTextEditor extends StatefulWidget {
  const _InlineTextEditor({
    required this.details,
    this.hintText,
    this.obscureText = false,
    this.maxLength,
  });

  final AppInlineEditDetails<String> details;
  final String? hintText;
  final bool obscureText;
  final int? maxLength;

  @override
  State<_InlineTextEditor> createState() => _InlineTextEditorState();
}

class _InlineTextEditorState extends State<_InlineTextEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.details.value);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextFormField(
      controller: _controller,
      focusNode: widget.details.focusNode,
      autofocus: true,
      hintText: widget.hintText,
      obscureText: widget.obscureText,
      maxLength: widget.maxLength,
      enabled: !widget.details.saving,
      onChanged: widget.details.onChanged,
      onSubmitted: (_) => widget.details.submit(),
    );
  }
}

class _InlineTextAreaEditor extends StatefulWidget {
  const _InlineTextAreaEditor({
    required this.details,
    required this.minHeight,
    required this.maxHeight,
    this.hintText,
  });

  final AppInlineEditDetails<String> details;
  final String? hintText;
  final double minHeight;
  final double maxHeight;

  @override
  State<_InlineTextAreaEditor> createState() => _InlineTextAreaEditorState();
}

class _InlineTextAreaEditorState extends State<_InlineTextAreaEditor> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.details.value);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppTextAreaFormField(
      controller: _controller,
      focusNode: widget.details.focusNode,
      hintText: widget.hintText,
      expandableHeight: true,
      minHeight: widget.minHeight,
      maxHeight: widget.maxHeight,
      enabled: !widget.details.saving,
      onChanged: widget.details.onChanged,
    );
  }
}

class _InlineStarRatingEditor extends StatefulWidget {
  const _InlineStarRatingEditor({
    required this.details,
    required this.max,
    required this.step,
  });

  final AppInlineEditDetails<double> details;
  final double max;
  final double step;

  @override
  State<_InlineStarRatingEditor> createState() =>
      _InlineStarRatingEditorState();
}

class _InlineStarRatingEditorState extends State<_InlineStarRatingEditor> {
  Timer? _submitTimer;

  @override
  void dispose() {
    _submitTimer?.cancel();
    super.dispose();
  }

  void _handleChanged(double value) {
    widget.details.onChanged(value);
    _submitTimer?.cancel();
    // StarRating emits intermediate values while its drag gesture is active.
    // Submit only the last settled value instead of the first pointer update.
    _submitTimer = Timer(const Duration(milliseconds: 180), () {
      widget.details.submit();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AppStarRating(
      value: widget.details.value,
      onChanged: widget.details.saving ? null : _handleChanged,
      max: widget.max,
      step: widget.step,
    );
  }
}

String _formatDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

String _formatTime(shad.TimeOfDay value) =>
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';
