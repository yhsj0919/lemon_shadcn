import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';
import 'app_field.dart';
import 'app_form.dart';

typedef AppChipParser<T> = T? Function(String text);
typedef AppChipLabelBuilder<T> = String Function(T value);

/// Controlled chip input. String chips work without a parser; domain objects
/// can provide [parseChip] while Form values remain formatted `List<T>` data.
class AppChipInput<T> extends StatefulWidget {
  const AppChipInput({
    super.key,
    required this.value,
    required this.onChanged,
    this.parseChip,
    this.labelBuilder,
    this.placeholder,
    this.enabled = true,
    this.allowDuplicates = false,
    this.maxItems,
    this.focusNode,
    this.autofocus = false,
  });

  final List<T> value;
  final ValueChanged<List<T>>? onChanged;
  final AppChipParser<T>? parseChip;
  final AppChipLabelBuilder<T>? labelBuilder;
  final Widget? placeholder;
  final bool enabled;
  final bool allowDuplicates;
  final int? maxItems;
  final FocusNode? focusNode;
  final bool autofocus;

  @override
  State<AppChipInput<T>> createState() => _AppChipInputState<T>();
}

class _AppChipInputState<T> extends State<AppChipInput<T>> {
  late final shad.ChipEditingController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = shad.ChipEditingController<T>();
    _replaceChips(widget.value);
  }

  @override
  void didUpdateWidget(covariant AppChipInput<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(_controller.chips, widget.value)) {
      _replaceChips(widget.value);
    }
  }

  // Upstream 0.0.53 leaves removed entries in its private chip map when the
  // chips setter replaces a list. Clearing text first keeps controlled values
  // and Flutter Form reset in lockstep without patching upstream code.
  void _replaceChips(List<T> chips) {
    _controller.text = '';
    _controller.chips = chips;
  }

  String _label(T value) => widget.labelBuilder?.call(value) ?? '$value';

  T? _parse(String raw) {
    final text = raw.trim();
    final maxItems = widget.maxItems;
    if (text.isEmpty ||
        (maxItems != null && _controller.chips.length >= maxItems)) {
      return null;
    }
    final parsed = widget.parseChip?.call(text) ?? text as T;
    if (parsed == null ||
        (!widget.allowDuplicates && _controller.chips.contains(parsed))) {
      return null;
    }
    return parsed;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final metrics =
        AppTheme.maybeOf(context)?.controls ?? const AppControlMetrics();
    final contentHeight = metrics.borderedContentHeight;
    final secondaryTheme =
        shad.ComponentTheme.maybeOf<shad.SecondaryButtonTheme>(context) ??
        const shad.SecondaryButtonTheme();
    Decoration chipDecoration(
      BuildContext context,
      Set<WidgetState> states,
      Decoration current,
    ) {
      if (current is! BoxDecoration) return current;
      return current.copyWith(
        color: theme.colorScheme.mutedForeground.withValues(alpha: 0.16),
      );
    }

    return shad.ComponentTheme(
      data: shad.FocusOutlineTheme(
        align: 0,
        border: Border.all(
          color: theme.colorScheme.ring,
          width: 1,
          strokeAlign: BorderSide.strokeAlignInside,
        ),
      ),
      child: shad.ComponentTheme(
        data: secondaryTheme.copyWith(decoration: () => chipDecoration),
        child: AppControlBox(
          contentHeight: contentHeight,
          child: shad.ChipInput<T>(
            controller: _controller,
            focusNode: widget.focusNode,
            autofocus: widget.autofocus,
            enabled: widget.enabled && widget.onChanged != null,
            padding: EdgeInsets.symmetric(
              horizontal: metrics.horizontalPadding,
            ),
            textAlignVertical: TextAlignVertical.center,
            placeholder: widget.placeholder,
            chipBuilder: (context, chip) => Text(_label(chip)),
            onChipSubmitted: _parse,
            onChipsChanged: (chips) =>
                widget.onChanged?.call(List<T>.of(chips)),
          ),
        ),
      ),
    );
  }
}

class AppChipInputFormField<T> extends FormField<List<T>> {
  AppChipInputFormField({
    super.key,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.parseChip,
    this.labelBuilder,
    this.placeholder,
    this.allowDuplicates = false,
    this.maxItems,
    this.onChanged,
    this.focusNode,
    this.autofocus = false,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppChipInputFormField<T>;
           return AppFormFieldBinding<List<T>>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppChipInput<T>(
                 value: state.value ?? const [],
                 parseChip: field.parseChip,
                 labelBuilder: field.labelBuilder,
                 placeholder: field.placeholder,
                 allowDuplicates: field.allowDuplicates,
                 maxItems: field.maxItems,
                 focusNode: field.focusNode,
                 autofocus: field.autofocus,
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
  final AppChipParser<T>? parseChip;
  final AppChipLabelBuilder<T>? labelBuilder;
  final Widget? placeholder;
  final bool allowDuplicates;
  final int? maxItems;
  final ValueChanged<List<T>>? onChanged;
  final FocusNode? focusNode;
  final bool autofocus;
  final AppAsyncFieldValidator<List<T>>? asyncValidator;
}
