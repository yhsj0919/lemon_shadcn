import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_field.dart';

typedef AppFieldValidator<T> = String? Function(T? value);

class AppTextFormField extends FormField<String> {
  AppTextFormField({
    super.key,
    this.label,
    this.description,
    this.hintText,
    this.controller,
    this.focusNode,
    this.required = false,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.onChanged,
    this.onSubmitted,
    super.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    super.onSaved,
    super.validator,
    super.errorBuilder,
    super.initialValue,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : assert(
         controller == null || initialValue == null,
         'initialValue cannot be used with a controller.',
       ),
       super(
         builder: (state) {
           final field = state.widget as AppTextFormField;
           return AppField(
             label: field.label,
             description: field.description,
             errorText: state.errorText,
             required: field.required,
             child: _AppTextFieldControl(
               value: state.value ?? field.controller?.text ?? '',
               controller: field.controller,
               focusNode: field.focusNode,
               hintText: field.hintText,
               obscureText: field.obscureText,
               keyboardType: field.keyboardType,
               textInputAction: field.textInputAction,
               autofillHints: field.autofillHints,
               enabled: field.enabled,
               readOnly: field.readOnly,
               inputFormatters: field.inputFormatters,
               onChanged: (value) {
                 state.didChange(value);
                 field.onChanged?.call(value);
               },
               onSubmitted: field.onSubmitted,
             ),
           );
         },
       );

  AppTextFormField.email({
    super.key,
    this.label = 'Email',
    this.description,
    this.hintText,
    this.controller,
    this.focusNode,
    this.required = false,
    this.onChanged,
    this.onSubmitted,
    super.enabled = true,
    this.readOnly = false,
    super.onSaved,
    AppFieldValidator<String>? validator,
    super.initialValue,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : obscureText = false,
       keyboardType = TextInputType.emailAddress,
       textInputAction = TextInputAction.next,
       autofillHints = const [AutofillHints.email],
       inputFormatters = null,
       super(
         validator:
             validator ??
             (required
                 ? AppValidators.compose([
                     AppValidators.required(),
                     AppValidators.email(),
                   ])
                 : AppValidators.email(allowEmpty: true)),
         builder: (state) {
           final field = state.widget as AppTextFormField;
           return AppField(
             label: field.label,
             description: field.description,
             errorText: state.errorText,
             required: field.required,
             child: _AppTextFieldControl(
               value: state.value ?? field.controller?.text ?? '',
               controller: field.controller,
               focusNode: field.focusNode,
               hintText: field.hintText,
               keyboardType: field.keyboardType,
               textInputAction: field.textInputAction,
               autofillHints: field.autofillHints,
               enabled: field.enabled,
               readOnly: field.readOnly,
               onChanged: (value) {
                 state.didChange(value);
                 field.onChanged?.call(value);
               },
               onSubmitted: field.onSubmitted,
             ),
           );
         },
       );

  final String? label;
  final String? description;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool required;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
}

class _AppTextFieldControl extends StatefulWidget {
  const _AppTextFieldControl({
    required this.value,
    required this.onChanged,
    this.controller,
    this.focusNode,
    this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    this.onSubmitted,
  });

  final String value;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<_AppTextFieldControl> createState() => _AppTextFieldControlState();
}

class _AppTextFieldControlState extends State<_AppTextFieldControl> {
  late TextEditingController _internalController;
  bool _syncingValue = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _internalController = TextEditingController(text: widget.value);
    if (widget.controller != null && widget.controller!.text != widget.value) {
      widget.controller!.text = widget.value;
    }
  }

  @override
  void didUpdateWidget(_AppTextFieldControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _syncingValue = true;
      _controller.value = _controller.value.copyWith(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
        composing: TextRange.empty,
      );
      _syncingValue = false;
    }
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return shad.TextField(
      controller: _controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText,
      obscureText: widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      autofillHints: widget.autofillHints,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      inputFormatters: widget.inputFormatters,
      onChanged: (value) {
        if (!_syncingValue) widget.onChanged(value);
      },
      onSubmitted: widget.onSubmitted,
    );
  }
}

abstract final class AppValidators {
  static AppFieldValidator<String> required({
    String message = 'This field is required.',
  }) {
    return (value) => value == null || value.trim().isEmpty ? message : null;
  }

  static AppFieldValidator<String> email({
    String message = 'Enter a valid email address.',
    bool allowEmpty = false,
  }) {
    final expression = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return (value) {
      if (value == null || value.trim().isEmpty) {
        return allowEmpty ? null : message;
      }
      return expression.hasMatch(value.trim()) ? null : message;
    };
  }

  static AppFieldValidator<T> compose<T>(
    Iterable<AppFieldValidator<T>> validators,
  ) {
    return (value) {
      for (final validator in validators) {
        final error = validator(value);
        if (error != null) return error;
      }
      return null;
    };
  }
}
