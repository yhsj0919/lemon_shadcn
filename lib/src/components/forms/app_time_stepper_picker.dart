import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../../foundation/app_control_box.dart';
import '../../foundation/app_interactive_style.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_prompt_control_frame.dart';

/// A popover time picker with coarse outer controls and precise inner arrows.
class AppTimeStepperPicker extends StatelessWidget {
  const AppTimeStepperPicker({
    super.key,
    required this.value,
    this.onChanged,
    this.minuteStep = 5,
    this.mode = shad.PromptMode.popover,
    this.hintText,
    this.enabled = true,
  }) : assert(minuteStep > 0 && minuteStep <= 59);

  final shad.TimeOfDay? value;
  final ValueChanged<shad.TimeOfDay?>? onChanged;
  final int minuteStep;
  final shad.PromptMode mode;
  final String? hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final localizations = shad.ShadcnLocalizations.of(context);
    final picker = shad.ObjectFormField<shad.TimeOfDay>(
      value: value,
      enabled: enabled,
      mode: mode,
      popoverPadding: EdgeInsets.zero,
      placeholder: Text(hintText ?? localizations.placeholderTimePicker),
      trailing: const Icon(shad.LucideIcons.clock),
      onChanged: onChanged,
      immediateValueChange: false,
      builder: (context, value) =>
          Text(localizations.formatTimeOfDay(value, use24HourFormat: true)),
      editorBuilder: (context, handler) => _AppTimeStepperEditor(
        initialValue: handler.value,
        minuteStep: minuteStep,
        handler: handler,
      ),
    );
    return AppControlBox(
      child: AppPromptControlFrame(enabled: enabled, child: picker),
    );
  }
}

/// A single field that edits the calendar date and time in one popover.
class AppDateTimePicker extends StatelessWidget {
  const AppDateTimePicker({
    super.key,
    required this.value,
    this.onChanged,
    this.minuteStep = 5,
    this.mode = shad.PromptMode.popover,
    this.hintText,
    this.enabled = true,
  }) : assert(minuteStep > 0 && minuteStep <= 59);

  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final int minuteStep;
  final shad.PromptMode mode;
  final String? hintText;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final picker = shad.ObjectFormField<DateTime>(
      value: value,
      onChanged: onChanged,
      enabled: enabled,
      mode: mode,
      immediateValueChange: false,
      popoverPadding: EdgeInsets.zero,
      placeholder: Text(hintText ?? '选择日期和时间'),
      trailing: const Icon(shad.LucideIcons.calendarClock),
      builder: (context, value) => Text(_formatDateTime(value)),
      editorBuilder: (context, handler) =>
          _AppDateTimeEditor(handler: handler, minuteStep: minuteStep),
    );
    return AppControlBox(
      child: AppPromptControlFrame(enabled: enabled, child: picker),
    );
  }
}

