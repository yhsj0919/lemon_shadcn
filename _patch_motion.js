const fs = require('fs');
const path = 'E:/lemon_shadcn/lib/src/foundation/app_theme_config.dart';
let t = fs.readFileSync(path, 'utf8').replace(/\r\n/g, '\n');

const oldMotionBlockStart = '/// Shared interactive motion tokens for [AppButton] / [AppIconButton].';
const oldMotionBlockEnd = 'enum AppShadowColorMode';
const start = t.indexOf(oldMotionBlockStart);
const end = t.indexOf(oldMotionBlockEnd);
if (start < 0 || end < 0) { console.error('block markers', start, end); process.exit(1); }

const neu = `/// Shared interactive motion tokens for [AppButton], [AppIconButton], and
/// [AppMotion] hover/press feedback.
///
/// Configure once via [AppMotionTheme.button] — all interactive surfaces read
/// the same values (no per-widget hardcoding).
@immutable
class AppButtonMotion {
  const AppButtonMotion({
    this.hoverOffset = const Offset(0, -3),
    this.hoverScale = 1.015,
    this.pressedScale = 0.96,
    this.pressExtraLift = 1.5,
    this.unhoveredPressNudge = 1.0,
    this.hoverDuration = const Duration(milliseconds: 240),
    this.pressDuration = const Duration(milliseconds: 140),
    this.hoverShadowOpacity = 0.14,
    this.hoverShadowBlurBase = 10,
    this.hoverShadowBlurExtra = 6,
    this.hoverShadowSpread = -4,
    this.hoverShadowOffsetBase = 3,
    this.hoverShadowOffsetExtra = 3,
  });

  static const standard = AppButtonMotion();

  /// Hover translation (typically upward, e.g. \`Offset(0, -3)\`).
  final Offset hoverOffset;

  /// Hover scale for [AppMotion.scale] / lift emphasis.
  final double hoverScale;

  /// Scale while pressed.
  final double pressedScale;

  /// Extra upward lift (px) for [AppButtonPressEffect.lift].
  final double pressExtraLift;

  /// Slight downward nudge when pressing without hover.
  final double unhoveredPressNudge;

  final Duration hoverDuration;
  final Duration pressDuration;

  final double hoverShadowOpacity;
  final double hoverShadowBlurBase;
  final double hoverShadowBlurExtra;
  final double hoverShadowSpread;
  final double hoverShadowOffsetBase;
  final double hoverShadowOffsetExtra;

  AppButtonMotion copyWith({
    Offset? hoverOffset,
    double? hoverScale,
    double? pressedScale,
    double? pressExtraLift,
    double? unhoveredPressNudge,
    Duration? hoverDuration,
    Duration? pressDuration,
    double? hoverShadowOpacity,
    double? hoverShadowBlurBase,
    double? hoverShadowBlurExtra,
    double? hoverShadowSpread,
    double? hoverShadowOffsetBase,
    double? hoverShadowOffsetExtra,
  }) {
    return AppButtonMotion(
      hoverOffset: hoverOffset ?? this.hoverOffset,
      hoverScale: hoverScale ?? this.hoverScale,
      pressedScale: pressedScale ?? this.pressedScale,
      pressExtraLift: pressExtraLift ?? this.pressExtraLift,
      unhoveredPressNudge: unhoveredPressNudge ?? this.unhoveredPressNudge,
      hoverDuration: hoverDuration ?? this.hoverDuration,
      pressDuration: pressDuration ?? this.pressDuration,
      hoverShadowOpacity: hoverShadowOpacity ?? this.hoverShadowOpacity,
      hoverShadowBlurBase: hoverShadowBlurBase ?? this.hoverShadowBlurBase,
      hoverShadowBlurExtra: hoverShadowBlurExtra ?? this.hoverShadowBlurExtra,
      hoverShadowSpread: hoverShadowSpread ?? this.hoverShadowSpread,
      hoverShadowOffsetBase:
          hoverShadowOffsetBase ?? this.hoverShadowOffsetBase,
      hoverShadowOffsetExtra:
          hoverShadowOffsetExtra ?? this.hoverShadowOffsetExtra,
    );
  }
}

@immutable
class AppMotionTheme {
  const AppMotionTheme({
    this.enabled = true,
    this.loadingDelay = const Duration(milliseconds: 120),
    this.minimumLoadingDuration = const Duration(milliseconds: 250),
    this.depthPerspective = 0.0012,
    this.depthDuration = const Duration(milliseconds: 320),
    this.depthTiltDuration = const Duration(milliseconds: 100),
    this.depthPressDuration = const Duration(milliseconds: 150),
    this.depthRotateY = 0.14,
    this.depthOffsetY = -10,
    this.depthTranslateZ = 18,
    this.depthPressAmount = 0.42,
    this.button = const AppButtonMotion(),
    // When false, AppButtons that omit config stay still (no hover lift).
    // Explicit configs (nav / toolbars) are always unchanged either way.
    this.buttonInteractive = true,
  });

  final bool enabled;
  final Duration loadingDelay;
  final Duration minimumLoadingDuration;
  final double depthPerspective;
  final Duration depthDuration;
  final Duration depthTiltDuration;
  final Duration depthPressDuration;
  final double depthRotateY;
  final double depthOffsetY;
  final double depthTranslateZ;
  final double depthPressAmount;

  /// Single motion profile for buttons and [AppMotion] hover/press.
  final AppButtonMotion button;

  /// When true (default), [AppButton]s that omit [config] use interactive motion.
  /// Set false to disable that default; chrome that passes an explicit config
  /// never picks this up.
  final bool buttonInteractive;

  /// Forwards to [button.hoverDuration] (shared interactive timing).
  Duration get duration => button.hoverDuration;

  /// Forwards to [button.hoverScale].
  double get hoverScale => button.hoverScale;

  /// Forwards to [button.pressedScale].
  double get pressedScale => button.pressedScale;

  /// Forwards to [button.hoverOffset].
  Offset get hoverOffset => button.hoverOffset;
}

`;

