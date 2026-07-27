import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Semantic typography roles shared by product and admin screens.
enum AppTextRole {
  display,
  h1,
  h2,
  h3,
  h4,
  title,
  subtitle,
  body,
  bodyStrong,
  label,
  caption,
  code,
  muted,
}

/// Theme overrides for [AppText].
class AppTextTheme extends shad.ComponentThemeData {
  const AppTextTheme({
    this.display,
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.title,
    this.subtitle,
    this.body,
    this.bodyStrong,
    this.label,
    this.caption,
    this.code,
    this.muted,
  });

  final TextStyle? display;
  final TextStyle? h1;
  final TextStyle? h2;
  final TextStyle? h3;
  final TextStyle? h4;
  final TextStyle? title;
  final TextStyle? subtitle;
  final TextStyle? body;
  final TextStyle? bodyStrong;
  final TextStyle? label;
  final TextStyle? caption;
  final TextStyle? code;
  final TextStyle? muted;

  TextStyle? _override(AppTextRole role) => switch (role) {
    AppTextRole.display => display,
    AppTextRole.h1 => h1,
    AppTextRole.h2 => h2,
    AppTextRole.h3 => h3,
    AppTextRole.h4 => h4,
    AppTextRole.title => title,
    AppTextRole.subtitle => subtitle,
    AppTextRole.body => body,
    AppTextRole.bodyStrong => bodyStrong,
    AppTextRole.label => label,
    AppTextRole.caption => caption,
    AppTextRole.code => code,
    AppTextRole.muted => muted,
  };

  static TextStyle _default(AppTextRole role, shad.ThemeData theme) {
    final typography = theme.typography;
    final colors = theme.colorScheme;
    return switch (role) {
      AppTextRole.display => typography.x5Large.merge(typography.bold),
      AppTextRole.h1 => typography.h1,
      AppTextRole.h2 => typography.h2,
      AppTextRole.h3 => typography.h3,
      AppTextRole.h4 => typography.h4,
      AppTextRole.title => typography.textLarge,
      AppTextRole.subtitle => typography.base.copyWith(
        color: colors.mutedForeground,
      ),
      AppTextRole.body => typography.p,
      AppTextRole.bodyStrong => typography.base.merge(typography.medium),
      AppTextRole.label => typography.textSmall,
      AppTextRole.caption => typography.xSmall.copyWith(
        color: colors.mutedForeground,
      ),
      AppTextRole.code => typography.inlineCode,
      AppTextRole.muted => typography.textMuted.copyWith(
        color: colors.mutedForeground,
      ),
    };
  }

  static TextStyle resolve(
    BuildContext context,
    AppTextRole role,
    TextStyle? widgetStyle,
  ) {
    final theme = shad.Theme.of(context);
    final componentTheme =
        shad.ComponentTheme.maybeOf<AppTextTheme>(context)?._override(role);
    final base = componentTheme ?? _default(role, theme);
    return widgetStyle == null ? base : base.merge(widgetStyle);
  }
}

/// Text whose style is selected by semantic purpose instead of font size.
class AppText extends StatelessWidget {
  const AppText(
    this.data, {
    super.key,
    this.role = AppTextRole.body,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  });

  const AppText.display(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.display;
  const AppText.h1(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.h1;
  const AppText.h2(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.h2;
  const AppText.h3(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.h3;
  const AppText.h4(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.h4;
  const AppText.title(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.title;
  const AppText.subtitle(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.subtitle;
  const AppText.body(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.body;
  const AppText.bodyStrong(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.bodyStrong;
  const AppText.label(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.label;
  const AppText.caption(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.caption;
  const AppText.code(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.code;
  const AppText.muted(this.data, {super.key, this.style, this.textAlign, this.maxLines, this.overflow, this.softWrap}) : role = AppTextRole.muted;

  final String data;
  final AppTextRole role;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;

  @override
  Widget build(BuildContext context) => Text(
    data,
    style: AppTextTheme.resolve(context, role, style),
    textAlign: textAlign,
    maxLines: maxLines,
    overflow: overflow,
    softWrap: softWrap,
  );
}
