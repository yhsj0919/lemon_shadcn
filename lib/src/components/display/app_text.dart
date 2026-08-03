import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Semantic typography roles for product and admin screens.
///
/// Defaults follow a compact admin scale so pages can pick a role without
/// tweaking `fontSize` on every call site.
enum AppTextRole {
  display,
  h1,
  h2,
  h3,
  h4,
  section,
  title,
  subtitle,
  lead,
  body,
  bodyStrong,
  label,

  /// Primary line in nav / select / Material list rows.
  listItem,

  /// Secondary line or group header under a list item.
  listSecondary,
  caption,
  helper,
  error,
  code,
  muted,
}

/// Theme overrides and presets for [AppText].
class AppTextTheme extends shad.ComponentThemeData {
  const AppTextTheme({
    this.display,
    this.h1,
    this.h2,
    this.h3,
    this.h4,
    this.section,
    this.title,
    this.subtitle,
    this.lead,
    this.body,
    this.bodyStrong,
    this.label,
    this.listItem,
    this.listSecondary,
    this.caption,
    this.helper,
    this.error,
    this.code,
    this.muted,
  });

  /// Compact admin baseline (body 14, page title 18, …).
  const AppTextTheme.admin() : this();

  /// One step larger than [AppTextTheme.admin] (body 16, page title 20, …).
  factory AppTextTheme.comfortable() {
    return AppTextTheme(
      display: const TextStyle(fontSize: 36, fontWeight: FontWeight.w700),
      h1: const TextStyle(fontSize: 28, fontWeight: FontWeight.w600),
      h2: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
      h3: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      h4: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      section: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      title: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      subtitle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      lead: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
      body: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      bodyStrong: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      label: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      listItem: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      listSecondary: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
      caption: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      helper: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      error: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
      code: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      muted: const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
    );
  }

  final TextStyle? display;
  final TextStyle? h1;
  final TextStyle? h2;
  final TextStyle? h3;
  final TextStyle? h4;
  final TextStyle? section;
  final TextStyle? title;
  final TextStyle? subtitle;
  final TextStyle? lead;
  final TextStyle? body;
  final TextStyle? bodyStrong;
  final TextStyle? label;
  final TextStyle? listItem;
  final TextStyle? listSecondary;
  final TextStyle? caption;
  final TextStyle? helper;
  final TextStyle? error;
  final TextStyle? code;
  final TextStyle? muted;

  TextStyle? _override(AppTextRole role) => switch (role) {
    AppTextRole.display => display,
    AppTextRole.h1 => h1,
    AppTextRole.h2 => h2,
    AppTextRole.h3 => h3,
    AppTextRole.h4 => h4,
    AppTextRole.section => section ?? h4,
    AppTextRole.title => title,
    AppTextRole.subtitle => subtitle,
    AppTextRole.lead => lead,
    AppTextRole.body => body,
    AppTextRole.bodyStrong => bodyStrong,
    AppTextRole.label => label,
    AppTextRole.listItem => listItem ?? body,
    AppTextRole.listSecondary => listSecondary ?? caption,
    AppTextRole.caption => caption,
    AppTextRole.helper => helper ?? caption,
    AppTextRole.error => error ?? caption,
    AppTextRole.code => code,
    AppTextRole.muted => muted,
  };

  AppTextTheme copyWith({
    TextStyle? display,
    TextStyle? h1,
    TextStyle? h2,
    TextStyle? h3,
    TextStyle? h4,
    TextStyle? section,
    TextStyle? title,
    TextStyle? subtitle,
    TextStyle? lead,
    TextStyle? body,
    TextStyle? bodyStrong,
    TextStyle? label,
    TextStyle? listItem,
    TextStyle? listSecondary,
    TextStyle? caption,
    TextStyle? helper,
    TextStyle? error,
    TextStyle? code,
    TextStyle? muted,
  }) {
    return AppTextTheme(
      display: display ?? this.display,
      h1: h1 ?? this.h1,
      h2: h2 ?? this.h2,
      h3: h3 ?? this.h3,
      h4: h4 ?? this.h4,
      section: section ?? this.section,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      lead: lead ?? this.lead,
      body: body ?? this.body,
      bodyStrong: bodyStrong ?? this.bodyStrong,
      label: label ?? this.label,
      listItem: listItem ?? this.listItem,
      listSecondary: listSecondary ?? this.listSecondary,
      caption: caption ?? this.caption,
      helper: helper ?? this.helper,
      error: error ?? this.error,
      code: code ?? this.code,
      muted: muted ?? this.muted,
    );
  }

