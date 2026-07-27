import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test('component registry uses unique App names', () {
    final names = AppComponentRegistry.components
        .map((component) => component.appName)
        .toList();

    expect(names.toSet().length, names.length);
    expect(
      AppComponentRegistry.components.every(
        (component) => component.status == AppComponentStatus.implemented,
      ),
      isTrue,
    );
  });
}
