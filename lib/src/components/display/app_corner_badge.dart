import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_badge.dart';

enum AppCornerBadgePosition { topLeft, topRight, bottomLeft, bottomRight }

/// Overlays a badge on any widget without changing the child's layout size.
class AppCornerBadge extends StatelessWidget {
  const AppCornerBadge({
    super.key,
    required this.child,
    required this.badge,
    this.position = AppCornerBadgePosition.topRight,
    this.offset = Offset.zero,
    this.overlap = 0.6,
    this.ignorePointer = true,
  }) : assert(overlap >= 0 && overlap <= 1);

  factory AppCornerBadge.count({
    Key? key,
    required Widget child,
    required int count,
    int maxCount = 99,
    Color? color,
    Color? foregroundColor,
    double size = 20,
    EdgeInsetsGeometry padding = const EdgeInsets.symmetric(horizontal: 5),
    AppBadgeShape shape = AppBadgeShape.pill,
    BorderRadiusGeometry? borderRadius,
    AppCornerBadgePosition position = AppCornerBadgePosition.topRight,
    Offset offset = Offset.zero,
    double overlap = 0.6,
    bool ignorePointer = true,
  }) {
    assert(count >= 0);
    assert(maxCount > 0);
    assert(size > 0);
    return AppCornerBadge(
      key: key,
      position: position,
      offset: offset,
      overlap: overlap,
      ignorePointer: ignorePointer,
      badge: _AppCountBadge(
        count: count,
        maxCount: maxCount,
        color: color,
        foregroundColor: foregroundColor,
        size: size,
        padding: padding,
        shape: shape,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }

  factory AppCornerBadge.dot({
    Key? key,
    required Widget child,
    Color? color,
    double size = 10,
    AppCornerBadgePosition position = AppCornerBadgePosition.topRight,
    Offset offset = Offset.zero,
    double overlap = 0.6,
    bool ignorePointer = true,
  }) {
    assert(size > 0);
    return AppCornerBadge(
      key: key,
      position: position,
      offset: offset,
      overlap: overlap,
      ignorePointer: ignorePointer,
      badge: _AppDotBadge(color: color, size: size),
      child: child,
    );
  }

  final Widget child;
  final Widget badge;
  final AppCornerBadgePosition position;
  final Offset offset;

  /// Fraction of the badge covering the child at the selected corner.
  ///
  /// `0` places the badge fully outside, `0.5` covers half of it, and `1`
  /// places it fully inside the child's bounds.
  final double overlap;
  final bool ignorePointer;

  @override
  Widget build(BuildContext context) {
    final outside = 1 - overlap;
    final (alignment, translation) = switch (position) {
      AppCornerBadgePosition.topLeft => (
        Alignment.topLeft,
        Offset(-outside, -outside),
      ),
      AppCornerBadgePosition.topRight => (
        Alignment.topRight,
        Offset(outside, -outside),
      ),
      AppCornerBadgePosition.bottomLeft => (
        Alignment.bottomLeft,
        Offset(-outside, outside),
      ),
      AppCornerBadgePosition.bottomRight => (
        Alignment.bottomRight,
        Offset(outside, outside),
      ),
    };
    final overlay = Align(
      alignment: alignment,
      child: Transform.translate(
        offset: offset,
        child: FractionalTranslation(
          translation: translation,
          child: IgnorePointer(ignoring: ignorePointer, child: badge),
        ),
      ),
    );
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned.fill(child: overlay),
      ],
    );
  }
}

class _AppCountBadge extends StatelessWidget {
  const _AppCountBadge({
    required this.count,
    required this.maxCount,
    required this.color,
    required this.foregroundColor,
    required this.size,
    required this.padding,
    required this.shape,
    required this.borderRadius,
  });

  final int count;
  final int maxCount;
  final Color? color;
  final Color? foregroundColor;
  final double size;
  final EdgeInsetsGeometry padding;
  final AppBadgeShape shape;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final background = color ?? theme.colorScheme.destructive;
    final foreground = foregroundColor ?? _contrastingForeground(background);
    final value = count > maxCount ? '$maxCount+' : '$count';
    return Semantics(
      label: value,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: background,
          borderRadius:
              borderRadius ??
              BorderRadius.circular(shape == AppBadgeShape.pill ? 999 : 6),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(minWidth: size, minHeight: size),
          child: Padding(
            padding: padding,
            child: Center(
              widthFactor: 1,
              heightFactor: 1,
              child: Text(
                value,
                maxLines: 1,
                style: TextStyle(
                  color: foreground,
                  fontSize: size * 0.55,
                  height: 1,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppDotBadge extends StatelessWidget {
  const _AppDotBadge({required this.color, required this.size});

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: color ?? theme.colorScheme.destructive,
        shape: BoxShape.circle,
      ),
      child: SizedBox.square(dimension: size),
    );
  }
}

Color _contrastingForeground(Color background) =>
    background.computeLuminance() > 0.179
    ? const Color(0xff000000)
    : const Color(0xffffffff);