String _formatDateTime(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')} '
    '${value.hour.toString().padLeft(2, '0')}:'
    '${value.minute.toString().padLeft(2, '0')}';

class _AppDateTimeEditor extends StatefulWidget {
  const _AppDateTimeEditor({required this.handler, required this.minuteStep});

  final shad.ObjectFormHandler<DateTime> handler;
  final int minuteStep;

  @override
  State<_AppDateTimeEditor> createState() => _AppDateTimeEditorState();
}

class _AppDateTimeEditorState extends State<_AppDateTimeEditor> {
  late final DateTime? _initialValue = widget.handler.value;
  late DateTime _value = _initialValue ?? DateTime.now();

  void _setDate(DateTime date) {
    setState(() {
      _value = DateTime(
        date.year,
        date.month,
        date.day,
        _value.hour,
        _value.minute,
      );
    });
  }

  void _setTime(shad.TimeOfDay time) {
    _value = DateTime(
      _value.year,
      _value.month,
      _value.day,
      time.hour,
      time.minute,
    );
  }

  void _clear() {
    widget.handler.value = null;
    widget.handler.close();
  }

  void _cancel() {
    widget.handler.value = _initialValue;
    widget.handler.close();
  }

  void _confirm([shad.TimeOfDay? time]) {
    if (time != null) _setTime(time);
    widget.handler.value = _value;
    widget.handler.close();
  }

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            shad.DatePickerDialog(
              selectionMode: shad.CalendarSelectionMode.single,
              initialViewType: shad.CalendarViewType.date,
              initialValue: shad.CalendarValue.single(_value),
              onChanged: (value) {
                if (value case shad.SingleCalendarValue(:final date)) {
                  _setDate(date);
                }
              },
            ),
            const SizedBox(height: 8),
            Align(
              child: _AppTimeStepperEditor(
                initialValue: shad.TimeOfDay(
                  hour: _value.hour,
                  minute: _value.minute,
                ),
                minuteStep: widget.minuteStep,
                showActions: false,
                onChanged: _setTime,
                onCancel: _cancel,
                onConfirm: _confirm,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                AppButton.text(onPressed: _clear, child: const Text('清空')),
                const Spacer(),
                AppButton.outline(onPressed: _cancel, child: const Text('取消')),
                const SizedBox(width: 8),
                AppButton.primary(onPressed: _confirm, child: const Text('确定')),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AppTimeStepperEditor extends StatefulWidget {
  const _AppTimeStepperEditor({
    required this.initialValue,
    required this.minuteStep,
    this.handler,
    this.onChanged,
    this.onCancel,
    this.onConfirm,
    this.showActions = true,
  });

  final shad.TimeOfDay? initialValue;
  final int minuteStep;
  final shad.ObjectFormHandler<shad.TimeOfDay>? handler;
  final ValueChanged<shad.TimeOfDay>? onChanged;
  final VoidCallback? onCancel;
  final ValueChanged<shad.TimeOfDay>? onConfirm;
  final bool showActions;

  @override
  State<_AppTimeStepperEditor> createState() => _AppTimeStepperEditorState();
}

class _AppTimeStepperEditorState extends State<_AppTimeStepperEditor> {
  late shad.TimeOfDay _value =
      widget.initialValue ?? const shad.TimeOfDay(hour: 0, minute: 0);

  void _setHour(int value) {
    if (value >= 0 && value <= 23) {
      _setValue(shad.TimeOfDay(hour: value, minute: _value.minute));
    }
  }

  void _setMinute(int value) {
    if (value >= 0 && value <= 59) {
      _setValue(shad.TimeOfDay(hour: _value.hour, minute: value));
    }
  }

  void _setValue(shad.TimeOfDay value) {
    if (_value == value) return;
    setState(() => _value = value);
    widget.onChanged?.call(value);
  }

  void _clear() {
    widget.handler?.value = null;
    widget.handler?.close();
  }

  void _cancel() {
    if (widget.onCancel case final callback?) return callback();
    widget.handler?.value = widget.initialValue;
    widget.handler?.close();
  }

  void _confirm() {
    if (widget.onConfirm case final callback?) return callback(_value);
    widget.handler?.value = _value;
    widget.handler?.close();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return IntrinsicWidth(
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _TimeUnitControl(
                      label: '时',
                      value: _value.hour,
                      maxValue: 23,
                      coarseStep: 5,
                      onInput: _setHour,
                      onConfirm: _confirm,
                      onCancel: _cancel,
                    ),
                    const SizedBox(width: 12),
                    SizedBox(
                      width: 24,
                      height: 44,
                      child: Center(child: const Text(':').x3Large()),
                    ),
                    const SizedBox(width: 12),
                    _TimeUnitControl(
                      label: '分',
                      value: _value.minute,
                      maxValue: 59,
                      coarseStep: widget.minuteStep,
                      onInput: _setMinute,
                      onConfirm: _confirm,
                      onCancel: _cancel,
                    ),
                  ],
                ),
                if (widget.showActions) ...[
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      AppButton.text(
                        onPressed: _clear,
                        child: const Text('清空'),
                      ),
                      const Spacer(),
                      AppButton.outline(
                        onPressed: _cancel,
                        child: const Text('取消'),
                      ),
                      const SizedBox(width: 8),
                      AppButton.primary(
                        onPressed: _confirm,
                        child: const Text('确定'),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Positioned(
            bottom: widget.showActions ? 60 : 0,
            right: 12,
            child: shad.Tooltip(
              tooltip: (context) => const shad.TooltipContainer(
                child: Text('↑↓ 调整 1，按住 Shift 调整 5'),
              ),
              child: Icon(
                shad.LucideIcons.circleHelp,
                size: 14,
                color: theme.colorScheme.mutedForeground.withValues(
                  alpha: 0.65,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeUnitControl extends StatelessWidget {
  const _TimeUnitControl({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.coarseStep,
    required this.onInput,
    required this.onConfirm,
    required this.onCancel,
  });

  final String label;
  final int value;
  final int maxValue;
  final int coarseStep;
  final ValueChanged<int> onInput;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppNumberInput(
            value: value,
            min: 0,
            max: maxValue,
            shiftStep: coarseStep,
            wrap: true,
            digits: 2,
            width: 72,
            variant: AppNumberInputVariant.compact,
            onChanged: onInput,
            onSubmitted: (_) => onConfirm(),
            onCancel: onCancel,
          ),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerLeft, child: Text(label).muted()),
        ],
      ),
    );
  }
}

/// Controlled integer input with mouse and keyboard step controls.
enum AppNumberInputVariant { form, compact }

class AppNumberInput extends StatelessWidget {
  const AppNumberInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.min = 0,
    this.max = 999999,
    this.step = 1,
    this.shiftStep = 5,
    this.wrap = false,
    this.digits,
    this.width = 120,
    this.variant = AppNumberInputVariant.form,
    this.enabled = true,
    this.onSubmitted,
    this.onCancel,
  }) : assert(min <= max),
       assert(step > 0),
       assert(shiftStep > 0);

  final int value;
  final ValueChanged<int> onChanged;
  final int min;
  final int max;
  final int step;
  final int shiftStep;
  final bool wrap;
  final int? digits;
  final double width;
  final AppNumberInputVariant variant;
  final bool enabled;
  final ValueChanged<int>? onSubmitted;
  final VoidCallback? onCancel;

  int _normalize(int value) {
    if (!wrap) return value.clamp(min, max);
    final range = max - min + 1;
    return min + ((value - min) % range + range) % range;
  }

  void _change(int delta) => onChanged(_normalize(value + delta));

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: _TimeValueBox(
        value: value,
        minValue: min,
        maxValue: max,
        step: step,
        coarseStep: shiftStep,
        wrap: wrap,
        digits: digits,
        variant: variant,
        enabled: enabled,
        onIncrease: () => _change(step),
        onDecrease: () => _change(-step),
        onCoarseIncrease: () => _change(shiftStep),
        onCoarseDecrease: () => _change(-shiftStep),
        onInput: (value) => onChanged(_normalize(value)),
        onConfirm: () => onSubmitted?.call(value),
        onCancel: onCancel ?? () {},
      ),
    );
  }
}

class _TimeValueBox extends StatefulWidget {
  const _TimeValueBox({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.step,
    required this.coarseStep,
    required this.wrap,
    required this.enabled,
    required this.variant,
    required this.onIncrease,
    required this.onDecrease,
    required this.onCoarseIncrease,
    required this.onCoarseDecrease,
    required this.onInput,
    required this.onConfirm,
    required this.onCancel,
    this.digits,
  });

  final int value;
  final int minValue;
  final int maxValue;
  final int step;
  final int coarseStep;
  final bool wrap;
  final bool enabled;
  final AppNumberInputVariant variant;
  final int? digits;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final VoidCallback onCoarseIncrease;
  final VoidCallback onCoarseDecrease;
  final ValueChanged<int> onInput;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  State<_TimeValueBox> createState() => _TimeValueBoxState();
}

class _TimeValueBoxState extends State<_TimeValueBox> {
  late final TextEditingController _controller = TextEditingController();
  late final FocusNode _focusNode = FocusNode(onKeyEvent: _handleKey)
    ..addListener(_handleFocus);

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_TimeValueBox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && !_focusNode.hasFocus) _sync();
  }

  void _sync() {
    _controller.text = _format(widget.value);
  }

  String _format(int value) => widget.digits == null
      ? value.toString()
      : value.toString().padLeft(widget.digits!, '0');

  void _handleFocus() {
    if (_focusNode.hasFocus) {
      _controller.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _controller.text.length,
      );
    } else {
      _submit(_controller.text);
      _sync();
    }
  }

  void _submit(String text) {
    final parsed = int.tryParse(text);
    if (parsed == null) return;
    final normalized = parsed.clamp(widget.minValue, widget.maxValue);
    widget.onInput(normalized);
    _controller.text = _format(normalized);
    _controller.selection = TextSelection.collapsed(
      offset: _controller.text.length,
    );
  }

  KeyEventResult _handleKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
      return KeyEventResult.ignored;
    }
    final coarse = HardwareKeyboard.instance.isShiftPressed;
    if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
      _runStep(
        coarse ? widget.onCoarseIncrease : widget.onIncrease,
        coarse ? widget.coarseStep : widget.step,
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _runStep(
        coarse ? widget.onCoarseDecrease : widget.onDecrease,
        coarse ? -widget.coarseStep : -widget.step,
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.enter ||
        event.logicalKey == LogicalKeyboardKey.numpadEnter) {
      _submit(_controller.text);
      widget.onConfirm();
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.escape) {
      widget.onCancel();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  void _runStep(VoidCallback callback, int delta) {
    if (!widget.enabled) return;
    callback();
    final raw = widget.value + delta;
    final next = widget.wrap
        ? widget.minValue +
              ((raw - widget.minValue) %
                          (widget.maxValue - widget.minValue + 1) +
                      (widget.maxValue - widget.minValue + 1)) %
                  (widget.maxValue - widget.minValue + 1)
        : raw.clamp(widget.minValue, widget.maxValue);
    _controller.text = _format(next);
    _controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: _controller.text.length,
    );
  }

  void _runPointerStep({required bool increase}) {
    final coarse = HardwareKeyboard.instance.isShiftPressed;
    final callback = increase
        ? (coarse ? widget.onCoarseIncrease : widget.onIncrease)
        : (coarse ? widget.onCoarseDecrease : widget.onDecrease);
    final amount = coarse ? widget.coarseStep : widget.step;
    _runStep(callback, increase ? amount : -amount);
  }

  @override
  void dispose() {
    _focusNode
      ..removeListener(_handleFocus)
      ..dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final compact = widget.variant == AppNumberInputVariant.compact;
    final content = Stack(
      children: [
        Positioned.fill(
          child: shad.TextField(
            border: Border.all(
              color: theme.colorScheme.border,
              width: 1,
              strokeAlign: BorderSide.strokeAlignInside,
            ),
            controller: _controller,
            focusNode: _focusNode,
            enabled: widget.enabled,
            maxLength: widget.digits,
            maxLines: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: compact ? TextAlign.center : TextAlign.left,
            textAlignVertical: TextAlignVertical.center,
            padding: EdgeInsets.only(
              left: compact ? 0 : 12,
              right: compact ? 18 : 34,
            ),
            style: compact ? theme.typography.x2Large : theme.typography.base,
            onChanged: (text) {
              if (compact) {
                if (text.length == widget.digits) _submit(text);
              } else if (int.tryParse(text) != null) {
                _submit(text);
              }
            },
            onSubmitted: _submit,
          ),
        ),
        Positioned(
          top: 1,
          right: 1,
          bottom: 1,
          width: compact ? 24 : 30,
          child: Column(
            children: [
              Expanded(
                child: AppInkWell(
                  enabled: widget.enabled,
                  onPressed: () => _runPointerStep(increase: true),
                  borderRadius: BorderRadius.zero,
                  child: const Center(
                    child: Icon(shad.LucideIcons.chevronUp, size: 12),
                  ),
                ),
              ),
              SizedBox(
                height: 1,
                child: ColoredBox(color: theme.colorScheme.border),
              ),
              Expanded(
                child: AppInkWell(
                  enabled: widget.enabled,
                  onPressed: () => _runPointerStep(increase: false),
                  borderRadius: BorderRadius.zero,
                  child: const Center(
                    child: Icon(shad.LucideIcons.chevronDown, size: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    return compact
        ? SizedBox(height: 44, child: content)
        : AppControlBox(child: content);
  }
}

class AppNumberInputFormField extends FormField<int> {
  AppNumberInputFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.min = 0,
    this.max = 999999,
    this.step = 1,
    this.shiftStep = 5,
    this.wrap = false,
    this.digits,
    this.inputWidth = 120,
    this.onChanged,
    super.initialValue = 0,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : assert(min <= max),
       super(
         builder: (state) {
           final field = state.widget as AppNumberInputFormField;
           return AppFormFieldBinding<int>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppNumberInput(
                 value: state.value ?? field.min,
                 min: field.min,
                 max: field.max,
                 step: field.step,
                 shiftStep: field.shiftStep,
                 wrap: field.wrap,
                 digits: field.digits,
                 width: field.inputWidth,
                 enabled: field.enabled,
                 onChanged: (value) {
                   state.didChange(value);
                   field.onChanged?.call(value);
                 },
               ),
             ),
           );
         },
       );

  final String? name;
  final String? label;
  final String? description;
  final bool required;
  final double? width;
  final int min;
  final int max;
  final int step;
  final int shiftStep;
  final bool wrap;
  final int? digits;
  final double inputWidth;
  final ValueChanged<int>? onChanged;
  final AppAsyncFieldValidator<int>? asyncValidator;
}

class AppDateTimePickerFormField extends FormField<DateTime> {
  AppDateTimePickerFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.minuteStep = 5,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppDateTimePickerFormField;
           return AppFormFieldBinding<DateTime>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppDateTimePicker(
                 value: state.value,
                 minuteStep: field.minuteStep,
                 enabled: field.enabled,
                 onChanged: (value) {
                   state.didChange(value);
                   field.onChanged?.call(value);
                 },
               ),
             ),
           );
         },
       );

  final String? name;
  final String? label;
  final String? description;
  final bool required;
  final double? width;
  final int minuteStep;
  final ValueChanged<DateTime?>? onChanged;
  final AppAsyncFieldValidator<DateTime>? asyncValidator;
}

class AppTimeStepperPickerFormField extends FormField<shad.TimeOfDay> {
  AppTimeStepperPickerFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.minuteStep = 5,
    this.onChanged,
    super.initialValue = const shad.TimeOfDay(hour: 9, minute: 0),
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppTimeStepperPickerFormField;
           return AppFormFieldBinding<shad.TimeOfDay>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppTimeStepperPicker(
                 value: state.value,
                 minuteStep: field.minuteStep,
                 enabled: field.enabled,
                 onChanged: (value) {
                   state.didChange(value);
                   field.onChanged?.call(value);
                 },
               ),
             ),
           );
         },
       );

  final String? name;
  final String? label;
  final String? description;
  final bool required;
  final double? width;
  final int minuteStep;
  final ValueChanged<shad.TimeOfDay?>? onChanged;
  final AppAsyncFieldValidator<shad.TimeOfDay>? asyncValidator;
}
