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
    this.placeholder,
    this.enabled = true,
  }) : assert(minuteStep > 0 && minuteStep <= 59);

  final shad.TimeOfDay? value;
  final ValueChanged<shad.TimeOfDay?>? onChanged;
  final int minuteStep;
  final shad.PromptMode mode;
  final Widget? placeholder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final localizations = shad.ShadcnLocalizations.of(context);
    final picker = shad.ObjectFormField<shad.TimeOfDay>(
      value: value,
      enabled: enabled,
      mode: mode,
      popoverPadding: EdgeInsets.zero,
      placeholder: placeholder ?? Text(localizations.placeholderTimePicker),
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

class _AppTimeStepperEditor extends StatefulWidget {
  const _AppTimeStepperEditor({
    required this.initialValue,
    required this.minuteStep,
    required this.handler,
  });

  final shad.TimeOfDay? initialValue;
  final int minuteStep;
  final shad.ObjectFormHandler<shad.TimeOfDay> handler;

  @override
  State<_AppTimeStepperEditor> createState() => _AppTimeStepperEditorState();
}

class _AppTimeStepperEditorState extends State<_AppTimeStepperEditor> {
  late shad.TimeOfDay _value =
      widget.initialValue ?? const shad.TimeOfDay(hour: 0, minute: 0);

  void _change({int hours = 0, int minutes = 0}) {
    const dayMinutes = 24 * 60;
    final current = _value.hour * 60 + _value.minute;
    final raw = (current + hours * 60 + minutes) % dayMinutes;
    final normalized = raw < 0 ? raw + dayMinutes : raw;
    _setValue(shad.TimeOfDay(hour: normalized ~/ 60, minute: normalized % 60));
  }

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
  }

  void _clear() {
    widget.handler.value = null;
    widget.handler.close();
  }

  void _cancel() {
    widget.handler.value = widget.initialValue;
    widget.handler.close();
  }

  void _confirm() {
    widget.handler.value = _value;
    widget.handler.close();
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
                      onDecrease: () => _change(hours: -5),
                      onIncrease: () => _change(hours: 5),
                      onFineDecrease: () => _change(hours: -1),
                      onFineIncrease: () => _change(hours: 1),
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
                      onDecrease: () => _change(minutes: -widget.minuteStep),
                      onIncrease: () => _change(minutes: widget.minuteStep),
                      onFineDecrease: () => _change(minutes: -1),
                      onFineIncrease: () => _change(minutes: 1),
                      onInput: _setMinute,
                      onConfirm: _confirm,
                      onCancel: _cancel,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    AppButton.text(onPressed: _clear, child: const Text('清空')),
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
            ),
          ),
          Positioned(
            bottom: 60,
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
    required this.onFineDecrease,
    required this.onFineIncrease,
    required this.onInput,
    required this.onConfirm,
    required this.onCancel,
    required this.onDecrease,
    required this.onIncrease,
  });

  final String label;
  final int value;
  final int maxValue;
  final int coarseStep;
  final VoidCallback onDecrease;
  final VoidCallback onIncrease;
  final VoidCallback onFineDecrease;
  final VoidCallback onFineIncrease;
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
          _TimeValueBox(
            value: value,
            maxValue: maxValue,
            coarseStep: coarseStep,
            onIncrease: onFineIncrease,
            onDecrease: onFineDecrease,
            onCoarseIncrease: onIncrease,
            onCoarseDecrease: onDecrease,
            onInput: onInput,
            onConfirm: onConfirm,
            onCancel: onCancel,
          ),
          const SizedBox(height: 6),
          Align(alignment: Alignment.centerLeft, child: Text(label).muted()),
        ],
      ),
    );
  }
}

class _TimeValueBox extends StatefulWidget {
  const _TimeValueBox({
    required this.value,
    required this.maxValue,
    required this.coarseStep,
    required this.onIncrease,
    required this.onDecrease,
    required this.onCoarseIncrease,
    required this.onCoarseDecrease,
    required this.onInput,
    required this.onConfirm,
    required this.onCancel,
  });

  final int value;
  final int maxValue;
  final int coarseStep;
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
    _controller.text = widget.value.toString().padLeft(2, '0');
  }

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
    final normalized = parsed.clamp(0, widget.maxValue);
    widget.onInput(normalized);
    _controller.text = normalized.toString().padLeft(2, '0');
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
        coarse ? widget.coarseStep : 1,
      );
      return KeyEventResult.handled;
    }
    if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
      _runStep(
        coarse ? widget.onCoarseDecrease : widget.onDecrease,
        coarse ? -widget.coarseStep : -1,
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
    callback();
    final range = widget.maxValue + 1;
    final raw = (widget.value + delta) % range;
    final next = raw < 0 ? raw + range : raw;
    _controller.text = next.toString().padLeft(2, '0');
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
    final amount = coarse ? widget.coarseStep : 1;
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
    return SizedBox(
      height: 44,
      child: Stack(
        children: [
          Positioned.fill(
            child: shad.TextField(
              controller: _controller,
              focusNode: _focusNode,
              maxLength: 2,
              maxLines: 1,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              textAlign: TextAlign.center,
              textAlignVertical: TextAlignVertical.center,
              padding: const EdgeInsets.only(right: 18),
              style: theme.typography.x2Large,
              onChanged: (text) {
                if (text.length == 2) _submit(text);
              },
              onSubmitted: _submit,
            ),
          ),
          Positioned(
            top: 1,
            right: 1,
            bottom: 1,
            width: 24,
            child: Column(
              children: [
                Expanded(
                  child: AppInkWell(
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
      ),
    );
  }
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