t = t.slice(0, start) + neu + t.slice(end);

// Simplify presets: only button, drop duplicate fields
const presets = [
  {
    old: `        motion: const AppMotionTheme(
          duration: Duration(milliseconds: 220),
          hoverScale: 1.01,
          pressedScale: 0.98,
          hoverOffset: Offset(0, -1),
          button: AppButtonMotion(
            hoverOffset: Offset(0, -1),
            pressedScale: 0.98,
            hoverDuration: Duration(milliseconds: 220),
          ),
        ),`,
    neu: `        motion: const AppMotionTheme(
          button: AppButtonMotion(
            hoverOffset: Offset(0, -1),
            hoverScale: 1.01,
            pressedScale: 0.98,
            hoverDuration: Duration(milliseconds: 220),
          ),
        ),`,
  },
  {
    old: `        motion: const AppMotionTheme(
          duration: Duration(milliseconds: 120),
          hoverScale: 1,
          pressedScale: 0.99,
          hoverOffset: Offset.zero,
          button: AppButtonMotion(
            hoverOffset: Offset.zero,
            pressedScale: 0.99,
            hoverDuration: Duration(milliseconds: 120),
            pressDuration: Duration(milliseconds: 100),
          ),
        ),`,
    neu: `        motion: const AppMotionTheme(
          button: AppButtonMotion(
            hoverOffset: Offset.zero,
            hoverScale: 1,
            pressedScale: 0.99,
            hoverDuration: Duration(milliseconds: 120),
            pressDuration: Duration(milliseconds: 100),
          ),
        ),`,
  },
  {
    old: `        motion: const AppMotionTheme(
          duration: Duration(milliseconds: 200),
          hoverScale: 1.01,
          pressedScale: 0.97,
          hoverOffset: Offset(0, -1),
          button: AppButtonMotion(
            hoverOffset: Offset(0, -1),
            pressedScale: 0.97,
            hoverDuration: Duration(milliseconds: 200),
          ),
        ),`,
    neu: `        motion: const AppMotionTheme(
          button: AppButtonMotion(
            hoverOffset: Offset(0, -1),
            hoverScale: 1.01,
            pressedScale: 0.97,
            hoverDuration: Duration(milliseconds: 200),
          ),
        ),`,
  },
];

for (const p of presets) {
  if (!t.includes(p.old)) { console.error('preset missing'); console.log(t.includes('hoverScale: 1.01')); process.exit(1); }
  t = t.replace(p.old, p.neu);
}

fs.writeFileSync(path, t.replace(/\n/g, '\r\n'));
console.log('theme ok');
