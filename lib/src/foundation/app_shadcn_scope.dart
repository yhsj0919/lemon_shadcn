import 'package:flutter/material.dart' show Material, MaterialType, Theme;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../components/display/app_text.dart';
import 'app_theme_config.dart';
import 'app_localizations_zh.dart';
import 'app_outline_style.dart';
import 'app_overlay_style.dart';

class AppShadcnScope extends StatelessWidget {
  const AppShadcnScope({
    super.key,
    required this.child,
    this.config,
    this.locale,
    this.provideMaterialHost = true,
    this.syncMaterialTheme = true,
  });

  final Widget child;
  final AppThemeConfig? config;
  final Locale? locale;
  final bool provideMaterialHost;

  /// When true (default), mirrors shadcn primary + sans fontFamily into the
  /// ambient Material [ThemeData] so existing Material widgets stay on brand.
  final bool syncMaterialTheme;

  static TransitionBuilder builder({
    AppThemeConfig? config,
    Locale? locale,
    bool syncMaterialTheme = true,
  }) {
    return (context, child) => AppShadcnScope(
      config: config,
      locale: locale,
      syncMaterialTheme: syncMaterialTheme,
      child: child ?? const SizedBox.shrink(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = config ?? AppThemeConfig.standard();
    var themedChild = resolved.componentThemeWrapper?.call(child) ?? child;
    final textTheme = resolved.textTheme;
    if (textTheme != null) {
      themedChild = shad.ComponentTheme<AppTextTheme>(
        data: textTheme,
        child: themedChild,
      );
    }
    return _AppThemeConfigScope(
      config: resolved,
      child: _AppLocalizationsHost(
        locale: locale,
        child: shad.ShadcnLayer(
          theme: resolved.lightTheme,
          darkTheme: resolved.darkTheme,
          themeMode: resolved.themeMode,
          // Keep layouts at 1.0 regardless of the test/host TargetPlatform.
          // Upstream defaults to AdaptiveScaling.mobile (1.25) on Android,
          // which would inflate every carefully-tuned control metric.
          scaling: shad.AdaptiveScaling.desktop,
          enableScrollInterception: resolved.enableScrollInterception,
          child: _AppControlComponentThemes(
            metrics: resolved.controls,
            child: _AppOverlayHost(
              child: shad.ToastLayer(
                child: shad.DrawerOverlay(
                  child: _MaterialThemeBridge(
                    enabled: syncMaterialTheme,
                    child: provideMaterialHost
                        ? Material(
                            type: MaterialType.transparency,
                            child: themedChild,
                          )
                        : themedChild,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Copies shadcn primary / UI font into Material so mixed trees stay aligned.
class _MaterialThemeBridge extends StatelessWidget {
  const _MaterialThemeBridge({required this.enabled, required this.child});

  final bool enabled;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    // Prefer ancestor [Theme] so Scope still works without MaterialApp
    // (widget tests) and without depending on Theme.maybeOf availability.
    final themeWidget = context.findAncestorWidgetOfExactType<Theme>();
    if (themeWidget == null) return child;

    final material = themeWidget.data;
    final shadTheme = shad.Theme.of(context);
    final colors = shadTheme.colorScheme;
    final sans = shadTheme.typography.sans;
    // Platform stacks often leave fontFamily null and rely on fallbacks
    // (e.g. Android). Prefer an explicit family so Material TextTheme.apply
    // actually replaces Roboto / the host default.
    final fontFamily = sans.fontFamily ?? sans.fontFamilyFallback?.firstOrNull;
    final fontPackage = _fontPackageFor(fontFamily);
    final listItem = AppTextTheme.resolve(context, AppTextRole.listItem, null);
    final listSecondary = AppTextTheme.resolve(
      context,
      AppTextRole.listSecondary,
      null,
    );
    final textTheme = material.textTheme.apply(
      fontFamily: fontFamily,
      fontFamilyFallback: sans.fontFamilyFallback,
      package: fontPackage,
    );
    // Merge list scale onto themed styles so null fontFamily on system stacks
    // does not wipe the family applied above.
    TextStyle listStyle(TextStyle? host, TextStyle role) =>
        host?.merge(role) ?? role;
    final bridged = material.copyWith(
      colorScheme: material.colorScheme.copyWith(
        primary: colors.primary,
        onPrimary: colors.primaryForeground,
      ),
      primaryColor: colors.primary,
      textTheme: textTheme.copyWith(
        titleMedium: listStyle(textTheme.titleMedium, listItem),
        titleSmall: listStyle(textTheme.titleSmall, listItem),
        bodyLarge: listStyle(textTheme.bodyLarge, listItem),
        bodyMedium: listStyle(textTheme.bodyMedium, listItem),
        bodySmall: listStyle(textTheme.bodySmall, listSecondary),
        labelLarge: listStyle(
          textTheme.labelLarge,
          listItem.copyWith(fontWeight: FontWeight.w500),
        ),
        labelMedium: listStyle(
          textTheme.labelMedium,
          listSecondary.copyWith(fontWeight: FontWeight.w500),
        ),
        labelSmall: listStyle(textTheme.labelSmall, listSecondary),
      ),
      primaryTextTheme: material.primaryTextTheme.apply(
        fontFamily: fontFamily,
        fontFamilyFallback: sans.fontFamilyFallback,
        package: fontPackage,
      ),
      listTileTheme: material.listTileTheme.copyWith(
        titleTextStyle: listStyle(textTheme.titleMedium, listItem),
        subtitleTextStyle: listStyle(textTheme.bodySmall, listSecondary),
        leadingAndTrailingTextStyle: listStyle(
          textTheme.labelSmall,
          listSecondary,
        ),
      ),
    );
    return Theme(data: bridged, child: child);
  }

  static String? _fontPackageFor(String? fontFamily) {
    return switch (fontFamily) {
      'GeistSans' || 'GeistMono' => 'shadcn_flutter',
      _ => null,
    };
  }
}

class _AppControlComponentThemes extends StatelessWidget {
  const _AppControlComponentThemes({
    required this.metrics,
    required this.child,
  });

  final AppControlMetrics metrics;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final inheritedTheme = shad.Theme.of(context);
    EdgeInsetsGeometry padding(
      BuildContext context,
      Set<WidgetState> states,
      EdgeInsetsGeometry current,
    ) {
      final resolved = current.resolve(Directionality.of(context));
      return EdgeInsets.fromLTRB(
        metrics.horizontalPadding,
        resolved.top,
        metrics.horizontalPadding,
        resolved.bottom,
      );
    }

    IconThemeData iconTheme(
      BuildContext context,
      Set<WidgetState> states,
      IconThemeData current,
    ) => current.copyWith(size: metrics.iconSize);

    Decoration outlineDecoration(
      BuildContext context,
      Set<WidgetState> states,
      Decoration current,
    ) {
      return AppOutlineStyle.resolve(context, states, current);
    }

    return shad.Theme(
      data: inheritedTheme.copyWith(
        iconTheme: () => inheritedTheme.iconTheme.copyWith(
          xSmall: () => IconThemeData(size: metrics.iconSize),
        ),
      ),
      child: shad.ComponentTheme<shad.ModalBackdropTheme>(
        data: shad.ModalBackdropTheme(
          barrierColor: AppOverlayStyle.modalBarrier(context),
        ),
        child: shad.ComponentTheme<shad.PrimaryButtonTheme>(
          data: shad.PrimaryButtonTheme(padding: padding, iconTheme: iconTheme),
          child: shad.ComponentTheme<shad.SecondaryButtonTheme>(
            data: shad.SecondaryButtonTheme(
              padding: padding,
              iconTheme: iconTheme,
            ),
            child: shad.ComponentTheme<shad.OutlineButtonTheme>(
              data: shad.OutlineButtonTheme(
                padding: padding,
                iconTheme: iconTheme,
                decoration: outlineDecoration,
              ),
              child: shad.ComponentTheme<shad.GhostButtonTheme>(
                data: shad.GhostButtonTheme(
                  padding: padding,
                  iconTheme: iconTheme,
                ),
                child: shad.ComponentTheme<shad.DestructiveButtonTheme>(
                  data: shad.DestructiveButtonTheme(
                    padding: padding,
                    iconTheme: iconTheme,
                  ),
                  child: shad.ComponentTheme<shad.LinkButtonTheme>(
                    data: shad.LinkButtonTheme(
                      padding: padding,
                      iconTheme: iconTheme,
                    ),
                    child: shad.ComponentTheme<shad.TextButtonTheme>(
                      data: shad.TextButtonTheme(
                        padding: padding,
                        iconTheme: iconTheme,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AppLocalizationsHost extends StatelessWidget {
  const _AppLocalizationsHost({required this.child, this.locale});

  final Widget child;
  final Locale? locale;

  @override
  Widget build(BuildContext context) {
    final existing = Localizations.of<shad.ShadcnLocalizations>(
      context,
      shad.ShadcnLocalizations,
    );
    if (existing != null && locale == null) return child;
    return Localizations.override(
      context: context,
      locale:
          locale ??
          Localizations.maybeLocaleOf(context) ??
          const Locale('zh', 'CN'),
      delegates: const [
        AppLocalizationsZh.delegate,
        shad.ShadcnLocalizations.delegate,
      ],
      child: child,
    );
  }
}

class _AppOverlayHost extends StatefulWidget {
  const _AppOverlayHost({required this.child});

  final Widget child;

  @override
  State<_AppOverlayHost> createState() => _AppOverlayHostState();
}

class _AppOverlayHostState extends State<_AppOverlayHost> {
  late final OverlayEntry _entry = OverlayEntry(
    builder: (context) => widget.child,
  );

  @override
  void didUpdateWidget(_AppOverlayHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    return Overlay(initialEntries: [_entry]);
  }
}

class AppTheme extends InheritedWidget {
  const AppTheme._({required this.config, required super.child});

  final AppThemeConfig config;

  static AppThemeConfig of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppTheme>();
    assert(scope != null, 'No AppShadcnScope found in this context.');
    return scope!.config;
  }

  static AppThemeConfig? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppTheme>()?.config;
  }

  @override
  bool updateShouldNotify(AppTheme oldWidget) => config != oldWidget.config;
}

class _AppThemeConfigScope extends StatelessWidget {
  const _AppThemeConfigScope({required this.config, required this.child});

  final AppThemeConfig config;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AppTheme._(config: config, child: child);
  }
}
