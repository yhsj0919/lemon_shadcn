import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_visual_style.dart';
import '../forms/app_field.dart';
import '../forms/app_form.dart';

/// A theme-compatible two-state action with the standard control height.
class AppToggle extends StatelessWidget {
  const AppToggle({
    super.key,
    required this.value,
    required this.onChanged,
    required this.child,
    this.enabled = true,
    this.style,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget child;
  final bool enabled;
  final shad.ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    final colors = resolveAppControlVisuals(context, {
      if (value) WidgetState.selected,
      if (!enabled || onChanged == null) WidgetState.disabled,
    });
    Widget toggle = AppControlBox(
      child: shad.Toggle(
        value: value,
        onChanged: onChanged,
        enabled: enabled,
        style: style ?? const shad.ButtonStyle.ghost(),
        child: child,
      ),
    );
    if (value && colors != null) {
      toggle = shad.ComponentTheme<shad.SecondaryButtonTheme>(
        data: shad.SecondaryButtonTheme(
          decoration: (context, states, decoration) {
            if (decoration is ShapeDecoration) {
              return decoration.copyWith(color: colors.background);
            }
            return decoration;
          },
          textStyle: (context, states, textStyle) =>
              textStyle.copyWith(color: colors.foreground),
          iconTheme: (context, states, iconTheme) =>
              iconTheme.copyWith(color: colors.foreground),
        ),
        child: toggle,
      );
    }
    return toggle;
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
    this.style,
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
                 style: field.style,
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
  final shad.ButtonStyle? style;
  final AppAsyncFieldValidator<bool>? asyncValidator;
}
