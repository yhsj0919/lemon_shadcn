import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_visual_style.dart';
import 'app_field.dart';
import 'app_form.dart';

class AppSlider extends StatelessWidget {
  const AppSlider({
    super.key,
    required this.value,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.hintValue,
    this.increaseStep,
    this.decreaseStep,
    this.enabled = true,
    this.valueIndicatorBuilder,
  });

  final shad.SliderValue value;
  final ValueChanged<shad.SliderValue>? onChanged;
  final ValueChanged<shad.SliderValue>? onChangeStart;
  final ValueChanged<shad.SliderValue>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final shad.SliderValue? hintValue;
  final double? increaseStep;
  final double? decreaseStep;
  final bool? enabled;
  final shad.SliderValueIndicatorBuilder? valueIndicatorBuilder;

  @override
  Widget build(BuildContext context) {
    final colors = resolveAppControlVisuals(context, {
      WidgetState.selected,
      if (enabled == false || onChanged == null) WidgetState.disabled,
    });
    final ancestor = shad.ComponentTheme.maybeOf<shad.SliderTheme>(context);
    final sliderTheme = (ancestor ?? const shad.SliderTheme()).copyWith(
      trackColor: colors == null ? null : () => colors.background,
      valueColor: colors == null
          ? null
          : () => colors.accent ?? colors.foreground,
      thumbColor: colors == null ? null : () => colors.foreground,
      thumbBorderColor: colors == null ? null : () => colors.border,
    );
    return shad.ComponentTheme<shad.SliderTheme>(
      data: sliderTheme,
      child: AppControlBox(
        child: Align(
          alignment: Alignment.center,
          child: shad.Slider(
            value: value,
            onChanged: onChanged,
            onChangeStart: onChangeStart,
            onChangeEnd: onChangeEnd,
            min: min,
            max: max,
            divisions: divisions,
            hintValue: hintValue,
            increaseStep: increaseStep,
            decreaseStep: decreaseStep,
            enabled: enabled,
            valueIndicatorBuilder: valueIndicatorBuilder,
          ),
        ),
      ),
    );
  }
}

class AppSliderFormField extends FormField<shad.SliderValue> {
  AppSliderFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.min = 0,
    this.max = 1,
    this.divisions,
    this.hintValue,
    this.increaseStep,
    this.decreaseStep,
    this.valueIndicatorBuilder,
    this.onChanged,
    this.onChangeStart,
    this.onChangeEnd,
    super.initialValue = const shad.SliderValue.single(0),
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppSliderFormField;
           return AppFormFieldBinding<shad.SliderValue>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppSlider(
                 value: state.value ?? const shad.SliderValue.single(0),
                 min: field.min,
                 max: field.max,
                 divisions: field.divisions,
                 hintValue: field.hintValue,
                 increaseStep: field.increaseStep,
                 decreaseStep: field.decreaseStep,
                 enabled: field.enabled,
                 valueIndicatorBuilder: field.valueIndicatorBuilder,
                 onChangeStart: field.onChangeStart,
                 onChangeEnd: field.onChangeEnd,
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
  final bool required;
  final double? width;
  final double min;
  final double max;
  final int? divisions;
  final shad.SliderValue? hintValue;
  final double? increaseStep;
  final double? decreaseStep;
  final shad.SliderValueIndicatorBuilder? valueIndicatorBuilder;
  final ValueChanged<shad.SliderValue>? onChanged;
  final ValueChanged<shad.SliderValue>? onChangeStart;
  final ValueChanged<shad.SliderValue>? onChangeEnd;
  final AppAsyncFieldValidator<shad.SliderValue>? asyncValidator;
}
