import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Shared visual and layout tokens for application overlays.
abstract final class AppOverlayStyle {
  static const EdgeInsets compactPadding =
      EdgeInsets.symmetric(horizontal: 12, vertical: 10);
  static const EdgeInsets toastPadding =
      EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  static const BorderRadiusGeometry surfaceBorderRadius =
      BorderRadius.all(Radius.circular(8));

  static const AlignmentGeometry popoverAlignment = Alignment.topCenter;
  static const AlignmentGeometry popoverAnchorAlignment =
      Alignment.bottomCenter;
  static const Offset popoverOffset = Offset(0, 8);

  static bool isDark(BuildContext context) =>
      shad.Theme.of(context).brightness == Brightness.dark;

  static Color modalBarrier(BuildContext context) =>
      Color.fromRGBO(0, 0, 0, isDark(context) ? 0.38 : 0.20);

  static List<BoxShadow> floatingShadows(BuildContext context) {
    final dark = isDark(context);
    return [
      BoxShadow(
        color: dark ? const Color(0x66000000) : const Color(0x24000000),
        blurRadius: 20,
        spreadRadius: -2,
        offset: const Offset(0, 8),
      ),
      BoxShadow(
        color: dark ? const Color(0x33000000) : const Color(0x14000000),
        blurRadius: 2,
        spreadRadius: -1,
        offset: const Offset(0, 1),
      ),
    ];
  }
}

/// Applies the shared card styling used by floating overlay surfaces.
class AppOverlaySurfaceTheme extends StatelessWidget {
  const AppOverlaySurfaceTheme({
    super.key,
    required this.child,
    this.padding = AppOverlayStyle.compactPadding,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return shad.ComponentTheme<shad.CardTheme>(
      data: shad.CardTheme(
        padding: padding,
        borderRadius: AppOverlayStyle.surfaceBorderRadius,
        boxShadow: AppOverlayStyle.floatingShadows(context),
      ),
      child: child,
    );
  }
}
