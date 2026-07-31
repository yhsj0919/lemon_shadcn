import 'package:flutter/material.dart' show Material, MaterialType;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_theme_config.dart';
import 'app_localizations_zh.dart';
import 'app_overlay_style.dart';

class AppShadcnScope extends StatelessWidget {
  const AppShadcnScope({
    super.key,
    required this.child,
    this.config,
    this.locale,
    this.provideMaterialHost = true,
  });

  final Widget child;
  final AppThemeConfig? config;
  final Locale? locale;
  final bool provideMaterialHost;

  static TransitionBuilder builder({AppThemeConfig? config, Locale? locale}) {
    return (context, child) =>
        AppShadcnScope(
          config: config,
          locale: locale,
          child: child ?? const SizedBox.shrink(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = config ?? AppThemeConfig.standard();
    final themedChild = resolved.componentThemeWrapper?.call(child) ?? child;
    return _AppThemeConfigScope(
      config: resolved,
      child: _AppLocalizationsHost(
        locale: locale,
        child: shad.ShadcnLayer(
          theme: resolved.lightTheme,
          darkTheme: resolved.darkTheme,
          themeMode: resolved.themeMode,
          enableScrollInterception: resolved.enableScrollInterception,
          child: _AppControlComponentThemes(
            metrics: resolved.controls,
            child: _AppOverlayHost(
              child: shad.ToastLayer(
                child: shad.DrawerOverlay(
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
    );
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

    return shad.ComponentTheme<shad.ModalBackdropTheme>(
      data: shad.ModalBackdropTheme(
        barrierColor: AppOverlayStyle.modalBarrier(context),
      ),
      child: shad.ComponentTheme<shad.PrimaryButtonTheme>(
        data: shad.PrimaryButtonTheme(padding: padding, iconTheme: iconTheme),
        child: shad.ComponentTheme<shad.SecondaryButtonTheme>(
        data: shad.SecondaryButtonTheme(padding: padding, iconTheme: iconTheme),
        child: shad.ComponentTheme<shad.OutlineButtonTheme>(
          data: shad.OutlineButtonTheme(padding: padding, iconTheme: iconTheme),
          child: shad.ComponentTheme<shad.GhostButtonTheme>(
            data: shad.GhostButtonTheme(padding: padding, iconTheme: iconTheme),
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
          locale ?? Localizations.maybeLocaleOf(context) ?? const Locale('zh', 'CN'),
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
