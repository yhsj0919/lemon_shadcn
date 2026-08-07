import 'package:flutter/widgets.dart';

class AppInlineEditOverlayController {
  AppInlineEditOverlayController({this.onClosed});

  final VoidCallback? onClosed;
  int _openOverlays = 0;

  bool get hasOpenOverlay => _openOverlays > 0;

  void opened() {
    _openOverlays++;
  }

  void closed() {
    if (_openOverlays == 0) return;
    _openOverlays--;
    if (_openOverlays == 0) onClosed?.call();
  }
}

class AppInlineEditOverlayScope extends InheritedWidget {
  const AppInlineEditOverlayScope({
    super.key,
    required this.controller,
    required super.child,
  });

  final AppInlineEditOverlayController controller;

  static AppInlineEditOverlayController? maybeOf(BuildContext context) =>
      context
          .dependOnInheritedWidgetOfExactType<AppInlineEditOverlayScope>()
          ?.controller;

  @override
  bool updateShouldNotify(AppInlineEditOverlayScope oldWidget) =>
      controller != oldWidget.controller;
}
