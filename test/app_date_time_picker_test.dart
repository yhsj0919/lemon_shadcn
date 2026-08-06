import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  testWidgets('date and time fields register strongly typed values and reset', (
    tester,
  ) async {
    final controller = AppFormController();
    final initialDate = DateTime(2026, 7, 25);
    const initialTime = shad.TimeOfDay(hour: 9, minute: 30);
    final initialRange = shad.DateTimeRange(
      DateTime(2026, 7, 25),
      DateTime(2026, 7, 27),
    );

    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppForm(
          controller: controller,
          child: Column(
            children: [
              AppDatePickerFormField(name: 'date', initialValue: initialDate),
              AppDateRangePickerFormField(
                name: 'range',
                initialValue: initialRange,
              ),
              AppTimePickerFormField(name: 'time', initialValue: initialTime),
            ],
          ),
        ),
      ),
    );

    final nextDate = DateTime(2026, 8, 1);
    final nextRange = shad.DateTimeRange(DateTime(2026, 8, 1), DateTime(2026, 8, 3));
    const nextTime = shad.TimeOfDay(hour: 14, minute: 45);
    tester.widget<shad.DatePicker>(find.byType(shad.DatePicker)).onChanged!(nextDate);
    tester.widget<shad.DateRangePicker>(find.byType(shad.DateRangePicker)).onChanged!(
      nextRange,
    );
    tester.widget<shad.TimePicker>(find.byType(shad.TimePicker)).onChanged!(nextTime);
    await tester.pump();

    expect(controller.value<DateTime>('date'), nextDate);
    expect(controller.value<shad.DateTimeRange>('range'), nextRange);
    expect(controller.value<shad.TimeOfDay>('time'), nextTime);

    controller.reset();
    await tester.pump();
    expect(controller.value<DateTime>('date'), initialDate);
    expect(controller.value<shad.DateTimeRange>('range'), initialRange);
    expect(controller.value<shad.TimeOfDay>('time'), initialTime);
  });

  testWidgets('date picker opens inside the shared overlay host', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppDatePicker(
          value: null,
          onChanged: (_) {},
          hintText: 'Choose date',
        ),
      ),
    );

    await tester.tap(find.text('Choose date'));
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.escape);
    await tester.pumpAndSettle();
    expect(find.byType(DatePickerDialog), findsNothing);
  });

  testWidgets('time picker opens inside the shared overlay host', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppTimePicker(
          value: null,
          onChanged: (_) {},
          hintText: 'Choose time',
        ),
      ),
    );

    await tester.tap(find.text('Choose time'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });
}
