import 'package:flutter/material.dart'
    show
        Material,
        ReorderableDragStartListener,
        ReorderableListView,
        RoundedRectangleBorder;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';
import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_theme_config.dart';
import 'app_field.dart';
import 'app_form.dart';

typedef AppObjectInput<T> = shad.FormattedObjectInput<T>;
typedef AppObjectConverter<A, B> = shad.BiDirectionalConvert<A, B>;

/// Floating chrome shared by sortable drag previews.
class AppSortableDragFeedback extends StatelessWidget {
  const AppSortableDragFeedback({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final radius = BorderRadius.circular(theme.radiusMd);
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: AppTheme.of(context).shadows.resolve(
          context,
          level: AppShadowLevel.floating,
          colorMode: AppShadowColorMode.custom,
          color: theme.colorScheme.foreground,
        ),
      ),
      child: Material(
        color: theme.colorScheme.popover,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: theme.colorScheme.border, width: 1),
        ),
        child: child,
      ),
    );
  }
}

/// Grip control used by [AppSortableInput] and table drag handles.
class AppSortableDragHandle extends StatelessWidget {
  const AppSortableDragHandle({super.key, this.enabled = true});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final iconSize = AppTheme.maybeOf(context)?.controls.iconSize ?? 16;
    final contentGap = AppTheme.maybeOf(context)?.controls.contentGap ?? 8;
    return Padding(
      padding: EdgeInsets.all(contentGap),
      child: Icon(
        shad.LucideIcons.gripVertical,
        size: iconSize,
        color: enabled
            ? theme.colorScheme.mutedForeground
            : theme.colorScheme.muted,
      ),
    );
  }
}

class AppSortableInput<T> extends StatelessWidget {
  const AppSortableInput({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.onChanged,
    this.itemKey,
    this.enabled = true,
    this.shrinkWrap = true,
    this.padding,
  });

