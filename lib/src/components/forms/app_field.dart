import 'package:flutter/material.dart' show Tooltip;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

enum AppFieldLayout { vertical, horizontal }

enum AppFieldErrorDisplay { auto, inline, trailingIcon, below }

@immutable
class AppFieldConfig {
  const AppFieldConfig({
    this.layout = AppFieldLayout.vertical,
    this.errorDisplay = AppFieldErrorDisplay.auto,
    this.labelWidth = 120,
    this.gap = 8,
  });

  final AppFieldLayout layout;
  final AppFieldErrorDisplay errorDisplay;
  final double labelWidth;
  final double gap;
}

/// Applies one field layout to an entire form subtree.
class AppFieldScope extends InheritedWidget {
  const AppFieldScope({super.key, required this.config, required super.child});

  AppFieldScope.horizontal({
    super.key,
    double labelWidth = 120,
    AppFieldErrorDisplay errorDisplay = AppFieldErrorDisplay.auto,
    double gap = 8,
    required super.child,
  }) : config = AppFieldConfig(
         layout: AppFieldLayout.horizontal,
         labelWidth: labelWidth,
         errorDisplay: errorDisplay,
         gap: gap,
       );

  final AppFieldConfig config;

  static AppFieldConfig of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppFieldScope>()?.config ??
      const AppFieldConfig();

  @override
  bool updateShouldNotify(AppFieldScope oldWidget) =>
      config != oldWidget.config;
}

extension on AppFieldConfig {
  AppFieldConfig copyWith({
    AppFieldLayout? layout,
    AppFieldErrorDisplay? errorDisplay,
    double? labelWidth,
    double? gap,
  }) => AppFieldConfig(
    layout: layout ?? this.layout,
    errorDisplay: errorDisplay ?? this.errorDisplay,
    labelWidth: labelWidth ?? this.labelWidth,
    gap: gap ?? this.gap,
  );
}

class AppField extends StatelessWidget {
  const AppField({
    super.key,
    required this.child,
    this.label,
    this.description,
    this.errorText,
    this.required = false,
    this.width,
    this.layout,
    this.errorDisplay,
    this.labelWidth,
  });

  final Widget child;
  final String? label;
  final String? description;
  final String? errorText;
  final bool required;
  final double? width;
  final AppFieldLayout? layout;
  final AppFieldErrorDisplay? errorDisplay;
  final double? labelWidth;

  @override
  Widget build(BuildContext context) {
    final inherited = AppFieldScope.of(context);
    final config = inherited.copyWith(
      layout: layout,
      errorDisplay: errorDisplay,
      labelWidth: labelWidth,
    );
    final resolvedErrorDisplay =
        config.errorDisplay == AppFieldErrorDisplay.auto
        ? config.layout == AppFieldLayout.vertical && label != null
              ? AppFieldErrorDisplay.inline
              : AppFieldErrorDisplay.trailingIcon
        : config.errorDisplay;
    return LayoutBuilder(
      builder: (context, constraints) {
        final control = _FieldControl(
          errorText: errorText,
          errorDisplay: resolvedErrorDisplay,
          child: child,
        );
        final body = switch (config.layout) {
          AppFieldLayout.vertical => _vertical(
            context,
            control,
            config,
            resolvedErrorDisplay,
          ),
          AppFieldLayout.horizontal => _horizontal(context, control, config),
        };
        final targetWidth =
            width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        return targetWidth == null
            ? body
            : SizedBox(width: targetWidth, child: body);
      },
    );
  }

  Widget _vertical(
    BuildContext context,
    Widget control,
    AppFieldConfig config,
    AppFieldErrorDisplay resolvedErrorDisplay,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      if (label != null) ...[
        _FieldLabel(
          label: label!,
          required: required,
          errorText: resolvedErrorDisplay == AppFieldErrorDisplay.inline
              ? errorText
              : null,
        ),
        SizedBox(height: config.gap - 2),
      ],
      control,
      ..._footer(context, config),
    ],
  );

  Widget _horizontal(
    BuildContext context,
    Widget control,
    AppFieldConfig config,
  ) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    mainAxisSize: MainAxisSize.min,
    children: [
      Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (label != null) ...[
            SizedBox(
              width: config.labelWidth,
              child: _FieldLabel(label: label!, required: required),
            ),
            SizedBox(width: config.gap),
          ],
          Expanded(child: control),
        ],
      ),
      if (_footer(context, config).isNotEmpty)
        Padding(
          padding: EdgeInsetsDirectional.only(
            start: label == null ? 0 : config.labelWidth + config.gap,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: _footer(context, config),
          ),
        ),
    ],
  );

  List<Widget> _footer(BuildContext context, AppFieldConfig config) => [
    if (description != null) ...[
      SizedBox(height: config.gap - 2),
      Text(description!).small().muted(),
    ],
    if (errorText != null &&
        config.errorDisplay == AppFieldErrorDisplay.below) ...[
      SizedBox(height: config.gap - 2),
      _FieldErrorText(errorText!),
    ],
  ];
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({
    required this.label,
    required this.required,
    this.errorText,
  });
  final String label;
  final bool required;
  final String? errorText;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Flexible(child: Text(label).small().medium()),
      if (required)
        DefaultTextStyle.merge(
          style: TextStyle(
            color: shad.Theme.of(context).colorScheme.destructive,
          ),
          child: const Text(' *').small(),
        ),
      if (errorText != null) ...[
        const shad.Gap(8),
        Flexible(child: _FieldErrorText(errorText!)),
      ],
    ],
  );
}

class _FieldControl extends StatelessWidget {
  const _FieldControl({
    required this.errorText,
    required this.errorDisplay,
    required this.child,
  });

  final String? errorText;
  final AppFieldErrorDisplay errorDisplay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (errorDisplay != AppFieldErrorDisplay.trailingIcon) {
      return child;
    }
    if (errorText == null) return child;
    final theme = shad.Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.center,
      children: [
        child,
        PositionedDirectional(
          end: 8,
          top: 0,
          bottom: 0,
          child: Center(
            child: DecoratedBox(
              decoration: BoxDecoration(color: theme.colorScheme.input),
              child: SizedBox(
                width: 20,
                child: Center(child: _FieldErrorIcon(errorText!)),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _FieldErrorIcon extends StatelessWidget {
  const _FieldErrorIcon(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    label: message,
    child: Tooltip(
      message: message,
      child: Icon(
        shad.LucideIcons.triangleAlert,
        size: 16,
        color: shad.Theme.of(context).colorScheme.destructive,
      ),
    ),
  );
}

class _FieldErrorText extends StatelessWidget {
  const _FieldErrorText(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Semantics(
    liveRegion: true,
    child: DefaultTextStyle.merge(
      style: TextStyle(color: shad.Theme.of(context).colorScheme.destructive),
      child: Text(message).small(),
    ),
  );
}
