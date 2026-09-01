import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../display/app_semantic_style.dart';

enum AppPaginationVariant { labeled, iconOnly }

typedef AppPaginationItemBuilder =
    Widget Function(
      BuildContext context,
      int page,
      bool selected,
      VoidCallback onPressed,
    );

typedef AppPaginationNavigationBuilder =
    Widget Function(
      BuildContext context,
      bool enabled,
      VoidCallback? onPressed,
    );

typedef AppPaginationEllipsisBuilder =
    Widget Function(BuildContext context, VoidCallback onPressed);

class AppPagination extends StatelessWidget {
  const AppPagination({
    super.key,
    required this.page,
    required this.totalPages,
    required this.onPageChanged,
    this.maxPages = 3,
    this.showSkipToFirstPage = true,
    this.showSkipToLastPage = true,
    this.hidePreviousOnFirstPage = false,
    this.hideNextOnLastPage = false,
    this.variant = AppPaginationVariant.iconOnly,
    this.showLabel,
    this.gap,
    this.itemBuilder,
    this.previousBuilder,
    this.nextBuilder,
    this.ellipsisBuilder,
  }) : assert(totalPages >= 1),
       assert(page >= 1 && page <= totalPages),
       assert(maxPages >= 1),
       assert(gap == null || gap >= 0);

  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int maxPages;
  final bool showSkipToFirstPage;
  final bool showSkipToLastPage;
  final bool hidePreviousOnFirstPage;
  final bool hideNextOnLastPage;
  final AppPaginationVariant variant;

  /// Compatibility override. When null, [variant] controls label visibility.
  final bool? showLabel;
  final double? gap;
  final AppPaginationItemBuilder? itemBuilder;
  final AppPaginationNavigationBuilder? previousBuilder;
  final AppPaginationNavigationBuilder? nextBuilder;
  final AppPaginationEllipsisBuilder? ellipsisBuilder;

  bool get hasPrevious => page > 1;
  bool get hasNext => page < totalPages;

  Iterable<int> get pages sync* {
    if (totalPages <= maxPages) {
      yield* List.generate(totalPages, (index) => index + 1);
      return;
    }
    final start = (page - maxPages ~/ 2).clamp(1, totalPages - maxPages + 1);
    yield* List.generate(maxPages, (index) => start + index);
  }

  int get firstShownPage => pages.first;
  int get lastShownPage => pages.last;

  Widget _pageButton(BuildContext context, int value) {
    final selected = value == page;
    final onPressed = () => onPageChanged(value);
    if (itemBuilder != null) {
      return itemBuilder!(context, value, selected, onPressed);
    }
    if (!selected) {
      return shad.ButtonStyleOverride(
        decoration: (context, states, value) => value is BoxDecoration
            ? value.copyWith(color: const Color(0x00000000))
            : value,
        child: shad.GhostButton(
          onPressed: onPressed,
          child: Text('$value'),
        ),
      );
    }

    final theme = shad.Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    return shad.Button(
      onPressed: onPressed,
      style: const shad.ButtonStyle.ghost().copyWith(
        decoration: (context, states, decoration) {
          if (decoration is! BoxDecoration) return decoration;
          final disabled = states.contains(WidgetState.disabled);
          final pressed = states.contains(WidgetState.pressed);
          final hovered = states.contains(WidgetState.hovered);
          final lightOpacity = disabled
              ? 0.04
              : pressed
              ? 0.14
              : hovered
              ? 0.11
              : AppSoftColor.selectionLightOpacity;
          final darkOpacity = disabled
              ? 0.06
              : pressed
              ? 0.18
              : hovered
              ? 0.15
              : AppSoftColor.selectionDarkOpacity;
          return decoration.copyWith(
            color: AppSoftColor.background(
              theme,
              selectedColor,
              lightOpacity: lightOpacity,
              darkOpacity: darkOpacity,
            ),
          );
        },
        textStyle: (context, states, style) => style.copyWith(
          color: selectedColor.withValues(
            alpha: states.contains(WidgetState.disabled) ? 0.45 : 1,
          ),
        ),
        iconTheme: (context, states, style) => style.copyWith(
          color: selectedColor.withValues(
            alpha: states.contains(WidgetState.disabled) ? 0.45 : 1,
          ),
        ),
      ),
      child: Text('$value'),
    );
  }

  Widget _ellipsis(BuildContext context, int target) {
    final onPressed = () => onPageChanged(target);
    return ellipsisBuilder?.call(context, onPressed) ??
        shad.GhostButton(
          onPressed: onPressed,
          child: const shad.MoreDots(),
        );
  }

  Widget _previous(BuildContext context, bool labels) {
    final onPressed = hasPrevious ? () => onPageChanged(page - 1) : null;
    return previousBuilder?.call(context, hasPrevious, onPressed) ??
        shad.GhostButton(
          onPressed: onPressed,
          leading: labels
              ? const Icon(shad.RadixIcons.chevronLeft, size: 14)
              : null,
          child: labels
              ? Text(shad.ShadcnLocalizations.of(context).buttonPrevious)
              : const Icon(shad.RadixIcons.chevronLeft, size: 14),
        );
  }

  Widget _next(BuildContext context, bool labels) {
    final onPressed = hasNext ? () => onPageChanged(page + 1) : null;
    return nextBuilder?.call(context, hasNext, onPressed) ??
        shad.GhostButton(
          onPressed: onPressed,
          trailing: labels
              ? const Icon(shad.RadixIcons.chevronRight, size: 14)
              : null,
          child: labels
              ? Text(shad.ShadcnLocalizations.of(context).buttonNext)
              : const Icon(shad.RadixIcons.chevronRight, size: 14),
        );
  }

  @override
  Widget build(BuildContext context) {
    final labels = showLabel ?? variant == AppPaginationVariant.labeled;
    final resolvedGap = gap ?? 4 * shad.Theme.of(context).scaling;
    final controls = <Widget>[];
    if (!hidePreviousOnFirstPage || hasPrevious) {
      controls.add(_previous(context, labels));
    }
    if (firstShownPage > 1) {
      if (showSkipToFirstPage && firstShownPage > 2) {
        controls.add(_pageButton(context, 1));
      }
      controls.add(_ellipsis(context, firstShownPage - 1));
    }
    controls.addAll(pages.map((value) => _pageButton(context, value)));
    if (lastShownPage < totalPages) {
      controls.add(_ellipsis(context, lastShownPage + 1));
      if (showSkipToLastPage && lastShownPage < totalPages - 1) {
        controls.add(_pageButton(context, totalPages));
      }
    }
    if (!hideNextOnLastPage || hasNext) {
      controls.add(_next(context, labels));
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var index = 0; index < controls.length; index++) ...[
          if (index > 0) SizedBox(width: resolvedGap),
          controls[index],
        ],
      ],
    );
  }
}
