import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_shadcn_scope.dart';
import 'app_field.dart';
import 'app_form.dart';

typedef AppTextArea = shad.TextArea;

class AppTextAreaFormField extends FormField<String> {
  AppTextAreaFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.hintText,
    this.controller,
    this.focusNode,
    this.required = false,
    this.width,
    this.height,
    this.expandableHeight = false,
    this.minHeight = 72,
    this.maxHeight = double.infinity,
    this.readOnly = false,
    this.onChanged,
    super.initialValue,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : assert(
         controller == null || initialValue == null,
         'initialValue cannot be used with a controller.',
       ),
       super(
         builder: (state) {
           final field = state.widget as AppTextAreaFormField;
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
               child: _AppTextAreaControl(
                 value: state.value ?? field.controller?.text ?? '',
                 controller: field.controller,
                 focusNode: field.focusNode,
                 hintText: field.hintText,
                 height: field.height,
                 expandableHeight: field.expandableHeight,
                 minHeight: field.minHeight,
                 maxHeight: field.maxHeight,
                 enabled: field.enabled,
                 readOnly: field.readOnly,
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
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final bool required;
  final double? width;
  final double? height;
  final bool expandableHeight;
  final double minHeight;
  final double maxHeight;
  final bool readOnly;
  final ValueChanged<String>? onChanged;
  final AppAsyncFieldValidator<String>? asyncValidator;
}

class _AppTextAreaControl extends StatefulWidget {
  const _AppTextAreaControl({
    required this.value,
    required this.hintText,
    required this.height,
    required this.expandableHeight,
    required this.minHeight,
    required this.maxHeight,
    required this.enabled,
    required this.readOnly,
    required this.onChanged,
    this.controller,
    this.focusNode,
  });

  final String value;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final double? height;
  final bool expandableHeight;
  final double minHeight;
  final double maxHeight;
  final bool enabled;
  final bool readOnly;
  final ValueChanged<String> onChanged;

  @override
  State<_AppTextAreaControl> createState() => _AppTextAreaControlState();
}

class _AppTextAreaControlState extends State<_AppTextAreaControl> {
  late final TextEditingController _internalController = TextEditingController(
    text: widget.value,
  );
  bool _syncing = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController;

  @override
  void didUpdateWidget(_AppTextAreaControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_controller.text != widget.value) {
      _syncing = true;
      _controller.value = TextEditingValue(
        text: widget.value,
        selection: TextSelection.collapsed(offset: widget.value.length),
      );
      _syncing = false;
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
    final height =
        widget.height ??
        AppTheme.maybeOf(context)?.controls.textAreaHeight ??
        100;
    return shad.ComponentTheme(
      data: shad.FocusOutlineTheme(
        align: 0,
        border: Border.all(
          color: theme.colorScheme.ring,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: shad.TextArea(
        controller: _controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        placeholder: widget.hintText == null ? null : Text(widget.hintText!),
        initialHeight: height,
        minHeight: widget.minHeight,
        maxHeight: widget.maxHeight,
        expandableHeight: widget.expandableHeight,
        enabled: widget.enabled,
        readOnly: widget.readOnly,
        onChanged: (value) {
          if (!_syncing) widget.onChanged(value);
        },
      ),
    );
  }
}
