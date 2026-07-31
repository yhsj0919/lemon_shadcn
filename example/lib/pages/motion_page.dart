import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart';

import 'actions_page.dart';

class MotionPage extends StatelessWidget {
  const MotionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ShadcnTheme.of(context).colorScheme;
    const followCardColor = Color(0xFF14B8A6);
    return ComponentPage(
      title: '动效',
      description: '具有主题感知阴影的可复用桌面反馈。',
      sections: [
        ComponentSection(
          title: '悬浮效果',
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children: [
              _Example(
                label: '上浮',
                color: colors.primary,
                child: const AppMotion.lift(child: _Tile(label: '悬浮查看')),
              ),
              _Example(
                label: '缩放',
                color: colors.destructive,
                child: const AppMotion.scale(child: _Tile(label: '悬浮查看')),
              ),
              _Example(
                label: '发光',
                color: colors.ring,
                child: const AppMotion.glow(child: _Tile(label: '悬浮查看')),
              ),
              _Example(
                label: '着色',
                color: colors.accentForeground,
                child: const AppMotion.tint(child: _Tile(label: '悬浮查看')),
              ),
              _Example(
                label: '跟随卡片颜色',
                color: followCardColor,
                child: const AppVisualStyle(
                  colors: AppVisualColors(background: followCardColor),
                  child: AppMotion.glow(
                    shadowColorMode: AppShadowColorMode.background,
                    hoverLift: true,
                    child: _Tile(
                      label: '悬浮查看',
                      background: followCardColor,
                      foreground: Color(0xFFFFFFFF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Y 轴上浮与 Z 轴景深',
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
        const ComponentSection(title: '选中状态色板', child: _SelectionPaletteDemo()),
        const ComponentSection(title: '数值动画', child: _NumericAnimationDemo()),
        ComponentSection(
          title: '动画构建器',
          child: _AnimationBuildersDemo(color: colors.primary),
        ),
      ],
    );
  }
}

class _AnimationBuildersDemo extends StatefulWidget {
  const _AnimationBuildersDemo({required this.color});

  final Color color;

  @override
  State<_AnimationBuildersDemo> createState() => _AnimationBuildersDemoState();
}

class _AnimationBuildersDemoState extends State<_AnimationBuildersDemo> {
  int _replayKey = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppEntranceAnimation.fade(
              key: ValueKey(_replayKey),
              duration: const Duration(milliseconds: 700),
              child: const Icon(LucideIcons.sparkles),
            ),
            const Gap(8),
            const Text('淡入动画').small().muted(),
            const Gap(8),
            AppButton.outline(
              onPressed: () => setState(() => _replayKey++),
              child: const Text('重播'),
            ),
          ],
        ),
        const Gap(24),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppLoopAnimation.pulse(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                ),
                child: const SizedBox.square(dimension: 20),
              ),
            ),
            const Gap(8),
            const Text('循环动画').small().muted(),
          ],
        ),
      ],
    );
  }
}

class _NumericAnimationDemo extends StatefulWidget {
  const _NumericAnimationDemo();

  @override
  State<_NumericAnimationDemo> createState() => _NumericAnimationDemoState();
}

class _NumericAnimationDemoState extends State<_NumericAnimationDemo> {
  double _target = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 96,
          child: AppAnimatedValueBuilder<double>(
            value: _target,
            initialValue: 0,
            duration: const Duration(milliseconds: 700),
            curve: Curves.easeOutCubic,
            builder: (context, value, child) => Text(
              value.round().toString(),
              textAlign: TextAlign.center,
            ).h2(),
          ),
        ),
        const Gap(16),
        AppButton.outline(
          onPressed: () {
            setState(() => _target = _target == 100 ? 0 : 100);
          },
          child: const Text('切换数值'),
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
            const Text('悬浮并水平移动').h3(),
            const Gap(8),
            const Text('Y/Z 位移 + X/Y 旋转 · 按下时下沉').small().muted(),
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
    final colors = ShadcnTheme.of(context).colorScheme;
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
                  child: Text(_selected ? '已选中 · 点击重置' : '点击选择'),
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
  const _Tile({required this.label, this.background, this.foreground});

  final String label;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    return Card(
      filled: background != null,
      fillColor: background,
      borderColor: background,
      child: SizedBox(
        width: 140,
        height: 88,
        child: Center(
          child: Text(label, style: TextStyle(color: foreground)),
        ),
      ),
    );
  }
}
