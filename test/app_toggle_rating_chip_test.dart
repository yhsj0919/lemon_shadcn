import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('toggle and rating fields collect values and reset', (
    tester,
  ) async {
    final controller = AppFormController();
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(
            controls: const AppControlMetrics(height: 42),
          ),
        ),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppToggleFormField(name: 'pinned', child: const Text('Pinned')),
              AppStarRatingFormField(name: 'rating', initialValue: 2),
            ],
          ),
        ),
      ),
    );

    tester.widget<Toggle>(find.byType(Toggle)).onChanged!(true);
    tester.widget<StarRating>(find.byType(StarRating)).onChanged!(4.5);
    await tester.pump();
    expect(controller.value<bool>('pinned'), isTrue);
    expect(controller.value<double>('rating'), 4.5);
    expect(tester.getSize(find.byType(AppControlBox).first).height, 42);

    controller.reset();
    await tester.pump();
    expect(controller.value<bool>('pinned'), isFalse);
    expect(controller.value<double>('rating'), 2);
  });

  testWidgets(
    'chip input keeps formatted values, rejects duplicates and resets',
    (tester) async {
      final controller = AppFormController();
      await tester.pumpWidget(
        material.MaterialApp(
          builder: AppShadcnScope.builder(),
          home: AppForm(
            controller: controller,
            child: AppChipInputFormField<String>(
              name: 'tags',
              initialValue: const ['flutter'],
            ),
          ),
        ),
      );

      ChipInput<String> input() =>
          tester.widget<ChipInput<String>>(find.byType(ChipInput<String>));
      final editingController = input().controller!;
      editingController.text = '${editingController.text}desktop';
      editingController.selection = TextSelection.collapsed(
        offset: editingController.text.length,
      );
      editingController.insertChipAtCursor(input().onChipSubmitted);
      input().onChipsChanged!(editingController.chips);
      await tester.pump();
      expect(controller.value<List<String>>('tags'), ['flutter', 'desktop']);

      editingController.text = '${editingController.text}desktop';
      editingController.selection = TextSelection.collapsed(
        offset: editingController.text.length,
      );
      editingController.insertChipAtCursor(input().onChipSubmitted);
      input().onChipsChanged!(editingController.chips);
      await tester.pump();
      expect(controller.value<List<String>>('tags'), ['flutter', 'desktop']);

      controller.reset();
      await tester.pumpAndSettle();
      expect(controller.value<List<String>>('tags'), ['flutter']);
      expect(input().controller!.chips, ['flutter']);
    },
  );
}
