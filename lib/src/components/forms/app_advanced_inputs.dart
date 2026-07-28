import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'dart:math' show max;

import 'package:flutter/foundation.dart' show listEquals;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_overlay_style.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../actions/app_button.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_prompt_control_frame.dart';
import 'app_option.dart';

typedef AppInput = shad.TextField;
typedef AppFormattedInput = shad.FormattedInput;
typedef AppFormattedInputController = shad.FormattedInputController;
typedef AppFormattedValue = shad.FormattedValue;
typedef AppFormattedValuePart = shad.FormattedValuePart;
typedef AppStaticPart = shad.StaticPart;
typedef AppColorInput = shad.ColorInput;
typedef AppColorInputController = shad.ColorInputController;
typedef AppColorPicker = shad.ColorPicker;
typedef AppColorDerivative = shad.ColorDerivative;
typedef AppColorPickerMode = shad.ColorPickerMode;
typedef AppItemPicker<T> = shad.ItemPicker<T>;
typedef AppItemList<T> = shad.ItemList<T>;
typedef AppItemPickerLayout = shad.ItemPickerLayout;
typedef AppMultipleChoiceController<T> = shad.MultipleChoiceController<T>;

abstract final class AppFormattedParts {
  static shad.FormattedValuePart fixed(String text) =>
      shad.FormattedValuePart(shad.StaticPart(text));

  static shad.FormattedValuePart editable(
    String value, {
    required int length,
    double? width,
    bool obscureText = false,
    Widget? placeholder,
  }) {
    return shad.FormattedValuePart(
      AppEditablePart(
        length: length,
        width: width ?? length * 14 + 8,
        obscureText: obscureText,
        placeholder: placeholder,
      ),
      value,
    );
  }
}

/// Editable formatted segment with vertically centered text.
///
/// This thin App implementation keeps the upstream value/controller protocol
/// while correcting the upstream top-aligned undecorated text field.
class AppEditablePart extends shad.InputPart {
  const AppEditablePart({
    required this.length,
    required this.width,
    this.obscureText = false,
    this.inputFormatters = const [],
    this.placeholder,
  });

  final int length;
  final double width;
  final bool obscureText;
  final List<TextInputFormatter> inputFormatters;
  final Widget? placeholder;

  @override
  bool get canHaveValue => true;

  @override
  Object? get partKey => null;

  @override
  Widget build(BuildContext context, shad.FormattedInputData data) {
    return _AppEditablePartWidget(part: this, data: data);
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is AppEditablePart &&
            other.length == length &&
            other.width == width &&
            other.obscureText == obscureText &&
            listEquals(other.inputFormatters, inputFormatters) &&
            other.placeholder == placeholder;
  }

  @override
  int get hashCode => Object.hash(
    length,
    width,
    obscureText,
    Object.hashAll(inputFormatters),
    placeholder,
  );
}

class _AppEditablePartWidget extends StatefulWidget {
  const _AppEditablePartWidget({required this.part, required this.data});

  final AppEditablePart part;
  final shad.FormattedInputData data;

  @override
  State<_AppEditablePartWidget> createState() => _AppEditablePartWidgetState();
}

