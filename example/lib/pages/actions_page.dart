import 'dart:async';

import 'package:lemon_shadcn/lemon_shadcn.dart';

class ActionsPage extends StatelessWidget {
  const ActionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Actions',
      description: 'Buttons and operations that trigger user actions.',
      sections: [
        ComponentSection(
          title: 'Button variants',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton.primary(
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 900));
                },
                loadingLabel: 'Saving',
                child: const Text('Async primary'),
              ),
              AppButton.secondary(
                onPressed: () {},
                child: const Text('Secondary'),
              ),
              AppButton.outline(onPressed: () {}, child: const Text('Outline')),
              AppButton.ghost(onPressed: () {}, child: const Text('Ghost')),
              AppButton.destructive(
                onPressed: () {},
                child: const Text('Destructive'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Buttons with icons',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppButton.primary(
                onPressed: () {},
                leading: const Icon(LucideIcons.plus),
                child: const Text('Create item'),
              ),
              AppButton.secondary(
                onPressed: () {},
                trailing: const Icon(LucideIcons.arrowRight),
                child: const Text('Continue'),
              ),
              AppButton.outline(
                onPressed: () async {
                  await Future<void>.delayed(const Duration(milliseconds: 900));
                },
                leading: const Icon(LucideIcons.download),
                loadingLabel: 'Downloading',
                child: const Text('Download'),
              ),
              AppButton.destructive(
                onPressed: () {},
                leading: const Icon(LucideIcons.trash2),
                child: const Text('Delete'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Square icon-only buttons',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppIconButton(
                key: const Key('square-icon-button-add'),
                tooltip: 'Add item',
                variant: AppButtonVariant.primary,
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
              ),
              AppIconButton(
                tooltip: 'Search',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
                icon: const Icon(LucideIcons.search),
              ),
              AppIconButton(
                key: const Key('square-icon-button-settings'),
                tooltip: 'Settings',
                onPressed: () {},
                icon: const Icon(LucideIcons.settings),
              ),
              AppIconButton(
                tooltip: 'Delete item',
                variant: AppButtonVariant.destructive,
                onPressed: () {},
                icon: const Icon(LucideIcons.trash2),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Circular icon-only buttons',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              AppIconButton.circle(
                key: const Key('icon-button-add'),
                tooltip: 'Add item',
                variant: AppButtonVariant.primary,
                onPressed: () {},
                icon: const Icon(LucideIcons.plus),
              ),
              AppIconButton.circle(
                key: const Key('icon-button-search'),
                tooltip: 'Search',
                variant: AppButtonVariant.secondary,
                onPressed: () {},
                icon: const Icon(LucideIcons.search),
              ),
              AppIconButton.circle(
                key: const Key('icon-button-settings'),
                tooltip: 'Settings',
                onPressed: () {},
                icon: const Icon(LucideIcons.settings),
              ),
              AppIconButton.circle(
                key: const Key('icon-button-delete'),
                tooltip: 'Delete item',
                variant: AppButtonVariant.destructive,
                onPressed: () {},
                icon: const Icon(LucideIcons.trash2),
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Shared async action',
          child: _SharedActionDemo(),
        ),
        ComponentSection(title: 'Toggle', child: const _ToggleDemo()),
      ],
    );
  }
}

class _SharedActionDemo extends StatefulWidget {
  const _SharedActionDemo();

  @override
  State<_SharedActionDemo> createState() => _SharedActionDemoState();
}

class _SharedActionDemoState extends State<_SharedActionDemo> {
  late final AppAsyncAction<void> _saveAction = AppAsyncAction(
    operation: () async {
      await Future<void>.delayed(const Duration(milliseconds: 900));
    },
    loadingDelay: const Duration(milliseconds: 120),
    minimumLoadingDuration: const Duration(milliseconds: 250),
  );

  @override
  void dispose() {
    _saveAction.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        AppButton.primary(
          action: _saveAction,
          loadingLabel: 'Saving',
          child: const Text('Save'),
        ),
        AppButton.outline(
          action: _saveAction,
          loadingLabel: 'Saving',
          child: const Text('Save from toolbar'),
        ),
      ],
    );
  }
}

class _ToggleDemo extends StatefulWidget {
  const _ToggleDemo();

  @override
  State<_ToggleDemo> createState() => _ToggleDemoState();
}

class _ToggleDemoState extends State<_ToggleDemo> {
  bool _selected = false;

  @override
  Widget build(BuildContext context) {
    return AppToggle(
      value: _selected,
      onChanged: (value) => setState(() => _selected = value),
      child: const Text('Pin toolbar'),
    );
  }
}

class ComponentPage extends StatelessWidget {
  const ComponentPage({
    super.key,
    required this.title,
    required this.description,
    required this.sections,
  });

  final String title;
  final String description;
  final List<Widget> sections;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title).h1(),
            const Gap(8),
            Text(description).muted(),
            const Gap(32),
            for (var index = 0; index < sections.length; index++) ...[
              if (index > 0) const Gap(24),
              sections[index],
            ],
          ],
        ),
      ),
    );
  }
}

class ComponentSection extends StatelessWidget {
  const ComponentSection({super.key, required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Text(title).h3(), const Gap(20), child],
        ),
      ),
    );
  }
}
