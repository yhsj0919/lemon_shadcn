import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_shadcn_scope.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_input_group.dart';

typedef AppFieldValidator<T> = String? Function(T? value);

class AppTextFormField extends FormField<String> {
  const AppTextFormField({
    super.key,
    this.label,
    this.name,
    this.description,
    this.hintText,
    this.controller,
    this.focusNode,
    this.required = false,
    this.width,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLength,
    this.leading,
    this.trailing,
    this.features,
    this.onChanged,
    this.onSubmitted,
    super.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.errorBuilder,
    super.initialValue,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : assert(
         controller == null || initialValue == null,
         'initialValue cannot be used with a controller.',
       ),
       super(builder: _buildField);

  AppTextFormField.email({
    super.key,
    this.label = 'Email',
    this.name,
    this.description,
    this.hintText,
    this.controller,
    this.focusNode,
    this.required = false,
    this.width,
    this.autofocus = false,
    this.leading,
    this.trailing,
    this.features,
    this.onChanged,
    this.onSubmitted,
    super.enabled = true,
    this.readOnly = false,
    super.onSaved,
    AppFieldValidator<String>? validator,
    this.asyncValidator,
    super.errorBuilder,
    super.initialValue,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : assert(
         controller == null || initialValue == null,
         'initialValue cannot be used with a controller.',
       ),
       obscureText = false,
       showObscureToggle = false,
       keyboardType = TextInputType.emailAddress,
       textInputAction = TextInputAction.next,
       autofillHints = const [AutofillHints.email],
       autocorrect = false,
       enableSuggestions = false,
       maxLength = null,
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
         builder: _buildField,
       );

  AppTextFormField.password({
    super.key,
    this.label = 'Password',
    this.name,
    this.description,
    this.hintText,
    this.controller,
    this.focusNode,
    this.required = false,
    this.width,
    this.autofocus = false,
    this.showObscureToggle = true,
    bool newPassword = false,
    this.leading,
    this.trailing,
    this.features,
    this.onChanged,
    this.onSubmitted,
    super.enabled = true,
    this.readOnly = false,
    this.inputFormatters,
    super.onSaved,
    AppFieldValidator<String>? validator,
    this.asyncValidator,
    super.errorBuilder,
    super.initialValue,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : assert(
         controller == null || initialValue == null,
         'initialValue cannot be used with a controller.',
       ),
       obscureText = true,
       keyboardType = TextInputType.visiblePassword,
       textInputAction = TextInputAction.next,
       autofillHints = [
         newPassword ? AutofillHints.newPassword : AutofillHints.password,
       ],
       autocorrect = false,
       enableSuggestions = false,
       maxLength = null,
       super(
         validator: validator ?? (required ? AppValidators.required() : null),
         builder: _buildField,
       );

  final String? label;
  final String? name;
  final String? description;
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool required;
  final double? width;
  final bool obscureText;
  final bool showObscureToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLength;
  final Widget? leading;
  final Widget? trailing;
  final List<shad.InputFeature>? features;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final AppAsyncFieldValidator<String>? asyncValidator;

  static Widget _buildField(FormFieldState<String> state) {
    final field = state.widget as AppTextFormField;
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
        child: AppTextField(
          value: state.value ?? field.controller?.text ?? '',
          controller: field.controller,
          focusNode: field.focusNode,
          hintText: field.hintText,
          obscureText: field.obscureText,
          showObscureToggle: field.showObscureToggle,
          keyboardType: field.keyboardType,
          textInputAction: field.textInputAction,
          autofillHints: field.autofillHints,
          autofocus: field.autofocus,
          autocorrect: field.autocorrect,
          enableSuggestions: field.enableSuggestions,
          maxLength: field.maxLength,
          leading: field.leading,
          trailing: field.trailing,
          features: field.features,
          enabled: field.enabled,
          readOnly: field.readOnly,
          inputFormatters: field.inputFormatters,
          onChanged: (value) {
            state.didChange(value);
            field.onChanged?.call(value);
          },
          onSubmitted: field.onSubmitted,
        ),
      ),
    );
  }
}

class AppTextField extends StatefulWidget {
  const AppTextField({
    super.key,
    required this.value,
    required this.onChanged,
    this.controller,
    this.focusNode,
    this.hintText,
    this.obscureText = false,
    this.showObscureToggle = false,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.autofocus = false,
    this.autocorrect = true,
    this.enableSuggestions = true,
    this.maxLength,
    this.leading,
    this.trailing,
    this.features,
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
  final bool showObscureToggle;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool autofocus;
  final bool autocorrect;
  final bool enableSuggestions;
  final int? maxLength;
  final Widget? leading;
  final Widget? trailing;
  final List<shad.InputFeature>? features;
  final bool enabled;
  final bool readOnly;
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String> onChanged;
  final ValueChanged<String>? onSubmitted;

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late TextEditingController _internalController;
  late bool _obscureText;
  bool _syncingValue = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.obscureText;
    _internalController = TextEditingController(text: widget.value);
    if (widget.controller != null && widget.controller!.text != widget.value) {
      widget.controller!.text = widget.value;
    }
  }

  @override
  void didUpdateWidget(AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
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
    final theme = shad.Theme.of(context);
    final features = <shad.InputFeature>[
      if (widget.leading != null)
        shad.InputFeature.leading(AppInputGroupAddon(child: widget.leading!)),
      ...?widget.features,
      if (widget.trailing != null)
        shad.InputFeature.trailing(AppInputGroupAddon(child: widget.trailing!)),
      if (widget.showObscureToggle)
        shad.InputFeature.trailing(
          Semantics(
            button: true,
            label: _obscureText ? 'Show password' : 'Hide password',
            child: shad.IconButton.text(
              density: shad.ButtonDensity.compact,
              enabled: widget.enabled,
              onPressed: widget.enabled
                  ? () => setState(() => _obscureText = !_obscureText)
                  : null,
              icon: Icon(
                _obscureText ? shad.LucideIcons.eye : shad.LucideIcons.eyeOff,
              ),
            ),
          ),
        ),
    ];
    return AppControlBox(
      child: shad.TextField(
        border: Border.all(
          color: theme.colorScheme.border,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
        controller: _controller,
        focusNode: widget.focusNode,
        padding: EdgeInsets.symmetric(
          horizontal:
              AppTheme.maybeOf(context)?.controls.horizontalPadding ?? 12,
        ),
        textAlignVertical: TextAlignVertical.center,
        hintText: widget.hintText,
        obscureText: _obscureText,
        keyboardType: widget.keyboardType,
        textInputAction: widget.textInputAction,
        autofillHints: widget.autofillHints,
        autofocus: widget.autofocus,
        autocorrect: widget.autocorrect,
        enableSuggestions: widget.enableSuggestions,
        maxLength: widget.maxLength,
        features: features,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        inputFormatters: widget.inputFormatters,
        onChanged: (value) {
          if (!_syncingValue) widget.onChanged(value);
        },
        onSubmitted: widget.onSubmitted,
      ),
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

  static AppFieldValidator<String> exactLength(
    int length, {
    String? message,
    bool allowEmpty = false,
  }) {
    assert(length >= 0);
    return (value) {
      final text = value ?? '';
      if (text.isEmpty && allowEmpty) return null;
      return text.runes.length == length
          ? null
          : message ?? 'Enter exactly $length characters.';
    };
  }
}
