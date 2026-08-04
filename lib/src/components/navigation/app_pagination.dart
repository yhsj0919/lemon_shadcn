import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Thin wrapper over upstream [shad.Pagination].
///
/// Bumps the chevron size via theme (`iconTheme.xSmall` → 16) because upstream
/// hardcodes `.iconXSmall()` and [shad.PaginationTheme] has no icon size knobs.
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
    this.showLabel,
    this.gap,
  });

  final int page;
  final int totalPages;
  final ValueChanged<int> onPageChanged;
  final int maxPages;
  final bool showSkipToFirstPage;
  final bool showSkipToLastPage;
  final bool hidePreviousOnFirstPage;
  final bool hideNextOnLastPage;
  final bool? showLabel;
  final double? gap;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    return shad.Theme(
      data: theme.copyWith(
        iconTheme: () => theme.iconTheme.copyWith(
          xSmall: () => const IconThemeData(size: 16),
        ),
      ),
      child: shad.Pagination(
        page: page,
        totalPages: totalPages,
        onPageChanged: onPageChanged,
        maxPages: maxPages,
        showSkipToFirstPage: showSkipToFirstPage,
        showSkipToLastPage: showSkipToLastPage,
        hidePreviousOnFirstPage: hidePreviousOnFirstPage,
        hideNextOnLastPage: hideNextOnLastPage,
        showLabel: showLabel,
        gap: gap,
      ),
    );
  }
}
