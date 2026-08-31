import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

import '../../foundation/app_control_box.dart';

/// Foreground and padding defaults shared by [AppTabs] and [AppTabList].
class AppTabsTheme extends shad.ComponentThemeData {
  const AppTabsTheme({
    this.selectedForegroundColor,
    this.unselectedForegroundColor,
    this.tabPadding,
  });

  final Color? selectedForegroundColor;
  final Color? unselectedForegroundColor;

  /// Padding around each tab label/icon. Overrides the density default when set.
  final EdgeInsetsGeometry? tabPadding;
}

/// Segmented tabs with a sliding selection indicator.
class AppTabs extends StatefulWidget {
  const AppTabs({
    super.key,
    required this.index,
    required this.onChanged,
    required this.children,
    this.padding,
    this.expand = false,
    this.iconOnly = false,
    this.selectedColor,
    this.selectedTextColor,
    this.unselectedColor,
    this.unselectedForegroundColor,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<shad.TabChild> children;

  /// Padding around each tab's content.
  ///
  /// Overrides [AppTabsTheme.tabPadding] and the density-based default. Prefer
  /// equal insets (e.g. [EdgeInsets.all]) with [iconOnly] so tabs stay square.
  final EdgeInsetsGeometry? padding;
  final bool expand;

  /// When true, tabs size to a square around their content instead of stretching
  /// horizontally. Defaults size so the full track matches
  /// [AppControlMetrics.height] (icon + equal padding + container inset).
  final bool iconOnly;

  /// Background color of the selected tab. Defaults to the theme primary.
  final Color? selectedColor;

  /// Text and icon color of the selected tab. Defaults to an automatic
  /// contrast color for [selectedColor].
  final Color? selectedTextColor;

  /// Background color of the unselected area. Defaults to the theme muted
  /// color.
  final Color? unselectedColor;

  /// Text and icon color of unselected tabs. Falls back to [AppTabsTheme],
  /// then to the semantic muted foreground.
  final Color? unselectedForegroundColor;
  final Duration duration;
  final Curve curve;

  @override
  State<AppTabs> createState() => _AppTabsState();
}

class _AppTabsState extends State<AppTabs> {
  final GlobalKey _trackKey = GlobalKey();
  late List<GlobalKey> _tabKeys;
  Rect? _indicator;
  bool _indicatorReady = false;
  bool _indicatorUpdateScheduled = false;
  int _indicatorMeasureAttempts = 0;

  @override
  void initState() {
    super.initState();
    _syncKeys();
    _scheduleIndicatorUpdate();
  }

  @override
  void didUpdateWidget(covariant AppTabs oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _syncKeys();
      _indicatorReady = false;
      _indicatorMeasureAttempts = 0;
    }
    if (oldWidget.index != widget.index ||
        oldWidget.children.length != widget.children.length ||
        oldWidget.expand != widget.expand ||
        oldWidget.iconOnly != widget.iconOnly ||
        oldWidget.padding != widget.padding ||
        oldWidget.children != widget.children) {
      _indicatorMeasureAttempts = 0;
      _scheduleIndicatorUpdate();
    }
  }

  void _syncKeys() {
    _tabKeys = List<GlobalKey>.generate(
      widget.children.length,
      (_) => GlobalKey(),
    );
  }

  void _scheduleIndicatorUpdate() {
    if (_indicatorUpdateScheduled) return;
    _indicatorUpdateScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _indicatorUpdateScheduled = false;
      if (!mounted) return;
      final updated = _updateIndicator();
      if (!updated && _indicatorMeasureAttempts < 8) {
        _indicatorMeasureAttempts++;
        _scheduleIndicatorUpdate();
        return;
      }
      // Remeasure once more after fonts/async labels settle.
      if (updated) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          _updateIndicator();
        });
      }
    });
  }

  /// Returns true when a usable indicator rect was applied (or already current).
  bool _updateIndicator() {
    final trackContext = _trackKey.currentContext;
    if (trackContext == null || _tabKeys.isEmpty) return false;
    final trackBox = trackContext.findRenderObject() as RenderBox?;
    if (trackBox == null || !trackBox.hasSize) return false;

    final index = widget.index.clamp(0, _tabKeys.length - 1);
    final tabContext = _tabKeys[index].currentContext;
    if (tabContext == null) return false;
    final tabBox = tabContext.findRenderObject() as RenderBox?;
    if (tabBox == null || !tabBox.hasSize || tabBox.size.isEmpty) return false;

    final offset = tabBox.localToGlobal(Offset.zero, ancestor: trackBox);
    // Sub-pixel negatives get clipped to a flat edge on the first tab.
    final next = Rect.fromLTWH(
      offset.dx.clamp(0.0, trackBox.size.width),
      offset.dy.clamp(0.0, trackBox.size.height),
      tabBox.size.width,
      tabBox.size.height,
    );
    if (_indicator == next && _indicatorReady) return true;
    setState(() {
      _indicator = next;
      _indicatorReady = true;
    });
    return true;
  }

  EdgeInsetsGeometry _resolveTabPadding(BuildContext context) {
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final densityGap = theme.density.baseGap * scaling;
    final densityContentPadding = theme.density.baseContentPadding * scaling;
    final compTheme = shad.ComponentTheme.maybeOf<shad.TabsTheme>(context);
    final appTabsTheme = shad.ComponentTheme.maybeOf<AppTabsTheme>(context);
    return shad.styleValue(
      // With container inset gap×0.5 and iconSize 16, all(gap×0.5) yields a
      // square tab whose outer track matches [AppControlMetrics.height] (~32).
      defaultValue: widget.iconOnly
          ? EdgeInsets.all(densityGap * 0.5)
          : EdgeInsets.symmetric(
              horizontal: densityContentPadding,
              vertical: densityGap * 0.5,
            ),
      themeValue: widget.padding == null
          ? (appTabsTheme?.tabPadding ?? compTheme?.tabPadding)
          : null,
      widgetValue: widget.padding,
    );
  }

  Widget _childBuilder(
    BuildContext context,
    shad.TabContainerData data,
    Widget child,
  ) {
    final theme = shad.Theme.of(context);
    final appTabsTheme = shad.ComponentTheme.maybeOf<AppTabsTheme>(context);
    final tabPadding = _resolveTabPadding(context);
    final selected = data.index == widget.index;
    final selectedColor = widget.selectedColor ?? theme.colorScheme.primary;
    final selectedForeground =
        widget.selectedTextColor ??
        appTabsTheme?.selectedForegroundColor ??
        (widget.selectedColor == null
            ? theme.colorScheme.primaryForeground
            : (selectedColor.computeLuminance() > 0.179
                  ? const Color(0xff000000)
                  : const Color(0xffffffff)));
    final configuredUnselectedForeground =
        widget.unselectedForegroundColor ??
        appTabsTheme?.unselectedForegroundColor;
    final unselectedForeground =
        configuredUnselectedForeground ??
        (widget.unselectedColor == null
            ? null
            : (widget.unselectedColor!.computeLuminance() > 0.179
                  ? const Color(0xff000000)
                  : const Color(0xffffffff)));

    Widget applyForeground(Widget content, Color color) {
      return IconTheme.merge(
        data: IconThemeData(color: color),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: color),
          child: content,
        ),
      );
    }

    final textScaled = widget.iconOnly ? child : child.small().medium();
    final colored = selected
        ? applyForeground(textScaled, selectedForeground)
        : unselectedForeground == null
        ? textScaled.muted()
        : applyForeground(textScaled, unselectedForeground);
    final metrics = AppControlMetricsScope.resolve(context);
    final iconChild = widget.iconOnly
        ? IconTheme.merge(
            data: IconThemeData(size: metrics.iconSize),
            child: colored,
          )
        : colored;

    // Keep tabs intrinsic-width. Plain [Align] expands to the Row's max width
    // and stretches icon-only tabs into wide rectangles. Equal [padding] with
    // [iconOnly] then yields a square hit target around the icon.
    //
    // Until the overlay indicator has been measured, paint the selection on the
    // tab itself so the first frame is never a clipped/missing pill.
    final tab = DecoratedBox(
      decoration: BoxDecoration(
        color: selected && !_indicatorReady
            ? (widget.selectedColor ?? theme.colorScheme.primary)
            : const Color(0x00000000),
        borderRadius: BorderRadius.circular(theme.radiusMd),
      ),
      child: Padding(
        padding: tabPadding,
        child: Align(
          alignment: Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          child: iconChild,
        ),
      ),
    );

    return KeyedSubtree(
      key: _tabKeys[data.index],
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => widget.onChanged(data.index),
        child: MouseRegion(
          hitTestBehavior: HitTestBehavior.translucent,
          cursor: SystemMouseCursors.click,
          child: tab,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final densityGap = theme.density.baseGap * scaling;
    final compTheme = shad.ComponentTheme.maybeOf<shad.TabsTheme>(context);
    final containerPadding = shad.styleValue(
      defaultValue: EdgeInsets.all(densityGap * 0.5),
      themeValue: compTheme?.containerPadding,
    );
    final backgroundColor =
        widget.unselectedColor ??
        shad.styleValue(
          defaultValue: theme.colorScheme.muted,
          themeValue: compTheme?.backgroundColor,
        );
    final borderRadius = shad.styleValue(
      defaultValue: BorderRadius.circular(theme.radiusLg),
      themeValue: compTheme?.borderRadius,
    );
    final resolvedRadius = borderRadius is BorderRadius
        ? borderRadius
        : borderRadius.resolve(Directionality.of(context));
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    final duration = !_indicatorReady || reduceMotion
        ? Duration.zero
        : widget.duration;
    final indicator = _indicator;
    // Expanding equal-width cells would defeat square icon-only sizing.
    final expand = widget.expand && !widget.iconOnly;

    return shad.TabContainer(
      selected: widget.index,
      onSelect: widget.onChanged,
      builder: (context, children) {
        final track = Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: resolvedRadius,
          ),
          padding: containerPadding,
          child: NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (_) {
              _scheduleIndicatorUpdate();
              return true;
            },
            child: SizeChangedLayoutNotifier(
              child: IntrinsicHeight(
                child: Stack(
                  key: _trackKey,
                  // Avoid clipping the first tab's rounded indicator when the
                  // measured origin is slightly negative on the initial frame.
                  clipBehavior: Clip.none,
                  children: [
                    if (indicator != null)
                      AnimatedPositioned(
                        duration: duration,
                        curve: widget.curve,
                        left: indicator.left,
                        top: indicator.top,
                        width: indicator.width,
                        height: indicator.height,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color:
                                widget.selectedColor ??
                                theme.colorScheme.primary,
                            borderRadius: BorderRadius.circular(theme.radiusMd),
                          ),
                        ),
                      ),
                    Row(
                      mainAxisSize: expand
                          ? MainAxisSize.max
                          : MainAxisSize.min,
                      // Stretch fills parent height and defeats square icon-only
                      // tabs; center keeps each tab at its intrinsic size.
                      crossAxisAlignment: widget.iconOnly
                          ? CrossAxisAlignment.center
                          : CrossAxisAlignment.stretch,
                      children: expand
                          ? [
                              for (final child in children)
                                Expanded(child: child),
                            ]
                          : children,
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
        // Shrink-wrap when icon-only so a stretched parent Row cannot inflate
        // the track into a tall capsule around square tabs.
        if (!widget.iconOnly) return track;
        return Align(
          alignment: Alignment.center,
          widthFactor: 1,
          heightFactor: 1,
          child: track,
        );
      },
      childBuilder: _childBuilder,
      children: widget.children,
    );
  }
}
