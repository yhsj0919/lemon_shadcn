import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_density.dart';
import 'app_field.dart';
import 'app_form.dart';
import 'app_input_group.dart';

/// A non-editable, text-only control with an optional trailing action.
///
/// [onTap] only applies to the display area. Interactive widgets supplied as
/// [trailing] keep their own tap handling.
class AppTextDisplay extends StatelessWidget {
  const AppTextDisplay({
    super.key,
    required this.text,
    this.placeholder,
    this.trailing,
    this.onTap,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
    this.density = AppDensity.normal,
    this.chrome = AppFieldChrome.normal,
    this.semanticLabel,
  });

  final String text;
  final String? placeholder;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final AppDensity density;
  final AppFieldChrome chrome;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final metrics = AppControlMetricsScope.resolve(context);
    final compact = density == AppDensity.compact;
    final displayedText = text.isEmpty ? placeholder ?? '' : text;
    final textColor = text.isEmpty && placeholder != null
        ? theme.colorScheme.mutedForeground
        : theme.colorScheme.foreground;

    Widget display = Align(
      alignment: AlignmentDirectional.centerStart,
      child: Text(
        displayedText,
        maxLines: maxLines,
        overflow: overflow,
        textAlign: textAlign,
        style: DefaultTextStyle.of(
          context,
        ).style.copyWith(color: textColor, fontSize: metrics.fontSize),
      ),
    );
    if (onTap != null) {
      display = Semantics(
        button: true,
        label: semanticLabel ?? displayedText,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onTap,
            child: display,
          ),
        ),
      );
    }

    if (chrome == AppFieldChrome.bare) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: display),
          if (trailing != null) ...[
            SizedBox(width: metrics.contentGap),
            AppInputGroupAddon(child: trailing!),
          ],
        ],
      );
    }

    return AppInputGroup(
      height: compact ? 24 : null,
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 4 : metrics.horizontalPadding,
      ),
      trailing: trailing,
      child: display,
    );
  }
}

/// Form field wrapper for [AppTextDisplay].
///
/// The value is display-only, but can still be registered under [name] so it
/// is available through [AppFormController].
class AppTextDisplayFormField extends FormField<String> {
  AppTextDisplayFormField({
    super.key,
    required this.value,
    this.name,
    this.label,
    this.description,
    this.placeholder,
    this.trailing,
    this.onTap,
    this.maxLines = 1,
    this.overflow = TextOverflow.ellipsis,
    this.textAlign = TextAlign.start,
    this.density = AppDensity.normal,
    this.chrome = AppFieldChrome.normal,
    this.width,
    this.semanticLabel,
  }) : super(
         initialValue: value,
         enabled: false,
         builder: (state) {
           final field = state.widget as AppTextDisplayFormField;
           final text = state.value ?? '';
           return AppFormFieldBinding<String>(
             name: field.name,
             value: text,
             builder: (context, _) => AppField(
               label: field.label,
               description: field.description,
               density: field.density,
               chrome: field.chrome,
               width: field.width,
               child: AppTextDisplay(
                 text: text,
                 placeholder: field.placeholder,
                 trailing: field.trailing,
                 onTap: field.onTap,
                 maxLines: field.maxLines,
                 overflow: field.overflow,
                 textAlign: field.textAlign,
                 density: field.density,
                 chrome: field.chrome,
                 semanticLabel: field.semanticLabel,
               ),
             ),
           );
         },
       );

  final String value;
  final String? name;
  final String? label;
  final String? description;
  final String? placeholder;
  final Widget? trailing;
  final VoidCallback? onTap;
  final int? maxLines;
  final TextOverflow overflow;
  final TextAlign textAlign;
  final AppDensity density;
  final AppFieldChrome chrome;
  final double? width;
  final String? semanticLabel;

  @override
  FormFieldState<String> createState() => _AppTextDisplayFormFieldState();
}

class _AppTextDisplayFormFieldState extends FormFieldState<String> {
  @override
  void didUpdateWidget(covariant AppTextDisplayFormField oldWidget) {
    super.didUpdateWidget(oldWidget);
    final field = widget as AppTextDisplayFormField;
    if (oldWidget.value != field.value && value != field.value) {
      didChange(field.value);
    }
  }
}
