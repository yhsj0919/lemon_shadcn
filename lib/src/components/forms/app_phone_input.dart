import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_prompt_control_frame.dart';

class AppPhoneInput extends StatefulWidget {
  const AppPhoneInput({
    super.key,
    this.value,
    this.onChanged,
    this.controller,
    this.initialCountry,
    this.onlyNumber = true,
    this.countries,
    this.searchPlaceholder,
    this.enabled = true,
  });

  final shad.PhoneNumber? value;
  final ValueChanged<shad.PhoneNumber?>? onChanged;
  final TextEditingController? controller;
  final shad.Country? initialCountry;
  final bool onlyNumber;
  final List<shad.Country>? countries;
  final Widget? searchPlaceholder;
  final bool enabled;

  @override
  State<AppPhoneInput> createState() => _AppPhoneInputState();
}

class _AppPhoneInputState extends State<AppPhoneInput> {
  late final TextEditingController _internalController =
      TextEditingController();
  shad.PhoneNumber? _lastEmitted;
  bool _syncing = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _syncValue(widget.value);
  }

  @override
  void didUpdateWidget(AppPhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller ||
        (widget.value != oldWidget.value && widget.value != _lastEmitted)) {
      _syncValue(widget.value);
    }
  }

  void _syncValue(shad.PhoneNumber? value) {
    final text = value?.toString() ?? '';
    if (_controller.text == text) return;
    _syncing = true;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _syncing = false;
  }

  @override
  void dispose() {
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppControlBox(
      child: AppPromptControlFrame(
        enabled: widget.enabled,
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.5,
            child: shad.PhoneInput(
              initialValue: widget.value,
              initialCountry:
                  widget.value?.country ??
                  widget.initialCountry ??
                  shad.Country.china,
              controller: _controller,
              onlyNumber: widget.onlyNumber,
              countries: widget.countries,
              searchPlaceholder: widget.searchPlaceholder,
              onChanged: (value) {
                if (_syncing) return;
                _lastEmitted = value;
                widget.onChanged?.call(value);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class AppPhoneInputFormField extends FormField<shad.PhoneNumber> {
  AppPhoneInputFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.initialCountry,
    this.onlyNumber = true,
    this.countries,
    this.searchPlaceholder,
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
           final field = state.widget as AppPhoneInputFormField;
           return AppFormFieldBinding<shad.PhoneNumber>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppPhoneInput(
                 value: state.value,
                 initialCountry: field.initialCountry,
                 onlyNumber: field.onlyNumber,
                 countries: field.countries,
                 searchPlaceholder: field.searchPlaceholder,
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
  final shad.Country? initialCountry;
  final bool onlyNumber;
  final List<shad.Country>? countries;
  final Widget? searchPlaceholder;
  final ValueChanged<shad.PhoneNumber?>? onChanged;
  final AppAsyncFieldValidator<shad.PhoneNumber>? asyncValidator;
}
