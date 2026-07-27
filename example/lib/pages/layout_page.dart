import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class LayoutPage extends StatelessWidget {
  const LayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ComponentPage(
      title: 'Layout and disclosure',
      description: 'Containers and progressive disclosure components.',
      sections: [
        const ComponentSection(
          title: 'Card',
          child: AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Default card'),
                Gap(6),
                Text('Style remains controlled by the upstream theme.'),
              ],
            ),
          ),
        ),
        const ComponentSection(
          title: 'Alert variants',
          child: Column(
            children: [
              AppAlert(
                title: Text('Information'),
                content: Text('Standard alert styling.'),
              ),
              Gap(12),
              AppAlert.destructive(
                title: Text('Action required'),
                content: Text('Destructive is a real upstream variant.'),
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Accordion',
          child: AppAccordion(
            items: [
              AppAccordionItem(
                trigger: AppAccordionTrigger(child: Text('Theme strategy')),
                content: Text(
                  'App aliases preserve upstream behavior and updates.',
                ),
              ),
              AppAccordionItem(
                trigger: AppAccordionTrigger(child: Text('Variants')),
                content: Text('Only real semantic variants use .xxx APIs.'),
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Collapsible and divider',
          child: AppCollapsible(
            children: [
              AppCollapsibleTrigger(child: Text('Advanced details')),
              AppCollapsibleContent(
                child: Column(
                  children: [
                    AppDivider(),
                    Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text('Hidden content follows the same theme.'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Steps',
          child: AppSteps(
            children: [
              Text('Configure the global theme'),
              Text('Add App-prefixed components'),
              Text('Verify categorized examples'),
            ],
          ),
        ),
        ComponentSection(
          title: 'Timeline',
          child: AppTimeline(
            data: [
              AppTimelineData(
                time: Text('09:00'),
                title: Text('Theme configured'),
              ),
              AppTimelineData(
                time: Text('11:30'),
                title: Text('Components verified'),
                content: Text('Static analysis and tests passed.'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
