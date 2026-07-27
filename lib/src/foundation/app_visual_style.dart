import 'package:flutter/widgets.dart';

import 'app_shadcn_scope.dart';

@immutable
class AppVisualColors {
  const AppVisualColors({
    this.background,
    this.foreground,
    this.border,
    this.accent,
    this.shadow,
  });

  final Color? background;
  final Color? foreground;
  final Color? border;
  final Color? accent;
  final Color? shadow;

  AppVisualColors copyWith({
    Color? background,
    Color? foreground,
    Color? border,
    Color? accent,
    Color? shadow,
  }) {
    return AppVisualColors(
      background: background ?? this.background,
      foreground: foreground ?? this.foreground,
      border: border ?? this.border,
      accent: accent ?? this.accent,
      shadow: shadow ?? this.shadow,
    );
  }

  static AppVisualColors lerp(
    AppVisualColors left,
    AppVisualColors right,
    double t,
  ) {
    return AppVisualColors(
      background: Color.lerp(left.background, right.background, t),
      foreground: Color.lerp(left.foreground, right.foreground, t),
      border: Color.lerp(left.border, right.border, t),
      accent: Color.lerp(left.accent, right.accent, t),
      shadow: Color.lerp(left.shadow, right.shadow, t),
    );
  }
}

@immutable
class AppVisualPalette {
  const AppVisualPalette({
    required this.normal,
    this.hovered,
    this.focused,
    this.pressed,
    this.selected,
    this.selectedHovered,
    this.invalid,
    this.disabled,
  });

  final AppVisualColors normal;
  final AppVisualColors? hovered;
  final AppVisualColors? focused;
  final AppVisualColors? pressed;
  final AppVisualColors? selected;
  final AppVisualColors? selectedHovered;
  final AppVisualColors? invalid;
  final AppVisualColors? disabled;

  AppVisualColors resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.disabled)) return disabled ?? normal;
    if (states.contains(WidgetState.error)) return invalid ?? normal;
    if (states.contains(WidgetState.pressed)) return pressed ?? normal;
    if (states.contains(WidgetState.selected) &&
        states.contains(WidgetState.hovered)) {
      return selectedHovered ?? selected ?? hovered ?? normal;
    }
    if (states.contains(WidgetState.selected)) return selected ?? normal;
    if (states.contains(WidgetState.focused)) return focused ?? normal;
    if (states.contains(WidgetState.hovered)) return hovered ?? normal;
    return normal;
  }
}

class AppAnimatedVisualStyle extends StatelessWidget {
  const AppAnimatedVisualStyle({
    super.key,
    required this.states,
    required this.palette,
    required this.child,
    this.duration = const Duration(milliseconds: 150),
    this.curve = Curves.easeOutCubic,
  });

  final Set<WidgetState> states;
  final AppVisualPalette palette;
  final Widget child;
  final Duration duration;
  final Curve curve;

  @override
  Widget build(BuildContext context) {
    final target = palette.resolve(states);
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    return TweenAnimationBuilder<AppVisualColors>(
      tween: _AppVisualColorsTween(end: target),
      duration: reduceMotion ? Duration.zero : duration,
      curve: curve,
      builder: (context, colors, child) {
        return AppVisualStyle(colors: colors, child: child!);
      },
      child: child,
    );
  }
}

class _AppVisualColorsTween extends Tween<AppVisualColors> {
  _AppVisualColorsTween({required AppVisualColors end}) : super(end: end);

  @override
  AppVisualColors lerp(double t) {
    final start = begin ?? end!;
    return AppVisualColors.lerp(start, end!, t);
  }
}

class AppVisualStyle extends InheritedWidget {
  const AppVisualStyle({super.key, required this.colors, required super.child});

  final AppVisualColors colors;

  static AppVisualColors? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppVisualStyle>()?.colors;
  }

  static AppVisualColors of(BuildContext context) {
    final colors = maybeOf(context);
    assert(colors != null, 'No AppVisualStyle found in this context.');
    return colors!;
  }

  @override
  bool updateShouldNotify(AppVisualStyle oldWidget) =>
      colors != oldWidget.colors;
}

AppVisualColors? resolveAppControlVisuals(
  BuildContext context,
  Set<WidgetState> states,
) {
  return AppVisualStyle.maybeOf(context) ??
      AppTheme.maybeOf(context)?.controlPalette?.resolve(states);
}
