import 'package:flutter/services.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class DataDisplayPage extends StatelessWidget {
  const DataDisplayPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Data display',
      description: 'Compact components for identity, status, and values.',
      sections: [
        ComponentSection(
          title: 'Avatar and badges',
          child: Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const AppAvatar(initials: 'LS'),
              const AppAvatarGroup(
                alignment: Alignment.centerLeft,
                children: [
                  AppAvatar(initials: 'A'),
                  AppAvatar(initials: 'B'),
                  AppAvatar(initials: 'C'),
                ],
              ),
              AppBadge.primary(child: const Text('Primary')),
              AppBadge.secondary(child: const Text('Secondary')),
              AppBadge.outline(child: const Text('Outline')),
              AppBadge.destructive(child: const Text('Destructive')),
            ],
          ),
        ),
        ComponentSection(
          title: 'Progress',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AppProgress(progress: 0.64),
              const Gap(12),
              const Row(
                children: [
                  SizedBox.square(
                    dimension: 24,
                    child: AppCircularProgressIndicator(value: .64),
                  ),
                  Gap(12),
                  Expanded(child: AppLinearProgressIndicator(value: .64)),
                ],
              ),
              const Gap(12),
              AppNumberTicker(
                number: 1280,
                formatter: (value) => '${value.round()}',
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Code snippet',
          child: AppCodeSnippet(
            code: Text('final theme = AppThemeConfig.standard();'),
          ),
        ),
        ComponentSection(
          title: 'Calendar',
          child: AppCalendar(
            view: AppCalendarView.now(),
            selectionMode: CalendarSelectionMode.single,
            value: AppCalendarValue.single(DateTime.now()),
          ),
        ),
        const ComponentSection(
          title: 'Chips',
          child: Wrap(
            spacing: 8,
            children: [
              AppChip(child: Text('Flutter')),
              AppChip(child: Text('Desktop')),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Loading and position',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppSkeleton(
                child: Row(
                  children: [
                    AppAvatar(initials: 'LS'),
                    Gap(8),
                    Text('Loading profile data'),
                  ],
                ),
              ),
              Gap(16),
              AppDotIndicator(index: 1, length: 4),
              Gap(16),
              AppKeyboardDisplay(
                keys: [LogicalKeyboardKey.control, LogicalKeyboardKey.keyK],
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Tracker',
          child: AppTracker(
            data: [
              AppTrackerData(level: TrackerLevel.fine, tooltip: Text('Ready')),
              AppTrackerData(
                level: TrackerLevel.warning,
                tooltip: Text('Slow'),
              ),
              AppTrackerData(
                level: TrackerLevel.critical,
                tooltip: Text('Down'),
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Overflow and selectable text',
          child: SizedBox(
            width: 300,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppOverflowMarquee(
                  child: Text(
                    'Long content scrolls only when it exceeds the available width.',
                  ),
                ),
                Gap(12),
                AppSelectableText('This content can be selected and copied.'),
                Gap(12),
                SizedBox(
                  height: 56,
                  child: AppScrollbarView(
                    child: Text('Scrollable content\nLine two\nLine three'),
                  ),
                ),
              ],
            ),
          ),
        ),
        ComponentSection(
          title: 'Async view',
          child: AppAsyncView<List<String>>(
            load: () async => ['Theme', 'Components', 'Forms'],
            isEmpty: (items) => items.isEmpty,
            emptyBuilder: (context) => const Text('No modules'),
            builder: (context, items) => Wrap(
              spacing: 8,
              children: [for (final item in items) AppChip(child: Text(item))],
            ),
          ),
        ),
        const ComponentSection(
          title: 'Chat',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppChat(
                avatarPrefix: AppAvatar(initials: 'A'),
                children: [
                  AppChatBubble(child: Text('Can the theme be shared?')),
                  AppChatBubble(child: Text('Yes, through AppThemeConfig.')),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
