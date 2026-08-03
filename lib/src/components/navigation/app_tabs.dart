import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Segmented tabs with a sliding selection indicator.
class AppTabs extends StatefulWidget {
  const AppTabs({
    super.key,
    required this.index,
    required this.onChanged,
    required this.children,
    this.padding,
    this.expand = false,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final List<shad.TabChild> children;
  final EdgeInsetsGeometry? padding;
  final bool expand;
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
    final tabPadding = shad.styleValue(
      defaultValue: EdgeInsets.symmetric(
        horizontal: densityContentPadding,
        vertical: densityGap * 0.5,
      ),
      themeValue: compTheme?.tabPadding,
      widgetValue: widget.padding,
    );
    final selected = data.index == widget.index;

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
              child: (selected ? child.foreground() : child.muted())
                  .small()
                  .medium(),
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
    final backgroundColor = shad.styleValue(
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
                        color: theme.colorScheme.background,
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
