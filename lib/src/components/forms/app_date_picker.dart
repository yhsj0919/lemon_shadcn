import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../actions/app_button.dart';
import '../../foundation/app_control_box.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_prompt_control_frame.dart';

enum _AppDatePickerKind { single, range }

String _formatAppDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-'
    '${value.month.toString().padLeft(2, '0')}-'
    '${value.day.toString().padLeft(2, '0')}';

class AppDatePicker extends StatelessWidget {
  const AppDatePicker({
    super.key,
    required this.value,
    this.onChanged,
    this.placeholder,
    this.mode,
    this.initialView,
    this.initialViewType,
    this.popoverAlignment,
    this.popoverAnchorAlignment,
    this.popoverPadding,
    this.dialogTitle,
    this.stateBuilder,
    this.enabled = true,
  }) : _kind = _AppDatePickerKind.single,
       rangeValue = null,
       onRangeChanged = null;

  const AppDatePicker.range({
    super.key,
    required this.rangeValue,
    this.onRangeChanged,
    this.placeholder,
    this.mode = shad.PromptMode.popover,
    this.initialView,
    this.initialViewType,
    this.popoverAlignment,
    this.popoverAnchorAlignment,
    this.popoverPadding,
    this.dialogTitle,
    this.stateBuilder,
    this.enabled = true,
  }) : _kind = _AppDatePickerKind.range,
       value = null,
       onChanged = null;

  final _AppDatePickerKind _kind;
  final DateTime? value;
  final ValueChanged<DateTime?>? onChanged;
  final shad.DateTimeRange? rangeValue;
  final ValueChanged<shad.DateTimeRange?>? onRangeChanged;
  final Widget? placeholder;
  final shad.PromptMode? mode;
  final shad.CalendarView? initialView;
  final shad.CalendarViewType? initialViewType;
  final AlignmentGeometry? popoverAlignment;
  final AlignmentGeometry? popoverAnchorAlignment;
  final EdgeInsetsGeometry? popoverPadding;
  final Widget? dialogTitle;
  final shad.DateStateBuilder? stateBuilder;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final localizations = shad.ShadcnLocalizations.of(context);
    final resolvedMode = mode ?? shad.PromptMode.popover;
    final picker = switch (_kind) {
      _AppDatePickerKind.single => shad.ObjectFormField<DateTime>(
        value: value,
        onChanged: onChanged,
        enabled: enabled,
        mode: resolvedMode,
        immediateValueChange: false,
        placeholder: placeholder ?? Text(localizations.placeholderDatePicker),
        trailing: const Icon(shad.LucideIcons.calendarDays),
        popoverAlignment: popoverAlignment,
        popoverAnchorAlignment: popoverAnchorAlignment,
        popoverPadding: popoverPadding,
        dialogTitle: dialogTitle,
        builder: (context, value) => Text(_formatAppDate(value)),
        editorBuilder: (context, handler) => _AppSingleDateEditor(
          handler: handler,
          initialView: initialView,
          initialViewType: initialViewType,
          stateBuilder: stateBuilder,
          showActions: resolvedMode == shad.PromptMode.popover,
        ),
      ),
      _AppDatePickerKind.range => shad.ObjectFormField<shad.DateTimeRange>(
        value: rangeValue,
        onChanged: onRangeChanged,
        enabled: enabled,
        mode: resolvedMode,
        immediateValueChange: false,
        placeholder: placeholder ?? Text(localizations.placeholderDatePicker),
        trailing: const Icon(shad.LucideIcons.calendarRange),
        popoverAlignment: popoverAlignment,
        popoverAnchorAlignment: popoverAnchorAlignment,
        popoverPadding: popoverPadding,
        dialogTitle: dialogTitle,
        builder: (context, value) => Text(
          '${_formatAppDate(value.start)} - ${_formatAppDate(value.end)}',
        ),
        editorBuilder: (context, handler) => _AppRangeDateEditor(
          handler: handler,
          initialView: initialView,
          initialViewType: initialViewType,
          stateBuilder: stateBuilder,
          showActions: resolvedMode == shad.PromptMode.popover,
        ),
      ),
    };
    return AppControlBox(
      child: AppPromptControlFrame(enabled: enabled, child: picker),
    );
  }
}

class _AppSingleDateEditor extends StatefulWidget {
  const _AppSingleDateEditor({
    required this.handler,
    required this.showActions,
    this.initialView,
    this.initialViewType,
    this.stateBuilder,
  });

  final shad.ObjectFormHandler<DateTime> handler;
  final bool showActions;
  final shad.CalendarView? initialView;
  final shad.CalendarViewType? initialViewType;
  final shad.DateStateBuilder? stateBuilder;

  @override
  State<_AppSingleDateEditor> createState() => _AppSingleDateEditorState();
}

class _AppSingleDateEditorState extends State<_AppSingleDateEditor> {
  late final DateTime? _initialValue = widget.handler.value;
  late DateTime? _value = _initialValue;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          shad.DatePickerDialog(
            initialView: widget.initialView,
            initialViewType:
                widget.initialViewType ?? shad.CalendarViewType.date,
            selectionMode: shad.CalendarSelectionMode.single,
            initialValue: _value == null
                ? null
                : shad.CalendarValue.single(_value!),
            stateBuilder: widget.stateBuilder,
            onChanged: (value) {
              final next = value == null
                  ? null
                  : (value as shad.SingleCalendarValue).date;
              setState(() => _value = next);
              if (!widget.showActions) widget.handler.value = next;
            },
          ),
          if (widget.showActions)
            _AppDateActions(
              onClear: () {
                widget.handler.value = null;
                widget.handler.close();
              },
              onCancel: () {
                widget.handler.value = _initialValue;
                widget.handler.close();
              },
              onConfirm: () {
                widget.handler.value = _value;
                widget.handler.close();
              },
            ),
        ],
      ),
    );
  }
}

