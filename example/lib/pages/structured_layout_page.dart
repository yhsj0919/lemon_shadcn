import 'package:lemon_shadcn/lemon_shadcn.dart';

import 'actions_page.dart';

class StructuredLayoutPage extends StatefulWidget {
  const StructuredLayoutPage({super.key});

  @override
  State<StructuredLayoutPage> createState() => _StructuredLayoutPageState();
}

class _StructuredLayoutPageState extends State<StructuredLayoutPage> {
  final _stepper = AppStepperController();

  @override
  void dispose() {
    _stepper.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final treeNodes = <AppTreeNode<String>>[
      AppTreeItemNode(
        data: 'lib',
        expanded: true,
        children: [
          AppTreeItemNode(data: 'components'),
          AppTreeItemNode(data: 'foundation'),
        ],
      ),
      AppTreeItemNode(data: 'test'),
    ];
    return ComponentPage(
      title: 'Structured layout',
      description: 'Resizable, sequential, hierarchical, and tabular layouts.',
      sections: [
        ComponentSection(
          title: 'Carousel',
          child: SizedBox(
            height: 120,
            child: AppCarousel(
              itemCount: 3,
              wrap: false,
              transition: const AppCarouselTransition.sliding(gap: 12),
              sizeConstraint: const AppCarouselFractionalConstraint(.72),
              itemBuilder: (context, index) =>
                  AppCard(child: Center(child: Text('Panel ${index + 1}'))),
            ),
          ),
        ),
        const ComponentSection(
          title: 'Resizable',
          child: SizedBox(
            height: 140,
            child: AppResizable.horizontal(
              draggerBuilder: AppResizable.defaultDraggerBuilder,
              children: [
                AppResizablePane(
                  initialSize: 180,
                  child: Center(child: Text('Files')),
                ),
                AppResizablePane.flex(child: Center(child: Text('Editor'))),
              ],
            ),
          ),
        ),
        ComponentSection(
          title: 'Stepper',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppStepper(
                controller: _stepper,
                steps: const [
                  AppStep(title: Text('Account')),
                  AppStep(title: Text('Profile')),
                  AppStep(title: Text('Review')),
                ],
              ),
              const Gap(12),
              AppButton.outline(
                onPressed: () => _stepper.nextStep(),
                child: const Text('Next step'),
              ),
            ],
          ),
        ),
        ComponentSection(
          title: 'Tree',
          child: SizedBox(
            height: 150,
            child: AppTree<String>(
              nodes: treeNodes,
              shrinkWrap: true,
              builder: (context, item) => Text(item.data),
            ),
          ),
        ),
        const ComponentSection(
          title: 'Table',
          child: AppTable(
            rows: [
              AppTableHeader(
                cells: [
                  AppTableCell(child: Text('Component')),
                  AppTableCell(child: Text('Status')),
                ],
              ),
              AppTableRow(
                cells: [
                  AppTableCell(child: Text('AppForm')),
                  AppTableCell(child: Text('Ready')),
                ],
              ),
            ],
          ),
        ),
        const ComponentSection(
          title: 'Pinned sheet',
          child: SizedBox(
            height: 180,
            child: AppPinnedSheet(
              initialStage: AppPinnedSheetStage.expanded(),
              backdropTransform: AppScaleBackdropTransform(),
              backdrop: Center(child: Text('Backdrop content')),
              child: AppCard(child: Center(child: Text('Pinned tools'))),
            ),
          ),
        ),
        ComponentSection(
          title: 'Window',
          child: SizedBox(
            height: 260,
            child: AppWindowNavigator(
              showTopSnapBar: false,
              initialWindows: [
                AppWindow(
                  title: Text('Theme preview'),
                  content: Center(child: Text('Draggable desktop window')),
                  bounds: Rect.fromLTWH(24, 18, 320, 200),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