  final List<T> items;
  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final ValueChanged<List<T>> onChanged;
  final Key Function(T item)? itemKey;
  final bool enabled;
  final bool shrinkWrap;
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: shrinkWrap,
      physics: shrinkWrap ? const NeverScrollableScrollPhysics() : null,
      padding: padding,
      buildDefaultDragHandles: false,
      proxyDecorator: (child, index, animation) =>
          AppSortableDragFeedback(child: child),
      itemCount: items.length,
      onReorderItem: enabled
          ? (oldIndex, newIndex) {
              final next = List<T>.of(items);
              final item = next.removeAt(oldIndex);
              next.insert(newIndex, item);
              onChanged(next);
            }
          : (_, _) {},
      itemBuilder: (context, index) {
        final item = items[index];
        return KeyedSubtree(
          key: itemKey?.call(item) ?? ValueKey<T>(item),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ReorderableDragStartListener(
                index: index,
                enabled: enabled,
                child: AppSortableDragHandle(enabled: enabled),
              ),
              SizedBox(width: 4 * shad.Theme.of(context).scaling),
              Flexible(
                fit: FlexFit.loose,
                child: DefaultTextStyle.merge(
                  style: shad.Theme.of(
                    context,
                  ).typography.base.copyWith(fontWeight: FontWeight.normal),
                  child: itemBuilder(context, index, item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class AppSortableInputFormField<T> extends FormField<List<T>> {
  AppSortableInputFormField({
    super.key,
    required this.itemBuilder,
    this.itemKey,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.onChanged,
    super.initialValue = const [],
    super.onSaved,
    super.validator,
    this.asyncValidator,
    super.enabled = true,
    super.autovalidateMode = AutovalidateMode.onUserInteraction,
    super.restorationId,
  }) : super(
         builder: (state) {
           final field = state.widget as AppSortableInputFormField<T>;
           final value = List<T>.of(state.value ?? const []);
           return AppFormFieldBinding<List<T>>(
             name: field.name,
             value: value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: AppSortableInput<T>(
                 items: value,
                 itemBuilder: field.itemBuilder,
                 itemKey: field.itemKey,
                 enabled: field.enabled,
                 onChanged: (next) {
                   state.didChange(next);
                   field.onChanged?.call(next);
                 },
               ),
             ),
           );
         },
       );

  final Widget Function(BuildContext context, int index, T item) itemBuilder;
  final Key Function(T item)? itemKey;
  final String? name;
  final String? label;
  final String? description;
  final bool required;
  final double? width;
  final ValueChanged<List<T>>? onChanged;
  final AppAsyncFieldValidator<List<T>>? asyncValidator;
}

class AppObjectInputFormField<T> extends FormField<T> {
  AppObjectInputFormField({
    super.key,
    required this.converter,
    required this.parts,
    this.name,
    this.label,
    this.description,
    this.required = false,
    this.width,
    this.popupBuilder,
    this.popoverIcon,
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
           final field = state.widget as AppObjectInputFormField<T>;
           return AppFormFieldBinding<T>(
             name: field.name,
             value: state.value,
             asyncValidator: field.asyncValidator,
             builder: (context, asyncError) => AppField(
               label: field.label,
               description: field.description,
               errorText: state.errorText ?? asyncError,
               required: field.required,
               width: field.width,
               child: _AppObjectInputControl<T>(
                 value: state.value,
                 converter: field.converter,
                 parts: field.parts,
                 popupBuilder: field.popupBuilder,
                 popoverIcon: field.popoverIcon,
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

  final shad.BiDirectionalConvert<T?, List<String?>> converter;
  final List<shad.InputPart> parts;
  final shad.FormattedInputPopupBuilder<T>? popupBuilder;
  final Widget? popoverIcon;
  final String? name;
  final String? label;
  final String? description;
  final bool required;
  final double? width;
  final ValueChanged<T?>? onChanged;
  final AppAsyncFieldValidator<T>? asyncValidator;
}

class _AppObjectController<T> extends ValueNotifier<T?>
    with shad.ComponentController<T?> {
  _AppObjectController(super.value);
}

class _AppObjectInputControl<T> extends StatefulWidget {
  const _AppObjectInputControl({
    required this.value,
    required this.converter,
    required this.parts,
    required this.enabled,
    required this.onChanged,
    this.popupBuilder,
    this.popoverIcon,
  });

  final T? value;
  final shad.BiDirectionalConvert<T?, List<String?>> converter;
  final List<shad.InputPart> parts;
  final bool enabled;
  final ValueChanged<T?> onChanged;
  final shad.FormattedInputPopupBuilder<T>? popupBuilder;
  final Widget? popoverIcon;

  @override
  State<_AppObjectInputControl<T>> createState() =>
      _AppObjectInputControlState<T>();
}

class _AppObjectInputControlState<T> extends State<_AppObjectInputControl<T>> {
  late final _AppObjectController<T> _controller = _AppObjectController<T>(
    widget.value,
  );
  T? _lastEmittedValue;
  bool _hasEmittedValue = false;

  @override
  void didUpdateWidget(covariant _AppObjectInputControl<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_hasEmittedValue && widget.value == _lastEmittedValue) {
      _hasEmittedValue = false;
      return;
    }
    if (widget.value != _controller.value) _controller.value = widget.value;
  }

  void _handleChanged(T? value) {
    _lastEmittedValue = value;
    _hasEmittedValue = true;
    widget.onChanged(value);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = AppTheme.maybeOf(context)?.controls.height ?? 32;
    final scaling = shad.Theme.of(context).scaling;
    return AppControlBox(
      child: shad.ComponentTheme<shad.FormattedInputTheme>(
        data: shad.FormattedInputTheme(height: height / scaling),
        child: shad.FormattedObjectInput<T>(
          controller: _controller,
          converter: widget.converter,
          parts: widget.parts,
          popupBuilder: widget.popupBuilder,
          popoverIcon: widget.popoverIcon,
          enabled: widget.enabled,
          onChanged: _handleChanged,
        ),
      ),
    );
  }
}
