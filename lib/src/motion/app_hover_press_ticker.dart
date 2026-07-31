import 'package:flutter/widgets.dart';

import '../foundation/app_theme_config.dart';

/// Shared 0..1 hover/press clocks for [AppButton] and [AppMotion].
///
/// Timing and curves come from [AppMotionTokens] so interactive surfaces stay
/// in sync without duplicating AnimationController boilerplate.
class AppHoverPressTicker {
  AppHoverPressTicker(TickerProvider vsync)
    : hover = AnimationController(
        vsync: vsync,
        duration: AppMotionTokens.standard.hoverDuration,
      ),
      press = AnimationController(
        vsync: vsync,
        duration: AppMotionTokens.standard.pressDuration,
      );

  final AnimationController hover;
  final AnimationController press;

  Listenable get listenable => Listenable.merge([hover, press]);

  void sync(AppMotionTokens tokens) {
    if (hover.duration != tokens.hoverDuration) {
      hover.duration = tokens.hoverDuration;
    }
    if (press.duration != tokens.pressDuration) {
      press.duration = tokens.pressDuration;
    }
  }

  void setHover(
    bool value, {
    required bool animate,
    required AppMotionTokens tokens,
  }) {
    sync(tokens);
    if (!animate) {
      hover.value = value ? 1 : 0;
      return;
    }
    hover.animateTo(
      value ? 1 : 0,
      duration: tokens.hoverDuration,
      curve: value ? Curves.easeOutCubic : Curves.easeInOutCubic,
    );
  }

  void setPress(
    bool value, {
    required bool animate,
    required AppMotionTokens tokens,
  }) {
    sync(tokens);
    if (!animate) {
      press.value = value ? 1 : 0;
      return;
    }
    press.animateTo(
      value ? 1 : 0,
      duration: tokens.pressDuration,
      curve: value ? Curves.easeOutCubic : Curves.easeInOutCubic,
    );
  }

  void reset() {
    hover.value = 0;
    press.value = 0;
  }

  void dispose() {
    hover.dispose();
    press.dispose();
  }
}
