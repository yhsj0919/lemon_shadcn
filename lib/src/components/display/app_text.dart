import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_utility_components.dart';

/// Optional overflow behavior for a single-line [AppText].
enum AppTextScrollMode {
  /// Starts scrolling as soon as the text overflows.
  automatic,

  /// Stays at the start and scrolls only while the pointer is inside.
  hover,
}

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
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null;

  /// Rich-text variant for content with mixed sizes, weights, or colors.
  const AppText.rich(
    this.textSpan, {
    super.key,
    this.role = AppTextRole.body,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : data = null;

  const AppText.display(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.display;

  const AppText.h1(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.h1;

  const AppText.h2(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.h2;

  const AppText.h3(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.h3;

  const AppText.h4(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.h4;

  const AppText.section(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.section;

  const AppText.title(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.title;

  const AppText.subtitle(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.subtitle;

  const AppText.lead(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.lead;

  const AppText.body(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.body;

  const AppText.bodyStrong(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.bodyStrong;

  const AppText.label(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.label;

  const AppText.listItem(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.listItem;

  const AppText.listSecondary(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.listSecondary;

  const AppText.caption(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.caption;

  const AppText.helper(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.helper;

  const AppText.error(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.error;

  const AppText.code(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.code;

  const AppText.muted(
    this.data, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.softWrap,
    this.leading,
    this.trailing,
    this.leadingGap,
    this.trailingGap,
    this.scrollMode,
    this.scrollDuration,
    this.scrollDelayDuration,
    this.scrollStep,
    this.scrollFadePortion,
    this.scrollCurve,
  }) : textSpan = null,
       role = AppTextRole.muted;

  final String? data;
  final InlineSpan? textSpan;
  final AppTextRole role;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;
  final bool? softWrap;
  final Widget? leading;
  final Widget? trailing;

  /// Space between [leading] and the text. Defaults according to the resolved
  /// font size: 4 for small text, 6 for body text, and 8 for larger headings.
  final double? leadingGap;

  /// Space between the text and [trailing]. Uses the same adaptive default as
  /// [leadingGap].
  final double? trailingGap;

  /// Enables single-line overflow scrolling. Null keeps the normal text
  /// layout; [AppTextScrollMode.automatic] and [AppTextScrollMode.hover]
  /// select the two scrolling behaviors.
  final AppTextScrollMode? scrollMode;
  final Duration? scrollDuration;
  final Duration? scrollDelayDuration;
  final double? scrollStep;
  final double? scrollFadePortion;
  final Curve? scrollCurve;

  static double _defaultGap(double? fontSize) {
    if (fontSize == null || fontSize <= 12) return 4;
    if (fontSize <= 16) return 6;
    return 8;
  }

  Widget _accessory(Widget child, TextStyle textStyle) {
    return IconTheme.merge(
      data: IconThemeData(color: textStyle.color, size: textStyle.fontSize),
      child: DefaultTextStyle.merge(style: textStyle, child: child),
    );
  }

  Widget _scrollingText(Widget child) {
    // Upstream scales this duration by overflowDistance / step. With the
    // default 100px step, 2.5s yields a calm, readable speed of about 40px/s.
    final duration = scrollDuration ?? const Duration(milliseconds: 2500);
    return switch (scrollMode) {
      AppTextScrollMode.automatic => AppOverflowMarquee(
        duration: duration,
        delayDuration: scrollDelayDuration,
        step: scrollStep,
        fadePortion: scrollFadePortion,
        curve: scrollCurve,
        child: child,
      ),
      AppTextScrollMode.hover => AppOverflowMarquee.hover(
        duration: duration,
        delayDuration: scrollDelayDuration,
        step: scrollStep,
        fadePortion: scrollFadePortion,
        curve: scrollCurve,
        child: child,
      ),
      null => child,
    };
  }

  @override
  Widget build(BuildContext context) {
    final resolvedStyle = AppTextTheme.resolve(context, role, style);
    final text = textSpan == null
        ? Text(
            data!,
            style: resolvedStyle,
            textAlign: textAlign,
            maxLines: scrollMode == null ? maxLines : 1,
            overflow: scrollMode == null ? overflow : TextOverflow.visible,
            softWrap: scrollMode == null ? softWrap : false,
          )
        : Text.rich(
            textSpan!,
            style: resolvedStyle,
            textAlign: textAlign,
            maxLines: scrollMode == null ? maxLines : 1,
            overflow: scrollMode == null ? overflow : TextOverflow.visible,
            softWrap: scrollMode == null ? softWrap : false,
          );
    final textContent = _scrollingText(text);

    if (leading == null && trailing == null) return textContent;

    final defaultGap = _defaultGap(resolvedStyle.fontSize);
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (leading case final leading?) ...[
          _accessory(leading, resolvedStyle),
          if ((leadingGap ?? defaultGap) > 0)
            SizedBox(width: leadingGap ?? defaultGap),
        ],
        Flexible(child: textContent),
        if (trailing case final trailing?) ...[
          if ((trailingGap ?? defaultGap) > 0)
            SizedBox(width: trailingGap ?? defaultGap),
          _accessory(trailing, resolvedStyle),
        ],
      ],
    );
  }
}
