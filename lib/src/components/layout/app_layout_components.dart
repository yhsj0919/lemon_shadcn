import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart' as shad;

typedef AppAccordion = shad.Accordion;
typedef AppAccordionItem = shad.AccordionItem;
typedef AppAccordionTrigger = shad.AccordionTrigger;
typedef AppAlert = shad.Alert;
typedef AppCard = shad.Card;
typedef AppDivider = shad.Divider;
typedef AppOutlinedContainer = shad.OutlinedContainer;
typedef AppTimelineData = shad.TimelineData;
typedef AppCarouselController = shad.CarouselController;
typedef AppCarouselTransition = shad.CarouselTransition;
typedef AppCarouselAlignment = shad.CarouselAlignment;
typedef AppCarouselSizeConstraint = shad.CarouselSizeConstraint;
typedef AppCarouselFixedConstraint = shad.CarouselFixedConstraint;
typedef AppCarouselFractionalConstraint = shad.CarouselFractionalConstraint;
typedef AppStepperController = shad.StepperController;
typedef AppStepperValue = shad.StepperValue;
typedef AppStep = shad.Step;
typedef AppTree<T> = shad.Tree<T>;
typedef AppTreeNode<T> = shad.TreeNode<T>;
typedef AppTreeItemNode<T> = shad.TreeItemNode<T>;
typedef AppTable = shad.Table;
typedef AppTableRow = shad.TableRow;
typedef AppTableHeader = shad.TableHeader;
typedef AppTableFooter = shad.TableFooter;
typedef AppTableCell = shad.TableCell;
typedef AppScaffold = shad.Scaffold;
typedef AppAppBar = shad.AppBar;
typedef AppDashedLine = shad.DashedLine;
typedef AppDashedContainer = shad.DashedContainer;

class AppTreeItem extends StatefulWidget {
  const AppTreeItem({
    super.key,
    required this.child,
    this.leading,
    this.trailing,
    this.onPressed,
    this.onDoublePressed,
    this.onExpand,
    this.expandable,
    this.focusNode,
  });

  final Widget child;
  final Widget? leading;
  final Widget? trailing;
  final VoidCallback? onPressed;
  final VoidCallback? onDoublePressed;
  final ValueChanged<bool>? onExpand;
  final bool? expandable;
  final FocusNode? focusNode;

  @override
  State<AppTreeItem> createState() => _AppTreeItemState();
}

class _AppTreeItemState extends State<AppTreeItem> {
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
  }

  @override
  void didUpdateWidget(covariant AppTreeItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNode != widget.focusNode) {
      if (oldWidget.focusNode == null) _focusNode.dispose();
      _focusNode = widget.focusNode ?? FocusNode();
    }
  }

  @override
  void dispose() {
    if (widget.focusNode == null) _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return shad.TreeItem(
      leading: widget.leading,
      trailing: widget.trailing,
      onPressed: widget.onPressed,
      onDoublePressed: widget.onDoublePressed,
      onExpand: widget.onExpand == null
          ? null
          : (expanded) {
              _focusNode.requestFocus();
              widget.onExpand!(expanded);
            },
      expandable: widget.expandable,
      focusNode: _focusNode,
      child: widget.child,
    );
  }
}

typedef AppResizablePanel = AppResizable;

class AppResizable extends shad.ResizablePanel {
  const AppResizable.horizontal({
    super.key,
    required super.children,
    super.dividerBuilder = shad.ResizablePanel.defaultDividerBuilder,
    super.draggerBuilder = defaultDraggerBuilder,
    super.draggerThickness,
    super.optionalDivider = false,
  }) : super.horizontal();

  const AppResizable.vertical({
    super.key,
    required super.children,
    super.dividerBuilder = shad.ResizablePanel.defaultDividerBuilder,
    super.draggerBuilder = defaultDraggerBuilder,
    super.draggerThickness,
    super.optionalDivider = false,
  }) : super.vertical();

  const AppResizable({
    super.key,
    required super.direction,
    required super.children,
    super.dividerBuilder = shad.ResizablePanel.defaultDividerBuilder,
    super.draggerBuilder = defaultDraggerBuilder,
    super.draggerThickness,
    super.optionalDivider = false,
  });

