import 'package:flutter/material.dart' as material;
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import 'app_theme_config.dart';

class AppShadcnScope extends StatelessWidget {
  const AppShadcnScope({
    super.key,
    required this.child,
    this.config,
    this.provideMaterialHost = true,
  });

  final Widget child;
  final AppThemeConfig? config;
  final bool provideMaterialHost;

  static TransitionBuilder builder({AppThemeConfig? config}) {
    return (context, child) =>
        AppShadcnScope(config: config, child: child ?? const SizedBox.shrink());
  }

  @override
  Widget build(BuildContext context) {
    final resolved = config ?? AppThemeConfig.standard();
    return _AppThemeConfigScope(
      config: resolved,
      child: shad.ShadcnLayer(
        theme: resolved.lightTheme,
        darkTheme: resolved.darkTheme,
        themeMode: resolved.themeMode,
        enableScrollInterception: resolved.enableScrollInterception,
        child: _AppOverlayHost(
          child: shad.DrawerOverlay(
            child: provideMaterialHost
                ? material.Material(
                    type: material.MaterialType.transparency,
                    child: child,
                  )
                : child,
          ),
        ),
      ),
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
