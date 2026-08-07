import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test(
    'AppDescriptions uses compact and independently configurable spacing',
    () {
      const descriptions = AppDescriptions(
        items: [],
        margin: material.EdgeInsets.all(20),
      );

      expect(descriptions.padding, const material.EdgeInsets.all(12));
      expect(
        descriptions.tableCellPadding,
        const material.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      );
      expect(descriptions.margin, const material.EdgeInsets.all(20));
    },
  );

  testWidgets('table row stays compact with a form-height value', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: const material.Align(
          alignment: material.Alignment.topLeft,
          child: AppDescriptions(
            type: AppDescriptionsType.table,
            columns: 1,
            layout: AppDescriptionLayout.horizontal,
            items: [
              AppDescriptionItem(
                label: material.Text('名称'),
                value: material.SizedBox(height: 32, child: material.Text('值')),
              ),
            ],
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(material.Table)).height, 48);
  });
}
