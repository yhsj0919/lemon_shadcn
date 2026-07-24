import 'package:flutter/material.dart' as material;
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('integrates with native Form validation and reset', (
    tester,
  ) async {
    final formKey = material.GlobalKey<material.FormState>();

    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: material.Form(
          key: formKey,
          child: AppTextFormField.email(
            label: 'Email',
            required: true,
            initialValue: 'initial@example.com',
          ),
        ),
      ),
    );

    expect(find.text('initial@example.com'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'invalid');
    await tester.pump();
    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(formKey.currentState!.validate(), isFalse);

    await tester.enterText(find.byType(TextField), 'valid@example.com');
    await tester.pump();
    expect(formKey.currentState!.validate(), isTrue);

    formKey.currentState!.reset();
    await tester.pump();
    expect(find.text('initial@example.com'), findsOneWidget);
  });
}
