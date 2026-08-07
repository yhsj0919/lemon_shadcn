import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lemon_shadcn/lemon_shadcn.dart';
import 'package:lemon_shadcn/shadcn.dart' as shad;

void main() {
  Widget result(AppResultStatus status) =>
      AppResult(status: status, title: Text(status.name));

  Color iconColor(WidgetTester tester, IconData icon) =>
      IconTheme.of(tester.element(find.byIcon(icon))).color!;

  testWidgets('AppResult uses the shared light semantic palette', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(themeMode: AppThemeMode.light),
        ),
        home: Wrap(
          children: [
            result(AppResultStatus.success),
            result(AppResultStatus.info),
            result(AppResultStatus.warning),
            result(AppResultStatus.error),
            result(AppResultStatus.notFound),
          ],
        ),
      ),
    );

    expect(
      iconColor(tester, shad.LucideIcons.circleCheckBig),
      const Color(0xff16a34a),
    );
    expect(iconColor(tester, shad.LucideIcons.info), const Color(0xff2563eb));
    expect(
      iconColor(tester, shad.LucideIcons.triangleAlert),
      const Color(0xfff59e0b),
    );
    expect(
      iconColor(tester, shad.LucideIcons.circleX),
      const Color(0xffef4444),
    );
    expect(
      iconColor(tester, shad.LucideIcons.fileQuestion),
      AppThemeConfig.standard().lightTheme.colorScheme.mutedForeground,
    );
  });

  testWidgets('AppResult uses bright semantic colors in dark mode', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        builder: AppShadcnScope.builder(
          config: AppThemeConfig.standard(themeMode: AppThemeMode.dark),
        ),
        home: Column(
          children: [
            result(AppResultStatus.warning),
            result(AppResultStatus.error),
          ],
        ),
      ),
    );

    expect(
      iconColor(tester, shad.LucideIcons.triangleAlert),
      const Color(0xfffbbf24),
    );
    expect(
      iconColor(tester, shad.LucideIcons.circleX),
      const Color(0xffff5c5c),
    );
  });
}
