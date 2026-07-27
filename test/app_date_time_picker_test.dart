import 'package:flutter/material.dart' as material;
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  testWidgets('date and time fields register strongly typed values and reset', (
    tester,
  ) async {
    final controller = AppFormController();
    final initialDate = DateTime(2026, 7, 25);
    const initialTime = TimeOfDay(hour: 9, minute: 30);
    final initialRange = DateTimeRange(
      DateTime(2026, 7, 25),
      DateTime(2026, 7, 27),
    );

    await tester.pumpWidget(
      material.MaterialApp(
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
    final nextRange = DateTimeRange(DateTime(2026, 8, 1), DateTime(2026, 8, 3));
    const nextTime = TimeOfDay(hour: 14, minute: 45);
    tester.widget<DatePicker>(find.byType(DatePicker)).onChanged!(nextDate);
    tester.widget<DateRangePicker>(find.byType(DateRangePicker)).onChanged!(
      nextRange,
    );
    tester.widget<TimePicker>(find.byType(TimePicker)).onChanged!(nextTime);
    await tester.pump();

    expect(controller.value<DateTime>('date'), nextDate);
    expect(controller.value<DateTimeRange>('range'), nextRange);
    expect(controller.value<TimeOfDay>('time'), nextTime);

    controller.reset();
    await tester.pump();
    expect(controller.value<DateTime>('date'), initialDate);
    expect(controller.value<DateTimeRange>('range'), initialRange);
    expect(controller.value<TimeOfDay>('time'), initialTime);
  });

  testWidgets('date picker opens inside the shared overlay host', (
    tester,
  ) async {
    await tester.pumpWidget(
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppDatePicker(
          value: null,
          onChanged: (_) {},
          placeholder: const Text('Choose date'),
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
      material.MaterialApp(
        builder: AppShadcnScope.builder(),
        home: AppTimePicker(
          value: null,
          onChanged: (_) {},
          placeholder: const Text('Choose time'),
        ),
      ),
    );

    await tester.tap(find.text('Choose time'));
    await tester.pumpAndSettle();
    expect(find.byType(TimePickerDialog), findsOneWidget);
  });
}