  /// Fills null slots from [other] (this instance wins when both set).
  AppTextTheme merge(AppTextTheme? other) {
    if (other == null) return this;
    return AppTextTheme(
      display: display ?? other.display,
      h1: h1 ?? other.h1,
      h2: h2 ?? other.h2,
      h3: h3 ?? other.h3,
      h4: h4 ?? other.h4,
      section: section ?? other.section,
      title: title ?? other.title,
      subtitle: subtitle ?? other.subtitle,
      lead: lead ?? other.lead,
      body: body ?? other.body,
      bodyStrong: bodyStrong ?? other.bodyStrong,
      label: label ?? other.label,
      listItem: listItem ?? other.listItem,
      listSecondary: listSecondary ?? other.listSecondary,
      caption: caption ?? other.caption,
      helper: helper ?? other.helper,
      error: error ?? other.error,
      code: code ?? other.code,
      muted: muted ?? other.muted,
    );
  }

  /// Admin-compact defaults assembled from upstream size tokens + weight/color.
  /// Compact admin sizes stay absolute so [AdaptiveScaling.mobile] (1.25x)
  /// does not inflate page titles / body copy in dense admin UIs.
  static TextStyle _default(AppTextRole role, shad.ThemeData theme) {
    final typography = theme.typography;
    final colors = theme.colorScheme;
    final muted = colors.mutedForeground;
    TextStyle sized(
      double fontSize, {
      FontWeight weight = FontWeight.w400,
      Color? color,
      bool mono = false,
    }) {
      final face = mono ? typography.mono : typography.sans;
      return face.copyWith(
        fontSize: fontSize,
        fontWeight: weight,
        color: color,
      );
    }

    return switch (role) {
      AppTextRole.display => sized(30, weight: FontWeight.w700),
      AppTextRole.h1 => sized(24, weight: FontWeight.w600),
      AppTextRole.h2 => sized(20, weight: FontWeight.w600),
      AppTextRole.h3 => sized(18, weight: FontWeight.w600),
      AppTextRole.h4 ||
      AppTextRole.section ||
      AppTextRole.title => sized(16, weight: FontWeight.w600),
      AppTextRole.subtitle => sized(14, color: muted),
      AppTextRole.lead => sized(16),
      AppTextRole.body || AppTextRole.listItem => sized(14),
      AppTextRole.bodyStrong => sized(14, weight: FontWeight.w500),
      AppTextRole.label => sized(14, weight: FontWeight.w500),
      AppTextRole.caption ||
      AppTextRole.helper ||
      AppTextRole.listSecondary => sized(12, color: muted),
      AppTextRole.error => sized(12, color: colors.destructive),
      AppTextRole.code => sized(13, weight: FontWeight.w500, mono: true),
      AppTextRole.muted => sized(14, color: muted),
    };
  }

  static TextStyle resolve(
    BuildContext context,
    AppTextRole role,
    TextStyle? widgetStyle,
  ) {
    final theme = shad.Theme.of(context);
    final roleDefault = _default(role, theme);
    final override = shad.ComponentTheme.maybeOf<AppTextTheme>(
      context,
    )?._override(role);
    // Overrides often only set size/weight; keep role font (incl. mono for code).
    final base = override == null ? roleDefault : roleDefault.merge(override);
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

  const AppText.display(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.display;

  const AppText.h1(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.h1;

  const AppText.h2(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.h2;

  const AppText.h3(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.h3;

  const AppText.h4(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.h4;

  const AppText.section(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.section;

  const AppText.title(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.title;

  const AppText.subtitle(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.subtitle;

  const AppText.lead(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.lead;

  const AppText.body(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.body;

  const AppText.bodyStrong(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.bodyStrong;

  const AppText.label(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.label;

  const AppText.listItem(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.listItem;

  const AppText.listSecondary(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.listSecondary;

  const AppText.caption(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.caption;

  const AppText.helper(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.helper;

  const AppText.error(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.error;

  const AppText.code(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.code;

  const AppText.muted(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
  }) : role = AppTextRole.muted;

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
