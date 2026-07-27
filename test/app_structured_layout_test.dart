import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('structured layout aliases render with upstream data types', (
    tester,
  ) async {
    final stepper = AppStepperController();
    addTearDown(stepper.dispose);
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: 320,
                height: 90,
                child: AppCarousel(
                  itemCount: 2,
                  wrap: false,
                  transition: const AppCarouselTransition.fading(),
                  itemBuilder: (context, index) => Text('Slide $index'),
                ),
              ),
              SizedBox(
                width: 320,
                height: 90,
                child: AppResizable.horizontal(
                  children: const [
                    AppResizablePane(initialSize: 120, child: Text('Left')),
                    AppResizablePane.flex(child: Text('Right')),
                  ],
                ),
              ),
              AppStepper(
                controller: stepper,
                steps: const [
                  AppStep(title: Text('One')),
                  AppStep(title: Text('Two')),
                ],
              ),
              SizedBox(
                height: 80,
                child: AppTree<String>(
                  nodes: [AppTreeItemNode(data: 'Root')],
                  shrinkWrap: true,
                  builder: (context, item) => Text(item.data),
                ),
              ),
              const AppTable(
                rows: [
                  AppTableRow(cells: [AppTableCell(child: Text('Cell'))]),
                ],
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(Carousel), findsOneWidget);
    expect(find.byType(ResizablePanel), findsOneWidget);
    expect(find.byType(Stepper), findsOneWidget);
    expect(find.byType(Tree<String>), findsOneWidget);
    expect(find.byType(Table), findsOneWidget);
  });
}
