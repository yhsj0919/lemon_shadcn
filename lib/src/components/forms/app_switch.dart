import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_visual_style.dart';
import 'app_field.dart';
import 'app_form.dart';

class AppSwitch extends StatelessWidget {
  const AppSwitch({
    super.key,
    required this.value,
    required this.onChanged,
    this.leading,
    this.trailing,
    this.enabled = true,
    this.gap,
    this.activeColor,
    this.inactiveColor,
    this.activeThumbColor,
    this.inactiveThumbColor,
    this.borderRadius,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? leading;
  final Widget? trailing;
  final bool? enabled;
  final double? gap;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? activeThumbColor;
  final Color? inactiveThumbColor;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final states = <WidgetState>{
      if (value) WidgetState.selected,
      if (enabled == false || onChanged == null) WidgetState.disabled,
    };
    final colors = resolveAppControlVisuals(context, states);
    Widget? label(Widget? child) => child == null
        ? null
        : DefaultTextStyle.merge(
            style: theme.typography.base.copyWith(fontWeight: FontWeight.normal),
            child: child,
          );
    final effectiveLeading = label(leading);
    final effectiveTrailing = label(trailing);
    return AppControlBox(
      child: Align(
        alignment: AlignmentDirectional.centerStart,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (effectiveLeading != null) effectiveLeading,
            if (effectiveLeading != null)
              SizedBox(width: gap ?? 8 * theme.scaling),
            SizedBox(
              width: 32.4 * theme.scaling,
              height: 18 * theme.scaling,
              child: FittedBox(
                fit: BoxFit.fill,
                child: shad.Switch(
                  value: value,
                  onChanged: onChanged,
                  enabled: enabled,
                  activeColor:
                      activeColor ?? colors?.background ?? colors?.accent,
                  inactiveColor: inactiveColor ?? colors?.background,
                  activeThumbColor: activeThumbColor ?? colors?.foreground,
                  inactiveThumbColor: inactiveThumbColor,
                  borderRadius: borderRadius,
                ),
              ),
            ),
            if (effectiveTrailing != null)
              SizedBox(width: gap ?? 8 * theme.scaling),
            if (effectiveTrailing != null) effectiveTrailing,
          ],
        ),
      ),
    );
  }
}

class AppSwitchFormField extends FormField<bool> {
  AppSwitchFormField({
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
           final field = state.widget as AppSwitchFormField;
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
               child: AppSwitch(
                 value: state.value ?? false,
                 enabled: field.enabled,
                 trailing: field.controlLabel,
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
  final Widget? controlLabel;
  final bool required;
  final double? width;
  final ValueChanged<bool>? onChanged;
  final AppAsyncFieldValidator<bool>? asyncValidator;
}
