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

@immutable
class AppOptionViewState {
  const AppOptionViewState({
    required this.selected,
    required this.highlighted,
    required this.disabled,
    this.query = '',
  });

  final bool selected;
  final bool highlighted;
  final bool disabled;
  final String query;
}

typedef AppOptionItemBuilder<V> =
    Widget Function(
      BuildContext context,
      AppOption<V> option,
      AppOptionViewState state,
    );
typedef AppSelectedOptionBuilder<V> =
    Widget Function(BuildContext context, AppOption<V> option);
typedef AppOptionTokenBuilder<V> =
    Widget Function(
      BuildContext context,
      AppOption<V> option,
      VoidCallback remove,
    );
typedef AppOptionEquals<V> = bool Function(V left, V right);

/// Shared object identity and presentation rules for selection controls.
@immutable
class AppOptionConfig<V> {
  const AppOptionConfig({
    this.equals,
    this.optionBuilder,
    this.selectedBuilder,
    this.tokenBuilder,
    this.searchText,
  });

  final AppOptionEquals<V>? equals;
  final AppOptionItemBuilder<V>? optionBuilder;
  final AppSelectedOptionBuilder<V>? selectedBuilder;
  final AppOptionTokenBuilder<V>? tokenBuilder;
  final String Function(AppOption<V> option)? searchText;

  bool isEqual<T>(T left, T right) {
    final compare = equals;
    return compare == null
        ? left == right
        : (compare as bool Function(T left, T right))(left, right);
  }

  String searchableText<T>(AppOption<T> option) {
    final resolve = searchText;
    return resolve == null
        ? <String>[option.label, ...option.keywords].join(' ')
        : (resolve as String Function(AppOption<T> option))(option);
  }

  Widget buildOption<T>(
    BuildContext context,
    AppOption<T> option,
    AppOptionViewState state,
  ) {
    final builder = optionBuilder;
    return builder == null
        ? option.child ??
              Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis)
        : (builder as AppOptionItemBuilder<T>)(context, option, state);
  }

  Widget buildSelected<T>(BuildContext context, AppOption<T> option) {
    final builder = selectedBuilder;
    return builder == null
        ? option.child ??
              Text(option.label, maxLines: 1, overflow: TextOverflow.ellipsis)
        : (builder as AppSelectedOptionBuilder<T>)(context, option);
  }
}
