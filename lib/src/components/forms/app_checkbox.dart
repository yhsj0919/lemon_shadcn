import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_visual_style.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_option.dart';

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
    this.useControlHeight = true,
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
  final bool useControlHeight;

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
            style: theme.typography.small.copyWith(
              fontWeight: FontWeight.normal,
            ),
            child: child,
          );
    final checkbox = Align(
      alignment: AlignmentDirectional.centerStart,
      widthFactor: 1,
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
        activeColor: activeColor ?? colors?.accent ?? theme.colorScheme.primary,
        borderColor: borderColor ?? colors?.border ?? theme.colorScheme.border,
        borderRadius: borderRadius,
      ),
    );
    return useControlHeight ? AppControlBox(child: checkbox) : checkbox;
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
    this.layout,
    this.labelWidth,
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
               layout: field.layout,
               labelWidth: field.labelWidth,
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
  final AppFieldLayout? layout;
  final double? labelWidth;
  final ValueChanged<bool>? onChanged;
  final AppAsyncFieldValidator<bool>? asyncValidator;
}

/// A controlled group of independently selectable checkbox options.
class AppCheckboxGroup<V> extends StatelessWidget {
  const AppCheckboxGroup({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.enabled = true,
    this.valueDirection = Axis.horizontal,
    this.spacing = 16,
    this.runSpacing = 8,
  });

  final List<AppOption<V>> options;
  final List<V> value;
  final ValueChanged<List<V>>? onChanged;
  final bool enabled;

  /// Layout direction for option values.
  final Axis valueDirection;
  final double spacing;
  final double runSpacing;

  void _toggle(AppOption<V> option, bool selected) {
    final next = List<V>.of(value);
    if (selected) {
      if (!next.contains(option.value)) next.add(option.value);
    } else {
      next.remove(option.value);
    }
    onChanged?.call(next);
  }

  @override
  Widget build(BuildContext context) {
    final items = [
      for (final option in options)
        AppCheckbox(
          state: value.contains(option.value)
              ? shad.CheckboxState.checked
              : shad.CheckboxState.unchecked,
          enabled: enabled && !option.disabled,
          useControlHeight: false,
          trailing: option.child ?? Text(option.label),
          onChanged: enabled && !option.disabled && onChanged != null
              ? (state) => _toggle(option, state == shad.CheckboxState.checked)
              : null,
        ),
    ];
    if (valueDirection == Axis.horizontal) {
      return Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: items,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var index = 0; index < items.length; index++) ...[
          if (index > 0) SizedBox(height: runSpacing),
          items[index],
        ],
      ],
    );
  }
}

class AppCheckboxGroupFormField<V> extends FormField<List<V>> {
  AppCheckboxGroupFormField({
    super.key,
    required this.options,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.layout,
    this.labelWidth,
    this.valueDirection = Axis.horizontal,
    this.spacing = 16,
    this.runSpacing = 8,
    this.onChanged,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppCheckboxGroupFormField<V>;
           return AppFormFieldBinding<List<V>>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               layout: field.layout,
               labelWidth: field.labelWidth,
               child: AppCheckboxGroup<V>(
                 options: field.options,
                 value: state.value ?? const [],
                 enabled: field.enabled,
                 valueDirection: field.valueDirection,
                 spacing: field.spacing,
                 runSpacing: field.runSpacing,
                 onChanged: (value) {
                   state.didChange(value);
                   field.onChanged?.call(value);
                 },
               ),
             ),
           );
         },
       );

  final List<AppOption<V>> options;
  final String? name;
  final String? label;
  final String? description;
  final bool required;
  final double? width;
  final AppFieldLayout? layout;
  final double? labelWidth;
  final Axis valueDirection;
  final double spacing;
  final double runSpacing;
  final ValueChanged<List<V>>? onChanged;
  final AppAsyncFieldValidator<List<V>>? asyncValidator;
}
