import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_visual_style.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_option.dart';

class AppRadioGroup<V> extends StatelessWidget {
  const AppRadioGroup({
    super.key,
    required this.options,
    this.value,
    this.onChanged,
    this.enabled = true,
    this.direction = Axis.vertical,
    this.spacing = 4,
  });

  final List<AppOption<V>> options;
  final V? value;
  final ValueChanged<V>? onChanged;
  final bool enabled;
  final Axis direction;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final ancestor = shad.ComponentTheme.maybeOf<shad.RadioTheme>(context);
    final items = <Widget>[
      for (final option in options)
        Builder(
          builder: (context) {
            final optionEnabled = enabled && !option.disabled;
            final colors = resolveAppControlVisuals(context, {
              if (value == option.value) WidgetState.selected,
              if (!optionEnabled) WidgetState.disabled,
            });
            final radioTheme = (ancestor ?? const shad.RadioTheme()).copyWith(
              size: ancestor?.size == null ? () => 18 * theme.scaling : null,
              activeColor: () =>
                  colors?.accent ??
                  colors?.foreground ??
                  theme.colorScheme.primary,
              borderColor: () => colors?.border ?? theme.colorScheme.border,
              backgroundColor: () =>
                  colors?.background ?? theme.colorScheme.background,
            );
            final optionLabel = DefaultTextStyle.merge(
              style: theme.typography.base.copyWith(
                fontWeight: FontWeight.normal,
              ),
              child: option.child ?? Text(option.label),
            );
            return shad.ComponentTheme<shad.RadioTheme>(
              data: radioTheme,
              child: AppControlBox(
                child: Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: shad.RadioItem<V>(
                    value: option.value,
                    enabled: optionEnabled,
                    trailing: optionLabel,
                  ),
                ),
              ),
            );
          },
        ),
    ];
    final content = direction == Axis.horizontal
        ? Wrap(
            spacing: spacing,
            runSpacing: spacing,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: items,
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _withVerticalSpacing(items),
          );
    return shad.RadioGroup<V>(
      value: value,
      enabled: enabled,
      onChanged: onChanged,
      child: content,
    );
  }

  List<Widget> _withVerticalSpacing(List<Widget> children) {
    if (children.length < 2 || spacing == 0) return children;
    final result = <Widget>[];
    for (var index = 0; index < children.length; index++) {
      if (index > 0) {
        result.add(SizedBox(height: spacing));
      }
      result.add(children[index]);
    }
    return result;
  }
}

class AppRadioGroupFormField<V> extends FormField<V> {
  AppRadioGroupFormField({
    super.key,
    required this.options,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.direction = Axis.vertical,
    this.spacing = 4,
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
           final field = state.widget as AppRadioGroupFormField<V>;
           return AppFormFieldBinding<V>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppRadioGroup<V>(
                 options: field.options,
                 value: state.value,
                 enabled: field.enabled,
                 direction: field.direction,
                 spacing: field.spacing,
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
  final Axis direction;
  final double spacing;
  final ValueChanged<V>? onChanged;
  final AppAsyncFieldValidator<V>? asyncValidator;
}