  static Widget? defaultDraggerBuilder(BuildContext context) {
    final direction = shad.Data.of<shad.ResizableData>(context).direction;
    final theme = shad.Theme.of(context);
    final color = theme.colorScheme.mutedForeground;
    final dots = [
      for (var index = 0; index < 3; index++)
        DecoratedBox(
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          child: const SizedBox.square(dimension: 2),
        ),
    ];
    final verticalDivider = direction == Axis.horizontal;
    return Center(
      child: Container(
        width: verticalDivider ? 10 : 20,
        height: verticalDivider ? 20 : 10,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: theme.colorScheme.muted,
          borderRadius: BorderRadius.circular(4),
        ),
        child: verticalDivider
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < dots.length; index++) ...[
                    if (index > 0) const SizedBox(height: 1.5),
                    dots[index],
                  ],
                ],
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < dots.length; index++) ...[
                    if (index > 0) const SizedBox(width: 1.5),
                    dots[index],
                  ],
                ],
              ),
      ),
    );
  }
}

class AppResizablePane extends shad.ResizablePane {
  const AppResizablePane({
    super.key,
    required super.initialSize,
    super.minSize = 80,
    super.maxSize,
    super.collapsedSize,
    required super.child,
    super.onSizeChangeStart,
    super.onSizeChange,
    super.onSizeChangeEnd,
    super.onSizeChangeCancel,
    super.initialCollapsed = false,
  });

  const AppResizablePane.flex({
    super.key,
    super.initialFlex = 1,
    super.minSize = 80,
    super.maxSize,
    super.collapsedSize,
    required super.child,
    super.onSizeChangeStart,
    super.onSizeChange,
    super.onSizeChangeEnd,
    super.onSizeChangeCancel,
    super.initialCollapsed = false,
  }) : super.flex();

  const AppResizablePane.controlled({
    super.key,
    required super.controller,
    super.minSize = 80,
    super.maxSize,
    super.collapsedSize,
    required super.child,
    super.onSizeChangeStart,
    super.onSizeChange,
    super.onSizeChangeEnd,
    super.onSizeChangeCancel,
  }) : super.controlled();
}

class AppCarousel extends StatefulWidget {
  const AppCarousel({
    super.key,
    required this.itemBuilder,
    required this.transition,
    this.itemCount,
    this.controller,
    this.alignment = shad.CarouselAlignment.center,
    this.direction = Axis.horizontal,
    this.wrap = true,
    this.pauseOnHover = true,
    this.autoplaySpeed,
    this.waitOnStart = false,
    this.draggable = true,
    this.reverse = false,
    this.autoplayReverse = false,
    this.sizeConstraint = const shad.CarouselFractionalConstraint(1),
    this.speed = const Duration(milliseconds: 200),
    this.curve = Curves.easeInOut,
    this.duration,
    this.durationBuilder,
    this.onIndexChanged,
    this.disableOverheadScrolling = true,
    this.disableDraggingVelocity = false,
  });

  final shad.CarouselItemBuilder itemBuilder;
  final int? itemCount;
  final shad.CarouselController? controller;
  final shad.CarouselAlignment alignment;
  final Axis direction;
  final bool wrap;
  final bool pauseOnHover;
  final Duration? autoplaySpeed;
  final bool waitOnStart;
  final bool draggable;
  final bool reverse;
  final bool autoplayReverse;
  final shad.CarouselSizeConstraint sizeConstraint;
  final Duration speed;
  final Curve curve;
  final Duration? duration;
  final Duration? Function(int index)? durationBuilder;
  final ValueChanged<int>? onIndexChanged;
  final bool disableOverheadScrolling;
  final bool disableDraggingVelocity;
  final shad.CarouselTransition transition;

  @override
  State<AppCarousel> createState() => _AppCarouselState();
}

class _AppCarouselState extends State<AppCarousel> {
  late PageController _pageController;
  Timer? _autoplayTimer;
  Timer? _wheelSettleTimer;
  bool _hovered = false;
  int? _dragStartPage;

