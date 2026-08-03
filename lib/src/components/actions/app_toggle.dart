import 'package:flutter/widgets.dart';

import '../forms/app_field.dart';
import '../forms/app_form.dart';
import 'app_button.dart';

/// A theme-compatible two-state action with the standard control height.
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.child,
    this.enabled = true,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final interactive = enabled && onChanged != null;
    final onPressed = interactive ? () => onChanged!(!value) : null;
    return Semantics(
      toggled: value,
      child: value
          ? AppButton.selected(
              onPressed: onPressed,
              config: AppButtonConfig.plain,
              child: child,
            )
          : AppButton.text(
              onPressed: onPressed,
              config: AppButtonConfig.plain,
              child: child,
            ),
    );
  }
}

class AppToggleFormField extends FormField<bool> {
  AppToggleFormField({
    super.key,
    required this.child,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.onChanged,
    super.initialValue = false,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppToggleFormField;
           return AppFormFieldBinding<bool>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppToggle(
                 value: state.value ?? false,
                 enabled: field.enabled,
                 onChanged: (value) {
                   state.didChange(value);
                   field.onChanged?.call(value);
                 },
                 child: field.child,
               ),
             ),
           );
         },
       );

  final Widget child;
  final String? name;
  final String? label;
  final String? description;
  final bool required;
  final double? width;
  final ValueChanged<bool>? onChanged;
  final AppAsyncFieldValidator<bool>? asyncValidator;
}
