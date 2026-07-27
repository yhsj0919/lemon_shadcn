import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_theme_config.dart';

/// Reusable component-level theme presets.
abstract final class AppComponentThemes {
  /// Opens date and time pickers as anchored popovers.
  static Widget popoverPickers(Widget child) {
    return shad.ComponentTheme<shad.DatePickerTheme>(
      data: const shad.DatePickerTheme(mode: shad.PromptMode.popover),
      child: shad.ComponentTheme<shad.TimePickerTheme>(
        data: const shad.TimePickerTheme(mode: shad.PromptMode.popover),
        child: child,
      ),
    );
  }

  /// Combines wrappers in declaration order, outside-in.
  static AppThemeWrapper combine(List<AppThemeWrapper> wrappers) {
    return (Widget child) {
      var result = child;
      for (var index = wrappers.length - 1; index >= 0; index--) {
        result = wrappers[index](result);
      }
      return result;
    };
  }
}
