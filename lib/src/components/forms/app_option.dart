import 'package:flutter/widgets.dart';

@immutable
class AppOption<V> {
  const AppOption({
    required this.value,
    required this.label,
    this.child,
    this.keywords = const [],
    this.disabled = false,
  });

  final V value;
  final String label;
  final Widget? child;
  final List<String> keywords;
  final bool disabled;
}
