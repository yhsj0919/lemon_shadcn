import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class MotionPage extends StatelessWidget {
  const MotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ComponentPage(
      title: 'Motion',
      description: 'Reusable desktop feedback with color-aware shadows.',
      sections: [
        ComponentSection(
          title: 'Hover effects',
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _Example(
                label: 'Lift',
                color: colors.primary,
                child: const AppMotion.lift(child: _Tile(label: 'Hover me')),
              ),
              _Example(
                label: 'Scale',
                color: colors.destructive,
                child: const AppMotion.scale(child: _Tile(label: 'Hover me')),
              ),
              _Example(
                label: 'Glow',
                color: colors.ring,
                child: const AppMotion.glow(child: _Tile(label: 'Hover me')),
              ),
              _Example(
                label: 'Tint',
                color: colors.accentForeground,
                child: const AppMotion.tint(child: _Tile(label: 'Hover me')),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Y-axis lift + Z-axis depth',
          child: AppVisualStyle(
            colors: AppVisualColors(
              border: colors.primary,
              accent: colors.primary,
            ),
            child: const SizedBox(
              height: 170,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: AppMotion.depth(child: _DepthTile()),
              ),
            ),
          ),
        ),
        const ComponentSection(
          title: 'Selected state palette',
          child: _SelectionPaletteDemo(),
        ),
        ComponentSection(
          title: 'Animation builders',
          child: Row(
            children: [
              AppAnimatedValueBuilder<double>(
                value: 1,
                initialValue: 0,
                duration: const Duration(milliseconds: 700),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: const Text('Animated value'),
                ),
              ),
              const Gap(24),
              AppRepeatedAnimationBuilder(
                start: 0,
                end: 1,
                duration: const Duration(seconds: 2),
                builder: (context, value, child) => Transform.scale(
                  scale: .9 + value * .1,
                  child: const Text('Repeated'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DepthTile extends StatelessWidget {
  const _DepthTile();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 280,
        height: 140,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Hover and move horizontally').h3(),
            const Gap(8),
            const Text(
              'translateY/Z + rotateX/Y · press to sink',
            ).small().muted(),
          ],
        ),
      ),
    );
  }
}

class _SelectionPaletteDemo extends StatefulWidget {
  const _SelectionPaletteDemo();

  @override
  State<_SelectionPaletteDemo> createState() => _SelectionPaletteDemoState();
}

class _SelectionPaletteDemoState extends State<_SelectionPaletteDemo> {
  bool _hovered = false;
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final states = <WidgetState>{
      if (_hovered) WidgetState.hovered,
      if (_selected) WidgetState.selected,
    };
    final palette = AppVisualPalette(
      normal: AppVisualColors(
        background: colors.card,
        foreground: colors.cardForeground,
        border: colors.border,
      ),
      hovered: AppVisualColors(
        background: colors.accent,
        foreground: colors.accentForeground,
        border: colors.ring,
      ),
      selected: AppVisualColors(
        background: colors.primary,
        foreground: colors.primaryForeground,
        border: colors.primary,
        shadow: colors.primary,
      ),
      selectedHovered: AppVisualColors(
        background: colors.primary,
        foreground: colors.primaryForeground,
        border: colors.ring,
        shadow: colors.primary,
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: () => setState(() => _selected = !_selected),
        child: AppAnimatedVisualStyle(
          states: states,
          palette: palette,
          child: Builder(
            builder: (context) {
              final visual = AppVisualStyle.of(context);
              return AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                width: 280,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: visual.background,
                  border: Border.all(color: visual.border!),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: DefaultTextStyle.merge(
                  style: TextStyle(color: visual.foreground),
                  child: Text(
                    _selected ? 'Selected · click to reset' : 'Click to select',
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Example extends StatelessWidget {
  const _Example({
    required this.label,
    required this.color,
    required this.child,
  });

  final String label;
  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppVisualStyle(
          colors: AppVisualColors(border: color, accent: color),
          child: child,
        ),
        const Gap(10),
        Text(label).small().muted(),
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
        width: 140,
        height: 88,
        child: Center(child: Text(label)),
      ),
    );
  }
}
