import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_shadcn_scope.dart';
import '../../foundation/app_shadow_types.dart';
import '../../foundation/app_theme_config.dart';

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

  @override
  Widget build(BuildContext context) {
    final level = shadowLevel;
    final resolvedShadows =
        boxShadow ??
        (level == null
            ? null
            : AppTheme.of(
                context,
              ).shadows.resolve(context, level: level, quality: shadowQuality));
    return shad.Card(
      padding: padding,
      filled: filled,
      fillColor: fillColor,
      borderRadius: borderRadius,
      clipBehavior: clipBehavior,
      borderColor: borderColor,
      borderWidth: borderWidth,
      boxShadow: resolvedShadows,
      surfaceOpacity: surfaceOpacity,
      surfaceBlur: surfaceBlur,
      duration: duration,
      child: child,
    );
  }
}
