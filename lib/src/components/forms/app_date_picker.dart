import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import 'app_field.dart';
import 'app_form.dart';

enum _AppDatePickerKind { single, range }

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
    this.mode = shad.PromptMode.dialog,
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
    final picker = switch (_kind) {
      _AppDatePickerKind.single => shad.DatePicker(
        value: value,
        onChanged: onChanged,
        placeholder: placeholder,
        mode: mode,
        initialView: initialView,
        initialViewType: initialViewType,
        popoverAlignment: popoverAlignment,
        popoverAnchorAlignment: popoverAnchorAlignment,
        popoverPadding: popoverPadding,
        dialogTitle: dialogTitle,
        stateBuilder: stateBuilder,
        enabled: enabled,
      ),
      _AppDatePickerKind.range => IgnorePointer(
        ignoring: !enabled,
        child: Opacity(
          opacity: enabled ? 1 : 0.5,
          child: shad.DateRangePicker(
            value: rangeValue,
            onChanged: onRangeChanged,
            placeholder: placeholder,
            mode: mode ?? shad.PromptMode.dialog,
            initialView: initialView,
            initialViewType: initialViewType,
            popoverAlignment: popoverAlignment,
            popoverAnchorAlignment: popoverAnchorAlignment,
            popoverPadding: popoverPadding,
            dialogTitle: dialogTitle,
            stateBuilder: stateBuilder,
          ),
        ),
      ),
    };
    return AppControlBox(child: picker);
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
    this.mode = shad.PromptMode.dialog,
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
