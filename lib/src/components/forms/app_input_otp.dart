import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';
import 'app_field.dart';
import 'app_form.dart';

class AppInputOtp extends StatefulWidget {
  const AppInputOtp({
    super.key,
    this.length = 6,
    this.initialValue,
    this.onChanged,
    this.onSubmitted,
    this.digitsOnly = true,
    this.obscured = false,
    this.readOnly = false,
    this.separatorEvery,
  }) : assert(length > 0),
       assert(separatorEvery == null || separatorEvery > 0);

  final int length;
  final String? initialValue;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool digitsOnly;
  final bool obscured;
  final bool readOnly;
  final int? separatorEvery;

  @override
  State<AppInputOtp> createState() => _AppInputOtpState();
}

class _AppInputOtpState extends State<AppInputOtp> {
  int _generation = 0;
  String? _lastEmitted;

  @override
  void didUpdateWidget(AppInputOtp oldWidget) {
    super.didUpdateWidget(oldWidget);
    final structureChanged =
        widget.length != oldWidget.length ||
        widget.digitsOnly != oldWidget.digitsOnly ||
        widget.obscured != oldWidget.obscured ||
        widget.readOnly != oldWidget.readOnly ||
        widget.separatorEvery != oldWidget.separatorEvery;
    final externalValueChanged =
        widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _lastEmitted;
    if (structureChanged || externalValueChanged) _generation++;
  }

  List<shad.InputOTPChild> _buildChildren() {
    final children = <shad.InputOTPChild>[];
    for (var index = 0; index < widget.length; index++) {
      if (index > 0 &&
          widget.separatorEvery != null &&
          index % widget.separatorEvery! == 0) {
        children.add(shad.InputOTPChild.separator);
      }
      children.add(
        shad.InputOTPChild.character(
          allowDigit: widget.digitsOnly,
          allowLowercaseAlphabet: !widget.digitsOnly,
          allowUppercaseAlphabet: !widget.digitsOnly,
          obscured: widget.obscured,
          readOnly: widget.readOnly,
        ),
      );
    }
    return children;
  }

  shad.OTPCodepointList? _codepoints(String? value) {
    if (value == null) return null;
    return value.runes.take(widget.length).toList();
  }

  String _string(shad.OTPCodepointList value) => value.otpToString();

  @override
  Widget build(BuildContext context) {
    final metrics =
        AppTheme.maybeOf(context)?.controls ?? const AppControlMetrics();
    final contentHeight = metrics.borderedContentHeight;
    final ancestor = shad.ComponentTheme.maybeOf<shad.InputOTPTheme>(context);
    final theme = (ancestor ?? const shad.InputOTPTheme()).copyWith(
      height: () => contentHeight,
      spacing: () => metrics.contentGap,
    );
    return shad.ComponentTheme<shad.InputOTPTheme>(
      data: theme,
      child: AppControlBox(
        contentHeight: contentHeight,
        alignment: AlignmentDirectional.centerStart,
        child: shad.InputOTP(
          key: ValueKey(_generation),
          children: _buildChildren(),
          initialValue: _codepoints(widget.initialValue),
          onChanged: (value) {
            final text = _string(value);
            _lastEmitted = text;
            widget.onChanged?.call(text);
          },
          onSubmitted: (value) {
            final text = _string(value);
            _lastEmitted = text;
            widget.onSubmitted?.call(text);
          },
        ),
      ),
    );
  }
}

class AppInputOtpFormField extends FormField<String> {
  AppInputOtpFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.length = 6,
    this.digitsOnly = true,
    this.obscured = false,
    this.separatorEvery,
    this.onChanged,
    this.onSubmitted,
    super.initialValue = '',
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppInputOtpFormField;
           return AppFormFieldBinding<String>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppInputOtp(
                 length: field.length,
                 initialValue: state.value,
                 digitsOnly: field.digitsOnly,
                 obscured: field.obscured,
                 readOnly: !field.enabled,
                 separatorEvery: field.separatorEvery,
                 onChanged: (value) {
                   state.didChange(value);
                   field.onChanged?.call(value);
                 },
                 onSubmitted: field.onSubmitted,
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
  final int length;
  final bool digitsOnly;
  final bool obscured;
  final int? separatorEvery;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final AppAsyncFieldValidator<String>? asyncValidator;
}
