import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_visual_style.dart';
import 'app_field.dart';
import 'app_form.dart';

/// Select-all style tristate clicks: checked ↔ unchecked, indeterminate → checked.
/// Indeterminate is display-only and never emitted from user interaction.
ValueChanged<shad.CheckboxState>? _appCheckboxOnChanged({
  required shad.CheckboxState state,
  required bool tristate,
  required ValueChanged<shad.CheckboxState>? onChanged,
}) {
  if (onChanged == null) return null;
  if (!tristate) return onChanged;
  return (_) {
    onChanged(
      state == shad.CheckboxState.checked
          ? shad.CheckboxState.unchecked
          : shad.CheckboxState.checked,
    );
  };
}

/// Compact checkbox control for use inside lists and composite controls.
class AppCheckboxIndicator extends StatelessWidget {
  const AppCheckboxIndicator({
    super.key,
    required this.state,
    required this.onChanged,
    this.tristate = false,
    this.enabled,
    this.size,
    this.backgroundColor,
    this.activeColor,
    this.borderColor,
    this.borderRadius,
  });

  final shad.CheckboxState state;
  final ValueChanged<shad.CheckboxState>? onChanged;
  final bool tristate;
  final bool? enabled;
  final double? size;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final states = <WidgetState>{
      if (state != shad.CheckboxState.unchecked) WidgetState.selected,
      if (enabled == false || onChanged == null) WidgetState.disabled,
    };
    final colors = resolveAppControlVisuals(context, states);
    return shad.Checkbox(
      state: state,
      onChanged: _appCheckboxOnChanged(
        state: state,
        tristate: tristate,
        onChanged: onChanged,
      ),
      tristate: tristate,
      enabled: enabled,
      size: size ?? 18 * theme.scaling,
      backgroundColor:
          backgroundColor ?? colors?.background ?? theme.colorScheme.background,
      activeColor: activeColor ?? colors?.accent ?? theme.colorScheme.primary,
      borderColor: borderColor ?? colors?.border ?? theme.colorScheme.border,
      borderRadius: borderRadius,
    );
  }
}

class AppCheckbox extends StatelessWidget {
  const AppCheckbox({
    super.key,
    required this.state,
    required this.onChanged,
    this.leading,
    this.trailing,
    this.tristate = false,
    this.enabled,
    this.size,
    this.gap,
    this.backgroundColor,
    this.activeColor,
    this.borderColor,
    this.borderRadius,
  });

  final shad.CheckboxState state;
  final ValueChanged<shad.CheckboxState>? onChanged;
  final Widget? leading;
  final Widget? trailing;
  final bool tristate;
  final bool? enabled;
  final double? size;
  final double? gap;
  final Color? backgroundColor;
  final Color? activeColor;
  final Color? borderColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final states = <WidgetState>{
      if (state != shad.CheckboxState.unchecked) WidgetState.selected,
      if (enabled == false || onChanged == null) WidgetState.disabled,
    };
    final colors = resolveAppControlVisuals(context, states);
    Widget? label(Widget? child) => child == null
        ? null
        : DefaultTextStyle.merge(
            style: theme.typography.base.copyWith(
              fontWeight: FontWeight.normal,
            ),
            child: child,
          );
    return AppControlBox(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: shad.Checkbox(
          state: state,
          onChanged: _appCheckboxOnChanged(
            state: state,
            tristate: tristate,
            onChanged: onChanged,
          ),
          leading: label(leading),
          trailing: label(trailing),
          tristate: tristate,
          enabled: enabled,
          size: size ?? 18 * theme.scaling,
          gap: gap,
          backgroundColor:
              backgroundColor ??
              colors?.background ??
              theme.colorScheme.background,
          activeColor:
              activeColor ?? colors?.accent ?? theme.colorScheme.primary,
          borderColor:
              borderColor ?? colors?.border ?? theme.colorScheme.border,
          borderRadius: borderRadius,
        ),
      ),
    );
  }
}

class AppCheckboxFormField extends FormField<bool> {
  AppCheckboxFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.controlLabel,
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
           final field = state.widget as AppCheckboxFormField;
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
               child: AppCheckbox(
                 state: state.value == true
                     ? shad.CheckboxState.checked
                     : shad.CheckboxState.unchecked,
                 enabled: field.enabled,
                 trailing: field.controlLabel,
                 onChanged: (checkboxState) {
                   final value = checkboxState == shad.CheckboxState.checked;
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
  final Widget? controlLabel;
  final bool required;
  final double? width;
  final ValueChanged<bool>? onChanged;
  final AppAsyncFieldValidator<bool>? asyncValidator;
}