class _AppRangeDateEditor extends StatefulWidget {
  const _AppRangeDateEditor({
    required this.handler,
    required this.showActions,
    this.initialView,
    this.initialViewType,
    this.stateBuilder,
  });

  final shad.ObjectFormHandler<shad.DateTimeRange> handler;
  final bool showActions;
  final shad.CalendarView? initialView;
  final shad.CalendarViewType? initialViewType;
  final shad.DateStateBuilder? stateBuilder;

  @override
  State<_AppRangeDateEditor> createState() => _AppRangeDateEditorState();
}

class _AppRangeDateEditorState extends State<_AppRangeDateEditor> {
  late final shad.DateTimeRange? _initialValue = widget.handler.value;
  late shad.DateTimeRange? _value = _initialValue;

  @override
  Widget build(BuildContext context) {
    return IntrinsicWidth(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          shad.DatePickerDialog(
            initialView: widget.initialView,
            initialViewType:
                widget.initialViewType ?? shad.CalendarViewType.date,
            selectionMode: shad.CalendarSelectionMode.range,
            viewMode: MediaQuery.sizeOf(context).width < 500
                ? shad.CalendarSelectionMode.single
                : shad.CalendarSelectionMode.range,
            initialValue: _value == null
                ? null
                : shad.CalendarValue.range(_value!.start, _value!.end),
            stateBuilder: widget.stateBuilder,
            onChanged: (value) {
              final range = value?.toRange();
              final next = range == null
                  ? null
                  : shad.DateTimeRange(range.start, range.end);
              setState(() => _value = next);
              if (!widget.showActions) widget.handler.value = next;
            },
          ),
          if (widget.showActions)
            _AppDateActions(
              onClear: () {
                widget.handler.value = null;
                widget.handler.close();
              },
              onCancel: () {
                widget.handler.value = _initialValue;
                widget.handler.close();
              },
              onConfirm: () {
                widget.handler.value = _value;
                widget.handler.close();
              },
            ),
        ],
      ),
    );
  }
}

class _AppDateActions extends StatelessWidget {
  const _AppDateActions({
    required this.onClear,
    required this.onCancel,
    required this.onConfirm,
  });

  final VoidCallback onClear;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          AppButton.text(onPressed: onClear, child: const Text('清空')),
          const Spacer(),
          AppButton.outline(onPressed: onCancel, child: const Text('取消')),
          const SizedBox(width: 8),
          AppButton.primary(onPressed: onConfirm, child: const Text('确定')),
        ],
      ),
    );
  }
}

class AppDatePickerFormField extends FormField<DateTime> {
  AppDatePickerFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.placeholder,
    this.required = false,
    this.width,
    this.mode,
    this.initialView,
    this.initialViewType,
    this.stateBuilder,
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
           final field = state.widget as AppDatePickerFormField;
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
               child: AppDatePicker(
                 value: state.value,
                 placeholder: field.placeholder,
                 mode: field.mode,
                 initialView: field.initialView,
                 initialViewType: field.initialViewType,
                 stateBuilder: field.stateBuilder,
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
  final Widget? placeholder;
  final bool required;
  final double? width;
  final shad.PromptMode? mode;
  final shad.CalendarView? initialView;
  final shad.CalendarViewType? initialViewType;
  final shad.DateStateBuilder? stateBuilder;
  final ValueChanged<DateTime?>? onChanged;
  final AppAsyncFieldValidator<DateTime>? asyncValidator;
}

class AppDateRangePickerFormField extends FormField<shad.DateTimeRange> {
  AppDateRangePickerFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.placeholder,
    this.required = false,
    this.width,
    this.mode = shad.PromptMode.popover,
    this.initialView,
    this.initialViewType,
    this.stateBuilder,
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
           final field = state.widget as AppDateRangePickerFormField;
           return AppFormFieldBinding<shad.DateTimeRange>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppDatePicker.range(
                 rangeValue: state.value,
                 placeholder: field.placeholder,
                 mode: field.mode,
                 initialView: field.initialView,
                 initialViewType: field.initialViewType,
                 stateBuilder: field.stateBuilder,
                 enabled: field.enabled,
                 onRangeChanged: (value) {
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
  final Widget? placeholder;
  final bool required;
  final double? width;
  final shad.PromptMode mode;
  final shad.CalendarView? initialView;
  final shad.CalendarViewType? initialViewType;
  final shad.DateStateBuilder? stateBuilder;
  final ValueChanged<shad.DateTimeRange?>? onChanged;
  final AppAsyncFieldValidator<shad.DateTimeRange>? asyncValidator;
}

typedef AppCalendar = shad.Calendar;
typedef AppCalendarValue = shad.CalendarValue;
typedef AppSingleCalendarValue = shad.SingleCalendarValue;
typedef AppRangeCalendarValue = shad.RangeCalendarValue;
typedef AppMultiCalendarValue = shad.MultiCalendarValue;
typedef AppCalendarView = shad.CalendarView;