  double get _viewportFraction => switch (widget.sizeConstraint) {
        shad.CarouselFractionalConstraint(:final fraction) => fraction,
        _ => 1,
      };

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: _viewportFraction);
    _scheduleAutoplay();
  }

  @override
  void didUpdateWidget(AppCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_viewportFraction !=
        (oldWidget.sizeConstraint is shad.CarouselFractionalConstraint
            ? (oldWidget.sizeConstraint as shad.CarouselFractionalConstraint)
                .fraction
            : 1)) {
      final page = _pageController.hasClients
          ? (_pageController.page ?? 0).round()
          : 0;
      _pageController.dispose();
      _pageController = PageController(
        initialPage: page,
        viewportFraction: _viewportFraction,
      );
    }
    _scheduleAutoplay();
  }

  void _scheduleAutoplay() {
    _autoplayTimer?.cancel();
    final interval = widget.duration ?? widget.autoplaySpeed;
    if (interval == null) return;
    _autoplayTimer = Timer.periodic(interval, (_) {
      if (!mounted || (widget.pauseOnHover && _hovered)) return;
      _move(widget.autoplayReverse ? -1 : 1);
    });
  }

  void _move(int delta) {
    if (!_pageController.hasClients) return;
    final current = (_pageController.page ?? 0).round();
    var target = current + delta;
    if (!widget.wrap && widget.itemCount != null) {
      target = target.clamp(0, widget.itemCount! - 1);
    }
    _pageController.animateToPage(target, duration: widget.speed, curve: widget.curve);
  }

  void _queueWheelMove(int direction) {
    _wheelSettleTimer?.cancel();
    _wheelSettleTimer = Timer(const Duration(milliseconds: 180), () {
      if (mounted) _move(direction);
    });
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _wheelSettleTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.wrap ? null : widget.itemCount;
    return MouseRegion(
      onEnter: (_) => _hovered = true,
      onExit: (_) => _hovered = false,
      child: Listener(
        onPointerSignal: (event) {
          if (event is! PointerScrollEvent) return;
          final delta = widget.direction == Axis.horizontal
              ? (event.scrollDelta.dx == 0
                    ? event.scrollDelta.dy
                    : event.scrollDelta.dx)
              : event.scrollDelta.dy;
          if (delta == 0) return;
          GestureBinding.instance.pointerSignalResolver.register(
            event,
            (_) => _queueWheelMove(delta > 0 ? 1 : -1),
          );
        },
        child: ScrollConfiguration(
          behavior: const _AppCarouselScrollBehavior(),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification &&
                  notification.dragDetails != null) {
                _dragStartPage = (_pageController.page ?? 0).round();
              } else if (notification is ScrollUpdateNotification &&
                  _dragStartPage != null &&
                  _pageController.hasClients) {
                final page = _pageController.page ?? _dragStartPage!.toDouble();
                final minPage = _dragStartPage! - 1;
                final maxPage = _dragStartPage! + 1;
                if (page < minPage) {
                  _pageController.jumpToPage(minPage);
                } else if (page > maxPage) {
                  _pageController.jumpToPage(maxPage);
                }
              } else if (notification is ScrollEndNotification) {
                _dragStartPage = null;
              }
              return false;
            },
            child: PageView.builder(
              controller: _pageController,
              scrollDirection: widget.direction,
              reverse: widget.reverse,
              physics: widget.draggable
                  ? const PageScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              itemCount: count,
              onPageChanged: (page) {
                final itemCount = widget.itemCount;
                final index = itemCount == null || itemCount == 0
                    ? page
                    : page % itemCount;
                widget.onIndexChanged?.call(index);
              },
              itemBuilder: (context, page) {
                final itemCount = widget.itemCount;
                final index = itemCount == null || itemCount == 0
                    ? page
                    : page % itemCount;
                return widget.itemBuilder(context, index);
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AppCarouselScrollBehavior extends ScrollBehavior {
  const _AppCarouselScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => const {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
      };
}

class AppCollapsible extends StatelessWidget {
  const AppCollapsible({
    super.key,
    required this.children,
    this.isExpanded,
    this.onExpansionChanged,
    this.width,
  });

  final List<Widget> children;
  final bool? isExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final collapsible = shad.Collapsible(
      isExpanded: isExpanded,
      onExpansionChanged: onExpansionChanged,
      children: children,
    );
    return LayoutBuilder(
      builder: (context, constraints) {
        final resolvedWidth = width ??
            (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        if (resolvedWidth == null) return collapsible;
        return SizedBox(width: resolvedWidth, child: collapsible);
      },
    );
  }
}

class AppSteps extends StatelessWidget {
  const AppSteps({
    super.key,
    required this.children,
    this.axis = Axis.vertical,
  });

  const AppSteps.vertical({super.key, required this.children})
      : axis = Axis.vertical;

  const AppSteps.horizontal({super.key, required this.children})
      : axis = Axis.horizontal;

  final List<Widget> children;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    return _AppStepTrack(
      axis: axis,
      labels: children,
      state: const _AppStepTrackState(),
    );
  }
}

class AppStepper extends StatelessWidget {
  const AppStepper({
    super.key,
    required this.controller,
    required this.steps,
    this.direction,
    this.size,
    this.variant,
  });

  const AppStepper.vertical({
    super.key,
    required this.controller,
    required this.steps,
    this.size,
    this.variant,
  }) : direction = Axis.vertical;

  const AppStepper.horizontal({
    super.key,
    required this.controller,
    required this.steps,
    this.size,
    this.variant,
  }) : direction = Axis.horizontal;

  final shad.StepperController controller;
  final List<shad.Step> steps;
  final Axis? direction;
  final shad.StepSize? size;
  final shad.StepVariant? variant;

  @override
  Widget build(BuildContext context) {
    // Explicit upstream variants remain available; Lemon's default uses the
    // same track as AppSteps so node and text geometry cannot drift apart.
    if (variant != null) {
      return shad.Stepper(
        controller: controller,
        steps: steps,
        direction: direction,
        size: size,
        variant: variant,
      );
    }
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        final current = controller.value.currentStep;
        final axis = direction ?? Axis.horizontal;
        final scaling = shad.Theme.of(context).scaling;
        final indicatorSize = switch (size) {
          shad.StepSize.small => 24 * scaling,
          shad.StepSize.large => 32 * scaling,
          _ => 28 * scaling,
        };
        final track = _AppStepTrack(
          axis: axis,
          labels: [
            for (final step in steps)
              size?.wrapper(context, step.title) ?? step.title,
          ],
          icons: [for (final step in steps) step.icon],
          indicatorSize: indicatorSize,
          state: _AppStepTrackState(
            activeIndex: current,
            failed: controller.value.stepStates.keys.toSet(),
          ),
          onSelected: controller.jumpToStep,
        );
        final content = current >= 0 && current < steps.length
            ? steps[current].contentBuilder?.call(context)
            : null;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            track,
            if (content != null) ...[
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: KeyedSubtree(key: ValueKey(current), child: content),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _AppStepTrackState {
  const _AppStepTrackState({this.activeIndex, this.failed = const {}});

  final int? activeIndex;
  final Set<int> failed;
}

class _AppStepTrack extends StatelessWidget {
  const _AppStepTrack({
    required this.axis,
    required this.labels,
    required this.state,
    this.icons = const [],
    this.onSelected,
    this.indicatorSize,
  });

  final Axis axis;
  final List<Widget> labels;
  final List<Widget?> icons;
  final _AppStepTrackState state;
  final ValueChanged<int>? onSelected;
  final double? indicatorSize;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final config = shad.ComponentTheme.maybeOf<shad.StepsTheme>(context);
    final size = indicatorSize ?? config?.indicatorSize ?? 28 * theme.scaling;
    final gap = config?.spacing ?? 12 * theme.scaling;
    final thickness = config?.connectorThickness ?? 2 * theme.scaling;
    final idle = config?.indicatorColor ?? theme.colorScheme.muted;
    if (axis == Axis.horizontal) {
      return LayoutBuilder(builder: (context, constraints) {
        final inset = labels.isEmpty ? 0.0 : constraints.maxWidth / labels.length / 2;
        return Stack(children: [
          if (labels.length > 1)
            Positioned(left: inset, right: inset, top: (size - thickness) / 2,
              child: Row(children: [
                for (var i = 0; i < labels.length - 1; i++)
                  Expanded(
                    child: Container(
                      height: thickness,
                      color: _connectorColor(context, i, idle),
                    ),
                  ),
              ])),
          Row(children: [
            for (var i = 0; i < labels.length; i++)
              Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
                _indicator(context, i, size, idle),
                SizedBox(height: gap),
                Center(child: labels[i]),
              ])),
          ]),
        ]);
      });
    }
    return Stack(children: [
      if (labels.length > 1)
        Positioned(
          left: (size - thickness) / 2,
          top: size / 2,
          bottom: size / 2,
          width: thickness,
          child: Column(children: [
            for (var i = 0; i < labels.length - 1; i++)
              Expanded(
                child: Container(
                  width: thickness,
                  color: _connectorColor(context, i, idle),
                ),
              ),
          ]),
        ),
      Column(mainAxisSize: MainAxisSize.min, children: [
        for (var i = 0; i < labels.length; i++) ...[
          Row(children: [
            _indicator(context, i, size, idle),
            SizedBox(width: gap),
            Expanded(
              child: SizedBox(
                height: size,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: labels[i],
                ),
              ),
            ),
          ]),
          if (i < labels.length - 1) SizedBox(height: gap),
        ],
      ]),
    ]);
  }

  Widget _indicator(BuildContext context, int index, double size, Color idle) {
    final theme = shad.Theme.of(context);
    final failed = state.failed.contains(index);
    final active = state.activeIndex;
    final selected = active != null && index <= active;
    final background = failed
        ? theme.colorScheme.destructive
        : selected ? theme.colorScheme.primary : idle;
    final foreground = selected || failed
        ? theme.colorScheme.primaryForeground
        : theme.colorScheme.foreground;
    final icon = index < icons.length ? icons[index] : null;
    return GestureDetector(
      onTap: onSelected == null ? null : () => onSelected!(index),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: background, shape: BoxShape.circle),
        child: DefaultTextStyle.merge(
          style: TextStyle(color: foreground),
          child: icon ?? Text('${index + 1}'),
        ),
      ),
    );
  }

  Color _connectorColor(BuildContext context, int index, Color idle) {
    final theme = shad.Theme.of(context);
    final active = state.activeIndex;
    if (active == null) return idle;
    if (state.failed.contains(index) || state.failed.contains(index + 1)) {
      return theme.colorScheme.destructive;
    }
    if (active > index) return theme.colorScheme.primary;
    return theme.colorScheme.border;
  }
}

