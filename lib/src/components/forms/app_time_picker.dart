import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_prompt_control_frame.dart';

class AppTimePicker extends StatelessWidget {
  const AppTimePicker({
    super.key,
    required this.value,
    this.onChanged,
    this.mode = shad.PromptMode.popover,
    this.placeholder,
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
  final Widget? placeholder;
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
          placeholder: placeholder,
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
    this.placeholder,
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
                 placeholder: field.placeholder,
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
  final Widget? placeholder;
  final bool required;
  final double? width;
  final shad.PromptMode mode;
  final bool? use24HourFormat;
  final bool showSeconds;
  final ValueChanged<shad.TimeOfDay?>? onChanged;
  final AppAsyncFieldValidator<shad.TimeOfDay>? asyncValidator;
}