class _AppEditablePartWidgetState extends State<_AppEditablePartWidget> {
  late final TextEditingController _controller;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _controller = _AppEditablePartController(
      maxLength: widget.part.length,
      hasPlaceholder: widget.part.placeholder != null,
      text: widget.data.initialValue,
    )..addListener(_textChanged);
    widget.data.controller?.addListener(_formattedValueChanged);
  }

  void _textChanged() {
    if (_syncing) return;
    final formattedController = widget.data.controller;
    if (formattedController == null) return;
    final parts = List<shad.FormattedValuePart>.from(
      formattedController.value.parts,
    );
    var valueIndex = 0;
    for (var index = 0; index < parts.length; index++) {
      if (!parts[index].part.canHaveValue) continue;
      if (valueIndex == widget.data.partIndex) {
        parts[index] = parts[index].withValue(_controller.text);
        break;
      }
      valueIndex++;
    }
    formattedController.value = shad.FormattedValue(parts);
  }

  void _formattedValueChanged() {
    if (_syncing) return;
    final values = widget.data.controller?.value.values;
    if (values == null || widget.data.partIndex >= values.length) return;
    final text = values.elementAt(widget.data.partIndex).value ?? '';
    if (text == _controller.text) return;
    _syncing = true;
    _controller.value = _controller.value.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
      composing: TextRange.empty,
    );
    _syncing = false;
  }

  void _onChanged(String value) {
    if (value.length >= widget.part.length) {
      final next = widget.data.partIndex + 1;
      if (next < widget.data.focusNodes.length) {
        widget.data.focusNodes[next].requestFocus();
      }
    }
  }

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.backspace ||
            event.logicalKey == LogicalKeyboardKey.arrowLeft) &&
        _controller.selection.isCollapsed &&
        _controller.selection.baseOffset == 0) {
      final previous = widget.data.partIndex - 1;
      if (previous >= 0) {
        widget.data.focusNodes[previous].requestFocus();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  @override
  void didUpdateWidget(covariant _AppEditablePartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.data.controller != widget.data.controller) {
      oldWidget.data.controller?.removeListener(_formattedValueChanged);
      widget.data.controller?.addListener(_formattedValueChanged);
    }
    _formattedValueChanged();
  }

  @override
  void dispose() {
    widget.data.controller?.removeListener(_formattedValueChanged);
    _controller.removeListener(_textChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return Focus(
      onKeyEvent: _onKeyEvent,
      child: SizedBox(
        width: widget.part.width,
        child: shad.ComponentTheme(
          data: const shad.FocusOutlineTheme(
            border: Border.fromBorderSide(BorderSide.none),
          ),
          child: shad.TextField(
            focusNode: widget.data.focusNode,
            controller: _controller,
            enabled: widget.data.enabled,
            maxLength: widget.part.length,
            onChanged: _onChanged,
            inputFormatters: widget.part.inputFormatters,
            placeholder: widget.part.placeholder,
            obscureText: widget.part.obscureText,
            maxLines: 1,
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            padding: EdgeInsets.symmetric(horizontal: 6 * theme.scaling),
            decoration: const BoxDecoration(),
            border: const Border.fromBorderSide(BorderSide.none),
            style: DefaultTextStyle.of(
              context,
            ).style.merge(theme.typography.mono),
          ),
        ),
      ),
    );
  }
}

class _AppEditablePartController extends TextEditingController {
  _AppEditablePartController({
    required this.maxLength,
    required this.hasPlaceholder,
    super.text,
  });

  final int maxLength;
  final bool hasPlaceholder;

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    final composingIsUsable =
        withComposing && value.composing.isValid && value.isComposingRangeValid;
    final mutedStyle = style?.copyWith(
      color: shad.Theme.of(context).colorScheme.mutedForeground,
    );

    if (!composingIsUsable) {
      if (text.isEmpty && hasPlaceholder) return const TextSpan();
      return TextSpan(
        style: style,
        children: [
          TextSpan(text: text),
          TextSpan(
            text: '_' * max(0, maxLength - text.length),
            style: mutedStyle,
          ),
        ],
      );
    }

    final before = value.composing.textBefore(value.text);
    final inside = value.composing.textInside(value.text);
    final after = value.composing.textAfter(value.text);
    final length = before.length + inside.length + after.length;
    if (length == 0 && hasPlaceholder) return const TextSpan();
    return TextSpan(
      style: style,
      children: [
        TextSpan(text: before),
        TextSpan(
          text: inside,
          style: style?.merge(
            const TextStyle(decoration: TextDecoration.underline),
          ),
        ),
        TextSpan(text: after),
        TextSpan(text: '_' * max(0, maxLength - length), style: mutedStyle),
      ],
    );
  }
}

/// Product-facing single choice that consumes formatted [AppOption] values.
class AppMultipleChoice<V> extends StatelessWidget {
  const AppMultipleChoice({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.allowUnselect = false,
    this.enabled = true,
    this.spacing = 8,
  });

  final List<AppOption<V>> options;
  final V? value;
  final ValueChanged<V?>? onChanged;
  final bool allowUnselect;
  final bool enabled;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return shad.MultipleChoice<V>(
      value: value,
      onChanged: onChanged,
      enabled: enabled,
      allowUnselect: allowUnselect,
      child: Wrap(
        spacing: spacing,
        runSpacing: spacing,
        children: [
          for (final option in options)
            Builder(
              builder: (context) {
                final selected =
                    shad.Choice.getValue<V>(context)?.contains(option.value) ??
                    false;
                final canChoose =
                    enabled && !option.disabled && onChanged != null;
                final button = selected
                    ? AppButton.secondary(
                        onPressed: canChoose
                            ? () => shad.Choice.choose(context, option.value)
                            : null,
                        child: option.child ?? Text(option.label),
                      )
                    : AppButton.outline(
                        onPressed: canChoose
                            ? () => shad.Choice.choose(context, option.value)
                            : null,
                        child: option.child ?? Text(option.label),
                      );
                return button;
              },
            ),
        ],
      ),
    );
  }
}

