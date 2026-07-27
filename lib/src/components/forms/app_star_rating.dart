import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_visual_style.dart';
import 'app_field.dart';
import 'app_form.dart';

class AppStarRating extends StatelessWidget {
  const AppStarRating({
    super.key,
    required this.value,
    this.onChanged,
    this.step = .5,
    this.direction = Axis.horizontal,
    this.max = 5,
    this.activeColor,
    this.backgroundColor,
    this.starSize,
    this.starSpacing,
    this.enabled = true,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final double step;
  final Axis direction;
  final double max;
  final Color? activeColor;
  final Color? backgroundColor;
  final double? starSize;
  final double? starSpacing;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = resolveAppControlVisuals(context, {
      if (value > 0) WidgetState.selected,
      if (!enabled || onChanged == null) WidgetState.disabled,
    });
    final rating = shad.StarRating(
      value: value,
      onChanged: onChanged,
      step: step,
      direction: direction,
      max: max,
      activeColor: activeColor ?? colors?.accent ?? colors?.foreground,
      backgroundColor: backgroundColor ?? colors?.border,
      starSize: starSize,
      starSpacing: starSpacing,
      enabled: enabled,
    );
    if (direction == Axis.vertical) return rating;
    return AppControlBox(
      child: Align(alignment: AlignmentDirectional.centerStart, child: rating),
    );
  }
}

class AppStarRatingFormField extends FormField<double> {
  AppStarRatingFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.step = .5,
    this.max = 5,
    this.starSize,
    this.starSpacing,
    this.onChanged,
    super.initialValue = 0,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppStarRatingFormField;
           return AppFormFieldBinding<double>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppStarRating(
                 value: state.value ?? 0,
                 step: field.step,
                 max: field.max,
                 starSize: field.starSize,
                 starSpacing: field.starSpacing,
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
  final bool required;
  final double? width;
  final double step;
  final double max;
  final double? starSize;
  final double? starSpacing;
  final ValueChanged<double>? onChanged;
  final AppAsyncFieldValidator<double>? asyncValidator;
}