class AppTimeline extends StatelessWidget {
  const AppTimeline({
    super.key,
    required this.data,
    this.timeConstraints,
    this.axis = Axis.vertical,
  });

  const AppTimeline.vertical({
    super.key,
    required this.data,
    this.timeConstraints,
  }) : axis = Axis.vertical;

  const AppTimeline.horizontal({
    super.key,
    required this.data,
    this.timeConstraints,
  }) : axis = Axis.horizontal;

  final List<shad.TimelineData> data;
  final BoxConstraints? timeConstraints;
  final Axis axis;

  @override
  Widget build(BuildContext context) {
    final theme = shad.Theme.of(context);
    final timelineTheme =
        shad.ComponentTheme.maybeOf<shad.TimelineTheme>(context);
    final scaling = theme.scaling;
    final resolvedTimeConstraints = timeConstraints ?? timelineTheme?.timeConstraints;
    final spacing = timelineTheme?.spacing ?? 16 * scaling;
    final dotSize = timelineTheme?.dotSize ?? 12 * scaling;
    final connectorThickness =
        timelineTheme?.connectorThickness ?? 2 * scaling;
    final defaultColor = timelineTheme?.color ?? theme.colorScheme.primary;
    final rowGap = timelineTheme?.rowGap ?? 16 * scaling;
    final headerHeight = dotSize > 28 * scaling ? dotSize : 28 * scaling;

    if (axis == Axis.horizontal) {
      return LayoutBuilder(
        builder: (context, constraints) {
          final endInset = data.isEmpty
              ? 0.0
              : constraints.maxWidth / data.length / 2;
          return Stack(
            children: [
              if (data.length > 1)
                Positioned(
                  left: endInset,
                  right: endInset,
                  top: headerHeight + (dotSize - connectorThickness) / 2,
                  child: Container(
                    height: connectorThickness,
                    color: defaultColor,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < data.length; index++)
                    Expanded(
                      child: Column(
                        children: [
                          SizedBox(
                            height: headerHeight,
                            child: Center(child: data[index].time),
                          ),
                          Container(
                            width: dotSize,
                            height: dotSize,
                            decoration: BoxDecoration(
                              color: data[index].color ?? defaultColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(height: 8 * scaling),
                          DefaultTextStyle.merge(
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: theme.colorScheme.secondaryForeground,
                              fontWeight: FontWeight.w600,
                            ),
                            child: data[index].title,
                          ),
                          if (data[index].content != null) ...[
                            SizedBox(height: 4 * scaling),
                            DefaultTextStyle.merge(
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: theme.colorScheme.mutedForeground,
                              ),
                              child: data[index].content!,
                            ),
                          ],
                        ],
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      );
    }

    return Table(
      defaultVerticalAlignment: TableCellVerticalAlignment.top,
      columnWidths: {
        0: const IntrinsicColumnWidth(),
        1: FixedColumnWidth(spacing),
        2: FixedColumnWidth(dotSize),
        3: FixedColumnWidth(spacing),
        4: const FlexColumnWidth(),
      },
      children: [
        for (var index = 0; index < data.length; index++)
          TableRow(
            children: [
              ConstrainedBox(
                constraints: resolvedTimeConstraints ?? const BoxConstraints(),
                child: SizedBox(
                  height: headerHeight,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: DefaultTextStyle.merge(
                      style: const TextStyle(fontWeight: FontWeight.w500),
                      child: data[index].time,
                    ),
                  ),
                ),
              ),
              const SizedBox.shrink(),
              TableCell(
                verticalAlignment: TableCellVerticalAlignment.fill,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    if (index != data.length - 1)
                      Positioned(
                        top: headerHeight / 2,
                        bottom: -headerHeight / 2,
                        left: (dotSize - connectorThickness) / 2,
                        child: Container(
                          width: connectorThickness,
                          color: data[index].color ?? defaultColor,
                        ),
                      ),
                    Positioned(
                      top: (headerHeight - dotSize) / 2,
                      left: 0,
                      child: Container(
                        width: dotSize,
                        height: dotSize,
                        decoration: BoxDecoration(
                          shape: theme.radius == 0
                              ? BoxShape.rectangle
                              : BoxShape.circle,
                          color: data[index].color ?? defaultColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox.shrink(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    height: headerHeight,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: DefaultTextStyle.merge(
                        style: TextStyle(
                          color: theme.colorScheme.secondaryForeground,
                          fontWeight: FontWeight.w600,
                        ),
                        child: data[index].title,
                      ),
                    ),
                  ),
                  if (data[index].content != null) ...[
                    SizedBox(height: 4 * scaling),
                    DefaultTextStyle.merge(
                      style: TextStyle(
                        color: theme.colorScheme.mutedForeground,
                      ),
                      child: data[index].content!,
                    ),
                  ],
                  if (index != data.length - 1) SizedBox(height: rowGap),
                ],
              ),
            ],
          ),
      ],
    );
  }
}

class AppCollapsibleTrigger extends StatelessWidget {
  const AppCollapsibleTrigger({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final state = shad.Data.of<shad.CollapsibleStateData>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: DefaultTextStyle.merge(
              style: const TextStyle(fontWeight: FontWeight.w600),
              child: child,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox.square(
            dimension: 40,
            child: shad.GhostButton(
              density: shad.ButtonDensity.icon,
              onPressed: state.handleTap,
              child: AnimatedRotation(
                turns: state.isExpanded ? 0.5 : 0,
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                child: const Icon(shad.LucideIcons.chevronDown, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AppCollapsibleContent extends StatelessWidget {
  const AppCollapsibleContent({
    super.key,
    required this.child,
    this.collapsible = true,
    this.duration = const Duration(milliseconds: 180),
  });

  final Widget child;
  final bool collapsible;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    final state = shad.Data.of<shad.CollapsibleStateData>(context);
    final visible = !collapsible || state.isExpanded;
    return TweenAnimationBuilder<double>(
      tween: Tween(end: visible ? 1 : 0),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) => ClipRect(
        child: Align(
          alignment: Alignment.topCenter,
          heightFactor: value,
          child: Opacity(
            opacity: value,
            child: IgnorePointer(ignoring: !visible, child: child),
          ),
        ),
      ),
      child: child,
    );
  }
}
