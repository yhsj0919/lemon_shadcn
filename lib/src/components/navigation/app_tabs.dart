import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Foreground defaults shared by [AppTabs] and [AppTabList].
class AppTabsTheme extends shad.ComponentThemeData {
  const AppTabsTheme({
    this.selectedForegroundColor,
    this.unselectedForegroundColor,
  });

  final Color? selectedForegroundColor;
  final Color? unselectedForegroundColor;
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
  final EdgeInsetsGeometry? padding;
  final bool expand;
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
    }
    if (oldWidget.index != widget.index ||
        oldWidget.children.length != widget.children.length ||
        oldWidget.expand != widget.expand ||
        oldWidget.padding != widget.padding) {
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateIndicator();
    });
  }

  void _updateIndicator() {
    final trackContext = _trackKey.currentContext;
    if (trackContext == null || _tabKeys.isEmpty) return;
    final trackBox = trackContext.findRenderObject() as RenderBox?;
    if (trackBox == null || !trackBox.hasSize) return;

    final index = widget.index.clamp(0, _tabKeys.length - 1);
    final tabContext = _tabKeys[index].currentContext;
    if (tabContext == null) return;
    final tabBox = tabContext.findRenderObject() as RenderBox?;
    if (tabBox == null || !tabBox.hasSize) return;

    final offset = tabBox.localToGlobal(Offset.zero, ancestor: trackBox);
    final next = offset & tabBox.size;
    if (_indicator == next && _indicatorReady) return;
    setState(() {
      _indicator = next;
      _indicatorReady = true;
    });
  }

  Widget _childBuilder(
    BuildContext context,
    shad.TabContainerData data,
    Widget child,
  ) {
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final densityGap = theme.density.baseGap * scaling;
    final densityContentPadding = theme.density.baseContentPadding * scaling;
    final compTheme = shad.ComponentTheme.maybeOf<shad.TabsTheme>(context);
    final appTabsTheme =
        shad.ComponentTheme.maybeOf<AppTabsTheme>(context);
    final tabPadding = shad.styleValue(
      defaultValue: EdgeInsets.symmetric(
        horizontal: densityContentPadding,
        vertical: densityGap * 0.5,
      ),
      themeValue: compTheme?.tabPadding,
      widgetValue: widget.padding,
    );
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
    final unselectedForeground = configuredUnselectedForeground ??
        (widget.unselectedColor == null
            ? null
            : (widget.unselectedColor!.computeLuminance() > 0.179
                  ? const Color(0xff000000)
                  : const Color(0xffffffff)));
    final unselectedChild = child.muted().small().medium();

    Widget applyForeground(Widget content, Color color) {
      return IconTheme.merge(
        data: IconThemeData(color: color),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: color),
          child: content,
        ),
      );
    }

    return KeyedSubtree(
      key: _tabKeys[data.index],
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTap: () => widget.onChanged(data.index),
        child: MouseRegion(
          hitTestBehavior: HitTestBehavior.translucent,
          cursor: SystemMouseCursors.click,
          child: Padding(
            padding: tabPadding,
            child: Align(
              alignment: Alignment.center,
              child: selected
                  ? applyForeground(child.small().medium(), selectedForeground)
                  : unselectedForeground == null
                  ? unselectedChild
                  : applyForeground(
                      child.small().medium(),
                      unselectedForeground,
                    ),
            ),
          ),
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
    final backgroundColor = widget.unselectedColor ??
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

    return shad.TabContainer(
      selected: widget.index,
      onSelect: widget.onChanged,
      builder: (context, children) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: resolvedRadius,
          ),
          padding: containerPadding,
          child: IntrinsicHeight(
            child: Stack(
              key: _trackKey,
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
                        color: widget.selectedColor ?? theme.colorScheme.primary,
                        borderRadius: BorderRadius.circular(theme.radiusMd),
                      ),
                    ),
                  ),
                Row(
                  mainAxisSize: widget.expand
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: widget.expand
                      ? [for (final child in children) Expanded(child: child)]
                      : children,
                ),
              ],
            ),
          ),
        );
      },
      childBuilder: _childBuilder,
      children: widget.children,
    );
  }
}
