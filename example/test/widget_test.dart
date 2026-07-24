import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn_example/main.dart';

void main() {
  testWidgets('renders the component gallery', (tester) async {
    await tester.pumpWidget(const ComponentGallery());

    expect(find.text('Button'), findsOneWidget);
    expect(find.text('Async primary'), findsOneWidget);
  });
}
