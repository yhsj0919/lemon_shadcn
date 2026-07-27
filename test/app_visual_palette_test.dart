import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';

void main() {
  test('resolves combined visual states in documented priority', () {
    const normal = AppVisualColors(background: Color(0xff000001));
    const hovered = AppVisualColors(background: Color(0xff000002));
    const selected = AppVisualColors(background: Color(0xff000003));
    const selectedHovered = AppVisualColors(background: Color(0xff000004));
    const invalid = AppVisualColors(background: Color(0xff000005));
    const disabled = AppVisualColors(background: Color(0xff000006));
    const palette = AppVisualPalette(
      normal: normal,
      hovered: hovered,
      selected: selected,
      selectedHovered: selectedHovered,
      invalid: invalid,
      disabled: disabled,
    );

    expect(
      palette.resolve({WidgetState.selected, WidgetState.hovered}),
      same(selectedHovered),
    );
    expect(
      palette.resolve({WidgetState.selected, WidgetState.error}),
      same(invalid),
    );
    expect(
      palette.resolve({WidgetState.disabled, WidgetState.error}),
      same(disabled),
    );
  });
}
