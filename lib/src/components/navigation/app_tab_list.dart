import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

/// Horizontal tab list with a sliding underline indicator.
class AppTabList extends StatefulWidget {
  const AppTabList({
    super.key,
    required this.children,
    required this.index,
    required this.onChanged,
    this.duration = const Duration(milliseconds: 220),
    this.curve = Curves.easeOutCubic,
  });

  final List<shad.TabChild> children;
  final int index;
  final ValueChanged<int>? onChanged;
  final Duration duration;
  final Curve curve;

  @override
  State<AppTabList> createState() => _AppTabListState();
}

class _AppTabListState extends State<AppTabList> {
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
  void didUpdateWidget(covariant AppTabList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.children.length != widget.children.length) {
      _syncKeys();
      _indicatorReady = false;
    }
    if (oldWidget.index != widget.index ||
        oldWidget.children.length != widget.children.length) {
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
    final next = Rect.fromLTWH(offset.dx, 0, tabBox.size.width, 0);
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
    final selected = data.index == widget.index;
    final button = shad.TabButton(
      enabled: data.onSelect != null,
      onPressed: () => data.onSelect?.call(data.index),
      child: selected ? child.foreground() : child.muted(),
    );
    return KeyedSubtree(key: _tabKeys[data.index], child: button);
  }

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final scaling = theme.scaling;
    final compTheme = shad.ComponentTheme.maybeOf<shad.TabListTheme>(context);
    final borderColor = shad.styleValue(
      defaultValue: theme.colorScheme.border,
      themeValue: compTheme?.borderColor,
    );
    final borderWidth = shad.styleValue(
      defaultValue: 1 * scaling,
      themeValue: compTheme?.borderWidth,
    );
    final indicatorColor = shad.styleValue(
      defaultValue: theme.colorScheme.primary,
      themeValue: compTheme?.indicatorColor,
    );
    final indicatorHeight = shad.styleValue(
      defaultValue: 2 * scaling,
      themeValue: compTheme?.indicatorHeight,
    );
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
            border: Border(
              bottom: BorderSide(color: borderColor, width: borderWidth),
            ),
          ),
          child: Stack(
            key: _trackKey,
            children: [
              Row(children: children),
              if (indicator != null)
                AnimatedPositioned(
                  duration: duration,
                  curve: widget.curve,
                  left: indicator.left,
                  width: indicator.width,
                  bottom: 0,
                  height: indicatorHeight,
                  child: ColoredBox(color: indicatorColor),
                ),
            ],
          ),
        );
      },
      childBuilder: _childBuilder,
      children: widget.children,
    );
  }
}