class AppMultipleChoiceFormField<V> extends FormField<V> {
  AppMultipleChoiceFormField({
    super.key,
    required this.options,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.allowUnselect = false,
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
           final field = state.widget as AppMultipleChoiceFormField<V>;
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
               child: AppMultipleChoice<V>(
                 options: field.options,
                 value: state.value,
                 enabled: field.enabled,
                 allowUnselect: field.allowUnselect,
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
  final bool allowUnselect;
  final ValueChanged<V?>? onChanged;
  final AppAsyncFieldValidator<V>? asyncValidator;
}

class AppItemPickerFormField<V> extends FormField<V> {
  AppItemPickerFormField({
    super.key,
    required this.options,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.placeholder,
    this.title,
    this.layout,
    this.mode,
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
           final field = state.widget as AppItemPickerFormField<V>;
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
               child: AppControlBox(
                 child: _AppItemPickerControl<V>(
                   options: field.options,
                   value: state.value,
                   placeholder: field.placeholder,
                   title: field.title,
                   layout: field.layout,
                   mode: field.mode ?? shad.PromptMode.popover,
                   enabled: field.enabled,
                   onChanged: (value) {
                     state.didChange(value);
                     field.onChanged?.call(value);
                   },
                 ),
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
  final Widget? placeholder;
  final Widget? title;
  final shad.ItemPickerLayout? layout;
  final shad.PromptMode? mode;
  final ValueChanged<V?>? onChanged;
  final AppAsyncFieldValidator<V>? asyncValidator;
}

class _AppItemPickerControl<V> extends StatefulWidget {
  const _AppItemPickerControl({
    required this.options,
    required this.value,
    required this.mode,
    required this.enabled,
    required this.onChanged,
    this.placeholder,
    this.title,
    this.layout,
  });

  final List<AppOption<V>> options;
  final V? value;
  final shad.PromptMode mode;
  final bool enabled;
  final ValueChanged<V?> onChanged;
  final Widget? placeholder;
  final Widget? title;
  final shad.ItemPickerLayout? layout;

  @override
  State<_AppItemPickerControl<V>> createState() =>
      _AppItemPickerControlState<V>();
}

class _AppItemPickerControlState<V> extends State<_AppItemPickerControl<V>> {
  bool _active = false;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return TapRegion(
      onTapOutside: (_) {
        if (_active) setState(() => _active = false);
      },
      child: Listener(
        onPointerDown: widget.enabled
            ? (_) {
                if (!_active) setState(() => _active = true);
              }
            : null,
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            shad.ComponentTheme(
              data: AppOverlayStyle.cardTheme(context),
              child: shad.ComponentTheme(
                data: const shad.FocusOutlineTheme(
                  border: Border.fromBorderSide(BorderSide.none),
                ),
                child: IgnorePointer(
                  ignoring: !widget.enabled,
                  child: shad.ItemPicker<V>(
                    items: shad.ItemList(
                      widget.options.map((option) => option.value).toList(),
                    ),
                    value: widget.value,
                    placeholder: widget.placeholder,
                    title: widget.title,
                    layout: widget.layout,
                    mode: widget.mode,
                    builder: (context, value) {
                      final option = widget.options.firstWhere(
                        (option) => option.value == value,
                      );
                      return option.child ?? Text(option.label);
                    },
                    onChanged: (value) {
                      if (_active) setState(() => _active = false);
                      widget.onChanged(value);
                    },
                  ),
                ),
              ),
            ),
            if (_active)
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(theme.radiusMd),
                      border: Border.all(
                        color: theme.colorScheme.ring,
                        width: 1,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class AppColorInputFormField extends FormField<shad.ColorDerivative> {
  AppColorInputFormField({
    super.key,
    required super.initialValue,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.showAlpha,
    this.enableEyeDropper = false,
    this.onChanged,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppColorInputFormField;
           return AppFormFieldBinding<shad.ColorDerivative>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppControlBox(
                 child: _AppColorInputControl(
                   value: state.value!,
                   enabled: field.enabled,
                   showAlpha: field.showAlpha,
                   enableEyeDropper: field.enableEyeDropper,
                   onChanged: (value) {
                     state.didChange(value);
                     field.onChanged?.call(value);
                   },
                 ),
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
  final bool? showAlpha;
  final bool enableEyeDropper;
  final ValueChanged<shad.ColorDerivative>? onChanged;
  final AppAsyncFieldValidator<shad.ColorDerivative>? asyncValidator;
}

class _AppColorInputControl extends StatelessWidget {
  const _AppColorInputControl({
    required this.value,
    required this.enabled,
    required this.enableEyeDropper,
    required this.onChanged,
    this.showAlpha,
  });

  final shad.ColorDerivative value;
  final bool enabled;
  final bool enableEyeDropper;
  final bool? showAlpha;
  final ValueChanged<shad.ColorDerivative> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return AppPromptControlFrame(
      enabled: enabled,
      child: shad.ComponentTheme(
        data: shad.ColorInputTheme(
          popoverPadding: EdgeInsets.all(8 * theme.scaling),
        ),
        child: shad.ComponentTheme(
          data: const shad.ColorPickerTheme(
            spacing: 8,
            controlSpacing: 6,
            sliderSize: 18,
          ),
          child: shad.ObjectFormField<shad.ColorDerivative>(
            value: value,
            enabled: enabled,
            mode: shad.PromptMode.popover,
            placeholder: const Text('选择颜色'),
            immediateValueChange: true,
            builder: (context, value) => Container(
              constraints: BoxConstraints(
                minWidth: 28 * theme.scaling,
                minHeight: 28 * theme.scaling,
              ),
              decoration: BoxDecoration(
                color: value.toColor(),
                borderRadius: BorderRadius.circular(theme.radiusSm),
                border: Border.all(color: theme.colorScheme.border),
              ),
            ),
            onChanged: (value) {
              if (value != null) onChanged(value);
            },
            editorBuilder: (context, handler) => SizedBox(
              width: 340,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.topLeft,
                child: DefaultTextStyle.merge(
                  textAlign: TextAlign.center,
                  child: SizedBox(
                    width: 480,
                    height: 400,
                    child: shad.ComponentTheme(
                      data: const shad.TextFieldTheme(
                        padding: EdgeInsets.only(left: 18, right: 4),
                      ),
                      child: shad.ColorPicker(
                        value: handler.value ?? value,
                        showAlpha: showAlpha ?? true,
                        enableEyeDropper: enableEyeDropper,
                        spacing: 8,
                        controlSpacing: 6,
                        sliderSize: 18,
                        onChanging: (value) => handler.value = value,
                        onChanged: (value) => handler.value = value,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppFormattedInputFormField extends FormField<shad.FormattedValue> {
  AppFormattedInputFormField({
    super.key,
    required super.initialValue,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.leading,
    this.trailing,
    this.onChanged,
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppFormattedInputFormField;
           return AppFormFieldBinding<shad.FormattedValue>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: _AppFormattedInputControl(
                 value: state.value!,
                 enabled: field.enabled,
                 leading: field.leading,
                 trailing: field.trailing,
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
  final Widget? leading;
  final Widget? trailing;
  final ValueChanged<shad.FormattedValue>? onChanged;
  final AppAsyncFieldValidator<shad.FormattedValue>? asyncValidator;
}

class _AppFormattedInputControl extends StatefulWidget {
  const _AppFormattedInputControl({
    required this.value,
    required this.enabled,
    required this.onChanged,
    this.leading,
    this.trailing,
  });

  final shad.FormattedValue value;
  final bool enabled;
  final ValueChanged<shad.FormattedValue> onChanged;
  final Widget? leading;
  final Widget? trailing;

  @override
  State<_AppFormattedInputControl> createState() =>
      _AppFormattedInputControlState();
}

class _AppFormattedInputControlState extends State<_AppFormattedInputControl> {
  late final shad.FormattedInputController _controller;
  shad.FormattedValue? _lastEmittedValue;
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    _controller = shad.FormattedInputController(widget.value)
      ..addListener(_controllerChanged);
  }

  void _controllerChanged() {
    if (_syncing) return;
    final value = _controller.value;
    _lastEmittedValue = value;
    widget.onChanged(value);
  }

  @override
  void didUpdateWidget(covariant _AppFormattedInputControl oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (identical(widget.value, _lastEmittedValue)) {
      _lastEmittedValue = null;
      return;
    }
    if (widget.value != _controller.value) {
      _syncing = true;
      try {
        _controller.value = widget.value;
      } finally {
        _syncing = false;
      }
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_controllerChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = AppTheme.maybeOf(context)?.controls.height ?? 36;
    final scaling = shad.Theme.of(context).scaling;
    return AppControlBox(
      child: shad.ComponentTheme<shad.FormattedInputTheme>(
        data: shad.FormattedInputTheme(height: height / scaling),
        child: shad.FormattedInput(
          controller: _controller,
          enabled: widget.enabled,
          leading: widget.leading,
          trailing: widget.trailing,
        ),
      ),
    );
  }
}
