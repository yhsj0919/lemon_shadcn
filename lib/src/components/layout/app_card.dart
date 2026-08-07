import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_shadow_types.dart';
import '../../foundation/app_theme_config.dart';
import '../display/app_semantic_style.dart';

/// Theme-aware card facade. Existing cards remain flat; use [AppCard.elevated]
/// or [shadowLevel] to opt into the shared, transition-aware shadow resolver.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.filled,
    this.fillColor,
    this.borderRadius,
    this.clipBehavior,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.duration,
    this.shadowLevel,
    this.shadowQuality,
    this.shadow = true,
    this.color,
    this.lightTintOpacity = 0.06,
    this.darkTintOpacity = 0.10,
  });

  const AppCard.elevated({
    super.key,
    required this.child,
    this.padding,
    this.filled,
    this.fillColor,
    this.borderRadius,
    this.clipBehavior,
    this.borderColor,
    this.borderWidth,
    this.boxShadow,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.duration,
    this.shadowLevel = AppShadowLevel.card,
    this.shadowQuality,
    this.shadow = true,
    this.color,
    this.lightTintOpacity = 0.06,
    this.darkTintOpacity = 0.10,
  });

  /// Color-driven card with a subtle tinted background, matching border, and
  /// a single theme-resolved colored shadow.
  const AppCard.soft({
    super.key,
    required this.child,
    required this.color,
    this.padding,
    this.filled = true,
    this.fillColor,
    this.borderRadius,
    this.clipBehavior,
    this.borderColor,
    this.borderWidth = 1,
    this.boxShadow,
    this.surfaceOpacity,
    this.surfaceBlur,
    this.duration,
    this.shadowLevel = AppShadowLevel.card,
    this.shadowQuality,
    this.shadow = true,
    this.lightTintOpacity = 0.06,
    this.darkTintOpacity = 0.10,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool? filled;
  final Color? fillColor;
  final BorderRadiusGeometry? borderRadius;
  final Clip? clipBehavior;
  final Color? borderColor;
  final double? borderWidth;

  /// Explicit shadows take precedence over theme resolution and are not
  /// automatically degraded during transitions.
  final List<BoxShadow>? boxShadow;
  final double? surfaceOpacity;
  final double? surfaceBlur;
  final Duration? duration;
  final AppShadowLevel? shadowLevel;
  final AppShadowQuality? shadowQuality;

  /// Quickly disables inherited, explicit, and theme-resolved shadows.
  final bool shadow;
  final Color? color;

  /// Card backgrounds are intentionally lighter than avatar/badge soft fills.
  final double lightTintOpacity;
  final double darkTintOpacity;

  @override
  Widget build(BuildContext context) {
    final tintColor = color;
    final level =
        shadowLevel ?? (tintColor == null ? null : AppShadowLevel.card);
    final theme = shad.Theme.of(context);
    final resolvedBorderColor =
        borderColor ??
        (tintColor == null ? null : AppSoftColor.border(theme, tintColor));
    final resolvedFillColor =
        fillColor ??
        (tintColor == null
            ? null
            : AppSoftColor.background(
                theme,
                tintColor,
                lightOpacity: lightTintOpacity,
                darkOpacity: darkTintOpacity,
              ));
    final resolvedShadows = !shadow
        ? const <BoxShadow>[]
        : boxShadow ??
              (level == null
                  ? null
                  : AppTheme.of(context).shadows.resolve(
                      context,
                      level: level,
                      quality: shadowQuality,
                      colorMode: tintColor == null
                          ? null
                          : AppShadowColorMode.custom,
                      color: tintColor,
                      // Saturated shadows need slightly more opacity than neutral
                      // surface shadows to remain visible beside the soft tint.
                      intensity: tintColor == null ? 1 : 1.5,
                    ));
    return shad.Card(
      padding: padding,
      filled: filled ?? (tintColor == null ? null : true),
      fillColor: resolvedFillColor,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      borderColor: resolvedBorderColor,
      borderWidth: borderWidth,
      boxShadow: resolvedShadows,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
      duration: duration,
      child: child,
    );
  }
}
