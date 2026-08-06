import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_prompt_control_frame.dart';
import 'app_time_stepper_picker.dart';

Widget? _hint(String? text) => text == null ? null : Text(text);

class AppTimePicker extends StatelessWidget {
  const AppTimePicker({
    super.key,
    required this.value,
    this.onChanged,
    this.mode = shad.PromptMode.popover,
    this.hintText,
    this.popoverAlignment,
    this.popoverAnchorAlignment,
    this.popoverPadding,
    this.use24HourFormat,
    this.showSeconds = false,
    this.dialogTitle,
    this.enabled = true,
  });

  final shad.TimeOfDay? value;
  final ValueChanged<shad.TimeOfDay?>? onChanged;
  final shad.PromptMode mode;
  final String? hintText;
  final AlignmentGeometry? popoverAlignment;
  final AlignmentGeometry? popoverAnchorAlignment;
  final EdgeInsetsGeometry? popoverPadding;
  final bool? use24HourFormat;
  final bool showSeconds;
  final Widget? dialogTitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!showSeconds) {
      return AppTimeStepperPicker(
        value: value,
        onChanged: onChanged,
        mode: mode,
        hintText: hintText,
        enabled: enabled,
      );
    }
    return AppControlBox(
      child: AppPromptControlFrame(
        enabled: enabled,
        child: shad.TimePicker(
          value: value,
          onChanged: onChanged,
          mode: mode,
          placeholder: _hint(hintText),
          popoverAlignment: popoverAlignment,
          popoverAnchorAlignment: popoverAnchorAlignment,
          popoverPadding: popoverPadding,
          use24HourFormat: use24HourFormat,
          showSeconds: showSeconds,
          dialogTitle: dialogTitle,
          enabled: enabled,
        ),
      ),
    );
  }
}

/// The original shadcn input-based time picker, retained for compatibility.
class AppLegacyTimePicker extends StatelessWidget {
  const AppLegacyTimePicker({
    super.key,
    required this.value,
    this.onChanged,
    this.mode = shad.PromptMode.popover,
    this.hintText,
    this.popoverAlignment,
    this.popoverAnchorAlignment,
    this.popoverPadding,
    this.use24HourFormat,
    this.showSeconds = false,
    this.dialogTitle,
    this.enabled = true,
  });

  final shad.TimeOfDay? value;
  final ValueChanged<shad.TimeOfDay?>? onChanged;
  final shad.PromptMode mode;
  final String? hintText;
  final AlignmentGeometry? popoverAlignment;
  final AlignmentGeometry? popoverAnchorAlignment;
  final EdgeInsetsGeometry? popoverPadding;
  final bool? use24HourFormat;
  final bool showSeconds;
  final Widget? dialogTitle;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return AppControlBox(
      child: AppPromptControlFrame(
        enabled: enabled,
        child: shad.TimePicker(
          value: value,
          onChanged: onChanged,
          mode: mode,
          placeholder: _hint(hintText),
          popoverAlignment: popoverAlignment,
          popoverAnchorAlignment: popoverAnchorAlignment,
          popoverPadding: popoverPadding,
          use24HourFormat: use24HourFormat,
          showSeconds: showSeconds,
          dialogTitle: dialogTitle,
          enabled: enabled,
        ),
      ),
    );
  }
}

class AppTimePickerFormField extends FormField<shad.TimeOfDay> {
  AppTimePickerFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.hintText,
    this.required = false,
    this.width,
    this.mode = shad.PromptMode.popover,
    this.use24HourFormat,
    this.showSeconds = false,
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
           final field = state.widget as AppTimePickerFormField;
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
               child: AppTimePicker(
                 value: state.value,
                 hintText: field.hintText,
                 mode: field.mode,
                 use24HourFormat: field.use24HourFormat,
                 showSeconds: field.showSeconds,
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
  final String? hintText;
  final bool required;
  final double? width;
  final shad.PromptMode mode;
  final bool? use24HourFormat;
  final bool showSeconds;
  final ValueChanged<shad.TimeOfDay?>? onChanged;
  final AppAsyncFieldValidator<shad.TimeOfDay>? asyncValidator;
}
