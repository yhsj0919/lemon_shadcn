import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
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
  late shad.Country _country;
  shad.PhoneNumber? _lastEmitted;
  bool _syncing = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void initState() {
    super.initState();
    _country =
        widget.value?.country ?? widget.initialCountry ?? shad.Country.china;
    _syncValue(widget.value);
    _controller.addListener(_handleTextChanged);
  }

  @override
  void didUpdateWidget(AppPhoneInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internalController).removeListener(
        _handleTextChanged,
      );
      _controller.addListener(_handleTextChanged);
    }
    if (widget.value != oldWidget.value && widget.value != _lastEmitted) {
      if (widget.value?.country != null) _country = widget.value!.country!;
      _syncValue(widget.value);
    }
  }

  void _syncValue(shad.PhoneNumber? value) {
    final text = value?.toString() ?? _country.dialCode;
    if (_controller.text == text) return;
    _syncing = true;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _syncing = false;
  }

  void _handleTextChanged() {
    if (_syncing) return;
    final detected = _findCountry(_controller.text);
    if (detected != null && detected.dialCode != _country.dialCode) {
      setState(() => _country = detected);
    }
    var number = _controller.text;
    if (number.startsWith(_country.dialCode)) {
      number = number.substring(_country.dialCode.length);
    }
    final value = shad.PhoneNumber(_country, number);
    _lastEmitted = value;
    widget.onChanged?.call(value);
  }

  shad.Country? _findCountry(String phone) {
    final normalized = phone.startsWith('+') ? phone.substring(1) : phone;
    final countries = [...(widget.countries ?? shad.Country.values)]
      ..sort((a, b) => b.dialCode.length.compareTo(a.dialCode.length));
    for (final country in countries) {
      final code = country.dialCode.replaceFirst('+', '');
      if (normalized.startsWith(code)) return country;
    }
    return null;
  }

  void _changeCountry(shad.Country country) {
    var number = _controller.text;
    if (number.startsWith(_country.dialCode)) {
      number = number.substring(_country.dialCode.length);
    } else if (number.startsWith('+')) {
      number = number.substring(1);
    }
    _country = country;
    final text = '${country.dialCode}$number';
    _syncing = true;
    _controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
    _syncing = false;
    _handleTextChanged();
    setState(() {});
  }

  bool _matchesCountry(shad.Country country, String query) {
    final normalized = query.toLowerCase();
    return country.name.toLowerCase().contains(normalized) ||
        country.dialCode.contains(normalized) ||
        country.code.toLowerCase().contains(normalized);
  }

  Widget _flag(shad.Country country) {
    return SizedBox(
      width: 24,
      height: 16,
      child: FittedBox(
        fit: BoxFit.fill,
        child: shad.CountryFlag.fromCountryCode(country.code),
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChanged);
    _internalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return AppControlBox(
      child: AppPromptControlFrame(
        enabled: widget.enabled,
        maintainBorder: true,
        activateOnPointerDown: false,
        child: IgnorePointer(
          ignoring: !widget.enabled,
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.5,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                shad.ButtonStyleOverride(
                  decoration: (context, states, value) => value is BoxDecoration
                      ? value.copyWith(border: const Border())
                      : value,
                  child: shad.Select<shad.Country>(
                    value: _country,
                    enabled: widget.enabled,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 7,
                    ),
                    expandIcon: null,
                    borderRadius: BorderRadius.only(
                      topLeft: theme.radiusMdRadius,
                      bottomLeft: theme.radiusMdRadius,
                    ),
                    popoverAlignment: Alignment.topLeft,
                    popoverAnchorAlignment: Alignment.bottomLeft,
                    popupWidthConstraint: shad.PopoverConstraint.flexible,
                    popupConstraints: const BoxConstraints(
                      maxWidth: 250,
                      maxHeight: 300,
                    ),
                    onChanged: (value) {
                      if (value != null) _changeCountry(value);
                    },
                    itemBuilder: (context, country) => _flag(country),
                    popup: shad.SelectPopup.builder(
                      builder: (context, query) => shad.SelectItemList(
                        children: [
                          for (final country
                              in widget.countries ?? shad.Country.values)
                            if (query == null ||
                                _matchesCountry(country, query))
                              shad.SelectItemButton(
                                value: country,
                                child: Row(
                                  children: [
                                    _flag(country),
                                    const shad.Gap(8),
                                    Expanded(child: Text(country.name)),
                                    const shad.Gap(16),
                                    Text(country.dialCode),
                                  ],
                                ),
                              ),
                        ],
                      ),
                    ).asBuilder,
                  ),
                ),
                Container(width: 1, color: theme.colorScheme.border),
                Expanded(
                  child: shad.TextField(
                    controller: _controller,
                    enabled: widget.enabled,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    keyboardType: widget.onlyNumber
                        ? TextInputType.phone
                        : null,
                    inputFormatters: [
                      if (widget.onlyNumber)
                        FilteringTextInputFormatter.digitsOnly,
                      _AlwaysPrefixedPlus(),
                    ],
                    border: const Border(),
                    borderRadius: BorderRadius.only(
                      topRight: theme.radiusMdRadius,
                      bottomRight: theme.radiusMdRadius,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AlwaysPrefixedPlus extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.startsWith('+')) return newValue;
    return TextEditingValue(
      text: '+${newValue.text}',
      selection: newValue.selection.copyWith(
        baseOffset: newValue.selection.baseOffset + 1,
        extentOffset: newValue.selection.extentOffset + 1,
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
